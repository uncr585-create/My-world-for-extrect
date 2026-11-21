-- ANMOL: LIVING WORLD — Coins, Village Shop, Trading V1
-- Script -> ServerScriptService. Separate saved coin balance; no inventory replacements.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local DSS = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local STORE = DSS:GetDataStore("AnmolLivingWorld_Coins_v1")
local LEASE = 180
local AUTOSAVE = 45
local MAX_COINS = 100000000
local SERVER_ID = (game.JobId ~= "" and game.JobId or "studio") .. ":" .. HttpService:GenerateGUID(false)
local sessions = {} -- player -> {balance, locked, dirty, busy, saving}
local pending = {} -- offer id -> {from, to, amount, expires}
local itemPending = {} -- id -> {from,to,item,count,expires}
local lastOffer = {}
local shopItems = {
    WoodBundle = {cost=4, gives={Wood=1}},
    StoneBundle = {cost=5, gives={Stone=1}},
    FiberBundle = {cost=4, gives={Fiber=1}},
    CrystalBundle = {cost=35, gives={Crystal=1}},
    StoneAxe = {cost=90, equipment="StoneAxe"},
    Sword = {cost=180, equipment="Sword"},
    LeafVest = {cost=125, equipment="LeafVest"},
    StoneArmor = {cost=350, equipment="StoneArmor"},
    CrystalArmor = {cost=950, equipment="CrystalArmor"},
}
local lootCoins = {RootStalker=12, WhisperShade=18, HollowDeer=28, CrystalBurrower=40}

local remotes = RS:FindFirstChild("AnmolEconomy") or Instance.new("Folder")
remotes.Name = "AnmolEconomy"; remotes.Parent = RS
local function getRemote(name)
    local existing = remotes:FindFirstChild(name)
    if existing then assert(existing:IsA("RemoteEvent")); return existing end
    local r=Instance.new("RemoteEvent");r.Name=name;r.Parent=remotes;return r
end
local Action = getRemote("Action")
local Update = getRemote("Update")
local Offer = getRemote("TradeOffer")
local OpenShop = getRemote("OpenShop")
local ItemTradeOffer = getRemote("ItemTradeOffer")
local function amount(n)
    return type(n)=="number" and n==n and n>=0 and n<=MAX_COINS and math.floor(n) or 0
end
local function key(player) return "Coins_"..player.UserId end
local function msg(player,text)
    if player.Parent==Players then Update:FireClient(player,"Message",text) end
end
local function sync(player)
    local s=sessions[player]
    if not s then return end
    player:SetAttribute("AnmolCoins", s.balance)
    Update:FireClient(player,"Coins",s.balance)
end
local function load(player)
    local success,result=pcall(function()
        return STORE:UpdateAsync(key(player),function(old)
            old=type(old)=="table" and old or {}
            local lease=tonumber(old.lockUntil) or 0
            if old.owner and old.owner~=SERVER_ID and lease>os.time() then
                return nil -- locked by another active server
            end
            return {coins=amount(old.coins),questClaims=type(old.questClaims)=="table" and old.questClaims or {},owner=SERVER_ID,lockUntil=os.time()+LEASE}
        end)
    end)
    if player.Parent~=Players then return end
    if not success or not result then
        warn("[Anmol Economy] Coin profile unavailable",player.Name,result)
        msg(player,"Coins unavailable; trading/shop disabled to protect data")
        return
    end
    sessions[player]={balance=amount(result.coins),locked=true,dirty=false,busy=false,saving=false}
    sync(player)
end
local function save(player,release)
    local s=sessions[player]
    if not s or not s.locked or s.saving then return end
    s.saving=true
    local balance=s.balance
    local ok,err=pcall(function()
        STORE:UpdateAsync(key(player),function(old)
            if type(old)~="table" or old.owner~=SERVER_ID then return nil end
            return {coins=balance,questClaims=type(old.questClaims)=="table" and old.questClaims or {},owner=release and nil or SERVER_ID,
                lockUntil=release and 0 or (os.time()+LEASE)}
        end)
    end)
    if not ok then warn("[Anmol Economy] Save failed",player.Name,err) else s.dirty=false end
    s.saving=false
