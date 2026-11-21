ANMOL: LIVING WORLD — World Healing + Nature Reaction V1

WHAT'S INCLUDED
- WorldHealing.server.lua : 6 healing plants with Hold E / mobile ProximityPrompt.
- WorldHealingHUD.client.lua : informative nature status banner.

ROBLOX STUDIO SETUP (when you have a PC)
1. Keep WorldAnger.server.lua (required). It must create:
   ReplicatedStorage.AnmolWorldState.Anger and ServerScriptService.AnmolWorldAction.
2. Keep IslandMap.server.lua (recommended) to create AnmolIslandV1.
3. Add WorldHealing.server.lua as a Script under ServerScriptService.
4. Add WorldHealingHUD.client.lua as a LocalScript under StarterPlayer > StarterPlayerScripts.
5. Start a Play test, walk to glowing plant placeholders in the forest,
   then hold E (or use the Roblox mobile ProximityPrompt button).
6. Verify World Anger drops 8 points per healing event, unless already 0.

BEHAVIOR
- 6 healable plant locations in Whispering Forest / village border.
- One successful heal reduces World Anger by 8.
- Each plant has a 55-second cooldown; no costs are charged.
- When World Anger increases: only this module's decorative vine parts
  change color. It will NOT move actual terrain or alter base geometry.
- Current V1 doesn't have healing crystals, boss pacification, or vegetation
  restoration persistence. Those require later integration/testing.

COMPATIBILITY NOTES
- Do not add a second copy of WorldAnger.server.lua.
- Works alongside the existing island map, weather, combat, and inventory code.
- WorldHeartHealed (-25) remains available in WorldAnger but isn't triggered
  by this V1. We will wire it into the heart interaction later.
- HUD may overlap earlier HUDs; adjust positioning during Studio tests.
- Scripts have not been tested in Roblox Studio. Tested logic is not guaranteed.
