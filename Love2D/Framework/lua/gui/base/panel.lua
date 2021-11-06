local PANEL = {}

function PANEL:Init()
	self.color = Color(math.Random(255),math.Random(255),math.Random(255),200)
end

function PANEL:SetColor(t)
	self.color = t
end

function PANEL:GetColor()
	return self.color
end

function PANEL:Paint(w,t)
	draw.RoundedBox(0,0,0,w,t,self.color)
end

function PANEL:NoPaint()
	self.Paint = EMPTYFUNCTION
	self.color = nil
end

gui.RegisterBase("Panel",PANEL)