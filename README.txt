ANMOL: LIVING WORLD — ACHIEVEMENTS + REWARDS V1

INSTALL ON PC (Roblox Studio):
1) Achievements.server.lua -> ServerScriptService (Script)
2) AchievementsHUD.client.lua -> StarterPlayer > StarterPlayerScripts (LocalScript)
3) LootRewards.server.lua -> REPLACE the older LootRewards.server.lua in ServerScriptService
4) Keep the MOST RECENT InventoryCrafting.server.lua (from Loot + Rewards V1); do not add a second copy.

Achievements and cosmetic title rewards:
- 10 Trees: Forest Wanderer
- 50 Trees: Woodland Keeper
- 5 Crystals: Crystal Seeker
- 25 Crystals: Crystal Expert
- 3 Crafts: Village Crafter
- 15 Crafts: Master Crafter
- 1 Monster: First Defender
- 10 Monsters: Monster Hunter
- 30 Monsters: Shadow Legend

Reads the saved inventory progress attributes AnmolTreesCut, AnmolCrystalsMined,
and AnmolItemsCrafted. Monster kills and achievement unlocks save in a
separate Roblox DataStore: AnmolLivingWorld_Achievements_v1.
When an achievement unlocks, a notification appears and player attribute
AnmolTitle is set to the most recently awarded title.

IMPORTANT:
- If Roblox DataStore loading fails, achievements may display for that session
  but saving is skipped, to avoid overwriting existing progress.
- This is a prototype. Roblox Studio/published experience testing is required.
- These are in-game cosmetic title labels; NOT official Roblox badges.
- Already unlocked titles will not trigger another toast on rejoin.
- No paid items, Robux rewards, or premium access.
- Copy/paste .lua files into the correct Roblox Studio Script objects.
- On mobile, extract ZIP and upload source .lua files to GitHub for later setup.
