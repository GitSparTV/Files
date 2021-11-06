gui = {}
local PanelsTree, PanelsMeta, ToClose, Hovered, Focused = {}, {}, {}

function gui.GetPanelsTree()
	return PanelsTree
end

function gui.GetPanelsMeta(panel)
	return PanelsMeta[panel]
end

function gui.GetHoveredPanel()
	return Hovered
end

function gui.AddToClose(panel)
	ToClose[#ToClose + 1] = panel
end

function gui.CloseAll(panel)
	for i = 1, #ToClose do
		ToClose[i]:Remove()
		ToClose[i] = nil
	end
end

require("libraries.modules.panelmeta")
local PANELMeta = debug.getregistry().Panel

hook.Add("Think", "GUIThink", function()
	for i = 1, #PanelsTree do
		if PanelsTree[i] then
			local s = SysTime()
			PanelsTree[i]:MetaThink()
			local e = SysTime()
			PanelsTree[i].ThinkTime = e - s
		end
	end
end)

hook.Add("GUIPaint", "GUIPaint", function()
	for i = 1, #PanelsTree do
		local p = PanelsTree[i]

		if p and not p.parent then
			PanelsTree[i]:MetaPaint()
		end
	end
end)

hook.Add("MousePressed", "GUIMousePressed", function(x, y, button, istouch, presses)
	for i = 1, #PanelsTree do
		local panel = PanelsTree[i]

		if not panel.Removing and panel._MouseCapture then
			panel:OnMousePressed(x, y, button, istouch, presses)
		end
	end

	if Hovered and not Hovered.Removing and not Hovered.disabled and Hovered.MouseLearn then
		if Focused then
			if Focused ~= Hovered then
				Focused.Focused = false
				Hovered.Focused = true
				Focused:OnFocusChanged(false)
				Focused = Hovered

				if Focused then
					Focused:OnFocusChanged(true)
				end
			end
		else
			Hovered.Focused = true
			Focused = Hovered
			Focused:OnFocusChanged(true)
		end

		Hovered:OnMousePressed(x, y, button, istouch, presses)

		return
	end

	if Focused then
		Focused.Focused = false
		Focused:OnFocusChanged(false)
		Focused = nil
	end
end)

hook.Add("MouseReleased", "GUIMouseReleased", function(x, y, button, istouch, presses)
	for i = 1, #PanelsTree do
		local panel = PanelsTree[i]

		if not panel.Removing and panel._MouseCapture then
			panel:OnMouseReleased(x, y, button, istouch, presses)
		end
	end

	if Hovered and not Hovered.disabled and Hovered.MouseLearn then
		Hovered:OnMouseReleased(x, y, button, istouch, presses)
	end
end)

hook.Add("MouseMoved", "GUIMouseMoved", function(x, y, dx, dy, istouch, presses)
	local last

	for i = 1, #PanelsTree do
		local panel = PanelsTree[i]

		if not panel.Removing and panel._MouseCapture then
			panel:OnCursorMoved(x, y, dx, dy, istouch, presses)
		end

		if not panel.Removing and not panel.Visible or (not panel.NoClipping and panel.NotInVisBound) or panel.disabled or not panel.MouseLearn or not panel:IsPosVisible(x, y) then
			goto cont
		end

		last = panel
		::cont::
	end

	if not last then
		if Hovered then
			Hovered:OnCursorExited(x, y, dx, dy, istouch, presses)
			Hovered = nil
			input.SetCursor("arrow")
		end

		return
	end

	if Hovered then
		if Hovered == last then
			last:OnCursorMoved(x, y, dx, dy, istouch, presses)

			if last.CursorOnHover ~= input.CurrentCursor then
				input.SetCursor(last.CursorOnHover)
			end

			return
		end

		Hovered:OnCursorExited(x, y, dx, dy, istouch, presses)
		Hovered = last
		Hovered:OnCursorEntered(x, y, dx, dy, istouch, presses)

		if Hovered.CursorOnHover ~= input.CurrentCursor then
			input.SetCursor(Hovered.CursorOnHover)
		end

		return
	end

	Hovered = last
	Hovered:OnCursorEntered(x, y, dx, dy, istouch, presses)

	if Hovered.CursorOnHover ~= input.CurrentCursor then
		input.SetCursor(Hovered.CursorOnHover)
	end
end)

hook.Add("MouseWheeled", "GUIMouseWheeled", function(delta)
	for i = 1, #PanelsTree do
		local panel = PanelsTree[i]

		if panel._MouseCapture then
			panel:OnMouseWheeled(delta)
		end

		if not panel.Visible or (not panel.NoClipping and panel.NotInVisBound) or panel.disabled or not panel.MouseLearn or not panel:IsPosVisible(input.GetCursorPos()) then
			goto cont
		end

		panel:OnMouseWheeled(delta)
		::cont::
	end

	hook.Run("MouseMoved", input.MouseX(), input.MouseY(), 0, 0, false, 0)
end)

hook.Add("TextInput", "GUITextInput", function(text)
	if Focused and not Focused.disabled and Focused.KeyLearn then
		Focused:OnTextInput(text)
	end
end)

hook.Add("KeyPress", "GUIKeyPress", function(key, scancode, isrepeat)
	if Focused and not Focused.disabled and Focused.KeyLearn then
		Focused:OnKeyCodePressed(key, scancode, isrepeat)
	end
end)

hook.Add("KeyRelease", "GUIKeyRelease", function(key, scancode)
	if Focused and not Focused.disabled and Focused.KeyLearn then
		Focused:OnKeyCodeReleased(key, scancode)
	end
end)

function gui.Create(panel, parent)
	local meta = PanelsMeta[panel]

	if not meta then
		error("No Meta")
	end

	if meta.BasePanel then
		local p = gui.Create(meta.BasePanel, parent)
		setmetatable(p, meta)
		p.init = false

		if p.Init then
			p:Init()
		end

		p.init = true

		return p
	end

	local p = {}
	setmetatable(p, meta)
	p:Prepare()

	if p.Init then
		p:Init()
	end

	p.init = true
	PanelsTree[#PanelsTree + 1] = p

	if parent then
		p:SetParent(parent)
	end

	return p
end

function gui.Remove(panel)
	if Hovered == panel then
		Hovered = nil
	end

	if Focused == panel then
		Focused = nil
	end
end

function PMGetBaseMeta(self)
	return PanelsMeta[self.BasePanel]
end

function gui.Register(name, meta, base)
	meta.BasePanel = base or "Panel"
	meta.PanelName = name
	PanelsMeta[name] = meta
	meta.GetBaseMeta = PMGetBaseMeta

	function meta.__index(t, k)
		return meta[k] or PanelsMeta[meta.BasePanel].__index(t, k)
	end

	meta.__tostring = PANELMeta.__tostring
	print("Registered: " .. name)
end

function gui.RegisterBase(name, meta)
	BasePanel = meta
	meta.PanelName = name
	PanelsMeta[name] = meta

	function meta.__index(t, k)
		return meta[k] or PANELMeta[k]
	end

	meta.__tostring = PANELMeta.__tostring
	print("Registered Base: " .. name)
end

function gui.NoPaint(meta)
	meta.Paint = EMPTYFUNCTION
	meta.PaintOver = EMPTYFUNCTION
	meta.color = nil
end