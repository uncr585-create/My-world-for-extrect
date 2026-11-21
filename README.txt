ANMOL: LIVING WORLD — SOUND + ATMOSPHERE V1

Files:
1. AnmolSoundConfig.lua (ModuleScript) -> ReplicatedStorage, name: AnmolSoundConfig
2. SoundAtmosphere.server.lua (Script) -> ServerScriptService
3. SoundAtmosphere.client.lua (LocalScript) -> StarterPlayer > StarterPlayerScripts

Requirements:
- WorldAnger.server.lua creates ReplicatedStorage.AnmolWorldState with Anger.
- Optional WeatherDayNight.server.lua provides Weather, TimeOfDayHours, and ThunderPulse.
- Sound files are NOT embedded. Upload audio you own or have permission to use
  to Roblox and put the approved IDs into AnmolSoundConfig.lua.
- If audio IDs are blank, gameplay/HUD still loads but is silent.
- Audio availability may depend on Roblox asset privacy and permissions.

Features:
- Ambient audio by day/night
- Rain/storm ambience
- Heartbeat intensity increases with anger
- Warning on mood escalation
- Thunder cue from the Weather system
- Mobile sound on/off toggle

Important:
- Does NOT replace WorldAnger or Weather scripts.
- Does NOT include monster-specific proximity sounds yet.
- Not tested inside Roblox Studio.
- Audio permissions, mobile performance and UI overlap require testing.
