-- ANMOL: LIVING WORLD — Sound Atmosphere V1
-- Put this LocalScript in StarterPlayer > StarterPlayerScripts.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local world = RS:WaitForChild("AnmolWorldState", 30)
if not world then return end
local anger = world:WaitForChild("Anger", 30)
if not anger then return end
local config = require(RS:WaitForChild("AnmolSoundConfig", 30))
local weatherValue = world:FindFirstChild("Weather")
local thunderValue = world:FindFirstChild("ThunderPulse")
local clockValue = world:FindFirstChild("TimeOfDayHours")

local folder = Instance.new("Folder")
folder.Name = "AnmolClientAudio"
folder.Parent = SoundService

local activeTweens = {}
local sounds = {}
local function buildSound(key, looping)
    local s = Instance.new("Sound")
    s.Name = key
    s.SoundId = config.AudioIds[key] or ""
    s.Looped = looping
    s.Volume = 0
    s.Parent = folder
    sounds[key] = s
    return s
end

for _, key in ipairs({"ForestDay", "ForestNight", "Rain", "Storm", "Heartbeat"}) do
    buildSound(key, true)
end
buildSound("Warning", false)
buildSound("Thunder", false)

local enabled = true
local master = math.clamp(tonumber(config.MasterVolume) or 0.65, 0, 1)
local function fade(key, target)
    local s = sounds[key]
    if not s then return end
    if activeTweens[key] then activeTweens[key]:Cancel() end
    if s.SoundId == "" then return end
    if target > 0 and not s.IsPlaying then s:Play() end
    local tween = TweenService:Create(s, TweenInfo.new(config.FadeSeconds or 1.7),
        { Volume = math.clamp(target, 0, 1) })
    activeTweens[key] = tween
    tween:Play()
    if target == 0 then
        tween.Completed:Once(function(state)
            if state == Enum.PlaybackState.Completed and s.Volume <= 0.001 then
                s:Pause()
            end
        end)
    end
end
local function updateAudio()
    local a = tonumber(anger.Value) or 0
    local weather = weatherValue and weatherValue.Value or "Clear"
    local clock = clockValue and tonumber(clockValue.Value) or 12
    local night = clock < 6 or clock >= 18
    local v = enabled and master or 0
    local danger = a >= 75 and 1 or (a >= 40 and 0.65 or 0.2)

    fade("ForestDay", night and 0 or v * 0.48)
    fade("ForestNight", night and v * 0.52 or 0)
    fade("Rain", weather == "Rain" and v * 0.6 or 0)
    fade("Storm", weather == "Thunderstorm" and v * 0.7 or 0)
    fade("Heartbeat", v * danger * 0.28)
end

anger.Changed:Connect(updateAudio)
task.spawn(function()
    while folder.Parent do
        weatherValue = world:FindFirstChild("Weather")
        thunderValue = world:FindFirstChild("ThunderPulse")
        clockValue = world:FindFirstChild("TimeOfDayHours")
        updateAudio()
        task.wait(3)
    end
end)
local lastMood = "Calm"
anger.Changed:Connect(function()
    local a = tonumber(anger.Value) or 0
    local mood = a >= 75 and "Furious" or (a >= 40 and "Disturbed" or "Calm")
    if mood ~= lastMood and mood ~= "Calm" and sounds.Warning.SoundId ~= "" and enabled then
        sounds.Warning.Volume = master * 0.7
        sounds.Warning:Play()
    end
    lastMood = mood
end)

task.spawn(function()
    while folder.Parent do
        local pulse = world:FindFirstChild("ThunderPulse")
        if pulse then
            pulse.Changed:Connect(function()
                if enabled and sounds.Thunder.SoundId ~= "" then
                    sounds.Thunder.Volume = master * 0.85
                    sounds.Thunder:Play()
                end
            end)
            break
        end
        task.wait(2)
    end
end)

-- Mobile-friendly sound ON/OFF control.
local gui = Instance.new("ScreenGui")
gui.Name = "AnmolSoundSettings"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local toggle = Instance.new("TextButton")
toggle.Name = "SoundToggle"
toggle.AnchorPoint = Vector2.new(1, 0)
toggle.Position = UDim2.new(1, -12, 0, 60)
toggle.Size = UDim2.fromOffset(122, 38)
toggle.BackgroundColor3 = Color3.fromRGB(24, 40, 42)
toggle.TextColor3 = Color3.fromRGB(245, 255, 245)
toggle.TextScaled = true
toggle.Font = Enum.Font.GothamBold
toggle.Text = "🔊 Sound ON"
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
toggle.Activated:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "🔊 Sound ON" or "🔇 Sound OFF"
    if not enabled then
        for _, s in pairs(sounds) do
            if not s.Looped then s:Stop() end
        end
    end
    updateAudio()
end)

updateAudio()
