-- ANMOL: LIVING WORLD — Weather + Time HUD V1
-- LocalScript location: StarterPlayer > StarterPlayerScripts
-- Uses replicated data from WeatherDayNight.server.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local world = ReplicatedStorage:WaitForChild("AnmolWorldState")
local weather = world:WaitForChild("Weather")
local hours = world:WaitForChild("TimeOfDayHours")
local thunder = world:WaitForChild("ThunderPulse")

local old = playerGui:FindFirstChild("AnmolWeatherHUD")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AnmolWeatherHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "WeatherPanel"
panel.Size = UDim2.fromOffset(182, 66)
panel.Position = UDim2.new(1, -194, 0, 100) -- right side, below top World Anger meter
panel.BackgroundColor3 = Color3.fromRGB(15, 28, 32)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -18, 1, -12)
label.Position = UDim2.fromOffset(9, 6)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(240, 246, 247)
label.TextSize = 15
label.Font = Enum.Font.GothamSemibold
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.TextWrapped = true
label.Parent = panel

local icons = {Clear = "☀", Rain = "☂", Fog = "☁", Thunderstorm = "⚡"}
local function update()
    local h = hours.Value
    local hour = math.floor(h)
    local minute = math.floor((h - hour) * 60)
    label.Text = string.format("%s %s\n🕒 %02d:%02d", icons[weather.Value] or "☁", weather.Value, hour, minute)
end
weather.Changed:Connect(update)
hours.Changed:Connect(update)
update()

local previous = thunder.Value
thunder.Changed:Connect(function(value)
    if value <= previous then return end
    previous = value
    label.Text = "⚡ THUNDER!"
    task.delay(1.4, function()
        if label.Parent then update() end
    end)
end)