end
local function ready(player)
    local s=sessions[player]
    return s and s.locked and not s.busy and not s.saving and player.Parent==Players and s
end
local function near(a,b)
    local ca=a.Character and a.Character:FindFirstChild("HumanoidRootPart")
    local cb=b.Character and b.Character:FindFirstChild("HumanoidRootPart")
    return ca and cb and (ca.Position-cb.Position).Magnitude <= 18
end
local shopPart=Instance.new("Part")
shopPart.Name="AnmolVillageShop"
shopPart.Anchored=true; shopPart.Size=Vector3.new(8,6,6)
shopPart.Position=Vector3.new(-215,4,20)
shopPart.Color=Color3.fromRGB(75,126,91)
shopPart.Material=Enum.Material.WoodPlanks
shopPart.Parent=Workspace
local prompt=Instance.new("ProximityPrompt")
prompt.ActionText="Open Shop";prompt.ObjectText="Heart Village Trader"
prompt.MaxActivationDistance=14;prompt.HoldDuration=.25;prompt.Parent=shopPart
prompt.Triggered:Connect(function(player)
    if ready(player) then OpenShop:FireClient(player) end
end)
local function nearShop(player)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return root and (root.Position-shopPart.Position).Magnitude<=20
end
local function grant(player,items)
    local bridge=SS:FindFirstChild("AnmolGrantLoot")
    if not bridge or not bridge:IsA("BindableFunction") then return false end
    local ok,success,granted=pcall(function() return bridge:Invoke(player,items) end)
    if not ok or not success or type(granted)~="table" then return false end
    for name,value in pairs(items) do
        if granted[name]~=value then return false end
    end
    return true
end
local function buy(player,id)
    local item=shopItems[id]
    local s=ready(player)
    if not item or not s or not nearShop(player) then return end
    if s.balance<item.cost then msg(player,"Not enough coins") return end
    s.busy=true
    s.balance-=item.cost
    s.dirty=true
    -- Bundles give only one unit, so inventory capacity cannot cause
    -- a partial purchase: it either grants one or refuses entirely.
    local success = false
    if item.equipment then
        local bridge = SS:FindFirstChild("AnmolInventoryTradeV2")
        if bridge and bridge:IsA("BindableFunction") then
            local ok,res = pcall(function()
                return bridge:Invoke("GrantEquipment",player,nil,item.equipment,1)
            end)
            success = ok and res == true
        end
    else
        success = grant(player,item.gives)
    end
    if not success then s.balance+=item.cost end
    s.dirty=true;s.busy=false;sync(player)
    msg(player,success and ("Purchased "..id) or "Purchase failed (inventory full or not ready)")
end
local function cancelOffer(id,notification)
    local t=pending[id]
    if not t then return end
    pending[id]=nil
    if notification then msg(t.from,notification); msg(t.to,notification) end
end
local function sendOffer(player,targetId,coins)
    local s=ready(player)
    if not s or type(targetId)~="number" or type(coins)~="number" then return end
    if coins~=math.floor(coins) or coins<1 or coins>1000 then return end
    local target=Players:GetPlayerByUserId(targetId)
    if not target or target==player or not ready(target) or not near(player,target) then
        msg(player,"Stand near another player to trade") return
    end
    if s.balance<coins then msg(player,"Not enough coins") return end
    local now=os.clock()
    if now-(lastOffer[player] or -100)<5 then return end
    lastOffer[player]=now
    -- Only one outstanding offer per sender.
    for id,existing in pairs(pending) do
        if existing.from==player then cancelOffer(id,nil) end
    end
    local id=HttpService:GenerateGUID(false)
    pending[id]={from=player,to=target,amount=coins,expires=now+30}
    Offer:FireClient(target,id,player.DisplayName,coins)
    msg(player,"Offer sent to "..target.DisplayName)
