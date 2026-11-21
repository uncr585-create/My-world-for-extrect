ANMOL: LIVING WORLD — QUESTS + DAILY MISSIONS V1

UPLOAD TO GITHUB: Keep all files in Quests_Daily_V1 folder for now. Delete nothing until final merge.

PC/ROBLOX STUDIO SETUP LATER:
- DailyQuests.server.lua -> ServerScriptService as Script
- DailyQuestsHUD.client.lua -> StarterPlayer/StarterPlayerScripts as LocalScript
- Economy.server.lua -> replacement for previous Economy.server.lua (do not run both)

REQUIRES:
- Latest InventoryCrafting.server.lua provides AnmolTreesCut, AnmolCrystalsMined, AnmolItemsCrafted attributes
- Achievements.server.lua provides AnmolMonsterKills
- Latest Coins + Shop + Trading V2 Economy script; updated copy in this package.

DAILY QUESTS (UTC reset):
- Cut 10 trees: 35 Coins
- Mine 5 crystals: 55 Coins
- Craft 3 items: 45 Coins
- Defeat 3 monsters: 70 Coins

Daily quests measure progress from the day's initial snapshot, not all-time totals. A quest can be claimed once per UTC day. Server checks progress. Coins are granted through an idempotent server-only quest reward function and tracked in the Economy coin profile to reduce duplicate grants across retries. The quest save is separate and can lag the coin save, but retrying an already-awarded claim won't mint it again.

NOTES:
- No Robux purchases or official Roblox badges.
- DataStore tests require a published experience and appropriate Studio access.
- If Economy profile fails to load, coin rewards do not grant.
- Some earlier scripts are untested and may require integration fixes on PC.
- Daily quests are based on UTC days, not local time zones.
- Must test load order, saving, UI overlap, quest reset, and in-game enemy kill events.
