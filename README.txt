ANMOL: LIVING WORLD — WORLD ANGER V1

On Android: save these three files to a separate GitHub repository for Anmol Living World.
On Windows/Mac Roblox Studio (later):
1. Put WorldAnger.server.lua code in a Script in ServerScriptService.
2. Put WorldAngerHUD.client.lua code in a LocalScript in StarterPlayer > StarterPlayerScripts.
3. Hit Play to see the replicated anger HUD. It starts at 20%.
4. In Studio server command bar, test:
   game.ServerScriptService.AnmolWorldAction:Fire("TreeCut")
   game.ServerScriptService.AnmolWorldAction:Fire("CrystalMined")
   game.ServerScriptService.AnmolWorldAction:Fire("Explosion")
   game.ServerScriptService.AnmolWorldAction:Fire("PlantHealed")
   game.ServerScriptService.AnmolWorldAction:Fire("WorldHeartHealed")

Important: V1 does not yet automatically detect tree chopping, mining, explosions or healing. Future resource scripts should call AnmolWorldAction on the SERVER after validating a player's action. It does not implement monsters or environment changes yet. Do not use a client RemoteEvent accepting arbitrary action names.
