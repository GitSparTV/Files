local PANEL = {}
AccessorFunc(PANEL, "text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "color", "Color")

function PANEL:Init()
	self:SetSize(62, 22)
	self.text = "Label"
	self.font = "Helvetica15"
	self.color = Color(0, 0, 0)
	self.xalign = 1
	self.yalign = 0
	self:SetMouseInputEnabled(true)
end

function PANEL:CenterAlign()
	self.xalign = 1
	self.yalign = 1
end

function PANEL:IsDown()
	return self.Depressed or false
end

function PANEL:OnMousePressed(mouse)
	self.Depressed = true
	self.LastMousePressed = CurTime()
end

function PANEL:DoClick()
end

function PANEL:SetText(t)
	self.text = tostring(t)
	local len, h = surface.GetTextSize(self.text, self.font, self.Wrapping and self.WrappingWide or nil)
	self.textLen, self.textH,self.fontlnH = len, h,surface.Fonts[self.font]:getHeight()
	self:OnTextChanged()
end

function PANEL:SetFont(t)
	self.font = tostring(t)
	local len, h = surface.GetTextSize(self.text, self.font, self.Wrapping and self.WrappingWide or nil)
	self.textLen, self.textH,self.fontlnH = len, h,surface.Fonts[self.font]:getHeight()
	self:OnTextChanged()
end

function PANEL:OnTextChanged()
end

function PANEL:OnMouseReleased(mouse)
	if self.Depressed then
		if vgui.GetHoveredPanel() == self then
			self:DoClick()
		end

		self.Depressed = false
	end

	self.LastMouseReleased = CurTime()
end

function PANEL:SetWrap(b)
	self.Wrapping = b
end

function PANEL:SetWrapWide(w)
	self.WrappingWide = w
end

function PANEL:SizeToContents(x, y)
	local len, h = surface.GetTextSize(self.text, self.font, self.Wrapping and self.WrappingWide or nil)
	self:SetSize(len + (x or 15), h + (y or 15))
	self:CenterAlign()
end

function PANEL:GetTextSize(line)
	return surface.GetTextSize(self.text, self.font, self.Wrapping and self.WrappingWide or nil, line)
end

function PANEL:GetFontHeight()
	return surface.Fonts[self:GetFont()]:getHeight() or 0
end

function PANEL:Paint(w, t)
	if not self.Wrapping then
		draw.SimpleText(self.text, self.font, w / 2, t / 2, self.color, self.xalign, self.yalign)
	else
		draw.DrawText(self.text, self.WrappingWide or self.w, self.font, w / 2, t / 2, self.color, self.xalign, self.yalign)
	end
end

vgui.RegisterBase("Label", PANEL)