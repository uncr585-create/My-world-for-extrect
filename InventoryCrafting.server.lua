-- ANMOL: LIVING WORLD / Inventory + Crafting V1 (Resource Integration)
-- Install as Script in ServerScriptService.
-- Server-authoritative inventory, crafting, node harvesting. No saving in V1.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local MAX_TOTAL_ITEMS = 100
local HARVEST_DISTANCE = 15
local CRAFT_COOLDOWN = 0.35
local ITEMS = {
    Wood = true, Stone = true, Crystal = true, Fiber = true,
    StoneAxe = true, Torch = true, Bandage = true, NoiseDecoy = true,
}
local RECIPES = {
    StoneAxe = { Wood = 3, Stone = 2 },
    Torch = { Wood = 2, Fiber = 1 },
    Bandage = { Fiber = 3 },
    NoiseDecoy = { Stone = 2, Crystal = 1 },
}
local RECIPE_ORDER = { "StoneAxe", "Torch", "Bandage", "NoiseDecoy" }
local NODE_YIELDS = { Wood = 3, Stone = 2, Crystal = 1, Fiber = 2 }

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

local inventories = {} -- [player] = { Wood = 0, ... }
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

Players.PlayerAdded:Connect(function(player)
    inventories[player] = newInventory()
    lastCraftAt[player] = 0
end)
for _, player in ipairs(Players:GetPlayers()) do
    inventories[player] = newInventory()
    lastCraftAt[player] = 0
end
Players.PlayerRemoving:Connect(function(player)
    inventories[player] = nil
    lastCraftAt[player] = nil
end)
GetInventory.OnServerInvoke = function(player)
    local inv = inventories[player]
    return inv and copyInventory(inv) or newInventory()
end

CraftRequest.OnServerEvent:Connect(function(player, recipeName)
    if type(recipeName) ~= "string" or #recipeName > 40 then return end
    local recipe = RECIPES[recipeName]
    local inv = inventories[player]
    if not inv or not recipe then return end
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
print("[Anmol] Inventory + Crafting V1 (Resource Integration) started; recipes:", table.concat(RECIPE_ORDER, ", "))
