# <img src="images/icon.png" width="32" height="32" alt=""> WhichClass

A World of Warcraft addon that adds a short section to gear tooltips showing **which class and spec the item's secondary stats suit**. For example, a leather item with Haste and Versatility lists *Guardian Druid*, because those are its top two stats.

Stat priorities and trinket ratings come from [Icy Veins](https://www.icy-veins.com/wow/) (patch 12.1.5, Midnight). You can override any spec's priority in the game.

<p>
  <img src="images/tooltip-match.jpg" alt="WhichClass tooltip section listing the specs that suit a pair of leather shoulders">
  &nbsp;
  <img src="images/tooltip-cloak.jpg" alt="WhichClass tooltip section listing the specs that suit a cloak">
</p>

## Features

- **Spec matches in the tooltip**, in class colours. When a spec has different priorities for different builds (hero talents, Raid vs Mythic+, survivability vs damage), the matching build is shown in brackets, such as *Brewmaster Monk (Survivability build)*.
- **Only specs that can use the item**: it checks armor type, weapon type, shields and the item's main stat (Strength, Agility or Intellect).
- **Second best and very low ratings**: when no spec has the item's stats as its top two, it lists the specs it's second best for, or warns that the stats are very low for everyone.
- **Trinket ratings**: the Icy Veins tier (S, A, B…) for every spec that rates the trinket.
- **Settings window** to turn each part on or off.
- **Customise tab**: drag a spec's stats into your own order and save it.
- **Light on performance**: nothing runs on a timer. Results are worked out once per item and cached.

## Installing

1. Download the latest code: **Code → Download ZIP**.
2. Extract it into `World of Warcraft\_retail_\Interface\AddOns\`.
3. Rename the folder from `WhichClass-main` to **`WhichClass`**. The game only loads it if the folder name matches the `.toc` file.
4. Restart the game, or type `/reload` if it was already running.

A **WC** button on the minimap shows that it has loaded.

## Using it

Hover over any piece of gear. The WhichClass section appears at the bottom of the tooltip.

| Action | What it does |
|---|---|
| Left-click the minimap button | Opens settings |
| Right-click the minimap button | Turns WhichClass tooltips on or off (the icon greys out while off) |
| Drag the minimap button | Moves it around the minimap |
| `/wc` | Opens settings |
| `/wc minimap` | Hides or shows the minimap button |

### How items are rated

Each spec has an order for the four secondary stats, for example Blood Death Knight (Deathbringer): **Critical Strike > Mastery = Versatility > Haste**. Stats joined by `=` are tied.

- **Top match**: both of the item's secondary stats are in the spec's best two places. Tied stats share a place, so in the example above Critical Strike, Mastery and Versatility all count.
- **Second best**: otherwise, both stats are within the first three priority levels, counting tied stats as one level. In the example, Haste is level 3, so any pair with Haste is second best.
- **Very low**: everything else.

The full list for every spec is in the reference image below.

## Settings

<img src="images/settings-general.jpg" width="640" alt="General settings tab">

| Option | Default |
|---|---|
| Show WhichClass in tooltips (same as right-clicking the minimap button) | On |
| Show lower quality ratings ("second best" and "very low") | On |
| Show off-hand items (shields, off-hand weapons and held items) | On |
| Show trinket ratings | On |
| Only Bind on Equip and Warbound items | On |

Turn off **Only Bind on Equip and Warbound items** to see WhichClass on soulbound gear too, such as dungeon and raid drops.

### Customising stat priorities

<img src="images/settings-customise.jpg" width="640" alt="Customise settings tab">

1. Pick a class, spec and (where there's more than one) build.
2. Drag the stat boxes into your order, and choose `>` (better than) or `=` (equal to) between them. Under each box you can see how the tooltip will treat that stat.
3. Press **Save**. The row flashes green and the spec shows as using your custom priority. Specs you've changed get a gold `*` in the dropdowns.

**Reset to default** puts the current spec back to the Icy Veins priority. **Reset all specs** clears every custom priority, after asking first.

## Stat priority reference

![Secondary stat priority for every class and spec](images/stat-priority-reference.png)

## Data files

The data is kept in readable tables so it's easy to update when Icy Veins changes its recommendations.

| File | What it holds |
|---|---|
| [`SpecData.lua`](SpecData.lua) | Each spec's main stat and secondary stat priority, with notes on the format at the top |
| [`TrinketData.lua`](TrinketData.lua) | Trinket tiers per spec, matched by item ID so it works in every game language |
| [`Data.lua`](Data.lua) | Which armor and weapon types each class can use |

If a row in `SpecData.lua` or `TrinketData.lua` has a mistake, WhichClass prints the row in chat when you log in.

### Tools

Both need Python 3.

```bash
pip install beautifulsoup4 html5lib pillow
```

Rebuild `TrinketData.lua` from the Icy Veins trinket rankings:

```bash
python tools/update_trinkets.py
```

Redraw the reference image from `SpecData.lua`:

```bash
python tools/make_reference.py
```

## Credits

Stat priorities and trinket ratings: [Icy Veins](https://www.icy-veins.com/wow/) class guides. WhichClass isn't affiliated with Icy Veins or Blizzard Entertainment.

## License

[MIT](LICENSE) © 2026 Martin Heine
