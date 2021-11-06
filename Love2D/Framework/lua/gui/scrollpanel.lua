local PANEL = {}

function PANEL:Init()
	self.Canvas = self:Add("Panel")
	self.Canvas:NoPaint()
	self.Canvas:SetName("Canvas")
	self.Canvas:SetSize(300, 300)
	self.ScrollBar = self:Add("VScrollBar")
	self.ScrollBar:Dock(RIGHT)
	self.ScrollBar:SetName("ScrollBar")
	self.ScrollBar:SetVisible(false)
	self:SetMouseInputEnabled(true)
end

gui.NoPaint(PANEL)

function PANEL:OnChildAdded(p)
	p:SetParent(self.Canvas)
end

function PANEL:PerformLayout(w, t)
	self.Canvas:SizeToChildren(false, true)
	local SB = self.ScrollBar
	SB:PerformLayout(SB.w, SB.t)
	local GripY, TrackSize, CanvasT = SB.Grip.y - SB.w, SB.TrackSize, self.Canvas.t

	if CanvasT == t then
		SB:SetVisible(false)
		self.Canvas:SetSize(w)
		self.Canvas:SetPos(0, 0)
	else
		self.Canvas:SetSize(w - SB.w)
		SB:SetVisible(true)
		self.Canvas:SetPos(0, -math.floor((GripY / TrackSize) * (CanvasT - 1)))
	end
end

function PANEL:OnMouseWheeled(delta)
	self:InvalidateLayout(true)
	self.ScrollBar:Scroll(-delta * 10)
end

function PANEL:Clear()
	self.Canvas:Clear()
end

function PANEL:ScrollToChild(child)
	if child:GetParent() ~= self.Canvas then return end
	self:InvalidateLayout(true)
	local _, y, _, t = child:GetBounds()
	self.ScrollBar:ScrollTo(y + t)
end

gui.Register("ScrollPanel", PANEL)
----------------------------------
local PANEL = {}

function PANEL:Init()
	self:SetSize(16, 40)
	self:SetColor(COLOR_DARKGRAY)
	self.Offset = 0
	self.TrackSize = 0
	self:SetMouseInputEnabled(true)
	self.UpArrow = self:Add("Button")
	self.UpArrow:Dock(TOP)
	self.UpArrow:SetFont("Unifont13")
	self.UpArrow:SetImage("arrow_up.png")
	self.UpArrow:SetText("")
	self.UpArrow:SetName("BUTTON")
	self.UpArrow:SetImageCentered(true)

	self.UpArrow.DoClick = function()
		self:Scroll(-5)
	end

	self.DownArrow = self:Add("Button")
	self.DownArrow:Dock(BOTTOM)
	self.DownArrow:SetFont("Unifont13")
	self.DownArrow:SetImage("arrow_down.png")
	self.DownArrow:SetText("")
	self.DownArrow:SetName("BUTTON")
	self.DownArrow:SetImageCentered(true)

	self.DownArrow.DoClick = function()
		self:Scroll(5)
	end

	self.Grip = self:Add("Panel")
	self.Grip:SetPos(0, 0)
	self.Grip:SetColor(COLOR_GRAY)

	self.Grip.OnMousePressed = function(s, x, y, mouse)
		if mouse ~= MOUSE_LEFT then return end
		self.GripPressed = true
		local _x, _y = s:ScreenToLocal(0, y)
		self.GripPos = _y
		self:OnMousePressed(x, y, mouse)
	end

	self.Grip:SetMouseInputEnabled(true)
	self.Grip:SetCursor("hand")
	self.Velocity = 0
end

function PANEL:OnMousePressed(x, y, mouse)
	if mouse ~= MOUSE_LEFT then return end
	local _, y = self:ScreenToLocal(x, y)
	local w, t = self.w, self.t
	self.TrackPress = math.Clamp(y, w, t - w)
	self:MouseCapture(true)
end

function PANEL:OnCursorMoved(x, y)
	if self.TrackPress or self.GripPressed then
		local _, y = self:ScreenToLocal(x, y)
		local w, t = self.w, self.t
		self.TrackPress = math.Clamp(y, w, t - w)
	end
end

function PANEL:OnMouseReleased(x, y, mouse)
	self.TrackPress = nil
	self.GripPressed = nil
	self.GripPos = nil
	self:MouseCapture(false)
end

function PANEL:Scroll(amount)
	self.Velocity = self.Velocity + amount
	self.PreciseY = self.PreciseY or self.Grip.y
	self.LastChange = 0
	self.LastChangeTime = CurTime()
end

function PANEL:ScrollTo(y)
	self.TrackPress = math.Clamp(math.floor(self.TrackSize * (y / self.parent.Canvas.t)), self.w, self.t - self.w - div2f(self.Grip.t / 2))
end

function PANEL:Think()
	if self.TrackPress then
		local GripY, GripT = self.Grip.y, self.Grip.t
		local RP, C = self.TrackPress, (GripY + GripT / 2)

		if self.GripPressed then
			self.Grip:SetPos(0, RP - self.GripPos)
			self:InvalidateParent(true)
		else
			self.Velocity = (RP < C and -C / RP or RP / C) * 20
		end

		self.LastChange = 0
		self.LastChangeTime = CurTime()
		self.PreciseY = self.Grip.y

		if math.abs(RP - C) <= GripT / 4 then
			self.TrackPress = nil
		end
	end

	if self.Velocity ~= 0 then
		-- CurTime() - self.LastChangeTime >= love.LastTick * 10
		-- if self.LastChange >= 0.2 then
			-- self.Velocity = 0
		-- end
		-- print(SysTime() - self.LastChangeTime)
		local nextVel = self.Velocity * 0.9
		self.PreciseY = self.PreciseY + self.Velocity - nextVel
		self.Grip:SetPos(0, self.PreciseY)
		self.Velocity = nextVel
		if math.abs(self.Velocity) <= 0.1 then self.Velocity = 0 self.PreciseY = nil end
		self:InvalidateParent(true)
		if self.UpArrow:IsDisabled() or self.DownArrow:IsDisabled() then self.Velocity = 0 end
	end
end

function PANEL:PerformLayout(w, t)
	self.UpArrow:SetSize(w, w)
	self.DownArrow:SetSize(w, w)
	local p, Grip = self.parent, self.Grip
	Grip:SetPos(0, math.Clamp(Grip.y, w, t - w - Grip.t))

	if Grip.y == w then
		self.UpArrow:SetDisabled(true)
	elseif Grip.y == t - w - Grip.t then
		self.DownArrow:SetDisabled(true)
	else
		self.UpArrow:SetDisabled(false)
		self.DownArrow:SetDisabled(false)
	end

	local PanelT, CanvasT, TrackSize = p.t, p.Canvas.t, t - w * 2
	self.TrackSize = TrackSize
	Grip:SetSize(w, math.Clamp(TrackSize / (CanvasT / PanelT), 5, TrackSize))
end

gui.Register("VScrollBar", PANEL)