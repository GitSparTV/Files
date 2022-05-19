local PANEL = {}

function PANEL:Init()
	self:SetSize(32,32)
	surface.SetTextureFilter(Material("missingmaterials.png"),TEXFILTER_NEAREST,1)
	self.C = Color(200,200,200)
end


function PANEL:Paint(w,t)
	draw.RoundedBox(0,0,0,w,t,self.C)
end

vgui.RegisterBase("Panel",PANEL)