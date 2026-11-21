ANMOL: LIVING WORLD — Building + Shelter V1 (mobile-prepared, UNTESTED)

FILES
1) Building.server.lua -> ServerScriptService as Script
2) BuildingHUD.client.lua -> StarterPlayer/StarterPlayerScripts as LocalScript
3) InventoryCrafting.server.lua -> REPLACE the previous saving-enabled
   InventoryCrafting.server.lua from Data Saving V1 (do NOT run two copies).

ALSO KEEP
- IslandMap.server.lua (map generation, buildable ground)
- IslandExpansionV2.server.lua (optional extra ground)
- Normal/Hardcore mode scripts
- Resource gathering and Inventory/Crafting UI scripts

COSTS
Wall 4 Wood + 2 Stone
Floor 3 Wood
Campfire 2 Wood + 3 Stone
Shelter 8 Wood + 4 Stone

HOW IT WORKS
- Select a piece and tap PLACE AHEAD; it places around 12 studs in
  front of your character. Rotate to choose direction.
- Server verifies player, distance, ground and materials; uses a
  server-only BindableFunction to deduct from existing persistent inventory.
- Structures are anchored placeholders; campfires give light.
- Build limit: 35 per player per server. Building is not saved yet.
- Shared Heart Village is protected from building.
- Buildings cannot overlap; some decorations and steep/raised areas
  may still need extra collision checks in Studio.

TEST IN ROBLOX STUDIO
- Use a published test experience with DataStore access appropriately configured.
- Test harvest -> place -> inventory deduction -> save -> reload.
- Test Normal/Hardcore, 2 players, mobile HUD scale, and placement boundaries.
- If all players start at the village, walk towards the forest before building.

NOTE: Importing .lua files to GitHub does not automatically install them
into Roblox. Studio setup, playtesting and publishing still required.
