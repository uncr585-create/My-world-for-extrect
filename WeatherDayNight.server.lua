-- ANMOL: LIVING WORLD — Dynamic Weather + Day/Night V1
-- Script location: ServerScriptService. One copy only.
-- Uses existing ReplicatedStorage.AnmolWorldState/Anger from WorldAnger.server.lua.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CONFIG = {
    DayLengthSeconds = 720, -- a full in-game 24-hour cycle in 12 real minutes
    StartingHour = 9,
    WeatherChangeSeconds = 110,
    ThunderIntervalMin = 12,
    ThunderIntervalMax = 25,
}

local world = ReplicatedStorage:WaitForChild("AnmolWorldState", 30)
if not world then
    warn("[Anmol Weather] Missing AnmolWorldState. Install WorldAnger.server.lua first.")
    return
end
local anger = world:WaitForChild("Anger", 30)
if not anger then
    warn("[Anmol Weather] Missing Anger value.")
    return
end

local function ensureValue(name, className, initial)
    local value = world:FindFirstChild(name)
    if not value then
        value = Instance.new(className)
        value.Name = name
        value.Value = initial
        value.Parent = world
    end
    return value
end

local weatherValue = ensureValue("Weather", "StringValue", "Clear")
local timeValue = ensureValue("TimeOfDayHours", "NumberValue", CONFIG.StartingHour)
local thunderPulse = ensureValue("ThunderPulse", "IntValue", 0)

-- The same Lighting settings are shared by all players in a server.
local atmosphere = Lighting:FindFirstChild("AnmolWeatherAtmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Name = "AnmolWeatherAtmosphere"
    atmosphere.Parent = Lighting
end
local terrain = Workspace:FindFirstChildOfClass("Terrain")
local clouds
if terrain then
    clouds = terrain:FindFirstChild("AnmolWeatherClouds")
    if not clouds then
        clouds = Instance.new("Clouds")
        clouds.Name = "AnmolWeatherClouds"
        clouds.Parent = terrain
    end
end

local profiles = {
    Clear = {density = 0.22, haze = 1, color = Color3.fromRGB(195, 225, 225), coverage = 0.25, cloudDensity = 0.25},
    Rain = {density = 0.34, haze = 2.1, color = Color3.fromRGB(138, 164, 180), coverage = 0.8, cloudDensity = 0.72},
    Fog = {density = 0.62, haze = 3.2, color = Color3.fromRGB(128, 150, 158), coverage = 0.7, cloudDensity = 0.52},
    Thunderstorm = {density = 0.51, haze = 2.8, color = Color3.fromRGB(93, 112, 139), coverage = 0.95, cloudDensity = 0.95},
}

local function chooseWeather()
    local a = anger.Value
    local roll = math.random(1, 100)
    if a >= 75 then
        if roll <= 45 then return "Thunderstorm" end
        if roll <= 75 then return "Fog" end
        if roll <= 95 then return "Rain" end
        return "Clear"
    elseif a >= 40 then
        if roll <= 15 then return "Thunderstorm" end
        if roll <= 50 then return "Fog" end
        if roll <= 80 then return "Rain" end
        return "Clear"
    else
        if roll <= 55 then return "Clear" end
        if roll <= 78 then return "Rain" end
        return "Fog"
    end
end

local function applyAtmosphere()
    local p = profiles[weatherValue.Value] or profiles.Clear
    atmosphere.Density = p.density
    atmosphere.Haze = p.haze
    atmosphere.Color = p.color
    atmosphere.Decay = Color3.fromRGB(65, 72, 86)
    if clouds then
        clouds.Cover = p.coverage
        clouds.Density = p.cloudDensity
        clouds.Color = p.color
    end
    -- Brightness stays moderate to avoid overly dark mobile gameplay.
    Lighting.Brightness = (weatherValue.Value == "Thunderstorm") and 1.1 or 2
    Lighting.ExposureCompensation = (weatherValue.Value == "Fog") and -0.18 or 0
end

local currentHour = CONFIG.StartingHour
Lighting.ClockTime = currentHour
timeValue.Value = currentHour
weatherValue.Value = chooseWeather()
applyAtmosphere()

weatherValue.Changed:Connect(applyAtmosphere)

-- Monotonic step accumulator; handles variable frame rates without a per-frame loop.
task.spawn(function()
    local last = os.clock()
    while true do
        task.wait(0.2)
        local now = os.clock()
        local dt = math.min(now - last, 2)
        last = now
        currentHour = (currentHour + dt * 24 / CONFIG.DayLengthSeconds) % 24
        Lighting.ClockTime = currentHour
        timeValue.Value = currentHour
    end
end)

task.spawn(function()
    while true do
        task.wait(CONFIG.WeatherChangeSeconds)
        local nextWeather = chooseWeather()
        -- Weather is driven by server-side anger; never accept client-side weather requests.
        weatherValue.Value = nextWeather
    end
end)

-- Flash-free thunder event: client sees a brief "THUNDER" warning only.
task.spawn(function()
    while true do
        task.wait(math.random(CONFIG.ThunderIntervalMin, CONFIG.ThunderIntervalMax))
        if weatherValue.Value == "Thunderstorm" then
            thunderPulse.Value += 1
        end
    end
end)

print("[Anmol Weather] V1 running (weather + 12-minute day/night cycle)")
