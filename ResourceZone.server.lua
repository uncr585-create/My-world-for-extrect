-- ANMOL: LIVING WORLD - Resource Zone V1
-- Put this Script in ServerScriptService. Designed for first Studio test.
-- Makes simple placeholder trees, rocks, crystals, and fiber plants around a spawn.
-- Existing InventoryCrafting.server.lua (replacement included) handles pickup/respawn.
-- Replace generated nodes with polished models as the island is built.
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local existing = Workspace:FindFirstChild("AnmolResourceZoneV1")
if existing then
    warn("[Anmol] Resource Zone already exists; avoiding duplicate props")
    return
end
local folder = Instance.new("Folder")
folder.Name = "AnmolResourceZoneV1"
folder.Parent = Workspace
local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
local center = spawn and spawn.Position or Vector3.new(0, 4, 0)

local function part(name, size, cf, color, parent, material, collision)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.CanCollide = collision ~= false
    p.Parent = parent
    return p
end

local function makeNode(kind, index, offset)
    local model = Instance.new("Model")
    model.Name = kind .. "_" .. index
    model:SetAttribute("ResourceType", kind)
    model:SetAttribute("RespawnSeconds", 15)
    model.Parent = folder
    local pos = center + offset
    local base
    if kind == "Wood" then
        base = part("Trunk", Vector3.new(3, 10, 3), CFrame.new(pos + Vector3.new(0, 5, 0)), Color3.fromRGB(105, 74, 52), model)
        part("Canopy", Vector3.new(10, 8, 10), CFrame.new(pos + Vector3.new(0, 11, 0)), Color3.fromRGB(55, 126, 77), model, Enum.Material.Grass, false)
    elseif kind == "Stone" then
        base = part("Rock", Vector3.new(7, 5, 6), CFrame.new(pos + Vector3.new(0, 2.5, 0)), Color3.fromRGB(112, 121, 131), model, Enum.Material.Slate)
    elseif kind == "Crystal" then
        base = part("Crystal", Vector3.new(4, 7, 4), CFrame.new(pos + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, math.rad(12)), Color3.fromRGB(78, 220, 240), model, Enum.Material.Neon)
    else
        base = part("FiberPlant", Vector3.new(4, 3, 4), CFrame.new(pos + Vector3.new(0, 1.5, 0)), Color3.fromRGB(69, 180, 95), model, Enum.Material.Grass)
    end
    model.PrimaryPart = base
    CollectionService:AddTag(model, "AnmolResourceNode")
end

local definitions = {
    {kind="Wood", offsets={Vector3.new(18,0,15), Vector3.new(-28,0,24), Vector3.new(30,0,-26)}},
    {kind="Stone", offsets={Vector3.new(-18,0,12), Vector3.new(25,0,30), Vector3.new(-32,0,-24)}},
    {kind="Crystal", offsets={Vector3.new(36,0,4), Vector3.new(-36,0,2)}},
    {kind="Fiber", offsets={Vector3.new(10,0,-18), Vector3.new(-12,0,-27), Vector3.new(3,0,29)}},
}
for _, def in ipairs(definitions) do
    for index, offset in ipairs(def.offsets) do
        makeNode(def.kind, index, offset)
    end
end
print("[Anmol] Resource Zone V1 spawned 11 harvest nodes")
