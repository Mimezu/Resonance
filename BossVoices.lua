local _, ns = ...

-- English encounter voice one-shots verified against this Retail client's local CASC payload.
-- Labels stay source-first because recognition and provenance are the purpose
-- of this optional library. Every retained entry decodes, contains audible signal, and is at most five seconds.\n-- Resonance bundles no audio files.
ns.BossVoiceCatalog = {
    -- Battle for Azeroth · Uldir
    { id=1990727, category="voice", label="Taloc — Encounter line II", detail="Uldir · Battle for Azeroth" },
    { id=2069374, category="voice", label="Taloc — Battle shout", detail="Uldir · Titan construct combat voice" },
    { id=2069381, category="voice", label="Taloc — Death", detail="Uldir · Titan construct death voice" },
    { id=1994579, category="voice", label="MOTHER — Facility warning I", detail="Uldir · Battle for Azeroth" },
    { id=1994580, category="voice", label="MOTHER — Facility warning II", detail="Uldir · Battle for Azeroth" },
    { id=1994581, category="voice", label="MOTHER — Facility warning III", detail="Uldir · Battle for Azeroth" },
    { id=1999526, category="voice", label="Zul — Dark prophecy III", detail="Uldir · Battle for Azeroth" },

    -- Battle for Azeroth · Battle of Dazar'alor
    { id=2400026, category="voice", label="Frida Ironbellows — Light's champion II", detail="Champions of the Light · Battle of Dazar'alor" },
    { id=2400027, category="voice", label="Frida Ironbellows — Light's champion III", detail="Champions of the Light · Battle of Dazar'alor" },
    { id=2400028, category="voice", label="Frida Ironbellows — Light's champion IV", detail="Champions of the Light · Battle of Dazar'alor" },
    { id=2445955, category="voice", label="Grong — Distant roar I", detail="Battle of Dazar'alor · creature signature" },
    { id=2445956, category="voice", label="Grong — Distant roar II", detail="Battle of Dazar'alor · creature signature" },
    { id=2445949, category="voice", label="Grong the Revenant — Battle roar I", detail="Battle of Dazar'alor · creature signature" },
    { id=2445952, category="voice", label="Grong the Revenant — Battle roar II", detail="Battle of Dazar'alor · creature signature" },
    { id=2400236, category="voice", label="Mestrah — Jadefire call I", detail="Jadefire Masters · Battle of Dazar'alor" },
    { id=2400237, category="voice", label="Mestrah — Jadefire call II", detail="Jadefire Masters · Battle of Dazar'alor" },
    { id=2400238, category="voice", label="Mestrah — Jadefire call III", detail="Jadefire Masters · Battle of Dazar'alor" },
    { id=2400191, category="voice", label="Manceroy — Flamefist call I", detail="Jadefire Masters · Battle of Dazar'alor" },
    { id=2400192, category="voice", label="Manceroy — Flamefist call II", detail="Jadefire Masters · Battle of Dazar'alor" },
    { id=2400193, category="voice", label="Manceroy — Flamefist call III", detail="Jadefire Masters · Battle of Dazar'alor" },
    { id=2399571, category="voice", label="Akunda — Champion invocation", detail="Conclave of the Chosen · Battle of Dazar'alor" },
    { id=2399547, category="voice", label="Gonk — Champion invocation", detail="Conclave of the Chosen · Battle of Dazar'alor" },
    { id=2399521, category="voice", label="Kimbul — Champion invocation", detail="Conclave of the Chosen · Battle of Dazar'alor" },
    { id=2399495, category="voice", label="Pa'ku — Champion invocation", detail="Conclave of the Chosen · Battle of Dazar'alor" },
    { id=2435258, category="voice", label="King Rastakhan — Royal defiance I", detail="Battle of Dazar'alor · Battle for Azeroth" },
    { id=2437274, category="voice", label="High Tinker Mekkatorque — Combat quip II", detail="Battle of Dazar'alor · Battle for Azeroth" },
    { id=2437283, category="voice", label="High Tinker Mekkatorque — Combat quip IV", detail="Battle of Dazar'alor · Battle for Azeroth" },
    { id=2436968, category="voice", label="Laminaria — Storm call I", detail="Stormwall Blockade · Battle of Dazar'alor" },
    { id=2436969, category="voice", label="Laminaria — Storm call II", detail="Stormwall Blockade · Battle of Dazar'alor" },
    { id=2436970, category="voice", label="Laminaria — Storm call III", detail="Stormwall Blockade · Battle of Dazar'alor" },
    { id=2435407, category="voice", label="Brother Joseph — Sea invocation I", detail="Stormwall Blockade · Battle of Dazar'alor" },
    { id=2435408, category="voice", label="Brother Joseph — Sea invocation II", detail="Stormwall Blockade · Battle of Dazar'alor" },
    { id=2435355, category="voice", label="Sister Katherine — Sea invocation I", detail="Stormwall Blockade · Battle of Dazar'alor" },
    { id=2437252, category="voice", label="Lady Jaina Proudmoore — Freezing declaration I", detail="Battle of Dazar'alor · Battle for Azeroth" },
    { id=2437255, category="voice", label="Lady Jaina Proudmoore — Freezing declaration IV", detail="Battle of Dazar'alor · Battle for Azeroth" },

    -- Battle for Azeroth · Ny'alotha
    { id=3194327, category="voice", label="Maut — Encounter voice I", detail="Ny'alotha · Battle for Azeroth" },
    { id=3194328, category="voice", label="Maut — Encounter voice II", detail="Ny'alotha · Battle for Azeroth" },
    { id=3185039, category="voice", label="Prophet Skitra — Encounter voice I", detail="Ny'alotha · Battle for Azeroth" },
    { id=3191566, category="voice", label="Ka'zir — Hivemind voice I", detail="The Hivemind · Ny'alotha" },
    { id=3191567, category="voice", label="Ka'zir — Hivemind voice II", detail="The Hivemind · Ny'alotha" },
    { id=3193534, category="voice", label="Drest'agath — Encounter voice I", detail="Ny'alotha · Battle for Azeroth" },
    { id=3193535, category="voice", label="Drest'agath — Encounter voice II", detail="Ny'alotha · Battle for Azeroth" },
    { id=3184326, category="voice", label="N'Zoth — Encounter voice I", detail="Carapace / N'Zoth · Ny'alotha" },
    { id=548739, category="voice", label="Shad'har — Aggro roar", detail="Ny'alotha · reused Fel Beast creature vocal" },
    { id=548740, category="voice", label="Shad'har — Warning growl", detail="Ny'alotha · reused Fel Beast creature vocal" },
    { id=548744, category="voice", label="Shad'har — Death cry", detail="Ny'alotha · reused Fel Beast creature vocal" },
    { id=548736, category="voice", label="Shad'har — Critical wound", detail="Ny'alotha · reused Fel Beast creature vocal" },
    { id=3235501, category="voice", label="Ra-den — Corrupted attack cry", detail="Ny'alotha · Battle for Azeroth" },

    -- Battle for Azeroth · Crucible of Storms
    { id=2737243, category="voice", label="Zaxasj — Aggro yell", detail="Restless Cabal · Crucible of Storms" },
    { id=2737264, category="voice", label="Zaxasj — Battle shout", detail="Restless Cabal · Crucible of Storms" },
    { id=2737267, category="voice", label="Zaxasj — Death cry", detail="Restless Cabal · Crucible of Storms" },
    { id=2529601, category="voice", label="Fa'thuul — Encounter voice II", detail="Restless Cabal · Crucible of Storms" },
    { id=2529628, category="voice", label="Zaxasj — Encounter voice II", detail="Restless Cabal · Crucible of Storms" },
    { id=2620119, category="voice", label="Uu'nat — Aggro yell", detail="Crucible of Storms · Battle for Azeroth" },
    { id=2620143, category="voice", label="Uu'nat — Battle shout", detail="Crucible of Storms · Battle for Azeroth" },
    { id=2620146, category="voice", label="Uu'nat — Death cry", detail="Crucible of Storms · Battle for Azeroth" },

    -- Battle for Azeroth · The Eternal Palace
    { id=2922258, category="voice", label="Abyssal Commander Sivara — Encounter voice", detail="The Eternal Palace · Battle for Azeroth" },
    { id=2989628, category="voice", label="Abyssal Commander Sivara — Battle shout", detail="The Eternal Palace · Battle for Azeroth" },
    { id=2989633, category="voice", label="Abyssal Commander Sivara — Critical wound", detail="The Eternal Palace · Battle for Azeroth" },
    { id=2920446, category="voice", label="Blackwater Behemoth — Deep-sea aggro", detail="The Eternal Palace · creature signature" },
    { id=2920461, category="voice", label="Blackwater Behemoth — Wound cry", detail="The Eternal Palace · creature signature" },
    { id=2993710, category="voice", label="Radiance of Azshara — Storm attack", detail="The Eternal Palace · Rage of Azshara voice set" },
    { id=2993720, category="voice", label="Radiance of Azshara — Battle shout", detail="The Eternal Palace · Rage of Azshara voice set" },
    { id=2993730, category="voice", label="Radiance of Azshara — Wound cry", detail="The Eternal Palace · Rage of Azshara voice set" },
    { id=2922108, category="voice", label="Lady Ashvane — Encounter voice", detail="The Eternal Palace · Battle for Azeroth" },
    { id=2997810, category="voice", label="Lady Ashvane — Coral-form aggro", detail="The Eternal Palace · Battle for Azeroth" },
    { id=2997829, category="voice", label="Lady Ashvane — Coral-form battle shout", detail="The Eternal Palace · Battle for Azeroth" },
    { id=2997838, category="voice", label="Lady Ashvane — Coral-form warning", detail="The Eternal Palace · Battle for Azeroth" },
    { id=2922619, category="voice", label="Pashmar — Encounter voice", detail="Queen's Court · The Eternal Palace" },
    { id=2989664, category="voice", label="Pashmar — Battle shout", detail="Queen's Court · The Eternal Palace" },
    { id=2989668, category="voice", label="Pashmar — Pre-combat warning", detail="Queen's Court · The Eternal Palace" },
    { id=2922659, category="voice", label="Silivaz — Encounter voice", detail="Queen's Court · The Eternal Palace" },
    { id=3013904, category="voice", label="Silivaz — Battle shout", detail="Queen's Court · The Eternal Palace" },
    { id=3013909, category="voice", label="Silivaz — Critical wound", detail="Queen's Court · The Eternal Palace" },
    { id=2913011, category="voice", label="Queen Azshara — Voice take I", detail="Nazjatar / Eternal Palace era · Battle for Azeroth" },
    { id=2929768, category="voice", label="Queen Azshara — Voice take III", detail="Nazjatar / Eternal Palace era · Battle for Azeroth" },
    { id=2994783, category="voice", label="Queen Azshara — Voice take IV", detail="Nazjatar / Eternal Palace era · Battle for Azeroth" },

    -- Dragonflight · Vault of the Incarnates

    -- Dragonflight · Aberrus

    -- Dragonflight · Amirdrassil
    { id=5328375, category="voice", label="Fyrakk — This is your end, Alexstrasza!", detail="Amirdrassil · iconic declaration" },
    { id=5328482, category="voice", label="Fyrakk — My will shall be their ruin!", detail="Amirdrassil · encounter yell" },
    { id=5328488, category="voice", label="Fyrakk — Die!", detail="Amirdrassil · attack yell" },

    -- Shadowlands · Castle Nathria
    { id=3579482, category="voice", label="Shriekwing — Piercing attack screech", detail="Castle Nathria · creature signature" },
    { id=3579502, category="voice", label="Shriekwing — Death shriek", detail="Castle Nathria · creature signature" },
    { id=3728035, category="voice", label="Huntsman Altimor — Aggro call", detail="Castle Nathria · Shadowlands" },
    { id=3728075, category="voice", label="Huntsman Altimor — Battle shout", detail="Castle Nathria · Shadowlands" },
    { id=3641817, category="voice", label="Hungering Destroyer — Hungry roar", detail="Castle Nathria · creature signature" },
    { id=3556446, category="voice", label="Lady Inerva — I will deal with them harshly", detail="Castle Nathria · encounter line" },
    { id=3855578, category="voice", label="Lady Inerva — Death cry", detail="Castle Nathria · reused Venthyr apothecary vocal" },
    { id=3741991, category="voice", label="Frieda — Battle shout", detail="Council of Blood · reused female Venthyr vocal" },
    { id=3741818, category="voice", label="Stavros — Battle shout", detail="Council of Blood · reused Prince Renathal vocal" },
    { id=3698758, category="voice", label="Niklaus — Battle shout", detail="Council of Blood · Castle Nathria" },
    { id=3698764, category="voice", label="Niklaus — Death cry", detail="Council of Blood · Castle Nathria" },
    { id=3598318, category="voice", label="Sludgefist — Brute battle roar", detail="Castle Nathria · creature signature" },
    { id=3737864, category="voice", label="Sludgefist — Death roar", detail="Castle Nathria · creature signature" },
    { id=3608032, category="voice", label="General Grashaal — Encounter voice", detail="Stone Legion Generals · Castle Nathria" },
    { id=3692605, category="voice", label="Sire Denathrius — I am eternal!", detail="Castle Nathria · iconic declaration" },
    { id=3692606, category="voice", label="Sire Denathrius — I am your master!", detail="Castle Nathria · iconic declaration" },
    { id=3756555, category="voice", label="Sire Denathrius — Battle shout", detail="Castle Nathria · Shadowlands" },

    -- Shadowlands · Sanctum of Domination
    { id=4195428, category="voice", label="Kel'Thuzad — Battle shout", detail="Sanctum of Domination · Shadowlands" },
    { id=4195434, category="voice", label="Kel'Thuzad — Death cry", detail="Sanctum of Domination · Shadowlands" },
    { id=4075660, category="voice", label="Sylvanas — Invading forces atop Torghast", detail="Sanctum of Domination · encounter-era line" },

    -- Shadowlands · Sepulcher of the First Ones
    { id=4383301, category="voice", label="Vigilant Guardian — Automa death sentence", detail="Sepulcher · construct signature" },
    { id=4284093, category="voice", label="Skolex — Devourer death roar", detail="Sepulcher · creature signature" },
    { id=4324390, category="voice", label="The Jailer — Open the way", detail="Sepulcher · iconic declaration" },

    -- The War Within · Nerub-ar Palace
    { id=5778616, category="voice", label="Nexus-Princess Ky'veza — Encounter voice II", detail="Nerub-ar Palace · The War Within" },

    -- The War Within · Liberation of Undermine
    { id=6183867, category="voice", label="Rik Reverb — Encounter voice I", detail="Liberation of Undermine · The War Within" },
    { id=6183869, category="voice", label="Rik Reverb — Encounter voice II", detail="Liberation of Undermine · The War Within" },
    { id=6183870, category="voice", label="Rik Reverb — Encounter voice III", detail="Liberation of Undermine · The War Within" },
    { id=6183871, category="voice", label="Rik Reverb — Encounter voice IV", detail="Liberation of Undermine · The War Within" },
    { id=6183977, category="voice", label="Stix Bunkjunker — Encounter voice II", detail="Liberation of Undermine · The War Within" },
    { id=6183978, category="voice", label="Stix Bunkjunker — Encounter voice III", detail="Liberation of Undermine · The War Within" },
    { id=6183979, category="voice", label="Stix Bunkjunker — Encounter voice IV", detail="Liberation of Undermine · The War Within" },
    { id=6159006, category="voice", label="Chrome King Gallywix — Encounter voice I", detail="Liberation of Undermine · The War Within" },
    { id=6159007, category="voice", label="Chrome King Gallywix — Encounter voice II", detail="Liberation of Undermine · The War Within" },
    { id=6159008, category="voice", label="Chrome King Gallywix — Encounter voice III", detail="Liberation of Undermine · The War Within" },
    { id=6159010, category="voice", label="Chrome King Gallywix — Encounter voice IV", detail="Liberation of Undermine · The War Within" },

    -- The War Within · Manaforge Omega

    -- Midnight 12.1 · currently identifiable raid voice folders
}
