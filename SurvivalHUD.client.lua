-- ANMOL: LIVING WORLD — Survival HUD V1
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Android touch Sprint button + PC LeftShift support.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local sprintRemote = ReplicatedStorage:WaitForChild("AnmolSurvivalRemotes"):WaitForChild("SetSprinting")

local old = player:WaitForChild("PlayerGui"):FindFirstChild("AnmolSurvivalHUD")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AnmolSurvivalHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player.PlayerGui

local panel = Instance.new("Frame")
panel.Name = "VitalsPanel"
panel.AnchorPoint = Vector2.new(0, 1)
panel.Position = UDim2.new(0, 14, 1, -20)
panel.Size = UDim2.fromOffset(215, 126)
panel.BackgroundColor3 = Color3.fromRGB(14, 24, 27)
panel.BackgroundTransparency = 0.12
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(72, 134, 110)
stroke.Thickness = 1.5

local rows = {}
local function addMeter(name, emoji, color, y)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, y)
    label.Size = UDim2.fromOffset(190, 20)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(236, 248, 237)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = panel

    local bg = Instance.new("Frame")
    bg.Position = UDim2.fromOffset(12, y + 21)
    bg.Size = UDim2.fromOffset(190, 9)
    bg.BackgroundColor3 = Color3.fromRGB(48, 58, 61)
    bg.Parent = panel
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = color
    fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    rows[name] = { label = label, fill = fill, emoji = emoji }
end

addMeter("Health", "❤️", Color3.fromRGB(224, 85, 96), 5)
addMeter("Hunger", "🍗", Color3.fromRGB(241, 178, 78), 45)
addMeter("Stamina", "⚡", Color3.fromRGB(81, 209, 167), 85)

local sprintButton = Instance.new("TextButton")
sprintButton.Name = "SprintButton"
sprintButton.AnchorPoint = Vector2.new(1, 1)
sprintButton.Position = UDim2.new(1, -20, 1, -142)
sprintButton.Size = UDim2.fromOffset(112, 52)
sprintButton.BackgroundColor3 = Color3.fromRGB(41, 105, 87)
sprintButton.TextColor3 = Color3.new(1, 1, 1)
sprintButton.Font = Enum.Font.GothamBold
sprintButton.TextSize = 17
sprintButton.Text = "⚡ SPRINT"
sprintButton.Visible = UserInputService.TouchEnabled
sprintButton.Parent = gui
Instance.new("UICorner", sprintButton).CornerRadius = UDim.new(0, 15)

local wanting = false
local function setSprint(value)
    if wanting == value then return end
    wanting = value
    sprintRemote:FireServer(value)
    sprintButton.BackgroundColor3 = value and Color3.fromRGB(31, 152, 105) or Color3.fromRGB(41, 105, 87)
    sprintButton.Text = value and "⚡ RUNNING" or "⚡ SPRINT"
end

-- Tap toggles sprint on mobile. This is easier than holding on touch screens.
sprintButton.Activated:Connect(function()
    setSprint(not wanting)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then setSprint(true) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then setSprint(false) end
end)

local humanoid
local healthConnection
local maxHealthConnection
local function updateVitals()
    local health = humanoid and humanoid.Health or 0
    local maxHealth = humanoid and humanoid.MaxHealth or 100
    local vals = {
        Health = {health, math.max(1, maxHealth)},
        Hunger = {player:GetAttribute("SurvivalHunger") or 100, 100},
        Stamina = {player:GetAttribute("SurvivalStamina") or 100, 100},
    }
    for name, pair in pairs(vals) do
        local row = rows[name]
        local value, maximum = pair[1], pair[2]
        row.label.Text = string.format("%s %s  %d/%d", row.emoji, name, math.ceil(value), maximum)
        row.fill.Size = UDim2.fromScale(math.clamp(value / maximum, 0, 1), 1)
    end
    if wanting and player:GetAttribute("SurvivalIsSprinting") == false
        and (player:GetAttribute("SurvivalStamina") or 100) <= 0 then
        setSprint(false)
    end
end

local function attachCharacter(character)
    if healthConnection then healthConnection:Disconnect() end
    if maxHealthConnection then maxHealthConnection:Disconnect() end
    humanoid = character:WaitForChild("Humanoid")
    healthConnection = humanoid.HealthChanged:Connect(updateVitals)
    maxHealthConnection = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateVitals)
    setSprint(false)
    updateVitals()
end
player.CharacterAdded:Connect(attachCharacter)
if player.Character then task.spawn(attachCharacter, player.Character) end
for _, attr in ipairs({"SurvivalHunger", "SurvivalStamina", "SurvivalIsSprinting"}) do
    player:GetAttributeChangedSignal(attr):Connect(updateVitals)
end
updateVitals()
