local _, ns = ...

-- The settings window is built the first time it's opened. Everything here
-- reacts to clicks; nothing runs on a timer.

local WIDTH, HEIGHT = 680, 470
local PREFIX = "|cffffd100WhichClass:|r "
local WHITE = "Interface\\Buttons\\WHITE8X8"

local frame
local refreshGeneral, refreshCustomise

local function ClassColored(classFile, text)
	local color = C_ClassColor and C_ClassColor.GetClassColor(classFile) or RAID_CLASS_COLORS[classFile]
	return color and color:WrapTextInColorCode(text) or text
end

local function Text(parent, template, text)
	local fs = parent:CreateFontString(nil, "ARTWORK", template)
	fs:SetJustifyH("LEFT")
	if text then fs:SetText(text) end
	return fs
end

local function Button(parent, text, width)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(width or 140, 24)
	b:SetText(text)
	return b
end

-- A message that shows for a moment, then fades out.
local function FlashText(parent)
	local fs = Text(parent, "GameFontNormal")
	fs:SetAlpha(0)
	local group = fs:CreateAnimationGroup()
	local fade = group:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetStartDelay(1.5)
	fade:SetDuration(0.8)
	group:SetScript("OnFinished", function() fs:SetAlpha(0) end)
	function fs:Flash(message, r, g, b)
		self:SetText(message)
		self:SetTextColor(r, g, b)
		group:Stop()
		self:SetAlpha(1)
		group:Play()
	end
	return fs
end

---------------------------------------------------------------------------
-- General tab
---------------------------------------------------------------------------

local GENERAL_OPTIONS = {
	{ key = "enabled", label = "Show WhichClass in tooltips",
	  desc = "The same as right-clicking the minimap button." },
	{ key = "showLowerQuality", label = "Show lower quality ratings",
	  desc = "When no spec has the item's stats as its top two, list the specs it's second best for, or warn that the stats are very low." },
	{ key = "showOffHand", label = "Show off-hand items",
	  desc = "Shields, off-hand weapons and held-in-off-hand items." },
	{ key = "showTrinkets", label = "Show trinket ratings",
	  desc = "Lists the Icy Veins tier (S, A, B...) for every spec that rates the trinket. Unrated trinkets are matched by their secondary stats, or show \"Not rated\" if they have none." },
	{ key = "bindOnly", label = "Only Bind on Equip and Warbound items",
	  desc = "Turn this off to see WhichClass on soulbound gear too, such as trinkets from dungeons and raids." },
}

local function SetOption(key, value)
	if key == "enabled" then
		ns.SetEnabled(value)
	else
		ns.db[key] = value
	end
	ns.ClearCache()
end

