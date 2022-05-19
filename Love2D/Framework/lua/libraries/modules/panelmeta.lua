local PM = {}
PM.__type = "panel"
PM.__index = PM
debug.getregistry().Panel = PM
NODOCK = 0
FILL = 1
LEFT = 2
RIGHT = 3
TOP = 4
BOTTOM = 5

function PM:Prepare()
	self.x, self.y, self.w, self.t = 0, 0, 32, 32
	self.Visible, self.NoClipping, self.CachedVisBound = true, false, {0, 0, 0, 0}
	self.Children = {}
	self.Focused, self.KeyLearn, self.MouseLearn, self._MouseCapture, self.CursorOnHover = false, false, false, false, "arrow"
	self._DockMargin, self._DockPadding, self.realw, self.realt, self.ZChildren, self.dock, self.ZPos = {0, 0, 0, 0}, {0, 0, 0, 0}, 32, 32, {}, NODOCK, 0
end

function PM:__tostring()
	if self.Removing or self.Dead then return "[Panel] [DEAD]" end

	return "[Panel:" .. self.PanelName .. "] " .. (self.Name and "[" .. self.Name .. "] " or "") .. "[" .. string.format("%d, %d, %d, %d",self.x, self.y, self.w, self.t) .. "]"
end

function PM:SetName(n)
	if n == nil then
		self.Name = nil

		return
	end

	self.Name = tostring(n)
end

function PM:GetName()
	return self.Name or ""
end

function PM:SetPos(x, y)
	if self.x == x and self.y == y then return end
	self.x = math.floor(x or self.x)
	self.y = math.floor(y or self.y)
end

function PM:SetSize(w, t)
	w, t = math.floor(w or self.w), math.floor(t or self.t)
	if self.w == w and self.t == t then return end
	self.w = w
	self.t = t
	self.realw, self.realt = w, t

	if self.parent then
		self.parent.DockUpdate = true
	end

	self.DockUpdate = true
	self:InvalidateLayout()
end

function PM:AppendSize(w, t)
	self:SetSize(self.w + w, self.t + t)
end

function PM:GetPos(x, y)
	return self.x, self.y
end

function PM:GetSize(w, t)
	return self.w, self.t
end

function PM:GetBounds()
	return self.x, self.y, self.w, self.t
end

function PM:GetScreenBounds()
	local x, y = self:LocalToScreen(0, 0)

	return x, y, self.w, self.t
end

function PM:GetRealBounds()
	return self.x, self.y, self.realw or self.w, self.realt or self.t
end

function PM:Center()
	if self.parent then
		local w, t = self.parent:GetSize()

		return self:SetPos(w / 2 - self.w / 2, t / 2 - self.t / 2)
	end

	self:SetPos(ScrW() / 2 - self.w / 2, ScrH() / 2 - self.t / 2)
end

function PM:SetCursor(c)
	self.CursorOnHover = c
end

function PM:MouseCapture(c)
	self._MouseCapture = c
end

function PM:IsHovered()
	return gui.GetHoveredPanel() == self
end

function PM:SetMouseInputEnabled(b)
	self.MouseLearn = b
end

function PM:IsMouseInputEnabled(b)
	return self.MouseLearn or self._MouseCapture
end

PM.OnMousePressed = EMPTYFUNCTION
PM.OnMouseReleased = EMPTYFUNCTION
PM.OnMouseWheeled = EMPTYFUNCTION
PM.OnCursorMoved = EMPTYFUNCTION
PM.OnCursorEntered = EMPTYFUNCTION
PM.OnCursorExited = EMPTYFUNCTION

function PM:SetKeyboadInputEnabled(b)
	self.KeyLearn = b
end

function PM:IsKeyboadInputEnabled(b)
	return self.KeyLearn
end

PM.OnKeyCodePressed = EMPTYFUNCTION
PM.OnKeyCodeReleased = EMPTYFUNCTION
PM.OnTextInput = EMPTYFUNCTION
PM.OnFocusChanged = EMPTYFUNCTION

