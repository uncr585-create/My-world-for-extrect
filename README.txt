ANMOL: LIVING WORLD — Game Modes V1 (Normal + Hardcore)

PC / ROBLOX STUDIO SETUP
1. ServerScriptService -> Script: paste GameModes.server.lua
2. StarterPlayer -> StarterPlayerScripts -> LocalScript:
   REPLACE old MainMenu with MainMenu_Updated.client.lua (do not keep both).
3. StarterPlayer -> StarterPlayerScripts -> LocalScript: paste GameModeHUD.client.lua
4. Keep SurvivalSystem.server.lua, SurvivalHUD.client.lua, WorldAnger scripts,
   and your other game systems. Do not run duplicate Main Menu scripts.
5. Test with at least 2 players in Studio's multiplayer test.

HOW IT WORKS
- Play chooses a mode on server, then spawns the character.
- Player spawn is manual: Players.CharacterAutoLoads = false.
- Normal: after death player is Downed for 45 seconds. Teammate can revive
  using ProximityPrompt (Hold E or mobile prompt), otherwise respawns.
- Hardcore: after death player is Downed for 20 seconds. If not revived,
  character stays eliminated for the remainder of THIS SERVER SESSION.
- Teammate revive produces a new character at standard SpawnLocation.
  Revive-at-death-position / revive animations are future features.

LIMITATIONS / TESTING
- This is untested Luau. Set up and integration testing in Roblox Studio required.
- Hardcore state is NOT persistent across rejoining another server. To enforce
  lasting permadeath, a persistent run ID / save-state policy is needed.
- Death during high network latency, late joining, other spawning code, or
  scripts that call LoadCharacter independently can conflict with this prototype.
- If you have other scripts that automatically respawn players, disable or
  integrate those scripts before testing.
- "Downed" is a revive window AFTER Humanoid death, not a crawling/ragdoll state.
- Separate Hardcore damage 1.5x and item-drop behavior are NOT implemented.
- Inventory data saving from your previous version remains separate.
- Main Menu background asset still requires a Roblox-uploaded image ID.
