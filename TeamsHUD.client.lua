-- ANMOL: LIVING WORLD — Team HUD V1
-- StarterPlayer > StarterPlayerScripts > TeamsHUD (LocalScript)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local remote = RS:WaitForChild("AnmolTeamsRemote")

local gui = Instance.new("ScreenGui")
gui.Name = "AnmolTeamsHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")
local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(115, 43)
open.Position = UDim2.new(0, 12, 0, 110)
open.Text = "👥 TEAM"
open.BackgroundColor3 = Color3.fromRGB(26, 61, 56)
open.TextColor3 = Color3.new(1,1,1)
open.Font = Enum.Font.GothamBold
open.TextSize = 17
open.Parent = gui
Instance.new("UICorner", open).CornerRadius = UDim.new(0, 10)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.87, 0, 0.72, 0)
panel.BackgroundColor3 = Color3.fromRGB(16, 34, 35)
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local constrain = Instance.new("UISizeConstraint")
constrain.MaxSize = Vector2.new(440, 440)
constrain.MinSize = Vector2.new(245, 250)
constrain.Parent = panel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -55, 0, 40)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "ANMOL • Team (0/8)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(37, 32)
close.Position = UDim2.new(1, -44, 0, 5)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(92, 43, 43)
close.Parent = panel
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(10, 44)
list.Size = UDim2.new(1, -20, 1, -100)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 5
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0,0,0,0)
list.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list
local leave = Instance.new("TextButton")
leave.Position = UDim2.new(0, 10, 1, -48)
leave.Size = UDim2.new(1, -20, 0, 38)
leave.BackgroundColor3 = Color3.fromRGB(78, 52, 52)
leave.TextColor3 = Color3.new(1,1,1)
leave.Text = "Leave Team"
leave.Parent = panel
Instance.new("UICorner", leave).CornerRadius = UDim.new(0, 8)
local toast = Instance.new("TextLabel")
toast.Size = UDim2.new(0.86,0,0,36)
toast.AnchorPoint = Vector2.new(0.5,0)
toast.Position = UDim2.new(0.5,0,0,8)
toast.TextColor3 = Color3.new(1,1,1)
toast.BackgroundColor3 = Color3.fromRGB(34, 49, 53)
toast.TextScaled = true
toast.Visible = false
toast.Parent = gui
Instance.new("UICorner", toast).CornerRadius = UDim.new(0,8)
local invitation = Instance.new("Frame")
invitation.AnchorPoint = Vector2.new(0.5, 1)
invitation.Position = UDim2.new(0.5,0,1,-18)
invitation.Size = UDim2.new(0.88,0,0,104)
invitation.BackgroundColor3 = Color3.fromRGB(43,56,45)
invitation.Visible = false
invitation.Parent = gui
Instance.new("UISizeConstraint", invitation).MaxSize = Vector2.new(390, 104)
Instance.new("UICorner", invitation).CornerRadius = UDim.new(0, 10)
local prompt = Instance.new("TextLabel")
prompt.Size = UDim2.new(1,-12,0,48)
prompt.Position = UDim2.fromOffset(6,1)
prompt.BackgroundTransparency = 1
prompt.TextWrapped = true
prompt.TextColor3 = Color3.new(1,1,1)
prompt.TextSize = 15
prompt.Font = Enum.Font.GothamBold
prompt.Parent = invitation
local function optionButton(txt, x, action)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.46,0,0,37)
    b.Position = UDim2.new(x,0,0,56)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(44,86,75)
    b.Parent = invitation
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.Activated:Connect(function()
        invitation.Visible = false
        remote:FireServer(action)
    end)
end
optionButton("Accept", 0.03, "Accept")
optionButton("Decline", 0.51, "Decline")

local snapshot
local function makeRow(label, buttonText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-6,0,38)
    row.BackgroundColor3 = Color3.fromRGB(31,51,51)
    row.Parent = list
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(buttonText and 0.69 or 1,-10,1,0)
    lbl.Position = UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Parent = row
    if buttonText then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.3,-8,0,30)
        btn.Position = UDim2.new(0.70,0,0,4)
        btn.BackgroundColor3 = Color3.fromRGB(58,104,78)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Text = buttonText
        btn.Parent = row
        btn.Activated:Connect(callback)
    end
end
local function redraw()
    for _, item in ipairs(list:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    local inTeam = snapshot ~= nil
    local myLeader = false
    local teammateIds = {}
    if inTeam then
        title.Text = string.format("ANMOL • Team (%d/8)",snapshot.size)
        for _, member in ipairs(snapshot.members) do
            teammateIds[member.userId] = true
            if member.userId == localPlayer.UserId then myLeader = member.leader end
            makeRow((member.leader and "👑 " or "👤 ") .. member.name .. " (@" .. member.username .. ")")
        end
    else
        title.Text = "ANMOL • No team"
    end
    leave.Visible = inTeam
    if not inTeam or myLeader then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and not teammateIds[p.UserId] then
                local targetId = p.UserId
                makeRow("+ " .. p.DisplayName .. " (@" .. p.Name .. ")", "Invite", function()
                    remote:FireServer("Invite",targetId)
                end)
            end
        end
    end
end
remote.OnClientEvent:Connect(function(kind, data)
    if kind == "Sync" then snapshot = data; redraw() end
    if kind == "InviteReceived" and typeof(data) == "table" then
        prompt.Text = tostring(data.name or "Someone") .. " invited you to their team (30s)."
        invitation.Visible = true
        local senderId = data.senderId
        task.delay(30, function()
            if invitation.Visible and senderId == data.senderId then invitation.Visible = false end
        end)
    end
    if kind == "Info" then
        toast.Text = tostring(data)
        toast.Visible = true
        local message = toast.Text
        task.delay(3.5, function()
            if toast.Text == message then toast.Visible = false end
        end)
    end
end)
open.Activated:Connect(function() panel.Visible = not panel.Visible; if panel.Visible then redraw() end end)
close.Activated:Connect(function() panel.Visible = false end)
leave.Activated:Connect(function() remote:FireServer("Leave") end)
Players.PlayerAdded:Connect(redraw)
Players.PlayerRemoving:Connect(redraw)
remote:FireServer("RequestSync")
