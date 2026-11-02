local _, ns = ...

-- The settings window: a sidebar with the pages, a header, the page itself
-- and a footer. It's built the first time it's opened, and everything here
-- reacts to clicks; nothing runs on a timer.

local UI = ns.UI
local C = UI.COLORS

local WIDTH, HEIGHT = 880, 660
local SIDEBAR = 200
local PAD = 28
local PAGE_WIDTH = WIDTH - SIDEBAR - PAD * 2
local MAX_ROLE_NAME = 30
local ICON = "Interface\\AddOns\\WhichAlt\\Media\\WA"

local frame
local refreshGeneral, refreshCustomise, refreshCharacters, refreshUpgrades
local currentPage = 1
local confirm -- confirm(message, onYes), set when the window is built

local function ClassColored(classFile, text)
	local color = C_ClassColor and C_ClassColor.GetClassColor(classFile) or RAID_CLASS_COLORS[classFile]
	return color and color:WrapTextInColorCode(text) or text
end

local function Colored(color, text)
	return "|c" .. UI.Hex(color) .. text .. "|r"
end

local function Trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- A message that shows for a moment, then fades out.
local function FlashText(parent)
	local fs = UI.Text(parent, "Normal")
	fs:SetAlpha(0)
	local group = fs:CreateAnimationGroup()
	local fade = group:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetStartDelay(1.5)
	fade:SetDuration(0.8)
	group:SetScript("OnFinished", function() fs:SetAlpha(0) end)
	function fs:Flash(message, color)
		self:SetText(message)
		self:SetTextColor(color[1], color[2], color[3])
		group:Stop()
		self:SetAlpha(1)
		group:Play()
	end
	return fs
end

local GOOD = { 0.2, 1, 0.45 }
local BAD = { 1, 0.38, 0.38 }
local WARN = { 1, 0.67, 0.2 }

-- A setting row: label and description on the left, toggle on the right.
local function ToggleRow(parent, x, y, width, label, desc, onChange)
	local row = UI.Panel(parent)
	row:SetSize(width, 46)
	row:SetPoint("TOPLEFT", x, y)
	local title = UI.Text(row, "Label", label)
	title:SetPoint("TOPLEFT", 14, -8)
	if desc then
		local note = UI.Text(row, "Small", desc)
		note:SetPoint("TOPLEFT", 14, -27)
		note:SetPoint("RIGHT", row, "RIGHT", -70, 0)
		note:SetWordWrap(false)
	end
	local toggle = UI.Toggle(row, onChange)
	toggle:SetPoint("RIGHT", -14, 0)
	return toggle
end

-- A setting row with a dropdown of choices on the right. choices is a list
-- of { value, text }; picking one sets ns.db[key].
local function DropdownRow(parent, x, y, width, label, desc, key, choices, ddWidth)
	local row = UI.Panel(parent)
	row:SetSize(width, 46)
	row:SetPoint("TOPLEFT", x, y)
	local title = UI.Text(row, "Label", label)
	title:SetPoint("TOPLEFT", 14, -8)
	ddWidth = ddWidth or 160
	if desc then
		local note = UI.Text(row, "Small", desc)
		note:SetPoint("TOPLEFT", 14, -27)
		note:SetPoint("RIGHT", row, "RIGHT", -(ddWidth + 24), 0)
		note:SetWordWrap(false)
	end
	local dd
	dd = UI.Dropdown(row, ddWidth, function(add)
		for _, choice in ipairs(choices) do
			add(choice[2], ns.db[key] == choice[1], function()
				ns.db[key] = choice[1]
				ns.ClearCache()
				dd:Refresh()
			end)
		end
	end)
	dd:SetPoint("RIGHT", -10, 0)
	return dd
end

---------------------------------------------------------------------------
-- General page
---------------------------------------------------------------------------

local MAIN_OPTIONS = {
	{ key = "enabled", label = "Show WhichAlt in tooltips", desc = "The same as right-clicking the minimap button." },
	{ key = "showLowerQuality", label = "Show lower quality ratings", desc = "If no spec has the item's top two stats, show the specs it's second best for." },
}

