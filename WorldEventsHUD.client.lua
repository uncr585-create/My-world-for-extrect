-- WorldEventsHUD.client.lua | StarterPlayerScripts
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local remote=RS:WaitForChild("AnmolWorldEvent")
local gui=Instance.new("ScreenGui")
gui.Name="AnmolWorldEventsHUD"
gui.ResetOnSpawn=false
gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
local text=Instance.new("TextLabel")
text.AnchorPoint=Vector2.new(.5,0)
text.Position=UDim2.fromScale(.5,.08)
text.Size=UDim2.new(.8,0,0,68)
text.BackgroundColor3=Color3.fromRGB(25,27,40)
text.BackgroundTransparency=.14
text.TextColor3=Color3.fromRGB(255,239,190)
text.TextScaled=true
text.TextWrapped=true
text.Font=Enum.Font.GothamBold
text.Visible=false
text.Parent=gui
Instance.new("UICorner",text).CornerRadius=UDim.new(0,12)
local generation=0
remote.OnClientEvent:Connect(function(name,duration,detail)
    generation+=1
    local mine=generation
    text.Text=(name=="Ended" and "✓ " or "⚠ ")..tostring(name).."\n"..tostring(detail)
    text.Visible=true
    if name=="Earthquake" then
        -- Small client-only shake, no server physics changes.
        task.spawn(function()
            local camera=workspace.CurrentCamera
            local untilTime=os.clock()+math.min(duration,8)
            while mine==generation and os.clock()<untilTime do
                if camera then camera.CFrame*=CFrame.new(math.random(-3,3)*.025,math.random(-3,3)*.025,0) end
                task.wait(.09)
            end
        end)
    end
    task.delay(name=="Ended" and 3 or math.min(duration,25),function()
        if mine==generation then text.Visible=false end
    end)
end)
