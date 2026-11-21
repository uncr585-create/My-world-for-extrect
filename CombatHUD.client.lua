-- ANMOL: LIVING WORLD / Combat UI V1
-- StarterPlayer > StarterPlayerScripts > CombatHUD.client.lua (LocalScript)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remotes = RS:WaitForChild("AnmolCombatRemotes")
local attack = remotes:WaitForChild("AttackRequest")
local feedback = remotes:WaitForChild("AttackFeedback")

local currentWeapon = "Fists"
local gui = Instance.new("ScreenGui")
gui.Name = "AnmolCombatHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local function makeButton(text, size, pos)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(39, 63, 60)
    b.TextColor3 = Color3.fromRGB(245, 250, 245)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = b
    return b
end
local attackButton = makeButton("⚔ ATTACK", UDim2.fromOffset(116, 54), UDim2.new(1, -128, 1, -145))
local weaponButton = makeButton("Fists ▾", UDim2.fromOffset(116, 38), UDim2.new(1, -128, 1, -191))
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 235, 156)
status.TextStrokeTransparency = 0.6
status.TextSize = 14
status.Font = Enum.Font.GothamBold
status.Text = ""
status.Size = UDim2.fromOffset(170, 25)
status.Position = UDim2.new(1, -180, 1, -225)
status.Parent = gui
local choices = {"Fists", "StoneAxe", "Sword", "CrystalBlade"}
weaponButton.Activated:Connect(function()
    for i, name in ipairs(choices) do
        if name == currentWeapon then
            currentWeapon = choices[i % #choices + 1]
            break
        end
    end
    weaponButton.Text = currentWeapon .. " ▾"
end)
local function swing() attack:FireServer(currentWeapon) end
attackButton.Activated:Connect(swing)
UIS.InputBegan:Connect(function(input, handled)
    if handled then return end
    if input.KeyCode == Enum.KeyCode.F then swing() end
end)
feedback.OnClientEvent:Connect(function(message)
    if type(message) == "string" then status.Text = message:sub(1, 70) end
end)
