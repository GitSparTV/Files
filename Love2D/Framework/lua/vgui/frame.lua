local PANEL = {}

function PANEL:Paint(w,t)
	draw.RoundedBox(4,0,0,w,t,Color(50,50,50))
	draw.RoundedBoxEx(4,0,0,w,32,Color(100,100,100),true,true,false,false)
end

function PANEL:Init()
	self:SetSize(512,256)
	self:SetPos(300,400)
	self.Padding = {5,32 + 5,5,5}

	self.close = self:Add("ImageButton")
	local s = 24
	self.close:SetSize(s,s)
	self.close:SetPos(10,10)
	self.close:SetImage("cross128.png")
	self.close:SetImageSize(16)
	self.close.DoClick = function() self:Close() end
	self:SetMouseInputEnabled(true)
end

function PANEL:PerformLayout(w,t)
	local s = 24
	self.close:SetPos(w-(s+2),16-s/2)
end

function PANEL:OnMousePressed(mouse)
	self.Depressed = true
	self.LastMousePos = {input.MouseX(),input.MouseY()}

	self.LastMousePressed = CurTime()
end
function PANEL:OnMouseReleased(mouse)
	if self.Depressed then
		self.Depressed = false
	end
		self.LastMouseReleased = CurTime()
end

function PANEL:Think()
	local x,y = self:LocalToScreen(0,0)
	if x <= input.MouseX() and input.MouseX() <= x+self.w and y <= input.MouseY() and input.MouseY() <= y+32 or self.Moving then
		self:SetCursor("hand")
		if self.Depressed then
			self.Moving = true
			self:SetPos(self.x-(self.LastMousePos[1]-input.MouseX()),self.y-(self.LastMousePos[2]-input.MouseY()))
			self.LastMousePos = {input.MouseX(),input.MouseY()}
		else
			self.Moving = false
		end
	else
		self:SetCursor("arrow")		
	end
end

function PANEL:OnClose() end
function PANEL:Close()
	self:OnClose()
	self:Remove()
end

vgui.Register("Frame",PANEL)