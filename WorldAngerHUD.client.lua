-- ANMOL: LIVING WORLD — World Anger mobile HUD V1
-- Place in StarterPlayer > StarterPlayerScripts as a LocalScript.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local worldState = ReplicatedStorage:WaitForChild("AnmolWorldState")
local angerValue = worldState:WaitForChild("Anger")
local moodValue = worldState:WaitForChild("Mood")

local old = playerGui:FindFirstChild("AnmolWorldAngerHUD")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AnmolWorldAngerHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "AngerPanel"
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.fromScale(0.5, 0.02)
frame.Size = UDim2.new(0.78, 0, 0, 62)
frame.BackgroundColor3 = Color3.fromRGB(19, 29, 30)
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
frame.Parent = gui

local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(430, 62)
limit.Parent = frame
local corners = Instance.new("UICorner")
corners.CornerRadius = UDim.new(0, 12)
corners.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 5)
title.Size = UDim2.new(1, -24, 0, 22)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235, 243, 236)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local track = Instance.new("Frame")
track.Position = UDim2.new(0, 12, 0, 34)
track.Size = UDim2.new(1, -24, 0, 15)
track.BorderSizePixel = 0
track.BackgroundColor3 = Color3.fromRGB(63, 67, 70)
track.Parent = frame
local trackCorners = Instance.new("UICorner")
trackCorners.CornerRadius = UDim.new(1, 0)
trackCorners.Parent = track

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BorderSizePixel = 0
fill.Parent = track
local fillCorners = Instance.new("UICorner")
fillCorners.CornerRadius = UDim.new(1, 0)
fillCorners.Parent = fill

local lastTween
local function redraw()
    local anger = math.clamp(angerValue.Value, 0, 100)
    local mood = moodValue.Value
    title.Text = string.format("WORLD ANGER  %d%%  •  %s", anger, mood)
    local color = anger >= 75 and Color3.fromRGB(235, 78, 76)
        or anger >= 40 and Color3.fromRGB(236, 178, 66)
        or Color3.fromRGB(76, 196, 122)
    if lastTween then lastTween:Cancel() end
    lastTween = TweenService:Create(fill, TweenInfo.new(0.25), {
        Size = UDim2.fromScale(anger / 100, 1),
        BackgroundColor3 = color,
    })
    lastTween:Play()
end

angerValue:GetPropertyChangedSignal("Value"):Connect(redraw)
moodValue:GetPropertyChangedSignal("Value"):Connect(redraw)
redraw()
