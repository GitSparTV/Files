local PANEL = {}
COLOR_DISABLED = Color(50,50,50,100)

function PANEL:Init()
	self:SetContentAlignment(5)
	self:SizeToContents()
	self.color = COLOR_GRAY
	self.disabled_color = COLOR_DISABLED
	self:SetCursor("hand")
	self:SetMouseInputEnabled(true)
end

function PANEL:SizeToContents()
	local w,t = self:GetContentSize()
	self:SetSize(w + 16, t + 10)
end

function PANEL:SetColor(t)
	self.color = t
end

function PANEL:GetColor()
	return self.color
end

function PANEL:IsDown()
	return self.Pressed
end

function PANEL:SetImage(image)
	if not image and self.image then self.image:Remove() return end
	if not self.image then self.image = self:Add("Image") end
	self.image:SetImage(image)
	self.image:SizeToContents()
	self:InvalidateLayout()
end

function PANEL:SetImageCentered(b) self.cimage = b end

function PANEL:PerformLayout(w,t)
	if self.image then
		self.image:SetPos(self.cimage and w/2 - div2f(self.image.w) or 4,t/2 - div2f(self.image.t))
		self:SetTextMargin(self.image.w,0)
	else
		self:SetTextMargin(0,0)
	end
end

function PANEL:Paint(w, t)
	draw.DrawBox(0, 0, w, t, self.color * (self:IsDown() and 0.6 or 0.8))
	draw.DrawBox(1, 1, w-2, t-2, self.color * (self:IsDown() and 0.8 or 1))
	if self:IsDisabled() then draw.DrawBox(0,0,w,t,self.disabled_color) end
end

function PANEL:PaintOver(w, t)
	self:DrawText(w, t)
end

gui.Register("Button", PANEL, "Label")