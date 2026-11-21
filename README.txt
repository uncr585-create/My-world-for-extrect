ANMOL: LIVING WORLD — MONSTER LOOT V2

Adds Hollow Deer and Crystal Burrower loot without removing the V1 loot and achievements kill event.

STUDIO INSTALL (after PC is available):
1. Replace the existing InventoryCrafting.server.lua Script in ServerScriptService with this version.
2. Replace the existing LootRewards.server.lua Script in ServerScriptService with this version.
3. Replace the InventoryCraftingHUD.client.lua LocalScript in StarterPlayer > StarterPlayerScripts with this version.
4. Keep MonsterAI.server.lua (V1), AdvancedMonsters.server.lua (V2), Combat.server.lua (last-hit enabled from Loot V1), Achievements.server.lua, and AchievementsHUD.client.lua.
5. Do NOT run multiple InventoryCrafting or LootRewards scripts simultaneously.
6. Keep existing DataStore name to retain saves. Test Studio DataStore access and backup important live data before deployment.

DROP TABLES (probability per credited kill):
Root Stalker: 2-4 Wood, 1-2 Fiber, 8% chance of 1 Crystal.
Whisper Shade: 1-3 Stone, 1-2 Fiber, 22% chance of 1 Crystal.
Hollow Deer: 2-4 Wood, 2-3 Fiber, 35% chance of 1 HollowAntler.
Crystal Burrower: 3-5 Stone, 1-2 Crystal, 30% chance of 1 CrystalShard.

NEW CRAFTS:
AntlerCharm: 1 HollowAntler + 3 Fiber
CrystalBlade: 2 CrystalShard + 3 Stone + 1 Crystal
These crafted items are INVENTORY ITEMS ONLY for now; no damage/ability effects are connected.

IMPORTANT:
- Requires attacker attribution from Combat.server.lua: LastHitUserId / LastHitAt.
- Uses server-only AnmolGrantLoot bridge; does not trust client reward amounts.
- Rewards can be partially granted when inventory capacity is limited (max 100 items).
- The monster kill achievement event is preserved.
- Scripts not tested in Roblox Studio yet.
- Android: extract ZIP and upload .lua files to GitHub as source; do not run a ZIP.
