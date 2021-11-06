function CreateMenu(parent)
	if not parent then gui.Close() end
	return parent:Add("Menu")
end

local PANEL = {}

function PANEL:Init()
	self:SetSize(50, 25)
	self.DrawColumn = false
	gui.AddToClose(self)
	-- self:DisableClipping(true)
end

GetSet(PANEL, "DrawColumn")

function PANEL:Paint(w, t)
	draw.DrawBox(0, 0, w, t, COLOR_LIGHTGRAY)

	if self:GetDrawColumn() then
		draw.DrawBox(0, 0, 16 + 4 + 4, t, COLOR_LIGHTGRAY * 0.8)
	end

	draw.OutlinedBox(1, 1, w - 2, t - 2, Color(0, 150, 255) * 0.7)
end

function PANEL:Stretch()
	self.Canvas:ReThink()
	self.Canvas:SizeToChildren(true, true)
	local _, y = self:LocalToScreen(0, 0)
	self:SetSize(math.max(self.w, self.Canvas.w), math.min(self.Canvas.t, ScrH() - y))
end

function PANEL:AddOption(text, icon, ref)
	local o = self:Add("MenuOption")
	o:SetText(text)
	o.UserStorage = ref
	local w, t = o:GetContentSize()
	o:SetSize(math.max(w + 24,150), t + 13)

	if icon then
		o:SetImage(icon)
	end

	self:Stretch()

	return o
end

function PANEL:AddSeparator()
	local l = self:Add("MenuSeparator")
	self:Stretch()
	return l
end

function PANEL:AddSubMenu(text, icon)
	local o = self:AddOption(text, icon)
	-- local m = gui.Create("Menu")
	local m = o:Add("Menu")
	m:DisableClipping(true)
	o:AddSubMenu(m)
	m:SetVisible(false)
	local x, y = o.w - 3, 0
	m:SetPos(x, y)

	return m, o
end

function PANEL:OpenSubMenu(submenu)
	if self.CurSubMenu == submenu then return end

	if self.CurSubMenu then
		self.CurSubMenu:SetVisible(false)
	end

	self.CurSubMenu = submenu
end

gui.Register("Menu", PANEL, "ScrollPanel")
------------------------------------------
PANEL = {}

function PANEL:Init()
	self:SetContentAlignment(4)
	self:SetSize(150, 40)
	self:SetTextColor(COLOR_BLACK)
	self:Dock(TOP)
end

function PANEL:OnFocusChanged(b)
	if not b and not self:GetRootParent():HasHierarchicalFocus() then
		gui.CloseAll()
	end
end

function PANEL:DoClick()

end

function PANEL:DoRightClick()

end

function PANEL:PerformLayout(w, t)
	self:SetTextMargin(16 + 4 + 4 + 4, 0)
	if self.image then self.image:SetPos(4, div2f(t - self.image.t)) end
end

function PANEL:Think()
	if self.SubMenu and self:IsHovered() then
		local x, y = self.w - 3, 0
		self.SubMenu:SetPos(x, y)
		self.SubMenu:SetVisible(true)
		self:GetParent():GetParent():OpenSubMenu(self.SubMenu)
	end
end

function PANEL:Paint(w, t)
	if self:IsHovered() then
		draw.DrawBox(2, 2, w - 4, t - 4, Color(0, 150, 255, 200))
		draw.OutlinedBox(3, 3, w - 6, t - 6, Color(0, 150, 255, 200) * 0.8)
	end

	if self.SubMenu then
		surface.SetDrawColor(0, 0, 0)
		surface.SetMaterial(Material("menu_arrow1.png"))
		surface.DrawTexturedRect(w - 10 - 4, div2f(t - 10), 10, 10, true)
	end
end

function PANEL:AddSubMenu(m)
	self.SubMenu = m
end

gui.Register("MenuOption", PANEL, "Button")
------------------------------------------
PANEL = {}

function PANEL:Init()
	self:Dock(TOP)
	self:SetSize(10, 5)
end

function PANEL:Paint(w, t)
	surface.SetDrawColor(COLOR_DARKGRAY)
	surface.DrawLine(4, t / 2, w - 4, t / 2)
end

gui.Register("MenuSeparator", PANEL, "Panel")