local addonName, ns = ...

local ICON = "Interface\\AddOns\\WhichClass\\Media\\WC"
local PRIMARIES = { "STRENGTH", "AGILITY", "INTELLECT" }
local PREFIX = "|cffffd100WhichClass:|r "

local GetItemStats = C_Item and C_Item.GetItemStats or GetItemStats
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant

-- Saved settings. Anything missing from WhichClassDB falls back to these.
ns.DEFAULTS = {
	enabled = true,          -- right-click on the minimap button
	showLowerQuality = true, -- "second best" and "very low" lines
	showOffHand = true,      -- shields, off-hand weapons and held-in-off-hand items
	showTrinkets = true,     -- trinket ratings
	bindOnly = true,         -- only Bind on Equip and Warbound items
}

---------------------------------------------------------------------------
-- Matching
---------------------------------------------------------------------------

local ARMOR = Enum.ItemClass.Armor
local WEAPON = Enum.ItemClass.Weapon
local ARMOR_GENERIC, ARMOR_SHIELD = 0, 6

-- Slots every class can wear, whatever the armor subclass says.
local ANY_CLASS_SLOTS = {
	INVTYPE_CLOAK = true,
	INVTYPE_FINGER = true,
	INVTYPE_NECK = true,
	INVTYPE_TRINKET = true,
}

-- Slots WhichClass never rates.
local SKIP_SLOTS = {
	[""] = true,
	INVTYPE_NON_EQUIP_IGNORE = true,
}

local OFF_HAND_SLOTS = {
	INVTYPE_HOLDABLE = true,
	INVTYPE_SHIELD = true,
	INVTYPE_WEAPONOFFHAND = true,
}

local SECONDARY_KEYS = {
	"ITEM_MOD_CRIT_RATING_SHORT",
	"ITEM_MOD_HASTE_RATING_SHORT",
	"ITEM_MOD_MASTERY_RATING_SHORT",
	"ITEM_MOD_VERSATILITY",
}

-- How well an item's secondaries suit a build.
local TOP, SECOND_BEST = 1, 2

local SECOND_BEST_HEADER = "|cffaaaaaaLower quality for all specs, but second best for:|r"
local VERY_LOW_LINE = "|cffff5555Very low stats for all specs, not recommended|r"
local NOT_RATED_LINE = "|cffaaaaaaNot rated|r"
local TRINKET_HEADER = "|cffaaaaaaTrinket rating (Icy Veins):|r"

-- Trinket tiers best first, with the colours Icy Veins uses.
local TIER_ORDER = { "S", "A", "B", "C", "D", "E", "F", "F-", "Defensive" }
local TIER_COLORS = {
	S = "ffe6cc80", A = "ffa335ee", B = "ff0070dd", C = "ff1eff00", D = "ffffffff",
	E = "ff9d9d9d", F = "ff9d9d9d", ["F-"] = "ff9d9d9d", Defensive = "ff78dcff",
}
local TIER_RANK = {}
for i, tier in ipairs(TIER_ORDER) do TIER_RANK[tier] = i end

local function CanEquip(gear, classID, subclassID, equipLoc)
	if ANY_CLASS_SLOTS[equipLoc] then
		return true
	elseif classID == ARMOR then
		if subclassID == ARMOR_SHIELD then
			return gear.shield == true
		elseif subclassID == ARMOR_GENERIC then
			return true
		end
		return subclassID == gear.armor
	elseif classID == WEAPON then
		return gear.weapons[subclassID] == true
	end
	return true
end

-- Returns a set of the primary stats on the item, or nil if it has none
-- (jewelry and some trinkets), in which case any spec can use it.
local function GetPrimaries(stats)
	local found
	for key in pairs(stats) do
		for _, primary in ipairs(PRIMARIES) do
			if key:find(primary, 1, true) then
				found = found or {}
				found[primary] = true
			end
		end
	end
	return found
end

