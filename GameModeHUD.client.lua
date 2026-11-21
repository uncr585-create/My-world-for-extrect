-- ANMOL: LIVING WORLD — Mode status display V1
-- StarterPlayer > StarterPlayerScripts > LocalScript
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "AnmolModeStatusHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Name = "ModeStatus"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.04)
label.Size = UDim2.new(0.83, 0, 0, 44)
label.BackgroundColor3 = Color3.fromRGB(15, 31, 29)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.fromRGB(241, 255, 241)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Visible = false
label.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = label
local cap = Instance.new("UISizeConstraint")
cap.MaxSize = Vector2.new(440, 44)
cap.Parent = label

local function update()
    local state = player:GetAttribute("AnmolLifeState")
    local mode = player:GetAttribute("AnmolGameMode")
    if state == "Downed" then
        label.Visible = true
        label.Text = "DOWNED — Teammate must revive you!"
        label.BackgroundColor3 = Color3.fromRGB(122, 68, 29)
    elseif state == "Eliminated" then
        label.Visible = true
        label.Text = "HARDCORE — Run over. Rejoin for a new session."
        label.BackgroundColor3 = Color3.fromRGB(112, 35, 40)
    elseif state == "Alive" then
        label.Visible = true
        label.Text = "ANMOL LIVING WORLD  •  " .. tostring(mode):upper()
        label.BackgroundColor3 = Color3.fromRGB(15, 54, 39)
    else
        label.Visible = false
    end
end
player:GetAttributeChangedSignal("AnmolLifeState"):Connect(update)
player:GetAttributeChangedSignal("AnmolGameMode"):Connect(update)
update()
