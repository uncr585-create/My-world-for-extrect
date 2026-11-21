-- RandomWorldEvents.server.lua | ServerScriptService
-- ANMOL: LIVING WORLD - prototype random world events.
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local rng = Random.new()
local remote = RS:FindFirstChild("AnmolWorldEvent") or Instance.new("RemoteEvent")
remote.Name = "AnmolWorldEvent"
remote.Parent = RS
local world = RS:FindFirstChild("AnmolWorldState")
local anger = world and world:FindFirstChild("Anger")
local active = false

local function message(name, seconds, detail)
    remote:FireAllClients(name, seconds, detail)
end
local function roots(duration)
    message("Living Roots",duration,"Watch your feet! Roots are rising.")
    local folder=Instance.new("Folder")
    folder.Name="TemporaryLivingRoots"
    folder.Parent=workspace
    for i=1,12 do
        local chars={}
        for _,plr in ipairs(Players:GetPlayers()) do
            local root=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if root then table.insert(chars,root) end
        end
        if #chars>0 then
            local anchor=chars[rng:NextInteger(1,#chars)]
            local part=Instance.new("Part")
            part.Name="WarningRoot"
            part.Anchored=true
            part.CanCollide=false
            part.Material=Enum.Material.Neon
            part.Color=Color3.fromRGB(153,65,77)
            part.Size=Vector3.new(5,0.35,5)
            part.Position=anchor.Position+Vector3.new(rng:NextInteger(-22,22),-2.5,rng:NextInteger(-22,22))
            part.Parent=folder
            task.delay(2,function()
                if not part.Parent then return end
                part.Color=Color3.fromRGB(85,160,75)
                part.Size=Vector3.new(5,8,5)
                part.Position+=Vector3.new(0,3.8,0)
                for _,plr in ipairs(Players:GetPlayers()) do
                    local char=plr.Character
                    local hrp=char and char:FindFirstChild("HumanoidRootPart")
                    local hum=char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health>0 and (hrp.Position-part.Position).Magnitude<5 then
                        hum:TakeDamage(8)
                    end
                end
            end)
        end
        task.wait(1.5)
    end
    task.wait(math.max(0,duration-18))
    folder:Destroy()
end
local function earthquake(duration)
    message("Earthquake",duration,"The island is trembling!")
    -- Visual client camera shake only: no terrain destruction.
    task.wait(duration)
end
local function crystalStorm(duration)
    message("Crystal Storm",duration,"Glowing crystal energy fills the air!")
    local old=Lighting.Ambient
    Lighting.Ambient=Color3.fromRGB(95,75,160)
    task.wait(duration)
    Lighting.Ambient=old
end
local events={
    {name="Earthquake",run=earthquake},
    {name="Crystal Storm",run=crystalStorm},
    {name="Living Roots",run=roots}
}
task.spawn(function()
    task.wait(35)
    while true do
        local a=anger and tonumber(anger.Value) or 0
        task.wait(rng:NextInteger(130,210) - math.floor(math.clamp(a,0,100)*0.35))
        if not active and #Players:GetPlayers()>0 then
            active=true
            local event=events[rng:NextInteger(1,#events)]
            local ok,err=pcall(event.run,25)
            if not ok then warn("[Anmol Events]",err) end
            remote:FireAllClients("Ended",0,event.name.." ended.")
            active=false
        end
    end
end)
