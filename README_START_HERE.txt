ANMOL: LIVING WORLD — FINAL PC INSTALLATION PREPARATION V1
===========================================================
USE AS YOUR LATEST SOURCE:
  Anmol_Pre_PC_Code_Audit_V2.zip (44 scripts)
This ZIP is a checklist and setup plan, NOT a new gameplay build.
Do NOT delete any older GitHub folders now.

BEFORE PC
[ ] Keep the Pre_PC_Audit_V2 ZIP and its extracted files safe on GitHub.
[ ] Keep old ZIP/version folders for backup.
[ ] Have Roblox account access ready. Never share passwords or session cookies.
[ ] Plan to use a Windows PC or Mac with Roblox Studio installed.

ON PC: MINIMAL INSTALL SEQUENCE
1. Open Roblox Studio. Make a NEW private Baseplate experience.
2. Enable Explorer, Properties, Output windows.
3. Copy scripts from Corrected_Studio_Source in Pre_PC_Audit_V2.
   - ServerScriptService/*.server.lua => Script in ServerScriptService
   - ServerScriptService/MonsterConfig.lua => ModuleScript in ServerScriptService
   - StarterPlayer/StarterPlayerScripts/*.client.lua => LocalScript there
   - ReplicatedStorage/AnmolSoundConfig.lua => ModuleScript in ReplicatedStorage
   Each file's CONTENT goes in a Studio script instance; ZIP itself is not
   directly executable as a Roblox experience.
4. Add scripts incrementally, not all at once. Start with map and spawn,
   then survival, then inventory/resources, then monsters/combat, then economy.
5. Click Play. If a red Output error appears, record its exact text and script.
6. Save privately. For persistent data tests, publish private experience,
   use a dedicated test place and only enable Studio API access when needed.
7. Test with 2 clients for teams and trading. Test on mobile separately.

FIRST 10 TESTS
[ ] Spawn and island generated correctly, no infinite waits
[ ] Survival HUD and stats change
[ ] Resource collection changes inventory
[ ] Crafting consumes materials correctly
[ ] Monsters attack, die, and grant loot
[ ] Armor mitigates monster and event damage
[ ] Shop purchase correctly changes coins and inventory
[ ] Daily quest progress, claim, and UTC reset
[ ] Two-player trade and team invite
[ ] Rejoin: items, coins, quests, and achievements persist

STOP CONDITIONS — DO NOT PUBLISH PUBLICLY IF:
- Any data loss, duplicate item exploit, or negative balance occurs.
- Output has startup errors, infinite yields or invalid remotes.
- UI blocks movement on phone or player spawn is broken.
- Buying equipment charges coins without awarding items.

KNOWN OPEN RISKS
- Cross-DataStore purchases/trades are not crash-atomic.
- Multiple HUDs may overlap and maps may create conflicting objects.
- Static audit does not guarantee scripts compile or run in Studio.
- MonsterConfig placement was corrected in Pre_PC_Audit_V2.
- Some script startup ordering and remote dependencies need verification.

SEND BACK FOR FIXES
- Screenshot or copy of Roblox Studio Output (first red error)
- Script name, approximate line number
- What you clicked / did right before error
- Whether testing with one or two players

No deletion or cleanup of older GitHub versions is requested yet.
