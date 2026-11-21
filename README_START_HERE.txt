ANMOL: LIVING WORLD — PRE-PC CODE AUDIT V2
==========================================
Static audit of Anmol_Final_Roblox_Studio_Setup_V1.zip (44 Lua files).
One definite configuration mismatch found and corrected in this ZIP:

FIXED: MonsterAI.server.lua requires
  ServerScriptService:WaitForChild("MonsterConfig")
but the prior final ZIP put MonsterConfig.lua in ReplicatedStorage.
The corrected package places MonsterConfig.lua under ServerScriptService.
Create a ModuleScript there, NOT a Script.
SoundAtmosphere.client.lua requires AnmolSoundConfig in ReplicatedStorage;
that placement remains correct.

HOW TO USE:
1. On Android extract this ZIP into a new GitHub folder:
   Pre_PC_Audit_V2
2. Do not delete any old folders yet.
3. On PC use Corrected_Studio_Source instead of previous Latest_Studio_Source.
4. For *.server.lua create Scripts in ServerScriptService.
5. For *.client.lua create LocalScripts in StarterPlayerScripts.
6. For MonsterConfig.lua create a ModuleScript in ServerScriptService.
7. For AnmolSoundConfig.lua create a ModuleScript in ReplicatedStorage.
8. Run tests in Roblox Studio and inspect Output.

WARNING: This is a source ZIP, NOT a ready-to-play Roblox place.
No Roblox Studio runtime or DataStore tests were performed. Other runtime
issues may remain. Existing coin/inventory purchases and trades are not
crash-atomic. Do not release publicly before multiplayer and save tests.
AUDIT_FINDINGS.csv has a prioritized list.
