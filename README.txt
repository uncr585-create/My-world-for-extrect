ANMOL: LIVING WORLD — SPECIAL WEAPONS & CHARM V1

FEATURES
- Crystal Blade: 32 damage, 10-stud range, 0.85s cooldown; every 4th successful Crystal Blade hit adds +18 bonus damage (50 total).
- Antler Charm: passive +3 Health every 10 seconds while item is owned and player is alive.
- No new remote lets players grant items or health themselves.
- Existing monster last-hit attribution remains intact for loot/achievements.

INSTALL LATER IN ROBLOX STUDIO
1. ServerScriptService: replace existing Combat.server.lua with this one (do not run two copies).
2. ServerScriptService: replace existing InventoryCrafting.server.lua with this one (do not run two copies).
3. ServerScriptService: add AntlerCharm.server.lua as a separate Script.
4. StarterPlayer > StarterPlayerScripts: replace CombatHUD.client.lua with this one.
5. Keep InventoryCraftingHUD.client.lua from Monster Loot V2, as it already lists both recipes.
6. Keep Monster AI, Loot Rewards, World Anger, DataStore and other existing scripts.

COMPATIBILITY NOTES
- Uses the AnmolHasWeapon BindableFunction from InventoryCrafting as the server-only ownership check.
- CrystalBlade and AntlerCharm are already craftable and saveable in Monster Loot V2 inventory.
- Antler Charm is passively active while owned; no equip control in V1.
- Health regeneration requires a living Humanoid; it does not bring eliminated Hardcore players back.
- Requires a proper monster rig with an AnmolMonster attribute and Humanoid.
- This package hasn't been run inside Roblox Studio; test on an unpublished/private experience first.
