local _, ns = ...

-- Secondary stats, keyed by the names C_Item.GetItemStats returns.
local CRIT = "ITEM_MOD_CRIT_RATING_SHORT"
local HASTE = "ITEM_MOD_HASTE_RATING_SHORT"
local MASTERY = "ITEM_MOD_MASTERY_RATING_SHORT"
local VERS = "ITEM_MOD_VERSATILITY"

-- Armor subclass IDs (Enum.ItemArmorSubclass)
local CLOTH, LEATHER, MAIL, PLATE = 1, 2, 3, 4

-- Weapon subclass IDs (Enum.ItemWeaponSubclass)
local AXE1H, AXE2H, BOW, GUN, MACE1H, MACE2H, POLEARM, SWORD1H, SWORD2H, WARGLAIVE, STAFF, FIST, DAGGER, CROSSBOW, WAND =
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 15, 18, 19

local function set(...)
	local t = {}
	for i = 1, select("#", ...) do t[select(i, ...)] = true end
	return t
end

-- What each class can equip. Shields are tracked separately from other armor.
ns.ClassGear = {
	DEATHKNIGHT = { name = "Death Knight", armor = PLATE, weapons = set(AXE1H, AXE2H, MACE1H, MACE2H, POLEARM, SWORD1H, SWORD2H) },
	DEMONHUNTER = { name = "Demon Hunter", armor = LEATHER, weapons = set(WARGLAIVE, AXE1H, FIST, SWORD1H) },
	DRUID       = { name = "Druid", armor = LEATHER, weapons = set(DAGGER, FIST, MACE1H, MACE2H, POLEARM, STAFF) },
	EVOKER      = { name = "Evoker", armor = MAIL, weapons = set(DAGGER, FIST, AXE1H, AXE2H, MACE1H, MACE2H, SWORD1H, SWORD2H, STAFF) },
	HUNTER      = { name = "Hunter", armor = MAIL, weapons = set(BOW, GUN, CROSSBOW, AXE1H, AXE2H, POLEARM, STAFF, SWORD1H, SWORD2H, FIST, DAGGER) },
	MAGE        = { name = "Mage", armor = CLOTH, weapons = set(DAGGER, SWORD1H, STAFF, WAND) },
	MONK        = { name = "Monk", armor = LEATHER, weapons = set(FIST, AXE1H, MACE1H, SWORD1H, POLEARM, STAFF) },
	PALADIN     = { name = "Paladin", armor = PLATE, shield = true, weapons = set(AXE1H, AXE2H, MACE1H, MACE2H, SWORD1H, SWORD2H, POLEARM) },
	PRIEST      = { name = "Priest", armor = CLOTH, weapons = set(DAGGER, MACE1H, STAFF, WAND) },
	ROGUE       = { name = "Rogue", armor = LEATHER, weapons = set(DAGGER, FIST, AXE1H, MACE1H, SWORD1H) },
	SHAMAN      = { name = "Shaman", armor = MAIL, shield = true, weapons = set(FIST, AXE1H, AXE2H, MACE1H, MACE2H, DAGGER, STAFF) },
	WARLOCK     = { name = "Warlock", armor = CLOTH, weapons = set(DAGGER, SWORD1H, STAFF, WAND) },
	WARRIOR     = { name = "Warrior", armor = PLATE, shield = true, weapons = set(AXE1H, AXE2H, MACE1H, MACE2H, POLEARM, SWORD1H, SWORD2H, STAFF, FIST, DAGGER) },
}

-- The four secondary stats in a fixed order, with the names used in the
-- data files and the colours used in the settings window.
ns.STATS = {
	{ key = CRIT, name = "Critical Strike", color = { 0.88, 0.33, 0.33 } },
	{ key = HASTE, name = "Haste", color = { 0.91, 0.77, 0.28 } },
	{ key = MASTERY, name = "Mastery", color = { 0.69, 0.49, 0.91 } },
	{ key = VERS, name = "Versatility", color = { 0.36, 0.78, 0.48 } },
}

local STAT_KEYS, STAT_NAMES = {}, {}
for _, stat in ipairs(ns.STATS) do
	STAT_KEYS[stat.name:lower()] = stat.key
	STAT_NAMES[stat.key] = stat.name
end
ns.STAT_NAMES = STAT_NAMES

local PRIMARY_KEYS = {
	["strength"] = "STRENGTH",
	["agility"] = "AGILITY",
	["intellect"] = "INTELLECT",
}

local CLASS_FILES = {}
for classFile, gear in pairs(ns.ClassGear) do
	CLASS_FILES[gear.name:lower()] = classFile
end

local function trim(s)
	return s:match("^%s*(.-)%s*$")
end