local function BuildGeneral(page)
	local checks = {}
	local y = -8
	for _, option in ipairs(GENERAL_OPTIONS) do
		local cb = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
		cb:SetSize(26, 26)
		cb:SetPoint("TOPLEFT", 12, y)
		local label = Text(cb, "GameFontHighlight", option.label)
		label:SetPoint("LEFT", cb, "RIGHT", 4, 1)
		local desc = Text(cb, "GameFontDisableSmall", option.desc)
		desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -3)
		desc:SetWidth(WIDTH - 110)
		cb:SetScript("OnClick", function(self)
			SetOption(option.key, self:GetChecked() and true or false)
		end)
		cb.key = option.key
		checks[#checks + 1] = cb
		y = y - 58
	end

	local reset = Button(page, "Restore default settings", 190)
	reset:SetPoint("BOTTOMLEFT", 12, 10)
	local flash = FlashText(page)
	flash:SetPoint("LEFT", reset, "RIGHT", 12, 0)
	reset:SetScript("OnClick", function()
		for key, value in pairs(ns.DEFAULTS) do
			SetOption(key, value)
		end
		refreshGeneral()
		flash:Flash("Settings restored", 0.2, 1, 0.2)
	end)

	local source = Text(page, "GameFontDisableSmall", "Stat priorities and trinket ratings from Icy Veins, patch 12.1.5. Your custom stat priorities are on the Customise tab.")
	source:SetPoint("BOTTOMLEFT", reset, "TOPLEFT", 0, 10)
	source:SetWidth(WIDTH - 60)

	refreshGeneral = function()
		for _, cb in ipairs(checks) do
			cb:SetChecked(ns.db[cb.key])
		end
	end
end

---------------------------------------------------------------------------
-- Customise tab
---------------------------------------------------------------------------

local SLOT_W, SLOT_H, GAP = 118, 34, 52

local selected = { class = nil, spec = nil, build = nil }
local state = { order = {}, seps = {} } -- what the row shows right now
local savedText                           -- what the build uses, for spotting unsaved changes

-- ">=" counts as ">" in the tooltip, so the editor only offers > and =.
local function EditorSeps(seps)
	local out = {}
	for i = 1, 3 do out[i] = seps[i] == "=" and "=" or ">" end
	return out
end

local function EditorText(text)
	local parsed = ns.ParseStats(text)
	return ns.FormatStats(parsed.order, EditorSeps(parsed.seps))
end

local function SpecsOf(classFile)
	local list = {}
	for _, spec in ipairs(ns.Specs) do
		if spec.class == classFile then list[#list + 1] = spec end
	end
	return list
end

local function SpecHasCustom(spec)
	for _, build in ipairs(spec.builds) do
		if build.custom then return true end
	end
	return false
end

local function ClassHasCustom(classFile)
	for _, spec in ipairs(SpecsOf(classFile)) do
		if SpecHasCustom(spec) then return true end
	end
	return false
end

local function LoadBuild(build)
	selected.build = build
	local parsed = ns.ParseStats(build.text)
	state.order = { unpack(parsed.order) }
	state.seps = EditorSeps(parsed.seps)
	savedText = ns.FormatStats(state.order, state.seps)
	refreshCustomise()
end

local function SelectSpec(spec)
	selected.spec = spec
	LoadBuild(spec.builds[1])
end

local function SelectClass(classFile)
	selected.class = classFile
	SelectSpec(SpecsOf(classFile)[1])
end

-- Starts on the player's own class and spec.
local function SelectPlayer()
	local _, classFile = UnitClass("player")
	local specs = SpecsOf(classFile)
	if #specs == 0 then
		SelectClass(ns.Specs[1].class)
		return
	end
	selected.class = classFile
	local ok, specName = pcall(function()
		local _, name = GetSpecializationInfo(GetSpecialization())
		return name
	end)
	for _, spec in ipairs(specs) do
		if ok and spec.spec == specName then
			SelectSpec(spec)
			return
		end
	end
	SelectSpec(specs[1])
end

local function IsDirty()
	return ns.FormatStats(state.order, state.seps) ~= savedText
end

local function BuildCustomise(page)
	local intro = Text(page, "GameFontHighlightSmall",
		"Pick a spec, drag the stat boxes into your order, and choose > (better than) or = (equal to) between them. Changes only apply when you press Save.")
	intro:SetPoint("TOPLEFT", 14, -6)
	intro:SetWidth(WIDTH - 60)

	-- Class, spec and build pickers
	local classDD = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
	classDD:SetWidth(170)
	classDD:SetPoint("TOPLEFT", 14, -44)
	local specDD = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
	specDD:SetWidth(170)
	specDD:SetPoint("LEFT", classDD, "RIGHT", 12, 0)
	local buildDD = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
	buildDD:SetWidth(190)
	buildDD:SetPoint("LEFT", specDD, "RIGHT", 12, 0)

	classDD:SetupMenu(function(_, root)
		local classes = {}
		for classFile, gear in pairs(ns.ClassGear) do
			classes[#classes + 1] = { file = classFile, name = gear.name }
		end
		table.sort(classes, function(a, b) return a.name < b.name end)
		for _, class in ipairs(classes) do
			local text = ClassColored(class.file, class.name) .. (ClassHasCustom(class.file) and " |cffffd100*|r" or "")
			root:CreateRadio(text,
				function(file) return selected.class == file end,
				function(file) SelectClass(file) end,
				class.file)
		end
	end)

	specDD:SetupMenu(function(_, root)
		for _, spec in ipairs(SpecsOf(selected.class)) do
			local text = ClassColored(spec.class, spec.spec) .. (SpecHasCustom(spec) and " |cffffd100*|r" or "")
			root:CreateRadio(text,
				function(s) return selected.spec == s end,
				function(s) SelectSpec(s) end,
				spec)
		end
	end)

	buildDD:SetupMenu(function(_, root)
		if not selected.spec then return end
		for _, build in ipairs(selected.spec.builds) do
			root:CreateRadio((build.label or "Default") .. (build.custom and " |cffffd100*|r" or ""),
				function(b) return selected.build == b end,
				function(b) LoadBuild(b) end,
				build)
		end
	end)

	local legend = Text(page, "GameFontDisableSmall", "|cffffd100*|r = has a custom priority")
	legend:SetPoint("TOPLEFT", classDD, "BOTTOMLEFT", 2, -6)

	-- The stat row: four slots, a box per stat sitting in a slot, and a
	-- > / = picker between each pair of slots.
	local row = CreateFrame("Frame", nil, page, "BackdropTemplate")
	local rowWidth = 4 * SLOT_W + 3 * GAP
	row:SetSize(rowWidth + 20, SLOT_H + 64)
	row:SetPoint("TOP", page, "TOP", 0, -112)
	row:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
	row:SetBackdropColor(0, 0, 0, 0.25)
	row:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

	-- Green outline that flashes around the row when a priority is saved.
	local glow = CreateFrame("Frame", nil, row, "BackdropTemplate")
	glow:SetPoint("TOPLEFT", -3, 3)
	glow:SetPoint("BOTTOMRIGHT", 3, -3)
	glow:SetBackdrop({ edgeFile = WHITE, edgeSize = 2 })
	glow:SetBackdropBorderColor(0.2, 1, 0.2, 1)
	glow:SetAlpha(0)
	local glowGroup = glow:CreateAnimationGroup()
	local glowFade = glowGroup:CreateAnimation("Alpha")
	glowFade:SetFromAlpha(1)
	glowFade:SetToAlpha(0)
	glowFade:SetStartDelay(1.2)
	glowFade:SetDuration(0.8)
	glowGroup:SetScript("OnFinished", function() glow:SetAlpha(0) end)
	local function Glow(r, g, b)
		glow:SetBackdropBorderColor(r, g, b, 1)
		glowGroup:Stop()
		glow:SetAlpha(1)
		glowGroup:Play()
	end

	local slots, slotTiers, seps = {}, {}, {}
	for i = 1, 4 do
		local slot = CreateFrame("Frame", nil, row, "BackdropTemplate")
		slot:SetSize(SLOT_W, SLOT_H)
		slot:SetPoint("TOPLEFT", 10 + (i - 1) * (SLOT_W + GAP), -24)
		slot:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
		slot:SetBackdropColor(0, 0, 0, 0.4)
		slot:SetBackdropBorderColor(0.35, 0.35, 0.4, 1)
		local number = Text(slot, "GameFontDisableSmall", "#" .. i)
		number:SetPoint("BOTTOM", slot, "TOP", 0, 4)
		local tier = Text(slot, "GameFontHighlightSmall")
		tier:SetPoint("TOP", slot, "BOTTOM", 0, -5)
		slots[i], slotTiers[i] = slot, tier
	end

	for i = 1, 3 do
		local dd = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
		dd:SetWidth(GAP - 6)
		dd:SetPoint("LEFT", slots[i], "RIGHT", 3, 0)
		dd:SetupMenu(function(_, root)
			for _, sep in ipairs({ ">", "=" }) do
				root:CreateRadio(sep,
					function(s) return state.seps[i] == s end,
					function(s) state.seps[i] = s; refreshCustomise() end,
					sep)
			end
		end)
		seps[i] = dd
	end

	local boxes = {}
	local function SlotUnderBox(box)
		local x = box:GetCenter()
		local best, bestDist
		for i, slot in ipairs(slots) do
			local dist = math.abs(slot:GetCenter() - x)
			if not bestDist or dist < bestDist then best, bestDist = i, dist end
		end
		return best
	end

	for _, stat in ipairs(ns.STATS) do
		local box = CreateFrame("Button", nil, row, "BackdropTemplate")
		box:SetSize(SLOT_W, SLOT_H)
		box:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
		box:SetBackdropColor(stat.color[1], stat.color[2], stat.color[3], 1)
		box:SetBackdropBorderColor(0, 0, 0, 0.6)
		box:SetFrameLevel(row:GetFrameLevel() + 5)
		box:SetMovable(true)
		box:SetClampedToScreen(true)
		box:RegisterForDrag("LeftButton")
		local label = Text(box, "GameFontHighlight", stat.name)
		label:SetPoint("CENTER")
		label:SetTextColor(0.08, 0.09, 0.12)
		box.key = stat.key

		box:SetScript("OnEnter", function(self)
			self:SetBackdropBorderColor(1, 1, 1, 1)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:AddLine("Drag to another position", 1, 1, 1)
			GameTooltip:Show()
		end)
		box:SetScript("OnLeave", function(self)
			self:SetBackdropBorderColor(0, 0, 0, 0.6)
			GameTooltip:Hide()
		end)
		box:SetScript("OnDragStart", function(self)
			GameTooltip:Hide()
			self:SetFrameLevel(row:GetFrameLevel() + 20)
			self:StartMoving()
		end)
		box:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			self:SetUserPlaced(false)
			self:SetFrameLevel(row:GetFrameLevel() + 5)
			local to = SlotUnderBox(self)
			for from, key in ipairs(state.order) do
				if key == self.key then
					state.order[from], state.order[to] = state.order[to], state.order[from]
					break
				end
			end
			refreshCustomise()
		end)
		boxes[stat.key] = box
	end

	-- Status, defaults and buttons
	local status = Text(page, "GameFontHighlight")
	status:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, -12)
	local default = Text(page, "GameFontDisableSmall")
	default:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 0, -4)
	default:SetWidth(rowWidth + 20)

	local save = Button(page, "Save", 110)
	save:SetPoint("BOTTOMLEFT", 12, 10)
	local resetSpec = Button(page, "Reset to default", 140)
	resetSpec:SetPoint("LEFT", save, "RIGHT", 8, 0)
	local resetAll = Button(page, "Reset all specs", 140)
	resetAll:SetPoint("BOTTOMRIGHT", -12, 10)
	local flash = FlashText(page)
	flash:SetPoint("LEFT", resetSpec, "RIGHT", 12, 0)

	local function Applied(message)
		ns.ClearCache()
		LoadBuild(selected.build)
		flash:Flash(message, 0.2, 1, 0.2)
		Glow(0.2, 1, 0.2)
	end

	save:SetScript("OnClick", function()
		local build = selected.build
		local text = ns.FormatStats(state.order, state.seps)
		if text == EditorText(build.defaultText) then
			ns.db.custom[build.key] = nil
			ns.SetBuildPriority(build, nil)
		else
			ns.db.custom[build.key] = text
			ns.SetBuildPriority(build, text)
		end
		Applied("Saved")
	end)

	resetSpec:SetScript("OnClick", function()
		local build = selected.build
		ns.db.custom[build.key] = nil
		ns.SetBuildPriority(build, nil)
		Applied("Reset to default")
	end)

	StaticPopupDialogs.WHICHCLASS_RESET_ALL = {
		text = "Reset every spec to the Icy Veins stat priority?\nAll your custom priorities will be removed.",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			wipe(ns.db.custom)
			for _, spec in ipairs(ns.Specs) do
				for _, build in ipairs(spec.builds) do
					ns.SetBuildPriority(build, nil)
				end
			end
			Applied("All specs reset")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	resetAll:SetScript("OnClick", function()
		StaticPopup_Show("WHICHCLASS_RESET_ALL")
	end)

	refreshCustomise = function()
		local build = selected.build
		if not build then return end

		buildDD:SetShown(#selected.spec.builds > 1)
		classDD:GenerateMenu()
		specDD:GenerateMenu()
		buildDD:GenerateMenu()

		-- Put each stat's box in its slot and show how the tooltip will
		-- treat that position with the current separators.
		local preview = ns.ParseStats(ns.FormatStats(state.order, state.seps))
		for i, key in ipairs(state.order) do
			local box = boxes[key]
			box:ClearAllPoints()
			box:SetPoint("CENTER", slots[i], "CENTER")
			if preview.place[key] <= 2 then
				slotTiers[i]:SetText("|cff33ff33Top two|r")
			elseif preview.level[key] <= 3 then
				slotTiers[i]:SetText("|cffccccccSecond best|r")
			else
				slotTiers[i]:SetText("|cffff5555Very low|r")
			end
		end
		for i = 1, 3 do seps[i]:GenerateMenu() end

		local dirty = IsDirty()
		local name = ClassColored(selected.spec.class, selected.spec.spec .. " " .. ns.ClassGear[selected.spec.class].name)
		if build.label then name = name .. " (" .. build.label .. ")" end
		local using = build.custom and "|cff33ff33using your custom priority|r" or "using the Icy Veins default"
		status:SetText(name .. " is " .. using .. (dirty and "   |cffffaa00Unsaved changes|r" or ""))
		default:SetText("Icy Veins default: " .. build.defaultText)

		save:SetEnabled(dirty)
		resetSpec:SetEnabled(build.custom or dirty)
		resetAll:SetEnabled(next(ns.db.custom) ~= nil)
	end
end

---------------------------------------------------------------------------
-- Window and tabs
---------------------------------------------------------------------------

local function CreateWindow()
	frame = CreateFrame("Frame", "WhichClassSettings", UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:Hide()
	tinsert(UISpecialFrames, "WhichClassSettings") -- Escape closes it

	local title = frame.TitleText
	if not title then
		title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		title:SetPoint("TOP", 0, -5)
	end
	title:SetText("WhichClass Settings")

	local pages, tabs = {}, {}
	local function ShowTab(index)
		for i, page in ipairs(pages) do
			page:SetShown(i == index)
			if i == index then tabs[i]:LockHighlight() else tabs[i]:UnlockHighlight() end
		end
		if index == 1 then refreshGeneral() else refreshCustomise() end
	end

	for i, name in ipairs({ "General", "Customise" }) do
		local tab = Button(frame, name, 120)
		tab:SetPoint("TOPLEFT", 14 + (i - 1) * 126, -30)
		tab:SetScript("OnClick", function() ShowTab(i) end)
		tabs[i] = tab

		local page = CreateFrame("Frame", nil, frame)
		page:SetPoint("TOPLEFT", 10, -62)
		page:SetPoint("BOTTOMRIGHT", -10, 8)
		pages[i] = page
	end

	BuildGeneral(pages[1])
	BuildCustomise(pages[2])
	SelectPlayer()
	ShowTab(1)
end

function ns.ToggleSettings()
	if not frame then CreateWindow() end
	frame:SetShown(not frame:IsShown())
end

-- Called when a setting changes from outside the window (minimap right-click).
function ns.RefreshSettings()
	if frame and frame:IsShown() then refreshGeneral() end
end