end
local function accept(player,id,acceptIt)
    if type(id)~="string" or #id>70 then return end
    local trade=pending[id]
    if not trade or trade.to~=player then return end
    pending[id]=nil
    if acceptIt~=true then msg(trade.from,"Offer declined") return end
    if os.clock()>trade.expires or not near(trade.from,player) then
        msg(player,"Trade expired or players too far") return end
    local a=ready(trade.from)
    local b=ready(player)
    if not a or not b or a.balance<trade.amount or b.balance>MAX_COINS-trade.amount then
        msg(player,"Trade unavailable") return end
    -- No yields between validating and transferring both balances.
    a.balance-=trade.amount; b.balance+=trade.amount
    a.dirty=true;b.dirty=true
    sync(trade.from);sync(player)
    msg(trade.from,"Sent "..trade.amount.." coins to "..player.DisplayName)
    msg(player,"Received "..trade.amount.." coins from "..trade.from.DisplayName)
end
Action.OnServerEvent:Connect(function(player,kind,arg1,arg2)
    if kind=="Buy" and type(arg1)=="string" then buy(player,arg1)
    elseif kind=="Offer" then sendOffer(player,arg1,arg2)
    elseif kind=="Accept" then accept(player,arg1,true)
    elseif kind=="Decline" then accept(player,arg1,false)
    elseif kind=="Sync" then if ready(player) then sync(player) end end
end)
local killEvent=SS:FindFirstChild("AnmolMonsterDefeated")
if not killEvent then
    killEvent=Instance.new("BindableEvent")
    killEvent.Name="AnmolMonsterDefeated"
    killEvent.Parent=SS
