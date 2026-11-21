ANMOL: LIVING WORLD — UI + SETTINGS V1

SETUP
1. In Roblox Studio, create a LocalScript in StarterPlayer > StarterPlayerScripts.
2. Paste SettingsHUD.client.lua into it.
3. Do not add duplicate copies. Keep this version in a separate GitHub folder until final integration.

FEATURES
- Mobile-friendly settings panel
- Global audio toggle for the local client (SoundService.Volume)
- Local lighting shadows/post-processing toggle (not a full graphics quality setting)
- Hide/show other ScreenGui HUDs, with Settings button remaining accessible

LIMITATIONS
- Session-only: settings are not persisted between rejoins.
- Audio toggle affects all audio, not just music.
- HUD visibility may conflict with other scripts that modify ScreenGui.Enabled.
- This does not unify the many existing game HUDs into one layout.
- Roblox Studio testing and mobile layout checks are still required.
