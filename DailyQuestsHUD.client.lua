-- ANMOL: LIVING WORLD — Daily Quests HUD V1
-- LocalScript in StarterPlayer > StarterPlayerScripts.
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local folder=RS:WaitForChild("AnmolQuests")
local Update=folder:WaitForChild("Update")
local Claim=folder:WaitForChild("Claim")
local gui=Instance.new("ScreenGui")
gui.Name="AnmolDailyQuests";gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local open=Instance.new("TextButton")
open.Name="QuestsButton";open.Text="📜 Quests";open.Size=UDim2.fromOffset(110,39)
open.Position=UDim2.new(1,-122,0,110);open.BackgroundColor3=Color3.fromRGB(36,74,64)
open.TextColor3=Color3.new(1,1,1);open.Font=Enum.Font.GothamBold;open.TextSize=15
open.Parent=gui
Instance.new("UICorner",open).CornerRadius=UDim.new(0,9)
local panel=Instance.new("Frame")
panel.Name="QuestPanel";panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.52)
panel.Size=UDim2.new(.9,0,.6,0)
panel.BackgroundColor3=Color3.fromRGB(18,34,34);panel.Visible=false;panel.Parent=gui
local constraint=Instance.new("UISizeConstraint")
constraint.MaxSize=Vector2.new(410,390);constraint.MinSize=Vector2.new(260,260)
constraint.Parent=panel
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,13)
local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=panel
local pad=Instance.new("UIPadding")
pad.PaddingTop=UDim.new(0,14);pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12)
pad.Parent=panel
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,34);title.BackgroundTransparency=1;title.Text="📜 DAILY QUESTS"
title.TextColor3=Color3.new(1,1,1);title.Font=Enum.Font.GothamBold;title.TextSize=20
title.LayoutOrder=0;title.Parent=panel
local latest={}
local function redraw(day,list)
    latest=list
    for _,v in ipairs(panel:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for index,d in ipairs(list) do
        local b=Instance.new("TextButton")
        b.Name=d.id;b.LayoutOrder=index
        b.Size=UDim2.new(1,0,0,56)
        b.BackgroundColor3=d.claimed and Color3.fromRGB(43,68,56) or Color3.fromRGB(45,57,64)
        b.TextColor3=Color3.new(1,1,1)
        b.Font=Enum.Font.GothamMedium;b.TextSize=14;b.TextWrapped=true
        local ready=d.progress>=d.goal and not d.claimed
        b.Text=d.title.."  ("..d.progress.."/"..d.goal..")\n"..(d.claimed and "✅ Claimed" or (ready and "🎁 CLAIM +"..d.reward.." Coins" or "+"..d.reward.." Coins"))
        b.Parent=panel
        b.Activated:Connect(function() if ready then Claim:FireServer(d.id) end end)
    end
end
open.Activated:Connect(function() panel.Visible=not panel.Visible end)
Update.OnClientEvent:Connect(redraw)
