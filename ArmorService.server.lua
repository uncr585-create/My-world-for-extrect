-- ANMOL: LIVING WORLD / Equipment + Armor V1
-- ServerScriptService > ArmorService.server.lua
-- Validates inventory ownership, protects monster/boss damage with a server-only bridge.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local ARMORS = {
    LeafVest = 0.10,       -- 10% less combat damage
    StoneArmor = 0.20,     -- 20% less combat damage
    CrystalArmor = 0.35,   -- 35% less combat damage
}
local remotes = RS:FindFirstChild("AnmolArmorRemotes") or Instance.new("Folder")
remotes.Name = "AnmolArmorRemotes"
remotes.Parent = RS
local equip = remotes:FindFirstChild("EquipArmor") or Instance.new("RemoteEvent")
equip.Name = "EquipArmor"
equip.Parent = remotes
local status = remotes:FindFirstChild("ArmorStatus") or Instance.new("RemoteEvent")
status.Name = "ArmorStatus"
status.Parent = remotes
local bridge = SS:WaitForChild("AnmolHasArmor", 30)
if not bridge then warn("[Anmol Armor] Missing AnmolHasArmor in InventoryCrafting") end
local selected = {}
local nextEquip = {}
local function owns(player, name)
    if name == "None" then return true end
    if not bridge then return false end
    local ok, result = pcall(function() return bridge:Invoke(player, name) end)
    return ok and result == true
end
local function setSelected(player, name)
    selected[player] = name
    player:SetAttribute("AnmolEquippedArmor", name)
    player:SetAttribute("AnmolArmorReduction", ARMORS[name] or 0)
    status:FireClient(player, name, math.floor((ARMORS[name] or 0) * 100))
end
local damageBridge = SS:FindFirstChild("AnmolApplyPlayerDamage") or Instance.new("BindableFunction")
damageBridge.Name = "AnmolApplyPlayerDamage"
damageBridge.Parent = SS
damageBridge.OnInvoke = function(player, incoming)
    if typeof(player) ~= "Instance" or not player:IsA("Player") then return false end
    if typeof(incoming) ~= "number" or incoming ~= incoming or incoming <= 0 or incoming > 1000 then
        return false
    end
    local character = player.Character
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local name = selected[player] or "None"
    -- Recheck ownership on each hit: cannot retain defense after losing armor.
    if name ~= "None" and not owns(player, name) then
        name = "None"
        setSelected(player, name)
    end
    local reduction = ARMORS[name] or 0
    hum:TakeDamage(math.max(1, incoming * (1 - reduction)))
    return true
end
equip.OnServerEvent:Connect(function(player, name)
    if type(name) ~= "string" or (name ~= "None" and not ARMORS[name]) then return end
    local now = os.clock()
    if now - (nextEquip[player] or -10) < 0.3 then return end
    nextEquip[player] = now
    if not owns(player, name) then
        status:FireClient(player, selected[player] or "None", math.floor((ARMORS[selected[player]] or 0)*100), "Craft armor first")
        return
    end
    setSelected(player, name)
end)
local function setup(player)
    setSelected(player, "None")
    player.CharacterAdded:Connect(function()
        -- Armor stays equipped during ordinary respawn in this server session.
        task.defer(function()
            if player.Parent then setSelected(player, selected[player] or "None") end
        end)
    end)
end
Players.PlayerAdded:Connect(setup)
for _, player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerRemoving:Connect(function(player)
    selected[player] = nil
    nextEquip[player] = nil
end)
print("[Anmol] Equipment + Armor V1 ready")
