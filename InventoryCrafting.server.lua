-- ANMOL: LIVING WORLD / Inventory + Crafting V1 (Resource Integration)
-- Install as Script in ServerScriptService.
-- Server-authoritative inventory, crafting, harvesting and DataStore persistence.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local MAX_TOTAL_ITEMS = 100
local HARVEST_DISTANCE = 15
local CRAFT_COOLDOWN = 0.35
local ITEMS = {
    Wood = true, Stone = true, Crystal = true, Fiber = true,
    StoneAxe = true, Sword = true, Torch = true, Bandage = true, NoiseDecoy = true,
}
local RECIPES = {
    StoneAxe = { Wood = 3, Stone = 2 },
    Sword = { Wood = 2, Stone = 5, Crystal = 1 },
    Torch = { Wood = 2, Fiber = 1 },
    Bandage = { Fiber = 3 },
    NoiseDecoy = { Stone = 2, Crystal = 1 },
}
local RECIPE_ORDER = { "StoneAxe", "Sword", "Torch", "Bandage", "NoiseDecoy" }
local NODE_YIELDS = { Wood = 3, Stone = 2, Crystal = 1, Fiber = 2 }

-- DataStore V1. Change DATASTORE_NAME only if you intentionally want a new save slot.
local DATASTORE_NAME = "AnmolLivingWorld_PlayerData_v1"
local SAVE_INTERVAL = 60
local LOCK_SECONDS = 180
local RETRIES = 3
local dataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
local sessionId = (game.JobId ~= "" and game.JobId or "studio") .. ":" .. HttpService:GenerateGUID(false)
local records = {} -- [player] = {inventory, progress, loaded, saving, dirty, closing, locked}

local function sanitizeCount(value, maxCount)
    if type(value) ~= "number" or value ~= value then return 0 end
    return math.clamp(math.floor(value), 0, maxCount)
end

local function safeProgress(raw)
    raw = type(raw) == "table" and raw or {}
    return {
        TreesCut = sanitizeCount(raw.TreesCut, 100000000),
        CrystalsMined = sanitizeCount(raw.CrystalsMined, 100000000),
        ItemsCrafted = sanitizeCount(raw.ItemsCrafted, 100000000),
    }
end

local function playerKey(player)
    return "Player_" .. tostring(player.UserId)
end

local function retryOperation(fn)
    local lastError
    for attempt = 1, RETRIES do
        local ok, result = pcall(fn)
        if ok then return true, result end
        lastError = tostring(result)
        if attempt < RETRIES then task.wait(attempt * 2) end
    end
    return false, lastError
end


local folder = ReplicatedStorage:FindFirstChild("AnmolInventoryRemotes")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "AnmolInventoryRemotes"
    folder.Parent = ReplicatedStorage
end
local function remote(name, className)
    local object = folder:FindFirstChild(name)
    if object then
        assert(object.ClassName == className, name .. " must be " .. className)
        return object
    end
    object = Instance.new(className)
    object.Name = name
    object.Parent = folder
    return object
end
local Snapshot = remote("Snapshot", "RemoteEvent")
local CraftRequest = remote("CraftRequest", "RemoteEvent")
local GetInventory = remote("GetInventory", "RemoteFunction")

local inventories = {} -- [player] = server-validated saved item counts
local lastCraftAt = {}
local nodeBusy = {} -- [instance] = true while depleted

local function newInventory()
    local inv = {}
    for item in pairs(ITEMS) do inv[item] = 0 end
    return inv
end
local function totalCount(inv)
    local total = 0
    for _, count in pairs(inv) do total += count end
    return total
end
local function copyInventory(inv)
    local copy = {}
    for item in pairs(ITEMS) do copy[item] = inv[item] or 0 end
    return copy
end
local function broadcast(player, message)
    local inv = inventories[player]
    if inv then Snapshot:FireClient(player, copyInventory(inv), message or "") end
end

