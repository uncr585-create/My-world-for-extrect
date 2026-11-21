-- ANMOL: LIVING WORLD — Daily Quests V1
-- Script in ServerScriptService; compatible with saved stat attributes from Inventory and Achievements.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local DSS = game:GetService("DataStoreService")
local store = DSS:GetDataStore("AnmolLivingWorld_DailyQuests_v1")
local folder = RS:FindFirstChild("AnmolQuests") or Instance.new("Folder")
folder.Name="AnmolQuests"; folder.Parent=RS
local function remote(name)
    local r=folder:FindFirstChild(name) or Instance.new("RemoteEvent")
    r.Name=name; r.Parent=folder; return r
end
local Update=remote("Update")
local Claim=remote("Claim")
local DEFS = {
    {id="TreeDay",title="Forest Helper",stat="AnmolTreesCut",goal=10,reward=35},
    {id="CrystalDay",title="Crystal Explorer",stat="AnmolCrystalsMined",goal=5,reward=55},
    {id="CraftDay",title="Village Maker",stat="AnmolItemsCrafted",goal=3,reward=45},
    {id="HuntDay",title="Night Defender",stat="AnmolMonsterKills",goal=3,reward=70},
}
local state={}
local function today() return math.floor(os.time()/86400) end -- UTC calendar day
local function num(n)
    if type(n)~="number" or n~=n then return 0 end
    return math.clamp(math.floor(n),0,100000000)
end
local function key(player) return "Daily_"..player.UserId end
local function fresh(player)
    local baselines={}
    for _,d in ipairs(DEFS) do baselines[d.id]=num(player:GetAttribute(d.stat)) end
    return {day=today(),base=baselines,claimed={}}
end
local function write(player,s)
    if state[player]~=s or not s.ready then return false end
    local snapshot={day=s.day,base=table.clone(s.base),claimed=table.clone(s.claimed)}
    local ok,err=pcall(function()
        store:UpdateAsync(key(player),function(old)
            -- Never let yesterday's save overwrite today's progress.
            if type(old)=="table" and tonumber(old.day) and old.day>snapshot.day then return nil end
            return snapshot
        end)
    end)
    if not ok then warn("[Anmol Quests] save failed",player.Name,err) end
    return ok
end
local function sync(player,s)
    if state[player]~=s or not s.ready then return end
    local payload={}
    for _,d in ipairs(DEFS) do
        local base=num(s.base[d.id])
        local completed=math.clamp(num(player:GetAttribute(d.stat))-base,0,d.goal)
        table.insert(payload,{id=d.id,title=d.title,progress=completed,goal=d.goal,reward=d.reward,claimed=s.claimed[d.id]==true})
    end
    Update:FireClient(player,s.day,payload)
end
local function refresh(player,s)
    if state[player]~=s then return false end
    local day=today()
    if s.day~=day then
        -- Snapshot new baseline at the UTC reset boundary.
        s.day=day;s.claimed={};s.base={}
        for _,d in ipairs(DEFS) do s.base[d.id]=num(player:GetAttribute(d.stat)) end
        s.dirty=true
    end
    return true
end
local function load(player)
    local ok,data=pcall(function() return store:GetAsync(key(player)) end)
    if player.Parent~=Players then return end
    if not ok then
        warn("[Anmol Quests] DataStore unavailable; quests disabled for",player.Name)
        return
    end
    -- Wait for saved inventory and kill stats before setting the daily baseline.
    -- Otherwise loaded lifetime progress could be mistaken for today's work.
    local deadline=os.clock()+45
    while player.Parent==Players and os.clock()<deadline do
        if player:GetAttribute("AnmolTreesCut")~=nil
           and player:GetAttribute("AnmolCrystalsMined")~=nil
           and player:GetAttribute("AnmolItemsCrafted")~=nil
           and player:GetAttribute("AnmolMonsterKills")~=nil then break end
        task.wait(.5)
    end
    if player.Parent~=Players then return end
    if player:GetAttribute("AnmolTreesCut")==nil
        or player:GetAttribute("AnmolCrystalsMined")==nil
        or player:GetAttribute("AnmolItemsCrafted")==nil
        or player:GetAttribute("AnmolMonsterKills")==nil then
        warn("[Anmol Quests] Waiting for inventory / achievements data; quests disabled for",player.Name)
        return
    end
    local s=fresh(player)
    if type(data)=="table" and data.day==today() then
        s.day=data.day
        s.base=type(data.base)=="table" and data.base or s.base
        s.claimed=type(data.claimed)=="table" and data.claimed or {}
    end
    s.ready=true;s.busy=false;s.dirty=false
    state[player]=s
    for _,d in ipairs(DEFS) do
        player:GetAttributeChangedSignal(d.stat):Connect(function()
            if state[player]==s then refresh(player,s);sync(player,s) end
        end)
    end
    sync(player,s)
end
Claim.OnServerEvent:Connect(function(player,id)
    if type(id)~="string" or #id>30 then return end
    local s=state[player]
    if not s or not s.ready or s.busy or not refresh(player,s) then return end
    local def
    for _,d in ipairs(DEFS) do if d.id==id then def=d;break end end
    if not def or s.claimed[id] then return end
    if num(player:GetAttribute(def.stat))-num(s.base[id]) < def.goal then return end
    s.busy=true
    local api=SS:FindFirstChild("AnmolQuestReward")
    local ok,granted=false,false
    if api and api:IsA("BindableFunction") then
        ok,granted=pcall(function() return api:Invoke(player,s.day,id) end)
    end
    if ok and granted then
        s.claimed[id]=true
        s.dirty=true
        write(player,s)
    end
    s.busy=false
    sync(player,s)
end)
Players.PlayerAdded:Connect(function(p) task.spawn(load,p) end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(load,p) end
Players.PlayerRemoving:Connect(function(p)
    local s=state[p]
    if s then write(p,s);state[p]=nil end
end)
task.spawn(function()
    while true do
        task.wait(45)
        for p,s in pairs(state) do
            refresh(p,s);sync(p,s)
            if s.dirty and not s.busy then if write(p,s) then s.dirty=false end end
        end
    end
end)
game:BindToClose(function()
    for p,s in pairs(state) do write(p,s) end
end)
