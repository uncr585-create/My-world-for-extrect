ANMOL LIVING WORLD — COINS + SHOP + TRADING V1

FILES (save all in a versioned GitHub folder; do NOT delete originals yet):
- Economy.server.lua => ServerScriptService / Script
- EconomyHUD.client.lua => StarterPlayer / StarterPlayerScripts / LocalScript

FEATURES:
- Saved coins in separate DataStore AnmolLivingWorld_Coins_v1
- Monsters grant coins through AnmolMonsterDefeated server BindableEvent:
    RootStalker 12; WhisperShade 18; HollowDeer 28; CrystalBurrower 40
- Village Shop automatically spawns next to Heart Village at (-215,4,20).
  Use proximity prompt to open. Buy single-unit resources; these use the inventory
  server-only AnmolGrantLoot bridge in the latest inventory code.
- Coins trading: player types recipient's exact username and amount, recipient
  must accept. Must be in same server within 18 studs; max 1000 coins per offer.
- Mobile-friendly Coins HUD, Shop, Trading popup.

DEPENDENCIES:
- Latest InventoryCrafting.server.lua from Equipment + Armor V1, which creates
  ServerScriptService.AnmolGrantLoot (required to buy shop resource bundles).
- Achievements.server.lua creates AnmolMonsterDefeated, and the *latest* 
  LootRewards.server.lua fires it on server-attributed monster deaths.
  Both scripts MUST be installed for coins from kills.
- IslandMap.server.lua places Heart Village in the same location.

IMPORTANT:
- Coin-only trading. Item-to-item trades will be added after inventory integration.
- DataStore access needs a published Roblox experience and Studio API setup.
- Separate inventory/coin DataStores are NOT an atomic transaction. Test purchases
  and disconnects carefully before releasing publicly.
- Session lease prevents simultaneous editing across servers in normal cases,
  but network/DataStore failures still need production testing.
- Do not run two Economy.server.lua copies.
- This has not yet been verified in Roblox Studio; do not guarantee functionality.