local FILTER_OPTIONS = {
	{ key = "showBoE", label = "Bind on Equip items", desc = "Gear you can still trade or sell." },
	{ key = "showWarbound", label = "Warbound items", desc = "Including Warbound until equipped." },
	{ key = "showSoulbound", label = "Soulbound items", desc = "Including drops that bind when picked up." },
	{ key = "showOffHand", label = "Off-hand items", desc = "Shields, off-hand weapons and held items." },
	{ key = "showTrinkets", label = "Trinkets", desc = "Icy Veins tier, or matched by stats if unrated." },
}

local function SetOption(key, value)
	if key == "enabled" then
		ns.SetEnabled(value)
	else
		ns.db[key] = value
	end
	ns.ClearCache()
end

local function BuildGeneral(page, footer)
	local toggles = {}
	local function Add(option, x, y, width)
		local toggle = ToggleRow(page, x, y, width, option.label, option.desc, function(on)
			SetOption(option.key, on)
		end)
		toggle.key = option.key
		toggles[#toggles + 1] = toggle
	end

	local tooltip = UI.Section(page, "Tooltip")
	tooltip:SetPoint("TOPLEFT", 0, 0)
	for i, option in ipairs(MAIN_OPTIONS) do
		Add(option, 0, -22 - (i - 1) * 50, PAGE_WIDTH)
	end
	local styleDD = DropdownRow(page, 0, -122, PAGE_WIDTH, "Match list style",
		"Grouped puts Perfect match and Good match under headings; One list tags good matches instead.",
		"matchStyle", { { "grouped", "Grouped" }, { "list", "One list" } })

	local filters = UI.Section(page, "Only show tooltip for")
	filters:SetPoint("TOPLEFT", 0, -180)
	local half = (PAGE_WIDTH - 4) / 2
	for i, option in ipairs(FILTER_OPTIONS) do
		local col, line = (i - 1) % 2, math.floor((i - 1) / 2)
		Add(option, col * (half + 4), -202 - line * 50, half)
	end

	local data = UI.Section(page, "Data")
	data:SetPoint("TOPLEFT", 0, -364)
	local about = UI.Text(page, "Small")
	about:SetPoint("TOPLEFT", 0, -386)
	about:SetWidth(PAGE_WIDTH)
	about:SetSpacing(4)

	local reset = UI.Button(footer, "Restore defaults", 160)
	reset:SetPoint("LEFT", 0, 0)
	local flash = FlashText(footer)
	flash:SetPoint("LEFT", reset, "RIGHT", 14, 0)
	reset:SetScript("OnClick", function()
		for key, value in pairs(ns.DEFAULTS) do
			SetOption(key, value)
		end
		refreshGeneral()
		flash:Flash("Settings restored", GOOD)
	end)

	refreshGeneral = function()
		for _, toggle in ipairs(toggles) do
			toggle:SetChecked(ns.db[toggle.key])
		end
		styleDD:Refresh()
		local lines, outdated, game = ns.GetDataStatus()
		if outdated then
			lines[#lines + 1] = Colored(WARN, "Some data is from an older patch than the game (" .. game .. "). Check for a WhichAlt update.")
		elseif game then
			lines[#lines + 1] = Colored(GOOD, "Up to date for patch " .. game)
		end
		about:SetText(table.concat(lines, "\n"))
	end
end

---------------------------------------------------------------------------
-- Customise page
---------------------------------------------------------------------------

local SLOT_W, SLOT_H, GAP = 116, 36, 46

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

local CHANGED = " " .. Colored({ 1, 0.82, 0 }, "*")

local function BuildCustomise(page, footer)
	local flash -- footer message, created below

	-- Role pickers
	local roleSection = UI.Section(page, "Role")
	roleSection:SetPoint("TOPLEFT", 0, 0)

	local columns = { { "Class", 0, 180 }, { "Spec", 196, 180 }, { "Role", 392, PAGE_WIDTH - 392 } }
	for _, column in ipairs(columns) do
		local label = UI.Text(page, "Small", column[1])
		label:SetPoint("TOPLEFT", column[2], -24)
	end

	local classDD = UI.Dropdown(page, columns[1][3], function(add)
		local classes = {}
		for classFile, gear in pairs(ns.ClassGear) do
			classes[#classes + 1] = { file = classFile, name = gear.name }
		end
		table.sort(classes, function(a, b) return a.name < b.name end)
		for _, class in ipairs(classes) do
			add(ClassColored(class.file, class.name) .. (ClassHasChanges(class.file) and CHANGED or ""),
				selected.class == class.file, function() SelectClass(class.file) end)
		end
	end)
	classDD:SetPoint("TOPLEFT", columns[1][2], -42)

	local specDD = UI.Dropdown(page, columns[2][3], function(add)
		for _, spec in ipairs(SpecsOf(selected.class)) do
			add(ClassColored(spec.class, spec.spec) .. (SpecHasChanges(spec) and CHANGED or ""),
				selected.spec == spec, function() SelectSpec(spec) end)
		end
	end)
	specDD:SetPoint("TOPLEFT", columns[2][2], -42)

	local roleDD = UI.Dropdown(page, columns[3][3], function(add)
		if not selected.spec then return end
		for _, build in ipairs(selected.spec.builds) do
			local text = RoleName(build)
			if build.isRole then
				text = text .. " " .. Colored(C.accent, "(yours)")
			elseif build.custom then
				text = text .. CHANGED
			end
			add(text, selected.build == build, function() LoadBuild(build) end)
		end
	end)
	roleDD:SetPoint("TOPLEFT", columns[3][2], -42)

	local legend = UI.Text(page, "Small", Colored({ 1, 0.82, 0 }, "*") .. " has your changes")
	legend:SetPoint("TOPLEFT", 0, -86)

	-- New role / Delete role, and the name box New role opens
	local newRole = UI.Button(page, "New role", 112)
	newRole:SetPoint("TOPLEFT", columns[3][2], -80)
	local deleteRole = UI.Button(page, "Delete role", 112)
	deleteRole:SetPoint("LEFT", newRole, "RIGHT", 8, 0)

	local nameBox = UI.EditBox(page, 230, "New role name")
	nameBox:SetPoint("TOPLEFT", columns[2][2], -80)
	nameBox:SetMaxLetters(MAX_ROLE_NAME)
	local create = UI.Button(page, "Create", 90, true)
	create:SetPoint("LEFT", nameBox, "RIGHT", 8, 0)
	local cancel = UI.Button(page, "Cancel", 90)
	cancel:SetPoint("LEFT", create, "RIGHT", 6, 0)
	local editorParts = { nameBox, create, cancel }

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

	-- Stat row: four slots, a box per stat sitting in a slot, and a
	-- > / = picker between each pair of slots.
	local statSection = UI.Section(page, "Stat priority")
	statSection:SetPoint("TOPLEFT", 0, -132)

	local row = UI.Panel(page)
	row:SetSize(PAGE_WIDTH, 100)
	row:SetPoint("TOPLEFT", 0, -154)
	local left = (PAGE_WIDTH - (4 * SLOT_W + 3 * GAP)) / 2

	-- Outline that flashes around the row when something is saved.
	local glow = CreateFrame("Frame", nil, row, "BackdropTemplate")
	glow:SetPoint("TOPLEFT", -2, 2)
	glow:SetPoint("BOTTOMRIGHT", 2, -2)
	glow:SetBackdrop({ edgeFile = UI.WHITE, edgeSize = 2 })
	glow:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 1)
	glow:SetAlpha(0)
	local glowGroup = glow:CreateAnimationGroup()
	local glowFade = glowGroup:CreateAnimation("Alpha")
	glowFade:SetFromAlpha(1)
	glowFade:SetToAlpha(0)
	glowFade:SetStartDelay(1.2)
	glowFade:SetDuration(0.8)
	glowGroup:SetScript("OnFinished", function() glow:SetAlpha(0) end)
	local function Glow()
		glowGroup:Stop()
		glow:SetAlpha(1)
		glowGroup:Play()
	end

	local slots, slotTiers, seps = {}, {}, {}
	for i = 1, 4 do
		local slot = UI.Panel(row, C.bg, C.border)
		slot:SetSize(SLOT_W, SLOT_H)
		slot:SetPoint("TOPLEFT", left + (i - 1) * (SLOT_W + GAP), -30)
		local number = UI.Text(slot, "Small", "#" .. i)
		number:SetPoint("BOTTOM", slot, "TOP", 0, 5)
		local tier = UI.Text(slot, "Small")
		tier:SetPoint("TOP", slot, "BOTTOM", 0, -6)
		slots[i], slotTiers[i] = slot, tier
	end

	for i = 1, 3 do
		local dd = UI.Dropdown(row, GAP - 8, function(add)
			for _, sep in ipairs({ ">", "=" }) do
				add(sep, state.seps[i] == sep, function()
					state.seps[i] = sep
					refreshCustomise()
				end)
			end
		end)
		dd:SetHeight(SLOT_H)
		dd:SetPoint("LEFT", slots[i], "RIGHT", 4, 0)
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
		UI.Paint(box, stat.color, stat.color)
		box:SetFrameLevel(row:GetFrameLevel() + 5)
		box:SetMovable(true)
		box:SetClampedToScreen(true)
		box:RegisterForDrag("LeftButton")
		local label = UI.Text(box, "Box", stat.name)
		label:SetPoint("CENTER")
		box.key = stat.key

		box:SetScript("OnEnter", function(self)
			self:SetBackdropBorderColor(1, 1, 1, 1)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:AddLine("Drag to another position", 1, 1, 1)
			GameTooltip:Show()
		end)
		box:SetScript("OnLeave", function(self)
			self:SetBackdropBorderColor(stat.color[1], stat.color[2], stat.color[3], 1)
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

	local status = UI.Text(page, "Label")
	status:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, -14)
	local default = UI.Text(page, "Small")
	default:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 0, -6)
	default:SetWidth(PAGE_WIDTH)

	-- Footer buttons
	local save = UI.Button(footer, "Save", 110, true)
	save:SetPoint("LEFT", 0, 0)
	local resetRole = UI.Button(footer, "Reset to default", 150)
	resetRole:SetPoint("LEFT", save, "RIGHT", 8, 0)
	local resetAll = UI.Button(footer, "Reset all specs", 150)
	resetAll:SetPoint("LEFT", resetRole, "RIGHT", 8, 0)
	flash = FlashText(footer)
	flash:SetPoint("LEFT", resetAll, "RIGHT", 14, 0)

	local function Done(message, build)
		ns.ClearCache()
		LoadBuild(build or selected.build)
		flash:Flash(message, GOOD)
		Glow()
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
			flash:Flash("Changes undone", GOOD)
			return
		end
		ns.db.custom[build.key] = nil
		ns.SetBuildPriority(build, nil)
		Done("Reset to default")
	end)

	resetAll:SetScript("OnClick", function()
		confirm("Reset every spec to the Icy Veins stat priority?\nAll your custom priorities and roles will be removed.", function()
			wipe(ns.db.custom)
			ns.RemoveAllRoles()
			for _, spec in ipairs(ns.Specs) do
				for _, build in ipairs(spec.builds) do
					ns.SetBuildPriority(build, nil)
				end
			end
			Done("All specs reset", selected.spec.builds[1])
		end)
	end)

	-- New roles start as a copy of whatever the row shows now.
	local function CreateRole()
		local name = Trim(nameBox:GetText() or "")
		if name == "" then
			flash:Flash("Type a name for the role", BAD)
		elseif name:find("|", 1, true) then
			flash:Flash("Role names can't contain |", BAD)
		elseif ns.RoleNameTaken(selected.spec, name) then
			flash:Flash("This spec already has a role called " .. name, BAD)
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

	deleteRole:SetScript("OnClick", function()
		local spec, build = selected.spec, selected.build
		local specName = spec.spec .. " " .. ns.ClassGear[spec.class].name
		confirm("Delete your role \"" .. build.label .. "\" for " .. specName .. "?", function()
			ns.RemoveRole(spec, build)
			if selected.spec == spec then
				Done("Role deleted", spec.builds[1])
			end
		end)
	end)

	refreshCustomise = function()
		local build = selected.build
		if not build then return end

		classDD:Refresh()
		specDD:Refresh()
		roleDD:Refresh()

		-- Put each stat's box in its slot and show how the tooltip will
		-- treat that position with the current separators.
		local preview = ns.ParseStats(ns.FormatStats(state.order, state.seps))
		for i, key in ipairs(state.order) do
			local box = boxes[key]
			box:ClearAllPoints()
			box:SetPoint("CENTER", slots[i], "CENTER")
			if preview.place[key] <= 2 then
				slotTiers[i]:SetText(Colored(C.accent, "Top two"))
			elseif preview.level[key] <= 3 then
				slotTiers[i]:SetText(Colored(C.muted, "Second best"))
			else
				slotTiers[i]:SetText(Colored(BAD, "Very low"))
			end
		end
		for i = 1, 3 do seps[i]:Refresh() end

		local dirty = IsDirty()
		local name = ClassColored(selected.spec.class, selected.spec.spec .. " " .. ns.ClassGear[selected.spec.class].name)
		name = name .. " (" .. RoleName(build) .. ")"
		local using
		if build.isRole then
			using = Colored(C.accent, "one of your roles")
			default:SetText("You made this role, so it has no Icy Veins default. Delete role removes it.")
		else
			using = build.custom and Colored(GOOD, "using your custom priority") or "using the Icy Veins default"
			default:SetText("Icy Veins default: " .. build.defaultText)
		end
		status:SetText(name .. " is " .. using .. (dirty and "   " .. Colored(WARN, "Unsaved changes") or ""))

		save:SetEnabled(dirty)
		resetRole:SetText(build.isRole and "Undo changes" or "Reset to default")
		resetRole:SetEnabled(build.custom or dirty)
		deleteRole:SetEnabled(build.isRole == true)
		resetAll:SetEnabled(next(ns.db.custom) ~= nil or next(ns.db.roles) ~= nil)
	end
end

---------------------------------------------------------------------------
-- Characters page: upgrade options and the character database
---------------------------------------------------------------------------

local function Ago(seconds)
	if not seconds then return "never" end
	local days = math.floor((time() - seconds) / 86400)
	if days <= 0 then return "today" end
	if days == 1 then return "yesterday" end
	return days .. " days ago"
end

local function SpecNameOf(char)
	local index = 0
	for _, spec in ipairs(ns.Specs) do
		if spec.class == char.class then
			index = index + 1
			if index == char.spec then return spec.spec end
		end
	end
	return "-"
end

local function BuildCharacters(page, footer)
	local options = UI.Section(page, "Upgrades in tooltips")
	options:SetPoint("TOPLEFT", 0, 0)
	local half = (PAGE_WIDTH - 4) / 2

	local showUpgrades = ToggleRow(page, 0, -22, half, "Show upgrades", "\"Upgrade for <character>\" lines.", function(on)
		SetOption("showUpgrades", on)
	end)
	local minDD = DropdownRow(page, half + 4, -22, half, "Smallest upgrade", nil, "minUpgrade",
		{ { 1, "1 item level" }, { 3, "3 item levels" }, { 5, "5 item levels" }, { 10, "10 item levels" }, { 15, "15 item levels" } }, 150)
	local ruleDD = DropdownRow(page, 0, -72, half, "Counts if", nil, "upgradeRule",
		{ { "perfectAny", "Top 2 stats, any spec" }, { "perfectCurrent", "Top 2 stats, current spec" },
		  { "goodAny", "Top 2 or tied #2, any spec" }, { "usable", "Any spec can use it" } }, 190)
	local charsDD = DropdownRow(page, half + 4, -72, half, "Characters", nil, "upgradeChars",
		{ { "all", "All, including you" }, { "others", "Only other characters" }, { "mailable", "Same or connected realm" } }, 170)

	local listSection = UI.Section(page, "Characters")
	listSection:SetPoint("TOPLEFT", 0, -134)
	local headers = { { "Name", 12 }, { "Level", 230 }, { "Spec", 290 }, { "Item level", 410 }, { "Last seen", 490 } }
	for _, header in ipairs(headers) do
		local text = UI.Text(page, "Small", header[1])
		text:SetPoint("TOPLEFT", header[2], -158)
	end

	local listHeight = HEIGHT - 116 - 74 - 178
	local list = UI.List(page, PAGE_WIDTH, listHeight, 44, function(parent)
		local row = UI.Panel(parent)
		row.name = UI.Text(row, "Label")
		row.name:SetPoint("TOPLEFT", 12, -6)
		row.realm = UI.Text(row, "Small")
		row.realm:SetPoint("TOPLEFT", 12, -23)
		row.level = UI.Text(row, "Normal")
		row.level:SetPoint("LEFT", 230, 0)
		row.spec = UI.Text(row, "Normal")
		row.spec:SetPoint("LEFT", 290, 0)
		row.ilvl = UI.Text(row, "Normal")
		row.ilvl:SetPoint("LEFT", 410, 0)
		row.seen = UI.Text(row, "Small")
		row.seen:SetPoint("LEFT", 490, 0)
		row.forget = UI.Button(row, "Forget", 64, false, 24)
		row.forget:SetPoint("RIGHT", -8, 0)
		row.forget:SetScript("OnClick", function(self)
			local char = self:GetParent().char
			confirm("Forget " .. char.name .. "-" .. char.realm .. "?\nTheir gear is recorded again next time you log in to them.", function()
				ns.Alts.Forget(char.key)
			end)
		end)
		return row
	end, function(row, char)
		row.char = char
		local you = char.key == ns.Alts.MyKey()
		row.name:SetText(ns.Match.ColorByClass(char.class, char.name) .. (you and Colored(C.muted, "  (you)") or ""))
		row.realm:SetText(char.realm)
		row.level:SetText(char.level or "-")
		row.spec:SetText(SpecNameOf(char))
		row.ilvl:SetText(char.ilvl or "-")
		row.seen:SetText(you and "now" or Ago(char.seen))
	end)
	list.frame:SetPoint("TOPLEFT", 0, -178)

	local empty = UI.Text(page, "Small", "Log in to each of your characters once with WhichAlt to add them here.")
	empty:SetPoint("TOPLEFT", 0, -186)

	local clear = UI.Button(footer, "Clear database", 160)
	clear:SetPoint("LEFT", 0, 0)
	local flash = FlashText(footer)
	flash:SetPoint("LEFT", clear, "RIGHT", 14, 0)
	clear:SetScript("OnClick", function()
		confirm("Clear the character database?\nEvery character and the Warband bank record is removed. This character is recorded again straight away.", function()
			ns.Alts.ClearAll()
			flash:Flash("Database cleared", GOOD)
		end)
	end)

	refreshCharacters = function()
		showUpgrades:SetChecked(ns.db.showUpgrades)
		minDD:Refresh()
		ruleDD:Refresh()
		charsDD:Refresh()
		local chars = ns.Alts.SortedChars()
		list:SetItems(chars)
		empty:SetShown(#chars == 0)
	end
end

---------------------------------------------------------------------------
-- Upgrades page: everything stored that's an upgrade for someone
---------------------------------------------------------------------------

local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant

local function BuildUpgrades(page, footer)
	local section = UI.Section(page, "Available upgrades")
	section:SetPoint("TOPLEFT", 0, 0)

	local listHeight = HEIGHT - 116 - 74 - 24
	local list = UI.List(page, PAGE_WIDTH, listHeight, 34, function(parent)
		local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
		row.heading = UI.Text(row, "Label")
		row.heading:SetPoint("LEFT", 4, -2)
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetSize(22, 22)
		row.icon:SetPoint("LEFT", 12, 0)
		row.item = UI.Text(row, "Normal")
		row.item:SetPoint("LEFT", 42, 0)
		row.item:SetWidth(250)
		row.item:SetWordWrap(false)
		row.where = UI.Text(row, "Small")
		row.where:SetPoint("LEFT", 300, 0)
		row.where:SetWidth(220)
		row.where:SetWordWrap(false)
		row.gain = UI.Text(row, "Normal")
		row.gain:SetPoint("RIGHT", -12, 0)
		row:SetScript("OnEnter", function(self)
			if not self.link then return end
			UI.Paint(self, C.hover, C.border)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.link)
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function(self)
			if self.link then UI.Paint(self, C.panel, C.border) end
			GameTooltip:Hide()
		end)
		return row
	end, function(row, entry)
		local isHeading = entry.heading ~= nil
		row.heading:SetShown(isHeading)
		row.icon:SetShown(not isHeading)
		row.item:SetShown(not isHeading)
		row.where:SetShown(not isHeading)
		row.gain:SetShown(not isHeading)
		if isHeading then
			row.link = nil
			row:SetBackdrop(nil)
			row.heading:SetText(entry.heading)
			return
		end
		UI.Paint(row, C.panel, C.border)
		local record, result = entry.record, entry.result
		row.link = record.link
		local _, _, _, _, icon = GetItemInfoInstant(record.link)
		row.icon:SetTexture(icon)
		row.item:SetText(record.link .. Colored(C.muted, "  " .. record.ilvl))
		local where = (ns.Alts.GROUP_NAMES[entry.group] or "") .. " · " .. entry.source
		if result.tooLow then where = where .. " · at level " .. result.need end
		row.where:SetText(where)
		row.gain:SetText(Colored(GOOD, result.empty and "empty slot" or ("+" .. math.floor(result.gain + 0.5))))
	end)
	list.frame:SetPoint("TOPLEFT", 0, -24)

	local empty = UI.Text(page, "Small", "No upgrades found. Gear in your characters' bags and the Warband bank is checked; open your bank once so WhichAlt can see it.")
	empty:SetPoint("TOPLEFT", 0, -30)
	empty:SetWidth(PAGE_WIDTH)

	local refresh = UI.Button(footer, "Refresh", 120)
	refresh:SetPoint("LEFT", 0, 0)
	local bankNote = UI.Text(footer, "Small")
	bankNote:SetPoint("LEFT", refresh, "RIGHT", 14, 0)

	refreshUpgrades = function()
		local items = {}
		for _, group in ipairs(ns.Alts.AllUpgrades()) do
			local char = group.char
			local heading = ns.Match.ColorByClass(char.class, group.isMe and (char.name .. " (you)") or char.name)
				.. Colored(C.muted, "   level " .. (char.level or "?") .. " · " .. SpecNameOf(char) .. " · item level " .. (char.ilvl or "?"))
			items[#items + 1] = { heading = heading }
			for _, entry in ipairs(group.entries) do items[#items + 1] = entry end
		end
		list:SetItems(items)
		empty:SetShown(#items == 0)
		local warband = ns.db.warband
		bankNote:SetText(warband and ("Warband bank recorded " .. Ago(warband.seen)) or "Warband bank not recorded yet: open your bank once")
	end
	refresh:SetScript("OnClick", function() refreshUpgrades() end)
end

---------------------------------------------------------------------------
-- Window: sidebar, header, pages and footer
---------------------------------------------------------------------------

local PAGES = {
	{ name = "General", subtitle = "Choose when WhichAlt adds its section to item tooltips.", build = BuildGeneral,
	  refresh = function() refreshGeneral() end },
	{ name = "Customise", subtitle = "Drag a role's stats into your order, pick > or = between them, then Save. Or add your own roles.", build = BuildCustomise,
	  refresh = function() refreshCustomise() end },
	{ name = "Characters", subtitle = "Your characters, and how WhichAlt decides what counts as an upgrade for them.", build = BuildCharacters,
	  refresh = function() refreshCharacters() end },
	{ name = "Upgrades", subtitle = "Gear in your characters' bags and the Warband bank that's an upgrade for one of them.", build = BuildUpgrades,
	  refresh = function() refreshUpgrades() end },
}

local function CreateWindow()
	frame = CreateFrame("Frame", "WhichAltSettings", UIParent, "BackdropTemplate")
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetScript("OnHide", UI.CloseMenu)
	UI.Paint(frame, C.bg, C.border)
	frame:Hide()
	tinsert(UISpecialFrames, "WhichAltSettings") -- Escape closes it

	confirm = UI.Confirm(frame)

	-- Sidebar
	local sidebar = UI.Panel(frame, C.sidebar, C.sidebar)
	sidebar:SetPoint("TOPLEFT", 1, -1)
	sidebar:SetPoint("BOTTOMLEFT", 1, 1)
	sidebar:SetWidth(SIDEBAR - 1)
	local edge = UI.Line(sidebar)
	edge:SetWidth(1)
	edge:SetPoint("TOPRIGHT")
	edge:SetPoint("BOTTOMRIGHT")

	local logo = sidebar:CreateTexture(nil, "ARTWORK")
	logo:SetTexture(ICON)
	logo:SetSize(34, 34)
	logo:SetPoint("TOPLEFT", 20, -22)
	local logoText = UI.Text(sidebar, "Logo", "WhichAlt")
	logoText:SetPoint("LEFT", logo, "RIGHT", 10, 0)
	local logoLine = UI.Line(sidebar)
	logoLine:SetHeight(1)
	logoLine:SetPoint("TOPLEFT", 0, -74)
	logoLine:SetPoint("TOPRIGHT", -1, -74)

	local version = UI.Text(sidebar, "Small", "v" .. ns.VERSION)
	version:SetPoint("BOTTOMLEFT", 22, 42)
	local dot = sidebar:CreateTexture(nil, "ARTWORK")
	dot:SetSize(7, 7)
	dot:SetPoint("BOTTOMLEFT", 22, 25)
	local dataStatus = UI.Text(sidebar, "Small")
	dataStatus:SetPoint("LEFT", dot, "RIGHT", 7, 0)

	-- Header
	local title = UI.Text(frame, "Title")
	title:SetPoint("TOPLEFT", SIDEBAR + PAD, -24)
	local subtitle = UI.Text(frame, "Subtitle")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	subtitle:SetPoint("RIGHT", frame, "RIGHT", -70, 0)
	local close = UI.CloseButton(frame)
	close:SetPoint("TOPRIGHT", -16, -16)
	close:SetScript("OnClick", function() frame:Hide() end)
	local headerLine = UI.Line(frame)
	headerLine:SetHeight(1)
	headerLine:SetPoint("TOPLEFT", SIDEBAR, -94)
	headerLine:SetPoint("TOPRIGHT", -1, -94)

	-- Footer
	local footerLine = UI.Line(frame)
	footerLine:SetHeight(1)
	footerLine:SetPoint("BOTTOMLEFT", SIDEBAR, 62)
	footerLine:SetPoint("BOTTOMRIGHT", -1, 62)
	local closeButton = UI.Button(frame, "Close", 140, true, 32)
	closeButton:SetPoint("BOTTOMRIGHT", -PAD, 15)
	closeButton:SetScript("OnClick", function() frame:Hide() end)

	-- Pages, each with its own content and footer buttons
	local navItems = {}
	local function ShowPage(index)
		UI.CloseMenu()
		for i, page in ipairs(PAGES) do
			page.content:SetShown(i == index)
			page.footer:SetShown(i == index)
			navItems[i]:SetSelected(i == index)
		end
		title:SetText(PAGES[index].name)
		subtitle:SetText(PAGES[index].subtitle)
		currentPage = index
		PAGES[index].refresh()
	end

	for i, page in ipairs(PAGES) do
		local nav = UI.NavItem(sidebar, page.name, SIDEBAR - 1)
		nav:SetPoint("TOPLEFT", 0, -88 - (i - 1) * 34)
		nav:SetScript("OnClick", function() ShowPage(i) end)
		navItems[i] = nav

		page.content = CreateFrame("Frame", nil, frame)
		page.content:SetPoint("TOPLEFT", SIDEBAR + PAD, -116)
		page.content:SetPoint("BOTTOMRIGHT", -PAD, 74)
		page.footer = CreateFrame("Frame", nil, frame)
		page.footer:SetPoint("BOTTOMLEFT", SIDEBAR + PAD, 16)
		page.footer:SetPoint("RIGHT", closeButton, "LEFT", -12, 0)
		page.footer:SetHeight(30)
		page.build(page.content, page.footer)
	end

	frame:SetScript("OnShow", function()
		local _, outdated = ns.GetDataStatus()
		local color = outdated and WARN or GOOD
		dot:SetColorTexture(color[1], color[2], color[3], 1)
		dataStatus:SetText(outdated and "Data out of date" or "Data up to date")
	end)

	SelectPlayer()
	ShowPage(1)
end

function ns.ToggleSettings()
	if not frame then CreateWindow() end
	frame:SetShown(not frame:IsShown())
end

-- Called when a setting changes from outside the window (minimap right-click).
-- Also called when the character database changes.
function ns.RefreshSettings()
	if frame and frame:IsShown() then PAGES[currentPage].refresh() end
end
