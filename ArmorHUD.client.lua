-- StarterPlayer > StarterPlayerScripts > ArmorHUD.client.lua (LocalScript)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local folder = RS:WaitForChild("AnmolArmorRemotes")
local equip = folder:WaitForChild("EquipArmor")
local status = folder:WaitForChild("ArmorStatus")
local gui = Instance.new("ScreenGui")
gui.Name = "AnmolArmorHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local open = Instance.new("TextButton")
open.Name = "ArmorButton"
open.Size = UDim2.fromOffset(135, 40)
open.Position = UDim2.new(0, 12, 0, 195)
open.Text = "🛡️ ARMOR"
open.Font = Enum.Font.GothamBold
open.TextSize = 16
open.TextColor3 = Color3.new(1,1,1)
open.BackgroundColor3 = Color3.fromRGB(37, 78, 72)
open.Parent = gui
Instance.new("UICorner", open).CornerRadius = UDim.new(0, 10)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 235)
frame.Position = UDim2.new(0, 12, 0, 242)
frame.BackgroundColor3 = Color3.fromRGB(16, 29, 30)
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 7)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent = frame
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 10)
pad.Parent = frame
local function label(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(205, 30)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.Text = text
    l.Parent = frame
    return l
end
local info = label("Equipped: None (0%)")
for _, data in ipairs({{"None","Unequip"},{"LeafVest","Leaf Vest (10%)"},{"StoneArmor","Stone Armor (20%)"},{"CrystalArmor","Crystal Armor (35%)"}}) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(205, 34)
    b.BackgroundColor3 = Color3.fromRGB(45, 105, 83)
    b.Text = data[2]
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Activated:Connect(function() equip:FireServer(data[1]) end)
end
open.Activated:Connect(function() frame.Visible = not frame.Visible end)
status.OnClientEvent:Connect(function(name, percent, message)
    info.Text = message or ("Equipped: " .. name .. " (" .. tostring(percent) .. "%)")
    open.Text = "🛡️ " .. tostring(percent) .. "% ARMOR"
end)
