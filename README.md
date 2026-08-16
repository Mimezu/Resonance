# Resonance 1.9.0

Resonance adds configurable, event-driven spell ambience to every Retail specialization while leaving Blizzard's original spell audio untouched.

## Design constraints

- Uses curated Blizzard spell-file IDs; no audio assets are bundled.
- Uses the SFX channel by default and never changes sound CVars.
- No combat-log listener, polling loop, target inspection, protected actions, or gameplay automation.
- Hero trees color important moments when their player-side cast or aura can be verified. Observable Apex talents have explicit capability-gated rules; pet-only and automatic effects are not given fake triggers.
- Aura data is player-only, delta-driven, guarded for secret values, and fails closed.
- Every gameplay moment has two optional layers, independent 0–5000 ms delays, and individual previews.
- Every real spell also exposes an optional Casting moment that fires once when its cast, channel, or empower bar starts. Its added layers stop with the cast bar using a short 80 ms fade, and delayed layers are cancelled when a cast ends early.
- The sound picker includes verified live and legacy class spells, martial effects, and iconic encounter one-shots; retired abilities are labeled Legacy.
- A floating sound picker organizes assets by texture, including Physical, Poison & Toxin, and Metal & Machines alongside the magical families.
- Search scans labels and provenance across the complete library, so boss, raid, dungeon, class, and spell names remain easy to find as the catalog grows.
- Sound sets are saved per character and specialization. Every spec receives protected, hand-curated `Resonance Subtle`, `Resonance Medium`, and `Resonance Expressive` presets with distinct sound choices, delays, layers, and enabled moments; personal sets can still be created, loaded, overwritten, or deleted.
- Personal sets carry explicit schema, rule-catalog and sound-catalog versions. Stable rule IDs and numeric FileDataIDs survive category/label changes; ordered aliases and remaps adapt retired identifiers, missing sounds are preserved but fail closed, and new rules stay disabled in older personal mixes until chosen.
- The developer-facing migration rules are documented in `COMPATIBILITY.md` so future releases keep this guarantee instead of relying on convention.
- Presets change the actual enabled moments. There is no global density filter, priority threshold, or sound budget silently suppressing an explicitly enabled spell.
- The compact editor uses real specialization icons, builds only the selected spec's controls, and places every moment for a spell horizontally on one card.
- Resonance windows use slim purple/teal scrollbars with wheel, track-click, and drag support instead of Blizzard's large arrow controls.
- Hero-tree names and capability gates come from the active trait subtree, preventing inactive hero talents from leaking into the selected build.
- Apex detection retains both a selected talent's passive/base identity and any active replacement spell, covering multi-rank replacement talents such as Merithra's Blessing.
- The temporary Misc family is retired. Six user-selected legacy accents were canonized into Arcane and Bronze; the other fourteen were removed.
- The normal catalog is built for game-feel: compact casts, impacts, tails, sparks, physical hits, poison textures, mechanisms, and encounter accents that tolerate repetition.
- Large boss signatures, recognizable machines, creature calls, and the six user-retained UI accents live in **Novelty & Fun**, away from normal spell-layer browsing.
- A separate **Boss Voices & Yells** library contains 115 English raid-boss dialogue, battle shout, scream, roar, and death-cry files from Battle for Azeroth onward. Each retained file was extracted from the local 12.1 CASC, decoded, verified to contain an audible signal, and measured at five seconds or less. Encrypted, missing, silent, and longer candidates are kept out of the live picker.
- The encounter library includes decoded launch-raid accents from The Voidspire, The Dreamrift, and March on Quel'Danas, plus all three playable Nexus Daggers variants from Nexus-Princess Ky'veza.
- Real player-class assets use `Class — Spell · Moment` labels even when an encounter reuses the same sound. Provenance stays in the searchable description.
- No new dialogue, music, ambience, footsteps, or persistent loops are imported. Two previously exposed non-transient assets remain isolated in Novelty for saved-set compatibility.
- Fine-grained families add sparkles, twinkles, chimes, crystal echoes/charges, embers, dust and short whooshes.
- Temporary `Sound sorting mode` can move sounds between families, mark sounds for deletion, and save a complete draft in `ResonanceDB.categoryExport` for Codex to canonize later.
- Solo audition mode temporarily routes Resonance to Dialog while muting SFX, music, and ambience, then restores the previous mix on disable or normal logout/reload.
- Preservation includes a delayed bronze Echo afterimage, nature accents for Verdant Embrace and Emerald Blossom, separate deep Fire Breath charge/release cues, and a watery-nature Merithra's Blessing cast phrase.

## Commands

- `/res` or `/res options` — open Settings.
- `/res on`, `/res off`, `/res toggle` — master control.
- `/res test` — preview the current major cue.
- `/res audit` — print detected spec, hero tree, Apex and rule count.
- `/res solo` — toggle temporary solo audition mode.
- `/res minimap` — show or hide the minimap button.
- `/res refresh` — rescan the live talent configuration.
- `/res reset` — reset configuration after confirmation.

## First test

Enable Resonance for the character, log in, run `/res audit`, open a sound swatch, audition the catalog, then test at a target dummy before entering group content. Diagnostic messages can be enabled temporarily from the standalone `/res` window.
