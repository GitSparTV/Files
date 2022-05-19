local PANEL = {}

function PANEL:Init()
	self.ViewPort = self:Add("Panel")
	self.ViewPort.Paint = function() end
	self:SetMouseInputEnabled(true)

	self.ViewPort.OnMousePressed = function(self, code)
		self:GetParent():OnMousePressed(code)
	end

	self.ViewPort.PerformLayout = function(pnl)
		self:PerformLayout()
		self:InvalidateParent()
	end

	-- self.ViewPort:SizeToChildren(false,true)
	self.ScrollBar = self:Add("ScrollBar")
	self.ScrollBar:Dock(RIGHT)
end

function PANEL:Paint(w, t)
end

function PANEL:Rebuild()
	self.ViewPort:SizeToChildren(false, true)

	-- Although this behaviour isn't exactly implied, center vertically too
	if (self.m_bNoSizing and self.ViewPort:GetTall() < self:GetTall()) then
		self.ViewPort:SetPos(0, (self:GetTall() - self.ViewPort:GetTall()) * 0.5)
	end
end

function PANEL:PerformLayout()
	local Tall = self.ViewPort:GetTall()
	local Wide = self:GetWide()
	local YPos = 0
	self:Rebuild()
	self.ScrollBar:SetUp(self:GetTall(), self.ViewPort:GetTall())
	YPos = self.ScrollBar:GetOffset()

	if (self.ScrollBar.Enabled) then
		Wide = Wide - self.ScrollBar:GetWide()
	end

	self.ViewPort:SetPos(0, YPos)
	self.ViewPort:SetWide(Wide)
	self:Rebuild()

	if (Tall ~= self.ViewPort:GetTall()) then
		self.ScrollBar:_SetScroll(self.ScrollBar:GetScroll()) -- Make sure we are not too far down!
	end
end

function PANEL:SizeToContents()
	self:SetSize(self.ViewPort:GetSize())
end

function PANEL:OnChildAdded(p)
	if not self:IsInitCalled() then return end
	p:SetParent(self.ViewPort)
end

function PANEL:OnVScroll(iOffset)
	self.ViewPort:SetPos(0, iOffset)
end

function PANEL:ScrollToChild(panel, eng)
	self:PerformLayout()
	local x, y = panel:GetPos()
	local w, h = panel:GetSize()
	y = y + h * 0.5
	y = y - self:GetTall() * 0.5
	self.ScrollBar:AnimateTo(y, 0.5, eng)
end

function PANEL:OnMouseWheeled(dlta)
	return self.ScrollBar:OnMouseWheeled(dlta)
end

vgui.Register("ScrollPanel", PANEL)
-------------------
local PANEL = {}
AccessorFunc(PANEL, "m_HideButtons", "HideButtons")

function PANEL:Init()
	self.Offset = 0
	self.Scroll = 0
	self.CanvasSize = 1
	self.BarSize = 1
	self.btnUp = vgui.Create("Button", self)
	self.btnUp:SetText("")

	self.btnUp.DoClick = function(self)
		self:GetParent():AddScroll(-1)
	end

	self.btnUp:SetText("˄")
	self.btnUp:SetFont("Unifont15")
	self.btnUp.yalign = 0
	self.btnUp:SetOffset(0, -5)
	self.btnDown = vgui.Create("Button", self)
	self.btnDown:SetText("")

	self.btnDown.DoClick = function(self)
		self:GetParent():AddScroll(1)
	end

	self.btnDown:SetText("˅")
	self.btnDown:SetFont("Unifont15")
	self.btnDown.yalign = 0
	self.btnDown:SetOffset(0, -5)
	self.btnGrip = vgui.Create("Button", self)
	self.btnGrip:SetText("")

	function self.btnGrip:OnMousePressed()
		self:GetParent():Grip()
	end

	self:SetSize(15, 15)
	self:SetHideButtons(false)
end

function PANEL:Paint(w, t)
	draw.RoundedBox(0, 0, 0, w, t, Color(50, 50, 50))
end

function PANEL:SetEnabled(b)
	if (not b) then
		self.Offset = 0
		self:SetScroll(0)
		self.HasChanged = true
	end

	self:SetMouseInputEnabled(b)
	self:SetVisible(b)

	-- We're probably changing the width of something in our parent
	-- by appearing or hiding, so tell them to re-do their layout.
	if (self.Enabled ~= b) then
		self:GetParent():InvalidateLayout()

		if (self:GetParent().OnScrollbarAppear) then
			self:GetParent():OnScrollbarAppear()
		end
	end

	self.Enabled = b
end

function PANEL:Value()
	return self.Pos
end

function PANEL:BarScale()
	if (self.BarSize == 0) then return 1 end

	return self.BarSize / (self.CanvasSize + self.BarSize)
end

function PANEL:SetUp(_barsize_, _canvassize_)
	self.BarSize = _barsize_
	self.CanvasSize = math.max(_canvassize_ - _barsize_, 1)
	self:SetEnabled(_canvassize_ > _barsize_)
	self:InvalidateLayout()
end

function PANEL:OnMouseWheeled(dlta)
	if (not self:IsVisible()) then return false end
	-- We return true if the scrollbar changed.
	-- If it didn't, we feed the mousehweeling to the parent panel
	-- if self.Erp_1 then dlta = dlta * self.DeltaMul end
	return self:AddScroll(dlta * -2, true)
