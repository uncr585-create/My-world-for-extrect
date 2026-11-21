-- ANMOL: LIVING WORLD — Achievements + Titles V1
-- ServerScriptService > Achievements.server.lua (Script)
-- Reads existing saved progress attributes, tracks kills, saves unlocked titles.
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local store = DSS:GetDataStore("AnmolLivingWorld_Achievements_v1")
local folder = RS:FindFirstChild("AnmolAchievements") or Instance.new("Folder")
folder.Name = "AnmolAchievements"; folder.Parent = RS
local announce = folder:FindFirstChild("Unlock") or Instance.new("RemoteEvent")
announce.Name = "Unlock"; announce.Parent = folder
local killEvent = SS:FindFirstChild("AnmolMonsterDefeated") or Instance.new("BindableEvent")
killEvent.Name = "AnmolMonsterDefeated"; killEvent.Parent = SS

local DEFINITIONS = {
  {id="FirstSteps", stat="AnmolTreesCut", target=10, title="Forest Wanderer"},
  {id="WoodKeeper", stat="AnmolTreesCut", target=50, title="Woodland Keeper"},
  {id="CrystalSeeker", stat="AnmolCrystalsMined", target=5, title="Crystal Seeker"},
  {id="CrystalExpert", stat="AnmolCrystalsMined", target=25, title="Crystal Expert"},
  {id="Maker", stat="AnmolItemsCrafted", target=3, title="Village Crafter"},
  {id="MasterMaker", stat="AnmolItemsCrafted", target=15, title="Master Crafter"},
  {id="FirstVictory", stat="AnmolMonsterKills", target=1, title="First Defender"},
  {id="MonsterHunter", stat="AnmolMonsterKills", target=10, title="Monster Hunter"},
  {id="ShadowLegend", stat="AnmolMonsterKills", target=30, title="Shadow Legend"},
}
local sessions = {} -- [player]={kills=number, unlocked={}, loaded=true/false, dirty=false}
local function cleanNum(n)
  if type(n) ~= "number" or n ~= n then return 0 end
  return math.clamp(math.floor(n),0,100000000)
end
local function readSaved(player)
  local success, value = pcall(function() return store:GetAsync("Player_"..player.UserId) end)
  if not success then warn("[Anmol Achievements] Save unavailable for",player.Name,value); return false,nil end
  return true, type(value)=="table" and value or {}
end
local function check(player, session)
  if sessions[player] ~= session then return end
  for _, d in ipairs(DEFINITIONS) do
    local count = cleanNum(player:GetAttribute(d.stat))
    if count >= d.target and not session.unlocked[d.id] then
      session.unlocked[d.id]=true
      session.dirty=true
      player:SetAttribute("AnmolTitle",d.title)
      announce:FireClient(player,d.id,d.title,d.target)
    end
  end
end
local function save(player, session)
  if not session.loaded or not session.dirty then return end
  local ids={}
  for id,active in pairs(session.unlocked) do if active then ids[id]=true end end
  local kills=session.kills
  -- Merge monotonic values; avoids overwriting newer kills/unlocks from another server.
  local ok,err=pcall(function()
    store:UpdateAsync("Player_"..player.UserId,function(old)
      old=type(old)=="table" and old or {}
      old.kills=math.max(cleanNum(old.kills),kills)
      local merged=type(old.unlocked)=="table" and old.unlocked or {}
      for id in pairs(ids) do merged[id]=true end
      old.unlocked=merged
      return old
    end)
  end)
  if ok then session.dirty=false else warn("[Anmol Achievements] Save failed",player.Name,err) end
end
local function setup(player)
  local ok,data=readSaved(player)
  if player.Parent~=Players then return end
  local session={kills=cleanNum(data and data.kills),unlocked={},loaded=ok,dirty=false}
  for _,d in ipairs(DEFINITIONS) do
    if data and type(data.unlocked)=="table" and data.unlocked[d.id]==true then
      session.unlocked[d.id]=true
    end
  end
  sessions[player]=session
  player:SetAttribute("AnmolMonsterKills",session.kills)
  for _,d in ipairs(DEFINITIONS) do
    if session.unlocked[d.id] then player:SetAttribute("AnmolTitle",d.title) end
  end
  for _,attr in ipairs({"AnmolTreesCut","AnmolCrystalsMined","AnmolItemsCrafted","AnmolMonsterKills"}) do
    player:GetAttributeChangedSignal(attr):Connect(function() check(player,session) end)
  end
  -- Inventory DataStore may load later; check again when attributes appear.
  check(player,session)
end
killEvent.Event:Connect(function(player,monsterType)
  if typeof(player)~="Instance" or not player:IsA("Player") or player.Parent~=Players then return end
  local session=sessions[player]
  if not session then return end
  session.kills=math.min(session.kills+1,100000000)
  session.dirty=true
  player:SetAttribute("AnmolMonsterKills",session.kills)
  check(player,session)
end)
Players.PlayerAdded:Connect(function(player) task.spawn(setup,player) end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(setup,player) end
Players.PlayerRemoving:Connect(function(player)
  local session=sessions[player]
  if session then save(player,session); sessions[player]=nil end
end)
task.spawn(function()
  while true do
    task.wait(60)
    for player,session in pairs(sessions) do save(player,session) end
  end
end)
game:BindToClose(function()
  for player,session in pairs(sessions) do save(player,session) end
end)
print("[Anmol] Achievements + Titles V1 loaded")
