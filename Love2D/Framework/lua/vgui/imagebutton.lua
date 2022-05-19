local PANEL = {}

function PANEL:Init()
	self.S = SysTime()
	self.ImageSize = 0
end

function PANEL:Paint(w,t)
	draw.RoundedBox(0,0,0,w,t,Color(150,150,150))
	draw.RoundedBox(0,1,1,w-2,t-2,Color(200,200,200))
	if isstring(self.image) then
		surface.SetDrawColor(Color(0,0,0))
		surface.SetMaterial(Material(self.image))
		local size = self.ImageSize
		if size == 0 then size = t end
		surface.DrawTexturedRect(w/2-math.Clamp(size,0,w)/2,t/2-math.Clamp(size,0,t)/2,math.Clamp(size,0,w),math.Clamp(size,0,t))
	end
end

function PANEL:SetImage(name) self.image = name end
function PANEL:SetImageSize(s) self.ImageSize = s end

vgui.Register("ImageButton",PANEL,"Button")