local PANEL = {}
AccessorFunc(PANEL, "DoneOnEnter", "DoneOnEnter")

function PANEL:Init()
	self:SetText("")
	self:SetFont("Consolas13")
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	self.History = {}
	self.HistoryScroller = -1
	self:SetDoneOnEnter(true)
	self:SetCursor("hand")
end

function PANEL:OnMousePressed()
	self.Active = true
end

function PANEL:OnFocusChanged()
	self.Active = false
end

function PANEL:OnTextChanged()
end

function PANEL:AddHistory()
	for k, v in ipairs(self.History) do
		if v == self:GetText() then
			table.remove(self.History, k)
			break
		end
	end

	table.insert(self.History, self:GetText())
end

function PANEL:AppendText(text)
	self:SetText(self:GetText() .. tostring(text))
end

function PANEL:OnKeyCodePressed(code)
	if not self.Active then return end

	if code == "return" then
		self:OnEnter()

		if self.DoneOnEnter then
			self.Active = false
		end
	elseif code == "escape" then
		self.Active = false
	elseif code == "backspace" then
		local t = self:GetText()
		local byteoffset = utf8.offset(t, -1)

		if byteoffset then
			self:SetText(t:sub(1, byteoffset - 1))
		end
	elseif code == "up" then
		if #self.History == 0 then return end
		self.HistoryScroller = math.Clamp(self.HistoryScroller + 1, 0, #self.History - 1)
		self:SetText(self.History[#self.History - self.HistoryScroller])
	elseif code == "down" then
		self.HistoryScroller = math.Clamp(self.HistoryScroller - 1, -1, #self.History - 1)
		self:SetText(self.HistoryScroller == -1 and "" or self.History[#self.History - self.HistoryScroller])
	end

	if input.IsKeyDown("lctrl", "rctrl") then
		if code == "c" then
			game.SetClipboardText(self:GetText())
		elseif code == "v" then
			self:AppendText(game.GetClipboardText())
		elseif code == "x" then
			game.SetClipboardText(self:GetText())
			self:SetText("")
		elseif code == "r" then
			game.Restart()
		end
	end
end

function PANEL:OnKeyCodeTyped(code)
	self:AppendText(code)
end

function PANEL:OnEnter()
end

function PANEL:Paint(w, t)
	draw.RoundedBox(0, 0, 0, w, t, Color(0, 0, 0))
	draw.RoundedBox(0, 1, 1, w - 2, t - 2, Color(150, 150, 150))
	draw.RoundedBox(0, 2, 2, w - 4, t - 4, Color(200, 200, 200))
	draw.RoundedBox(0, 3, 3, w - 6, t - 6, Color(255, 255, 255))
	draw.SimpleText(self.text, self.font, 5, t / 2 - self.textH / 2, Color(20, 20, 20), 0, 0)

	if self.Active then
		draw.RoundedBox(0, 5 + self.textLen, t / 2 - self.fontlnH / 2, 1, self.fontlnH, Color(0, 0, 0, math.abs(math.sin(CurTime() * 3)) * 255))
	end
end

vgui.Register("TextEntry", PANEL, "Label")