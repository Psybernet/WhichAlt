local _, ns = ...

-- Where this table came from. The weapons each spec uses were checked
-- against the Icy Veins best-in-slot pages and their weapon FAQs.
ns.WeaponDataInfo = { source = "Icy Veins", patch = "12.1.5", updated = "2026-10-26" }

--[[
WhichAlt weapon rules: which weapons, shields and off-hand items each spec
actually uses. A weapon only lists specs that use that kind of weapon, so a
polearm won't suggest Marksmanship Hunter even if its stats match.

  - One line per spec. A spec that can fight in two styles (for example
    two-handed or dual wield) gets a line per style with a Build name, and
    the tooltip shows that name in brackets: "Frost Death Knight (Dual Wield)".
    Use "-" as the Build when the spec has only one style.
  - Columns are separated by "|". Spacing doesn't matter.
  - Weapons are separated by commas and must be from this list:
      1H Axe, 2H Axe, 1H Mace, 2H Mace, 1H Sword, 2H Sword, Polearm, Staff,
      Dagger, Fist Weapon, Warglaive, Bow, Gun, Crossbow, Wand,
      Shield, Off-hand Item
    ("Off-hand Item" means held-in-off-hand items such as orbs and tomes.)
  - Lines starting with # are ignored.

Armor (cloth, leather, mail, plate) still follows the class, so it isn't here.
If a line has a mistake, WhichAlt prints that line in chat on login.
]]

ns.WeaponText = [[
Class        | Spec          | Build       | Weapons

Death Knight | Blood         | -           | 2H Axe, 2H Mace, 2H Sword, Polearm
Death Knight | Frost         | Dual Wield  | 1H Axe, 1H Mace, 1H Sword
Death Knight | Frost         | Two-Hand    | 2H Axe, 2H Mace, 2H Sword, Polearm
Death Knight | Unholy        | -           | 2H Axe, 2H Mace, 2H Sword, Polearm

Demon Hunter | Havoc         | -           | Warglaive, 1H Axe, 1H Sword, Fist Weapon
Demon Hunter | Vengeance     | -           | Warglaive, 1H Axe, 1H Sword, Fist Weapon
Demon Hunter | Devourer      | -           | Dagger, 1H Sword

Druid        | Balance       | -           | Staff, 1H Mace, Dagger, Fist Weapon, Off-hand Item
Druid        | Feral         | -           | Staff, Polearm, 2H Mace
Druid        | Guardian      | -           | Staff, Polearm, 2H Mace
Druid        | Restoration   | -           | Staff, 1H Mace, Dagger, Fist Weapon, Off-hand Item

Evoker       | Devastation   | -           | Staff, Dagger, 1H Sword, 1H Mace, 1H Axe, Fist Weapon, Off-hand Item
Evoker       | Preservation  | -           | Staff, Dagger, 1H Sword, 1H Mace, 1H Axe, Fist Weapon, Off-hand Item
Evoker       | Augmentation  | -           | Staff, Dagger, 1H Sword, 1H Mace, 1H Axe, Fist Weapon, Off-hand Item

Hunter       | Beast Mastery | -           | Bow, Gun, Crossbow
Hunter       | Marksmanship  | -           | Bow, Gun, Crossbow
Hunter       | Survival      | Two-Hand    | Polearm, Staff, 2H Axe, 2H Sword
Hunter       | Survival      | Dual Wield  | Dagger, 1H Axe, 1H Sword, Fist Weapon

Mage         | Arcane        | -           | Staff, Dagger, 1H Sword, Wand, Off-hand Item
Mage         | Fire          | -           | Staff, Dagger, 1H Sword, Wand, Off-hand Item
Mage         | Frost         | -           | Staff, Dagger, 1H Sword, Wand, Off-hand Item

Monk         | Brewmaster    | Two-Hand    | Staff, Polearm
Monk         | Brewmaster    | Dual Wield  | 1H Axe, 1H Mace, 1H Sword, Fist Weapon
Monk         | Mistweaver    | -           | Staff, 1H Axe, 1H Mace, 1H Sword, Fist Weapon, Off-hand Item
Monk         | Windwalker    | -           | Staff, Polearm

Paladin      | Holy          | -           | 1H Axe, 1H Mace, 1H Sword, Shield, Off-hand Item
Paladin      | Protection    | -           | 1H Axe, 1H Mace, 1H Sword, Shield
Paladin      | Retribution   | -           | 2H Axe, 2H Mace, 2H Sword, Polearm

Priest       | Discipline    | -           | Staff, Dagger, 1H Mace, Wand, Off-hand Item
Priest       | Holy          | -           | Staff, Dagger, 1H Mace, Wand, Off-hand Item
Priest       | Shadow        | -           | Staff, Dagger, 1H Mace, Wand, Off-hand Item

Rogue        | Assassination | -           | Dagger
Rogue        | Outlaw        | -           | 1H Axe, 1H Mace, 1H Sword, Fist Weapon, Dagger
Rogue        | Subtlety      | -           | Dagger

Shaman       | Elemental     | -           | Staff, 1H Axe, 1H Mace, Dagger, Fist Weapon, Shield, Off-hand Item
Shaman       | Enhancement   | -           | 1H Axe, 1H Mace, Fist Weapon
Shaman       | Restoration   | -           | Staff, 1H Axe, 1H Mace, Dagger, Fist Weapon, Shield, Off-hand Item

Warlock      | Affliction    | -           | Staff, Dagger, 1H Sword, Wand, Off-hand Item
Warlock      | Demonology    | -           | Staff, Dagger, 1H Sword, Wand, Off-hand Item
Warlock      | Destruction   | -           | Staff, Dagger, 1H Sword, Wand, Off-hand Item

Warrior      | Arms          | -           | 2H Axe, 2H Mace, 2H Sword, Polearm, Staff
Warrior      | Fury          | -           | 2H Axe, 2H Mace, 2H Sword, Polearm, Staff
Warrior      | Protection    | -           | 1H Axe, 1H Mace, 1H Sword, Fist Weapon, Dagger, Shield
]]
