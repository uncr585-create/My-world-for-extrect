-- OPTIONAL testing-only resource props: install in ServerScriptService.
-- This script does nothing unless ENABLE_DEMO_NODES is set to true.
-- Do not use demo nodes for a production game map; replace with proper assets.
local ENABLE_DEMO_NODES = false
if not ENABLE_DEMO_NODES then return end
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local spawnPoint = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
local center = spawnPoint and spawnPoint.Position or Vector3.new(0, 5, 0)
local props = {
    {name="Wood", delta=Vector3.new(14,0,0), color=Color3.fromRGB(107,73,45)},
    {name="Stone", delta=Vector3.new(-14,0,0), color=Color3.fromRGB(132,140,153)},
    {name="Crystal", delta=Vector3.new(0,0,14), color=Color3.fromRGB(72,197,225)},
    {name="Fiber", delta=Vector3.new(0,0,-14), color=Color3.fromRGB(70,171,92)},
}
local folder = Instance.new("Folder")
folder.Name="AnmolDemoResources"
folder.Parent=Workspace
for _, entry in ipairs(props) do
    local part = Instance.new("Part")
    part.Name=entry.name .. "Resource"
    part.Size=Vector3.new(5,5,5)
    part.Anchored=true
    part.Material=Enum.Material.Neon
    part.Color=entry.color
    part.Position=center+entry.delta+Vector3.new(0,3,0)
    part:SetAttribute("ResourceType",entry.name)
    part:SetAttribute("RespawnSeconds",10)
    part.Parent=folder
    CollectionService:AddTag(part,"AnmolResourceNode")
end