end

function PANEL:AddScroll(dlta, scroll)
	local OldScroll = self:GetScroll()
	dlta = dlta * 25

	if scroll then
		self:SetScroll(self:GetScroll() + dlta)
	else
		self:SetScroll(self:GetScroll() + dlta, nil, true)
	end

	return OldScroll ~= self:GetScroll()
end

function PANEL:SetScroll(scrll, eng, nospeed, speed)
	if (not self.Enabled) then self.Scroll = 0 return end
	self:AnimateTo(scrll, speed or 0.5, eng or oQuerp, nospeed)
end

function PANEL:_SetScroll(scrll)
	if (not self.Enabled) then
		self.Scroll = 0

		return
	end

	-- self:GetParent():PerformLayout(self:GetParent().w,self:GetParent().t)
	-- self:PerformLayoutInternal(true)
	self.Scroll = math.Clamp(scrll, 0, self.CanvasSize)
	self:InvalidateLayout()
	-- If our parent has a OnVScroll function use that, if
	-- not then invalidate layout (which can be pretty slow)
	local func = self:GetParent().OnVScroll

	if (func) then
		func(self:GetParent(), self:GetOffset())
	else
		self:GetParent():InvalidateLayout()
	end
end

function PANEL:GetScroll()
	if (not self.Enabled) then
		self.Scroll = 0
	end

	return self.Scroll
end

function PANEL:GetOffset()
	if (not self.Enabled) then return 0 end

	return self.Scroll * -1
end

function PANEL:Scroller()
	self:_SetScroll(self.Erp_1 or self:GetScroll())

	if self:IsErpCompleted(1) then
		self:DeleteErp(1)
		self.Erp_1 = nil
		self.DeltaMul = nil
		self:RemoveThinkHook("Scroller")

		return
	end
end

function PANEL:AnimateTo(scrll, delay, eng, nospeed)
	-- io.print(,)
	if self.Erp_1 then
		if math.sign(self:GetScroll()-scrll) ~= math.sign(self:GetScroll()-(select(2,self:GetErpRange(1)) or 0)) then
			self.DeltaMul = 0
		end
		self:FeedErpClock(1)
		self.DeltaMul = math.Clamp(self.DeltaMul + 0.2,0,5)

		self:SetErpRange(1, self:GetScroll(),nospeed and scrll or self:GetScroll() + (scrll - self:GetScroll()) * self.DeltaMul)
	else
		self:AddErp(eng or iCuerp, delay, self.Scroll, scrll)
		self:AddThinkHook("Scroller")
		self.DeltaMul = 0
	end
end

function PANEL:Think()
end

function PANEL:OnMousePressed()
	local _, y = self:CursorPos()
	local PageSize = self.BarSize

	if (y > self.btnGrip.y) then
		self:SetScroll(self:GetScroll() + PageSize, nil, true)
	else
		self:SetScroll(self:GetScroll() - PageSize, nil, true)
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = false
	self.DraggingCanvas = nil
	self:MouseCapture(false)
	self.btnGrip.Depressed = false
end

function PANEL:OnCursorMoved(x, y)
	if (not self.Enabled) then return end
	if (not self.Dragging) then return end
	local x, y = self:ScreenToLocal(0, y)
	-- Uck.
	y = y - self.btnUp:GetTall()
	y = y - self.HoldPos
	local BtnHeight = self:GetWide()

	if (self:GetHideButtons()) then
		BtnHeight = 0
	end

	local TrackSize = self:GetTall() - BtnHeight * 2 - self.btnGrip:GetTall()
	y = y / TrackSize
	self:SetScroll(y * self.CanvasSize, oCuerp, true, 0.5)
end

function PANEL:Grip()
	if (not self.Enabled) then return end
	if (self.BarSize == 0) then return end
	self:MouseCapture(true)
	self.Dragging = true
	local x, y = self.btnGrip:ScreenToLocal(0, input.MouseY())
	self.HoldPos = y
	self.btnGrip.Depressed = true
end

function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local BtnHeight = Wide

	if (self:GetHideButtons()) then
		BtnHeight = 0
	end

	local Scroll = self:GetScroll() / self.CanvasSize
	local BarSize = math.max(self:BarScale() * (self:GetTall() - (BtnHeight * 2)), 10)
	local Track = self:GetTall() - (BtnHeight * 2) - BarSize
	Track = Track + 1
	Scroll = Scroll * Track
	self.btnGrip:SetPos(0, BtnHeight + Scroll)
	self.btnGrip:SetSize(Wide, BarSize)

	if (BtnHeight > 0) then
		self.btnUp:SetPos(0, 0, Wide, Wide)
		self.btnUp:SetSize(Wide, BtnHeight)
		self.btnDown:SetPos(0, self:GetTall() - BtnHeight)
		self.btnDown:SetSize(Wide, BtnHeight)
		self.btnUp:SetVisible(true)
		self.btnDown:SetVisible(true)
	else
		self.btnUp:SetVisible(false)
		self.btnDown:SetVisible(false)
		self.btnDown:SetSize(Wide, BtnHeight)
		self.btnUp:SetSize(Wide, BtnHeight)
	end
end

-- 
vgui.Register("ScrollBar", PANEL)