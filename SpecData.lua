local _, ns = ...

--[[
WhichClass spec data. Edit the table below when stat priorities change.

  - One line per spec. If a spec has more than one recommended priority
    (hero talents, raid vs Mythic+, survivability vs damage), give each its
    own line with a Build name. Use "-" as the Build when there's only one.
  - Columns are separated by "|". Spacing doesn't matter.
  - Primary is Strength, Agility or Intellect.
  - Secondary stats go best first and must be exactly:
      Critical Strike, Haste, Mastery, Versatility
    Put one of these between each pair:
      >    better than
      =    equal to (same priority)
      >=   better than or equal to (counted as > by the tooltip)
  - Class must be one of: Death Knight, Demon Hunter, Druid, Evoker, Hunter,
    Mage, Monk, Paladin, Priest, Rogue, Shaman, Warlock, Warrior
  - Lines starting with # are ignored.

How the tooltip uses it:
  - Top match: both of the item's stats are in the build's best two.
    Stats tied for a place share it, so in
      Critical Strike > Mastery = Versatility > Haste
    Crit + Mastery, Crit + Versatility and Mastery + Versatility all count.
  - Second best: otherwise, both stats are within the first three
    priority levels, counting tied stats as one level. In the example
    above, Haste is level 3, so any pair with Haste is second best.
  - Very low: everything else (pairs that include a level 4 stat).

If a line has a mistake, WhichClass prints that line in chat on login.

Source: Icy Veins stat priority widgets, patch 12.1.5 (October 2026).
]]

ns.SpecText = [[
Class        | Spec          | Primary   | Build                 | Secondary stats (best first)

Death Knight | Blood         | Strength  | San'layn              | Haste >= Critical Strike > Mastery >= Versatility
Death Knight | Blood         | Strength  | Deathbringer          | Critical Strike > Mastery = Versatility > Haste
Death Knight | Frost         | Strength  | -                     | Critical Strike > Haste = Mastery > Versatility
Death Knight | Unholy        | Strength  | -                     | Critical Strike >= Mastery >= Haste > Versatility

Demon Hunter | Havoc         | Agility   | -                     | Critical Strike > Mastery > Haste > Versatility
Demon Hunter | Vengeance     | Agility   | -                     | Haste > Mastery = Versatility = Critical Strike
Demon Hunter | Devourer      | Intellect | -                     | Mastery > Haste > Critical Strike > Versatility

Druid        | Balance       | Intellect | Elune's Chosen        | Mastery > Haste > Critical Strike > Versatility
Druid        | Balance       | Intellect | Keeper of the Grove   | Mastery > Critical Strike > Haste > Versatility
Druid        | Feral         | Agility   | Single-Target         | Mastery > Haste = Critical Strike > Versatility
Druid        | Feral         | Agility   | AoE                   | Mastery > Critical Strike > Haste > Versatility
Druid        | Guardian      | Agility   | Survivability build   | Haste > Versatility > Mastery > Critical Strike
Druid        | Guardian      | Agility   | Damage build          | Haste > Versatility > Critical Strike = Mastery
Druid        | Restoration   | Intellect | -                     | Haste = Mastery > Versatility > Critical Strike

Evoker       | Devastation   | Intellect | -                     | Critical Strike > Haste = Mastery > Versatility
Evoker       | Preservation  | Intellect | -                     | Mastery > Critical Strike > Haste > Versatility
Evoker       | Augmentation  | Intellect | -                     | Mastery > Critical Strike = Haste > Versatility

Hunter       | Beast Mastery | Agility   | Single-Target         | Mastery > Haste > Critical Strike > Versatility
Hunter       | Beast Mastery | Agility   | Mythic+               | Mastery > Critical Strike > Versatility > Haste
Hunter       | Marksmanship  | Agility   | -                     | Critical Strike > Mastery > Versatility > Haste
Hunter       | Survival      | Agility   | -                     | Mastery > Critical Strike > Haste > Versatility

Mage         | Arcane        | Intellect | -                     | Haste > Critical Strike > Mastery > Versatility
Mage         | Fire          | Intellect | -                     | Haste > Mastery > Versatility > Critical Strike
Mage         | Frost         | Intellect | -                     | Mastery = Critical Strike > Haste > Versatility

Monk         | Brewmaster    | Agility   | Survivability build   | Critical Strike = Versatility = Mastery > Haste
Monk         | Brewmaster    | Agility   | Damage build          | Critical Strike = Mastery > Versatility > Haste
Monk         | Mistweaver    | Intellect | Raid                  | Haste > Critical Strike > Versatility > Mastery
Monk         | Mistweaver    | Intellect | Mythic+               | Haste > Mastery >= Critical Strike > Versatility
Monk         | Windwalker    | Agility   | -                     | Haste = Critical Strike = Mastery > Versatility

Paladin      | Holy          | Intellect | Herald of the Sun     | Mastery > Haste > Critical Strike > Versatility
Paladin      | Holy          | Intellect | Lightsmith            | Mastery > Critical Strike > Haste > Versatility
Paladin      | Holy          | Intellect | Mythic+               | Mastery > Haste > Critical Strike > Versatility
Paladin      | Protection    | Strength  | Survivability build   | Haste > Versatility = Mastery > Critical Strike
Paladin      | Protection    | Strength  | Damage build          | Haste > Critical Strike > Versatility = Mastery
Paladin      | Retribution   | Strength  | -                     | Mastery > Haste = Critical Strike > Versatility

Priest       | Discipline    | Intellect | -                     | Haste > Mastery > Critical Strike > Versatility
Priest       | Holy          | Intellect | Raid                  | Critical Strike > Mastery = Versatility > Haste
Priest       | Holy          | Intellect | Mythic+               | Critical Strike > Versatility = Haste > Mastery
Priest       | Shadow        | Intellect | -                     | Haste >= Mastery > Critical Strike > Versatility

Rogue        | Assassination | Agility   | -                     | Critical Strike = Haste > Mastery > Versatility
Rogue        | Outlaw        | Agility   | -                     | Critical Strike > Haste > Versatility > Mastery
Rogue        | Subtlety      | Agility   | -                     | Mastery > Haste > Versatility > Critical Strike

Shaman       | Elemental     | Intellect | -                     | Mastery > Haste = Critical Strike > Versatility
Shaman       | Enhancement   | Agility   | Stormbringer          | Critical Strike = Mastery = Haste > Versatility
Shaman       | Enhancement   | Agility   | Totemic               | Mastery = Haste > Critical Strike > Versatility
Shaman       | Restoration   | Intellect | -                     | Critical Strike > Versatility = Haste > Mastery

Warlock      | Affliction    | Intellect | -                     | Haste = Critical Strike > Mastery > Versatility
Warlock      | Demonology    | Intellect | -                     | Haste > Critical Strike > Mastery > Versatility
Warlock      | Destruction   | Intellect | -                     | Haste > Critical Strike > Mastery > Versatility

Warrior      | Arms          | Strength  | -                     | Critical Strike > Haste > Mastery > Versatility
Warrior      | Fury          | Strength  | -                     | Mastery > Haste > Versatility > Critical Strike
Warrior      | Protection    | Strength  | -                     | Haste > Critical Strike = Versatility > Mastery
]]
