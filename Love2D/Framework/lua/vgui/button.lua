local PANEL = {}

function PANEL:Init()
	self:SetSize(62,22)
	self.XOffest = 0
	self.YOffest = 0
	self:SetCursor("hand")
	self:CenterAlign()
	self.S = SysTime()
end

function PANEL:SetOffset(x,y) self.XOffest = x self.YOffest = y end

function PANEL:Paint(w,t)
	draw.RoundedBox(0,0,0,w,t,Color(150,150,150))
	draw.RoundedBox(0,1,1,w-2,t-2,Color(200,200,200))
	draw.SimpleText(self.text,self.font,w/2 + self.XOffest,t/2 + self.YOffest,Color(50,50,50),self.xalign,self.yalign)
end

vgui.Register("Button",PANEL,"Label")