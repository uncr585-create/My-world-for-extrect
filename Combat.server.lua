-- ANMOL: LIVING WORLD / Weapons + Combat V1
-- ServerScriptService > Combat.server.lua (Script)
-- Damage is computed by SERVER. Clients only request swings + selected weapon.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local folder = RS:FindFirstChild("AnmolCombatRemotes") or Instance.new("Folder")
folder.Name = "AnmolCombatRemotes"
folder.Parent = RS
local request = folder:FindFirstChild("AttackRequest") or Instance.new("RemoteEvent")
request.Name = "AttackRequest"
request.Parent = folder
local feedback = folder:FindFirstChild("AttackFeedback") or Instance.new("RemoteEvent")
feedback.Name = "AttackFeedback"
feedback.Parent = folder

local WEAPONS = {
    Fists = {Damage = 4, Range = 5, Cooldown = 0.9},
    StoneAxe = {Damage = 16, Range = 7, Cooldown = 0.9},
    Sword = {Damage = 25, Range = 9, Cooldown = 0.7},
}
local lastAttack = {}
local bridge = SS:WaitForChild("AnmolHasWeapon", 30)
if not bridge then warn("[Anmol Combat] Missing AnmolHasWeapon bridge in InventoryCrafting") end
local function hasWeapon(player, name)
    if name == "Fists" then return true end
    if not bridge then return false end
    local ok, result = pcall(function() return bridge:Invoke(player, name) end)
    return ok and result == true
end
local function getTarget(character, origin, look, range)
    local monsters = Workspace:FindFirstChild("AnmolMonsters")
    if not monsters then return nil end
    local bestHum, bestDistance
    for _, model in ipairs(monsters:GetChildren()) do
        if model:IsA("Model") and model:GetAttribute("AnmolMonster") == true then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 and root:IsA("BasePart") then
                local delta = root.Position - origin
                local dist = delta.Magnitude
                if dist > 0.01 and dist <= range and look:Dot(delta.Unit) >= 0.3 then
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = {character}
                    local hit = Workspace:Raycast(origin, delta, params)
                    if hit and hit.Instance:IsDescendantOf(model) and (not bestDistance or dist < bestDistance) then
                        bestDistance = dist
                        bestHum = hum
                    end
                end
            end
        end
    end
    return bestHum
end
request.OnServerEvent:Connect(function(player, requestedWeapon)
    if type(requestedWeapon) ~= "string" then return end
    local config = WEAPONS[requestedWeapon]
    if not config then return end
    local character = player.Character
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not root or not root:IsA("BasePart") then return end
    local now = os.clock()
    if now - (lastAttack[player] or -1000) < config.Cooldown then return end
    -- Rate limit before inventory work so requests can't repeatedly spam a lookup.
    lastAttack[player] = now
    if not hasWeapon(player, requestedWeapon) then
        feedback:FireClient(player, "Craft " .. requestedWeapon .. " first")
        return
    end
    local target = getTarget(character, root.Position + Vector3.new(0, 1, 0), root.CFrame.LookVector, config.Range)
    if target then
        -- Reward attribution is set by the server only, just before damage.
        local monster = target.Parent
        if monster and monster:IsA("Model") and monster:GetAttribute("AnmolMonster") == true then
            monster:SetAttribute("LastHitUserId", player.UserId)
            monster:SetAttribute("LastHitAt", os.time())
        end
        target:TakeDamage(config.Damage)
        feedback:FireClient(player, "Hit: -" .. config.Damage)
    else
        feedback:FireClient(player, "Miss")
    end
end)
Players.PlayerRemoving:Connect(function(player) lastAttack[player] = nil end)
print("[Anmol] Combat V1 ready")