function PM:LocalToScreen(w, t)
	local x, y = self.x, self.y

	if self.parent then
		x, y = self.parent:LocalToScreen(self.x, self.y)
	end

	return x + w, y + t
end

function PM:ScreenToLocal(x, y)
	local x0, y0 = self:LocalToScreen(0, 0)

	return x - x0, y - y0
end

function PM:GetVisibleArea()
	local x, y = self:LocalToScreen(0, 0)
	local w, t, CVB, p, VisFail = self.w, self.t, self.CachedVisBound, self.parent

	if not self.Visible then
		VisFail = true
		goto skip
	end

	if p then
		local px, py, pw, pt = p:GetVisibleArea()

		if pw == 0 or pt == 0 then
			VisFail = true
			goto skip
		end

		local lx, ly, lw, lt, prex, prey = px < x, py < y, px + pw < x + w, py + pt < y + t, x, y
		w, t, x, y = lw and (px + pw) - x or w, lt and (ly and (py + pt) - y or pt) or t, lx and x or px, ly and y or py

		if w < 0 or t < 0 or (not lw and prex + w <= px) or (not lt and prey + t <= py) then
			VisFail = true
		end
	elseif x + w <= 0 or y + t <= 0 or x > ScrW() or y > ScrH() then
		VisFail = true
	end

	::skip::
	self.NotInVisBound = VisFail

	if VisFail then
		x, y, w, t = 0, 0, 0, 0
	end

	CVB[1], CVB[2], CVB[3], CVB[4] = x, y, w, t

	return x, y, w, t
end

-- function PM:GetVisibleArea()
-- 	local x, y, w, t = self.x, self.y, self.w, self.t
-- 	if self.parent then
-- 		local p = self.parent
-- 		local px, py, pw, pt = p:GetVisibleArea()
-- 		local prx, pry, prw, prt = p:GetBounds()
-- 		if prx < 0 then
-- 			x = x + prx
-- 		end
-- 		if pry < 0 then
-- 			y = y + pry
-- 		end
-- 		if px <= 0 or py <= 0 or pw <= 0 or pt <= 0 then
-- 			self.NotInVisBound = true
-- 			self.CachedVisBound[1], self.CachedVisBound[2], self.CachedVisBound[3], self.CachedVisBound[4] = 0, 0, 0, 0
-- 			return 0, 0, 0, 0
-- 		end
-- 		-- x = x - (prw - pw)
-- 		-- y = y - (prt - pt)
-- 		-- end
-- 		x, y = px + x, py + y
-- 		local gpw, gpt, gw, gt, sx, sy, dx, dy = px + pw, py + pt, x + w, y + t, x < px, y < py, px - x, py - y
-- 		w, t = gpw < gw and w + gpw - gw or w, gpt < gt and t + gpt - gt or t
-- 		w, t = sx and w - dx or w, sy and t - dy or t
-- 		x, y = sx and px or x, sy and py or y
-- 		if px > gw or py > gt or x > gpw or y > gpt then
-- 			self.NotInVisBound = true
-- 			self.CachedVisBound[1], self.CachedVisBound[2], self.CachedVisBound[3], self.CachedVisBound[4] = 0, 0, 0, 0
-- 			return 0, 0, 0, 0
-- 		end
-- 	end
-- 	self.NotInVisBound = false
-- 	self.CachedVisBound[1], self.CachedVisBound[2], self.CachedVisBound[3], self.CachedVisBound[4] = x, y, w, t
-- 	return x, y, w, t
-- end
function PM:GetCachedVisibleArea()
	return self.CachedVisBound[1], self.CachedVisBound[2], self.CachedVisBound[3], self.CachedVisBound[4]
end

function PM:IsPosVisible(x, y)
	local vx, vy, vw, vt = self:GetCachedVisibleArea()

	if self.NoClipping then
		vx, vy, vw, vt = self:GetScreenBounds()
	end

	if x < vx or y < vy or x > vx + vw or y > vy + vt then return false end

	return true
end

function PM:IsFocused()
	return self.Focused
end

function PM:GetRootParent()
	if not self.parent then return self end

	return self.parent:GetRootParent()
end

