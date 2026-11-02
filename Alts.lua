local _, ns = ...

-- Character database: what each of your characters wears and carries, and
-- what's in the Warband bank. It lives in WhichAltDB, which is shared by
-- every character on the account, and is only updated from game events
-- (logging in, changing gear, bag changes, opening the bank).
--
--   WhichAltDB.chars["Name-Realm"] = {
--     name, realm, class, level, spec (index), ilvl, seen (time), connected,
--     equipped = { [slot] = { link, ilvl, loc } },
--     bags = { gear, ... },
--   }
--   WhichAltDB.warband = { items = { gear, ... }, seen = time }
--   gear = { link, ilvl, loc, class, sub, min (level), stats, movable, warbound }

local Alts = {}
ns.Alts = Alts

local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetItemStats = C_Item and C_Item.GetItemStats or GetItemStats
local GetDetailedItemLevelInfo = C_Item and C_Item.GetDetailedItemLevelInfo or GetDetailedItemLevelInfo
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink

local ARMOR, WEAPON = Enum.ItemClass.Armor, Enum.ItemClass.Weapon
local EQUIP_SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }
local MAIN, OFF = 16, 17

-- Which kind of slot an item goes in. Weapons are "MAIN" or "OFF".
local GROUPS = {
	INVTYPE_HEAD = "HEAD", INVTYPE_NECK = "NECK", INVTYPE_SHOULDER = "SHOULDER",
	INVTYPE_CHEST = "CHEST", INVTYPE_ROBE = "CHEST", INVTYPE_WAIST = "WAIST",
	INVTYPE_LEGS = "LEGS", INVTYPE_FEET = "FEET", INVTYPE_WRIST = "WRIST",
	INVTYPE_HAND = "HAND", INVTYPE_FINGER = "FINGER", INVTYPE_TRINKET = "TRINKET",
	INVTYPE_CLOAK = "CLOAK",
	INVTYPE_WEAPON = "MAIN", INVTYPE_2HWEAPON = "MAIN", INVTYPE_WEAPONMAINHAND = "MAIN",
	INVTYPE_RANGED = "MAIN", INVTYPE_RANGEDRIGHT = "MAIN",
	INVTYPE_WEAPONOFFHAND = "OFF", INVTYPE_HOLDABLE = "OFF", INVTYPE_SHIELD = "OFF",
}
local GROUP_SLOTS = {
	HEAD = { 1 }, NECK = { 2 }, SHOULDER = { 3 }, CHEST = { 5 }, WAIST = { 6 }, LEGS = { 7 },
	FEET = { 8 }, WRIST = { 9 }, HAND = { 10 }, FINGER = { 11, 12 }, TRINKET = { 13, 14 }, CLOAK = { 15 },
}
Alts.GROUP_NAMES = {
	HEAD = "Head", NECK = "Neck", SHOULDER = "Shoulder", CHEST = "Chest", WAIST = "Waist",
	LEGS = "Legs", FEET = "Feet", WRIST = "Wrist", HAND = "Hands", FINGER = "Ring",
	TRINKET = "Trinket", CLOAK = "Back", MAIN = "Weapon", OFF = "Off hand",
}

-- Stat keys worth keeping with stored gear: main stats and the four secondaries.
local KEEP_STATS = {
	ITEM_MOD_CRIT_RATING_SHORT = true, ITEM_MOD_HASTE_RATING_SHORT = true,
	ITEM_MOD_MASTERY_RATING_SHORT = true, ITEM_MOD_VERSATILITY = true,
}

local function Match() return ns.Match end

---------------------------------------------------------------------------
-- Reading items
---------------------------------------------------------------------------

local GetCurrentItemLevel = C_Item and C_Item.GetCurrentItemLevel

-- Set when an item's level hasn't loaded yet, so it's read again once the
-- game reports the item has loaded (GET_ITEM_INFO_RECEIVED).
local pending = false

-- Item level, or nil if the game hasn't loaded it yet. Reading it from the
-- item's bag or equipment slot is the most reliable.
local function ItemLevel(link, location)
	if location and GetCurrentItemLevel then
		local ok, ilvl = pcall(GetCurrentItemLevel, location)
		if ok and ilvl and ilvl > 0 then return ilvl end
	end
	local ilvl = link and GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(link)
	if ilvl and ilvl > 0 then return ilvl end
end

