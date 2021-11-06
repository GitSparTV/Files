local PANEL = {}
PANEL.Lines = 12
PANEL.Padding = 10
PANEL.Speed = 10
PANEL.LineSize = 4

function PANEL:SetLineAmount(a)
	self.Lines = a
end

function PANEL:SetLineSize(s)
	self.LineSize = s
end

function PANEL:SetSpeed(s)
	self.Speed = s
end

function PANEL:SetPadding(s)
	self.Padding = s
end

function PANEL:Paint(w, t)
	local x, y, W, T = Floor4(w / 2 + self.Padding, t / 2 - div2f(self.LineSize), w / 2 - self.Padding, self.LineSize)

	for i = 0, 360, 360 / self.Lines do
		if i > 360 then return end
		draw.DrawRectRotated(x, y, W, T, COLOR_WHITE * (self.Mode and (0.2 * i / 360 - (SysTime() * self.Speed) % 10 / 10) or (0.3 + ((i - SysTime() * 36 * self.Speed) % 360) / 360 * 0.7)), math.rad(i), -self.Padding, div2f(T))
	end
end

gui.Register("Throbber", PANEL)