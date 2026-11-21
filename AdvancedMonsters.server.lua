-- ANMOL: LIVING WORLD | Monster AI V2 — Hollow Deer + Crystal Burrower
-- Script -> ServerScriptService. Keep MonsterAI.server.lua (V1) enabled.
-- V2 is a standalone addition: does not require editing the V1 MonsterConfig.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local PathfindingService = game:GetService("PathfindingService")

local folder = Workspace:FindFirstChild("AnmolMonsters")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "AnmolMonsters"
    folder.Parent = Workspace
end
local spawnFolder = Workspace:WaitForChild("MonsterSpawns", 30)
local world = RS:WaitForChild("AnmolWorldState", 30)
local angerValue = world and world:WaitForChild("Anger", 15)
local action = SS:FindFirstChild("AnmolWorldAction")
if not action then action = SS:WaitForChild("AnmolWorldAction", 30) end

local SETTINGS = {
    HollowDeer = {maxHealth=125, walk=9, chase=18, attackDamage=17, reach=6,
        detect=50, lose=90, attackCooldown=2.1, respawn=38,
        color=Color3.fromRGB(68, 58, 53), glow=Color3.fromRGB(120, 250, 145),
        spawnName="AnmolForestDeerSpawn"},
    CrystalBurrower = {maxHealth=180, walk=8, chase=21, attackDamage=22, reach=7,
        detect=55, lose=105, attackCooldown=2.4, respawn=45,
        color=Color3.fromRGB(49, 64, 85), glow=Color3.fromRGB(65, 220, 255),
        spawnName="AnmolCrystalSpawn_1"},
}
local function anger()
    return angerValue and math.clamp(tonumber(angerValue.Value) or 0,0,100) or 0
end

local function findSpawn(monsterType)
    if not spawnFolder then return nil end
    local cfg = SETTINGS[monsterType]
    local chosen = spawnFolder:FindFirstChild(cfg.spawnName)
    if not chosen and monsterType == "HollowDeer" then
        for _, obj in ipairs(spawnFolder:GetChildren()) do
            if obj:IsA("BasePart") and not obj.Name:find("Crystal")
               and not obj.Name:find("Marsh") and not obj.Name:find("Heart") then
                chosen = obj; break
            end
        end
    end
    if chosen and chosen:IsA("BasePart") then return chosen.Position end
    return nil
end

-- Simple R6-compatible rig so Humanoid:MoveTo and existing Combat work.
local function part(model,name,size,color,collide)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.Color=color;p.Material=Enum.Material.SmoothPlastic
    p.CanCollide=collide or false;p.Massless=not collide;p.Parent=model
    return p
end
local function joint(p0,p1,name,c0,c1)
    local m=Instance.new("Motor6D")
    m.Name=name;m.Part0=p0;m.Part1=p1;m.C0=c0;m.C1=c1;m.Parent=p0
end
local function createMonster(kind,position)
    local cfg=SETTINGS[kind]
    local model=Instance.new("Model")
    model.Name=kind
    model:SetAttribute("AnmolMonster",true)
    model:SetAttribute("MonsterType",kind)
    local root=part(model,"HumanoidRootPart",Vector3.new(2,2,1),cfg.color)
    root.Transparency=1
    local torso=part(model,"Torso",Vector3.new(2,2,1),cfg.color,true)
    local head=part(model,"Head",Vector3.new(1.7,1.7,1.5),cfg.color)
    local la=part(model,"Left Arm",Vector3.new(1,2,1),cfg.color)
    local ra=part(model,"Right Arm",Vector3.new(1,2,1),cfg.color)
    local ll=part(model,"Left Leg",Vector3.new(1,2,1),cfg.color)
    local rl=part(model,"Right Leg",Vector3.new(1,2,1),cfg.color)
    joint(root,torso,"RootJoint",CFrame.new(),CFrame.new())
    joint(torso,head,"Neck",CFrame.new(0,1,0),CFrame.new(0,-0.85,0))
    joint(torso,la,"Left Shoulder",CFrame.new(-1.5,0.5,0),CFrame.new(0,0.5,0))
    joint(torso,ra,"Right Shoulder",CFrame.new(1.5,0.5,0),CFrame.new(0,0.5,0))
    joint(torso,ll,"Left Hip",CFrame.new(-0.5,-1,0),CFrame.new(0,1,0))
    joint(torso,rl,"Right Hip",CFrame.new(0.5,-1,0),CFrame.new(0,1,0))
    local hum=Instance.new("Humanoid")
    hum.RigType=Enum.HumanoidRigType.R6
    hum.MaxHealth=cfg.maxHealth;hum.Health=cfg.maxHealth
    hum.WalkSpeed=cfg.walk
    hum.BreakJointsOnDeath=false
    hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    hum.Parent=model
    local light=Instance.new("PointLight")
    light.Color=cfg.glow;light.Range=12;light.Brightness=1.2;light.Parent=head
    local label=Instance.new("BillboardGui")
    label.Size=UDim2.fromOffset(130,30);label.StudsOffset=Vector3.new(0,2.2,0)
    label.AlwaysOnTop=true;label.Parent=head
    local text=Instance.new("TextLabel")
    text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1
    text.Text=kind=="HollowDeer" and "🦌 Hollow Deer" or "💎 Crystal Burrower"
    text.TextColor3=cfg.glow;text.TextScaled=true
    text.Font=Enum.Font.GothamBold;text.Parent=label
    model.PrimaryPart=root
    model.Parent=folder
    model:PivotTo(CFrame.new(position+Vector3.new(0,4,0)))
    pcall(function()root:SetNetworkOwner(nil)end)
    return model,hum,root
