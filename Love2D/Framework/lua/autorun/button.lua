-- -- -- local scroll = vgui.Create("ScrollPanel")
-- -- -- scroll:SetSize(128, 256)
-- -- -- scroll:Center()
-- -- -- for I = 1, 10 do
-- -- -- 	local l = scroll:Add("Label")
-- -- -- 	l:SetPos(5, 50 * I)
-- -- -- 	l:SizeToContents()
-- -- -- 	l:SetMouseInputEnabled(false)
-- -- -- end

-- local P = gui.Create("Panel")
-- P:SetSize(300, 300)
-- P:Center()
-- P:SetName("Main")
-- GP = P

-- local One = P:Add("Panel")
-- function One:Paint(w, t)
-- 	draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0))
-- 	draw.RoundedBox(2, w / 2 - 10, t / 2 - 11, 20, 20, Color(0, 0, 0))
-- 	draw.SimpleText(self:GetZPos(), "Helvetica15", w / 2, t / 2, Color(255, 255, 255), 1, 1)
-- end

-- One:Dock(RIGHT)
-- One:SetName("R1")
-- local One = P:Add("Panel")

-- function One:Paint(w, t)
-- 	draw.RoundedBox(0, 0, 0, w, t, Color(255, 255, 0))
-- 	draw.RoundedBox(2, w / 2 - 10, t / 2 - 11, 20, 20, Color(0, 0, 0))
-- 	draw.SimpleText(self:GetZPos(), "Helvetica15", w / 2, t / 2, Color(255, 255, 255), 1, 1)
-- end

-- One:Dock(LEFT)
-- One:SetName("L2")

-- local One = P:Add("Panel")

-- function One:Paint(w, t)
-- 	draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 255))
-- 	draw.RoundedBox(2, w / 2 - 10, t / 2 - 11, 20, 20, Color(0, 0, 0))
-- 	draw.SimpleText(self:GetZPos(), "Helvetica15", w / 2, t / 2, Color(255, 255, 255), 1, 1)
-- end

-- One:Dock(BOTTOM)
-- One:SetName("B3")
-- local One = P:Add("Panel")

-- function One:Paint(w, t)
-- 	draw.RoundedBox(0, 0, 0, w, t, Color(25, 25, 200))
-- 	draw.RoundedBox(2, w / 2 - 10, t / 2 - 11, 20, 20, Color(0, 0, 0))
-- 	draw.SimpleText(self:GetZPos(), "Helvetica15", w / 2, t / 2, Color(255, 255, 255), 1, 1)
-- end

-- timer.Simple(5,function()
-- 	One:SetZPos(1)
-- end)

-- One:Dock(TOP)
-- One:SetName("T4")

-- local One = P:Add("Panel")

-- function One:Paint(w, t)
-- 	draw.RoundedBox(0, 0, 0, w, t, Color(0, 255, 0))
-- 	draw.RoundedBox(2, w / 2 - 10, t / 2 - 11, 20, 20, Color(0, 0, 0))
-- 	draw.SimpleText(self:GetZPos(), "Helvetica15", w / 2, t / 2, Color(255, 255, 255), 1, 1)
-- end

-- One:Dock(FILL)
-- One:SetName("F5")
