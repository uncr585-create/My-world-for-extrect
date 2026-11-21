-- ANMOL: LIVING WORLD — Multiplayer Teams V1
-- ServerScriptService > Teams (Script)
-- Server authoritative parties, maximum 8 players per team.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local MAX_TEAM_SIZE = 8
local INVITE_LIFETIME = 30
local ACTION_COOLDOWN = 0.6
local remote = RS:FindFirstChild("AnmolTeamsRemote") or Instance.new("RemoteEvent")
remote.Name = "AnmolTeamsRemote"
remote.Parent = RS

local teams = {}                 -- [id] = {leader = userId, members = {[userId]=true}}
local membership = {}            -- [userId] = teamId
local invites = {}               -- [recipientUserId] = {senderId, expires}
local lastAction = {}            -- [userId] = time
local nextTeamId = 0

local function online(id)
    return Players:GetPlayerByUserId(id)
end
local function count(team)
    local n = 0
    for _ in pairs(team.members) do n += 1 end
    return n
end
local function info(id)
    local team = teams[id]
    if not team then return nil end
    local members = {}
    for userId in pairs(team.members) do
        local p = online(userId)
        if p then
            table.insert(members, {userId = userId, name = p.DisplayName, username = p.Name, leader = userId == team.leader})
        end
    end
    table.sort(members, function(a, b)
        if a.leader ~= b.leader then return a.leader end
        return a.username < b.username
    end)
    return {id = id, size = #members, max = MAX_TEAM_SIZE, members = members}
end
local function syncTeam(id)
    local team = teams[id]
    if not team then return end
    local data = info(id)
    for userId in pairs(team.members) do
        local p = online(userId)
        if p then
            p:SetAttribute("AnmolTeamId", id)
            p:SetAttribute("AnmolTeamLeader", userId == team.leader)
            remote:FireClient(p, "Sync", data)
        end
    end
end
local function notify(p, msg)
    if p then remote:FireClient(p, "Info", msg) end
end
local function detach(p)
    local userId = p.UserId
    local id = membership[userId]
    membership[userId] = nil
    p:SetAttribute("AnmolTeamId", nil)
    p:SetAttribute("AnmolTeamLeader", false)
    remote:FireClient(p, "Sync", nil)
    if not id then return end
    local team = teams[id]
    if not team then return end
    team.members[userId] = nil
    if not next(team.members) then
        teams[id] = nil
        return
    end
    if team.leader == userId then
        local leaderId
        for memberId in pairs(team.members) do
            if not leaderId or memberId < leaderId then leaderId = memberId end
        end
        team.leader = leaderId
        notify(online(leaderId), "You are now the team leader.")
    end
    syncTeam(id)
end

remote.OnServerEvent:Connect(function(player, action, value)
    if type(action) ~= "string" then return end
    local now = os.clock()
    if now - (lastAction[player.UserId] or 0) < ACTION_COOLDOWN then return end
    lastAction[player.UserId] = now
    if action == "RequestSync" then
        local id = membership[player.UserId]
        remote:FireClient(player, "Sync", id and info(id) or nil)
        return
    end
    if action == "Invite" then
        if typeof(value) ~= "number" or value % 1 ~= 0 or value == player.UserId then return end
        local target = online(value)
        if not target then notify(player, "Player is not in this server."); return end
        if membership[target.UserId] then notify(player, "That player already has a team."); return end
        local id = membership[player.UserId]
        if id then
            local team = teams[id]
            if not team or team.leader ~= player.UserId then notify(player, "Only team leaders can invite."); return end
            if count(team) >= MAX_TEAM_SIZE then notify(player, "Team is full (8/8)."); return end
        end
        invites[target.UserId] = {senderId = player.UserId, expires = now + INVITE_LIFETIME}
        remote:FireClient(target, "InviteReceived", {senderId = player.UserId, name = player.DisplayName, seconds = INVITE_LIFETIME})
        notify(player, "Invite sent to " .. target.DisplayName)
        return
    end
    if action == "Decline" then
        invites[player.UserId] = nil
        return
    end
    if action == "Accept" then
        local pending = invites[player.UserId]
        invites[player.UserId] = nil
        if not pending or now > pending.expires then notify(player, "Invite expired."); return end
        if membership[player.UserId] then notify(player, "Leave your current team first."); return end
        local sender = online(pending.senderId)
        if not sender then notify(player, "Inviter left the server."); return end
        local id = membership[sender.UserId]
        if not id then
            nextTeamId += 1
            id = nextTeamId
            teams[id] = {leader = sender.UserId, members = {[sender.UserId] = true}}
            membership[sender.UserId] = id
        end
        local team = teams[id]
        if not team or team.leader ~= sender.UserId or count(team) >= MAX_TEAM_SIZE then
            notify(player, "That team is unavailable or full.")
            return
        end
        team.members[player.UserId] = true
        membership[player.UserId] = id
        syncTeam(id)
        notify(player, "You joined " .. sender.DisplayName .. "'s team!")
        return
    end
    if action == "Leave" then
        detach(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    detach(player)
    invites[player.UserId] = nil
    lastAction[player.UserId] = nil
    for targetId, request in pairs(invites) do
        if request.senderId == player.UserId then invites[targetId] = nil end
    end
end)
