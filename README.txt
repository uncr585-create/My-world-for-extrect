ANMOL: LIVING WORLD — MONSTER AI V1
==================================
What is inside:
- MonsterConfig.lua (ModuleScript)
- MonsterAI.server.lua (Script)

FEATURES
- Automatically generates basic Root Stalker and Whisper Shade placeholder R6 monsters.
- Server-authoritative movement and damage; no client-supplied damage RemoteEvent.
- NPCs try pathfinding and chase nearby players.
- Whisper Shade notices fast-moving/running players from farther away.
- Reads Workspace attribute WorldAnger (0..100) if your World Anger system supplies it.
- Whisper Shade becomes eligible for spawns above 25 anger. Otherwise Root Stalker.
- Attacks damage the Humanoid, integrating with Roblox health by default.

PC SETUP IN ROBLOX STUDIO (LATER)
1) Add a ModuleScript to ServerScriptService, name EXACTLY MonsterConfig, paste MonsterConfig.lua.
2) Add a Script to ServerScriptService, name MonsterAI, paste MonsterAI.server.lua.
3) Optional: Create a Workspace folder named MonsterSpawns with anchored Parts marking enemy spawn spots.
   If absent, the script attempts to spawn at random ground positions 45-110 studs from players.
4) Test in Play mode. Use Server logs / Output for errors.
5) Disable/destroy the script if monsters interfere with your map while testing.

ANDROID NOW
- Upload both Lua files AND this README to your game's GitHub repository.
- This is not a loadstring for a Roblox executor. It is game server code for your own Roblox place.

IMPORTANT
- THIS VERSION IS UNTESTED IN ROBLOX STUDIO. NPC body/rig movement and pathfinding may require fixes.
- The NPCs are placeholders, not finished 3D character models or animations.
- WorldAnger compatibility is conditional: the other script must call
  workspace:SetAttribute("WorldAnger", value) on the server.
- Normal/Hardcore damage multipliers are NOT yet connected.
- Monster kills, loot drops, persistent data, sound, sophisticated hearing and animations are future systems.
- For smooth navigation place marker parts on navigable terrain, away from players' spawn.
