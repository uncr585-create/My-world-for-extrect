-- ANMOL: LIVING WORLD | World Healing HUD V1
-- Roblox Studio: StarterPlayer > StarterPlayerScripts > LocalScript
-- Informational HUD. Healing uses built-in ProximityPrompt (touch compatible).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local world = RS:WaitForChild("AnmolWorldState", 45)
if not world then return end
local anger = world:WaitForChild("Anger", 30)
if not anger then return end
local gui = Instance.new("ScreenGui")
gui.Name = "AnmolNatureHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "NatureStatus"
label.AnchorPoint = Vector2.new(.5, 0)
label.Position = UDim2.new(.5, 0, 0, 12)
label.Size = UDim2.new(.65, 0, 0, 34)
label.BackgroundColor3 = Color3.fromRGB(17, 37, 27)
label.BackgroundTransparency = .2
label.TextColor3 = Color3.fromRGB(219, 255, 228)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 9)
local function render()
    local a = anger.Value
    label.Text = (a >= 75 and "🌿 NATURE: HOSTILE" or (a >= 40 and "🌱 NATURE: ALERT" or "🌸 NATURE: RESTORING")) .. "  •  Anger " .. tostring(a) .. "%"
end
anger.Changed:Connect(render)
render()
