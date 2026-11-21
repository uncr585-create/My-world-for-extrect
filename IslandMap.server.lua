-- ANMOL: LIVING WORLD - Island Map V1 (prototype)
-- Script location: ServerScriptService/IslandMap
-- Builds Heart Village + Whispering Forest and future-area signposts.
-- Deterministic placeholder geometry; replace with final meshes and terrain later.
-- Compatible with InventoryCrafting.server.lua resource tags and MonsterAI.server.lua spawn markers.

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local rng = Random.new(20261121)
local old = Workspace:FindFirstChild("AnmolIslandV1")
if old then
    warn("[Anmol Island] Already generated. Skip second copy.")
    return
end

local map = Instance.new("Folder")
map.Name = "AnmolIslandV1"
map.Parent = Workspace
local forest = Instance.new("Folder")
forest.Name = "WhisperingForest"
forest.Parent = map
local village = Instance.new("Folder")
village.Name = "HeartVillage"
village.Parent = map
local future = Instance.new("Folder")
future.Name = "FutureAreaMarkers"
future.Parent = map
local resourceFolder = Instance.new("Folder")
resourceFolder.Name = "ForestResources"
resourceFolder.Parent = map

local C = {
    grass = Color3.fromRGB(63, 118, 75),
    village = Color3.fromRGB(96, 150, 100),
    dirt = Color3.fromRGB(126, 98, 70),
    trunk = Color3.fromRGB(85, 64, 55),
    leaf = Color3.fromRGB(39, 91, 69),
    moss = Color3.fromRGB(67, 120, 82),
    stone = Color3.fromRGB(106, 120, 128),
    crystal = Color3.fromRGB(75, 224, 245),
    flower = Color3.fromRGB(128, 244, 175),
}

