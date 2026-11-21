ANMOL: LIVING WORLD — World Heart Boss V1

CONTENTS:
- WorldHeartBoss.server.lua
- WorldHeartBossHUD.client.lua

INSTALL IN ROBLOX STUDIO (later, when PC is available):
1) Keep IslandMap.server.lua and IslandExpansionV2.server.lua in ServerScriptService.
2) Put WorldHeartBoss.server.lua in ServerScriptService as a Script.
3) Put WorldHeartBossHUD.client.lua in StarterPlayer > StarterPlayerScripts as a LocalScript.
4) Keep WorldAnger.server.lua in ServerScriptService for anger integration.
5) Press Play in Studio. Travel to World Heart area (-116, 485) on the island.
6) Start battle at GREEN pedestal by the arena entrance.
7) Channel Strike at BLUE crystals around guardian. Dodge RED circle warnings.
8) Boss has 3 phases (100-67%, 66-34%, 33-0%). Higher World Anger increases attack damage.
9) On boss defeat, WorldHeartHealed server event lowers Anger by 25.
10) Boss resets 18 seconds after win/fail. Trial fails after 150 seconds or 45 seconds without any strike.

NOTES:
- Boss uses placeholder glowing part, not final animated monster model.
- No sword damage yet: interact with blue strike crystals to damage the boss.
- All strikes, health changes, and boss damage are checked on the server.
- No loot rewards, boss save data, or Hardcore/Normal split yet.
- This code has not been tested inside Roblox Studio; fixes may be needed.
- Avoid placing another script that builds/controls a different World Heart Boss simultaneously.
- Server script waits for the map expansion; Studio startup order does not need to be manual.
