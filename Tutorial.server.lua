-- ANMOL Living World - tutorial progress server (prototype)
-- Place in ServerScriptService as Script
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStoreService = game:GetService('DataStoreService')
local store = DataStoreService:GetDataStore('AnmolTutorial_v1')
local remote = Instance.new('RemoteEvent')
remote.Name = 'AnmolTutorialRemote'
remote.Parent = ReplicatedStorage
local progress = {}
local function save(player)
    local state = progress[player]
    if state == nil then return end
    local ok, err = pcall(function() store:SetAsync(tostring(player.UserId), state) end)
    if not ok then warn('Tutorial save failed:', err) end
end
Players.PlayerAdded:Connect(function(player)
    local value = 0
    local ok, data = pcall(function() return store:GetAsync(tostring(player.UserId)) end)
    if ok and type(data) == 'number' then value = math.clamp(math.floor(data), 0, 6) end
    progress[player] = value
    remote:FireClient(player, 'Sync', value)
end)
remote.OnServerEvent:Connect(function(player, action, step)
    if action ~= 'Advance' or type(step) ~= 'number' then return end
    local current = progress[player]
    if current == nil then return end
    step = math.floor(step)
    -- This is a guided reading tutorial, not verified gameplay achievements.
    if step == current + 1 and step <= 6 then
        progress[player] = step
        remote:FireClient(player, 'Sync', step)
        if step == 6 then task.spawn(save, player) end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    save(player)
    progress[player] = nil
end)
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do save(player) end
end)
