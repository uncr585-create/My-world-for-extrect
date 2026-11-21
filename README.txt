ANMOL: LIVING WORLD — PLAYER DATA SAVING V1
==========================================

FILES INCLUDED
- InventoryCrafting.server.lua  (UPDATED replacement; contains saving)
- README.txt

PURPOSE
Saves player inventory and 3 progress counters across game sessions:
  Wood, Stone, Crystal, Fiber, StoneAxe, Torch, Bandage, NoiseDecoy
  TreesCut, CrystalsMined, ItemsCrafted

IMPORTANT: REPLACE, DON'T ADD DUPLICATES
1. KEEP your original ResourceZone / IslandMap / Expansion / World Anger scripts as previously planned.
2. REPLACE the OLD InventoryCrafting.server.lua from Resource Collection V1
   with THIS InventoryCrafting.server.lua inside ServerScriptService.
3. DO NOT run both InventoryCrafting.server.lua versions at once.
4. KEEP the original InventoryCraftingHUD.client.lua in StarterPlayerScripts.
5. KEEP SurvivalSystem.server.lua and SurvivalHUD.client.lua in their places.
6. Do not add a separate DataSaving.server.lua. Saving is integrated into the replacement.

STUDIO & DATASTORE SETUP (PC LATER)
- Publish the experience before testing real DataStore persistence.
- Game Settings > Security > Enable Studio Access to API Services only for
  a test environment (prefer a separate test experience); live games have
  data store access on Roblox servers without this Studio toggle.
- Test in a published private test experience. DataStore requests can fail or
  be throttled; use Developer Console to inspect warnings.
- If a player's save cannot be loaded, the script KICKS instead of giving
  them an empty inventory and risking an overwrite.
- Autosave every ~60 seconds and PlayerRemoving / BindToClose backups.
- Temporary session lease prevents typical two-server save overwrites.
- In case of forced server crash, player may have to wait up to 180 seconds
  for a stale lease to expire before rejoining successfully.

WHAT IS NOT YET SAVED
- Hunger, stamina, health and character position (reset each session)
- Normal/Hardcore selection (current main menu is client-only)
- Boss wins, map changes, World Anger (server-wide), cosmetics, buildings
- Equipment effects or item usage (not implemented yet)

TEST CHECKLIST
A. Collect 3 Wood and 1 Crystal; open inventory and verify quantities.
B. Craft an item; verify materials decrease and crafted item increases.
C. Leave the test server and rejoin after the first session closes;
   check the same items still exist.
D. During a deliberately disabled DataStore test, check that loading fails
   safely, rather than allowing overwriting of an old save.

NOTES
- This code has NOT been run in Roblox Studio or live Roblox; verify before launch.
- DataStore name: AnmolLivingWorld_PlayerData_v1 (do not change casually).
- Counts are clamped, and inventory is capped at 100 total items on load.
- Never expose save modification remotes directly to players.
