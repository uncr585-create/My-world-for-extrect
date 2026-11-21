-- ANMOL: LIVING WORLD — Island Expansion V2
-- Add as Script in ServerScriptService alongside IslandMap.server.lua (V1).
-- Includes Crystal Depths, Toxic Marsh, and World Heart PLACEHOLDER arena.
-- Safe to rerun: skips if expansion already exists. Uses only Roblox native parts.
-- Coordinates are designed to connect to V1's 800 x 600 stud island base.

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local rng = Random.new(20261122)

-- Script load order in Roblox Studio isn't guaranteed.
local island = Workspace:WaitForChild("AnmolIslandV1", 90)
if not island then
    warn("[Anmol Expansion] V1 IslandMap missing; add/run IslandMap.server.lua first")
    return
end
if island:FindFirstChild("ExpansionV2") then
    warn("[Anmol Expansion] V2 already generated")
    return
end

local expansion = Instance.new("Folder")
expansion.Name = "ExpansionV2"
expansion.Parent = island

local C = {
    rock = Color3.fromRGB(68, 74, 94),
    slate = Color3.fromRGB(95, 105, 116),
    blue = Color3.fromRGB(64, 219, 245),
    purple = Color3.fromRGB(163, 100, 232),
    toxic = Color3.fromRGB(73, 110, 76),
    moss = Color3.fromRGB(54, 83, 62),
    acid = Color3.fromRGB(122, 218, 70),
    soil = Color3.fromRGB(121, 94, 77),
    root = Color3.fromRGB(93, 68, 76),
    heart = Color3.fromRGB(232, 71, 122),
}
local function part(name, size, position, color, material, parent, collision, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = collision ~= false
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end
local function light(p, color, range, brightness)
    local l = Instance.new("PointLight")
    l.Color, l.Range, l.Brightness = color, range, brightness
    l.Parent = p
end
local function label(p, title)
    local gui = Instance.new("BillboardGui")
    gui.Name = "AreaSign"
    gui.AlwaysOnTop = true
    gui.MaxDistance = 170
    gui.Size = UDim2.fromOffset(240, 42)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 7, 0)
    gui.Parent = p
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.Font = Enum.Font.GothamBold
    t.TextScaled = true
    t.TextStrokeTransparency = .6
    t.TextColor3 = Color3.fromRGB(231, 255, 239)
    t.BackgroundColor3 = Color3.fromRGB(15, 24, 32)
    t.BackgroundTransparency = .25
    t.Text = title
    t.Parent = gui
end
local function folder(name)
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = expansion
    return f
end
local crystals = folder("CrystalDepths")
local marsh = folder("ToxicMarsh")
local heart = folder("WorldHeart")
local resources = folder("ExpansionResources")

-- V1 central base extends X -400..400 and Z -300..300.
-- These new traversable plates overlap its boundary slightly.
-- Ground surface is roughly Y=0.5; platforms/paths are slightly higher.
part("CrystalPlate", Vector3.new(310, 20, 338), Vector3.new(222, -10.5, 442), C.rock, Enum.Material.Slate, crystals)
part("MarshPlate", Vector3.new(320, 20, 335), Vector3.new(215, -10.5, -442), C.toxic, Enum.Material.Grass, marsh)
part("HeartPlate", Vector3.new(280, 20, 310), Vector3.new(-115, -10.5, 450), C.moss, Enum.Material.Grass, heart)

-- Roads from forest to northern cave, southern marsh, and village to Heart.
part("ForestToCrystalTrail", Vector3.new(18, .45, 155), Vector3.new(305, 1, 293), C.slate, Enum.Material.Cobblestone, crystals)
part("ForestToMarshTrail", Vector3.new(20, .45, 155), Vector3.new(251, 1, -294), C.soil, Enum.Material.Ground, marsh)
part("VillageToHeartTrail", Vector3.new(20, .45, 160), Vector3.new(-140, 1, 294), C.soil, Enum.Material.Ground, heart)

-- The V1 future markers are only signposts and are harmless to leave in place.
local function resource(kind, x, z, index)
    local m = Instance.new("Model")
    m.Name = "V2_" .. kind .. "_" .. index
    m:SetAttribute("ResourceType", kind)
    m:SetAttribute("RespawnSeconds", 20)
    m.Parent = resources
    local root
    if kind == "Crystal" then
        root = part("Crystal", Vector3.new(5, 10, 5), Vector3.new(x, 5.5, z), C.blue, Enum.Material.Neon, m)
        light(root, C.blue, 22, 1.1)
    elseif kind == "Stone" then
        root = part("Rock", Vector3.new(9, 5, 8), Vector3.new(x, 3, z), C.slate, Enum.Material.Slate, m)
    elseif kind == "Fiber" then
        root = part("FiberPlant", Vector3.new(5, 4, 5), Vector3.new(x, 2.5, z), C.acid, Enum.Material.Grass, m, false)
    else
        root = part("Trunk", Vector3.new(4, 12, 4), Vector3.new(x, 6.5, z), C.root, Enum.Material.Wood, m)
        part("Crown", Vector3.new(15, 12, 15), Vector3.new(x, 17, z), C.moss, Enum.Material.Grass, m, false, Enum.PartType.Ball)
    end
    m.PrimaryPart = root
    CollectionService:AddTag(m, "AnmolResourceNode")
