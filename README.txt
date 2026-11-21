ANMOL: LIVING WORLD — EQUIPMENT + ARMOR V1

New mechanics:
- Leaf Vest: craft 8 Fiber + 3 Wood, blocks 10% monster/boss damage.
- Stone Armor: craft 12 Stone + 4 Fiber, blocks 20% damage.
- Crystal Armor: craft 6 Crystal + 8 Stone + 1 Crystal Shard, blocks 35% damage.
- Equip only one armor at a time via mobile-friendly Armor HUD.
- SERVER verifies owned item before equipping and on every attack.
- Damage mitigation applies to the monsters and World Heart Boss updated here.
- Starvation, poison and other damage paths are NOT reduced by armor yet.

INSTALL IN ROBLOX STUDIO (NOT DELTA):
ServerScriptService Scripts:
  REPLACE InventoryCrafting.server.lua (latest replacement with saved inventory)
  ADD ArmorService.server.lua
  REPLACE MonsterAI.server.lua (Root Stalker + Whisper Shade)
  REPLACE AdvancedMonsters.server.lua (Hollow Deer + Burrower)
  REPLACE WorldHeartBoss.server.lua
StarterPlayer > StarterPlayerScripts LocalScripts:
  REPLACE InventoryCraftingHUD.client.lua
  ADD ArmorHUD.client.lua

IMPORTANT:
- Do not keep duplicate versions of same-name scripts.
- Keep existing Combat, Loot, Crafting, WorldAnger, GameModes and Weather scripts.
- Equipped armor selection persists for this SERVER SESSION only; crafted armor item
  is persisted via current inventory DataStore. Re-equip after rejoining.
- If an ArmorService Script is absent, updated AI falls back to regular damage.
- All gameplay is UNTESTED in Roblox Studio. Test with one player, then multiplayer.
- Studio DataStore testing requires a published experience and appropriate API settings.