function PM:HasHierarchicalFocus()
	if self:IsFocused() then return true end

	for i = 1, #self.Children do
		if self.Children[i]:HasHierarchicalFocus() then return true end
	end

	return false
end

PM.OnChildAdded = EMPTYFUNCTION
PM.OnChildRemoved = EMPTYFUNCTION

function PM:GetChildren()
	return self.Children
end

function PM:SizeToChildren(x, y)
	local maxw, maxt = 0, 0

	for i = 1, #self.Children do
		local p = self.Children[i]
		local px, py, w, t = p:GetRealBounds()
		w, t = px + w, py + t

		if x and maxw < w then
			maxw = w
		end

		if y and maxt < t then
			maxt = t
		end
	end

	if x and maxw < 0 or y and maxt < 0 then return end
	self:SetSize(x and maxw or self.w, y and maxt or self.t)
end

function PM:SetParent(parent)
	if self.parent == parent then return end

	if self.parent and self.parent ~= parent then
		table.RemoveByValue(self.parent.Children, self)

		if parent.init then
			self.parent:OnChildRemoved(self)
		end

		self.parent.DockUpdate = true
		self.parent.ZPosUpdate = true
	end

	self.parent = parent
	parent.Children[#parent.Children + 1] = self

	if parent.init then
		parent:OnChildAdded(self)
	end

	parent.DockUpdate = true
	parent.ZPosUpdate = true
end

function PM:GetParent()
	return self.parent
end

function PM:Add(panel)
	return gui.Create(panel, self)
end

local function RemovingFunc(self)
	gui.Remove(self)
	table.RemoveByValue(gui.GetPanelsTree(), self)

	for k, v in pairs(self) do
		self[k] = nil
	end

	self.Dead = true
end

function PM:Remove()
	if self.OnRemove then
		self:OnRemove()
	end

	self.Removing = true

	if self.parent and not self.parent.Removing then
		table.RemoveByValue(self.parent.Children, self)
		table.RemoveByValue(self.parent.ZChildren, self)
		self.parent:OnChildRemoved(self)
	end

	for i = 1, #self.Children do
		self.Children[i]:Remove()
	end

	timer.Simple(0, RemovingFunc, self)
end

function PM:MetaThink()
	if self.Removing then return end
	self:ZPosThink()
	self:DockCalc()

	if self.NextLayout then
		self:InvalidateLayout(true)
	end

	self:Think()
	self:AnimationThink()
end

PM.ReThink = PM.MetaThink
PM.AnimationThink = EMPTYFUNCTION
PM.Think = EMPTYFUNCTION

function PM:DisableClipping(b)
	self.NoClipping = b
end

PM.Paint = EMPTYFUNCTION
PM.PaintOver = EMPTYFUNCTION

function PM:MetaPaint()
	if self.Removing then return end
	if self.parent and (not self.parent.Visible or self.parent.NotInVisBound) then return end
	local vx, vy, vw, vt = self:GetVisibleArea()
	if not self.Visible or (not self.NoClipping and self.NotInVisBound) then return end
	local x, y = self:LocalToScreen(0, 0)
	render.PushRenderTarget(RT_PUSH_ALL)
	if vw <= 0 or vt <= 0 then return render.PopRenderTarget() end

	-- Draw not relative to parent
	if not self.NoClipping then
		render.SetScissorRect(vx, vy, vw, vt)
	end

	render.Translate(x, y)
	self:Paint(self.w, self.t)
	self:PaintOver(self.w, self.t)
	render.PopRenderTarget()

	for i = 1, #self.ZChildren do
		self.ZChildren[i]:MetaPaint()
	end
end

function PM:SetDisabled(d)
	self.disabled = d
end

function PM:IsDisabled()
	return self.disabled
end

function PM:SetVisible(d)
	self.Visible = d
end

function PM:IsVisible()
	return self.Visible
end

function PM:GetZPos()
	return self.ZPos
end

function PM:SetZPos(z)
	self.ZPos = z

	if self.parent then
		self.parent.DockUpdate = true
		self.parent.ZPosUpdate = true
	end
end

function PM:DockPadding(l, t, r, b)
	self._DockPadding[1], self._DockPadding[2], self._DockPadding[3], self._DockPadding[4] = l, t, r, b
end

function PM:DockMargin(l, t, r, b)
	self._DockMargin[1], self._DockMargin[2], self._DockMargin[3], self._DockMargin[4] = l, t, r, b
end

function PM:Dock(d)
	self.dock = d

	if self.parent then
		self.parent.DockUpdate = true
		self.parent.ZPosUpdate = true
	end
end

PM.PerformLayout = EMPTYFUNCTION

function PM:InvalidateLayout(now)
	if now then
		self:PerformLayout(self.w, self.t)

		if self.parent then
			self.parent:InvalidateLayout(true)
		end

		self.NextLayout = nil
		self.DockUpdate = true
	else
		self.NextLayout = true
	end
end

function PM:InvalidateParent(now)
	self.parent:InvalidateLayout(now)
end

function PM:ZPosThink()
	if self.ZPosUpdate then
		local PreZ, Zn = {{}}, 0

		for i = 1, #self.Children do
			local p = self.Children[i]
			local zpos = p.ZPos

			if Zn < zpos + 1 then
				Zn = zpos + 1
			end

			if not PreZ[zpos + 1] then
				PreZ[zpos + 1] = {}
			end

			PreZ[zpos + 1][#PreZ[zpos + 1] + 1] = p
		end

		self.ZChildren = {}
		local ZC = self.ZChildren

		for i = Zn, 1, -1 do
			local z = PreZ[i]

			for I = 1, #z do
				ZC[#ZC + 1] = z[I]
			end
		end

		self.ZPosUpdate = false
	end
end

function PM:DockCalc()
	if not self.DockUpdate or not self.init then return end
	self:PerformLayout(self.w, self.t)
	local sx, sy, sw, st = self._DockPadding[1], self._DockPadding[2], self.w - self._DockPadding[1] - self._DockPadding[3], self.t - self._DockPadding[2] - self._DockPadding[4]
	local ZC = self.ZChildren

	for i = 1, #ZC do
		local p = ZC[i]

		if p.dock == NODOCK or not p.Visible then
			goto cont
		end

		local w, t = p.realw, p.realt
		local prex, prey, prew, pret = p.x, p.y, p.w, p.t

		if p.dock == LEFT then
			p.x, p.y, p.w, p.t = sx + p._DockMargin[1], sy + p._DockMargin[2], math.Clamp(w, 0, sw) - p._DockMargin[1], st - p._DockMargin[2] - p._DockMargin[4]
			sx, sw = sx + p.x + p.w + p._DockMargin[3], sw - p.x - p.w - p._DockMargin[3]
		elseif p.dock == RIGHT then
			p.w, p.t = math.Clamp(w, 0, sw), st - p._DockMargin[2] - p._DockMargin[4]
			p.x, p.y = sx + sw - p.w - p._DockMargin[3], sy + p._DockMargin[2]
			sw = sw - p.w - p._DockMargin[1] - p._DockMargin[3]
		elseif p.dock == TOP then
			p.x, p.y, p.w, p.t = sx + p._DockMargin[1], sy + p._DockMargin[2], sw - p._DockMargin[1] - p._DockMargin[3], math.Clamp(t, 0, st) - p._DockMargin[2]
			sy, st = sy + p.t + p._DockMargin[4], st - p.t - p._DockMargin[4]
		elseif p.dock == BOTTOM then
			p.w, p.t = sw - p._DockMargin[1] - p._DockMargin[3], math.Clamp(t, 0, st)
			p.x, p.y = sx + p._DockMargin[1], sy + st - p.t - p._DockMargin[4]
			st = st - p.t - p._DockMargin[4] - p._DockMargin[2]
		end

		if prex ~= p.x or prey ~= p.y or prew ~= p.w or pret ~= p.t then
			p:InvalidateLayout()
		end

		::cont::
	end

	for i = 1, #ZC do
		local p = ZC[i]

		if p.dock ~= FILL then
			goto cont
		end

		local prex, prey, prew, pret = p.x, p.y, p.w, p.t
		p.x, p.y, p.w, p.t = sx + p._DockMargin[1], sy + p._DockMargin[2], sw - p._DockMargin[1] - p._DockMargin[3], st - p._DockMargin[2] - p._DockMargin[4]

		if prex ~= p.x or prey ~= p.y or prew ~= p.w or pret ~= p.t then
			p:InvalidateLayout()
		end

		::cont::
	end

	self:PerformLayout(self.w, self.t)
	self.DockUpdate = false
end

function PM:AddErp(mode, time, from, to)
	if not self.ErpList then
		function self:AnimationThink()
			for k, v in pairs(self.ErpList) do
				if not v.on then
					goto cont
				end

				self[v.id] = v.func(SysTime() - v.systime, v.time, v.lastval or (v.switch and v.from or v.to), v.switch and v.to or v.from)
				::cont::
			end

			if self.ThinkHook then
				for k, v in pairs(self.ThinkHook) do
					self[v](self)
				end
			end
		end

		self.ErpList = {}
	end

	self.ErpList[#self.ErpList + 1] = {
		id = "Erp_" .. (#self.ErpList + 1),
		func = mode,
		time = time,
		from = from,
		to = to,
		switch = true,
		systime = SysTime(),
		on = true
	}

	return "Erp_" .. (table.Count(self.ErpList))
end

function PM:AddThinkHook(func)
	if not self.ErpList then
		function self:AnimationThink()
			if self.ThinkHook then
				for k, v in pairs(self.ThinkHook) do
					self[v](self)
				end
			end
		end

		self.ThinkHook = {}
		self.ErpList = {}
	end

	self.ThinkHook[#self.ThinkHook + 1] = func
end

function PM:SetErpRange(id, a, b)
	if not self.ErpList or not self.ErpList[id] then return end
	self.ErpList[id].from = a
	self.ErpList[id].to = b
end

function PM:GetErpRange(id)
	if not self.ErpList or not self.ErpList[id] then return end

	return self.ErpList[id].from, self.ErpList[id].to
end

function PM:SetErpMode(id, func)
	if not self.ErpList or not self.ErpList[id] then return end
	self.ErpList[id].func = func
end

function PM:IsErpCompleted(id)
	if not self.ErpList or not self.ErpList[id] then return end

	return SysTime() - self.ErpList[id].systime > self.ErpList[id].time
end

function PM:SetErpOn(id, b)
	if not self.ErpList or not self.ErpList[id] then return end
	self.ErpList[id].on = b
end

function PM:SetErpEndTime(id, a)
	if not self.ErpList or not self.ErpList[id] then return end
	self.ErpList[id].time = a
end

function PM:DeleteErp(id)
	if not self.ErpList or not self.ErpList[id] then return end
	table.remove(self.ErpList, id)
	self["Erp_" .. id] = nil
end

function PM:DeleteAllErp()
	if not self.ErpList then return end

	for k, v in pairs(self.ErpList) do
		self.ErpList[k] = nil
		self["Erp_" .. id] = nil
	end
end

function PM:SwitchErp(id, bool)
	if not self.ErpList or not self.ErpList[id] then return end

	if self.ErpList[id].switch ~= bool then
		self.ErpList[id].systime = SysTime()
		self.ErpList[id].switch = bool
		self.ErpList[id].lastval = self[self.ErpList[id].id]
	end
end

function PM:GetErpTime(id)
	if not self.ErpList or not self.ErpList[id] then return end

	return SysTime() - (self.ErpList[id].systime or 0)
end

function PM:FeedErpClock(id)
	if not self.ErpList or not self.ErpList[id] then return end
	self.ErpList[id].systime = SysTime()
end

function PM:SetErpClock(id, s)
	if not self.ErpList or not self.ErpList[id] then return end
	self.ErpList[id].systime = s
end

function PM:GetErpClock(id)
	if not self.ErpList or not self.ErpList[id] then return end

	return self.ErpList[id].systime
end

function PM:GetErpState(id)
	if not self.ErpList or not self.ErpList[id] then return end

	return self.ErpList[id].switch
end