ANMOL: LIVING WORLD — ROBLOX STUDIO SETUP GUIDE V1
===================================================
This is a SOURCE PACKAGE, NOT a playable .rbxl or .rbxlx file.
44 Luau source files are organized by intended Roblox Studio service.
The scripts have NOT been tested in Roblox Studio. Some systems may conflict.

WHAT TO KEEP ON GITHUB
- Keep ALL your existing historical version folders. Delete NOTHING yet.
- Upload this extracted ZIP into a NEW folder named Final_Studio_Setup_V1.
- The 'Latest_Studio_Source' folder contains 44 selected scripts including:
  RandomWorldEvents.server.lua from Integration Fixes V1
  Economy.server.lua from Coin Saving Safety V2
  InventoryCrafting.server.lua from Trading Inventory Safety V2
- Source selection is based on filename and known patches, not full runtime testing.

PC INSTALLATION (ROBLOX STUDIO)
1. Install Roblox Studio and sign into your Roblox account.
2. Create a NEW Baseplate place; File > Publish to Roblox (keep private).
3. Open View > Explorer, Properties and Output.
4. For every file in Latest_Studio_Source/ServerScriptService:
   Create a Script under ServerScriptService. Name it exactly as the filename
   (without .lua if desired, but keep unique). Paste the entire file contents.
5. For every file in Latest_Studio_Source/StarterPlayer/StarterPlayerScripts:
   Create a LocalScript under StarterPlayer > StarterPlayerScripts.
   Paste its contents.
6. For every file in Latest_Studio_Source/ReplicatedStorage:
   Create a ModuleScript under ReplicatedStorage, paste contents and name it
   according to the module's expected require() reference.
7. Save and run Play. Read every red error in Output.
8. Add/fix scripts in small groups. Do not assume all 44 will work together.
9. For multiplayer: Test > Start with 2 players (UI may vary by Studio version).
10. For DataStore tests: publish private experience and configure Studio API
    access only in a dedicated test place; avoid overwriting production data.
11. Test on Android Roblox client after Studio issues are fixed.
12. Only after all tests pass should you decide which historical files to archive.

IMPORTANT SAFETY / LIMITATIONS
- Roblox Studio cannot be run on Android; PC or Mac is required for assembly.
- ZIP files cannot be imported as an instantly playable Roblox experience.
- This is not a complete map/asset pack. Some code may generate basic world
  geometry, but animations, sound assets, UI positioning, and balance remain.
- Shop coins and inventory use separate DataStores; purchases are not fully
  crash-atomic. Two-player item trades also lack atomic multi-profile saves.
- No server crash / reconnect / exploit-resistance guarantees are provided.
- Don't publish the game publicly until data loss and duplication tests pass.
- If Studio reports errors, share Output text and the affected script for fixes.

FIRST PLAY TEST CHECKLIST
[ ] No red errors in Output at startup
[ ] Island and spawn appear, no overlapping map pieces
[ ] Health/hunger/stamina change normally
[ ] Harvesting grants inventory resources
[ ] Crafting works and costs resources
[ ] Monster attacks, drops, coins and achievements work
[ ] Quest progress and claims work once only
[ ] Coins, items and progress persist after rejoin
[ ] Full inventory cannot receive purchased or traded items
[ ] Teams, trades, death, boss and events work with 2+ players
[ ] HUD controls work on mobile without overlapping
[ ] Hardcore and normal mode have expected death behavior

ORDER OF DEBUGGING
A. Island/Spawn and Player Survival
B. Inventory, Resources, Crafting
C. Combat, Monsters, Loot, Armor
D. Coins, Shop, Trading, Quests, DataStore
E. Teams, Events, Boss, Tutorial, HUD, Settings
F. Mobile performance and multiplayer stress test

This package is an organizational milestone, not a tested final game.
