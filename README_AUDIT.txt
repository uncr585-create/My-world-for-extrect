ANMOL: LIVING WORLD — INTEGRATION COMPATIBILITY AUDIT V1
========================================================
Source inspected: Anmol_Final_Integration_V1.zip
Scope: static code inspection only. No Roblox Studio execution or DataStore test.

OBSERVATIONS
- Integration package includes 44 distinct Luau scripts.
- DailyQuests.server.lua calls the AnmolQuestReward BindableFunction exposed
  by Economy.server.lua. Quest claim and coin award persistence still need
  reconnect/failure-path tests.
- InventoryCrafting.server.lua defines inventory grant and trade bridge APIs.
- Daily quest counters are set by InventoryCrafting.server.lua.
- LootRewards and Economy use AnmolMonsterDefeated event.
- World Events Living Roots damage calls Humanoid:TakeDamage directly, so it
  may bypass the armor mitigation logic. Verify before release.
- Shop item purchase involves separate coin and inventory state; a crash or
  failure between steps may cause mismatched balances/items.
- Script version selection is filename-based, not full dependency resolution.
- Studio script types and instance placement must be configured manually.
- This package does not modify or delete your GitHub files.

PRIORITY FIX PLAN
P0: Start Studio with one script per purpose; inspect Output for syntax errors.
P0: Verify currency purchase, item transfer and DataStore save/rejoin.
P0: Check map generation, spawn and initial character survival.
P1: Verify resource harvesting -> inventory -> crafting -> daily quest progress.
P1: Verify monster death -> loot -> coin reward -> achievements.
P1: Test team invites, event timing, World Anger and boss progression.
P1: Check all mobile GUI overlays and settings toggles.
P2: Add armor-aware Living Roots damage, polish audio/animations/FX.

TEST MATRIX
1) Solo new user: spawn, tutorial, resources, craft, inventory.
2) Rejoin same user: coins, items, quest progress persist.
3) Two players: team invite, coin offer, item trade; verify ownership.
4) Full inventory: reject item purchase/trade without charging or losing items.
5) Server shutdown during trade or purchase: confirm recovery/no duplication.
6) Daily reset UTC: old quest rewards cannot be claimed again.
7) 8 players: monster spawn rate, HUD readability, event performance.
8) Hardcore death: correct revive/saving behavior.
9) Low-end Android: UI, frame rate, input and sound.

NO AUTOMATIC PATCHES IN THIS AUDIT
Without running Studio, replacing working scripts with speculative fixes is
riskier than identifying dependencies. This report contains concrete test
priorities and a static checklist. Next stage is controlled fixes from errors.
