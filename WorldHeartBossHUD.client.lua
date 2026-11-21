-- ANMOL: LIVING WORLD — World Heart Boss HUD V1
-- StarterPlayer > StarterPlayerScripts > LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local state = ReplicatedStorage:WaitForChild("AnmolBossState", 120)
if not state then return end
local active = state:WaitForChild("Active")
local health = state:WaitForChild("Health")
local maxHealth = state:WaitForChild("MaxHealth")
local phase = state:WaitForChild("Phase")
local message = state:WaitForChild("Message")

local gui = Instance.new("ScreenGui")
gui.Name = "AnmolBossHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Size = UDim2.new(.6, 0, 0, 80)
panel.Position = UDim2.new(.2, 0, 0, 42)
panel.BackgroundColor3 = Color3.fromRGB(22, 16, 27)
panel.BackgroundTransparency = .15
panel.BorderSizePixel = 0
panel.Parent = gui
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(540, 100)
limit.MinSize = Vector2.new(220, 75)
limit.Parent = panel
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.fromOffset(10, 3)
title.TextColor3 = Color3.fromRGB(252, 231, 240)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = panel
local barBack = Instance.new("Frame")
barBack.Size = UDim2.new(1, -20, 0, 17)
barBack.Position = UDim2.fromOffset(10, 32)
barBack.BackgroundColor3 = Color3.fromRGB(71, 52, 70)
barBack.BorderSizePixel = 0
barBack.Parent = panel
Instance.new("UICorner", barBack).CornerRadius = UDim.new(0, 6)
local bar = Instance.new("Frame")
bar.Size = UDim2.fromScale(1, 1)
bar.BackgroundColor3 = Color3.fromRGB(237, 77, 124)
bar.BorderSizePixel = 0
bar.Parent = barBack
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 22)
info.Position = UDim2.fromOffset(10, 53)
info.TextColor3 = Color3.fromRGB(237, 207, 216)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextScaled = true
info.Parent = panel
local function render()
    panel.Visible = active.Value
    title.Text = "WORLD HEART GUARDIAN  •  PHASE " .. tostring(phase.Value)
    bar.Size = UDim2.fromScale(math.clamp(health.Value / math.max(1, maxHealth.Value), 0, 1), 1)
    info.Text = tostring(health.Value) .. "/" .. tostring(maxHealth.Value) .. " HP  •  " .. message.Value
end
for _, v in ipairs({active, health, maxHealth, phase, message}) do
    v.Changed:Connect(render)
end
render()
