"""Draws the WhichClass stat priority reference image from SpecData.lua.

Usage: python tools/make_reference.py [SpecData.lua] [output.png]

With no arguments it reads SpecData.lua and writes images/stat-priority-reference.png
in the addon folder.
"""
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "SpecData.lua")
out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(ROOT, "images", "stat-priority-reference.png")
text = open(src, encoding="utf-8").read()
table = re.search(r"ns\.SpecText = \[\[(.*?)\]\]", text, re.S).group(1)

# Each row's stats as (name, separator before it, place, level), matching
# the tooltip: ties share a place (1, 2, 2, 4) and a level (1, 2, 2, 3).
rows = []
for line in table.splitlines():
    line = line.strip()
    if not line or line.startswith("#") or line.lower().startswith("class"):
        continue
    cls, spec, primary, build, stats_text = [c.strip() for c in line.split("|")]
    stats, prev_sep, place, level = [], None, 0, 0
    for i, (name, sep) in enumerate(re.findall(r"([^>=]+)([>=]*)", stats_text), 1):
        if prev_sep != "=":
            place, level = i, level + 1
        stats.append((name.strip(), prev_sep, place, level))
        prev_sep = sep
    rows.append((cls, spec, primary, "" if build == "-" else build, stats))

CLASS = {"Death Knight": "#C41E3A", "Demon Hunter": "#A330C9", "Druid": "#FF7C0A", "Evoker": "#33937F",
         "Hunter": "#AAD372", "Mage": "#3FC7EB", "Monk": "#00FF98", "Paladin": "#F48CBA", "Priest": "#FFFFFF",
         "Rogue": "#FFF468", "Shaman": "#0070DD", "Warlock": "#8788EE", "Warrior": "#C69B6D"}
STAT = {"Critical Strike": "#e05555", "Haste": "#e8c547", "Mastery": "#b07ce8", "Versatility": "#5cc77a"}
SEP = {">": ">", "=": "=", ">=": "\u2265"}
BG, ALT = "#14161f", "#1b1e29"


def fade(hex_color, amount=0.4):
    """Blend a colour toward the background."""
    c = [int(hex_color[i:i + 2], 16) for i in (1, 3, 5)]
    b = [int(BG[i:i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(b[k] + (c[k] - b[k]) * amount):02x}" for k in range(3))


F = "C:/Windows/Fonts/"
title = ImageFont.truetype(F + "segoeuib.ttf", 34)
head = ImageFont.truetype(F + "segoeuib.ttf", 17)
bold = ImageFont.truetype(F + "segoeuib.ttf", 17)
reg = ImageFont.truetype(F + "segoeui.ttf", 16)
small = ImageFont.truetype(F + "segoeui.ttf", 15)
sep_font = ImageFont.truetype(F + "segoeuib.ttf", 18)

STAT_X, STAT_STEP, BOX_W = 690, 182, 150
cols = [("Class", 40), ("Spec", 210), ("Primary", 370), ("Build", 480)]
W, ROW, TOP = STAT_X + 4 * STAT_STEP + 20, 30, 190
groups = len({r[0] for r in rows})
H = TOP + 40 + len(rows) * ROW + groups * 10 + 70

img = Image.new("RGB", (W, H), BG)
d = ImageDraw.Draw(img)
d.text((40, 30), "WhichClass", font=title, fill="#ffd100")
d.text((40, 76), "Secondary stat priority by spec (best first)  \u00b7  Icy Veins, patch 12.1.5", font=reg, fill="#b8bccb")

# Legend: stat colours, then what the box styles and separators mean.
x = 40
for name, col in STAT.items():
    d.rounded_rectangle((x, 108, x + 14, 122), 3, fill=col)
    d.text((x + 20, 104), name, font=small, fill="#d6d8e0")
    x += d.textlength(name, font=small) + 50
y = 140
x = 40
d.rounded_rectangle((x, y, x + 40, y + 18), 4, fill="#8a8fa3")
d.text((x + 50, y - 2), "Top two (tooltip match)", font=small, fill="#d6d8e0")
x += 260
d.rounded_rectangle((x, y, x + 40, y + 18), 4, outline="#8a8fa3", width=2)
d.text((x + 50, y - 2), "Second best (level 3)", font=small, fill="#d6d8e0")
x += 240
d.rounded_rectangle((x, y, x + 40, y + 18), 4, outline=fade("#8a8fa3"), width=2)
d.text((x + 50, y - 2), "Very low (level 4)", font=small, fill="#d6d8e0")
x += 220
d.text((x, y - 2), ">  better     =  equal     \u2265  better or equal", font=small, fill="#d6d8e0")

y = TOP
for name, cx in cols + [("#1", STAT_X), ("#2", STAT_X + STAT_STEP), ("#3", STAT_X + 2 * STAT_STEP), ("#4", STAT_X + 3 * STAT_STEP)]:
    d.text((cx, y), name, font=head, fill="#8a8fa3")
y += 30
d.line((30, y - 4, W - 20, y - 4), fill="#3a3e4f", width=2)

prev, shade = None, False
for cls, spec, primary, build, stats in rows:
    if cls != prev:
        if prev:
            y += 10
        shade = False
    row_bg = ALT if shade else BG
    if shade:
        d.rectangle((30, y, W - 20, y + ROW), fill=ALT)
    shade = not shade
    c = CLASS[cls]
    if cls != prev:
        d.text((cols[0][1], y + 4), cls, font=bold, fill=c)
    d.rectangle((30, y, 33, y + ROW), fill=c)
    d.text((cols[1][1], y + 4), spec, font=bold, fill=c)
    d.text((cols[2][1], y + 5), primary, font=reg, fill="#c9ccd6")
    d.text((cols[3][1], y + 5), build, font=reg, fill="#9ea3b5")

    for i, (name, sep, place, level) in enumerate(stats):
        bx = STAT_X + i * STAT_STEP
        box = (bx, y + 4, bx + BOX_W, y + ROW - 4)
        col = STAT[name]
        if place <= 2:
            d.rounded_rectangle(box, 5, fill=col)
            d.text((bx + 8, y + 5), name, font=bold, fill=BG)
        elif level <= 3:
            d.rounded_rectangle(box, 5, fill=row_bg, outline=col, width=2)
            d.text((bx + 8, y + 5), name, font=reg, fill=col)
        else:
            d.rounded_rectangle(box, 5, fill=row_bg, outline=fade(col), width=2)
            d.text((bx + 8, y + 5), name, font=reg, fill=fade(col, 0.55))
        if sep:
            glyph = SEP.get(sep, sep)
            gx = bx - (STAT_STEP - BOX_W) / 2 - d.textlength(glyph, font=sep_font) / 2
            d.text((gx, y + 3), glyph, font=sep_font, fill="#ffffff" if sep == "=" else "#8a8fa3")
    prev = cls
    y += ROW

d.text((40, y + 22), "Ties share a place: in  Crit > Mastery = Vers > Haste  the top two are Crit, Mastery and Vers, and Haste is level 3.",
       font=small, fill="#8a8fa3")
img.save(out)
print(W, H, len(rows))