local function block(name, size, pos, color, material, parent, canCollide, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.CanCollide = canCollide ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function label(target, text, width)
    local gui = Instance.new("BillboardGui")
    gui.Name = "AreaLabel"
    gui.Size = UDim2.fromOffset(width or 200, 48)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 6, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 150
    gui.Parent = target
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundColor3 = Color3.fromRGB(13, 31, 25)
    t.BackgroundTransparency = .18
    t.TextColor3 = Color3.fromRGB(216, 255, 223)
    t.TextStrokeTransparency = .65
    t.Font = Enum.Font.GothamBold
    t.TextScaled = true
    t.Text = text
    t.Parent = gui
end

-- Ground top is Y=0. Village centered near X=-185; forest near X=150.
block("IslandBase", Vector3.new(800, 20, 600), Vector3.new(0, -11, 0), C.grass, Enum.Material.Grass, map)
block("VillageGround", Vector3.new(220, 2, 240), Vector3.new(-190, -.4, 0), C.village, Enum.Material.Grass, village)
block("ForestGround", Vector3.new(390, 2, 470), Vector3.new(154, -.4, 0), C.grass, Enum.Material.Grass, forest)
-- Continuous traversable central path, oriented East/West.
block("VillageToForestPath", Vector3.new(425, .3, 20), Vector3.new(-8, .78, 0), C.dirt, Enum.Material.Ground, map)

-- Heart Village spawn: players appear on the safe central clearing.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "HeartVillageSpawn"
spawn.Size = Vector3.new(14, 1, 14)
spawn.Position = Vector3.new(-190, 1.3, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.CanCollide = true
spawn.Color = Color3.fromRGB(91, 202, 151)
spawn.Material = Enum.Material.Neon
spawn.Parent = village
label(spawn, "HEART VILLAGE", 220)

local function hut(x, z, angle)
    local model = Instance.new("Model")
    model.Name = "VillageHut"
    model.Parent = village
    local cf = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(angle), 0)
    local base = block("Walls", Vector3.new(20, 14, 17), (cf * CFrame.new(0, 7, 0)).Position,
        Color3.fromRGB(143, 109, 80), Enum.Material.WoodPlanks, model)
    base.CFrame = cf * CFrame.new(0, 7, 0)
    local roof = block("Roof", Vector3.new(25, 3, 21), (cf * CFrame.new(0, 15, 0)).Position,
        Color3.fromRGB(70, 61, 60), Enum.Material.Slate, model)
    roof.CFrame = cf * CFrame.new(0, 15, 0)
    local door = block("Door", Vector3.new(7, 9, .5), (cf * CFrame.new(0, 4.5, -8.8)).Position,
        Color3.fromRGB(56, 47, 38), Enum.Material.Wood, model, false)
    door.CFrame = cf * CFrame.new(0, 4.5, -8.8)
end
hut(-240, -52, 15)
hut(-230, 65, -16)
hut(-144, -65, -25)

local fire = block("Campfire", Vector3.new(6, 2, 6), Vector3.new(-184, 1.2, -32),
    Color3.fromRGB(246, 158, 66), Enum.Material.Neon, village, false, Enum.PartType.Ball)
local flameLight = Instance.new("PointLight")
flameLight.Range, flameLight.Brightness = 20, 2
flameLight.Color = Color3.fromRGB(255, 168, 93)
flameLight.Parent = fire
label(fire, "CAMP • SAFE SPAWN", 210)

-- Decorative tree; non-interactive. Resource trees are tagged separately.
local function tree(x, z, scale)
    local m = Instance.new("Model")
    m.Name = "WhisperTree"
    m.Parent = forest
    local trunk = block("Trunk", Vector3.new(3, 14, 3) * scale,
        Vector3.new(x, 7 * scale, z), C.trunk, Enum.Material.Wood, m)
    block("Crown", Vector3.new(15, 15, 15) * scale,
        Vector3.new(x, 18 * scale, z), C.leaf, Enum.Material.Grass, m, false, Enum.PartType.Ball)
    return trunk
end

-- Keep the main trail open and leave a wider clear pocket around the Whisper Core.
for _ = 1, 125 do
    local x = rng:NextNumber(-32, 338)
    local z = rng:NextNumber(-216, 216)
    local avoidTrail = math.abs(z) < 24 and x < 210
    local avoidCore = (Vector2.new(x - 210, z - 85)).Magnitude < 34
    local avoidPond = (Vector2.new(x - 160, z + 116)).Magnitude < 42
    if not avoidTrail and not avoidCore and not avoidPond then
        tree(x, z, rng:NextNumber(.7, 1.35))
    end
end

local core = block("WhisperCore", Vector3.new(22, 28, 22), Vector3.new(210, 14, 85),
    Color3.fromRGB(155, 75, 178), Enum.Material.Neon, forest, false, Enum.PartType.Ball)
label(core, "WHISPER CORE", 210)
local coreLight = Instance.new("PointLight")
coreLight.Color, coreLight.Range, coreLight.Brightness = Color3.fromRGB(187, 91, 229), 42, 2
coreLight.Parent = core

local pond = block("EchoPond", Vector3.new(70, .4, 60), Vector3.new(160, .35, -116),
    Color3.fromRGB(48, 177, 174), Enum.Material.Glass, forest, false)
pond.Transparency = .3
label(pond, "ECHO POND", 200)

local function resource(kind, x, z, i)
    local m = Instance.new("Model")
    m.Name = kind .. "_Forest_" .. i
    m:SetAttribute("ResourceType", kind)
    m:SetAttribute("RespawnSeconds", 15)
    m.Parent = resourceFolder
    local root
    if kind == "Wood" then
        root = block("Trunk", Vector3.new(3, 11, 3), Vector3.new(x, 5.5, z), C.trunk, Enum.Material.Wood, m)
        block("Canopy", Vector3.new(11, 10, 11), Vector3.new(x, 15, z), C.leaf,
            Enum.Material.Grass, m, false, Enum.PartType.Ball)
    elseif kind == "Stone" then
        root = block("Rock", Vector3.new(7, 5, 6), Vector3.new(x, 2.5, z), C.stone, Enum.Material.Slate, m)
    elseif kind == "Crystal" then
        root = block("Crystal", Vector3.new(4, 8, 4), Vector3.new(x, 4, z), C.crystal, Enum.Material.Neon, m)
    else
        root = block("FiberPlant", Vector3.new(4, 3, 4), Vector3.new(x, 1.5, z), C.flower,
            Enum.Material.Grass, m)
    end
    m.PrimaryPart = root
    CollectionService:AddTag(m, "AnmolResourceNode")
end

local resources = {
    {"Wood", 20, 62}, {"Wood", 65, -65}, {"Wood", 123, 61}, {"Wood", 288, 166},
    {"Stone", 44, -108}, {"Stone", 240, -46}, {"Stone", 300, 102},
    {"Crystal", 291, -157}, {"Crystal", 293, 48},
    {"Fiber", 116, -90}, {"Fiber", 82, 104}, {"Fiber", 207, -128},
}
for index, entry in ipairs(resources) do resource(entry[1], entry[2], entry[3], index) end

-- MonsterAI V1 reads BasePart markers from Workspace.MonsterSpawns.
local spawnFolder = Workspace:FindFirstChild("MonsterSpawns")
if not spawnFolder then
    spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "MonsterSpawns"
    spawnFolder.Parent = Workspace
end
for i, coords in ipairs({{275,-75}, {318,158}, {85,-172}, {315,-184}, {92,180}}) do
    local marker = block("AnmolForestSpawn_" .. i, Vector3.new(2, 1, 2),
        Vector3.new(coords[1], 1, coords[2]), Color3.fromRGB(230, 88, 104),
        Enum.Material.SmoothPlastic, spawnFolder, false)
    marker.Transparency = 1
    marker.CanQuery = false
end

-- Future zones are signposts only; real 3D biomes will be separate additions.
local function futureSign(name, x, z)
    local sign = block(name, Vector3.new(12, 7, 2), Vector3.new(x, 5, z),
        Color3.fromRGB(105, 84, 62), Enum.Material.WoodPlanks, future, false)
    label(sign, name .. " • COMING NEXT", 260)
end
futureSign("CRYSTAL DEPTHS", 305, 220)
futureSign("TOXIC MARSH", 250, -235)
futureSign("WORLD HEART", 0, 235)

Workspace:SetAttribute("AnmolIslandMapReady", true)
print("[Anmol Island] V1 ready: Heart Village + Whispering Forest + 12 resource nodes + 5 monster markers")
