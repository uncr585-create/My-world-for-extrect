ANMOL: LIVING WORLD — Dynamic Weather + Day/Night V1

FEATURES
- 12 real minutes = one 24-hour in-game cycle
- Clear, Rain, Fog, Thunderstorm (weather state + sky/cloud/fog effects)
- Higher World Anger increases Fog and Thunderstorm probability
- Weather + local game time mobile-friendly HUD
- Thunderstorm HUD warning (no screen flashing)

IMPORTANT LIMITATIONS
- Rain is atmospheric weather state only; falling raindrop particles and sounds are NOT yet implemented.
- Monsters, stamina, water, shelter and crop effects are NOT yet linked to the weather.
- These scripts have not been run in Roblox Studio yet.

ROBLOX STUDIO SETUP (when PC available)
1. Keep existing WorldAnger.server.lua in ServerScriptService.
2. Put WeatherDayNight.server.lua in ServerScriptService as a Script.
3. Put WeatherHUD.client.lua in StarterPlayer > StarterPlayerScripts as a LocalScript.
4. Test in Play mode; watch Weather and TimeOfDayHours under ReplicatedStorage/AnmolWorldState.
5. DO NOT install multiple copies of weather/time scripts. If you add other day/night scripts later, disable those or they will fight over Lighting.ClockTime.
6. Existing World Anger V1 is REQUIRED. The weather script waits up to 30s for it.

ANDROID PREP
Extract this ZIP and upload all 3 files to your Anmol Living World GitHub repository.
Upload the individual .lua files; keep the ZIP as a backup if you want.

SERVER TEST (Studio Command Bar when running as server)
game.ServerScriptService.AnmolWorldAction:Fire("Explosion")

Not an executable Android APK or a Roblox experience until integrated in Studio.
