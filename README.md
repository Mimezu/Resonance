# Resonance

![Resonance icon](Assets/ResonanceIcon.png)

Layer curated World of Warcraft sounds onto confirmed spell moments.

[Download the latest release](https://github.com/Mimezu/Resonance/releases/latest/download/Resonance.zip)

![The Resonance spell editor](.github/readme/resonance-editor.png)

## Start here

1. Type `/res` in game.
2. Choose **Resonance Subtle**, **Medium**, or **Expressive**.
3. Click a sound slot to browse and preview the library.
4. Save a Personal set when you want to keep your changes.

Resonance adds its own layers. It does not replace WoW's original spell audio.

## Spell layers

Each spell can have a sound at the moment it matters:

- **Cast** — WoW confirms the spell succeeded.
- **Casting** — a cast, channel, or empower bar begins.
- **Release** — an empowered spell completes.

Add layers for more detail, then use millisecond delays to space them out.

![Layer sounds and adjust their delays](.github/readme/sound-layers.png)

## Generic sounds

The **Generic** tab follows the character across specializations. It includes:

- Skyriding: Surge Forward, Skyward Ascent, Whirling Surge, and Aerial Halt.
- Travel: Key to the Arcantina.
- Recovery: Recuperate.
- Hearthstones: every supported Hearthstone toy or item available to that character gets its own Cast and Casting card.

## Sound sets and sharing

Sound sets are saved per character and specialization. Generic sets are saved once per character.

Export a set to share one specialization or a Generic setup. Import it on a matching specialization or Generic tab. The compact `RES3F` format keeps rule and sound IDs, layers, delays, and toggles; older `RES1` codes still import.

![Built-in presets and personal sound sets](.github/readme/sound-sets.png)

## Sound library

Open a sound slot to search, preview, and favorite sounds. Search by sound name, class, spell, encounter, or description.

![Browse and search the sound library](.github/readme/sound-picker.png)

## Install

1. Download [Resonance.zip](https://github.com/Mimezu/Resonance/releases/latest).
2. Extract the `Resonance` folder into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Enable Resonance on the character-selection AddOns screen.
4. Type `/res`.

## Commands

- `/res` — open Resonance.
- `/res help` — open help.
- `/res tutorial` — start the tutorial.
- `/res on`, `/res off`, `/res toggle` — control the addon.
- `/res test` — preview an active cue, or open the library when none is active.
- `/res solo` — toggle solo audition mode.
- `/res minimap` — show or hide the minimap button.
- `/res reset` — reset Resonance after confirmation.

Resonance is for Retail World of Warcraft.
