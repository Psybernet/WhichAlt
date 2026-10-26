local _, ns = ...

-- Written by tools/update_trinkets.py. The Settings window compares the
-- patch with the game's.
ns.TrinketDataInfo = { source = "Icy Veins", patch = "12.1.5", updated = "2026-10-20" }

--[[
WhichAlt trinket ratings, from the Icy Veins "Best in Slot Gear" pages
(trinket rankings table for each spec). Rebuild this file with:

    python tools/update_trinkets.py

or edit it by hand:
  - One row per trinket per spec. Columns are separated by "|".
  - Content is "-" when the rating applies everywhere. Otherwise it names
    where the rating applies (Raid, Mythic+, or a hero talent), with one
    row for each.
  - Tier is the letter from Icy Veins (S best, then A, B, C, D...), or
    "Defensive" for a defensive pick.
  - Item ID is the number in the item's Wowhead link. The tooltip matches
    trinkets by this, so it works in every game language.
  - Lines starting with # are ignored.

Trinkets not listed here show as "Not rated", unless they have secondary
stats, in which case they're matched like other gear.
]]

ns.TrinketText = [[
Class        | Spec          | Content         | Tier      | Item ID | Trinket

Death Knight | Blood         | -               | S         | 270175  | Voracious Heart of Ula'tek
Death Knight | Blood         | -               | S         | 158367  | Merektha's Fang
Death Knight | Blood         | -               | A         | 270165  | Keeper's Seething Core
Death Knight | Blood         | -               | A         | 270164  | Gebbo's Bottomless Bag
Death Knight | Blood         | -               | A         | 270173  | Zul'jin's Guillotine Technique
Death Knight | Blood         | -               | B         | 274493  | Effigy of Ula'tek's Faithful
Death Knight | Blood         | -               | B         | 250245  | Tumor of the Swarm
Death Knight | Blood         | -               | B         | 250259  | Sapling of the Dawnroot
Death Knight | Blood         | -               | B         | 250238  | Seed of the Devouring Wild
Death Knight | Blood         | -               | B         | 273796  | Vile Vial of Volatile Venom
Death Knight | Blood         | -               | B         | 193757  | Ruby Whelp Shell
Death Knight | Blood         | -               | B         | 250226  | Latch's Crooked Hook
Death Knight | Blood         | Mythic+         | S         | 281215  | Twisted Horror's Tendril
Death Knight | Blood         | Mythic+         | A         | 270163  | Sszorak's Ferocity
Death Knight | Blood         | Raid            | A         | 281215  | Twisted Horror's Tendril
Death Knight | Frost         | -               | S         | 270175  | Voracious Heart of Ula'tek
Death Knight | Frost         | -               | A         | 250259  | Sapling of the Dawnroot
Death Knight | Frost         | -               | A         | 270164  | Gebbo's Bottomless Bag
Death Knight | Frost         | -               | A         | 246304  | Darkmoon Dominion: Hunt
Death Knight | Frost         | -               | A         | 270165  | Keeper's Seething Core
Death Knight | Frost         | -               | A         | 249343  | Gaze of the Alnseer
Death Knight | Frost         | -               | B         | 246305  | Darkmoon Dominion: Blood
Death Knight | Frost         | -               | B         | 250238  | Seed of the Devouring Wild
Death Knight | Frost         | -               | B         | 250228  | Resonant Bellowstone
Death Knight | Frost         | -               | B         | 273796  | Vile Vial of Volatile Venom
Death Knight | Frost         | -               | C         | 193762  | Blazebinder's Hoof
Death Knight | Frost         | -               | C         | 250229  | Idol of the War Loa
Death Knight | Frost         | -               | C         | 193757  | Ruby Whelp Shell
Death Knight | Frost         | -               | C         | 273797  | Tattered Amani War Banner
Death Knight | Frost         | -               | C         | 270163  | Sszorak's Ferocity
Death Knight | Unholy        | -               | S         | 270175  | Voracious Heart of Ula'tek
Death Knight | Unholy        | -               | S         | 270173  | Zul'jin's Guillotine Technique
Death Knight | Unholy        | -               | S         | 281215  | Twisted Horror's Tendril
Death Knight | Unholy        | -               | A         | 270165  | Keeper's Seething Core
Death Knight | Unholy        | -               | A         | 270164  | Gebbo's Bottomless Bag
Death Knight | Unholy        | -               | A         | 246304  | Darkmoon Dominion: Hunt
Death Knight | Unholy        | -               | A         | 273797  | Tattered Amani War Banner
Death Knight | Unholy        | -               | A         | 249343  | Gaze of the Alnseer
Death Knight | Unholy        | -               | B         | 246305  | Darkmoon Dominion: Blood
Death Knight | Unholy        | -               | B         | 241340  | Magister's Alchemist Stone
Death Knight | Unholy        | -               | B         | 250238  | Seed of the Devouring Wild
Death Knight | Unholy        | -               | B         | 250228  | Resonant Bellowstone
Death Knight | Unholy        | -               | B         | 193762  | Blazebinder's Hoof
Death Knight | Unholy        | -               | B         | 273796  | Vile Vial of Volatile Venom
Death Knight | Unholy        | -               | C         | 250259  | Sapling of the Dawnroot
Death Knight | Unholy        | -               | C         | 250229  | Idol of the War Loa
Death Knight | Unholy        | -               | C         | 193757  | Ruby Whelp Shell
Death Knight | Unholy        | -               | C         | 246307  | Darkmoon Dominion: Void
Death Knight | Unholy        | -               | C         | 270163  | Sszorak's Ferocity
Demon Hunter | Havoc         | -               | S         | 270173  | Zul'jin's Guillotine Technique
Demon Hunter | Havoc         | -               | S         | 270168  | Font of Venomous Rage
Demon Hunter | Havoc         | -               | S         | 270175  | Voracious Heart of Ula'tek
Demon Hunter | Havoc         | -               | S         | 281215  | Twisted Horror's Tendril
Demon Hunter | Havoc         | -               | A         | 250225  | Void Execution Mandate
Demon Hunter | Havoc         | -               | A         | 273796  | Vile Vial of Volatile Venom
Demon Hunter | Havoc         | -               | A         | 270165  | Keeper's Seething Core
Demon Hunter | Havoc         | -               | A         | 270166  | Vashnik's Sanguine Rancor
Demon Hunter | Havoc         | -               | B         | 270164  | Gebbo's Bottomless Bag
Demon Hunter | Havoc         | -               | B         | 250228  | Resonant Bellowstone
Demon Hunter | Havoc         | -               | B         | 250215  | Freightrunner's Flask
Demon Hunter | Havoc         | -               | B         | 159617  | Lustrous Golden Plumage
Demon Hunter | Havoc         | -               | B         | 248583  | Drum of Renewed Bonds
Demon Hunter | Havoc         | -               | B         | 250214  | Lightspire Core
Demon Hunter | Havoc         | -               | B         | 250259  | Sapling of the Dawnroot
Demon Hunter | Havoc         | -               | B         | 251792  | Glorious Crusader's Keepsake
Demon Hunter | Havoc         | -               | C         | 265657  | Fiber of Living Agony
Demon Hunter | Havoc         | -               | C         | 158374  | Tiny Electromental in a Jar
Demon Hunter | Havoc         | -               | C         | 251785  | Void-Reaper's Libram
Demon Hunter | Havoc         | -               | C         | 274493  | Effigy of Ula'tek's Faithful
Demon Hunter | Havoc         | -               | D         | 274497  | Spirit-Rending Poison
Demon Hunter | Havoc         | -               | D         | 251784  | Sylvan Wakrapuku
Demon Hunter | Havoc         | -               | D         | 246304  | Darkmoon Dominion: Hunt
Demon Hunter | Havoc         | -               | D         | 246305  | Darkmoon Dominion: Blood
Demon Hunter | Havoc         | -               | D         | 246306  | Darkmoon Dominion: Rot
Demon Hunter | Havoc         | -               | D         | 246307  | Darkmoon Dominion: Void
Demon Hunter | Havoc         | -               | D         | 241340  | Magister's Alchemist Stone
Demon Hunter | Havoc         | -               | D         | 251783  | Lost Idol of the Hash'ey
Demon Hunter | Havoc         | -               | D         | 274496  | Ophidian Bone Whistle
Demon Hunter | Vengeance     | -               | S         | 281215  | Twisted Horror's Tendril
Demon Hunter | Vengeance     | -               | S         | 280617  | Lightbearer's Shield Fragment
Demon Hunter | Vengeance     | -               | S         | 270175  | Voracious Heart of Ula'tek
Demon Hunter | Vengeance     | -               | S         | 270173  | Zul'jin's Guillotine Technique
Demon Hunter | Vengeance     | -               | S         | 270165  | Keeper's Seething Core
Demon Hunter | Vengeance     | -               | S         | 270164  | Gebbo's Bottomless Bag
Demon Hunter | Vengeance     | -               | A         | 273796  | Vile Vial of Volatile Venom
Demon Hunter | Vengeance     | -               | A         | 270160  | First Mate's Shellward
Demon Hunter | Vengeance     | -               | B         | 250243  | Manaheart's Binding Flame
Demon Hunter | Vengeance     | -               | B         | 250244  | Permafrost Essence
Demon Hunter | Vengeance     | -               | B         | 250259  | Sapling of the Dawnroot
Demon Hunter | Vengeance     | -               | B         | 270168  | Font of Venomous Rage
Demon Hunter | Vengeance     | -               | C         | 270166  | Vashnik's Sanguine Rancor
Demon Hunter | Vengeance     | -               | C         | 159618  | Mchimba's Ritual Bandages
Demon Hunter | Vengeance     | -               | C         | 158374  | Tiny Electromental in a Jar
Demon Hunter | Vengeance     | Aldrachi Reaver | B         | 250215  | Freightrunner's Flask
Demon Hunter | Vengeance     | Aldrachi Reaver | B         | 273797  | Tattered Amani War Banner
Demon Hunter | Vengeance     | Aldrachi Reaver | B         | 250228  | Resonant Bellowstone
Demon Hunter | Vengeance     | Aldrachi Reaver | B         | 159617  | Lustrous Golden Plumage
Demon Hunter | Vengeance     | Aldrachi Reaver | C         | 193757  | Ruby Whelp Shell
Demon Hunter | Vengeance     | Aldrachi Reaver | C         | 270174  | Idol of the Howling Nexus
Demon Hunter | Vengeance     | Aldrachi Reaver | C         | 250225  | Void Execution Mandate
Demon Hunter | Vengeance     | Aldrachi Reaver | C         | 250214  | Lightspire Core
Demon Hunter | Vengeance     | Aldrachi Reaver | C         | 250245  | Tumor of the Swarm
Demon Hunter | Vengeance     | Annihilator     | A         | 250215  | Freightrunner's Flask
Demon Hunter | Vengeance     | Annihilator     | A         | 273797  | Tattered Amani War Banner
Demon Hunter | Vengeance     | Annihilator     | A         | 250228  | Resonant Bellowstone
Demon Hunter | Vengeance     | Annihilator     | A         | 159617  | Lustrous Golden Plumage
Demon Hunter | Vengeance     | Annihilator     | B         | 193757  | Ruby Whelp Shell
Demon Hunter | Vengeance     | Annihilator     | B         | 270174  | Idol of the Howling Nexus
Demon Hunter | Vengeance     | Annihilator     | B         | 250225  | Void Execution Mandate
Demon Hunter | Vengeance     | Annihilator     | B         | 250214  | Lightspire Core
Demon Hunter | Devourer      | -               | S         | 281215  | Twisted Horror's Tendril
Demon Hunter | Devourer      | -               | S         | 270164  | Gebbo's Bottomless Bag
Demon Hunter | Devourer      | -               | A         | 250215  | Freightrunner's Flask
Demon Hunter | Devourer      | -               | A         | 270167  | Wavecaller's Seastone
Demon Hunter | Devourer      | -               | A         | 270161  | Fang of Umbral Malignance
Demon Hunter | Devourer      | -               | A         | 250224  | Mindpiercer's Sigil
Demon Hunter | Devourer      | -               | A         | 273796  | Vile Vial of Volatile Venom
Demon Hunter | Devourer      | -               | A         | 193757  | Ruby Whelp Shell
Demon Hunter | Devourer      | -               | A         | 270169  | Hex Lord's Dooming Idol
Demon Hunter | Devourer      | -               | B         | 251792  | Glorious Crusader's Keepsake
Demon Hunter | Devourer      | -               | B         | 248583  | Drum of Renewed Bonds
Demon Hunter | Devourer      | -               | B         | 250259  | Sapling of the Dawnroot
Demon Hunter | Devourer      | -               | B         | 273649  | Stormbound Emblem of Dazar
Demon Hunter | Devourer      | -               | C         | 270168  | Font of Venomous Rage
Demon Hunter | Devourer      | -               | C         | 270170  | Vexhul's Everflowing Gland
Demon Hunter | Devourer      | -               | C         | 251783  | Lost Idol of the Hash'ey
Demon Hunter | Devourer      | -               | C         | 251786  | Ever-Collapsing Void Fissure
Demon Hunter | Devourer      | -               | C         | 273794  | Knot of Writhing Serpents
Demon Hunter | Devourer      | -               | D         | 274497  | Spirit-Rending Poison
Demon Hunter | Devourer      | -               | D         | 251784  | Sylvan Wakrapuku
Demon Hunter | Devourer      | -               | D         | 246304  | Darkmoon Dominion: Hunt
Demon Hunter | Devourer      | -               | D         | 250214  | Lightspire Core
Demon Hunter | Devourer      | -               | D         | 246305  | Darkmoon Dominion: Blood
Demon Hunter | Devourer      | -               | D         | 246306  | Darkmoon Dominion: Rot
Demon Hunter | Devourer      | -               | D         | 246307  | Darkmoon Dominion: Void
Demon Hunter | Devourer      | -               | D         | 241340  | Magister's Alchemist Stone
Demon Hunter | Devourer      | -               | D         | 274493  | Effigy of Ula'tek's Faithful
Demon Hunter | Devourer      | -               | D         | 274496  | Ophidian Bone Whistle
Demon Hunter | Devourer      | -               | D         | 251787  | Sealed Chaos Urn
Demon Hunter | Devourer      | -               | D         | 274495  | Pulse Seeker's Oculus
Demon Hunter | Devourer      | -               | D         | 280123  | Sharp Axe Holster
Druid        | Balance       | -               | S         | 281215  | Twisted Horror's Tendril
Druid        | Balance       | -               | S         | 273796  | Vile Vial of Volatile Venom
Druid        | Balance       | -               | S         | 270167  | Wavecaller's Seastone
Druid        | Balance       | -               | A         | 270164  | Gebbo's Bottomless Bag
Druid        | Balance       | -               | A         | 250215  | Freightrunner's Flask
Druid        | Balance       | -               | A         | 270169  | Hex Lord's Dooming Idol
Druid        | Balance       | -               | B         | 270170  | Vexhul's Everflowing Gland
Druid        | Balance       | -               | B         | 250259  | Sapling of the Dawnroot
Druid        | Balance       | -               | B         | 250224  | Mindpiercer's Sigil
Druid        | Balance       | -               | B         | 250214  | Lightspire Core
Druid        | Balance       | -               | B         | 270161  | Fang of Umbral Malignance
Druid        | Balance       | -               | C         | 193757  | Ruby Whelp Shell
Druid        | Balance       | -               | C         | 273794  | Knot of Writhing Serpents
Druid        | Balance       | -               | C         | 273649  | Stormbound Emblem of Dazar
Druid        | Balance       | -               | C         | 158368  | Sethraliss' Defiled Relic
Druid        | Balance       | -               | C         | 270168  | Font of Venomous Rage
Druid        | Feral         | -               | S         | 270175  | Voracious Heart of Ula'tek
Druid        | Feral         | -               | S         | 270173  | Zul'jin's Guillotine Technique
Druid        | Feral         | -               | S         | 281215  | Twisted Horror's Tendril
Druid        | Feral         | -               | A         | 270164  | Gebbo's Bottomless Bag
Druid        | Feral         | -               | A         | 270165  | Keeper's Seething Core
Druid        | Feral         | -               | A         | 159617  | Lustrous Golden Plumage
Druid        | Feral         | -               | A         | 273796  | Vile Vial of Volatile Venom
Druid        | Feral         | -               | A         | 250228  | Resonant Bellowstone
Druid        | Feral         | -               | B         | 250225  | Void Execution Mandate
Druid        | Feral         | -               | B         | 250214  | Lightspire Core
Druid        | Feral         | -               | B         | 270166  | Vashnik's Sanguine Rancor
Druid        | Feral         | -               | B         | 248583  | Drum of Renewed Bonds
Druid        | Feral         | -               | B         | 250215  | Freightrunner's Flask
Druid        | Feral         | -               | B         | 265657  | Fiber of Living Agony
Druid        | Feral         | -               | B         | 251792  | Glorious Crusader's Keepsake
Druid        | Feral         | -               | C         | 270168  | Font of Venomous Rage
Druid        | Feral         | -               | C         | 250259  | Sapling of the Dawnroot
Druid        | Feral         | -               | C         | 274493  | Effigy of Ula'tek's Faithful
Druid        | Feral         | -               | C         | 158374  | Tiny Electromental in a Jar
Druid        | Feral         | -               | C         | 251785  | Void-Reaper's Libram
Druid        | Feral         | -               | D         | 273797  | Tattered Amani War Banner
Druid        | Feral         | -               | D         | 246304  | Darkmoon Dominion: Hunt
Druid        | Feral         | -               | D         | 246305  | Darkmoon Dominion: Blood
Druid        | Feral         | -               | D         | 246306  | Darkmoon Dominion: Rot
Druid        | Feral         | -               | D         | 246307  | Darkmoon Dominion: Void
Druid        | Feral         | -               | D         | 241340  | Magister's Alchemist Stone
Druid        | Feral         | -               | D         | 251783  | Lost Idol of the Hash'ey
Druid        | Feral         | -               | D         | 274496  | Ophidian Bone Whistle
Druid        | Feral         | -               | D         | 274497  | Spirit-Rending Poison
Druid        | Guardian      | -               | S         | 270175  | Voracious Heart of Ula'tek
Druid        | Guardian      | -               | S         | 270173  | Zul'jin's Guillotine Technique
Druid        | Guardian      | -               | S         | 270168  | Font of Venomous Rage
Druid        | Guardian      | -               | S         | 270164  | Gebbo's Bottomless Bag
Druid        | Guardian      | -               | S         | 273796  | Vile Vial of Volatile Venom
Druid        | Guardian      | -               | S         | 250245  | Tumor of the Swarm
Druid        | Guardian      | -               | S         | 270165  | Keeper's Seething Core
Druid        | Guardian      | -               | A         | 159617  | Lustrous Golden Plumage
Druid        | Guardian      | -               | A         | 270166  | Vashnik's Sanguine Rancor
Druid        | Guardian      | -               | A         | 270160  | First Mate's Shellward
Druid        | Guardian      | -               | A         | 273797  | Tattered Amani War Banner
Druid        | Guardian      | -               | B         | 250244  | Permafrost Essence
Druid        | Guardian      | -               | B         | 250215  | Freightrunner's Flask
Druid        | Guardian      | -               | B         | 250243  | Manaheart's Binding Flame
Druid        | Guardian      | -               | B         | 250228  | Resonant Bellowstone
Druid        | Guardian      | -               | B         | 250259  | Sapling of the Dawnroot
Druid        | Guardian      | -               | B         | 250214  | Lightspire Core
Druid        | Guardian      | -               | B         | 270174  | Idol of the Howling Nexus
Druid        | Guardian      | -               | B         | 250225  | Void Execution Mandate
Druid        | Guardian      | -               | C         | 159618  | Mchimba's Ritual Bandages
Druid        | Guardian      | -               | C         | 193757  | Ruby Whelp Shell
Druid        | Guardian      | -               | D         | 158374  | Tiny Electromental in a Jar
Druid        | Restoration   | -               | S         | 270162  | Soulcoiler Ritual Vessel
Druid        | Restoration   | -               | S         | 270167  | Wavecaller's Seastone
Druid        | Restoration   | -               | S         | 270164  | Gebbo's Bottomless Bag
Druid        | Restoration   | -               | A         | 270169  | Hex Lord's Dooming Idol
Druid        | Restoration   | -               | A         | 280835  | Sigil of the Impending Eclipse
Druid        | Restoration   | -               | A         | 250214  | Lightspire Core
Druid        | Restoration   | -               | A         | 248583  | Drum of Renewed Bonds
Druid        | Restoration   | -               | A         | 251792  | Glorious Crusader's Keepsake
Druid        | Restoration   | -               | B         | 193757  | Ruby Whelp Shell
Druid        | Restoration   | -               | B         | 273649  | Stormbound Emblem of Dazar
Druid        | Restoration   | -               | B         | 250248  | Mycolic Medicine
Druid        | Restoration   | -               | B         | 250255  | Unstable Felheart Crystal
Druid        | Restoration   | -               | B         | 270171  | Preternatural Antivenom
Druid        | Restoration   | -               | C         | 250254  | Seed of Radiant Hope
Druid        | Restoration   | -               | C         | 273796  | Vile Vial of Volatile Venom
Druid        | Restoration   | -               | D         | 264507  | Crucible of Erratic Energies
Druid        | Restoration   | -               | D         | 264701  | Cosmic Bell
Druid        | Restoration   | -               | F-        | 193748  | Kyrakka's Searing Embers
Evoker       | Devastation   | -               | S         | 281215  | Twisted Horror's Tendril
Evoker       | Devastation   | -               | S         | 270168  | Font of Venomous Rage
Evoker       | Devastation   | -               | S         | 270164  | Gebbo's Bottomless Bag
Evoker       | Devastation   | -               | S         | 270167  | Wavecaller's Seastone
Evoker       | Devastation   | -               | A         | 250215  | Freightrunner's Flask
Evoker       | Devastation   | -               | A         | 250224  | Mindpiercer's Sigil
Evoker       | Devastation   | -               | A         | 273796  | Vile Vial of Volatile Venom
Evoker       | Devastation   | -               | B         | 270169  | Hex Lord's Dooming Idol
Evoker       | Devastation   | -               | B         | 273794  | Knot of Writhing Serpents
Evoker       | Preservation  | -               | S         | 270162  | Soulcoiler Ritual Vessel
Evoker       | Preservation  | -               | S         | 270164  | Gebbo's Bottomless Bag
Evoker       | Preservation  | -               | A         | 270167  | Wavecaller's Seastone
Evoker       | Preservation  | -               | A         | 250214  | Lightspire Core
Evoker       | Preservation  | -               | A         | 248583  | Drum of Renewed Bonds
Evoker       | Preservation  | -               | A         | 193757  | Ruby Whelp Shell
Evoker       | Preservation  | -               | A         | 250215  | Freightrunner's Flask
Evoker       | Preservation  | -               | A         | 270169  | Hex Lord's Dooming Idol
Evoker       | Preservation  | -               | B         | 249343  | Gaze of the Alnseer
Evoker       | Preservation  | -               | B         | 249811  | Light of the Cosmic Crescendo
Evoker       | Preservation  | -               | B         | 251792  | Glorious Crusader's Keepsake
Evoker       | Preservation  | -               | B         | 274493  | Effigy of Ula'tek's Faithful
Evoker       | Preservation  | -               | B         | 273796  | Vile Vial of Volatile Venom
Evoker       | Preservation  | -               | C         | 250248  | Mycolic Medicine
Evoker       | Preservation  | -               | C         | 250255  | Unstable Felheart Crystal
Evoker       | Preservation  | -               | C         | 268292  | Sporelord's Mycelial Insignia
Evoker       | Preservation  | -               | C         | 264507  | Crucible of Erratic Energies
Evoker       | Preservation  | -               | D         | 250254  | Seed of Radiant Hope
Evoker       | Preservation  | -               | D         | 270171  | Preternatural Antivenom
Evoker       | Preservation  | -               | D         | 264701  | Cosmic Bell
Evoker       | Augmentation  | -               | S         | 281215  | Twisted Horror's Tendril
Evoker       | Augmentation  | -               | A         | 270169  | Hex Lord's Dooming Idol
Evoker       | Augmentation  | -               | A         | 270167  | Wavecaller's Seastone
Evoker       | Augmentation  | -               | A         | 270170  | Vexhul's Everflowing Gland
Evoker       | Augmentation  | -               | A         | 250214  | Lightspire Core
Evoker       | Augmentation  | -               | A         | 250224  | Mindpiercer's Sigil
Evoker       | Augmentation  | -               | A         | 250215  | Freightrunner's Flask
Evoker       | Augmentation  | -               | A         | 270164  | Gebbo's Bottomless Bag
Evoker       | Augmentation  | -               | B         | 248583  | Drum of Renewed Bonds
Evoker       | Augmentation  | -               | B         | 273794  | Knot of Writhing Serpents
Evoker       | Augmentation  | -               | B         | 273796  | Vile Vial of Volatile Venom
Evoker       | Augmentation  | -               | B         | 193757  | Ruby Whelp Shell
Evoker       | Augmentation  | -               | C         | 251792  | Glorious Crusader's Keepsake
Evoker       | Augmentation  | -               | C         | 249809  | Locus-Walker's Ribbon
Evoker       | Augmentation  | -               | C         | 245829  | Darkmoon Deck: Hunt
Evoker       | Augmentation  | -               | D         | 273649  | Stormbound Emblem of Dazar
Evoker       | Augmentation  | -               | D         | 251786  | Ever-Collapsing Void Fissure
Evoker       | Augmentation  | -               | D         | 245855  | Darkmoon Deck: Blood
Evoker       | Augmentation  | -               | D         | 245846  | Darkmoon Deck: Rot
Evoker       | Augmentation  | -               | D         | 245750  | Darkmoon Deck: Void
Evoker       | Augmentation  | Mythic+         | S         | 270161  | Fang of Umbral Malignance
Evoker       | Augmentation  | Mythic+         | A         | 270168  | Font of Venomous Rage
Evoker       | Augmentation  | Mythic+         | C         | 250259  | Sapling of the Dawnroot
Evoker       | Augmentation  | Raid            | S         | 270168  | Font of Venomous Rage
Evoker       | Augmentation  | Raid            | S         | 249346  | Vaelgor's Final Stare
Evoker       | Augmentation  | Raid            | A         | 270161  | Fang of Umbral Malignance
Evoker       | Augmentation  | Raid            | B         | 250259  | Sapling of the Dawnroot
Evoker       | Augmentation  | Raid            | C         | 249343  | Gaze of the Alnseer
Hunter       | Beast Mastery | -               | S         | 270175  | Voracious Heart of Ula'tek
Hunter       | Beast Mastery | -               | S         | 281215  | Twisted Horror's Tendril
Hunter       | Beast Mastery | -               | S         | 159617  | Lustrous Golden Plumage
Hunter       | Beast Mastery | -               | A         | 270165  | Keeper's Seething Core
Hunter       | Beast Mastery | -               | A         | 270173  | Zul'jin's Guillotine Technique
Hunter       | Beast Mastery | -               | A         | 250215  | Freightrunner's Flask
Hunter       | Beast Mastery | -               | A         | 273796  | Vile Vial of Volatile Venom
Hunter       | Beast Mastery | -               | A         | 270164  | Gebbo's Bottomless Bag
Hunter       | Beast Mastery | -               | A         | 250225  | Void Execution Mandate
Hunter       | Beast Mastery | -               | B         | 273797  | Tattered Amani War Banner
Hunter       | Beast Mastery | -               | B         | 250214  | Lightspire Core
Hunter       | Beast Mastery | -               | B         | 250228  | Resonant Bellowstone
Hunter       | Beast Mastery | -               | B         | 270166  | Vashnik's Sanguine Rancor
Hunter       | Beast Mastery | -               | B         | 246304  | Darkmoon Dominion: Hunt
Hunter       | Beast Mastery | -               | B         | 241340  | Magister's Alchemist Stone
Hunter       | Beast Mastery | -               | C         | 158374  | Tiny Electromental in a Jar
Hunter       | Beast Mastery | -               | C         | 250259  | Sapling of the Dawnroot
Hunter       | Beast Mastery | -               | C         | 193757  | Ruby Whelp Shell
Hunter       | Beast Mastery | -               | C         | 270168  | Font of Venomous Rage
Hunter       | Marksmanship  | -               | S         | 270175  | Voracious Heart of Ula'tek
Hunter       | Marksmanship  | -               | S         | 270168  | Font of Venomous Rage
Hunter       | Marksmanship  | -               | A         | 281215  | Twisted Horror's Tendril
Hunter       | Marksmanship  | -               | A         | 270173  | Zul'jin's Guillotine Technique
Hunter       | Marksmanship  | -               | B         | 159617  | Lustrous Golden Plumage
Hunter       | Marksmanship  | -               | B         | 270165  | Keeper's Seething Core
Hunter       | Marksmanship  | -               | B         | 273796  | Vile Vial of Volatile Venom
Hunter       | Marksmanship  | -               | B         | 270164  | Gebbo's Bottomless Bag
Hunter       | Marksmanship  | -               | C         | 250225  | Void Execution Mandate
Hunter       | Marksmanship  | -               | C         | 270166  | Vashnik's Sanguine Rancor
Hunter       | Marksmanship  | -               | C         | 250214  | Lightspire Core
Hunter       | Marksmanship  | -               | C         | 250228  | Resonant Bellowstone
Hunter       | Marksmanship  | -               | C         | 158374  | Tiny Electromental in a Jar
Hunter       | Marksmanship  | -               | C         | 193757  | Ruby Whelp Shell
Hunter       | Marksmanship  | -               | C         | 246304  | Darkmoon Dominion: Hunt
Hunter       | Marksmanship  | -               | C         | 250259  | Sapling of the Dawnroot
Hunter       | Marksmanship  | -               | D         | 250215  | Freightrunner's Flask
Hunter       | Marksmanship  | -               | D         | 273797  | Tattered Amani War Banner
Hunter       | Marksmanship  | -               | D         | 241340  | Magister's Alchemist Stone
Hunter       | Survival      | -               | S         | 270175  | Voracious Heart of Ula'tek
Hunter       | Survival      | -               | S         | 270173  | Zul'jin's Guillotine Technique
Hunter       | Survival      | -               | A         | 250215  | Freightrunner's Flask
Hunter       | Survival      | -               | A         | 273797  | Tattered Amani War Banner
Hunter       | Survival      | -               | B         | 159617  | Lustrous Golden Plumage
Hunter       | Survival      | -               | B         | 273796  | Vile Vial of Volatile Venom
Hunter       | Survival      | -               | B         | 281215  | Twisted Horror's Tendril
Hunter       | Survival      | -               | B         | 250225  | Void Execution Mandate
Hunter       | Survival      | -               | B         | 270165  | Keeper's Seething Core
Hunter       | Survival      | -               | C         | 270164  | Gebbo's Bottomless Bag
Hunter       | Survival      | -               | D         | 250214  | Lightspire Core
Hunter       | Survival      | -               | D         | 250228  | Resonant Bellowstone
Hunter       | Survival      | -               | D         | 246304  | Darkmoon Dominion: Hunt
Hunter       | Survival      | -               | E         | 193757  | Ruby Whelp Shell
Hunter       | Survival      | -               | E         | 250259  | Sapling of the Dawnroot
Hunter       | Survival      | -               | E         | 270166  | Vashnik's Sanguine Rancor
Hunter       | Survival      | -               | E         | 241340  | Magister's Alchemist Stone
Hunter       | Survival      | -               | E         | 270168  | Font of Venomous Rage
Hunter       | Survival      | -               | E         | 158374  | Tiny Electromental in a Jar
Mage         | Arcane        | -               | S         | 250215  | Freightrunner's Flask
Mage         | Arcane        | -               | S         | 281215  | Twisted Horror's Tendril
Mage         | Arcane        | -               | S         | 270164  | Gebbo's Bottomless Bag
Mage         | Arcane        | -               | A         | 270170  | Vexhul's Everflowing Gland
Mage         | Arcane        | -               | A         | 273796  | Vile Vial of Volatile Venom
Mage         | Arcane        | -               | A         | 250214  | Lightspire Core
Mage         | Arcane        | -               | A         | 270167  | Wavecaller's Seastone
Mage         | Arcane        | -               | B         | 270169  | Hex Lord's Dooming Idol
Mage         | Arcane        | -               | B         | 250259  | Sapling of the Dawnroot
Mage         | Arcane        | -               | B         | 250224  | Mindpiercer's Sigil
Mage         | Arcane        | -               | C         | 270161  | Fang of Umbral Malignance
Mage         | Arcane        | -               | C         | 273649  | Stormbound Emblem of Dazar
Mage         | Arcane        | -               | C         | 273794  | Knot of Writhing Serpents
Mage         | Arcane        | -               | D         | 158368  | Sethraliss' Defiled Relic
Mage         | Arcane        | -               | D         | 193757  | Ruby Whelp Shell
Mage         | Arcane        | -               | D         | 270168  | Font of Venomous Rage
Mage         | Fire          | -               | S         | 273796  | Vile Vial of Volatile Venom
Mage         | Fire          | -               | S         | 270164  | Gebbo's Bottomless Bag
Mage         | Fire          | -               | A         | 281215  | Twisted Horror's Tendril
Mage         | Fire          | -               | A         | 270170  | Vexhul's Everflowing Gland
Mage         | Fire          | -               | A         | 250214  | Lightspire Core
Mage         | Fire          | -               | A         | 270167  | Wavecaller's Seastone
Mage         | Fire          | -               | B         | 270169  | Hex Lord's Dooming Idol
Mage         | Fire          | -               | B         | 250259  | Sapling of the Dawnroot
Mage         | Fire          | -               | B         | 250224  | Mindpiercer's Sigil
Mage         | Fire          | -               | C         | 270161  | Fang of Umbral Malignance
Mage         | Fire          | -               | C         | 273649  | Stormbound Emblem of Dazar
Mage         | Fire          | -               | C         | 273794  | Knot of Writhing Serpents
Mage         | Fire          | -               | D         | 250215  | Freightrunner's Flask
Mage         | Fire          | -               | D         | 158368  | Sethraliss' Defiled Relic
Mage         | Fire          | -               | D         | 193757  | Ruby Whelp Shell
Mage         | Fire          | -               | D         | 270168  | Font of Venomous Rage
Mage         | Frost         | -               | S         | 270170  | Vexhul's Everflowing Gland
Mage         | Frost         | -               | S         | 270167  | Wavecaller's Seastone
Mage         | Frost         | -               | S         | 270164  | Gebbo's Bottomless Bag
Mage         | Frost         | -               | S         | 250224  | Mindpiercer's Sigil
Mage         | Frost         | -               | S         | 273796  | Vile Vial of Volatile Venom
Mage         | Frost         | -               | A         | 250259  | Sapling of the Dawnroot
Mage         | Frost         | -               | A         | 250215  | Freightrunner's Flask
Mage         | Frost         | -               | A         | 250214  | Lightspire Core
Mage         | Frost         | -               | A         | 270161  | Fang of Umbral Malignance
Mage         | Frost         | -               | A         | 273794  | Knot of Writhing Serpents
Mage         | Frost         | -               | B         | 274493  | Effigy of Ula'tek's Faithful
Mage         | Frost         | -               | B         | 251792  | Glorious Crusader's Keepsake
Mage         | Frost         | -               | B         | 270169  | Hex Lord's Dooming Idol
Mage         | Frost         | -               | C         | 193757  | Ruby Whelp Shell
Mage         | Frost         | -               | C         | 251785  | Void-Reaper's Libram
Mage         | Frost         | -               | C         | 270168  | Font of Venomous Rage
Mage         | Frost         | -               | C         | 251786  | Ever-Collapsing Void Fissure
Mage         | Frost         | -               | C         | 251784  | Sylvan Wakrapuku
Monk         | Brewmaster    | -               | S         | 270175  | Voracious Heart of Ula'tek
Monk         | Brewmaster    | -               | S         | 270168  | Font of Venomous Rage
Monk         | Brewmaster    | -               | S         | 281215  | Twisted Horror's Tendril
Monk         | Brewmaster    | -               | S         | 250245  | Tumor of the Swarm
Monk         | Brewmaster    | -               | S         | 270173  | Zul'jin's Guillotine Technique
Monk         | Brewmaster    | -               | A         | 159617  | Lustrous Golden Plumage
Monk         | Brewmaster    | -               | A         | 158374  | Tiny Electromental in a Jar
Monk         | Brewmaster    | -               | A         | 250215  | Freightrunner's Flask
Monk         | Brewmaster    | -               | A         | 270164  | Gebbo's Bottomless Bag
Monk         | Brewmaster    | -               | A         | 250228  | Resonant Bellowstone
Monk         | Brewmaster    | -               | A         | 270166  | Vashnik's Sanguine Rancor
Monk         | Brewmaster    | -               | A         | 250259  | Sapling of the Dawnroot
Monk         | Brewmaster    | -               | A         | 250214  | Lightspire Core
Monk         | Brewmaster    | -               | A         | 248583  | Drum of Renewed Bonds
Monk         | Brewmaster    | -               | A         | 270165  | Keeper's Seething Core
Monk         | Brewmaster    | -               | A         | 270160  | First Mate's Shellward
Monk         | Brewmaster    | -               | A         | 265657  | Fiber of Living Agony
Monk         | Brewmaster    | -               | A         | 280617  | Lightbearer's Shield Fragment
Monk         | Brewmaster    | -               | B         | 273796  | Vile Vial of Volatile Venom
Monk         | Brewmaster    | -               | B         | 251785  | Void-Reaper's Libram
Monk         | Brewmaster    | -               | B         | 159618  | Mchimba's Ritual Bandages
Monk         | Brewmaster    | -               | B         | 274493  | Effigy of Ula'tek's Faithful
Monk         | Brewmaster    | -               | B         | 250225  | Void Execution Mandate
Monk         | Brewmaster    | -               | B         | 193757  | Ruby Whelp Shell
Monk         | Brewmaster    | -               | B         | 273797  | Tattered Amani War Banner
Monk         | Brewmaster    | -               | B         | 250243  | Manaheart's Binding Flame
Monk         | Brewmaster    | -               | B         | 251792  | Glorious Crusader's Keepsake
Monk         | Brewmaster    | -               | B         | 250244  | Permafrost Essence
Monk         | Brewmaster    | -               | B         | 246307  | Darkmoon Dominion: Void
Monk         | Brewmaster    | -               | B         | 241340  | Magister's Alchemist Stone
Monk         | Brewmaster    | -               | C         | 274498  | Spirit Ward
Monk         | Brewmaster    | -               | C         | 251790  | Desecrated Chalice
Monk         | Brewmaster    | -               | C         | 251783  | Lost Idol of the Hash'ey
Monk         | Brewmaster    | -               | C         | 246306  | Darkmoon Dominion: Rot
Monk         | Brewmaster    | -               | C         | 274499  | Toxiferous Transfusion
Monk         | Brewmaster    | -               | C         | 274497  | Spirit-Rending Poison
Monk         | Brewmaster    | -               | C         | 270174  | Idol of the Howling Nexus
Monk         | Brewmaster    | -               | D         | 274496  | Ophidian Bone Whistle
Monk         | Brewmaster    | -               | D         | 246304  | Darkmoon Dominion: Hunt
Monk         | Brewmaster    | -               | D         | 264694  | Ultradon Cuirass
Monk         | Brewmaster    | -               | D         | 246305  | Darkmoon Dominion: Blood
Monk         | Mistweaver    | -               | S         | 270162  | Soulcoiler Ritual Vessel
Monk         | Mistweaver    | -               | A         | 270167  | Wavecaller's Seastone
Monk         | Mistweaver    | -               | A         | 281215  | Twisted Horror's Tendril
Monk         | Mistweaver    | -               | A         | 280835  | Sigil of the Impending Eclipse
Monk         | Mistweaver    | -               | A         | 270164  | Gebbo's Bottomless Bag
Monk         | Mistweaver    | -               | A         | 270169  | Hex Lord's Dooming Idol
Monk         | Mistweaver    | -               | B         | 250215  | Freightrunner's Flask
Monk         | Mistweaver    | -               | B         | 273649  | Stormbound Emblem of Dazar
Monk         | Mistweaver    | -               | B         | 250248  | Mycolic Medicine
Monk         | Mistweaver    | -               | B         | 193757  | Ruby Whelp Shell
Monk         | Mistweaver    | -               | C         | 250214  | Lightspire Core
Monk         | Mistweaver    | -               | C         | 248583  | Drum of Renewed Bonds
Monk         | Mistweaver    | -               | C         | 251792  | Glorious Crusader's Keepsake
Monk         | Windwalker    | -               | S         | 270175  | Voracious Heart of Ula'tek
Monk         | Windwalker    | -               | S         | 270173  | Zul'jin's Guillotine Technique
Monk         | Windwalker    | -               | A         | 250215  | Freightrunner's Flask
Monk         | Windwalker    | -               | A         | 273796  | Vile Vial of Volatile Venom
Monk         | Windwalker    | -               | A         | 250225  | Void Execution Mandate
Monk         | Windwalker    | -               | A         | 270164  | Gebbo's Bottomless Bag
Monk         | Windwalker    | -               | A         | 270165  | Keeper's Seething Core
Monk         | Windwalker    | -               | A         | 281215  | Twisted Horror's Tendril
Monk         | Windwalker    | -               | B         | 250259  | Sapling of the Dawnroot
Monk         | Windwalker    | -               | B         | 270168  | Font of Venomous Rage
Monk         | Windwalker    | -               | B         | 159617  | Lustrous Golden Plumage
Monk         | Windwalker    | -               | D         | 250214  | Lightspire Core
Monk         | Windwalker    | -               | D         | 241340  | Magister's Alchemist Stone
Monk         | Windwalker    | -               | D         | 273797  | Tattered Amani War Banner
Monk         | Windwalker    | -               | D         | 270166  | Vashnik's Sanguine Rancor
Paladin      | Holy          | -               | S         | 270162  | Soulcoiler Ritual Vessel
Paladin      | Holy          | -               | S         | 281215  | Twisted Horror's Tendril
Paladin      | Holy          | -               | A         | 270164  | Gebbo's Bottomless Bag
Paladin      | Holy          | -               | A         | 270167  | Wavecaller's Seastone
Paladin      | Holy          | -               | A         | 250214  | Lightspire Core
Paladin      | Holy          | -               | A         | 248583  | Drum of Renewed Bonds
Paladin      | Holy          | -               | A         | 193757  | Ruby Whelp Shell
Paladin      | Holy          | -               | A         | 270169  | Hex Lord's Dooming Idol
Paladin      | Holy          | -               | B         | 274493  | Effigy of Ula'tek's Faithful
Paladin      | Holy          | -               | B         | 251792  | Glorious Crusader's Keepsake
Paladin      | Holy          | -               | B         | 273796  | Vile Vial of Volatile Venom
Paladin      | Holy          | -               | B         | 249343  | Gaze of the Alnseer
Paladin      | Holy          | -               | C         | 250254  | Seed of Radiant Hope
Paladin      | Holy          | -               | C         | 250248  | Mycolic Medicine
Paladin      | Holy          | -               | C         | 250255  | Unstable Felheart Crystal
Paladin      | Holy          | -               | D         | 270171  | Preternatural Antivenom
Paladin      | Holy          | -               | D         | 264507  | Crucible of Erratic Energies
Paladin      | Holy          | -               | D         | 264701  | Cosmic Bell
Paladin      | Protection    | -               | S         | 270173  | Zul'jin's Guillotine Technique
Paladin      | Protection    | -               | S         | 270175  | Voracious Heart of Ula'tek
Paladin      | Protection    | -               | A         | 270168  | Font of Venomous Rage
Paladin      | Protection    | -               | A         | 270164  | Gebbo's Bottomless Bag
Paladin      | Protection    | -               | A         | 281215  | Twisted Horror's Tendril
Paladin      | Protection    | -               | B         | 270602  | Venomous Gladiator's Badge of Ferocity
Paladin      | Protection    | -               | B         | 273796  | Vile Vial of Volatile Venom
Paladin      | Protection    | -               | B         | 158367  | Merektha's Fang
Paladin      | Protection    | -               | B         | 250259  | Sapling of the Dawnroot
Paladin      | Protection    | -               | Defensive | 270160  | First Mate's Shellward
Paladin      | Protection    | -               | Defensive | 250245  | Tumor of the Swarm
Paladin      | Protection    | -               | Defensive | 270174  | Idol of the Howling Nexus
Paladin      | Retribution   | -               | S         | 270173  | Zul'jin's Guillotine Technique
Paladin      | Retribution   | -               | S         | 270175  | Voracious Heart of Ula'tek
Paladin      | Retribution   | -               | B         | 270164  | Gebbo's Bottomless Bag
Paladin      | Retribution   | -               | B         | 270165  | Keeper's Seething Core
Paladin      | Retribution   | -               | B         | 273796  | Vile Vial of Volatile Venom
Paladin      | Retribution   | -               | B         | 193762  | Blazebinder's Hoof
Paladin      | Retribution   | -               | B         | 270168  | Font of Venomous Rage
Paladin      | Retribution   | -               | B         | 281215  | Twisted Horror's Tendril
Paladin      | Retribution   | -               | C         | 250259  | Sapling of the Dawnroot
Paladin      | Retribution   | -               | C         | 250228  | Resonant Bellowstone
Paladin      | Retribution   | -               | C         | 270163  | Sszorak's Ferocity
Paladin      | Retribution   | -               | C         | 158367  | Merektha's Fang
Paladin      | Retribution   | -               | C         | 250229  | Idol of the War Loa
Paladin      | Retribution   | -               | C         | 273797  | Tattered Amani War Banner
Paladin      | Retribution   | -               | C         | 250245  | Tumor of the Swarm
Paladin      | Retribution   | -               | D         | 250238  | Seed of the Devouring Wild
Paladin      | Retribution   | -               | D         | 273795  | Coiled Fangstone
Paladin      | Retribution   | -               | D         | 193757  | Ruby Whelp Shell
Priest       | Discipline    | -               | S         | 270167  | Wavecaller's Seastone
Priest       | Discipline    | -               | S         | 270162  | Soulcoiler Ritual Vessel
Priest       | Discipline    | -               | S         | 280835  | Sigil of the Impending Eclipse
Priest       | Discipline    | -               | S         | 270164  | Gebbo's Bottomless Bag
Priest       | Discipline    | -               | S         | 270169  | Hex Lord's Dooming Idol
Priest       | Discipline    | -               | S         | 281215  | Twisted Horror's Tendril
Priest       | Discipline    | -               | A         | 251792  | Glorious Crusader's Keepsake
Priest       | Discipline    | -               | A         | 248583  | Drum of Renewed Bonds
Priest       | Discipline    | -               | A         | 193757  | Ruby Whelp Shell
Priest       | Discipline    | -               | A         | 250214  | Lightspire Core
Priest       | Discipline    | -               | B         | 270603  | Venomous Gladiator's Insignia of Alacrity
Priest       | Discipline    | -               | B         | 273649  | Stormbound Emblem of Dazar
Priest       | Discipline    | -               | B         | 249343  | Gaze of the Alnseer
Priest       | Discipline    | -               | B         | 249341  | Volatile Void Suffuser
Priest       | Discipline    | -               | B         | 273796  | Vile Vial of Volatile Venom
Priest       | Discipline    | -               | B         | 250256  | Heart of Wind
Priest       | Discipline    | -               | B         | 250215  | Freightrunner's Flask
Priest       | Discipline    | -               | C         | 250248  | Mycolic Medicine
Priest       | Discipline    | -               | C         | 268292  | Sporelord's Mycelial Insignia
Priest       | Discipline    | -               | C         | 250255  | Unstable Felheart Crystal
Priest       | Discipline    | -               | C         | 250254  | Seed of Radiant Hope
Priest       | Discipline    | -               | C         | 193718  | Emerald Coach's Whistle
Priest       | Discipline    | -               | D         | 250224  | Mindpiercer's Sigil
Priest       | Discipline    | -               | D         | 270161  | Fang of Umbral Malignance
Priest       | Discipline    | -               | D         | 270170  | Vexhul's Everflowing Gland
Priest       | Discipline    | -               | D         | 273794  | Knot of Writhing Serpents
Priest       | Discipline    | -               | D         | 250259  | Sapling of the Dawnroot
Priest       | Discipline    | -               | D         | 158368  | Sethraliss' Defiled Relic
Priest       | Discipline    | -               | D         | 270171  | Preternatural Antivenom
Priest       | Holy          | -               | S         | 270162  | Soulcoiler Ritual Vessel
Priest       | Holy          | -               | A         | 270164  | Gebbo's Bottomless Bag
Priest       | Holy          | -               | B         | 193757  | Ruby Whelp Shell
Priest       | Holy          | -               | B         | 250214  | Lightspire Core
Priest       | Holy          | -               | B         | 270167  | Wavecaller's Seastone
Priest       | Holy          | -               | B         | 280835  | Sigil of the Impending Eclipse
Priest       | Holy          | -               | B         | 270169  | Hex Lord's Dooming Idol
Priest       | Holy          | -               | C         | 250215  | Freightrunner's Flask
Priest       | Holy          | -               | C         | 273796  | Vile Vial of Volatile Venom
Priest       | Holy          | -               | C         | 264507  | Crucible of Erratic Energies
Priest       | Holy          | -               | C         | 250248  | Mycolic Medicine
Priest       | Holy          | -               | C         | 249809  | Locus-Walker's Ribbon
Priest       | Holy          | -               | C         | 251792  | Glorious Crusader's Keepsake
Priest       | Holy          | -               | C         | 248583  | Drum of Renewed Bonds
Priest       | Holy          | -               | D         | 273649  | Stormbound Emblem of Dazar
Priest       | Holy          | -               | D         | 250254  | Seed of Radiant Hope
Priest       | Holy          | -               | D         | 250255  | Unstable Felheart Crystal
Priest       | Shadow        | -               | S         | 281215  | Twisted Horror's Tendril
Priest       | Shadow        | -               | A         | 270164  | Gebbo's Bottomless Bag
Priest       | Shadow        | -               | A         | 270169  | Hex Lord's Dooming Idol
Priest       | Shadow        | -               | A         | 270167  | Wavecaller's Seastone
Priest       | Shadow        | -               | A         | 250215  | Freightrunner's Flask
Priest       | Shadow        | -               | B         | 273796  | Vile Vial of Volatile Venom
Priest       | Shadow        | -               | B         | 250214  | Lightspire Core
Priest       | Shadow        | -               | B         | 250224  | Mindpiercer's Sigil
Priest       | Shadow        | -               | B         | 270170  | Vexhul's Everflowing Gland
Priest       | Shadow        | -               | B         | 273649  | Stormbound Emblem of Dazar
Priest       | Shadow        | -               | C         | 270161  | Fang of Umbral Malignance
Priest       | Shadow        | -               | C         | 248583  | Drum of Renewed Bonds
Priest       | Shadow        | -               | C         | 251792  | Glorious Crusader's Keepsake
Priest       | Shadow        | -               | C         | 250144  | Emberwing Feather
Priest       | Shadow        | -               | C         | 273794  | Knot of Writhing Serpents
Priest       | Shadow        | -               | C         | 250259  | Sapling of the Dawnroot
Priest       | Shadow        | -               | C         | 193757  | Ruby Whelp Shell
Priest       | Shadow        | -               | C         | 250256  | Heart of Wind
Priest       | Shadow        | -               | C         | 251786  | Ever-Collapsing Void Fissure
Priest       | Shadow        | -               | C         | 251785  | Void-Reaper's Libram
Priest       | Shadow        | -               | C         | 246304  | Darkmoon Dominion: Hunt
Rogue        | Assassination | -               | S         | 270175  | Voracious Heart of Ula'tek
Rogue        | Assassination | -               | S         | 281215  | Twisted Horror's Tendril
Rogue        | Assassination | -               | S         | 270168  | Font of Venomous Rage
Rogue        | Assassination | -               | A         | 270165  | Keeper's Seething Core
Rogue        | Assassination | -               | A         | 270173  | Zul'jin's Guillotine Technique
Rogue        | Assassination | -               | A         | 270164  | Gebbo's Bottomless Bag
Rogue        | Assassination | -               | B         | 159617  | Lustrous Golden Plumage
Rogue        | Assassination | -               | B         | 250228  | Resonant Bellowstone
Rogue        | Assassination | -               | B         | 250215  | Freightrunner's Flask
Rogue        | Assassination | -               | B         | 273796  | Vile Vial of Volatile Venom
Rogue        | Assassination | -               | B         | 270166  | Vashnik's Sanguine Rancor
Rogue        | Assassination | -               | B         | 250225  | Void Execution Mandate
Rogue        | Assassination | -               | B         | 250259  | Sapling of the Dawnroot
Rogue        | Assassination | -               | C         | 193757  | Ruby Whelp Shell
Rogue        | Assassination | -               | C         | 273797  | Tattered Amani War Banner
Rogue        | Assassination | -               | C         | 250214  | Lightspire Core
Rogue        | Assassination | -               | D         | 158374  | Tiny Electromental in a Jar
Rogue        | Assassination | -               | D         | 250245  | Tumor of the Swarm
Rogue        | Outlaw        | -               | S         | 270175  | Voracious Heart of Ula'tek
Rogue        | Outlaw        | -               | S         | 270173  | Zul'jin's Guillotine Technique
Rogue        | Outlaw        | -               | S         | 281215  | Twisted Horror's Tendril
Rogue        | Outlaw        | -               | A         | 270164  | Gebbo's Bottomless Bag
Rogue        | Outlaw        | -               | A         | 270165  | Keeper's Seething Core
Rogue        | Outlaw        | -               | A         | 250259  | Sapling of the Dawnroot
Rogue        | Outlaw        | -               | A         | 159617  | Lustrous Golden Plumage
Rogue        | Outlaw        | -               | A         | 273796  | Vile Vial of Volatile Venom
Rogue        | Outlaw        | -               | A         | 250214  | Lightspire Core
Rogue        | Outlaw        | -               | A         | 250215  | Freightrunner's Flask
Rogue        | Outlaw        | -               | A         | 250225  | Void Execution Mandate
Rogue        | Outlaw        | -               | B         | 273797  | Tattered Amani War Banner
Rogue        | Outlaw        | -               | B         | 250228  | Resonant Bellowstone
Rogue        | Outlaw        | -               | B         | 158374  | Tiny Electromental in a Jar
Rogue        | Outlaw        | -               | C         | 270166  | Vashnik's Sanguine Rancor
Rogue        | Outlaw        | -               | C         | 193757  | Ruby Whelp Shell
Rogue        | Outlaw        | -               | C         | 250245  | Tumor of the Swarm
Rogue        | Outlaw        | -               | D         | 270168  | Font of Venomous Rage
Rogue        | Subtlety      | -               | S         | 270175  | Voracious Heart of Ula'tek
Rogue        | Subtlety      | -               | S         | 270173  | Zul'jin's Guillotine Technique
Rogue        | Subtlety      | -               | S         | 270165  | Keeper's Seething Core
Rogue        | Subtlety      | -               | S         | 281215  | Twisted Horror's Tendril
Rogue        | Subtlety      | -               | A         | 250215  | Freightrunner's Flask
Rogue        | Subtlety      | -               | A         | 270164  | Gebbo's Bottomless Bag
Rogue        | Subtlety      | -               | A         | 270168  | Font of Venomous Rage
Rogue        | Subtlety      | -               | A         | 274493  | Effigy of Ula'tek's Faithful
Rogue        | Subtlety      | -               | A         | 248583  | Drum of Renewed Bonds
Rogue        | Subtlety      | -               | B         | 265657  | Fiber of Living Agony
Rogue        | Subtlety      | -               | B         | 250259  | Sapling of the Dawnroot
Rogue        | Subtlety      | -               | B         | 270166  | Vashnik's Sanguine Rancor
Rogue        | Subtlety      | -               | B         | 250228  | Resonant Bellowstone
Rogue        | Subtlety      | -               | B         | 250214  | Lightspire Core
Rogue        | Subtlety      | -               | B         | 159617  | Lustrous Golden Plumage
Rogue        | Subtlety      | -               | B         | 273796  | Vile Vial of Volatile Venom
Rogue        | Subtlety      | -               | C         | 250225  | Void Execution Mandate
Rogue        | Subtlety      | -               | C         | 158374  | Tiny Electromental in a Jar
Rogue        | Subtlety      | -               | C         | 241340  | Magister's Alchemist Stone
Rogue        | Subtlety      | -               | C         | 193757  | Ruby Whelp Shell
Rogue        | Subtlety      | -               | D         | 251785  | Void-Reaper's Libram
Rogue        | Subtlety      | -               | D         | 251783  | Lost Idol of the Hash'ey
Rogue        | Subtlety      | -               | D         | 274496  | Ophidian Bone Whistle
Rogue        | Subtlety      | -               | D         | 274497  | Spirit-Rending Poison
Rogue        | Subtlety      | -               | D         | 273797  | Tattered Amani War Banner
Rogue        | Subtlety      | -               | D         | 246307  | Darkmoon Dominion: Void
Rogue        | Subtlety      | -               | D         | 246304  | Darkmoon Dominion: Hunt
Rogue        | Subtlety      | -               | D         | 246305  | Darkmoon Dominion: Blood
Rogue        | Subtlety      | -               | D         | 246306  | Darkmoon Dominion: Rot
Shaman       | Elemental     | -               | S         | 281215  | Twisted Horror's Tendril
Shaman       | Elemental     | -               | S         | 270164  | Gebbo's Bottomless Bag
Shaman       | Elemental     | -               | S         | 250215  | Freightrunner's Flask
Shaman       | Elemental     | -               | S         | 270167  | Wavecaller's Seastone
Shaman       | Elemental     | -               | S         | 273796  | Vile Vial of Volatile Venom
Shaman       | Elemental     | -               | A         | 270161  | Fang of Umbral Malignance
Shaman       | Elemental     | -               | A         | 270170  | Vexhul's Everflowing Gland
Shaman       | Elemental     | -               | A         | 250214  | Lightspire Core
Shaman       | Elemental     | -               | A         | 273649  | Stormbound Emblem of Dazar
Shaman       | Elemental     | -               | B         | 270169  | Hex Lord's Dooming Idol
Shaman       | Elemental     | -               | B         | 251792  | Glorious Crusader's Keepsake
Shaman       | Elemental     | -               | B         | 248583  | Drum of Renewed Bonds
Shaman       | Elemental     | -               | B         | 273794  | Knot of Writhing Serpents
Shaman       | Elemental     | -               | B         | 245752  | Thalassian Competitor's Insignia of Alacrity
Shaman       | Elemental     | -               | C         | 193757  | Ruby Whelp Shell
Shaman       | Elemental     | -               | C         | 270168  | Font of Venomous Rage
Shaman       | Elemental     | -               | C         | 250259  | Sapling of the Dawnroot
Shaman       | Elemental     | -               | C         | 250224  | Mindpiercer's Sigil
Shaman       | Enhancement   | -               | S         | 270175  | Voracious Heart of Ula'tek
Shaman       | Enhancement   | -               | S         | 270173  | Zul'jin's Guillotine Technique
Shaman       | Enhancement   | -               | S         | 281215  | Twisted Horror's Tendril
Shaman       | Enhancement   | -               | A         | 273796  | Vile Vial of Volatile Venom
Shaman       | Enhancement   | -               | A         | 270165  | Keeper's Seething Core
Shaman       | Enhancement   | -               | A         | 270164  | Gebbo's Bottomless Bag
Shaman       | Enhancement   | -               | A         | 250225  | Void Execution Mandate
Shaman       | Enhancement   | -               | A         | 250228  | Resonant Bellowstone
Shaman       | Enhancement   | -               | B         | 159617  | Lustrous Golden Plumage
Shaman       | Enhancement   | -               | B         | 250215  | Freightrunner's Flask
Shaman       | Enhancement   | -               | B         | 250214  | Lightspire Core
Shaman       | Enhancement   | -               | B         | 248583  | Drum of Renewed Bonds
Shaman       | Enhancement   | -               | B         | 251792  | Glorious Crusader's Keepsake
Shaman       | Enhancement   | -               | B         | 270166  | Vashnik's Sanguine Rancor
Shaman       | Enhancement   | -               | C         | 270168  | Font of Venomous Rage
Shaman       | Enhancement   | -               | C         | 265657  | Fiber of Living Agony
Shaman       | Enhancement   | -               | C         | 250259  | Sapling of the Dawnroot
Shaman       | Enhancement   | -               | C         | 274493  | Effigy of Ula'tek's Faithful
Shaman       | Enhancement   | -               | C         | 158374  | Tiny Electromental in a Jar
Shaman       | Enhancement   | -               | C         | 251785  | Void-Reaper's Libram
Shaman       | Enhancement   | -               | C         | 273797  | Tattered Amani War Banner
Shaman       | Enhancement   | -               | D         | 274496  | Ophidian Bone Whistle
Shaman       | Enhancement   | -               | D         | 274497  | Spirit-Rending Poison
Shaman       | Enhancement   | -               | D         | 246304  | Darkmoon Dominion: Hunt
Shaman       | Enhancement   | -               | D         | 246305  | Darkmoon Dominion: Blood
Shaman       | Enhancement   | -               | D         | 246306  | Darkmoon Dominion: Rot
Shaman       | Enhancement   | -               | D         | 246307  | Darkmoon Dominion: Void
Shaman       | Enhancement   | -               | D         | 241340  | Magister's Alchemist Stone
Shaman       | Enhancement   | -               | D         | 251784  | Sylvan Wakrapuku
Shaman       | Enhancement   | -               | D         | 251783  | Lost Idol of the Hash'ey
Shaman       | Restoration   | -               | S         | 281215  | Twisted Horror's Tendril
Shaman       | Restoration   | -               | S         | 270164  | Gebbo's Bottomless Bag
Shaman       | Restoration   | -               | S         | 270162  | Soulcoiler Ritual Vessel
Shaman       | Restoration   | -               | S         | 270167  | Wavecaller's Seastone
Shaman       | Restoration   | -               | S         | 270169  | Hex Lord's Dooming Idol
Shaman       | Restoration   | -               | A         | 193757  | Ruby Whelp Shell
Shaman       | Restoration   | -               | A         | 250215  | Freightrunner's Flask
Shaman       | Restoration   | -               | A         | 248583  | Drum of Renewed Bonds
Shaman       | Restoration   | -               | A         | 251792  | Glorious Crusader's Keepsake
Shaman       | Restoration   | -               | B         | 250214  | Lightspire Core
Shaman       | Restoration   | -               | B         | 273796  | Vile Vial of Volatile Venom
Shaman       | Restoration   | -               | B         | 250255  | Unstable Felheart Crystal
Shaman       | Restoration   | -               | B         | 250254  | Seed of Radiant Hope
Shaman       | Restoration   | -               | C         | 250248  | Mycolic Medicine
Shaman       | Restoration   | -               | C         | 273649  | Stormbound Emblem of Dazar
Shaman       | Restoration   | -               | C         | 241291  | Primal Philosopher's Stone
Shaman       | Restoration   | -               | C         | 251788  | Gift of Light
Shaman       | Restoration   | -               | C         | 251789  | Consecrated Chalice
Warlock      | Affliction    | -               | S         | 273649  | Stormbound Emblem of Dazar
Warlock      | Affliction    | -               | S         | 281215  | Twisted Horror's Tendril
Warlock      | Affliction    | -               | A         | 270168  | Font of Venomous Rage
Warlock      | Affliction    | -               | A         | 270170  | Vexhul's Everflowing Gland
Warlock      | Affliction    | -               | A         | 270167  | Wavecaller's Seastone
Warlock      | Affliction    | -               | A         | 270164  | Gebbo's Bottomless Bag
Warlock      | Affliction    | -               | A         | 250214  | Lightspire Core
Warlock      | Affliction    | -               | A         | 250224  | Mindpiercer's Sigil
Warlock      | Affliction    | -               | B         | 270161  | Fang of Umbral Malignance
Warlock      | Affliction    | -               | B         | 273796  | Vile Vial of Volatile Venom
Warlock      | Affliction    | -               | B         | 250215  | Freightrunner's Flask
Warlock      | Affliction    | -               | B         | 273794  | Knot of Writhing Serpents
Warlock      | Affliction    | -               | C         | 270169  | Hex Lord's Dooming Idol
Warlock      | Affliction    | -               | C         | 250259  | Sapling of the Dawnroot
Warlock      | Affliction    | -               | C         | 193757  | Ruby Whelp Shell
Warlock      | Affliction    | -               | C         | 158368  | Sethraliss' Defiled Relic
Warlock      | Demonology    | -               | S         | 273649  | Stormbound Emblem of Dazar
Warlock      | Demonology    | -               | S         | 281215  | Twisted Horror's Tendril
Warlock      | Demonology    | -               | A         | 273796  | Vile Vial of Volatile Venom
Warlock      | Demonology    | -               | A         | 270167  | Wavecaller's Seastone
Warlock      | Demonology    | -               | A         | 270164  | Gebbo's Bottomless Bag
Warlock      | Demonology    | -               | A         | 270169  | Hex Lord's Dooming Idol
Warlock      | Demonology    | -               | A         | 270170  | Vexhul's Everflowing Gland
Warlock      | Demonology    | -               | B         | 250224  | Mindpiercer's Sigil
Warlock      | Demonology    | -               | B         | 250214  | Lightspire Core
Warlock      | Demonology    | -               | B         | 250215  | Freightrunner's Flask
Warlock      | Demonology    | -               | B         | 270168  | Font of Venomous Rage
Warlock      | Demonology    | -               | C         | 273794  | Knot of Writhing Serpents
Warlock      | Demonology    | -               | C         | 270161  | Fang of Umbral Malignance
Warlock      | Demonology    | -               | C         | 250259  | Sapling of the Dawnroot
Warlock      | Demonology    | -               | C         | 193757  | Ruby Whelp Shell
Warlock      | Demonology    | -               | C         | 158368  | Sethraliss' Defiled Relic
Warlock      | Destruction   | -               | S         | 250215  | Freightrunner's Flask
Warlock      | Destruction   | -               | S         | 281215  | Twisted Horror's Tendril
Warlock      | Destruction   | -               | A         | 270164  | Gebbo's Bottomless Bag
Warlock      | Destruction   | -               | A         | 270167  | Wavecaller's Seastone
Warlock      | Destruction   | -               | A         | 270168  | Font of Venomous Rage
Warlock      | Destruction   | -               | A         | 270170  | Vexhul's Everflowing Gland
Warlock      | Destruction   | -               | A         | 273649  | Stormbound Emblem of Dazar
Warlock      | Destruction   | -               | B         | 270169  | Hex Lord's Dooming Idol
Warlock      | Destruction   | -               | B         | 273796  | Vile Vial of Volatile Venom
Warlock      | Destruction   | -               | B         | 250214  | Lightspire Core
Warlock      | Destruction   | -               | B         | 250224  | Mindpiercer's Sigil
Warlock      | Destruction   | -               | C         | 250259  | Sapling of the Dawnroot
Warlock      | Destruction   | -               | C         | 270161  | Fang of Umbral Malignance
Warlock      | Destruction   | -               | C         | 273794  | Knot of Writhing Serpents
Warlock      | Destruction   | -               | C         | 193757  | Ruby Whelp Shell
Warlock      | Destruction   | -               | C         | 158368  | Sethraliss' Defiled Relic
Warrior      | Arms          | -               | S         | 270173  | Zul'jin's Guillotine Technique
Warrior      | Arms          | -               | S         | 270175  | Voracious Heart of Ula'tek
Warrior      | Arms          | -               | S         | 270164  | Gebbo's Bottomless Bag
Warrior      | Arms          | -               | A         | 273796  | Vile Vial of Volatile Venom
Warrior      | Arms          | -               | A         | 250229  | Idol of the War Loa
Warrior      | Arms          | -               | A         | 270165  | Keeper's Seething Core
Warrior      | Arms          | -               | A         | 250238  | Seed of the Devouring Wild
Warrior      | Arms          | -               | A         | 250259  | Sapling of the Dawnroot
Warrior      | Arms          | -               | B         | 193757  | Ruby Whelp Shell
Warrior      | Arms          | -               | B         | 250228  | Resonant Bellowstone
Warrior      | Arms          | -               | B         | 193762  | Blazebinder's Hoof
Warrior      | Arms          | -               | B         | 270168  | Font of Venomous Rage
Warrior      | Arms          | -               | C         | 273797  | Tattered Amani War Banner
Warrior      | Arms          | -               | C         | 270163  | Sszorak's Ferocity
Warrior      | Arms          | -               | C         | 273795  | Coiled Fangstone
Warrior      | Arms          | -               | C         | 158367  | Merektha's Fang
Warrior      | Fury          | -               | S         | 270173  | Zul'jin's Guillotine Technique
Warrior      | Fury          | -               | S         | 270175  | Voracious Heart of Ula'tek
Warrior      | Fury          | -               | S         | 270164  | Gebbo's Bottomless Bag
Warrior      | Fury          | -               | A         | 273796  | Vile Vial of Volatile Venom
Warrior      | Fury          | -               | A         | 250229  | Idol of the War Loa
Warrior      | Fury          | -               | A         | 270165  | Keeper's Seething Core
Warrior      | Fury          | -               | A         | 250238  | Seed of the Devouring Wild
Warrior      | Fury          | -               | A         | 250259  | Sapling of the Dawnroot
Warrior      | Fury          | -               | B         | 193757  | Ruby Whelp Shell
Warrior      | Fury          | -               | B         | 250228  | Resonant Bellowstone
Warrior      | Fury          | -               | B         | 193762  | Blazebinder's Hoof
Warrior      | Fury          | -               | B         | 270168  | Font of Venomous Rage
Warrior      | Fury          | -               | C         | 273797  | Tattered Amani War Banner
Warrior      | Fury          | -               | C         | 270163  | Sszorak's Ferocity
Warrior      | Fury          | -               | C         | 273795  | Coiled Fangstone
Warrior      | Fury          | -               | C         | 158367  | Merektha's Fang
Warrior      | Protection    | -               | S         | 270173  | Zul'jin's Guillotine Technique
Warrior      | Protection    | -               | S         | 270175  | Voracious Heart of Ula'tek
Warrior      | Protection    | -               | A         | 270165  | Keeper's Seething Core
Warrior      | Protection    | -               | A         | 273795  | Coiled Fangstone
Warrior      | Protection    | -               | A         | 273796  | Vile Vial of Volatile Venom
Warrior      | Protection    | -               | A         | 250245  | Tumor of the Swarm
Warrior      | Protection    | -               | A         | 270164  | Gebbo's Bottomless Bag
Warrior      | Protection    | -               | B         | 250228  | Resonant Bellowstone
Warrior      | Protection    | -               | B         | 270163  | Sszorak's Ferocity
Warrior      | Protection    | -               | B         | 270174  | Idol of the Howling Nexus
Warrior      | Protection    | -               | B         | 193757  | Ruby Whelp Shell
Warrior      | Protection    | -               | B         | 250229  | Idol of the War Loa
Warrior      | Protection    | -               | Defensive | 270160  | First Mate's Shellward
Warrior      | Protection    | -               | Defensive | 159618  | Mchimba's Ritual Bandages
Warrior      | Protection    | Mythic+         | S         | 281215  | Twisted Horror's Tendril
Warrior      | Protection    | Mythic+         | B         | 250238  | Seed of the Devouring Wild
Warrior      | Protection    | Mythic+         | B         | 158367  | Merektha's Fang
Warrior      | Protection    | Raid            | A         | 281215  | Twisted Horror's Tendril
]]
