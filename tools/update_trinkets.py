"""Rebuilds WhichClass/TrinketData.lua from the Icy Veins trinket rankings.

Usage: python tools/update_trinkets.py [path to TrinketData.lua]

Each spec's "Best in Slot Gear" page has a trinket table with tiers (S, A,
B, ...) and one or more columns (Raid / Mythic+, or hero talents). A trinket
with the same tier in every column gets one row with Content "-"; otherwise
it gets a row per column it appears in.
"""
import os
import sys
import time
import urllib.request

from bs4 import BeautifulSoup  # also needs html5lib: pip install beautifulsoup4 html5lib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "TrinketData.lua")

SPECS = [
    ("blood", "death-knight", "tank"), ("frost", "death-knight", "dps"), ("unholy", "death-knight", "dps"),
    ("havoc", "demon-hunter", "dps"), ("vengeance", "demon-hunter", "tank"), ("devourer", "demon-hunter", "dps"),
    ("balance", "druid", "dps"), ("feral", "druid", "dps"), ("guardian", "druid", "tank"), ("restoration", "druid", "healing"),
    ("devastation", "evoker", "dps"), ("preservation", "evoker", "healing"), ("augmentation", "evoker", "dps"),
    ("beast-mastery", "hunter", "dps"), ("marksmanship", "hunter", "dps"), ("survival", "hunter", "dps"),
    ("arcane", "mage", "dps"), ("fire", "mage", "dps"), ("frost", "mage", "dps"),
    ("brewmaster", "monk", "tank"), ("mistweaver", "monk", "healing"), ("windwalker", "monk", "dps"),
    ("holy", "paladin", "healing"), ("protection", "paladin", "tank"), ("retribution", "paladin", "dps"),
    ("discipline", "priest", "healing"), ("holy", "priest", "healing"), ("shadow", "priest", "dps"),
    ("assassination", "rogue", "dps"), ("outlaw", "rogue", "dps"), ("subtlety", "rogue", "dps"),
    ("elemental", "shaman", "dps"), ("enhancement", "shaman", "dps"), ("restoration", "shaman", "healing"),
    ("affliction", "warlock", "dps"), ("demonology", "warlock", "dps"), ("destruction", "warlock", "dps"),
    ("arms", "warrior", "dps"), ("fury", "warrior", "dps"), ("protection", "warrior", "tank"),
]
TIER_ORDER = ["S", "A", "B", "C", "D", "E", "F", "F-", "Defensive"]
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0 Safari/537.36"


def title(slug):
    return " ".join(w.capitalize() for w in slug.split("-"))


def clean(text):
    return " ".join(text.split())


def tier_name(text):
    text = clean(text)
    if "defensive" in text.lower():
        return "Defensive"
    return text.removesuffix(" Tier").removesuffix(" tier").strip()


def column_name(text):
    text = clean(text)
    return "Raid" if text.lower() in ("raid", "raiding") else text


def tier_rank(tier):
    return TIER_ORDER.index(tier) if tier in TIER_ORDER else len(TIER_ORDER)


def item_id(span):
    ref = span["data-iv-tooltip"]
    return ref.split("item/")[1].split("?")[0]


def scrape(spec, cls, role):
    url = f"https://www.icy-veins.com/wow/{spec}-{cls}-pve-{role}-gear-best-in-slot"
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    html = urllib.request.urlopen(req, timeout=30).read().decode("utf-8")
    # html5lib parses like a browser; html.parser mis-nests some of these tables.
    table = BeautifulSoup(html, "html5lib").select_one("details.trinket-dropdown table")
    if table is None:
        raise RuntimeError(f"no trinket table on {url}")

    rows = table.find_all("tr")
    columns = [column_name(c.get_text()) for c in rows[0].find_all(["th", "td"])[1:]]
    trinkets = {}  # id -> {"name", "tiers": [tier per column]}
    for row in rows[1:]:
        cells = row.find_all(["th", "td"], recursive=False)
        tier = tier_name(cells[0].get_text())
        for col, cell in enumerate(cells[1:]):
            for entry in cell.select(":scope > ul > li, :scope > ul > details"):
                span = (entry.select_one('summary [data-iv-tooltip*="/item/"]')
                        or entry.select_one('[data-iv-tooltip*="/item/"]'))
                if span is None:
                    continue
                tid = item_id(span)
                t = trinkets.setdefault(tid, {"name": clean(span.get_text()), "tiers": [None] * len(columns)})
                current = t["tiers"][col]
                if current is None or tier_rank(tier) < tier_rank(current):
                    t["tiers"][col] = tier

    out = []
    for tid, t in trinkets.items():
        tiers = t["tiers"]
        if len(columns) == 1 or all(x == tiers[0] for x in tiers):
            out.append(("-", tiers[0], tid, t["name"]))
        else:
            out += [(columns[c], tier, tid, t["name"]) for c, tier in enumerate(tiers) if tier]
    out.sort(key=lambda r: (r[0] != "-", r[0], tier_rank(r[1])))
    return out


lines = []
for spec, cls, role in SPECS:
    rows = scrape(spec, cls, role)
    print(f"{title(spec)} {title(cls)}: {len(rows)} rows")
    for content, tier, tid, name in rows:
        lines.append(f"{title(cls):<12} | {title(spec):<13} | {content:<15} | {tier:<9} | {tid:<7} | {name}")
    time.sleep(0.5)

header = '''local _, ns = ...

--[[
WhichClass trinket ratings, from the Icy Veins "Best in Slot Gear" pages
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

'''
with open(OUT, "w", encoding="utf-8", newline="\n") as f:
    f.write(header + "\n".join(lines) + "\n]]\n")
print(f"Wrote {len(lines)} rows to {OUT}")
