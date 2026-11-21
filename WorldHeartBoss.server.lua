-- ANMOL: LIVING WORLD — World Heart Boss V1
-- ServerScriptService > Script named WorldHeartBoss
-- Requires IslandMap.server.lua + IslandExpansionV2.server.lua
-- Native parts only: no external assets. Server validates all interactions.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local island = Workspace:WaitForChild("AnmolIslandV1", 90)
local expansion = island and island:WaitForChild("ExpansionV2", 90)
local heartZone = expansion and expansion:WaitForChild("WorldHeart", 90)
local heartCore = heartZone and heartZone:WaitForChild("LivingHeart", 30)
if not heartCore or not heartCore:IsA("BasePart") then
    warn("[Anmol Boss] Missing LivingHeart. Run IslandMap and IslandExpansionV2 first.")
    return
end

local CENTER = Vector3.new(heartCore.Position.X, 3, heartCore.Position.Z)
local ARENA_RADIUS = 66
local MAX_HEALTH = 300
local ATTACK_COOLDOWN = 1.35
local RESET_DELAY = 18
local FAIL_AFTER = 150

local stateFolder = ReplicatedStorage:FindFirstChild("AnmolBossState") or Instance.new("Folder")
stateFolder.Name = "AnmolBossState"
stateFolder.Parent = ReplicatedStorage
local function value(className, name, start)
    local inst = stateFolder:FindFirstChild(name) or Instance.new(className)
    inst.Name = name
    inst.Value = start
    inst.Parent = stateFolder
    return inst
end
local active = value("BoolValue", "Active", false)
local hp = value("IntValue", "Health", MAX_HEALTH)
local maxHp = value("IntValue", "MaxHealth", MAX_HEALTH)
local phase = value("IntValue", "Phase", 0)
local message = value("StringValue", "Message", "Approach the World Heart to start the trial")

local worldState = ReplicatedStorage:FindFirstChild("AnmolWorldState")
local function getAnger()
    worldState = worldState or ReplicatedStorage:FindFirstChild("AnmolWorldState")
    local anger = worldState and worldState:FindFirstChild("Anger")
    return anger and math.clamp(anger.Value, 0, 100) or 20
end

local visuals = heartZone:FindFirstChild("BossV1Visuals") or Instance.new("Folder")
visuals.Name = "BossV1Visuals"
visuals.Parent = heartZone
visuals:ClearAllChildren() -- helpful when preview-testing in Studio