-- Claim a DataStore session before enabling inventory actions. This helps prevent
-- two servers editing the same player data simultaneously.
local function openSession(player)
    local key = playerKey(player)
    local success, stored = retryOperation(function()
        return dataStore:UpdateAsync(key, function(previous)
            previous = type(previous) == "table" and previous or {}
            local lease = type(previous.lease) == "table" and previous.lease or nil
            if lease and lease.id ~= sessionId
                and type(lease.untilTime) == "number"
                and lease.untilTime > os.time() then
                return nil -- another session owns this save
            end
            return {
                version = 1,
                inventory = type(previous.inventory) == "table" and previous.inventory or {},
                progress = type(previous.progress) == "table" and previous.progress or {},
                lease = { id = sessionId, untilTime = os.time() + LOCK_SECONDS },
                updatedAt = previous.updatedAt,
            }
        end)
    end)
    if not success or type(stored) ~= "table" or type(stored.lease) ~= "table"
        or stored.lease.id ~= sessionId then
        return nil, success and "Data already open in another server" or tostring(stored)
    end
    local inv = newInventory()
    local raw = type(stored.inventory) == "table" and stored.inventory or {}
    local remaining = MAX_TOTAL_ITEMS
    -- Consistent order makes total-cap sanitization deterministic.
    for _, item in ipairs({"Wood", "Stone", "Crystal", "Fiber", "StoneAxe", "Torch", "Bandage", "NoiseDecoy"}) do
        inv[item] = math.min(sanitizeCount(raw[item], MAX_TOTAL_ITEMS), remaining)
        remaining -= inv[item]
    end
    return {inventory = inv, progress = safeProgress(stored.progress), loaded = true,
        saving = false, dirty = false, closing = false, locked = true}
end

local function setProgressAttributes(player, record)
    player:SetAttribute("AnmolTreesCut", record.progress.TreesCut)
    player:SetAttribute("AnmolCrystalsMined", record.progress.CrystalsMined)
    player:SetAttribute("AnmolItemsCrafted", record.progress.ItemsCrafted)
end

local function saveSession(player, release)
    local record = records[player]
    if not record or not record.loaded or not record.locked then return false end
    while record.saving do task.wait(0.1) end
    record.saving = true
    -- Capture server-validated snapshot; never trust numbers supplied by the client.
    local inventory = copyInventory(record.inventory)
    local progress = safeProgress(record.progress)
    local success, result = retryOperation(function()
        return dataStore:UpdateAsync(playerKey(player), function(previous)
            if type(previous) ~= "table" or type(previous.lease) ~= "table"
                or previous.lease.id ~= sessionId then
                return nil -- don't overwrite a save owned by another server
            end
            local nextData = {
                version = 1,
                inventory = inventory,
                progress = progress,
                updatedAt = os.time(),
            }
            if not release then
                nextData.lease = {id = sessionId, untilTime = os.time() + LOCK_SECONDS}
            end
            return nextData
        end)
    end)
    record.saving = false
    if success and type(result) == "table" then
        if release then record.locked = false end
        record.dirty = false
        return true
    end
    warn("[Anmol Save] Save failed for", player.UserId, tostring(result))
    return false
end

local function setupPlayer(player)
    local record, reason = openSession(player)
    if not record then
        warn("[Anmol Save] Load failed for", player.UserId, reason)
        player:Kick("Unable to safely load your save. Please retry in a moment.")
        return
    end
    if not player.Parent then
        -- Disconnect occurred while loading; create record to release the lease.
        records[player] = record
        saveSession(player, true)
        records[player] = nil
        return
    end
    records[player] = record
    inventories[player] = record.inventory
    lastCraftAt[player] = 0
    setProgressAttributes(player, record)
    broadcast(player, "Your inventory is loaded")
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(setupPlayer, player)
end)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
    local record = records[player]
    if record then
        record.closing = true
        saveSession(player, true)
    end
    inventories[player] = nil
    records[player] = nil
    lastCraftAt[player] = nil
end)

-- Save regularly (also refreshes the server lease even if no items changed).
task.spawn(function()
    while true do
        task.wait(SAVE_INTERVAL)
        for player, record in pairs(records) do
            if player.Parent and not record.closing then
                task.spawn(function() saveSession(player, false) end)
            end
        end
    end
end)

