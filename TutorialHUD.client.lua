-- ANMOL Living World - guided tutorial HUD
-- Place in StarterPlayer > StarterPlayerScripts as LocalScript
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild('AnmolTutorialRemote')
local steps = {
    {'Welcome to ANMOL: LIVING WORLD', 'Explore the island, survive, and discover the World Heart.'},
    {'Stay Alive', 'Watch your Health, Hunger, and Stamina. Avoid danger when low.'},
    {'Gather Resources', 'Collect Wood, Stone, Fiber, and Crystals from the world.'},
    {'Craft and Equip', 'Open Inventory to craft tools, weapons, armor, and supplies.'},
    {'Fight Carefully', 'Watch monster behavior. Fight with teammates when possible.'},
    {'World Anger', 'The island reacts to your actions. World Anger can make survival harder.'}
}
local gui = Instance.new('ScreenGui')
gui.Name = 'AnmolTutorialHUD'
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild('PlayerGui')
local frame = Instance.new('Frame')
frame.AnchorPoint = Vector2.new(.5,.5)
frame.Position = UDim2.fromScale(.5,.5)
frame.Size = UDim2.new(.88,0,0,250)
frame.BackgroundColor3 = Color3.fromRGB(21,29,36)
frame.Parent = gui
Instance.new('UICorner',frame).CornerRadius = UDim.new(0,14)
local title = Instance.new('TextLabel')
title.BackgroundTransparency=1
title.Size=UDim2.new(1,-24,0,62)
title.Position=UDim2.fromOffset(12,14)
title.TextColor3=Color3.fromRGB(241,223,156)
title.TextScaled=true
title.TextWrapped=true
title.Font=Enum.Font.GothamBold
title.Parent=frame
local body = Instance.new('TextLabel')
body.BackgroundTransparency=1
body.Position=UDim2.fromOffset(14,82)
body.Size=UDim2.new(1,-28,0,90)
body.TextColor3=Color3.new(1,1,1)
body.TextScaled=true
body.TextWrapped=true
body.Font=Enum.Font.Gotham
body.Parent=frame
local button = Instance.new('TextButton')
button.Position=UDim2.new(.1,0,1,-60)
button.Size=UDim2.new(.8,0,0,44)
button.BackgroundColor3=Color3.fromRGB(64,140,110)
button.TextColor3=Color3.new(1,1,1)
button.TextScaled=true
button.Font=Enum.Font.GothamBold
button.Parent=frame
Instance.new('UICorner',button).CornerRadius=UDim.new(0,10)
local current = 0
local function render()
    if current >= #steps then
        frame.Visible=false
        return
    end
    frame.Visible=true
    local step=steps[current+1]
    title.Text=string.format('%s (%d/%d)',step[1],current+1,#steps)
    body.Text=step[2]
    button.Text=current==#steps-1 and 'Finish Tutorial' or 'Next'
end
button.Activated:Connect(function()
    if current < #steps then remote:FireServer('Advance',current+1) end
end)
remote.OnClientEvent:Connect(function(action, value)
    if action=='Sync' and type(value)=='number' then
        current=math.clamp(math.floor(value),0,#steps)
        render()
    end
end)
frame.Visible=false