end

local crystalAlertUntil = 0
if action then
    action.Event:Connect(function(name)
        if name=="CrystalMined" then
            crystalAlertUntil=os.clock()+18
        end
    end)
end

local function nearestPlayer(origin,maxDistance)
    local selected, bestDist=nil,maxDistance
    for _,p in ipairs(Players:GetPlayers()) do
        local ch=p.Character
        local h=ch and ch:FindFirstChildOfClass("Humanoid")
        local r=ch and ch:FindFirstChild("HumanoidRootPart")
        if h and r and h.Health>0 then
            local dist=(r.Position-origin).Magnitude
            if dist<bestDist then selected={player=p,hum=h,root=r};bestDist=dist end
        end
    end
    return selected,bestDist
end
local function move(hum,root,pos)
    local path=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
    local ok=pcall(function()path:ComputeAsync(root.Position,pos)end)
    if ok and path.Status==Enum.PathStatus.Success then
        local points=path:GetWaypoints()
        local waypoint=points[math.min(2,#points)]
        if waypoint then
            if waypoint.Action==Enum.PathWaypointAction.Jump then hum.Jump=true end
            hum:MoveTo(waypoint.Position)
            return
        end
    end
    hum:MoveTo(pos)
end

local function runBrain(kind,model,hum,root)
    local cfg=SETTINGS[kind]
    local angry=false
    local startingHealth=hum.Health
    local home=root.Position
    local lastAttack=0
    local lastMove=0
    local goal=home
    hum.HealthChanged:Connect(function(value)
        if value<startingHealth then angry=true end -- Deer reacts when attacked
        startingHealth=value
    end)
    while model.Parent and hum.Health>0 do
        task.wait(0.35)
        if not model.Parent or hum.Health<=0 then break end
        local currentAnger=anger()
        local aggro=false
        local range=cfg.detect
        if kind=="HollowDeer" then
            aggro=angry or currentAnger>=80
            -- Neutral deer does not attack until provoked or World Anger >=80.
        else
            aggro=true
            if os.clock()<crystalAlertUntil then range=range+45 end
        end
        local target,dist=nearestPlayer(root.Position,range)
        if target and aggro then
            hum.WalkSpeed=cfg.chase
            if dist<=cfg.reach and os.clock()-lastAttack>=cfg.attackCooldown then
                lastAttack=os.clock()
                if target.hum.Health>0 then target.hum:TakeDamage(cfg.attackDamage) end
            end
            if os.clock()-lastMove>1 then
                lastMove=os.clock()
                move(hum,root,target.root.Position)
            end
        else
            hum.WalkSpeed=cfg.walk
            if (goal-root.Position).Magnitude<5 or os.clock()-lastMove>5 then
                goal=home+Vector3.new(math.random(-17,17),0,math.random(-17,17))
                lastMove=os.clock()
                move(hum,root,goal)
            end
        end
    end
    task.wait(2)
    if model.Parent then model:Destroy() end
end

local function loopType(kind)
    local cfg=SETTINGS[kind]
    while true do
        local pos=findSpawn(kind)
        if pos then
            local model,hum,root=createMonster(kind,pos)
            task.spawn(runBrain,kind,model,hum,root)
            -- max one spawned of this type at a time
            hum.Died:Wait()
            task.wait(cfg.respawn)
        else
            warn("[Anmol Monster V2] Missing spawn marker for "..kind..". Waiting...")
            task.wait(15)
            spawnFolder=Workspace:FindFirstChild("MonsterSpawns")
        end
    end
end
-- Map scripts may create spawn markers after this script starts.
task.spawn(loopType,"HollowDeer")
task.spawn(loopType,"CrystalBurrower")
print("[Anmol] Monster AI V2 loaded")
