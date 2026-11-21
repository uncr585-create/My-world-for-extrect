-- ANMOL: LIVING WORLD / Mobile Building Controls V1
-- StarterPlayer > StarterPlayerScripts > LocalScript
-- Rotate your character to aim; Place Ahead builds 12 studs in front.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local place = RS:WaitForChild("AnmolBuildingRemotes"):WaitForChild("Place")

local gui = Instance.new("ScreenGui")
gui.Name = "AnmolBuildingHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local holder = Instance.new("Frame")
holder.AnchorPoint = Vector2.new(1, 0.5)
holder.Position = UDim2.new(1, -10, .53, 0)
holder.Size = UDim2.fromOffset(155, 250)
holder.BackgroundColor3 = Color3.fromRGB(14, 31, 26)
holder.BackgroundTransparency = .15
holder.Parent = gui
Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 12)
local pad = Instance.new("UIPadding", holder)
pad.PaddingTop = UDim.new(0, 9)
pad.PaddingBottom = UDim.new(0, 9)
pad.PaddingLeft = UDim.new(0, 7)
pad.PaddingRight = UDim.new(0, 7)
local list = Instance.new("UIListLayout", holder)
list.Padding = UDim.new(0, 5)
list.SortOrder = Enum.SortOrder.LayoutOrder

local selected = "Wall"
local function button(label, order)
    local b = Instance.new("TextButton")
    b.LayoutOrder = order
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(38, 70, 57)
    b.TextColor3 = Color3.fromRGB(241, 255, 237)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.Text = label
    b.Parent = holder
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end
local selectorButtons = {}
for index, piece in ipairs({"Wall", "Floor", "Campfire", "Shelter"}) do
    local b = button(piece, index)
    selectorButtons[piece] = b
    b.Activated:Connect(function() selected = piece end)
end
local placeButton = button("PLACE AHEAD", 5)
placeButton.BackgroundColor3 = Color3.fromRGB(51, 153, 105)
local status = Instance.new("TextLabel")
status.LayoutOrder = 6
status.Size = UDim2.new(1, 0, 0, 30)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(231, 249, 233)
status.TextSize = 12
status.Text = "Choose a piece"
status.Parent = holder
local busy = false
placeButton.Activated:Connect(function()
    if busy then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then status.Text = "Spawn first"; return end
    busy = true
    local point = root.Position + root.CFrame.LookVector * 12
    local ok, allowed, message = pcall(function() return place:InvokeServer(selected, point) end)
    status.Text = ok and tostring(message) or "Server not ready"
    busy = false
end)
