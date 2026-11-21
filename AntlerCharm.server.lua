-- ANMOL: LIVING WORLD — Antler Charm V1 passive ability
-- Put this Script in ServerScriptService.
-- While a player owns a crafted AntlerCharm, grant 3 HP every 10 seconds.
-- Does not revive dead/downed players and cannot exceed MaxHealth.
-- No client RemoteEvent can grant this ability.
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local hasItem = ServerScriptService:WaitForChild("AnmolHasWeapon", 60)
if not hasItem or not hasItem:IsA("BindableFunction") then
    warn("[Anmol Charm] Inventory bridge missing. Install latest InventoryCrafting.server.lua")
    return
end
local HEAL = 3
local INTERVAL = 10
local alive = {}
local function loop(player)
    while player.Parent == Players and alive[player] do
        task.wait(INTERVAL)
        if player.Parent ~= Players or not alive[player] then break end
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            local ok, owned = pcall(function() return hasItem:Invoke(player, "AntlerCharm") end)
            if ok and owned == true then
                hum.Health = math.min(hum.MaxHealth, hum.Health + HEAL)
            end
        end
    end
end
Players.PlayerAdded:Connect(function(player)
    alive[player] = true
    task.spawn(loop, player)
end)
Players.PlayerRemoving:Connect(function(player) alive[player] = nil end)
for _, player in ipairs(Players:GetPlayers()) do
    alive[player] = true
    task.spawn(loop, player)
end
print("[Anmol] Antler Charm passive ready")