-- Parses "Critical Strike > Mastery = Versatility > Haste" into
--   order: stat keys best first      seps: separator after each of the first three
--   place: ties share a spot (1, 2, 2, 4)
--   level: ties count as one level (1, 2, 2, 3)
-- Returns nil and a message if the text isn't valid.
function ns.ParseStats(text)
	local result = { order = {}, seps = {}, place = {}, level = {} }
	local count, curPlace, curLevel, prevSep = 0, 0, 0, nil
	for stat, sep in text:gmatch("([^>=]+)([>=]*)") do
		local name = trim(stat)
		local key = STAT_KEYS[name:lower()]
		if not key then
			return nil, "unknown stat '" .. name .. "'"
		elseif result.place[key] then
			return nil, "stat listed twice: " .. name
		end
		count = count + 1
		if prevSep ~= "=" then
			curPlace, curLevel = count, curLevel + 1
		end
		result.order[count], result.place[key], result.level[key] = key, curPlace, curLevel
		if sep ~= "" then
			if sep ~= ">" and sep ~= "=" and sep ~= ">=" then
				return nil, "unknown separator '" .. sep .. "' (use >, = or >=)"
			end
			result.seps[count] = sep
		end
		prevSep = sep
	end
	if count ~= 4 then
		return nil, "needs all 4 secondary stats, found " .. count
	elseif #result.seps ~= 3 then
		return nil, "needs a separator between each pair of stats"
	end
	return result
end

