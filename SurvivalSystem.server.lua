-- ANMOL: LIVING WORLD — Survival System V1
-- Place this Script in ServerScriptService.
-- Server owns Health, Hunger, Stamina and movement speeds.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CONFIG = {
    MaxHunger = 100,
    MaxStamina = 100,
    WalkSpeed = 16,
    SprintSpeed = 24,
    SprintDrainPerSecond = 15,
    StaminaRegenPerSecond = 12,
    RegenDelay = 1.5,
    HungerDrainPerSecond = 0.12,
    SprintHungerExtraPerSecond = 0.08,
    StarvationDamagePerSecond = 4,
    RecoveryThreshold = 12,
}

local folder = ReplicatedStorage:FindFirstChild("AnmolSurvivalRemotes")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "AnmolSurvivalRemotes"
    folder.Parent = ReplicatedStorage
end

local sprintRemote = folder:FindFirstChild("SetSprinting")
if not sprintRemote then
    sprintRemote = Instance.new("RemoteEvent")
    sprintRemote.Name = "SetSprinting"
    sprintRemote.Parent = folder
end

local stats = {} -- [player] = {hunger, stamina, wantsSprint, lastSprint, fractional...}

local function setAttributes(player, state)
    player:SetAttribute("SurvivalHunger", math.clamp(state.hunger, 0, CONFIG.MaxHunger))
    player:SetAttribute("SurvivalStamina", math.clamp(state.stamina, 0, CONFIG.MaxStamina))
    player:SetAttribute("SurvivalIsSprinting", state.isSprinting)
end

local function applySpeed(player, state)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        state.isSprinting = false
        return nil
    end
    local sprint = state.wantsSprint
        and state.stamina > 0
        and humanoid.MoveDirection.Magnitude > 0.05
    state.isSprinting = sprint
    humanoid.WalkSpeed = sprint and CONFIG.SprintSpeed or CONFIG.WalkSpeed
    return humanoid
end

local function setupPlayer(player)
    local state = {
        hunger = CONFIG.MaxHunger,
        stamina = CONFIG.MaxStamina,
        wantsSprint = false,
        isSprinting = false,
        lastSprint = -math.huge,
        starvationDamage = 0,
    }
    stats[player] = state
    setAttributes(player, state)
    player.CharacterAdded:Connect(function(character)
        state.hunger = CONFIG.MaxHunger -- V1 resets stats on respawn
        state.stamina = CONFIG.MaxStamina
        state.wantsSprint = false
        state.isSprinting = false
        state.starvationDamage = 0
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid then
            humanoid.WalkSpeed = CONFIG.WalkSpeed
        end
        setAttributes(player, state)
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

sprintRemote.OnServerEvent:Connect(function(player, desired)
    if type(desired) ~= "boolean" then return end
    local state = stats[player]
    if state then
        state.wantsSprint = desired
    end
end)

local last = os.clock()
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    local dt = math.clamp(now - last, 0, 0.25)
    last = now
    for player, state in pairs(stats) do
        local humanoid = applySpeed(player, state)
        if humanoid then
            if state.isSprinting then
                state.stamina = math.max(0, state.stamina - CONFIG.SprintDrainPerSecond * dt)
                state.lastSprint = now
                if state.stamina <= 0 then
                    state.wantsSprint = false
                    state.isSprinting = false
                    humanoid.WalkSpeed = CONFIG.WalkSpeed
                end
            elseif not state.wantsSprint and now - state.lastSprint >= CONFIG.RegenDelay then
                state.stamina = math.min(CONFIG.MaxStamina, state.stamina + CONFIG.StaminaRegenPerSecond * dt)
            elseif state.wantsSprint and humanoid.MoveDirection.Magnitude <= 0.05 and now - state.lastSprint >= CONFIG.RegenDelay then
                -- Let players recover while standing still.
                state.stamina = math.min(CONFIG.MaxStamina, state.stamina + CONFIG.StaminaRegenPerSecond * dt)
            end
            state.hunger = math.max(0, state.hunger - (CONFIG.HungerDrainPerSecond + (state.isSprinting and CONFIG.SprintHungerExtraPerSecond or 0)) * dt)
            if state.hunger <= 0 then
                state.starvationDamage += CONFIG.StarvationDamagePerSecond * dt
                local wholeDamage = math.floor(state.starvationDamage)
                if wholeDamage >= 1 then
                    humanoid:TakeDamage(wholeDamage)
                    state.starvationDamage -= wholeDamage
                end
            else
                state.starvationDamage = 0
            end
        else
            state.isSprinting = false
        end
        -- Attributes are replicated to clients for the HUD.
        setAttributes(player, state)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    stats[player] = nil
end)

-- Later: add server-validated food consumption through a dedicated RemoteEvent.
-- Do not let clients directly set Hunger or Stamina values.
