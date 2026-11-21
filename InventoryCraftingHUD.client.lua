-- ANMOL: LIVING WORLD / Inventory + Crafting V1 UI
-- Install as LocalScript in StarterPlayer > StarterPlayerScripts.
-- Touch-friendly buttons; UI only requests recipes, server validates materials.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remoteFolder = ReplicatedStorage:WaitForChild("AnmolInventoryRemotes")
local Snapshot = remoteFolder:WaitForChild("Snapshot")
local CraftRequest = remoteFolder:WaitForChild("CraftRequest")
local GetInventory = remoteFolder:WaitForChild("GetInventory")

local RECIPES = {
    {name="StoneAxe", label="Stone Axe", need="3 Wood + 2 Stone"},
    {name="Sword", label="Sword", need="2 Wood + 5 Stone + 1 Crystal"},
    {name="Torch", label="Torch", need="2 Wood + 1 Fiber"},
    {name="Bandage", label="Bandage", need="3 Fiber"},
    {name="NoiseDecoy", label="Noise Decoy", need="2 Stone + 1 Crystal"},
    {name="AntlerCharm", label="Antler Charm", need="1 Hollow Antler + 3 Fiber"},
    {name="CrystalBlade", label="Crystal Blade", need="2 Crystal Shards + 3 Stone + 1 Crystal"},
}
local ITEM_ORDER = {"Wood", "Stone", "Crystal", "Fiber", "HollowAntler", "CrystalShard", "StoneAxe", "Sword", "Torch", "Bandage", "NoiseDecoy", "AntlerCharm", "CrystalBlade"}

local gui = Instance.new("ScreenGui")
gui.Name = "AnmolInventoryHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function rounded(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end
local function text(parent, label, size, bold)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = label
    t.TextColor3 = Color3.fromRGB(235, 246, 236)
    t.TextSize = size
    t.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    t.TextWrapped = true
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = parent
    return t
end
local function button(parent, label, size)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Text = label
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(49, 101, 73)
    b.Parent = parent
    rounded(b, 10)
    return b
end

local toggle = button(gui, "🎒 INVENTORY", UDim2.fromOffset(146, 45))
toggle.Position = UDim2.new(1, -158, 0, 66)
local panel = Instance.new("Frame")
panel.Name = "InventoryPanel"
panel.Size = UDim2.new(0.87, 0, 0.76, 0)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(16, 30, 28)
panel.BackgroundTransparency = 0.04
panel.Visible = false
panel.Parent = gui
rounded(panel, 16)
local constraints = Instance.new("UISizeConstraint")
constraints.MaxSize = Vector2.new(470, 560)
constraints.MinSize = Vector2.new(250, 230)
constraints.Parent = panel
local top = text(panel, "ANMOL • INVENTORY & CRAFTING", 17, true)
top.Size = UDim2.new(1,-65,0,36)
top.Position = UDim2.fromOffset(15, 6)
local close = button(panel,"✕",UDim2.fromOffset(40,34))
close.Position = UDim2.new(1,-49,0,8)
local scroller = Instance.new("ScrollingFrame")
scroller.Size = UDim2.new(1,-24,1,-100)
scroller.Position = UDim2.fromOffset(12,48)
scroller.BackgroundTransparency = 1
scroller.ScrollBarThickness = 5
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.CanvasSize = UDim2.new()
scroller.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroller
local itemLabel = text(scroller,"Loading items...",14,false)
itemLabel.Size = UDim2.new(1,-7,0,84)
itemLabel.LayoutOrder = 1
local craftingLabel = text(scroller,"CRAFT RECIPES",16,true)
craftingLabel.Size = UDim2.new(1,-7,0,26)
craftingLabel.LayoutOrder = 2
for i, recipe in ipairs(RECIPES) do
    local craft = button(scroller, recipe.label .. "  |  " .. recipe.need, UDim2.new(1,-9,0,47))
    craft.TextSize = 13
    craft.LayoutOrder = i + 2
    craft.Activated:Connect(function() CraftRequest:FireServer(recipe.name) end)
end
local status = text(panel,"Collect resources from world nodes to start crafting.",12,false)
status.Position = UDim2.new(0,12,1,-45)
status.Size = UDim2.new(1,-24,0,38)
status.TextColor3 = Color3.fromRGB(170,215,184)

local function render(inv, message)
    if type(inv) ~= "table" then return end
    local lines = {}
    local total = 0
    for _, name in ipairs(ITEM_ORDER) do
        local count = tonumber(inv[name]) or 0
        total += count
        table.insert(lines, name .. ": " .. count)
    end
    itemLabel.Text = "BACKPACK (" .. total .. "/100 items)\n" .. table.concat(lines, "  •  ")
    if type(message)=="string" and message~="" then status.Text = message end
end
Snapshot.OnClientEvent:Connect(render)
toggle.Activated:Connect(function() panel.Visible = not panel.Visible end)
close.Activated:Connect(function() panel.Visible = false end)
local ok, inv = pcall(function() return GetInventory:InvokeServer() end)
if ok then render(inv, "Choose a recipe to craft.") else status.Text = "Could not load backpack yet." end
