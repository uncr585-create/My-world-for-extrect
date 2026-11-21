-- ANMOL: LIVING WORLD | World Healing & Nature Reaction V1
-- Roblox Studio: ServerScriptService > Script
-- Requires WorldAnger.server.lua. IslandMap.server.lua optional for positioning.
-- Server only: ProximityPrompt gives a player a validated opportunity to heal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local state = ReplicatedStorage:WaitForChild("AnmolWorldState", 45)
local action = ServerScriptService:WaitForChild("AnmolWorldAction", 45)
if not state or not action then
    warn("[Anmol Healing] World Anger system is missing; healing disabled")
    return
end
local anger = state:WaitForChild("Anger", 30)
local mood = state:WaitForChild("Mood", 30)
if not anger or not mood then return end

-- Optional map dependency. Wait for map generator so we can group plants with it.
local map = Workspace:WaitForChild("AnmolIslandV1", 20)
local parent = map or Workspace
if parent:FindFirstChild("AnmolHealingV1") then
    warn("[Anmol Healing] Already generated; avoiding duplicates")
    return
end
local root = Instance.new("Folder")
root.Name = "AnmolHealingV1"
root.Parent = parent

local specs = {
    {name = "Echo Pond Bloom", x = 130, z = -96},
    {name = "Whisper Moss", x = 227, z = 30},
    {name = "Moon Fern", x = 85, z = 140},
    {name = "Ancient Bloom", x = 255, z = -150},
    {name = "Village Sprout", x = -115, z = 85},
    {name = "Forest Lanternflower", x = 300, z = 185},
}
local COOLDOWN = 55
local HOLD_SECONDS = 1.5
local MAX_DISTANCE = 12

local plantRecords = {}
local function makePlant(spec, index)
    local plant = Instance.new("Model")
    plant.Name = "HealingPlant_" .. index
    plant.Parent = root

    local stem = Instance.new("Part")
    stem.Name = "Stem"
    stem.Size = Vector3.new(1.4, 4, 1.4)
    stem.Position = Vector3.new(spec.x, 2.5, spec.z)
    stem.Color = Color3.fromRGB(78, 127, 82)
    stem.Material = Enum.Material.Grass
    stem.Anchored = true
    stem.CanCollide = false
    stem.Parent = plant

    local bloom = Instance.new("Part")
    bloom.Name = "Bloom"
    bloom.Size = Vector3.new(5, 5, 5)
    bloom.Position = Vector3.new(spec.x, 5.3, spec.z)
    bloom.Shape = Enum.PartType.Ball
    bloom.Color = Color3.fromRGB(110, 91, 105)
    bloom.Material = Enum.Material.SmoothPlastic
    bloom.Anchored = true
    bloom.CanCollide = false
    bloom.Parent = plant
    plant.PrimaryPart = bloom

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(119, 255, 181)
    light.Range = 18
    light.Brightness = 0
    light.Parent = bloom

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "HealPrompt"
    prompt.ActionText = "Heal Nature (Anger -8)"
    prompt.ObjectText = spec.name
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = HOLD_SECONDS
    prompt.MaxActivationDistance = MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = bloom

    local availableAt = 0
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or player.Parent ~= Players then return end
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then return end
        -- Re-check range and cooldown on server; never trust a client-provided anger amount.
        if (hrp.Position - bloom.Position).Magnitude > MAX_DISTANCE + 3 then return end
        if os.clock() < availableAt then return end
        if anger.Value <= 0 then return end

        availableAt = os.clock() + COOLDOWN
        prompt.Enabled = false
        action:Fire("PlantHealed")
        bloom.Color = Color3.fromRGB(116, 255, 179)
        bloom.Material = Enum.Material.Neon
        light.Brightness = 1.8
        plant:SetAttribute("HealedBy", player.UserId)
        plant:SetAttribute("CooldownUntil", Workspace:GetServerTimeNow() + COOLDOWN)
        task.delay(COOLDOWN, function()
            if not plant.Parent then return end
            bloom.Color = Color3.fromRGB(110, 91, 105)
            bloom.Material = Enum.Material.SmoothPlastic
            light.Brightness = 0
            prompt.Enabled = true
        end)
    end)
    table.insert(plantRecords, {bloom = bloom, light = light, prompt = prompt})
end
for i, spec in ipairs(specs) do makePlant(spec, i) end

-- Nature Reaction: affect ONLY decorative parts created by this module;
-- no destructive changes to player buildings, terrain, or other systems.
local reaction = Instance.new("Folder")
reaction.Name = "NatureReactions"
reaction.Parent = root
local vineParts = {}
for i = 1, 10 do
    local part = Instance.new("Part")
    part.Name = "ReactiveVine_" .. i
    part.Size = Vector3.new(1.8, 1.8, 12)
    part.Anchored = true
    part.CanCollide = false
    part.Position = Vector3.new(10 + i * 25, 2, 215)
    part.Material = Enum.Material.Grass
    part.Parent = reaction
    table.insert(vineParts, part)
end

local function updateReaction()
    local a = math.clamp(tonumber(anger.Value) or 0, 0, 100)
    local angry = a >= 75
    local uneasy = a >= 40
    local color = angry and Color3.fromRGB(188, 52, 79)
        or (uneasy and Color3.fromRGB(150, 111, 65) or Color3.fromRGB(65, 169, 105))
    for _, vine in ipairs(vineParts) do
        TweenService:Create(vine, TweenInfo.new(1.2), {Color = color, Transparency = angry and 0 or (uneasy and .2 or .55)}):Play()
    end
    state:SetAttribute("NatureReaction", angry and "Hostile" or (uneasy and "Alert" or "Restoring"))
end
anger.Changed:Connect(updateReaction)
updateReaction()
print("[Anmol Healing] 6 healing plants and nature reaction visuals loaded")
