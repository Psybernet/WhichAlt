local _, ns = ...

-- Flat dark theme and widgets for the settings window: colours, fonts,
-- buttons, toggles, dropdowns, edit boxes and a confirm dialog. Nothing is
-- built until the settings window first opens.

local UI = {}
ns.UI = UI

local WHITE = "Interface\\Buttons\\WHITE8X8"
local FONT = "Fonts\\ARIALN.TTF" -- built-in clean sans

local C = {
	bg = { 0.082, 0.090, 0.102 },      -- window
	sidebar = { 0.060, 0.066, 0.075 },
	panel = { 0.110, 0.120, 0.135 },   -- sections, inputs
	hover = { 0.150, 0.162, 0.180 },
	border = { 0.190, 0.200, 0.225 },
	borderHover = { 0.360, 0.380, 0.420 },
	accent = { 0.050, 0.780, 0.600 },
	accentDim = { 0.035, 0.360, 0.290 },
	text = { 0.920, 0.930, 0.940 },
	muted = { 0.600, 0.620, 0.650 },
	faint = { 0.420, 0.440, 0.470 },
	off = { 0.220, 0.235, 0.260 },     -- toggle track when off
}
UI.COLORS = C
UI.WHITE = WHITE

local BACKDROP = { bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 }

function UI.Hex(color)
	local function byte(v) return math.floor(v * 255 + 0.5) end
	return ("ff%02x%02x%02x"):format(byte(color[1]), byte(color[2]), byte(color[3]))
end

---------------------------------------------------------------------------
-- Fonts
---------------------------------------------------------------------------

local fonts = {}
local function MakeFont(name, size, color)
	local font = CreateFont("WhichAltFont" .. name)
	font:SetFont(FONT, size, "")
	font:SetTextColor(color[1], color[2], color[3])
	font:SetShadowOffset(1, -1)
	font:SetShadowColor(0, 0, 0, 0.6)
	fonts[name] = font
end

local fontsReady = false
local function EnsureFonts()
	if fontsReady then return end
	fontsReady = true
	MakeFont("Logo", 22, C.accent)
	MakeFont("Title", 30, C.text)
	MakeFont("Subtitle", 14, C.muted)
	MakeFont("Label", 15, C.text)
	MakeFont("Normal", 14, C.text)
	MakeFont("Small", 12, C.muted)
	MakeFont("Section", 12, C.faint)
	MakeFont("Box", 15, { 0.08, 0.09, 0.12 })
end

function UI.Text(parent, fontName, text)
	EnsureFonts()
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFontObject(fonts[fontName or "Normal"])
	fs:SetJustifyH("LEFT")
	if text then fs:SetText(text) end
	return fs
end

---------------------------------------------------------------------------
-- Basic shapes
---------------------------------------------------------------------------

function UI.Paint(frame, bg, border, alpha)
	if not frame.SetBackdrop then return end
	frame:SetBackdrop(BACKDROP)
	frame:SetBackdropColor(bg[1], bg[2], bg[3], alpha or 1)
	frame:SetBackdropBorderColor(border[1], border[2], border[3], 1)
end

function UI.Panel(parent, bg, border)
	local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	UI.Paint(panel, bg or C.panel, border or C.border)
	return panel
end

-- A one-pixel line in the border colour.
function UI.Line(parent, color)
	local line = parent:CreateTexture(nil, "ARTWORK")
	local c = color or C.border
	line:SetColorTexture(c[1], c[2], c[3], 1)
	return line
end

-- A small "v" made of two rotated lines, for dropdowns.
local function Chevron(parent)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(12, 8)
	for i, angle in ipairs({ -45, 45 }) do
		local t = holder:CreateTexture(nil, "OVERLAY")
		t:SetColorTexture(C.muted[1], C.muted[2], C.muted[3], 1)
		t:SetSize(7, 1.5)
		t:SetPoint("CENTER", holder, "CENTER", i == 1 and -2.2 or 2.2, 0)
		t:SetRotation(math.rad(angle))
	end
	return holder
end

-- Uppercase section title with a line running to the right edge.
function UI.Section(parent, text)
	local label = UI.Text(parent, "Section", text:upper())
	local line = UI.Line(parent)
	line:SetHeight(1)
	line:SetPoint("LEFT", label, "RIGHT", 10, 0)
	line:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
	return label
end

---------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------

local function PaintButton(self)
	local enabled = self:IsEnabled()
	local hover = enabled and self:IsMouseOver()
	local bg = hover and C.hover or C.panel
	local border, text
	if not enabled then
		border, text = C.border, C.faint
	elseif self.primary then
		border, text = hover and C.accent or C.accentDim, C.accent
	else
		border, text = hover and C.borderHover or C.border, C.text
	end
	UI.Paint(self, bg, border)
	self:GetFontString():SetTextColor(text[1], text[2], text[3])
end

