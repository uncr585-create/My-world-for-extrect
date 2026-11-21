ANMOL: LIVING WORLD — Monster AI V2

INSTALL
- Keep existing MonsterAI.server.lua and MonsterConfig.lua from V1.
- Add AdvancedMonsters.server.lua to ServerScriptService as a Script.
- Keep WorldAnger.server.lua and IslandMap.server.lua + IslandExpansionV2.server.lua enabled.
- Adds models to Workspace.AnmolMonsters for existing Combat to hit them.

SPAWN POINTS
- Crystal Burrower uses Workspace.MonsterSpawns.AnmolCrystalSpawn_1 from Island Expansion V2.
- Hollow Deer uses Workspace.MonsterSpawns.AnmolForestDeerSpawn if created; otherwise first non-crystal/non-marsh/non-heart marker from V1 Island map.
- If neither marker exists, the script waits instead of spawning at the wrong location.

BEHAVIOR
- Hollow Deer (125 HP, 17 damage) is neutral until hit or World Anger >=80.
- Crystal Burrower (180 HP, 22 damage) detects nearby players; CrystalMined world action increases its detection for 18 seconds.
- Server controls targeting, pathfinding, attacks and damage.
- One of each special monster alive at a time, respawn after death.

LIMITATIONS
- Placeholder R6 models, not final deer/worm art or animations.
- Crystal alert has no exact mining position yet, so detection boost is global to this monster.
- LootRewards V1 ONLY has drops for RootStalker and WhisperShade; these new monsters provide no loot until its reward table is extended.
- Normal/Hardcore damage multipliers not connected yet.
- Test in Roblox Studio; not yet tested.
