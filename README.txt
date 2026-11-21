ANMOL: LIVING WORLD - Random World Events V1
Files:
- RandomWorldEvents.server.lua -> ServerScriptService (Script)
- WorldEventsHUD.client.lua -> StarterPlayer > StarterPlayerScripts (LocalScript)

Three prototype events:
1. Earthquake: mobile-friendly alert and small client camera shake
2. Crystal Storm: temporary ambient lighting change
3. Living Roots: visible roots appear near players, then inflict 8 damage if close

Event cycle: approximately every 95-210 seconds, adjusted by World Anger.
World Anger integration is optional: reads ReplicatedStorage.AnmolWorldState.Anger if available.
No older scripts need replacing. Keep this in a separate GitHub folder for now.

Not included yet: event loot rewards, advanced particle effects, sound IDs, zone-based events, terrain destruction.
Important: root damage uses Humanoid:TakeDamage directly; it does not yet use the Armor damage bridge.
Important: this is untested prototype code. Roblox Studio multiplayer and mobile testing required.