game:BindToClose(function()
    local pending = 0
    for player, record in pairs(records) do
        if record.loaded and record.locked then
            pending += 1
            task.spawn(function()
                saveSession(player, true)
                pending -= 1
            end)
        end
    end
    local deadline = os.clock() + 25
    while pending > 0 and os.clock() < deadline do task.wait(0.1) end
end)

-- Building V1 uses this server-only bridge, never a client-controlled inventory number.
-- Add this only once. The building server invokes it after placement validation.
local spendBridge = game:GetService("ServerScriptService"):FindFirstChild("AnmolSpendResources")
if not spendBridge then
    spendBridge = Instance.new("BindableFunction")
    spendBridge.Name = "AnmolSpendResources"
    spendBridge.Parent = game:GetService("ServerScriptService")
end
spendBridge.OnInvoke = function(player, costs)
    if typeof(player) ~= "Instance" or not player:IsA("Player") then return false, "Invalid player" end
    if type(costs) ~= "table" then return false, "Invalid cost" end
    local inv = inventories[player]
    local record = records[player]
    if not inv or not record or not record.loaded or record.closing or not record.locked then
        return false, "Inventory not ready"
    end
    for item, amount in pairs(costs) do
        if (item ~= "Wood" and item ~= "Stone") or type(amount) ~= "number"
            or amount < 1 or amount > 50 or amount ~= math.floor(amount) then
            return false, "Invalid materials"
        end
        if (inv[item] or 0) < amount then return false, "Need more " .. item end
    end
    for item, amount in pairs(costs) do inv[item] -= amount end
    record.dirty = true
    broadcast(player, "Materials used for building")
    return true, "OK"
end

-- Combat integration: read-only server-only equipment ownership check.
local combatBridge = game:GetService("ServerScriptService"):FindFirstChild("AnmolHasWeapon")
if not combatBridge then
    combatBridge = Instance.new("BindableFunction")
    combatBridge.Name = "AnmolHasWeapon"
    combatBridge.Parent = game:GetService("ServerScriptService")
end
combatBridge.OnInvoke = function(player, itemName)
    if typeof(player) ~= "Instance" or not player:IsA("Player") then return false end
    if itemName ~= "StoneAxe" and itemName ~= "Sword" then return false end
    local inv = inventories[player]
    local record = records[player]
    return inv ~= nil and record ~= nil and record.loaded == true
        and record.locked == true and not record.closing and (inv[itemName] or 0) >= 1
end

-- Loot Rewards V1: server-only, validated item grant bridge.
-- No client RemoteEvent may directly grant items.
local grantBridge = game:GetService("ServerScriptService"):FindFirstChild("AnmolGrantLoot")
if not grantBridge then
    grantBridge = Instance.new("BindableFunction")
    grantBridge.Name = "AnmolGrantLoot"
    grantBridge.Parent = game:GetService("ServerScriptService")
end
grantBridge.OnInvoke = function(player, rewards)
    if typeof(player) ~= "Instance" or not player:IsA("Player") then return false, {} end
    if type(rewards) ~= "table" then return false, {} end
    local record = records[player]
    local inv = inventories[player]
    if not record or not record.loaded or not record.locked or record.closing or not inv then
        return false, {}
    end
    -- Rewards only use collected material types (no free tools or crafted weapons).
    local allowed = {Wood = true, Stone = true, Crystal = true, Fiber = true}
    local granted = {}
    local capacity = math.max(0, MAX_TOTAL_ITEMS - totalCount(inv))
    for _, name in ipairs({"Wood", "Stone", "Crystal", "Fiber"}) do
        local count = rewards[name]
        if count ~= nil then
            if type(count) ~= "number" or count ~= count or count ~= math.floor(count)
                or count < 0 or count > 20 then
                return false, {}
            end
            local amount = math.min(capacity, count)
            if amount > 0 then
                granted[name] = amount
                capacity -= amount
            end
        end
    end
    for name in pairs(rewards) do
        if not allowed[name] then return false, {} end
    end
    if next(granted) == nil then return false, {} end
    for name, count in pairs(granted) do inv[name] += count end
    record.dirty = true
    local chunks = {}
    for _, name in ipairs({"Wood", "Stone", "Crystal", "Fiber"}) do
        if granted[name] then table.insert(chunks, "+" .. granted[name] .. " " .. name) end
    end
    broadcast(player, "Monster loot: " .. table.concat(chunks, ", "))
    return true, granted
