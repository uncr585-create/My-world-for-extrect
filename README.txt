ANMOL: LIVING WORLD — Health / Hunger / Stamina V1

Files
- SurvivalSystem.server.lua  -> ServerScriptService > Script
- SurvivalHUD.client.lua     -> StarterPlayer > StarterPlayerScripts > LocalScript

V1 behavior
- Health uses Roblox Humanoid health (default 100).
- Hunger starts at 100 and decreases over time; at zero, health decreases.
- Stamina starts at 100; sprinting drains it and resting regenerates it.
- Mobile players tap the Sprint button to toggle; desktop players hold LeftShift.
- Movement and hunger/stamina are authoritative on the server.
- Stats reset on respawn in V1. Permanent death rules for Hardcore are NOT included here.
- Eating, hunger saving and game mode integration are planned for a later module.

Setup requires Roblox Studio on Windows or macOS. Android can save/edit/upload these files,
but not execute these server-side game scripts in an independent Roblox experience.

Security: never let a client send arbitrary Hunger/Stamina/Health values to the server.
