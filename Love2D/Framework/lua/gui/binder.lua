local PANEL = {}

function PANEL:Init()
	self:SetText("No Bind")
end

function PANEL:DoClick()
	self:SetText("Press a key")
	self.ListenForInput = true
	input.Listen()
end

function PANEL:Think()
	if self.ListenForInput then
		local key = input.Listened
		if not key then return end
		if key == "escape" then self.ListenForInput = false self:SetText(self.Key) return end
		self.ListenForInput = false
		self.Key = key
		self:SetText(key)
		self:OnChange(key)
	end
end

function PANEL:GetKey()
	return self.Key
end

function PANEL:SetKey(key)
	self.Key = key
	self:SetText(key)
	self:OnChange(key)
end

PANEL.OnChange = EMPTYFUNCTION

gui.Register("Binder",PANEL,"Button")