end

GetInventory.OnServerInvoke = function(player)
    local inv = inventories[player]
    return inv and copyInventory(inv) or newInventory()
end

CraftRequest.OnServerEvent:Connect(function(player, recipeName)
    if type(recipeName) ~= "string" or #recipeName > 40 then return end
    local recipe = RECIPES[recipeName]
    local inv = inventories[player]
    local record = records[player]
    if not inv or not record or record.closing or not recipe then return end
    local now = os.clock()
    if now - (lastCraftAt[player] or 0) < CRAFT_COOLDOWN then return end
    lastCraftAt[player] = now
    for ingredient, needed in pairs(recipe) do
        if (inv[ingredient] or 0) < needed then
            broadcast(player, "Not enough " .. ingredient)
            return
        end
    end
    local used = 0
    for _, needed in pairs(recipe) do used += needed end
    if totalCount(inv) - used + 1 > MAX_TOTAL_ITEMS then
        broadcast(player, "Inventory full")
        return
    end
    for ingredient, needed in pairs(recipe) do inv[ingredient] -= needed end
    inv[recipeName] += 1
    record.progress.ItemsCrafted += 1
    record.dirty = true
    setProgressAttributes(player, record)
    broadcast(player, "Crafted " .. recipeName)
end)

local function findRootPart(node)
    if node:IsA("BasePart") then return node end
    if node:IsA("Model") then
        return node.PrimaryPart or node:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function setupNode(node)
    local part = findRootPart(node)
    if not part then return end
    local resource = node:GetAttribute("ResourceType")
    if type(resource) ~= "string" or not NODE_YIELDS[resource] then return end
    if part:FindFirstChild("AnmolGatherPrompt") then return end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "AnmolGatherPrompt"
    prompt.ObjectText = resource
    prompt.ActionText = "Collect"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = part

    prompt.Triggered:Connect(function(player)
        if nodeBusy[node] or not node.Parent then return end
        local inv = inventories[player]
        local record = records[player]
        if not record or record.closing then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not inv or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - part.Position).Magnitude > HARVEST_DISTANCE then return end
        -- ResourceType is set on nodes by the game builder, never by the client.
        local kind = node:GetAttribute("ResourceType")
        local yieldCount = NODE_YIELDS[kind]
        if not yieldCount then return end
        local room = MAX_TOTAL_ITEMS - totalCount(inv)
        if room <= 0 then broadcast(player, "Inventory full"); return end
        nodeBusy[node] = true
        prompt.Enabled = false
        local gained = math.min(room, yieldCount)
        inv[kind] += gained
        if kind == "Wood" then record.progress.TreesCut += 1 end
        if kind == "Crystal" then record.progress.CrystalsMined += gained end
        record.dirty = true
        setProgressAttributes(player, record)
        broadcast(player, "+" .. gained .. " " .. kind)
        -- World Anger V1 server-only integration; only successful harvests count.
        local worldAction = game:GetService("ServerScriptService"):FindFirstChild("AnmolWorldAction")
        if worldAction and worldAction:IsA("BindableEvent") then
            if kind == "Wood" then
                worldAction:Fire("TreeCut")
            elseif kind == "Crystal" then
                worldAction:Fire("CrystalMined")
            end
        end
        local respawn = tonumber(node:GetAttribute("RespawnSeconds")) or 12
        task.delay(math.clamp(respawn, 3, 120), function()
            nodeBusy[node] = nil
            if prompt.Parent and node.Parent then prompt.Enabled = true end
        end)
    end)
end

for _, node in ipairs(CollectionService:GetTagged("AnmolResourceNode")) do setupNode(node) end
CollectionService:GetInstanceAddedSignal("AnmolResourceNode"):Connect(setupNode)
print("[Anmol] Inventory + Crafting + Saving V1 started; recipes:", table.concat(RECIPE_ORDER, ", "))
