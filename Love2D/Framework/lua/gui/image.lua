local PANEL = {}

function PANEL:Init()
	self.ImageMarginX,self.ImageMarginY = 0,0
end

function PANEL:SetImageMargin(w,t) self.ImageMarginX,self.ImageMarginY = w,t end

function PANEL:SetImage(image)
	self.material = Material(image)
end

function PANEL:SizeToContents(factor)
	factor = factor or 1
	local w,t = surface.SetMaterial(self.material):getDimensions()
	self:SetSize(w * factor,t * factor)
end

function PANEL:Paint(w,t)
	if not self.material then return end
	surface.SetDrawColor(COLOR_WHITE)
	surface.SetMaterial(self.material)
	surface.DrawTexturedRect(self.ImageMarginX,self.ImageMarginY,w - self.ImageMarginX * 2,t - self.ImageMarginY * 2,true)
end

gui.Register("Image",PANEL)