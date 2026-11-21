ANMOL: LIVING WORLD — FINAL INTEGRATION V1 (UNTESTED ASSEMBLY)
==============================================================
This package is a CURATED FILE LAYOUT, not a tested, fully working Roblox place.
All .lua files are text sources. In Roblox Studio, create Script / LocalScript /
ModuleScript instances in the indicated locations and paste their source.
Do not simply drag this ZIP into Studio and expect it to run.

IMPORTANT: Do not delete any GitHub version folders now.
This ZIP selects ONE version per script filename; see SOURCE_MANIFEST.csv.
Original ZIPs remain archived. Older scripts were not removed from GitHub.

Version precedence (critical):
- InventoryCrafting.server.lua: Trading Equipment Shop V2
- Economy.server.lua: Quests Daily V1 (contains Trading V2 additions)
- EconomyHUD.client.lua: Trading Equipment Shop V2
- LootRewards.server.lua: Monster Loot V2
- MonsterAI.server.lua, AdvancedMonsters.server.lua, WorldHeartBoss.server.lua:
  Equipment Armor V1
- InventoryCraftingHUD.client.lua: Equipment Armor V1

SETUP IN ROBLOX STUDIO
1. Create a new Baseplate experience, save and publish privately.
2. For each Studio_Layout/ServerScriptService/*.server.lua create a Script
   inside ServerScriptService, then paste the contents.
3. For each Studio_Layout/StarterPlayer/StarterPlayerScripts/*.client.lua
   create a LocalScript there and paste contents.
4. For ReplicatedStorage/*.lua create ModuleScripts with matching names.
5. DO NOT install two scripts with the same purpose from earlier ZIPs.
6. Test Play (1 player), then Start Server (2-3 players).
7. Check View > Output for runtime errors; fix in small batches.
8. Verify DataStores with a private published experience and safe test data.
9. Only after tests pass, reconcile duplicates and update final GitHub branch.

KNOWN BLOCKERS / NOT YET VERIFIED
- This is a best-effort filename-based merge, NOT a semantic merge.
- Some systems may use incompatible remote names, attributes, or DataStores.
- Economy and inventory use separate DataStores: equipment purchases are not
  transactionally atomic across both stores.
- Armor and item trading interactions require regression tests.
- Tutorial and UI windows may overlap; HUD layout needs manual integration.
- Multiple map/building scripts may create overlapping objects.
- Resource nodes, combat, loot, achievements and daily quest progress require
  end-to-end testing; some quest counters may not fire as expected.
- Animation assets, sound assets and visual polish are not included.
- Not a .rbxl/.rbxlx place; no Roblox Studio runtime was available here.
- Original Roblox asset IDs and Studio properties must be configured manually.

TEST CHECKLIST
[ ] Game starts with no errors and menu appears
[ ] Map and spawn are usable
[ ] Inventory collects resources and crafts recipes
[ ] Health/hunger/stamina behave correctly
[ ] Monsters spawn, attack and drop loot
[ ] Armor reduces eligible damage
[ ] Coins/shop item purchases, item trading, team invitations work
[ ] Daily quests track and reward only once
[ ] Data saves/loads across rejoin, no loss on disconnect
[ ] Normal/Hardcore death/revive and boss progression work
[ ] Weather, events, tutorial, settings HUD do not conflict
[ ] Mobile controls, frame rate and 8-player server performance checked

SOURCE_MANIFEST.csv lists chosen source ZIP and duplicate count.
This is a preparation milestone, not a completed/tested game.
