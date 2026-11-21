-- ANMOL: LIVING WORLD / Building + Shelter V1
-- ServerScriptService > Script (Building.server.lua)
-- Requires UPDATED saving-enabled InventoryCrafting.server.lua from this ZIP.
-- Validates build cost, player proximity, ground and collision on SERVER.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local COSTS = {
    Wall = {Wood = 4, Stone = 2},
    Floor = {Wood = 3},
    Campfire = {Wood = 2, Stone = 3},
    Shelter = {Wood = 8, Stone = 4},
}
local RANGE = 24
local MIN_RANGE = 5
local MAX_PER_PLAYER = 35
local COOLDOWN = 0.8
local lastPlace = {}
local count = {}
local placedPoints = {}

local remotes = RS:FindFirstChild("AnmolBuildingRemotes") or Instance.new("Folder")
remotes.Name = "AnmolBuildingRemotes"
remotes.Parent = RS
local request = remotes:FindFirstChild("Place") or Instance.new("RemoteFunction")
request.Name = "Place"
request.Parent = remotes
local builtFolder = Workspace:FindFirstChild("AnmolPlayerBuildings") or Instance.new("Folder")
builtFolder.Name = "AnmolPlayerBuildings"
builtFolder.Parent = Workspace

local function makePart(model, name, size, cf, color, material)
    local part = Instance.new("Part")
    part.Name, part.Size, part.CFrame = name, size, cf
    part.Anchored, part.CanCollide = true, true
    part.Material, part.Color = material, color
    part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    part.Parent = model
    return part
end

local function generate(piece, center, player)
    local model = Instance.new("Model")
    model.Name = piece .. "_" .. player.UserId
    model:SetAttribute("OwnerUserId", player.UserId)
    local wood = Color3.fromRGB(125, 84, 56)
    local stone = Color3.fromRGB(92, 95, 100)
    if piece == "Wall" then
        makePart(model, "Wall", Vector3.new(10, 9, 1), CFrame.new(center + Vector3.new(0, 4.5, 0)), wood, Enum.Material.WoodPlanks)
    elseif piece == "Floor" then
        makePart(model, "Floor", Vector3.new(10, 1, 10), CFrame.new(center + Vector3.new(0, 0.5, 0)), wood, Enum.Material.WoodPlanks)
    elseif piece == "Campfire" then
        makePart(model, "StoneRing", Vector3.new(5, 0.7, 5), CFrame.new(center + Vector3.new(0, .35, 0)), stone, Enum.Material.Cobblestone)
        local ember = makePart(model, "WarmEmber", Vector3.new(2, 1, 2), CFrame.new(center + Vector3.new(0, 1, 0)), Color3.fromRGB(255, 126, 44), Enum.Material.Neon)
        ember.CanCollide = false
        local flame = Instance.new("Fire")
        flame.Size, flame.Heat = 5, 6
        flame.Parent = ember
        local light = Instance.new("PointLight")
        light.Color, light.Range, light.Brightness = Color3.fromRGB(255, 160, 72), 18, 1.5
        light.Parent = ember
    elseif piece == "Shelter" then
        makePart(model, "Base", Vector3.new(12, .8, 12), CFrame.new(center + Vector3.new(0, .4, 0)), wood, Enum.Material.WoodPlanks)
        for _, x in ipairs({-5, 5}) do
            for _, z in ipairs({-5, 5}) do
                makePart(model, "Post", Vector3.new(.8, 7, .8), CFrame.new(center + Vector3.new(x, 4, z)), wood, Enum.Material.Wood)
            end
        end
        makePart(model, "Roof", Vector3.new(14, 1, 14), CFrame.new(center + Vector3.new(0, 8, 0)), wood, Enum.Material.WoodPlanks)
    end
    model.Parent = builtFolder
    return model
end

local groundNames = {
    IslandBase = true, VillageGround = true, ForestGround = true,
    CrystalPlate = true, MarshPlate = true, HeartPlate = true,
}
local function findGroundParts()
    local island = Workspace:FindFirstChild("AnmolIslandV1")
    if not island then return {} end
    local result = {}
    for _, d in ipairs(island:GetDescendants()) do
        if d:IsA("BasePart") and groundNames[d.Name] then
            table.insert(result, d)
        end
    end
    return result
end

request.OnServerInvoke = function(player, piece, desired)
    if type(piece) ~= "string" or not COSTS[piece] then return false, "Unknown building" end
    if typeof(desired) ~= "Vector3" or desired.X ~= desired.X or desired.Z ~= desired.Z then
        return false, "Invalid position"
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 or player:GetAttribute("AnmolLifeState") == "Eliminated" then
        return false, "You must be alive"
    end
    local now = os.clock()
    if now - (lastPlace[player] or 0) < COOLDOWN then return false, "Build cooldown" end
    if (count[player] or 0) >= MAX_PER_PLAYER then return false, "Build limit reached" end
    local flat = Vector3.new(desired.X, root.Position.Y, desired.Z)
    local horizontalDistance = (flat - root.Position).Magnitude
    if horizontalDistance < MIN_RANGE or horizontalDistance > RANGE then return false, "Build closer to your character" end
    local x = math.floor(desired.X / 5 + 0.5) * 5
    local z = math.floor(desired.Z / 5 + 0.5) * 5
    -- Preserve Heart Village as an unobstructed shared safe area.
    if x >= -305 and x <= -75 and z >= -135 and z <= 135 then
        return false, "Cannot build inside Heart Village"
    end
    local grounds = findGroundParts()
    if #grounds == 0 then return false, "Load IslandMap first" end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Include
    rayParams.FilterDescendantsInstances = grounds
    local hit = Workspace:Raycast(Vector3.new(x, 150, z), Vector3.new(0, -300, 0), rayParams)
    if not hit or hit.Normal.Y < 0.95 then return false, "Build only on flat island ground" end
    local center = Vector3.new(x, hit.Position.Y, z)
    if math.abs(center.Y - root.Position.Y) > 14 then return false, "Different elevation" end
    for _, point in ipairs(placedPoints) do
        if (Vector3.new(point.X, 0, point.Z) - Vector3.new(x, 0, z)).Magnitude < 13 then
            return false, "Too close to another building"
        end
    end
    local spend = SS:FindFirstChild("AnmolSpendResources")
    if not spend or not spend:IsA("BindableFunction") then return false, "Inventory bridge missing" end
    -- Spend bridge is synchronous, server-only, and deducts materials atomically.
    local called, approved, reason = pcall(function() return spend:Invoke(player, COSTS[piece]) end)
    if not called then return false, "Inventory error" end
    if not approved then return false, reason or "Missing resources" end
    lastPlace[player] = now
    local model = generate(piece, center, player)
    table.insert(placedPoints, center)
    count[player] = (count[player] or 0) + 1
    return true, piece .. " placed!"
end

Players.PlayerRemoving:Connect(function(player)
    lastPlace[player] = nil
    count[player] = nil
end)
print("[Anmol] Building + Shelter V1 ready")
