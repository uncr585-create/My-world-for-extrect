ANMOL: LIVING WORLD — Island Expansion V2

CONTENTS
- IslandExpansionV2.server.lua (new, additive server script)

WHAT IT ADDS
- Crystal Depths: glowing pillars, 5 crystals and 3 stone resource nodes
- Toxic Marsh: glowing decorative pools, 5 fiber and 3 wood resource nodes
- World Heart: central glowing heart and boss-arena placeholder
- Traversable ground and roads connecting these areas to the V1 island
- Four additional monster spawn markers; V1 AI decides if/when it uses them

IMPORTANT SETUP WHEN YOU HAVE ROBLOX STUDIO
1. Keep IslandMap.server.lua (V1) in ServerScriptService.
2. Add IslandExpansionV2.server.lua as a SECOND Script in ServerScriptService.
3. Keep MonsterAI.server.lua, MonsterConfig.lua, InventoryCrafting.server.lua etc. in their specified locations.
4. Do NOT enable DemoResourceNodes.server.lua / ResourceZone.server.lua along with the V1 map; those create duplicate demo nodes.
5. Delete the default Baseplate if it obstructs your island (your V1 island already makes its own floor).
6. Play-test for collision, pathfinding, resource pickups, and spawn safety.

COMPATIBILITY
This V2 waits for Workspace.AnmolIslandV1 (V1 map) before generating. It is an extension, not a replacement.
Resources use AnmolResourceNode tags and ResourceType attributes as the existing inventory collector expects.
The arena is decorative for now: no boss damage, loot, or scripted battle. The toxic puddles are also decorative.

KNOWN LIMITATIONS
- These are blockout/prototype shapes, not detailed terrain or finished models.
- No guaranteed enemy logic for Crystal Burrower or Heart Guardian yet.
- Existing Monster AI V1 may spawn basic enemies at the new markers.
- Scripts have NOT been executed or tested in Roblox Studio.
- To use from Android, extract ZIP and upload .lua + README to GitHub as files.
