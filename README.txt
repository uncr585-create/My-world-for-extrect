ANMOL: LIVING WORLD — WEAPONS + COMBAT V1

INCLUDED FILES + ROBLOX STUDIO PLACEMENT:
- Combat.server.lua -> ServerScriptService as Script
- CombatHUD.client.lua -> StarterPlayer > StarterPlayerScripts as LocalScript
- InventoryCrafting.server.lua -> ServerScriptService as Script, REPLACE previous same-name inventory script
- InventoryCraftingHUD.client.lua -> StarterPlayer > StarterPlayerScripts as LocalScript, REPLACE previous inventory HUD

IMPORTANT
1. ONLY ONE InventoryCrafting.server.lua script should be active.
   This updated version is based on Building + Shelter V1 and retains its saving and building bridges.
2. Keep MonsterAI.server.lua and MonsterConfig.lua from Monster AI V1.
3. Hit detection only damages models in Workspace.AnmolMonsters with AnmolMonster=true and a living Humanoid.
4. Players must face targets, be in range and have line of sight.
5. Weapons: Fists (free, damage 4), StoneAxe (damage 16), Sword (damage 25).
6. Craft Sword from 2 Wood + 5 Stone + 1 Crystal. Stone Axe from 3 Wood + 2 Stone.
7. HUD works on touch (ATTACK button) and keyboard F. Select weapons using the cycle button.
8. Existing DATASTORE_NAME is unchanged; older saves load with Sword quantity defaulting to 0.
9. Boss (World Heart) uses its own crystal mechanic in V1, not weapon hits yet.
10. This is a first prototype; Studio testing, animations, mobile UI spacing, exploit resistance and balancing remain.
11. Do not execute these server scripts via a client executor; put them in Studio as specified.