end
killEvent.Event:Connect(function(player,monsterType)
    local s=ready(player)
    local reward=lootCoins[monsterType]
    if not s or not reward then return end
    s.balance=math.min(MAX_COINS,s.balance+reward)
    s.dirty=true;sync(player)
    msg(player,"+"..reward.." Coins ("..monsterType..")")
end)
Players.PlayerAdded:Connect(function(player) task.spawn(load,player) end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(load,player) end
Players.PlayerRemoving:Connect(function(player)
    for id,t in pairs(pending) do
        if t.from==player or t.to==player then cancelOffer(id,nil) end
    end
    save(player,true)
    sessions[player]=nil;lastOffer[player]=nil
end)
task.spawn(function()
    while true do
        task.wait(AUTOSAVE)
        for player in pairs(sessions) do task.spawn(save,player,false) end
        for id,t in pairs(pending) do if t.expires<os.clock() then cancelOffer(id,"Trade offer expired") end end
    end
end)
game:BindToClose(function()
    local count=0
    for player in pairs(sessions) do
        count+=1
        task.spawn(function() save(player,true);count-=1 end)
    end
    local untilTime=os.clock()+25
    while count>0 and os.clock()<untilTime do task.wait(.1) end
end)

-- Quests V1: server-only, idempotent reward grant; requires a loaded coin profile.
-- Reward ids are unique per UTC day and quest name.
local questReward = SS:FindFirstChild("AnmolQuestReward")
if not questReward then
    questReward = Instance.new("BindableFunction")
    questReward.Name = "AnmolQuestReward"
    questReward.Parent = SS
end
local ALLOWED_QUEST_PAY = {TreeDay=35, CrystalDay=55, CraftDay=45, HuntDay=70}
questReward.OnInvoke = function(player, day, questId)
    if typeof(player) ~= "Instance" or not player:IsA("Player") or player.Parent ~= Players then return false end
    if type(day) ~= "number" or day ~= math.floor(os.time()/86400) then return false end
    if type(questId) ~= "string" or not ALLOWED_QUEST_PAY[questId] then return false end
    local s = ready(player)
    if not s then return false end
    s.busy = true
    local rewardId = tostring(day) .. ":" .. questId
    local updated
    local ok, err = pcall(function()
        updated = STORE:UpdateAsync(key(player), function(old)
            if type(old) ~= "table" or old.owner ~= SERVER_ID then return nil end
            local claims = type(old.questClaims)=="table" and old.questClaims or {}
            if not claims[rewardId] then
                claims[rewardId] = true
                old.coins = math.min(MAX_COINS, amount(old.coins) + ALLOWED_QUEST_PAY[questId])
            end
            -- Keep 14-day claim history to avoid unbounded DataStore growth.
            for claim in pairs(claims) do
                local claimDay = tonumber(tostring(claim):match("^(%d+):"))
                if claimDay and claimDay < day-14 then claims[claim] = nil end
            end
            old.questClaims = claims
            old.lockUntil = os.time()+LEASE
            return old
        end)
    end)
    if ok and updated and sessions[player] == s then
        s.balance = amount(updated.coins)
        s.dirty = false
        sync(player)
    else
        warn("[Anmol Quests] Coin grant unavailable", err)
    end
    s.busy = false
    return ok and updated ~= nil
end

print("[Anmol] Coins + Village Shop + Trading V1 ready")


-- Trading V2: item offers are requested by a player, validated on server,
-- and only applied when the recipient accepts while both are nearby.
local TRADE_ITEMS = {Wood=true, Stone=true, Crystal=true, Fiber=true,
    HollowAntler=true, CrystalShard=true, StoneAxe=true, Sword=true,
    Torch=true, Bandage=true, NoiseDecoy=true, AntlerCharm=true,
    CrystalBlade=true, LeafVest=true, StoneArmor=true, CrystalArmor=true}
local function cancelItemOffer(id, message)
    local trade=itemPending[id]
    if not trade then return end
    itemPending[id]=nil
    if message then msg(trade.from,message);msg(trade.to,message) end
end
local function offerItem(player,targetId,itemName,count)
    if not ready(player) or type(targetId)~="number" or type(itemName)~="string"
        or not TRADE_ITEMS[itemName] or type(count)~="number"
        or count~=math.floor(count) or count<1 or count>10 then return end
    local target=Players:GetPlayerByUserId(targetId)
    if not target or target==player or not ready(target) or not near(player,target) then
        msg(player,"Stand near another player to trade");return end
    local now=os.clock()
    if now-(lastOffer[player] or -100)<5 then return end
    lastOffer[player]=now
    for id,t in pairs(itemPending) do if t.from==player then cancelItemOffer(id,nil) end end
    local id=HttpService:GenerateGUID(false)
    itemPending[id]={from=player,to=target,item=itemName,count=count,expires=now+30}
    ItemTradeOffer:FireClient(target,id,player.DisplayName,itemName,count)
    msg(player,"Item offer sent to "..target.DisplayName)
end
local function answerItem(player,id,accepted)
    if type(id)~="string" or #id>70 then return end
    local t=itemPending[id]
    if not t or t.to~=player then return end
    itemPending[id]=nil
    if not accepted then msg(t.from,"Item trade declined");return end
    if os.clock()>t.expires or not near(t.from,player) then
        msg(player,"Trade expired or players too far");return end
    if not ready(player) or not ready(t.from) then
        msg(player,"Player data not ready");return end
    local bridge=SS:FindFirstChild("AnmolInventoryTradeV2")
    if not bridge or not bridge:IsA("BindableFunction") then
        msg(player,"Inventory trade bridge unavailable");return end
    local ok,result,reason=pcall(function()
        return bridge:Invoke("Transfer",t.from,player,t.item,t.count)
    end)
    if not ok or not result then
        msg(player,"Trade failed: "..tostring(reason or "unavailable"))
        msg(t.from,"Item trade failed")
        return
    end
    msg(t.from,"Sent "..t.count.." "..t.item.." to "..player.DisplayName)
    msg(player,"Received "..t.count.." "..t.item.." from "..t.from.DisplayName)
end
Action.OnServerEvent:Connect(function(player,kind,a,b,c)
    if kind=="ItemOffer" then offerItem(player,a,b,c)
    elseif kind=="ItemAccept" then answerItem(player,a,true)
    elseif kind=="ItemDecline" then answerItem(player,a,false) end
end)
Players.PlayerRemoving:Connect(function(player)
    for id,t in pairs(itemPending) do
        if t.from==player or t.to==player then cancelItemOffer(id,nil) end
    end
end)
task.spawn(function()
    while true do
        task.wait(5)
        for id,t in pairs(itemPending) do
            if os.clock()>t.expires then cancelItemOffer(id,"Item trade expired") end
        end
    end
end)
