# Changelog

All notable changes to WhichAlt. Versions follow [semantic versioning](https://semver.org/): the last number for fixes, the middle one for new features, the first for big changes.

## [1.4.0] - 2026-10-26

### Added
- Weapon rules per spec (`WeaponData.lua`): weapons, shields and off-hand items only list specs that actually use them, checked against the Icy Veins best-in-slot pages. For example, a polearm no longer suggests Marksmanship Hunter, and Agility daggers only suggest Assassination, Outlaw and dual-wield Survival.
- Specs that can fight two-handed or dual wield (Frost Death Knight, Survival Hunter, Brewmaster Monk) show which style fits in brackets, such as *Frost Death Knight (Dual Wield)*.
- Weapon rules appear in the data status at the bottom of Settings → General.

### Fixed
- Devourer Demon Hunters can now be suggested for daggers.

## [1.3.0] - 2026-10-26

### Added
- Version and data status at the bottom of Settings → General: the WhichAlt version, where the stat and trinket data came from, which patch it's for, when it was updated, and whether it's up to date with the game.
- A one-time chat note when the game is on a newer patch than the data.
- Version number in the minimap button's tooltip.
- Release packaging: tagging a version on GitHub builds a ready-to-install `WhichAlt` zip on the Releases page.

## [1.2.0] - 2026-10-26

### Changed
- Renamed the addon from WhichClass to WhichAlt, with a WA minimap icon.
- Slash commands are now `/whichalt` and `/walt` (`/walt minimap` hides or shows the minimap button).
- Settings are saved under the new name, so earlier WhichClass settings and roles don't carry over.

## [1.1.0] - 2026-10-21

### Added
- Custom roles: New role and Delete role in the Customise tab. Your roles show in tooltips in brackets.
- Class, Spec and Role labels above the Customise dropdowns.
- "Only show tooltip for" section in General, with separate Bind on Equip, Warbound and Soulbound options alongside off-hand items and trinkets.

## [1.0.0] - 2026-10-20

### Added
- Tooltip section listing the class and specs whose top two secondary stats an item has, in class colours, with build names in brackets where specs differ by build.
- Filtering by armor type, weapon type, shields and main stat.
- Tied stats (`=`) in stat priorities, "second best" and "very low" ratings.
- Icy Veins trinket tiers for every spec.
- Settings window (General and Customise tabs) with drag-and-drop custom stat priorities.
- Minimap button: left-click for settings, right-click to turn tooltips on or off.
- Readable data tables (`SpecData.lua`, `TrinketData.lua`) and tools to rebuild the trinket data and the reference image.