local function part(name, size, pos, color, transparency, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.Material = Enum.Material.Neon
    p.Color = color
    p.Transparency = transparency or 0
    if shape then p.Shape = shape end
    p.Parent = visuals
    return p
end

local guardian = part("Guardian", Vector3.new(15, 18, 15), CENTER + Vector3.new(0, 14, 0), Color3.fromRGB(198, 54, 109), .12, Enum.PartType.Ball)
local light = Instance.new("PointLight")
light.Color = guardian.Color
light.Range = 40
light.Brightness = 2
light.Parent = guardian

local function inArena(pos)
    return (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(CENTER.X, 0, CENTER.Z)).Magnitude <= ARENA_RADIUS
end
local function validCharacter(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then return nil, nil end
    return humanoid, root
end
local function makePrompt(parent, action, object, distance, hold)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "BossPrompt"
    prompt.ActionText = action
    prompt.ObjectText = object
    prompt.HoldDuration = hold or .5
    prompt.MaxActivationDistance = distance or 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = parent
    return prompt
end

-- Place interaction near the arena FLOOR; the LivingHeart core is 20 studs above ground.
local startPad = part("StartTrialPedestal", Vector3.new(7, 2, 7), CENTER + Vector3.new(0, -1, -45), Color3.fromRGB(74, 227, 162))
local startPrompt = makePrompt(startPad, "Start Heart Trial", "World Heart", 12, 1)
local strikePrompts = {}
for i, angle in ipairs({0, math.pi * 2 / 3, math.pi * 4 / 3}) do
    local pos = CENTER + Vector3.new(math.cos(angle)*23, 1, math.sin(angle)*23)
    local pad = part("StrikeCrystal" .. i, Vector3.new(6, 7, 6), pos, Color3.fromRGB(111, 197, 250), .12)
    local prompt = makePrompt(pad, "Channel Strike", "Guardian", 10, .35)
    prompt.Enabled = false
    table.insert(strikePrompts, {part = pad, prompt = prompt})
end

local combatGeneration = 0
local lastHitAt = {}
local lastActivity = 0
local pendingReset = false

local function enableStrikes(isEnabled)
    for _, entry in ipairs(strikePrompts) do
        entry.prompt.Enabled = isEnabled
    end
end
local function setPhaseFromHealth()
    local ratio = hp.Value / math.max(1, MAX_HEALTH)
    local p = ratio > .66 and 1 or ratio > .33 and 2 or 3
    if phase.Value ~= p then
        phase.Value = p
        message.Value = ({"The Heart awakens", "The roots are enraged", "FINAL PHASE!"})[p]
        guardian.Color = ({Color3.fromRGB(198,54,109),Color3.fromRGB(251,136,49),Color3.fromRGB(245,44,69)})[p]
        light.Color = guardian.Color
    end
end
local function finish(victory)
    if not active.Value then return end
    active.Value = false
    enableStrikes(false)
    combatGeneration += 1
    message.Value = victory and "Guardian defeated! Island heart is calmer." or "The trial faded. Try again."
    startPrompt.Enabled = false
    if victory then
        local action = game:GetService("ServerScriptService"):FindFirstChild("AnmolWorldAction")
        if action and action:IsA("BindableEvent") then
            action:Fire("WorldHeartHealed") -- uses existing server-only World Anger action
        end
    end
    if pendingReset then return end
    pendingReset = true
    task.delay(RESET_DELAY, function()
        pendingReset = false
        hp.Value = MAX_HEALTH
        phase.Value = 0
        startPrompt.Enabled = true
        message.Value = "Approach the World Heart to start the trial"
        guardian.Color = Color3.fromRGB(198, 54, 109)
        light.Color = guardian.Color
    end)
end

local function warningBlast(centerPoint, radius, damage, generation)
    local disk = part("DangerWarning", Vector3.new(radius * 2, .28, radius * 2),
        Vector3.new(centerPoint.X, CENTER.Y + .2, centerPoint.Z), Color3.fromRGB(255, 78, 77), .52, Enum.PartType.Cylinder)
    -- Cylinders use their X axis as height: rotate to make a flat ground warning.
    disk.CFrame = CFrame.new(disk.Position) * CFrame.Angles(0, 0, math.pi / 2)
    disk.CanQuery = false
    task.wait(1.25) -- gives players a fair chance to dodge
    if active.Value and generation == combatGeneration then
        for _, player in ipairs(Players:GetPlayers()) do
            local humanoid, root = validCharacter(player)
            if humanoid and root and inArena(root.Position) then
                local dxz = Vector3.new(root.Position.X - centerPoint.X, 0, root.Position.Z - centerPoint.Z)
                if dxz.Magnitude <= radius then
                    humanoid:TakeDamage(damage)
                end
            end
        end
    end
    disk:Destroy()
end

local function fightLoop(generation)
    local fightStartedAt = os.clock()
    while active.Value and generation == combatGeneration do
        if os.clock() - fightStartedAt > FAIL_AFTER or os.clock() - lastActivity > 45 then
            finish(false)
            break
        end
        local targets = {}
        for _, player in ipairs(Players:GetPlayers()) do
            local humanoid, root = validCharacter(player)
            if humanoid and root and inArena(root.Position) then
                table.insert(targets, root)
            end
        end
        if #targets == 0 then
            task.wait(1.5)
        else
            local chosen = targets[math.random(1, #targets)]
            local p = chosen.Position
            local angerMultiplier = 1 + (getAnger() / 200) -- at 100 anger = 1.5x
            local radius = ({10, 13, 16})[phase.Value] or 10
            local dmg = math.floor((({12, 17, 23})[phase.Value] or 12) * angerMultiplier)
            task.spawn(warningBlast, p, radius, dmg, generation)
            task.wait((({4.0, 3.2, 2.5})[phase.Value] or 4.0))
        end
    end
end

startPrompt.Triggered:Connect(function(player)
    local humanoid, root = validCharacter(player)
    if not humanoid or not root or (root.Position - startPad.Position).Magnitude > 14 then return end
    if active.Value or pendingReset then return end
    active.Value = true
    combatGeneration += 1
    hp.Value = MAX_HEALTH
    phase.Value = 0
    setPhaseFromHealth()
    lastActivity = os.clock()
    lastHitAt = {}
    startPrompt.Enabled = false
    enableStrikes(true)
    task.spawn(fightLoop, combatGeneration)
end)

for _, entry in ipairs(strikePrompts) do
    entry.prompt.Triggered:Connect(function(player)
        if not active.Value then return end
        local humanoid, root = validCharacter(player)
        if not humanoid or not root then return end
        if (root.Position - entry.part.Position).Magnitude > 13 or not inArena(root.Position) then return end
        local now = os.clock()
        if now - (lastHitAt[player] or -100) < ATTACK_COOLDOWN then return end
        lastHitAt[player] = now
        lastActivity = now
        hp.Value = math.max(0, hp.Value - 15)
        if hp.Value <= 0 then
            finish(true)
        else
            setPhaseFromHealth()
        end
    end)
end

Players.PlayerRemoving:Connect(function(player)
    lastHitAt[player] = nil
end)

print("[Anmol Boss] World Heart boss V1 ready. Start the trial at the green pedestal.")
