# Saved-set compatibility contract

Resonance treats personal sound sets as user data, not as disposable copies of a built-in preset.

## Stable identities

- Rule IDs are permanent. Never reuse a retired rule ID for a different spell or moment.
- Sounds are stored by numeric FileDataID, not by display label or category.
- Category IDs are stable even when their displayed names change.

Renames and replacements belong in `RULE_ID_ALIASES`, `SOUND_ID_REMAP`, or `CATEGORY_ID_ALIASES` in `Bootstrap.lua`. Old mappings must remain there permanently so a user can skip several addon releases and still migrate directly.

## Personal sets versus built-in presets

- A personal set is a frozen snapshot of every current rule toggle, layer, sound and delay for one character and specialization.
- Rules introduced by a later addon version default to disabled in an older personal set.
- Built-in Subtle, Medium and Expressive presets are versioned separately and may be refreshed by an addon update.
- Editing a built-in preset detaches the working set, so an update does not overwrite those edits.

## Removed content

- A removed sound remains stored in the set with its FileDataID and last known label. It is marked missing and skipped safely during playback.
- If a replacement exists, add a permanent `SOUND_ID_REMAP` entry. The next load adapts the set automatically.
- A retired rule remains preserved in the saved set and is reported by `/res audit`. If it has a successor, add a permanent `RULE_ID_ALIASES` entry.
- An invalid or retired category assignment is preserved in `legacyCategoryDraft`, while the sound returns to its canonical category.

## Schema upgrades

Account migrations run in numeric order through `ACCOUNT_MIGRATIONS`. Character/spec migrations run through `CHARACTER_STORE_MIGRATIONS`. Every schema change must:

1. Increment the corresponding database version.
2. Add an idempotent migration at that exact version.
3. Preserve unknown fields and retired references unless they are demonstrably unsafe.
4. Advance the stored version only after the migration finishes.
5. Test a direct upgrade from an old SavedVariables snapshot, not only from the immediately previous release.

If an existing rule's built-in enabled state or layer defaults change, the release migration must materialize the old effective value before installing the new default. Do not ask an old sparse personal set to infer history from the current rule table; ambiguous legacy values must fail closed.

## Shared transfer codes

- `RES1` exports are data-only, versioned and checksummed. They never contain executable Lua.
- A transfer freezes every current toggle, layer count, FileDataID/SoundKit ID, sound kind, last-known label and delay for exactly one specialization.
- Imports preserve unknown rules and missing sounds, then run the same aliases, sound remaps and normalization used by SavedVariables upgrades.
- Importing never overwrites or auto-loads a set. Name collisions create an `(Imported)` copy.
- Future codecs may introduce a new prefix, but the addon must retain a permanent reader for `RES1` just as it retains old database migrations.

The addon folder and SavedVariables are separate. Updating the addon preserves sets in `WTF`; reinstalling Windows, deleting `WTF`, or moving to another computer still requires a backup or an exported sound-set code.
