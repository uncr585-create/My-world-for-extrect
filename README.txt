ANMOL: LIVING WORLD — RESOURCE COLLECTION V1

IMPORTANT: This pack UPDATES InventoryCrafting.server.lua from the earlier Inventory + Crafting V1 ZIP.
Do not run both versions simultaneously (they register the same remote handlers and node prompts).

LATER ROBLOX STUDIO INSTALL:
1. Keep the World Anger V1 server script in ServerScriptService.
2. REPLACE your old InventoryCrafting.server.lua with the new file included here.
3. Add ResourceZone.server.lua as a separate Script in ServerScriptService.
4. Keep your original InventoryCraftingHUD.client.lua in StarterPlayer > StarterPlayerScripts.
5. Do NOT enable the old DemoResourceNodes.server.lua; this pack has its own test zone.
6. Add a SpawnLocation and flat ground for testing. Then press Play in Studio.

HOW IT WORKS:
- 11 placeholder nodes spawn around the SpawnLocation (3 Wood, 3 Stone, 2 Crystal, 3 Fiber).
- Players hold the ProximityPrompt on each node to collect items.
- Existing server inventory handles item amounts, full backpack and 15-second cooldown.
- Successful Wood collection fires AnmolWorldAction(TreeCut): +3 anger.
- Successful Crystal collection fires AnmolWorldAction(CrystalMined): +5 anger.
- Stone and Fiber currently do not change World Anger.
- Prompts are touch-friendly for Android players.

LIMITATIONS:
- Nodes are intentionally simple placeholder geometry, not finished forest models.
- Pickups are prompt-based, not axe animations or mining swings.
- The model remains visible during cooldown; its prompt temporarily disables.
- No inventory persistence, drops, or sophisticated multiplayer resource balancing yet.
- Studio test is still necessary. Files alone do not publish a Roblox experience.