-- The reverse of ParseStats: stat keys and separators back into text.
function ns.FormatStats(order, seps)
	local parts = {}
	for i, key in ipairs(order) do
		parts[#parts + 1] = STAT_NAMES[key]
		if seps[i] then parts[#parts + 1] = seps[i] end
	end
	return table.concat(parts, " ")
end

-- Points a build at a custom priority, or back at its default with nil.
function ns.SetBuildPriority(build, customText)
	local parsed, err = ns.ParseStats(customText or build.defaultText)
	if not parsed then return false, err end
	build.text, build.custom = customText or build.defaultText, customText ~= nil
	build.place, build.level = parsed.place, parsed.level
	return true
end

-- Problems go to ns.DataErrors so they can be printed once the game has loaded.
ns.DataErrors = {}

local function Problem(file, line, message)
	ns.DataErrors[#ns.DataErrors + 1] = ("%s: %s, in this line:\n  %s"):format(file, message, line)
end

-- Splits a data table into trimmed columns, skipping blanks, comments and
-- the header row (first column "Class").
local function EachRow(text, columns, file)
	local rows = {}
	for line in (text or ""):gmatch("([^\n]*)\n?") do
		line = trim(line)
		if line ~= "" and not line:find("^#") then
			local cols = {}
			for col in (line .. "|"):gmatch("([^|]*)|") do
				cols[#cols + 1] = trim(col)
			end
			if cols[1]:lower() ~= "class" then
				if #cols ~= columns then
					Problem(file, line, ("expected %d columns separated by |, found %d"):format(columns, #cols))
				else
					cols.line = line
					rows[#rows + 1] = cols
				end
			end
		end
	end
	return rows
end

---------------------------------------------------------------------------
-- Specs (SpecData.lua)
--   ns.Specs = { { class, spec, primary, index, builds = { build, ... } } }
--   build = { key, label, defaultText, text, custom, place, level }
-- Lines for the same class and spec become builds of one entry.
---------------------------------------------------------------------------

ns.Specs = {}
local specsByKey = {}

for _, cols in ipairs(EachRow(ns.SpecText, 5, "SpecData.lua")) do
	local className, specName, primaryName, buildName, statText = unpack(cols)
	local classFile = CLASS_FILES[className:lower()]
	local primary = PRIMARY_KEYS[primaryName:lower()]
	local parsed, err = ns.ParseStats(statText)

	if not classFile then
		Problem("SpecData.lua", cols.line, "unknown class '" .. className .. "'")
	elseif not primary then
		Problem("SpecData.lua", cols.line, "unknown primary stat '" .. primaryName .. "'")
	elseif not parsed then
		Problem("SpecData.lua", cols.line, err)
	else
		local specKey = classFile .. ":" .. specName:lower()
		local spec = specsByKey[specKey]
		if not spec then
			spec = { class = classFile, spec = specName, primary = primary, builds = {}, index = #ns.Specs + 1 }
			specsByKey[specKey] = spec
			ns.Specs[#ns.Specs + 1] = spec
		end
		local label = buildName ~= "-" and buildName ~= "" and buildName or nil
		local build = { label = label, defaultText = statText, key = classFile .. ":" .. specName .. ":" .. (label or "") }
		ns.SetBuildPriority(build, nil)
		spec.builds[#spec.builds + 1] = build
	end
end

---------------------------------------------------------------------------
-- Trinkets (TrinketData.lua)
--   ns.Trinkets[itemID] = { { spec, content, tier }, ... }
---------------------------------------------------------------------------

ns.Trinkets = {}

for _, cols in ipairs(EachRow(ns.TrinketText, 6, "TrinketData.lua")) do
	local className, specName, content, tier, itemID = unpack(cols)
	local classFile = CLASS_FILES[className:lower()]
	local spec = classFile and specsByKey[classFile .. ":" .. specName:lower()]
	itemID = tonumber(itemID)

	if not classFile then
		Problem("TrinketData.lua", cols.line, "unknown class '" .. className .. "'")
	elseif not spec then
		Problem("TrinketData.lua", cols.line, "no spec '" .. specName .. "' for " .. className .. " in SpecData.lua")
	elseif not itemID then
		Problem("TrinketData.lua", cols.line, "Item ID must be a number")
	elseif tier == "" then
		Problem("TrinketData.lua", cols.line, "missing tier")
	else
		local list = ns.Trinkets[itemID] or {}
		ns.Trinkets[itemID] = list
		list[#list + 1] = { spec = spec, content = content ~= "-" and content ~= "" and content or nil, tier = tier }
	end
end

---------------------------------------------------------------------------
-- Custom roles, made in the Customise tab and kept in WhichAltDB.roles:
--   roles["DRUID:Guardian"] = { { name = "Mythic+ AoE", text = "Haste > ..." } }
-- Each one becomes an extra build on its spec, so the tooltip treats it
-- like the Icy Veins builds.
---------------------------------------------------------------------------

local function RoleKey(spec)
	return spec.class .. ":" .. spec.spec
end

local function AttachRole(spec, name, text)
	local build = { label = name, defaultText = text, isRole = true, key = "role:" .. RoleKey(spec) .. ":" .. name }
	if not ns.SetBuildPriority(build, nil) then return nil end
	spec.builds[#spec.builds + 1] = build
	return build
end

-- Adds saved roles to their specs at login. Drops any that can't be read.
function ns.LoadRoles()
	for _, spec in ipairs(ns.Specs) do
		local key = RoleKey(spec)
		local kept = {}
		for _, role in ipairs(ns.db.roles[key] or {}) do
			if type(role) == "table" and role.name and role.text and AttachRole(spec, role.name, role.text) then
				kept[#kept + 1] = role
			end
		end
		ns.db.roles[key] = #kept > 0 and kept or nil
	end
end

-- True if the spec already has a role (Icy Veins or custom) with this name.
function ns.RoleNameTaken(spec, name)
	name = name:lower()
	for _, build in ipairs(spec.builds) do
		if (build.label or "Default"):lower() == name then return true end
	end
	return false
end

function ns.AddRole(spec, name, text)
	local key = RoleKey(spec)
	local build = AttachRole(spec, name, text)
	if not build then return nil end
	ns.db.roles[key] = ns.db.roles[key] or {}
	table.insert(ns.db.roles[key], { name = name, text = text })
	return build
end

function ns.SaveRole(spec, build, text)
	for _, role in ipairs(ns.db.roles[RoleKey(spec)] or {}) do
		if role.name == build.label then role.text = text end
	end
	build.defaultText = text
	ns.SetBuildPriority(build, nil)
end

function ns.RemoveRole(spec, build)
	for i = #spec.builds, 1, -1 do
		if spec.builds[i] == build then table.remove(spec.builds, i) end
	end
	local key = RoleKey(spec)
	local list = ns.db.roles[key] or {}
	for i = #list, 1, -1 do
		if list[i].name == build.label then table.remove(list, i) end
	end
	if #list == 0 then ns.db.roles[key] = nil end
end

function ns.RemoveAllRoles()
	for _, spec in ipairs(ns.Specs) do
		for i = #spec.builds, 1, -1 do
			if spec.builds[i].isRole then table.remove(spec.builds, i) end
		end
	end
	wipe(ns.db.roles)
end

---------------------------------------------------------------------------
-- Data status, shown in Settings: where each data file came from, and
-- whether it's older than the patch the game is on.
---------------------------------------------------------------------------

local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

-- "12.1.5" -> 120105, so patches compare as numbers.
local function PatchNumber(patch)
	local major, minor, rev = tostring(patch or ""):match("^(%d+)%.(%d+)%.?(%d*)")
	if not major then return nil end
	return tonumber(major) * 10000 + tonumber(minor) * 100 + (tonumber(rev) or 0)
end

-- "2026-10-20" -> "20 Oct 2026"
local function NiceDate(iso)
	local y, m, d = tostring(iso or ""):match("^(%d+)-(%d+)-(%d+)$")
	if not y or not MONTHS[tonumber(m)] then return iso or "unknown" end
	return tonumber(d) .. " " .. MONTHS[tonumber(m)] .. " " .. y
end

-- Returns a line per data file, whether any of them is older than the
-- game, and the game's patch.
function ns.GetDataStatus()
	local game = GetBuildInfo and GetBuildInfo()
	local gamePatch = PatchNumber(game)
	local lines, outdated = {}, false
	for _, entry in ipairs({ { "Stat priorities", ns.SpecDataInfo }, { "Trinket ratings", ns.TrinketDataInfo } }) do
		local label, info = entry[1], entry[2] or {}
		local dataPatch = PatchNumber(info.patch)
		local old = gamePatch and dataPatch and dataPatch < gamePatch
		outdated = outdated or old
		lines[#lines + 1] = ("%s: %s, patch %s, updated %s%s"):format(label, info.source or "unknown source",
			info.patch or "?", NiceDate(info.updated), old and "  |cffffaa00(older than the game)|r" or "")
	end
	return lines, outdated, game
end
