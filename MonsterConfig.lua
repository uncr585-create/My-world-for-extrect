-- ModuleScript: ServerScriptService/MonsterConfig
-- ANMOL: LIVING WORLD - Monster AI V1 settings
local Config = {}

Config.MaxMonsters = 6
Config.SpawnInterval = 12
Config.MinSpawnDistance = 35
Config.MaxSpawnDistance = 110
Config.RespawnDelay = 18
Config.AngerAttribute = "WorldAnger" -- optional attribute on Workspace, 0-100
Config.Debug = false

Config.Types = {
    RootStalker = {
        MaxHealth = 110,
        WalkSpeed = 10,
        ChaseSpeed = 15,
        DetectionRadius = 42,
        LoseRadius = 82,
        AttackRadius = 5,
        Damage = 15,
        AttackCooldown = 2,
        Color = Color3.fromRGB(86, 74, 53),
        Glow = Color3.fromRGB(140, 255, 118),
        NoiseSensitivity = 0.3,
        MinAnger = 0,
    },
    WhisperShade = {
        MaxHealth = 65,
        WalkSpeed = 12,
        ChaseSpeed = 19,
        DetectionRadius = 26,
        LoseRadius = 100,
        AttackRadius = 5,
        Damage = 11,
        AttackCooldown = 1.4,
        Color = Color3.fromRGB(39, 33, 63),
        Glow = Color3.fromRGB(178, 112, 255),
        NoiseSensitivity = 1.0,
        MinAnger = 25,
    },
}

return Config
