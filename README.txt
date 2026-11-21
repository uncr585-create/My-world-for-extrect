ANMOL: LIVING WORLD — LOOT + REWARDS V1

INSTALL (when you have Roblox Studio):
1. Replace the OLD Combat.server.lua in ServerScriptService with this version.
2. Replace the OLD InventoryCrafting.server.lua with this version. It is based on Weapons + Combat V1 and keeps the existing crafting, saving, building and resource features.
3. Add LootRewards.server.lua as a NEW Script in ServerScriptService.
4. Keep MonsterAI.server.lua and MonsterConfig.lua from Monster AI V1.
5. Do NOT run old and new same-name inventory or combat scripts simultaneously.

REWARDS:
- Root Stalker: 2–4 Wood, 1–2 Fiber, 8% chance of 1 Crystal.
- Whisper Shade: 1–3 Stone, 1–2 Fiber, 22% chance of 1 Crystal.
- Last player to land a valid server-checked hit receives the reward if the monster dies within 25 seconds.
- Items are added through a server-only BindableFunction and are included in saved inventory.
- Inventory max is still 100 total items. Overflow rewards are not granted.
- If nobody attacked the monster, there is no loot reward.

NOT INCLUDED:
- Physical dropped loot bags or sharing rewards across the whole party.
- Boss rewards (boss currently uses separate health system, not a monster Humanoid).
- Actual Roblox Studio gameplay testing.

NOTE: Rewards require both the revised Combat and InventoryCrafting scripts.
DataStore permissions and UI overlap should be tested in Roblox Studio.
