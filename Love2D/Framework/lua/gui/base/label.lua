local PANEL = {}

function PANEL:Init()
	self.text = "Label"
	self.font = surface.DefaultFont
	self.textW = 0
	self.textT = 0
	self.textcolor = COLOR_WHITE
	self.align = 7
	self.alignlayout = {0, 0, TALIGN_LEFT, TALIGN_TOP}
	self.XMargin,self.YMargin = 0,0
	self.mousebits = 0
end

function PANEL:SetText(t)
	self.text = tostring(t)
end

function PANEL:GetText()
	return self.text
end

function PANEL:SetFont(t)
	self.font = t
end

function PANEL:GetFont()
	return self.font
end

function PANEL:SetTextColor(t)
	self.textcolor = t
end

function PANEL:GetTextColor()
	return self.textcolor
end

function PANEL:GetContentSize()
	local w, t = surface.GetTextSize(self.text, self.font)
	self.textW, self.textT = w, t
	return w,t
end

PANEL.SetColor = SetTextColor
PANEL.GetColor = GetTextColor

function PANEL:SizeToContents(addw, addt)
	local w,t = self:GetContentSize()
	self:SetSize(w + (addw or 0), t + (addt or 0))
end

function PANEL:SetContentAlignment(a)
	self.align = a
	local al = self.alignlayout

	if a == 1 then
		al[1], al[2], al[3], al[4] = 0, 1, TALIGN_LEFT, TALIGN_BOTTOM
	elseif a == 2 then
		al[1], al[2], al[3], al[4] = 0.5, 1, TALIGN_CENTER, TALIGN_BOTTOM
	elseif a == 3 then
		al[1], al[2], al[3], al[4] = 1, 1, TALIGN_RIGHT, TALIGN_BOTTOM
	elseif a == 4 then
		al[1], al[2], al[3], al[4] = 0, 0.5, TALIGN_LEFT, TALIGN_CENTER
	elseif a == 5 then
		al[1], al[2], al[3], al[4] = 0.5, 0.5, TALIGN_CENTER, TALIGN_CENTER
	elseif a == 6 then
		al[1], al[2], al[3], al[4] = 1, 0.5, TALIGN_RIGHT, TALIGN_CENTER
	elseif a == 7 then
		al[1], al[2], al[3], al[4] = 0, 0, TALIGN_LEFT, TALIGN_TOP
	elseif a == 8 then
		al[1], al[2], al[3], al[4] = 0.5, 0, TALIGN_CENTER, TALIGN_TOP
	elseif a == 9 then
		al[1], al[2], al[3], al[4] = 1, 0, TALIGN_RIGHT, TALIGN_TOP
	end
end

function PANEL:SetTextMargin(x,y)
	self.XMargin,self.YMargin = x,y
end

local MOUSEToBits = {
	[MOUSE_LEFT] = 1,
	[MOUSE_RIGHT] = 2,
	[MOUSE_MIDDLE] = 4
}

function PANEL:OnMousePressed(x, y, button, istouch, presses)
	if self:IsDisabled() then return end
	self:MouseCapture(true)
	self.mousebits = bit.bor(self.mousebits, MOUSEToBits[button])
	self.Pressed = true
end

function PANEL:OnMouseReleased(x, y, button, istouch, presses)
	if self:IsDisabled() or not self.Pressed then return end
	self:MouseCapture(false)

	if self:IsHovered() and bit.band(self.mousebits, MOUSEToBits[button]) == MOUSEToBits[button] then
		if button == MOUSE_LEFT then
			self:DoClick(presses)
		elseif button == MOUSE_RIGHT then
			self:DoRightClick(presses)
		elseif button == MOUSE_MIDDLE then
			self:DoMiddleClick(presses)
		end
	end

	self.mousebits = 0
	self.Pressed = false
end

PANEL.DoClick = EMPTYFUNCTION
PANEL.DoRightClick = EMPTYFUNCTION
PANEL.DoMiddleClick = EMPTYFUNCTION

function PANEL:Paint(w, t)
	self:DrawText(w, t)
end

function PANEL:DrawText(w, t)
	local al = self.alignlayout
	if not self.wrap then
		draw.SimpleText(itext.fold(self.text,self.font,w - self.XMargin), self.font, self.XMargin + w * al[1] , t * al[2] + self.YMargin, self.textcolor, al[3], al[4])
	else
		draw.DrawText(self.text, w - div2f(self.XMargin), self.font, self.XMargin + w * al[1] , t * al[2] + self.YMargin, self.textcolor, al[3], al[4])
	end
end

gui.RegisterBase("Label", PANEL)