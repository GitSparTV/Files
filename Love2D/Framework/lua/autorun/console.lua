--[[ Console = vgui.Create("Frame")
Console.Screen = Console:Add("ScrollPanel")
Console:SetSize(800, 800)
Console:SetPos(ScrW() / 2, 0)
-- Console.Screen:SetSize(400, 400)
Console.Screen:Dock(FILL)
Console.Input = Console:Add("Panel")
Console.Input:Dock(BOTTOM)
Console.Input:SetName("INPUT")
Console.Input:DockMargin(0, 5, 0, 0)
Console.Input.Entry = Console.Input:Add("TextEntry")
Console.Input.Entry:Dock(FILL)
Console.Input.Entry:SetDoneOnEnter(false)

function Console.Input.Entry:OnEnter()
	self:AddHistory()
	TraceSKIP = 6
	RunString(self:GetText(), "ConsoleLua")
	TraceSKIP = 0
	self:SetText("")
end

Console.Screen.Text = Console.Screen:Add("Label")
Console.Screen.Text:SetName(t)
Console.Screen.Text:SetFont("Consolas13")
Console.Screen.Text:SetWrap(true)
Console.Screen.Text:SetWrapWide(800)
Console.Screen.Text:SetColor(Color(255, 255, 255))

function ClearChat()
	Console.Screen:SetText("")
	ConsoleLog = ""
end

-- rerror = rerror or error
-- function error(a)
-- 	a = a or ""
-- 	print(FormatError(debug.getinfo(2, "S").short_src .. ":" .. debug.getinfo(2, "l").currentline .. ": " .. a))
-- end
timer.Create("GC", 0.5, 0, function()
	GC = collectgarbage("count")
end)

timerF = vgui.Create("Frame")
timerF:SetSize(400, 600)
timerF.Screen = timerF:Add("ScrollPanel")
timerF.Screen:Dock(FILL)
local timers = timerF.Screen:Add("Label")

function timers:Think()
	local S = ""
	-- for k, v in ipairs(timer.timers) do
	-- S = S .. string.format("#%d: %.2f/%.2f [%d times] [simple: %s]\n", k, CurTime() - v.startTime, v.time, v.times or 0, tostring(v.simple))
	-- end
	-- S = S .. "Hover: " .. tostring(vgui.GetHoveredPanel())
	-- S = S .. "\nGC: " .. tostring(math.floor(GC or 0)) .. "\n\n"
	-- for k, v in ipairs(vgui.GetPanels()) do
	-- 	if v:IsVisible() then S = S .. tostring(v) .. "\n" end
	-- end
	-- for k, v in pairs(W.ForceTypes or {}) do
		-- S = S .. k .. " = " .. tostring(W.GetWheelForceType(1, v)) .. "\n"
	-- end

	-- for i=1,128 do
	-- S = S .. i .. " = " .. tostring(W.IsButtonTriggered(1,i)) .. "\n"
	-- end
	timers:SetText(S)
	timers:SizeToContents()
end

timers:SetColor(Color(255, 255, 255))
-- timers:SetPos(400, 400)
timers:SetWrap(true)
-- timers:Dock(FILL)
timers:SetWrap(400)
timers:SetFont("Consolas13")
-- SS = vgui.Create("ScrollPanel")
-- SS:SetSize(300, 300)
-- SS:SetPos(0, 0)
-- for I = 1, 100 do
-- 	local a = SS:Add("Panel")
-- 	a:Dock(TOP)
-- 	a:SetSize(10, 50)
-- 	a:SetMouseInputEnabled(true)
-- 	a:SetName("Panel "..#SS.ViewPort:GetChildren())
-- 	function SCROLL()
-- 		Console.Screen.ScrollBar:_SetScroll(Console.Screen.ScrollBar.CanvasSize)
-- 	end
-- end
--]] 