-- Flat button. "primary" ones have a teal border and text, like Close.
function UI.Button(parent, text, width, primary, height)
	EnsureFonts()
	local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
	b:SetSize(width or 140, height or 30)
	local fs = b:CreateFontString(nil, "OVERLAY")
	fs:SetFontObject(fonts.Normal)
	fs:SetPoint("CENTER")
	b:SetFontString(fs)
	b:SetText(text)
	b.primary = primary
	b:SetScript("OnEnter", PaintButton)
	b:SetScript("OnLeave", PaintButton)
	b:SetScript("OnEnable", PaintButton)
	b:SetScript("OnDisable", PaintButton)
	PaintButton(b)
	return b
end

-- Square button with an X, for closing the window.
function UI.CloseButton(parent)
	local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
	b:SetSize(30, 30)
	UI.Paint(b, C.panel, C.border)
	for _, angle in ipairs({ 45, -45 }) do
		local t = b:CreateTexture(nil, "OVERLAY")
		t:SetColorTexture(C.muted[1], C.muted[2], C.muted[3], 1)
		t:SetSize(14, 1.5)
		t:SetPoint("CENTER")
		t:SetRotation(math.rad(angle))
	end
	b:SetScript("OnEnter", function(self) UI.Paint(self, C.hover, C.borderHover) end)
	b:SetScript("OnLeave", function(self) UI.Paint(self, C.panel, C.border) end)
	return b
end

-- Sidebar navigation entry with a teal bar when selected.
function UI.NavItem(parent, text, width)
	EnsureFonts()
	local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
	b:SetSize(width, 32)
	local fs = b:CreateFontString(nil, "OVERLAY")
	fs:SetFontObject(fonts.Label)
	fs:SetPoint("LEFT", 22, 0)
	b:SetFontString(fs)
	b:SetText(text)
	local bar = b:CreateTexture(nil, "OVERLAY")
	bar:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 1)
	bar:SetPoint("TOPLEFT")
	bar:SetPoint("BOTTOMLEFT")
	bar:SetWidth(3)

	function b:SetSelected(selected)
		self.selected = selected
		bar:SetShown(selected)
		local c = selected and C.text or C.muted
		fs:SetTextColor(c[1], c[2], c[3])
		UI.Paint(self, selected and C.panel or C.sidebar, selected and C.panel or C.sidebar)
	end
	b:SetScript("OnEnter", function(self)
		if not self.selected then fs:SetTextColor(C.text[1], C.text[2], C.text[3]) end
	end)
	b:SetScript("OnLeave", function(self) self:SetSelected(self.selected) end)
	b:SetSelected(false)
	return b
end

---------------------------------------------------------------------------
-- Toggle switch
---------------------------------------------------------------------------

-- On/off switch: teal track with the knob on the right when on.
function UI.Toggle(parent, onChange)
	local t = CreateFrame("Button", nil, parent, "BackdropTemplate")
	t:SetSize(40, 20)
	local knob = t:CreateTexture(nil, "OVERLAY")
	knob:SetSize(14, 14)

	function t:SetChecked(checked)
		self.checked = checked and true or false
		local track = self.checked and C.accent or C.off
		UI.Paint(self, track, track)
		knob:ClearAllPoints()
		if self.checked then
			knob:SetPoint("RIGHT", -3, 0)
			knob:SetColorTexture(1, 1, 1, 1)
		else
			knob:SetPoint("LEFT", 3, 0)
			knob:SetColorTexture(0.62, 0.64, 0.67, 1)
		end
	end
	function t:GetChecked()
		return self.checked
	end
	t:SetScript("OnClick", function(self)
		self:SetChecked(not self.checked)
		if onChange then onChange(self.checked) end
	end)
	t:SetChecked(false)
	return t
end

---------------------------------------------------------------------------
-- Dropdown
---------------------------------------------------------------------------

-- One shared list for every dropdown. A full-screen catcher behind it
-- closes the list when you click anywhere else.
local menu, catcher
local menuItems = {}

function UI.CloseMenu()
	if menu then
		menu:Hide()
		catcher:Hide()
	end
end

local function MenuItem(index)
	local item = CreateFrame("Button", nil, menu, "BackdropTemplate")
	item:SetHeight(24)
	item:SetPoint("TOPLEFT", 4, -4 - (index - 1) * 24)
	item:SetPoint("RIGHT", -4, 0)
	local fs = item:CreateFontString(nil, "OVERLAY")
	fs:SetFontObject(fonts.Normal)
	fs:SetPoint("LEFT", 10, 0)
	fs:SetPoint("RIGHT", -24, 0)
	fs:SetJustifyH("LEFT")
	item:SetFontString(fs)
	local tick = item:CreateTexture(nil, "OVERLAY")
	tick:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 1)
	tick:SetSize(6, 6)
	tick:SetPoint("RIGHT", -10, 0)
	item.tick = tick
	item:SetScript("OnEnter", function(self) UI.Paint(self, C.hover, C.hover) end)
	item:SetScript("OnLeave", function(self) UI.Paint(self, C.panel, C.panel) end)
	item:SetScript("OnClick", function(self)
		UI.CloseMenu()
		if self.onSelect then self.onSelect() end
	end)
	UI.Paint(item, C.panel, C.panel)
	menuItems[index] = item
	return item
