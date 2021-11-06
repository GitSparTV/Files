local PANEL = {}
PANEL.Animated = false
PANEL.Intermediated = false
PANEL.Circle = false
PANEL.Segments = 1
PANEL.SegmentsPadding = 0
PANEL.TextPos = 0
PANEL.TextBackground = true
PANEL.BackgroundColor = COLOR_GRAY
PANEL.BarColor = COLOR_GREEN * 0.8
PANEL.TextBackgroundColor = PANEL.BackgroundColor:SetAlpha(200)
PANEL.Erp_1 = 0

function PANEL:Init()
	self:AddErp(oCuerp, 0.3, 0, 0)
	self:SetErpOn(1, false)
end

function PANEL:SetPercent(perc, normalize)
	if not normalize then
		perc = math.floor(perc) / 100
	end

	if self.Animated then
		self:SetErpRange(1, self.Erp_1, math.Clamp(perc, 0, 1))
		self:FeedErpClock(1)
		self:SetErpOn(1, true)
	else
		self:SetErpOn(1, false)
		self.Erp_1 = math.Clamp(perc, 0, 1)
	end
end

function PANEL:SetBackgroundColor(color) self.BackgroundColor = color end
function PANEL:SetBarColor(color) self.BarColor = color end
function PANEL:SetTextBackgroundColor(color) self.TextBackgroundColor = color end

function PANEL:SetAnimated(b)
	self.Animated = b
end

function PANEL:SetIntermediated(b)
	self.Intermediated = b
end

function PANEL:SetCircleMode(b)
	self.Circle = b
end

function PANEL:SetText(mode, bg_bool)
	if self.Intermediated then
		self.InterText = mode
	end

	if not mode then
		self.TextPos = 0

		return
	end

	self.TextPos = mode

	if bg_bool ~= nil then
		self.TextBackground = bg_bool
	end
end

function PANEL:GetPercent()
	return math.floor(self.Erp_1 * 100)
end

function PANEL:SetSegments(seg, padding)
	self.Segments = math.max(math.floor(seg), 1) or self.Segments
	self.SegmentsPadding = padding or self.SegmentsPadding
end

function PANEL:Paint(w, t)
	if self.Circle then
		draw.DrawCircle(w/2,t/2,t/2,self.BackgroundColor,360)
		draw.DrawArc(w/2,t/2,t/2 - 2,- math.pi/2,math.Remap(self.Erp_1,0,1,0,math.pi * 2) - math.pi/2,self.BarColor,360)
		return
	end
	if self.Intermediated then
		draw.RoundedBox(4, 0, 0, w, t, self.BackgroundColor)
		draw.RoundedBox(4, 1, 1, w - 2, t - 2, self.BarColor * (0.7 + absin(SysTime()) * 0.3))

		if self.InterText then
			draw.SimpleText(self.InterText, nil, w / 2, t / 2, COLOR_WHITE, 1, 1)
		end

		return
	end

	local padding, segments = self.SegmentsPadding, self.Segments
	padding = padding + (w % 2 == 0 and padding % 2 or (padding % 2 == 0 and 1 or 0))
	local size = (w - padding * (segments - 1)) / segments

	for i = 0, segments - 1 do
		if segments == 1 then
			draw.RoundedBox(4, 0, 0, w, t, self.BackgroundColor)
			draw.RoundedBox(4, 1, 1, math.Clamp(self.Erp_1 * w, 0, w) - 2, t - 2, self.BarColor)
		else
			draw.RoundedBox(4, i * (size + padding), 0, size, t, self.BackgroundColor)
			local loading0, loading1 = (1 / segments) * i, (1 / segments) * (i + 1)
			draw.RoundedBox(4, i * (size + padding) + 1, 1, math.Clamp(math.Remap(self.Erp_1, loading0, loading1, 0, size), 0, size) - 2, t - 2, self.BarColor)
		end

		if self.TextPos ~= 0 then
			local text = self:GetPercent() .. "%"

			if self.TextBackground then
				local len, h = surface.GetTextSize(text)
				draw.RoundedBox(4, self.TextPos == 1 and w / 2 - len / 2 - 2 or self.Erp_1 * w - len - 5 - 2, t / 2 - h / 2 - 1, len + 4, h + 2, self.TextBackgroundColor)
			end

			draw.SimpleText(text, nil, self.TextPos == 1 and w / 2 or self.Erp_1 * w - 5, t / 2 + 1, COLOR_WHITE, self.TextPos, 1)
		end
	end
end

gui.Register("ProgressBar", PANEL)