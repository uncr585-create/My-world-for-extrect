-- ANMOL: LIVING WORLD — Achievements Notification V1
-- StarterPlayer > StarterPlayerScripts (LocalScript)
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local remote=RS:WaitForChild("AnmolAchievements"):WaitForChild("Unlock")
local gui=Instance.new("ScreenGui")
gui.Name="AnmolAchievementHUD";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local label=Instance.new("TextLabel")
label.Name="AchievementToast";label.AnchorPoint=Vector2.new(0.5,0)
label.Position=UDim2.new(0.5,0,0,-100);label.Size=UDim2.new(0.82,0,0,68)
label.BackgroundColor3=Color3.fromRGB(19,36,31)
label.BackgroundTransparency=0.1;label.TextColor3=Color3.fromRGB(247,232,155)
label.Font=Enum.Font.GothamBold;label.TextScaled=true;label.TextWrapped=true
label.Parent=gui
local limit=Instance.new("UISizeConstraint")
limit.MaxSize=Vector2.new(430,68);limit.Parent=label
Instance.new("UICorner",label).CornerRadius=UDim.new(0,12)
local queue={};local running=false
local function process()
 if running then return end
 running=true
 while #queue>0 do
  local msg=table.remove(queue,1)
  label.Text=msg
  TweenService:Create(label,TweenInfo.new(.35),{Position=UDim2.new(.5,0,0,18)}):Play()
  task.wait(3.5)
  local t=TweenService:Create(label,TweenInfo.new(.3),{Position=UDim2.new(.5,0,0,-100)})
  t:Play();t.Completed:Wait()
 end
 running=false
end
remote.OnClientEvent:Connect(function(id,title,target)
 if type(title)~="string" or type(target)~="number" then return end
 table.insert(queue,"🏆 ACHIEVEMENT UNLOCKED!\nTitle: "..title)
 task.spawn(process)
end)