local function SlotLocation(bag, slot)
	if not ItemLocation then return end
	local ok, location
	if slot then
		ok, location = pcall(ItemLocation.CreateFromBagAndSlot, ItemLocation, bag, slot)
	else
		ok, location = pcall(ItemLocation.CreateFromEquipmentSlot, ItemLocation, bag)
	end
	return ok and location or nil
end

local function CompactStats(link)
	local stats = GetItemStats(link)
	if not stats then return nil end
	local kept = {}
	for key in pairs(stats) do
		if KEEP_STATS[key] or key:find("STRENGTH", 1, true) or key:find("AGILITY", 1, true) or key:find("INTELLECT", 1, true) then
			kept[key] = true
		end
	end
	return kept
end

-- A record of a piece of wearable gear, or nil for anything else. ilvl is
-- nil while the game is still loading the item.
local function GearRecord(link, location)
	if not link then return end
	local itemID, _, _, loc, _, classID, subclassID = GetItemInfoInstant(link)
	if not itemID or not GROUPS[loc] or (classID ~= ARMOR and classID ~= WEAPON) then return end
	local _, _, _, _, minLevel = GetItemInfo(link)
	local ilvl = ItemLevel(link, location)
	if not ilvl then pending = true end
	return {
		link = link, ilvl = ilvl, loc = loc, class = classID, sub = subclassID,
		min = minLevel, stats = CompactStats(link),
	}
end

-- Whether an item in the bags can go to another character (not soulbound),
-- and whether that's through the Warband (warbound items).
local function Transfer(bag, slot)
	if not (ItemLocation and C_Item and C_Item.IsBound) then return true, false end
	local ok, movable, warbound = pcall(function()
		local location = ItemLocation:CreateFromBagAndSlot(bag, slot)
		if not C_Item.IsBound(location) then return true, false end
		if C_Bank and C_Bank.IsItemAllowedInBankType and Enum.BankType then
			local account = C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, location)
			return account, account
		end
		return false, false
	end)
	if not ok then return true, false end
	return movable, warbound
end

---------------------------------------------------------------------------
-- Recording this character
---------------------------------------------------------------------------

local function MyKey()
	local name, realm = UnitName("player"), GetNormalizedRealmName and GetNormalizedRealmName()
	if name and realm then return name .. "-" .. realm, name, realm end
end
Alts.MyKey = MyKey

local function MyRecord()
	local key, name, realm = MyKey()
	if not key then return end
	local char = ns.db.chars[key] or {}
	ns.db.chars[key] = char
	char.name, char.realm = name, realm
	local _, classFile = UnitClass("player")
	char.class = classFile
	return char
end

local function ScanBasics(char)
	char.level = UnitLevel("player")
	local spec = GetSpecialization and GetSpecialization()
	if spec and spec > 0 then char.spec = spec end
	local _, equipped = GetAverageItemLevel()
	if equipped then char.ilvl = math.floor(equipped + 0.5) end
	char.connected = GetAutoCompleteRealms and GetAutoCompleteRealms() or nil
	char.seen = time()
end

local function ScanEquipped(char)
	char.equipped = {}
	for _, slot in ipairs(EQUIP_SLOTS) do
		local link = GetInventoryItemLink("player", slot)
		local record = GearRecord(link, link and SlotLocation(slot))
		if record then
			char.equipped[slot] = { link = link, ilvl = record.ilvl, loc = record.loc }
		end
	end
end

