ANMOL: LIVING WORLD — MULTIPLAYER TEAM SYSTEM V1

INSTALL (PC / ROBLOX STUDIO LATER)
1. ServerScriptService > Script named Teams:
   paste contents of Teams.server.lua
2. StarterPlayer > StarterPlayerScripts > LocalScript named TeamsHUD:
   paste contents of TeamsHUD.client.lua
3. Multiplayer test with at least 2 test players in Studio.

FEATURES
- Team invitations between players in the same server
- Accept / Decline within 30 seconds
- Maximum 8 members per team
- Only current leader can invite new members
- Leave team; leader transfers automatically
- Server checks requests, cooldowns and team sizes
- Mobile-friendly TEAM button and team roster
- Replicated Player attributes AnmolTeamId and AnmolTeamLeader

LIMITATIONS
- Teams last for the current Roblox server session only; they do not persist.
- This is NOT a party matchmaking or cross-server teleport system.
- Friendly fire, revives, map markers and shared quests are NOT yet integrated.
- V1 uses an in-server roster; players must actually be in the same server.
- Not tested in Roblox Studio yet. Game UI placement can overlap other HUDs.
- No files from earlier versions need to be deleted for this V1.

ANDROID / GITHUB
Extract the ZIP and upload its two .lua files plus README.txt to a folder
named Multiplayer_Teams_V1. Keep your older files in their own folders.
