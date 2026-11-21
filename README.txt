ANMOL: LIVING WORLD - INVENTORY + CRAFTING V1

INSTALL IN ROBLOX STUDIO (Windows/Mac, later):
1) Add InventoryCrafting.server.lua as Script inside ServerScriptService.
2) Add InventoryCraftingHUD.client.lua as LocalScript inside StarterPlayer > StarterPlayerScripts.
3) Add collectable Parts or Models in Workspace. Tag each with CollectionService tag:
   AnmolResourceNode
   Set Attribute ResourceType (string) to one of Wood / Stone / Crystal / Fiber.
   Optional RespawnSeconds (number) default 12, min 3, max 120.
4) For quick testing without building assets, optionally install DemoResourceNodes.server.lua
   into ServerScriptService and set ENABLE_DEMO_NODES = true.

HOW IT WORKS:
- Server alone owns item counts; maximum 100 total items per player.
- Prompt collecting gives Wood +3 / Stone +2 / Crystal +1 / Fiber +2.
- Stone Axe: 3 Wood + 2 Stone
- Torch: 2 Wood + 1 Fiber
- Bandage: 3 Fiber
- Noise Decoy: 2 Stone + 1 Crystal
- Tap 🎒 INVENTORY to view inventory and craft.
- Nodes have shared depletion / respawn, and server validates distance.

IMPORTANT LIMITATIONS:
- Crafted items currently count in inventory; no equipped tools, light effects,
  healing or noise effects until future gameplay systems are connected.
- No DataStore persistence yet; inventory resets when a player leaves.
- This prototype does NOT alter the existing survival HUD or World Anger scripts.
- Studio installation / in-game testing has not happened yet.
- A ZIP is for backup. Extract .lua files before installing them in Studio.
