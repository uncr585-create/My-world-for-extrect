-- ANMOL: LIVING WORLD — Normal / Hardcore modes V1
-- ServerScriptService > Script
-- Server decides mode, respawn, revive, and elimination.
-- V1 run is limited to the current server session. A separate run save is needed
-- before hardcore elimination can persist across server re-joins.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Players.CharacterAutoLoads = false

local NORMAL_REVIVE_SECONDS = 45
local HARDCORE_REVIVE_SECONDS = 20
local REVIVE_HOLD_SECONDS = 3

local remoteFolder = ReplicatedStorage:FindFirstChild("AnmolModeRemotes") or Instance.new("Folder")
remoteFolder.Name = "AnmolModeRemotes"
remoteFolder.Parent = ReplicatedStorage
local chooseMode = remoteFolder:FindFirstChild("ChooseMode") or Instance.new("RemoteFunction")
chooseMode.Name = "ChooseMode"
chooseMode.Parent = remoteFolder

local rescueFolder = workspace:FindFirstChild("AnmolReviveMarkers") or Instance.new("Folder")
rescueFolder.Name = "AnmolReviveMarkers"
rescueFolder.Parent = workspace

local states = {} -- [player] = {mode, status, generation, marker, dyingConnection}

local function setStatus(player, state, newStatus)
    state.status = newStatus
    player:SetAttribute("AnmolGameMode", state.mode)
    player:SetAttribute("AnmolLifeState", newStatus)
end

local function clearMarker(state)
    if state.marker then
        state.marker:Destroy()
        state.marker = nil
    end
end

local function safeSpawn(player, state)
    if not player.Parent or states[player] ~= state then return end
    state.generation += 1 -- invalidate the previous revive timeout
    clearMarker(state)
    setStatus(player, state, "Alive")
    local ok, err = pcall(function() player:LoadCharacter() end)
    if not ok then
        warn("[Anmol Modes] Failed to spawn:", player.Name, err)
        setStatus(player, state, "SpawnError")
    end
end

local function isEligibleReviver(reviver, target)
    if reviver == target then return false end
    local state = states[reviver]
    if not state or state.status ~= "Alive" then return false end
    local char = reviver.Character
    local human = char and char:FindFirstChildOfClass("Humanoid")
    return human ~= nil and human.Health > 0
end

local function onDeath(player, state, character)
    if states[player] ~= state or state.status ~= "Alive" then return end
    setStatus(player, state, "Downed")
    local timeLimit = state.mode == "Hardcore" and HARDCORE_REVIVE_SECONDS or NORMAL_REVIVE_SECONDS
    local currentGeneration = state.generation + 1
    state.generation = currentGeneration

    local root = character:FindFirstChild("HumanoidRootPart")
    local lastPosition = root and root.Position or character:GetPivot().Position

    local marker = Instance.new("Part")
    marker.Name = player.Name .. "_Revive"
    marker.Size = Vector3.new(3, 1, 3)
    marker.CFrame = CFrame.new(lastPosition + Vector3.new(0, 2.5, 0))
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.Transparency = 0.35
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(81, 221, 166)
    marker.Parent = rescueFolder
    state.marker = marker

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Revive " .. player.DisplayName
    prompt.ObjectText = "Downed teammate"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = REVIVE_HOLD_SECONDS
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = marker

    prompt.Triggered:Connect(function(reviver)
        if states[player] ~= state or state.status ~= "Downed" then return end
        if state.generation ~= currentGeneration then return end
        if not isEligibleReviver(reviver, player) then return end
        local char = reviver.Character
        local reviverRoot = char and char:FindFirstChild("HumanoidRootPart")
        if not reviverRoot or (reviverRoot.Position - marker.Position).Magnitude > 14 then return end
        safeSpawn(player, state) -- V1 revive respawns at spawn, NOT the fallen position
    end)

    task.delay(timeLimit, function()
        if states[player] ~= state or state.status ~= "Downed" then return end
        if state.generation ~= currentGeneration then return end
        clearMarker(state)
        if state.mode == "Normal" then
            safeSpawn(player, state)
        else
            setStatus(player, state, "Eliminated")
            -- CharacterAutoLoads=false prevents a new character in this session.
        end
    end)
end

local function setupPlayer(player)
    local state = { mode = nil, status = "Selecting", generation = 0, marker = nil }
    states[player] = state
    player:SetAttribute("AnmolLifeState", "Selecting")
    player:SetAttribute("AnmolGameMode", "")
    player.CharacterAdded:Connect(function(character)
        if states[player] ~= state then return end
        -- Attach to each newly spawned Humanoid.
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid then
            humanoid.BreakJointsOnDeath = false
            humanoid.Died:Connect(function() onDeath(player, state, character) end)
        end
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

chooseMode.OnServerInvoke = function(player, requestedMode)
    if requestedMode ~= "Normal" and requestedMode ~= "Hardcore" then
        return false, "Invalid mode"
    end
    local state = states[player]
    if not state then return false, "Player not ready" end
    if state.mode ~= nil then
        return false, "Mode already chosen for this server session"
    end
    state.mode = requestedMode
    safeSpawn(player, state)
    return state.status == "Alive", state.status == "Alive" and requestedMode or "Spawn failed"
end

Players.PlayerRemoving:Connect(function(player)
    local state = states[player]
    if state then
        state.generation += 1
        clearMarker(state)
        states[player] = nil
    end
end)