end

local function OpenMenu(owner)
	if not menu then
		catcher = CreateFrame("Button", nil, UIParent)
		catcher:SetAllPoints(UIParent)
		catcher:SetFrameStrata("FULLSCREEN_DIALOG")
		catcher:SetScript("OnClick", UI.CloseMenu)
		menu = CreateFrame("Frame", nil, catcher, "BackdropTemplate")
		UI.Paint(menu, C.panel, C.borderHover)
		menu:SetFrameLevel(catcher:GetFrameLevel() + 5)
	end
	if menu:IsShown() and menu.owner == owner then
		UI.CloseMenu()
		return
	end

	local entries = {}
	owner.build(function(text, selected, onSelect)
		entries[#entries + 1] = { text = text, selected = selected, onSelect = onSelect }
	end)
	for i, entry in ipairs(entries) do
		local item = menuItems[i] or MenuItem(i)
		item:SetText(entry.text)
		item.tick:SetShown(entry.selected and true or false)
		item.onSelect = entry.onSelect
		item:Show()
	end
	for i = #entries + 1, #menuItems do menuItems[i]:Hide() end

	menu:SetSize(math.max(owner:GetWidth(), 140), #entries * 24 + 8)
	menu:ClearAllPoints()
	menu:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
	menu.owner = owner
	catcher:Show()
	menu:Show()
end

-- Flat dropdown. build(add) runs each time it opens and calls
-- add(text, isSelected, onSelect) for every choice.
function UI.Dropdown(parent, width, build)
	EnsureFonts()
	local dd = CreateFrame("Button", nil, parent, "BackdropTemplate")
	dd:SetSize(width, 30)
	dd.build = build
	dd.isDropdown = true
	UI.Paint(dd, C.panel, C.border)
	local fs = dd:CreateFontString(nil, "OVERLAY")
	fs:SetFontObject(fonts.Normal)
	fs:SetPoint("LEFT", 10, 0)
	fs:SetPoint("RIGHT", -24, 0)
	fs:SetJustifyH("LEFT")
	fs:SetWordWrap(false)
	dd:SetFontString(fs)
	local chevron = Chevron(dd)
	chevron:SetPoint("RIGHT", -9, 0)

	dd:SetScript("OnClick", OpenMenu)
	dd:SetScript("OnEnter", function(self) UI.Paint(self, C.hover, C.borderHover) end)
	dd:SetScript("OnLeave", function(self) UI.Paint(self, C.panel, C.border) end)

	-- Shows the selected choice's text.
	function dd:Refresh()
		local shown = ""
		self.build(function(text, selected)
			if selected then shown = text end
		end)
		self:SetText(shown)
	end
	return dd
end

---------------------------------------------------------------------------
-- Edit box
---------------------------------------------------------------------------

function UI.EditBox(parent, width, placeholder)
	EnsureFonts()
	local eb = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
	eb:SetSize(width, 30)
	eb:SetFontObject(fonts.Normal)
	eb:SetTextInsets(10, 10, 0, 0)
	eb:SetAutoFocus(false)
	UI.Paint(eb, C.panel, C.border)
	local hint = UI.Text(eb, "Small", placeholder)
	hint:SetPoint("LEFT", 10, 0)
	eb:SetScript("OnTextChanged", function(self) hint:SetShown((self:GetText() or "") == "") end)
	eb:SetScript("OnEditFocusGained", function(self) UI.Paint(self, C.panel, C.accent) end)
	eb:SetScript("OnEditFocusLost", function(self) UI.Paint(self, C.panel, C.border) end)
	return eb
end

---------------------------------------------------------------------------
-- Confirm dialog, drawn over the window
---------------------------------------------------------------------------

function UI.Confirm(window)
	local overlay = CreateFrame("Frame", nil, window, "BackdropTemplate")
	overlay:SetAllPoints(window)
	overlay:SetFrameLevel(window:GetFrameLevel() + 50)
	overlay:EnableMouse(true)
	UI.Paint(overlay, { 0, 0, 0 }, { 0, 0, 0 }, 0.6)
	overlay:Hide()

	local box = UI.Panel(overlay, C.bg, C.borderHover)
	box:SetSize(420, 150)
	box:SetPoint("CENTER")
	local message = UI.Text(box, "Label")
	message:SetPoint("TOPLEFT", 20, -20)
	message:SetPoint("TOPRIGHT", -20, -20)
	message:SetJustifyH("CENTER")
	local yes = UI.Button(box, "Yes", 120, true)
	yes:SetPoint("BOTTOMRIGHT", box, "BOTTOM", -6, 18)
	local no = UI.Button(box, "No", 120)
	no:SetPoint("BOTTOMLEFT", box, "BOTTOM", 6, 18)

	local onYes
	yes:SetScript("OnClick", function()
		overlay:Hide()
		if onYes then onYes() end
	end)
	no:SetScript("OnClick", function() overlay:Hide() end)

	return function(text, callback)
		message:SetText(text)
		onYes = callback
		overlay:Show()
	end
end
