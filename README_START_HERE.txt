ANMOL: LIVING WORLD — Trading + Inventory Safety V2
====================================================
TARGETED PATCH: InventoryCrafting.server.lua
Studio destination: ServerScriptService as a Script.
Use this file INSTEAD OF the InventoryCrafting.server.lua from
Final Integration V1. Do not run both scripts together.

PATCHED:
- Inventory save now compares the saved snapshot against the latest
  in-memory inventory and crafting progress before clearing dirty.
  This avoids falsely declaring newer unsaved changes as persisted.
- Server loot grants now reject requests during an active save, rather
  than allowing grants to race the save snapshot.
- Existing trade bridge still validates item ownership, amounts,
  inventory capacity and both players' session availability.
- Existing transfer mutation remains no-yield between subtract/add.

NOT FULLY SOLVED:
- Two player inventory profiles are saved separately; server crashes can
  lose or duplicate transferred items after a trade.
- Loot grants rejected during a save are not automatically retried by
  this script; callers should implement safe retry/queue behavior.
- Inventory save's lease handling, simultaneous player exits, and
  purchase interactions require live Studio tests.
- Coins and inventory are separate DataStores, so purchases are not
  crash-atomic. No cross-store transactional guarantee is provided.
- Do not claim this is a fully duplication-proof trade system.

ANDROID / GITHUB:
Extract ZIP and upload into a NEW folder Trading_Inventory_Safety_V2.
Do not delete old GitHub folders yet.
During final Studio assembly, choose exactly one inventory script:
the updated script in this ZIP.

TESTS:
1. Trade item with two players and verify quantities.
2. Try full receiver inventory, invalid item and amount.
3. Trade and disconnect/rejoin quickly.
4. Trigger loot grants during autosave.
5. Craft while autosave is in flight.
6. Purchase equipment, reconnect, check both inventory and coins.
7. Verify all errors in Roblox Studio Output.
This is static patching, not Studio-tested.
