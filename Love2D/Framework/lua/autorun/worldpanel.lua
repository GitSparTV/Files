--[[ local WorldPanel = {}

function WorldPanel:Paint(w,t)
	draw.RoundedBox(0,0,0,w,t,Color(255,255,255))
end

function WorldPanel:Init()
	self:SetSize(ScrW(),ScrH())
	self.SetSize = nil
	self:SetPos(0,0)
end
-- vgui.Register("WorldPanel",WorldPanel)

-- local WP = vgui.Create("WorldPanel")

-- function vgui.GetWorldPanel() return WP end--]] 