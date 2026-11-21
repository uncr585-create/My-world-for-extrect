ANMOL: LIVING WORLD — Integration Fixes V1
==========================================
PATCHED SCRIPT:
  RandomWorldEvents.server.lua
  Install as a Script in ServerScriptService (replaces ONLY the old
  RandomWorldEvents.server.lua during FINAL Studio assembly).

FIX APPLIED:
  Living Roots event damage now invokes ServerScriptService.AnmolApplyPlayerDamage
  if ArmorService.server.lua has created that BindableFunction.
  This uses the existing server-side armor ownership/reduction checks.
  If no armor bridge is installed, it falls back to Humanoid:TakeDamage(8).
  On bridge errors, the event logs a warning and does not double-hit.

INSPECTED, NOT FIXED:
  Economy.server.lua purchases subtract coins and grant inventory in
  separate stores. They are not crash-atomic.
  Economy.server.lua saves balance snapshots and has potential stale-save
  races under simultaneous operations. Needs runtime test and a coordinated
  transaction/persistence redesign, not a superficial one-line patch.
  Daily quest claim storage and coin reward updates also need failure tests.
  Existing GUI overlap and map collision have not been tested.

KEEP EXISTING GITHUB VERSIONS:
  Upload this ZIP extracted into a new Integration_Fixes_V1 folder.
  DO NOT delete/replace old GitHub versions yet.
  At Studio assembly, install exactly ONE RandomWorldEvents.server.lua:
  use this patched one instead of the old Final Integration V1 version.
  Keep other 43 scripts from Final Integration V1 unchanged for now.

NOT TESTED:
  No Roblox Studio execution was possible. Run 2-player tests, armor tests,
  DataStore failure/rejoin tests, and inspect Studio Output before release.
