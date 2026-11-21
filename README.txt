ANMOL: LIVING WORLD — ISLAND MAP GENERATOR V1
==============================================

WHAT THIS FILE DOES
- Creates Heart Village (spawn, 3 huts, campfire)
- Creates Whispering Forest (125 decorative tree attempts, Whisper Core, Echo Pond)
- Makes one connecting trail across the two areas
- Creates 12 tagged harvest nodes using "AnmolResourceNode" and "ResourceType"
- Creates monster spawn markers under Workspace/MonsterSpawns for Monster AI V1
- Adds signposts for Crystal Depths, Toxic Marsh, and World Heart (NOT real zones yet)

INSTALL ON PC (Roblox Studio)
1. Open your own place in Roblox Studio.
2. Insert a Script named IslandMap into ServerScriptService.
3. Paste in IslandMap.server.lua.
4. In ServerScriptService, DISABLE or DELETE the old ResourceZone.server.lua
   from Resource Collection V1. It also generates example resources and would
   duplicate the new forest's nodes. KEEP the UPDATED InventoryCrafting.server.lua.
5. Keep WorldAnger.server.lua, MonsterAI.server.lua and MonsterConfig module.
6. IMPORTANT: The map creates its own HeartVillageSpawn. Remove/disable old
   SpawnLocations in your baseplate to avoid inconsistent spawn points.
7. Remove existing huge baseplate if it overlaps the island surface.
8. Press Play in Studio and test village, forest, harvesting and monster paths.

ORDER / COMPATIBILITY
- This map is one server Script, not a client script or Delta executor script.
- The inventory server script listens for CollectionService AnmolResourceNode tags.
- The MonsterAI server script looks at Workspace.MonsterSpawns.
- Scripts can start in any order: inventory uses tag-added listeners; monsters
  will see map spawn markers by their first scheduled spawn (usually 12 sec).
- MonsterAI V1 does NOT enforce an actual safe zone. Monsters may follow players
  toward village. Village safe-zone combat logic still needs implementation.
- World Anger effects, zone events and art polish are future work.
- Placeholder parts are meant for mechanics tests, not final landscape art.

ANDROID WORKFLOW
1. Download ZIP, extract it with Android Files.
2. Upload IslandMap.server.lua and README.txt to your game GitHub repository.
3. Keep ZIP as a backup.
4. Roblox Studio on Windows/Mac is needed to run and test this server script.

DO NOT use this as a loadstring inside someone else's Roblox game.
