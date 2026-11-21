-- Script: ServerScriptService/MonsterAI
-- ANMOL: LIVING WORLD - Monster AI V1
-- Server controls spawning, target selection, movement and damage.
-- Includes simple generated placeholder monsters; replace with custom rigs later.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ServerScriptService:WaitForChild("MonsterConfig"))

local monstersFolder = Workspace:FindFirstChild("AnmolMonsters") or Instance.new("Folder")
monstersFolder.Name = "AnmolMonsters"
monstersFolder.Parent = Workspace

local spawnFolder = Workspace:FindFirstChild("MonsterSpawns")
if not spawnFolder then
    spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "MonsterSpawns"
    spawnFolder.Parent = Workspace
end

local function anger()
    local a = tonumber(Workspace:GetAttribute(Config.AngerAttribute))
    return math.clamp(a or 0, 0, 100)
end

local function makePart(name, size, color, parent, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = Enum.Material.SmoothPlastic
    part.CanCollide = name == "Torso"
    part.Transparency = transparency or 0
    part.Parent = parent
    return part
end

local function motor(name, part0, part1, c0, c1)
    local joint = Instance.new("Motor6D")
    joint.Name = name
    joint.Part0 = part0
    joint.Part1 = part1
    joint.C0 = c0
    joint.C1 = c1 or CFrame.new()
    joint.Parent = part0
end

local function createMonster(monsterType, pos)
    local data = Config.Types[monsterType]
    local model = Instance.new("Model")
    model.Name = monsterType
    model:SetAttribute("AnmolMonster", true)
    model:SetAttribute("MonsterType", monsterType)

    local root = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), data.Color, model, 1)
    root.CanCollide = false
    local torso = makePart("Torso", Vector3.new(2, 2, 1), data.Color, model)
    local head = makePart("Head", Vector3.new(1.7, 1.5, 1.5), data.Color, model)
    local lArm = makePart("Left Arm", Vector3.new(1, 2, 1), data.Color, model)
    local rArm = makePart("Right Arm", Vector3.new(1, 2, 1), data.Color, model)
    local lLeg = makePart("Left Leg", Vector3.new(1, 2, 1), data.Color, model)
    local rLeg = makePart("Right Leg", Vector3.new(1, 2, 1), data.Color, model)
    for _, limb in ipairs({head, lArm, rArm, lLeg, rLeg}) do
        limb.CanCollide = false
        limb.Massless = true
    end
    -- Roblox R6-compatible motors and attachment offsets
    motor("RootJoint", root, torso, CFrame.new(), CFrame.new())
    motor("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.75, 0))
    motor("Left Shoulder", torso, lArm, CFrame.new(-1.5, 0.5, 0), CFrame.new(0, 0.5, 0))
    motor("Right Shoulder", torso, rArm, CFrame.new(1.5, 0.5, 0), CFrame.new(0, 0.5, 0))
    motor("Left Hip", torso, lLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
    motor("Right Hip", torso, rLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))

    local hum = Instance.new("Humanoid")
    hum.Name = "Humanoid"
    hum.RigType = Enum.HumanoidRigType.R6
    hum.MaxHealth = data.MaxHealth
    hum.Health = data.MaxHealth
    hum.WalkSpeed = data.WalkSpeed
    hum.BreakJointsOnDeath = false
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum.Parent = model

    local glow = Instance.new("PointLight")
    glow.Color = data.Glow
    glow.Range = 10
    glow.Brightness = 0.7
    glow.Parent = head

    local eyeGui = Instance.new("BillboardGui")
    eyeGui.Name = "Eyes"
    eyeGui.Size = UDim2.fromOffset(76, 28)
    eyeGui.StudsOffset = Vector3.new(0, 0.05, -0.85)
    eyeGui.AlwaysOnTop = true
    eyeGui.Parent = head
    local eyes = Instance.new("TextLabel")
    eyes.Size = UDim2.fromScale(1, 1)
    eyes.BackgroundTransparency = 1
    eyes.Text = "●  ●"
    eyes.TextColor3 = data.Glow
    eyes.TextScaled = true
    eyes.Font = Enum.Font.GothamBold
    eyes.Parent = eyeGui

    model.PrimaryPart = root
    model.Parent = monstersFolder
    model:PivotTo(CFrame.new(pos + Vector3.new(0, 4, 0)))
    pcall(function() root:SetNetworkOwner(nil) end)
    return model, hum, root
end

local function getAlivePlayers()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 then
            table.insert(list, { player = player, humanoid = hum, root = root })
        end
    end
    return list
end

local function chooseTarget(monsterType, origin)
    local cfg = Config.Types[monsterType]
    local best, bestScore
    local currentAnger = anger()
    local detection = cfg.DetectionRadius * (1 + currentAnger / 180)
    for _, info in ipairs(getAlivePlayers()) do
        local dist = (info.root.Position - origin).Magnitude
        local moving = info.root.AssemblyLinearVelocity.Magnitude
        local running = moving > 14
        local effectiveRange = detection + (running and 30 * cfg.NoiseSensitivity or 0)
        if dist <= effectiveRange then
            local score = dist - (running and 12 * cfg.NoiseSensitivity or 0)
            if not best or score < bestScore then
                best = info
                bestScore = score
            end
        end
    end
    return best
end

local function moveToward(hum, root, destination)
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    local ok = pcall(function() path:ComputeAsync(root.Position, destination) end)
    if ok and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        local nextWp = waypoints[math.min(2, #waypoints)]
        if nextWp then
            if nextWp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
            hum:MoveTo(nextWp.Position)
            return
        end
    end
    hum:MoveTo(destination)
end

local function dealArmorAwareDamage(player, humanoid, amount)
    local bridge = game:GetService("ServerScriptService"):FindFirstChild("AnmolApplyPlayerDamage")
    if bridge and bridge:IsA("BindableFunction") then
        local ok, result = pcall(function() return bridge:Invoke(player, amount) end)
        if ok and result == true then return end
    end
    humanoid:TakeDamage(amount)
end

local function monsterBrain(monsterType, model, hum, root)
    local cfg = Config.Types[monsterType]
    local target = nil
    local lastAttack = 0
    local lastPath = 0
    local home = root.Position
    local wanderGoal = home
    while model.Parent and hum.Health > 0 do
        task.wait(0.25)
        if not model.Parent or hum.Health <= 0 then break end
        if target then
            local character = target.player.Character
            if not character or target.humanoid.Health <= 0 or not target.root:IsDescendantOf(Workspace)
                or (target.root.Position - root.Position).Magnitude > cfg.LoseRadius then
                target = nil
            end
        end
        if not target then target = chooseTarget(monsterType, root.Position) end
        if target then
            hum.WalkSpeed = cfg.ChaseSpeed
            local dist = (target.root.Position - root.Position).Magnitude
            if dist <= cfg.AttackRadius and os.clock() - lastAttack >= cfg.AttackCooldown then
                lastAttack = os.clock()
                dealArmorAwareDamage(target.player, target.humanoid, cfg.Damage)
            end
            if os.clock() - lastPath > 0.8 then
                lastPath = os.clock()
                moveToward(hum, root, target.root.Position)
            end
        else
            hum.WalkSpeed = cfg.WalkSpeed
            if (wanderGoal - root.Position).Magnitude < 6 or os.clock() - lastPath > 5 then
                wanderGoal = home + Vector3.new(math.random(-24,24), 0, math.random(-24,24))
                lastPath = os.clock()
                moveToward(hum, root, wanderGoal)
            end
        end
    end
    if model.Parent then
        task.wait(2)
        model:Destroy()
    end
end

local function playerNearSpawn(pos)
    local nearest = math.huge
    for _, p in ipairs(getAlivePlayers()) do
        nearest = math.min(nearest, (p.root.Position - pos).Magnitude)
    end
    return nearest
end

local function getSpawnPosition()
    local points = {}
    for _, obj in ipairs(spawnFolder:GetChildren()) do
        if obj:IsA("BasePart") then table.insert(points, obj) end
    end
    if #points > 0 then
        local shuffled = table.clone(points)
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        for _, point in ipairs(shuffled) do
            if playerNearSpawn(point.Position) >= Config.MinSpawnDistance then
                return point.Position
            end
        end
        return nil
    end

    -- Temporary fallback for early testing (no spawn markers yet).
    local players = getAlivePlayers()
    if #players == 0 then return nil end
    local p = players[math.random(#players)]
    local angle = math.random() * math.pi * 2
    local dist = math.random(Config.MinSpawnDistance + 10, Config.MaxSpawnDistance)
    local approx = p.root.Position + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {monstersFolder, p.root.Parent}
    local hit = Workspace:Raycast(approx + Vector3.new(0, 120, 0), Vector3.new(0, -260, 0), params)
    return hit and hit.Position or nil
end

local function spawnOne()
    if #monstersFolder:GetChildren() >= Config.MaxMonsters then return end
    local pos = getSpawnPosition()
    if not pos then return end
    local which = "RootStalker"
    if anger() >= Config.Types.WhisperShade.MinAnger and math.random() < 0.45 then
        which = "WhisperShade"
    end
    local model, hum, root = createMonster(which, pos)
    task.spawn(monsterBrain, which, model, hum, root)
end

Workspace:SetAttribute("AnmolMonsterSystemReady", true)
while true do
    task.wait(Config.SpawnInterval)
    spawnOne()
    Workspace:SetAttribute("AnmolMonsterCount", #monstersFolder:GetChildren())
end