end

-- Crystal Depths (surface cave placeholder + glowing pillars; cave tunnels later).
local arch = part("CrystalGate", Vector3.new(30, 25, 6), Vector3.new(304, 13, 366), C.purple, Enum.Material.Slate, crystals)
label(arch, "CRYSTAL DEPTHS")
for i = 1, 18 do
    local x = rng:NextNumber(95, 340)
    local z = rng:NextNumber(385, 575)
    if math.abs(x - 305) > 18 or z > 420 then
        local h = rng:NextNumber(7, 22)
        local p = part("GlowingPillar", Vector3.new(5, h, 5), Vector3.new(x, h/2+.5, z), i%3==0 and C.purple or C.blue, Enum.Material.Neon, crystals)
        if i % 3 == 0 then light(p, C.purple, 18, .7) end
    end
end
for i, p in ipairs({{128,418},{181,538},{260,490},{330,555},{115,558}}) do
    resource("Crystal", p[1], p[2], i)
end
for i, p in ipairs({{155,458},{300,445},{200,577}}) do
    resource("Stone", p[1], p[2], i)
end

-- Toxic Marsh: solid walkable floor + non-damaging luminous puddles.
local marshSign = part("MarshGate", Vector3.new(28, 18, 6), Vector3.new(248, 10, -369), C.root, Enum.Material.Wood, marsh)
label(marshSign, "TOXIC MARSH")
for i = 1, 16 do
    local x = rng:NextNumber(83, 347)
    local z = rng:NextNumber(-595, -398)
    local puddle = part("ToxicPool_Decoration", Vector3.new(rng:NextNumber(8,17), .25, rng:NextNumber(8,17)), Vector3.new(x, .68, z), C.acid, Enum.Material.Neon, marsh, false)
    puddle.Transparency = .28
end
for i, p in ipairs({{115,-460},{179,-545},{323,-510},{266,-574},{347,-423}}) do
    resource("Fiber",p[1],p[2],i)
end
for i, p in ipairs({{128,-550},{235,-477},{319,-565}}) do
    resource("Wood",p[1],p[2],i)
end

-- World Heart: center point and visible boss arena, WITHOUT a live boss yet.
local arena = part("HeartArena", Vector3.new(124, 2, 124), Vector3.new(-116, 1.3, 485), C.root, Enum.Material.Slate, heart, true, Enum.PartType.Cylinder)
local core = part("LivingHeart", Vector3.new(24, 34, 24), Vector3.new(-116, 20, 485), C.heart, Enum.Material.Neon, heart, false, Enum.PartType.Ball)
light(core, C.heart, 65, 2.5)
label(core, "WORLD HEART • BOSS ARENA")
for i=1,10 do
    local a = (i / 10) * math.pi * 2
    local pos = Vector3.new(-116 + 80*math.cos(a), 11, 485 + 80*math.sin(a))
    part("HeartRootPillar", Vector3.new(8, 21, 8), pos, C.root, Enum.Material.Wood, heart)
end
local heartPrompt = Instance.new("ProximityPrompt")
heartPrompt.ActionText = "Inspect World Heart"
heartPrompt.ObjectText = "Living Heart"
heartPrompt.HoldDuration = 1
heartPrompt.MaxActivationDistance = 14
heartPrompt.Parent = core
heartPrompt.Triggered:Connect(function(player)
    -- Placeholder: server-authoritative boss event will be added later.
    print("[Anmol Heart] inspected by", player.Name)
end)

-- More monsters use existing AI V1's shared spawn folder; only 2 already supported types.
-- No unsupported third monster type is added here.
local spawns = Workspace:FindFirstChild("MonsterSpawns")
if not spawns then
    spawns = Instance.new("Folder")
    spawns.Name = "MonsterSpawns"
    spawns.Parent = Workspace
end
local function marker(name, x, z)
    if spawns:FindFirstChild(name) then return end
    local p = part(name, Vector3.new(2,1,2), Vector3.new(x,1.5,z), C.purple, Enum.Material.SmoothPlastic, spawns, false)
    p.Transparency = 1
    p.CanQuery = false
end
marker("AnmolCrystalSpawn_1", 190, 496)
marker("AnmolCrystalSpawn_2", 322, 528)
marker("AnmolMarshSpawn_1", 180, -495)
marker("AnmolMarshSpawn_2", 326, -525)

Workspace:SetAttribute("AnmolExpansionV2Ready", true)
print("[Anmol Island] Expansion V2 ready: Crystal Depths, Toxic Marsh, World Heart arena + 16 resource nodes")
