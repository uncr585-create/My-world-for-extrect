ANMOL: LIVING WORLD — Trading V2 + Equipment Shop

IMPORTANT: These are UPDATED copies of existing Economy/Inventory scripts, NOT additive copies.
Keep the original archives in GitHub for now, as requested. When setting up Studio, only ONE active Script per role.

Contents:
- Economy.server.lua — REPLACE Coins Shop Trading V1 Economy.server.lua
- EconomyHUD.client.lua — REPLACE Coins Shop Trading V1 HUD
- InventoryCrafting.server.lua — REPLACE the InventoryCrafting.server.lua version from Equipment Armor V1 (preserves armor, crafted items and DataStore)

In Studio:
  Economy.server.lua -> ServerScriptService > Script
  InventoryCrafting.server.lua -> ServerScriptService > Script
  EconomyHUD.client.lua -> StarterPlayer > StarterPlayerScripts > LocalScript

Features:
- 5 shop equipment items: Stone Axe 90, Sword 180, Leaf Vest 125, Stone Armor 350, Crystal Armor 950 coins.
- Existing material bundles and coin trading remain.
- Item trade: one-way transfer to nearby player after recipient Accept.
- Server checks item type, count (1-10), inventory ownership/capacity and distance.
- Trade requests expire after 30 seconds; cooldown and recipient confirmation.

Requirements / limitations:
- Shop purchases require standing near Heart Village Trader.
- Buyer balance must be loaded from the existing Economy DataStore.
- Both players must have loaded inventories.
- Shop purchase uses two independent saved profiles (coins/inventory): it isn't an atomic cross-DataStore transaction; data loss or rejoin at wrong time could yield inconsistent results. Test and improve save recovery before releasing to public players.
- No Robux involved.
- Item trade is an offer of items from sender to recipient, not a simultaneous two-sided exchange; do not present it as swap trading.
- Existing equipped armor might remain active until refreshed after trading it away; test equipped-item state.
- Not tested in Roblox Studio.