local function ScanBags(char)
	char.bags = {}
	for bag = 0, NUM_BAG_SLOTS or 4 do
		for slot = 1, GetContainerNumSlots(bag) or 0 do
			local link = GetContainerItemLink(bag, slot)
			local record = GearRecord(link, link and SlotLocation(bag, slot))
			if record then
				record.movable, record.warbound = Transfer(bag, slot)
				char.bags[#char.bags + 1] = record
			end
		end
	end
end

local WARBAND_TABS = {}
if Enum.BagIndex then
	for i = 1, 5 do
		local bag = Enum.BagIndex["AccountBankTab_" .. i]
		if bag then WARBAND_TABS[#WARBAND_TABS + 1] = bag end
	end
end

local function ScanWarband()
	local items, readable = {}, false
	for _, bag in ipairs(WARBAND_TABS) do
		local slots = GetContainerNumSlots(bag) or 0
		if slots > 0 then readable = true end
		for slot = 1, slots do
			local link = GetContainerItemLink(bag, slot)
			local record = GearRecord(link, link and SlotLocation(bag, slot))
			if record then
				record.movable, record.warbound = true, true
				items[#items + 1] = record
			end
		end
	end
	if readable then ns.db.warband = { items = items, seen = time() } end
end

local bankOpen = false
local events = CreateFrame("Frame")
local retries = 0

-- Listen for item data arriving only while some item level is missing,
-- and give up after a while so it never keeps rescanning.
local function WatchPending()
	if pending and retries < 20 then
		events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	else
		events:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	end
end

local function FullScan(char)
	pending = false
	ScanBasics(char)
	ScanEquipped(char)
	ScanBags(char)
	if bankOpen then ScanWarband() end
	WatchPending()
end

-- Records everything about this character now.
function Alts.ScanNow()
	local char = MyRecord()
	if not char then return end
	retries = 0
	FullScan(char)
end

local function Changed()
	ns.ClearCache()
	if ns.RefreshSettings then ns.RefreshSettings() end
end

local BANK_TYPES = {}
if Enum.PlayerInteractionType then
	for _, name in ipairs({ "Banker", "AccountBanker" }) do
		if Enum.PlayerInteractionType[name] then BANK_TYPES[Enum.PlayerInteractionType[name]] = true end
	end
end

events:SetScript("OnEvent", function(_, event, arg1)
	if not ns.db then return end
	local char = MyRecord()
	if not char then return end
	if event == "PLAYER_ENTERING_WORLD" then
		retries = 0
		FullScan(char)
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		retries = retries + 1
		FullScan(char)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		ScanEquipped(char)
		ScanBasics(char)
		WatchPending()
	elseif event == "BAG_UPDATE_DELAYED" then
		ScanBags(char)
		if bankOpen then ScanWarband() end
		WatchPending()
	elseif event == "PLAYER_LEVEL_UP" then
		char.level = arg1 or UnitLevel("player")
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		ScanBasics(char)
	elseif event == "BANKFRAME_OPENED" then
		bankOpen = true
		ScanWarband()
	elseif event == "BANKFRAME_CLOSED" then
		bankOpen = false
	elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		if not BANK_TYPES[arg1] then return end
		bankOpen = true
		ScanWarband()
	elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
		if BANK_TYPES[arg1] then bankOpen = false end
		return
	end
	Changed()
end)

-- Called once saved variables are loaded.
function Alts.Start()
	ns.db.chars = ns.db.chars or {}
	for _, event in ipairs({
		"PLAYER_ENTERING_WORLD", "PLAYER_EQUIPMENT_CHANGED", "BAG_UPDATE_DELAYED", "PLAYER_LEVEL_UP",
		"PLAYER_SPECIALIZATION_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "BANKFRAME_OPENED",
		"BANKFRAME_CLOSED", "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
	}) do
		pcall(events.RegisterEvent, events, event)
	end
end

function Alts.Forget(key)
	ns.db.chars[key] = nil
	if key == MyKey() then Alts.ScanNow() end
	Changed()
end

function Alts.ClearAll()
	wipe(ns.db.chars)
	ns.db.warband = nil
	Alts.ScanNow()
	Changed()
end

---------------------------------------------------------------------------
-- Upgrades
---------------------------------------------------------------------------

local function SpecsOf(classFile)
	local list = {}
	for _, spec in ipairs(ns.Specs) do
		if spec.class == classFile then list[#list + 1] = spec end
	end
	return list
end

-- The specs to check for a character under the "Counts if" option.
local function SpecsToCheck(char)
	local specs = SpecsOf(char.class)
	if ns.db.upgradeRule ~= "perfectCurrent" then return specs end
	local current = specs[char.spec or 0]
	return current and { current } or {}
end

local function SecondaryCount(stats)
	local count = 0
	for key in pairs(stats or {}) do
		if KEEP_STATS[key] then count = count + 1 end
	end
	return count
end

-- An item to check, from a link or a stored record.
local function ItemFrom(link, record)
	record = record or GearRecord(link)
	if not record or not record.ilvl then return end
	local stats = record.stats or CompactStats(record.link)
	return {
		link = record.link, ilvl = record.ilvl, loc = record.loc, class = record.class, sub = record.sub,
		min = record.min, stats = stats, primaries = stats and Match().GetPrimaries(stats), group = GROUPS[record.loc],
	}
end

-- The spec the item suits for this character, preferring their current
-- spec, or nil. By default the item has to be a perfect match (#1 and #2
-- stats) for the spec; "goodAny" also accepts stats tied for #2, and
-- "usable" only checks the spec can use it. Items without two secondary
-- stats (many trinkets) can't be judged on stats, so they only need to be
-- usable.
local function FittingSpec(item, specs, char)
	local rule = ns.db.upgradeRule
	local judgeStats = rule ~= "usable" and SecondaryCount(item.stats) >= 2
	local current = SpecsOf(char.class)[char.spec or 0]
	local found
	for _, spec in ipairs(specs) do
		if Match().SpecCanUse(spec, item.primaries, item.class, item.sub, item.loc) then
			local suits = true
			if judgeStats then
				local tier = Match().MatchSpec(spec, item.stats)
				suits = tier == Match().PERFECT or (rule == "goodAny" and tier == Match().GOOD)
			end
			if suits then
				if spec == current then return spec end
				found = found or spec
			end
		end
	end
	return found
end

-- Item level of what the character wears where this item would go. Rings,
-- trinkets and dual wielded weapons compare with the weaker of the two.
local function EquippedLevelOrZero(char, item, at)
	local eq = char.equipped or {}
	local slots = GROUP_SLOTS[item.group]
	if slots then
		if #slots == 2 then return math.min(at(slots[1]), at(slots[2])) end
		return at(slots[1])
	elseif item.group == "MAIN" then
		local off = eq[OFF]
		if item.loc == "INVTYPE_2HWEAPON" and off then
			if off.loc == "INVTYPE_2HWEAPON" then return math.min(at(MAIN), at(OFF)) end
			return (at(MAIN) + at(OFF)) / 2
		elseif item.loc == "INVTYPE_WEAPON" and off and (off.loc == "INVTYPE_WEAPON" or off.loc == "INVTYPE_WEAPONOFFHAND") then
			return math.min(at(MAIN), at(OFF))
		end
		return at(MAIN)
	elseif item.group == "OFF" then
		if not eq[OFF] and eq[MAIN] and eq[MAIN].loc == "INVTYPE_2HWEAPON" then return at(MAIN) end
		return at(OFF)
	end
	return 0
end

-- Empty slots count as 0. Returns nil if any item involved has no known
-- item level yet, so nothing is called an upgrade over unknown gear.
local function EquippedLevel(char, item)
	local eq = char.equipped or {}
	local unknown = false
	local function at(slot)
		local worn = eq[slot]
		if not worn then return 0 end
		if not worn.ilvl or worn.ilvl <= 0 then
			unknown = true
			return 0
		end
		return worn.ilvl
	end
	local level = EquippedLevelOrZero(char, item, at)
	if unknown then return nil end
	return level
end

-- Best item level the character already has waiting for this slot: worn,
-- in their bags, or in the Warband bank.
local function StoredLevel(char, item, specs)
	local best = EquippedLevel(char, item)
	if not best then return nil end
	local lists = { char.bags or {}, ns.db.warband and ns.db.warband.items or {} }
	for _, list in ipairs(lists) do
		for _, record in ipairs(list) do
			if record.link ~= item.link and GROUPS[record.loc] == item.group and record.ilvl and record.ilvl > best then
				local stored = ItemFrom(nil, record)
				for _, spec in ipairs(specs) do
					if Match().SpecCanUse(spec, stored.primaries, stored.class, stored.sub, stored.loc) then
						best = record.ilvl
						break
					end
				end
			end
		end
	end
	return best
end

-- Upgrade details for one character, or nil if it isn't an upgrade for them.
local function Evaluate(char, item)
	local specs = SpecsToCheck(char)
	local spec = FittingSpec(item, specs, char)
	if not spec then return end

	local tooLow = item.min and char.level and item.min > char.level
	local baseline
	if tooLow then
		baseline = StoredLevel(char, item, specs)
	else
		baseline = EquippedLevel(char, item)
	end
	if not baseline then return end
	local gain = item.ilvl - baseline
	if gain < (ns.db.minUpgrade or 1) then return end

	local tier = item.stats and Match().MatchSpec(spec, item.stats)
	return { char = char, gain = gain, empty = baseline == 0, tooLow = tooLow, need = item.min, spec = spec, tier = tier }
end

local function SameMailRealm(a, b)
	if a.realm == b.realm then return true end
	for _, realm in ipairs(a.connected or {}) do
		if realm == b.realm then return true end
	end
	return false
end

-- Whether an item held by "from" (nil for the Warband bank) can count for
-- character "to" under the options. warbound items move through the
-- Warband bank, so realms don't matter for them.
local function CanReach(to, from, movable, warbound, me)
	if ns.db.upgradeChars == "others" and to == me then return false end
	if from and from ~= to and not movable then return false end
	if ns.db.upgradeChars == "mailable" and from and from ~= to and not warbound then
		return SameMailRealm(from, to)
	end
	return true
end

local function SortedChars()
	local list = {}
	for key, char in pairs(ns.db.chars or {}) do
		char.key = key
		list[#list + 1] = char
	end
	table.sort(list, function(a, b) return a.name < b.name end)
	return list
end
Alts.SortedChars = SortedChars

local function Who(char, me)
	if char == me then return Match().ColorByClass(char.class, "you") end
	local name = char.name
	if me and char.realm ~= me.realm then name = name .. "-" .. char.realm end
	return Match().ColorByClass(char.class, name)
end

local ACCENT, GOOD_GREEN, MUTED = "|cff0dc799", "|cff33ff73", "|cff8a8f99"

local function Describe(result, me)
	local gain = result.empty and "empty slot" or ("+" .. math.floor(result.gain + 0.5) .. " item level")
	local quality = ""
	if result.spec and result.tier == Match().PERFECT then
		quality = MUTED .. ", perfect stats for " .. result.spec.spec .. "|r"
	elseif result.spec and result.tier == Match().GOOD then
		quality = MUTED .. ", good stats for " .. result.spec.spec .. "|r"
	end
	if result.tooLow then
		local start = ACCENT .. "Upgrade for|r " .. Who(result.char, me) .. MUTED .. " at level " .. result.need .. "|r ("
		if result.empty then
			return start .. GOOD_GREEN .. "nothing for that slot yet|r)"
		end
		return start .. GOOD_GREEN .. gain .. "|r better than their gear, bags and the Warband bank)"
	end
	return ACCENT .. "Upgrade for|r " .. Who(result.char, me) .. " (" .. GOOD_GREEN .. gain .. "|r" .. quality .. ")"
end

-- Tooltip lines for a hovered item. Soulbound items only count for the
-- character you're on.
function Alts.UpgradeLines(link, bindOption)
	if not ns.db or not ns.db.chars then return end
	local record = GearRecord(link)
	if not record then return end
	local item = ItemFrom(nil, record)
	if not item then return nil, true end -- item level not loaded yet
	local me = ns.db.chars[MyKey() or ""]
	local movable = bindOption ~= "showSoulbound"
	local warbound = bindOption == "showWarbound"

	local results = {}
	for _, char in ipairs(SortedChars()) do
		local reachable
		if char == me then
			reachable = ns.db.upgradeChars ~= "others"
		elseif not movable or not me then
			reachable = false
		else
			reachable = CanReach(char, me, movable, warbound, me)
		end
		if reachable then
			local result = Evaluate(char, item)
			if result then results[#results + 1] = result end
		end
	end
	table.sort(results, function(a, b) return a.gain > b.gain end)

	local lines = {}
	for _, result in ipairs(results) do lines[#lines + 1] = Describe(result, me) end
	return lines
end

-- Everything stored anywhere (every character's bags and the Warband bank)
-- that's an upgrade for one of your characters, for the Upgrades page:
--   { { char = char, entries = { { record, gain, source, result } } } }
function Alts.AllUpgrades()
	local me = ns.db.chars[MyKey() or ""]
	local chars = SortedChars()
	local sources = {}
	for _, holder in ipairs(chars) do
		for _, record in ipairs(holder.bags or {}) do
			sources[#sources + 1] = { record = record, from = holder,
				label = holder == me and "Your bags" or (holder.name .. "'s bags") }
		end
	end
	for _, record in ipairs(ns.db.warband and ns.db.warband.items or {}) do
		sources[#sources + 1] = { record = record, label = "Warband bank" }
	end

	local groups = {}
	for _, target in ipairs(chars) do
		local entries = {}
		for _, source in ipairs(sources) do
			local record = source.record
			if CanReach(target, source.from, record.movable, record.warbound, me) then
				local item = ItemFrom(nil, record)
				local result = item and Evaluate(target, item)
				if result then
					entries[#entries + 1] = { record = record, source = source.label, result = result, group = GROUPS[record.loc] }
				end
			end
		end
		if #entries > 0 then
			table.sort(entries, function(a, b) return a.result.gain > b.result.gain end)
			groups[#groups + 1] = { char = target, entries = entries, isMe = target == me }
		end
	end
	return groups
end

Alts.Describe = Describe
