-- ANMOL: LIVING WORLD / Monster Loot V2
-- ServerScriptService > LootRewards.server.lua (Script)
-- Pays the most recent valid server-attributed attacker on a monster death.
local Players = game:GetService("Players")
local SS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local monsters = Workspace:WaitForChild("AnmolMonsters", 60)
if not monsters then warn("[Anmol Loot] Monster folder missing") return end
local grantBridge = SS:WaitForChild("AnmolGrantLoot", 60)
if not grantBridge then warn("[Anmol Loot] Inventory reward bridge missing") return end

local claimed = setmetatable({}, {__mode = "k"})
local bound = setmetatable({}, {__mode = "k"})
local DROP_TABLES = {
    RootStalker = {Wood = {2,4}, Fiber = {1,2}, CrystalChance = 0.08},
    WhisperShade = {Stone = {1,3}, Fiber = {1,2}, CrystalChance = 0.22},
    HollowDeer = {Wood = {2,4}, Fiber = {2,3}, HollowAntlerChance = 0.35},
    CrystalBurrower = {Stone = {3,5}, Crystal = {1,2}, CrystalShardChance = 0.30},
}
local function rollRewards(monsterType)
    local spec = DROP_TABLES[monsterType]
    if not spec then return nil end
    local rewards = {}
    for name, range in pairs(spec) do
        if name ~= "CrystalChance" and name ~= "HollowAntlerChance" and name ~= "CrystalShardChance" then
            rewards[name] = math.random(range[1],range[2])
        end
    end
    if math.random() < (spec.CrystalChance or 0) then rewards.Crystal = 1 end
    if math.random() < (spec.HollowAntlerChance or 0) then rewards.HollowAntler = 1 end
    if math.random() < (spec.CrystalShardChance or 0) then rewards.CrystalShard = 1 end
    return rewards
end
local function onDeath(model)
    if claimed[model] then return end
    claimed[model] = true
    local lastHit = model:GetAttribute("LastHitUserId")
    local lastAt = model:GetAttribute("LastHitAt")
    if type(lastHit) ~= "number" or type(lastAt) ~= "number" then return end
    if os.time() - lastAt > 25 then return end
    local player = Players:GetPlayerByUserId(lastHit)
    if not player then return end
    -- Inform Achievements about a server-verified monster kill.
    local event = SS:FindFirstChild("AnmolMonsterDefeated")
    if event and event:IsA("BindableEvent") then
        event:Fire(player, model:GetAttribute("MonsterType"))
    end
    local rewards = rollRewards(model:GetAttribute("MonsterType"))
    if not rewards then return end
    local ok, granted, result = pcall(function()
        return grantBridge:Invoke(player, rewards)
    end)
    if not ok then
        warn("[Anmol Loot] Grant error:", granted)
    elseif not granted then
        warn("[Anmol Loot] No items granted (inventory full, locked, or not loaded)")
    end
end
local function watch(model)
    if not model:IsA("Model") or bound[model] then return end
    if model:GetAttribute("AnmolMonster") ~= true then return end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    bound[model] = true
    humanoid.Died:Connect(function() onDeath(model) end)
    if humanoid.Health <= 0 then onDeath(model) end
end
for _, model in ipairs(monsters:GetChildren()) do watch(model) end
monsters.ChildAdded:Connect(watch)
print("[Anmol] Monster Loot V2 ready")
