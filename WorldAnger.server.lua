-- ANMOL: LIVING WORLD — World Anger V1
-- Place in ServerScriptService as a Script.
-- All anger mutations happen on the server; clients can only read the replicated value.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MAX_ANGER = 100
local START_ANGER = 20
local CHANGE_VALUES = {
    TreeCut = 3,
    CrystalMined = 5,
    Explosion = 15,
    PlantHealed = -8,
    WorldHeartHealed = -25,
}

local worldState = ReplicatedStorage:FindFirstChild("AnmolWorldState")
if not worldState then
    worldState = Instance.new("Folder")
    worldState.Name = "AnmolWorldState"
    worldState.Parent = ReplicatedStorage
end

local angerValue = worldState:FindFirstChild("Anger")
if not angerValue then
    angerValue = Instance.new("IntValue")
    angerValue.Name = "Anger"
    angerValue.Value = START_ANGER
    angerValue.Parent = worldState
end

local moodValue = worldState:FindFirstChild("Mood")
if not moodValue then
    moodValue = Instance.new("StringValue")
    moodValue.Name = "Mood"
    moodValue.Parent = worldState
end

local function moodFor(anger)
    if anger >= 75 then return "Furious" end
    if anger >= 40 then return "Disturbed" end
    return "Calm"
end

local function updateMood()
    moodValue.Value = moodFor(angerValue.Value)
end

local function applyWorldAction(actionName)
    local amount = CHANGE_VALUES[actionName]
    if not amount then
        warn("[Anmol World] Unknown world action:", actionName)
        return false
    end

    angerValue.Value = math.clamp(angerValue.Value + amount, 0, MAX_ANGER)
    updateMood()
    print(string.format("[Anmol World] %s (%+d) -> anger %d, mood %s",
        actionName, amount, angerValue.Value, moodValue.Value))
    return true
end

-- Hook to future server-side resource systems by calling:
-- game.ServerScriptService.AnmolWorldAction:Fire("TreeCut")
-- Never expose a client FireServer(actionName) entry point without server validation.
local serverAction = game:GetService("ServerScriptService"):FindFirstChild("AnmolWorldAction")
if not serverAction then
    serverAction = Instance.new("BindableEvent")
    serverAction.Name = "AnmolWorldAction"
    serverAction.Parent = game:GetService("ServerScriptService")
end
serverAction.Event:Connect(applyWorldAction)

updateMood()
print("[Anmol World] World Anger V1 loaded.")

-- Studio test example (run from the SERVER command bar):
-- game.ServerScriptService.AnmolWorldAction:Fire("CrystalMined")