-- TOP if two of the item's stats are in the build's best two places (ties
-- share a place, so "Crit > Mastery = Vers" puts all three there).
-- SECOND_BEST if two are within the first three priority levels, counting
-- tied stats as one level. nil when every pairing needs a level 4 stat.
local function BuildTier(build, stats)
	local top, near = 0, 0
	for key, place in pairs(build.place) do
		if stats[key] then
			if place <= 2 then top = top + 1 end
			if build.level[key] <= 3 then near = near + 1 end
		end
	end
	if top >= 2 then
		return TOP
	elseif near >= 2 then
		return SECOND_BEST
	end
end

-- Returns the spec's best tier and the build labels to show in brackets for
-- it. The label is nil when every build reaches that tier.
local function MatchSpec(spec, stats)
	local tiers, best = {}, nil
	for i, build in ipairs(spec.builds) do
		local tier = BuildTier(build, stats)
		tiers[i] = tier
		if tier and (not best or tier < best) then best = tier end
	end
	if not best then return end

	local labels, seen, matched = {}, {}, 0
	for i, build in ipairs(spec.builds) do
		if tiers[i] == best then
			matched = matched + 1
			if build.label and not seen[build.label] then
				seen[build.label] = true
				labels[#labels + 1] = build.label
			end
		end
	end
	if matched == #spec.builds or #labels == 0 then
		return best
	end
	return best, table.concat(labels, ", ")
end

local function ColorByClass(classFile, text)
	local color = C_ClassColor and C_ClassColor.GetClassColor(classFile) or RAID_CLASS_COLORS[classFile]
	return color and color:WrapTextInColorCode(text) or text
end

local function SpecName(spec)
	return spec.spec .. " " .. ns.ClassGear[spec.class].name
end

-- Lines for a rated trinket: one per tier, listing each spec at its best
-- tier. Content (Raid, Mythic+, hero talent) goes in brackets when the
-- rating only applies there.
local function GetTrinketLines(ratings)
	local bySpec, entries = {}, {}
	for _, rating in ipairs(ratings) do
		local rank = TIER_RANK[rating.tier] or #TIER_ORDER + 1
		local entry = bySpec[rating.spec]
		if not entry then
			entry = { spec = rating.spec }
			bySpec[rating.spec] = entry
			entries[#entries + 1] = entry
		end
		if not entry.rank or rank < entry.rank then
			entry.rank, entry.tier, entry.contents, entry.everywhere = rank, rating.tier, {}, false
		end
		if rank == entry.rank then
			if rating.content then
				entry.contents[#entry.contents + 1] = rating.content
			else
				entry.everywhere = true
			end
		end
	end
	table.sort(entries, function(a, b)
		if a.rank ~= b.rank then return a.rank < b.rank end
		return a.spec.index < b.spec.index
	end)

	local lines, current, names = { TRINKET_HEADER }, nil, nil
	local function Flush()
		if current then
			local color = TIER_COLORS[current] or "ffffffff"
			lines[#lines + 1] = "|c" .. color .. current .. "|r  " .. table.concat(names, ", ")
		end
	end
	for _, entry in ipairs(entries) do
		if entry.tier ~= current then
			Flush()
			current, names = entry.tier, {}
		end
		local text = SpecName(entry.spec)
		if not entry.everywhere and #entry.contents > 0 then
			text = text .. " (" .. table.concat(entry.contents, ", ") .. ")"
		end
		names[#names + 1] = ColorByClass(entry.spec.class, text)
	end
	Flush()
	return lines
end

-- Returns the lines to show under the WhichClass header, or nil if the
-- item's stats haven't loaded yet.
local function GetMatchLines(link, itemID, classID, subclassID, equipLoc)
	local isTrinket = equipLoc == "INVTYPE_TRINKET"
	if isTrinket and ns.Trinkets[itemID] then
		return GetTrinketLines(ns.Trinkets[itemID])
	end

	local stats = GetItemStats(link)
	if not stats then return end

	local secondaries = 0
	for _, key in ipairs(SECONDARY_KEYS) do
		if stats[key] then secondaries = secondaries + 1 end
	end
	if secondaries < 2 then
		return isTrinket and { NOT_RATED_LINE } or {}
	end

	local primaries = GetPrimaries(stats)
	local top, second = {}, {}
	for _, spec in ipairs(ns.Specs) do
		local gear = ns.ClassGear[spec.class]
		if (not primaries or primaries[spec.primary]) and CanEquip(gear, classID, subclassID, equipLoc) then
			local tier, label = MatchSpec(spec, stats)
			if tier then
				local text = SpecName(spec)
				if label then
					text = text .. " (" .. label .. ")"
				end
				local list = tier == TOP and top or second
				list[#list + 1] = ColorByClass(spec.class, text)
			end
		end
	end

	if #top > 0 then
		return top
	elseif not ns.db.showLowerQuality then
		return {}
	elseif #second > 0 then
		table.insert(second, 1, SECOND_BEST_HEADER)
		return second
	end
	return { VERY_LOW_LINE }
end

-- Tooltips refresh the same item over and over (bag updates, modifier keys),
-- so results are cached by item link. Wiped when it grows past a few hundred,
-- and whenever a setting or stat priority changes.
local cache, cacheSize = {}, 0

function ns.ClearCache()
	wipe(cache)
	cacheSize = 0
end

local function GetCachedLines(link, itemID, classID, subclassID, equipLoc)
	local lines = cache[link]
	if lines then return lines end

	lines = GetMatchLines(link, itemID, classID, subclassID, equipLoc)
	if not lines then return end -- stats not loaded yet; try again next time

	if cacheSize >= 300 then ns.ClearCache() end
	cache[link] = lines
	cacheSize = cacheSize + 1
	return lines
end

---------------------------------------------------------------------------
-- Tooltip
---------------------------------------------------------------------------

-- Binding lines that mean the item can still be traded or sent to an alt.
-- Soulbound items (including BoE gear once equipped) are left alone.
local TRADABLE_BINDS = {}
for _, key in ipairs({
	"ITEM_BIND_ON_EQUIP",            -- Binds when equipped
	"ITEM_ACCOUNTBOUND",             -- Warbound
	"ITEM_ACCOUNTBOUND_UNTIL_EQUIP", -- Warbound until equipped
	"ITEM_BNETACCOUNTBOUND",
	"ITEM_BIND_TO_ACCOUNT",
	"ITEM_BIND_TO_BNETACCOUNT",
	"ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP",
}) do
	if _G[key] then TRADABLE_BINDS[_G[key]] = true end
end

local function IsTradableBind(data)
	for _, line in ipairs(data.lines or {}) do
		if line.leftText and TRADABLE_BINDS[line.leftText] then
			return true
		end
	end
	return false
end

local function OnTooltipItem(tooltip, data)
	local db = ns.db
	if not db or not db.enabled or not tooltip.GetItem or not data then return end
	local _, link = tooltip:GetItem()
	if not link then return end

	local itemID, _, _, equipLoc, _, classID, subclassID = GetItemInfoInstant(link)
	if not equipLoc or SKIP_SLOTS[equipLoc] then return end
	if equipLoc == "INVTYPE_TRINKET" and not db.showTrinkets then return end
	if OFF_HAND_SLOTS[equipLoc] and not db.showOffHand then return end

	if db.bindOnly then
		local okBind, tradable = pcall(IsTradableBind, data)
		if not okBind or not tradable then return end
	end

	local ok, lines = pcall(GetCachedLines, link, itemID, classID, subclassID, equipLoc)
	if not ok or not lines or #lines == 0 then return end

	tooltip:AddLine(" ")
	tooltip:AddLine("|T" .. ICON .. ":14|t WhichClass", 1, 0.82, 0)
	for _, line in ipairs(lines) do
		tooltip:AddLine(line, 1, 1, 1, true)
	end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipItem)

---------------------------------------------------------------------------
-- Minimap button
---------------------------------------------------------------------------

local button = CreateFrame("Button", "WhichClassMinimapButton", Minimap)
button:SetSize(31, 31)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:SetHighlightTexture(136477) -- Interface\Minimap\UI-Minimap-ZoomButton-Highlight
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:RegisterForDrag("LeftButton")

local background = button:CreateTexture(nil, "BACKGROUND")
background:SetSize(20, 20)
background:SetTexture(136467) -- Interface\Minimap\UI-Minimap-Background
background:SetPoint("TOPLEFT", 7, -5)

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetSize(20, 20)
icon:SetTexture(ICON)
icon:SetPoint("TOPLEFT", 6, -6)

local border = button:CreateTexture(nil, "OVERLAY")
border:SetSize(53, 53)
border:SetTexture(136430) -- Interface\Minimap\MiniMap-TrackingBorder
border:SetPoint("TOPLEFT")

local function UpdatePosition()
	local angle = math.rad(ns.db.minimapAngle)
	local radius = Minimap:GetWidth() / 2 + 10
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function OnDragUpdate()
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	ns.db.minimapAngle = math.deg(math.atan2(py / scale - my, px / scale - mx))
	UpdatePosition()
end

button:SetScript("OnDragStart", function(self)
	self:SetScript("OnUpdate", OnDragUpdate)
end)

button:SetScript("OnDragStop", function(self)
	self:SetScript("OnUpdate", nil)
end)

local function ShowButtonTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("WhichClass", 1, 0.82, 0)
	if ns.db.enabled then
		GameTooltip:AddLine("Tooltips: |cff33ff33On|r", 1, 1, 1)
	else
		GameTooltip:AddLine("Tooltips: |cffff5555Off|r", 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Left-click", "Open settings", 1, 0.82, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("Right-click", ns.db.enabled and "Turn tooltips off" or "Turn tooltips on", 1, 0.82, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("Drag", "Move this button", 1, 0.82, 0, 1, 1, 1)
	GameTooltip:Show()
end

button:SetScript("OnEnter", ShowButtonTooltip)
button:SetScript("OnLeave", GameTooltip_Hide)

-- Greys the icon out while tooltips are off.
function ns.UpdateMinimapButton()
	button:SetShown(not ns.db.hideMinimap)
	icon:SetDesaturated(not ns.db.enabled)
	icon:SetAlpha(ns.db.enabled and 1 or 0.6)
end

-- Turns WhichClass tooltips on or off (minimap right-click and the
-- General tab both use this).
function ns.SetEnabled(enabled)
	ns.db.enabled = enabled
	ns.UpdateMinimapButton()
	if ns.RefreshSettings then ns.RefreshSettings() end
end

button:SetScript("OnClick", function(self, mouseButton)
	if mouseButton == "RightButton" then
		ns.SetEnabled(not ns.db.enabled)
		print(PREFIX .. "tooltips " .. (ns.db.enabled and "|cff33ff33on|r" or "|cffff5555off|r") .. ".")
		if GameTooltip:GetOwner() == self then ShowButtonTooltip(self) end
	else
		ns.ToggleSettings()
	end
end)

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
	if name ~= addonName then return end

	WhichClassDB = WhichClassDB or {}
	ns.db = WhichClassDB
	for key, value in pairs(ns.DEFAULTS) do
		if ns.db[key] == nil then ns.db[key] = value end
	end
	ns.db.minimapAngle = ns.db.minimapAngle or 225
	ns.db.custom = ns.db.custom or {}

	-- Apply saved custom stat priorities. Drop any that no longer parse.
	for _, spec in ipairs(ns.Specs) do
		for _, build in ipairs(spec.builds) do
			local text = ns.db.custom[build.key]
			if text and not ns.SetBuildPriority(build, text) then
				ns.db.custom[build.key] = nil
				print(PREFIX .. "your custom priority for " .. SpecName(spec) .. " couldn't be read and was reset.")
			end
		end
	end

	UpdatePosition()
	ns.UpdateMinimapButton()
	for _, problem in ipairs(ns.DataErrors) do
		print(PREFIX .. "|cffff5555" .. problem .. "|r")
	end
	self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_WHICHCLASS1 = "/wc"
SLASH_WHICHCLASS2 = "/whichclass"
SlashCmdList.WHICHCLASS = function(msg)
	if msg and msg:lower():match("^%s*minimap") then
		ns.db.hideMinimap = not ns.db.hideMinimap
		ns.UpdateMinimapButton()
		print(PREFIX .. "minimap button " .. (ns.db.hideMinimap and "hidden" or "shown") .. ". Type /wc minimap to change it back.")
	else
		ns.ToggleSettings()
	end
end
