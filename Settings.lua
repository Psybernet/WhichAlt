local _, ns = ...

-- The settings window is built the first time it's opened. Everything here
-- reacts to clicks; nothing runs on a timer.

local WIDTH, HEIGHT = 680, 490
local WHITE = "Interface\\Buttons\\WHITE8X8"
local MAX_ROLE_NAME = 30

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

local function Checkbox(parent, label)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetSize(26, 26)
	cb.label = Text(cb, "GameFontHighlight", label)
	cb.label:SetPoint("LEFT", cb, "RIGHT", 4, 1)
	return cb
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

local function Trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

---------------------------------------------------------------------------
-- General tab
---------------------------------------------------------------------------

local MAIN_OPTIONS = {
	{ key = "enabled", label = "Show WhichAlt in tooltips",
	  desc = "The same as right-clicking the minimap button." },
	{ key = "showLowerQuality", label = "Show lower quality ratings",
	  desc = "When no spec has the item's stats as its top two, list the specs it's second best for, or warn that the stats are very low." },
}

local FILTER_OPTIONS = {
	{ key = "showBoE", label = "Bind on Equip items" },
	{ key = "showWarbound", label = "Warbound items", note = "including Warbound until equipped" },
	{ key = "showSoulbound", label = "Soulbound items", note = "including dungeon and raid drops that bind when picked up" },
	{ key = "showOffHand", label = "Off-hand items", note = "shields, off-hand weapons and held items" },
	{ key = "showTrinkets", label = "Trinkets", note = "Icy Veins tier, or matched by stats if unrated" },
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
	local function Track(cb, key)
		cb.key = key
		cb:SetScript("OnClick", function(self)
			SetOption(key, self:GetChecked() and true or false)
		end)
		checks[#checks + 1] = cb
	end

	local y = -8
	for _, option in ipairs(MAIN_OPTIONS) do
		local cb = Checkbox(page, option.label)
		cb:SetPoint("TOPLEFT", 12, y)
		local desc = Text(cb, "GameFontDisableSmall", option.desc)
		desc:SetPoint("TOPLEFT", cb.label, "BOTTOMLEFT", 0, -3)
		desc:SetWidth(WIDTH - 110)
		Track(cb, option.key)
		y = y - 58
	end

	local heading = Text(page, "GameFontNormal", "Only show tooltip for:")
	heading:SetPoint("TOPLEFT", 16, y - 4)
	local headingNote = Text(page, "GameFontDisableSmall",
		"WhichAlt only appears on items whose binding is ticked here. Off-hand items and trinkets can be switched off too.")
	headingNote:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -3)
	headingNote:SetWidth(WIDTH - 60)
	y = y - 44

	for _, option in ipairs(FILTER_OPTIONS) do
		local cb = Checkbox(page, option.label)
		cb:SetPoint("TOPLEFT", 30, y)
		if option.note then
			local note = Text(cb, "GameFontDisableSmall", "(" .. option.note .. ")")
			note:SetPoint("LEFT", cb.label, "RIGHT", 8, 0)
		end
		Track(cb, option.key)
		y = y - 30
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

	-- Version and data status, e.g. "WhichAlt 1.3.0" then one line per data
	-- file, then whether the data matches the game's patch.
	local about = Text(page, "GameFontDisableSmall")
	about:SetPoint("BOTTOMLEFT", reset, "TOPLEFT", 0, 12)
	about:SetWidth(WIDTH - 60)
	about:SetSpacing(3)

	refreshGeneral = function()
		for _, cb in ipairs(checks) do
			cb:SetChecked(ns.db[cb.key])
		end

		local lines, outdated, game = ns.GetDataStatus()
		table.insert(lines, 1, "|cffffd100WhichAlt " .. ns.VERSION .. "|r")
		if outdated then
			lines[#lines + 1] = "|cffffaa00Some data is from an older patch than the game (" .. game .. "). Check for a WhichAlt update.|r"
		elseif game then
			lines[#lines + 1] = "|cff33ff33Up to date for patch " .. game .. "|r"
		end
		about:SetText(table.concat(lines, "\n"))
	end
end

---------------------------------------------------------------------------
-- Customise tab
---------------------------------------------------------------------------

local SLOT_W, SLOT_H, GAP = 118, 34, 52

local selected = { class = nil, spec = nil, build = nil }
local state = { order = {}, seps = {} } -- what the row shows right now
local savedText                           -- what the role uses, for spotting unsaved changes
local hideRoleEditor                      -- set once the page is built

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

-- True if the spec has a changed priority or a custom role (shown as *).
local function SpecHasChanges(spec)
	for _, build in ipairs(spec.builds) do
		if build.custom or build.isRole then return true end
	end
	return false
end

local function ClassHasChanges(classFile)
	for _, spec in ipairs(SpecsOf(classFile)) do
		if SpecHasChanges(spec) then return true end
	end
	return false
end

local function RoleName(build)
	return build.label or "Default"
end

local function LoadBuild(build)
	if hideRoleEditor then hideRoleEditor() end
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

local function Dropdown(parent, width, label)
	local dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
	dd:SetWidth(width)
	local text = Text(parent, "GameFontNormalSmall", label)
	text:SetPoint("BOTTOMLEFT", dd, "TOPLEFT", 2, 3)
	return dd
end

local function BuildCustomise(page)
	local intro = Text(page, "GameFontHighlightSmall",
		"Pick a role, drag the stat boxes into your order, and choose > (better than) or = (equal to) between them. Changes only apply when you press Save. Use New role to add your own.")
	intro:SetPoint("TOPLEFT", 14, -6)
	intro:SetWidth(WIDTH - 60)

	-- Class, spec and role pickers, each with a label above it
	local classDD = Dropdown(page, 150, "Class")
	classDD:SetPoint("TOPLEFT", 14, -58)
	local specDD = Dropdown(page, 150, "Spec")
	specDD:SetPoint("LEFT", classDD, "RIGHT", 12, 0)
	local roleDD = Dropdown(page, 190, "Role")
	roleDD:SetPoint("LEFT", specDD, "RIGHT", 12, 0)

	classDD:SetupMenu(function(_, root)
		local classes = {}
		for classFile, gear in pairs(ns.ClassGear) do
			classes[#classes + 1] = { file = classFile, name = gear.name }
		end
		table.sort(classes, function(a, b) return a.name < b.name end)
		for _, class in ipairs(classes) do
			local text = ClassColored(class.file, class.name) .. (ClassHasChanges(class.file) and " |cffffd100*|r" or "")
			root:CreateRadio(text,
				function(file) return selected.class == file end,
				function(file) SelectClass(file) end,
				class.file)
		end
	end)

	specDD:SetupMenu(function(_, root)
		for _, spec in ipairs(SpecsOf(selected.class)) do
			local text = ClassColored(spec.class, spec.spec) .. (SpecHasChanges(spec) and " |cffffd100*|r" or "")
			root:CreateRadio(text,
				function(s) return selected.spec == s end,
				function(s) SelectSpec(s) end,
				spec)
		end
	end)

	roleDD:SetupMenu(function(_, root)
		if not selected.spec then return end
		for _, build in ipairs(selected.spec.builds) do
			local text = RoleName(build)
			if build.isRole then
				text = text .. " |cff66ccff(yours)|r"
			elseif build.custom then
				text = text .. " |cffffd100*|r"
			end
			root:CreateRadio(text,
				function(b) return selected.build == b end,
				function(b) LoadBuild(b) end,
				build)
		end
	end)

	local legend = Text(page, "GameFontDisableSmall", "|cffffd100*|r = has your changes")
	legend:SetPoint("TOPLEFT", classDD, "BOTTOMLEFT", 2, -8)

	-- New role / Delete role, and the name box that New role opens
	local newRole = Button(page, "New role", 92)
	newRole:SetPoint("TOPLEFT", roleDD, "BOTTOMLEFT", 0, -4)
	local deleteRole = Button(page, "Delete role", 92)
	deleteRole:SetPoint("LEFT", newRole, "RIGHT", 6, 0)

	local nameBox = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
	nameBox:SetSize(150, 20)
	nameBox:SetPoint("TOPLEFT", roleDD, "BOTTOMLEFT", 6, -6)
	nameBox:SetAutoFocus(false)
	nameBox:SetMaxLetters(MAX_ROLE_NAME)
	local nameLabel = Text(page, "GameFontNormalSmall", "New role name:")
	nameLabel:SetPoint("RIGHT", nameBox, "LEFT", -10, 0)
	local create = Button(page, "Create", 64)
	create:SetPoint("LEFT", nameBox, "RIGHT", 6, 0)
	local cancel = Button(page, "Cancel", 64)
	cancel:SetPoint("LEFT", create, "RIGHT", 4, 0)
	local editorParts = { nameBox, nameLabel, create, cancel }

	local function ShowRoleEditor(show)
		for _, part in ipairs(editorParts) do part:SetShown(show) end
		newRole:SetShown(not show)
		deleteRole:SetShown(not show)
		legend:SetShown(not show)
		if show then
			nameBox:SetText("")
			nameBox:SetFocus()
		else
			nameBox:ClearFocus()
		end
	end
	hideRoleEditor = function() ShowRoleEditor(false) end
	ShowRoleEditor(false)

	-- The stat row: four slots, a box per stat sitting in a slot, and a
	-- > / = picker between each pair of slots.
	local row = CreateFrame("Frame", nil, page, "BackdropTemplate")
	local rowWidth = 4 * SLOT_W + 3 * GAP
	row:SetSize(rowWidth + 20, SLOT_H + 64)
	row:SetPoint("TOP", page, "TOP", 0, -128)
	row:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
	row:SetBackdropColor(0, 0, 0, 0.25)
	row:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

	-- Outline that flashes around the row when something is saved.
	local glow = CreateFrame("Frame", nil, row, "BackdropTemplate")
	glow:SetPoint("TOPLEFT", -3, 3)
	glow:SetPoint("BOTTOMRIGHT", 3, -3)
	glow:SetBackdrop({ edgeFile = WHITE, edgeSize = 2 })
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
	local resetRole = Button(page, "Reset to default", 140)
	resetRole:SetPoint("LEFT", save, "RIGHT", 8, 0)
	local resetAll = Button(page, "Reset all specs", 140)
	resetAll:SetPoint("BOTTOMRIGHT", -12, 10)
	local flash = FlashText(page)
	flash:SetPoint("LEFT", resetRole, "RIGHT", 12, 0)

	local function Done(message, build)
		ns.ClearCache()
		LoadBuild(build or selected.build)
		flash:Flash(message, 0.2, 1, 0.2)
		Glow(0.2, 1, 0.2)
	end

	local function Problem(message)
		flash:Flash(message, 1, 0.35, 0.35)
	end

	save:SetScript("OnClick", function()
		local build = selected.build
		local text = ns.FormatStats(state.order, state.seps)
		if build.isRole then
			ns.SaveRole(selected.spec, build, text)
		elseif text == EditorText(build.defaultText) then
			ns.db.custom[build.key] = nil
			ns.SetBuildPriority(build, nil)
		else
			ns.db.custom[build.key] = text
			ns.SetBuildPriority(build, text)
		end
		Done("Saved")
	end)

	-- For Icy Veins roles this goes back to the Icy Veins priority; for your
	-- own roles it undoes unsaved changes.
	resetRole:SetScript("OnClick", function()
		local build = selected.build
		if build.isRole then
			LoadBuild(build)
			flash:Flash("Changes undone", 0.2, 1, 0.2)
			return
		end
		ns.db.custom[build.key] = nil
		ns.SetBuildPriority(build, nil)
		Done("Reset to default")
	end)

	-- New roles start as a copy of whatever the row shows now.
	local function CreateRole()
		local name = Trim(nameBox:GetText() or "")
		if name == "" then
			Problem("Type a name for the role")
		elseif name:find("|", 1, true) then
			Problem("Role names can't contain |")
		elseif ns.RoleNameTaken(selected.spec, name) then
			Problem("This spec already has a role called " .. name)
		else
			local build = ns.AddRole(selected.spec, name, ns.FormatStats(state.order, state.seps))
			Done("Role created", build)
		end
	end
	newRole:SetScript("OnClick", function() ShowRoleEditor(true) end)
	create:SetScript("OnClick", CreateRole)
	cancel:SetScript("OnClick", function() ShowRoleEditor(false) end)
	nameBox:SetScript("OnEnterPressed", CreateRole)
	nameBox:SetScript("OnEscapePressed", function() ShowRoleEditor(false) end)

	StaticPopupDialogs.WHICHALT_DELETE_ROLE = {
		text = "Delete your role \"%s\" for %s?",
		button1 = YES,
		button2 = NO,
		OnAccept = function(_, data)
			ns.RemoveRole(data.spec, data.build)
			if selected.spec == data.spec then
				Done("Role deleted", data.spec.builds[1])
			end
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	deleteRole:SetScript("OnClick", function()
		local spec, build = selected.spec, selected.build
		StaticPopup_Show("WHICHALT_DELETE_ROLE", build.label,
			spec.spec .. " " .. ns.ClassGear[spec.class].name, { spec = spec, build = build })
	end)

	StaticPopupDialogs.WHICHALT_RESET_ALL = {
		text = "Reset every spec to the Icy Veins stat priority?\nAll your custom priorities and roles will be removed.",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			wipe(ns.db.custom)
			ns.RemoveAllRoles()
			for _, spec in ipairs(ns.Specs) do
				for _, build in ipairs(spec.builds) do
					ns.SetBuildPriority(build, nil)
				end
			end
			Done("All specs reset", selected.spec.builds[1])
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	resetAll:SetScript("OnClick", function()
		StaticPopup_Show("WHICHALT_RESET_ALL")
	end)

	refreshCustomise = function()
		local build = selected.build
		if not build then return end

		classDD:GenerateMenu()
		specDD:GenerateMenu()
		roleDD:GenerateMenu()

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
		name = name .. " (" .. RoleName(build) .. ")"
		local using
		if build.isRole then
			using = "|cff66ccffone of your roles|r"
			default:SetText("You made this role, so it has no Icy Veins default. Delete role removes it.")
		else
			using = build.custom and "|cff33ff33using your custom priority|r" or "using the Icy Veins default"
			default:SetText("Icy Veins default: " .. build.defaultText)
		end
		status:SetText(name .. " is " .. using .. (dirty and "   |cffffaa00Unsaved changes|r" or ""))

		save:SetEnabled(dirty)
		resetRole:SetText(build.isRole and "Undo changes" or "Reset to default")
		resetRole:SetEnabled(build.custom or dirty)
		deleteRole:SetEnabled(build.isRole == true)
		resetAll:SetEnabled(next(ns.db.custom) ~= nil or next(ns.db.roles) ~= nil)
	end
end

---------------------------------------------------------------------------
-- Window and tabs
---------------------------------------------------------------------------

local function CreateWindow()
	frame = CreateFrame("Frame", "WhichAltSettings", UIParent, "BasicFrameTemplateWithInset")
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
	tinsert(UISpecialFrames, "WhichAltSettings") -- Escape closes it

	local title = frame.TitleText
	if not title then
		title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		title:SetPoint("TOP", 0, -5)
	end
	title:SetText("WhichAlt Settings")

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
