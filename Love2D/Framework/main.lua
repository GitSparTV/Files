ConsoleLog = ""
IOprint = IOprint or print
EMPTYFUNCTION = function() end

if love.system.getOS() == "Windows" then
	love._openConsole()
end

love.filesystem.setRequirePath("lua/?.lua;bin/?.lua;?.lua")
love.filesystem.setCRequirePath("bin/?.dll;bin/?.so;?.dll;?.so")

-- function print(...)
-- 	local t = ""
-- 	local args = {...}
-- 	for I = 1, select("#", ...) do
-- 		v = tostring(args[I])
-- 		if I == 1 then
-- 			t = v:gsub("\t", "    ")
-- 		else
-- 			t = t .. "    " .. v:gsub("\t", "    ")
-- 		end
-- 	end
-- 	ConsoleLog = ConsoleLog .. t .. "\n"
-- 	if Console and Console:IsInitCalled() then
-- 		local count = 0
-- 		local trunlog = ""
-- 		for k in string.gmatch(ConsoleLog:reverse(), ".") do
-- 			if k == "\n" then
-- 				count = count + 1
-- 				if count > 200 then break end
-- 			end
-- 			trunlog = trunlog .. k
-- 		end
-- 		ConsoleLog = trunlog:reverse()
-- 		Console.Screen.Text:SetText(ConsoleLog)
-- 		Console.Screen.Text:SizeToContents()
-- 		if Console.Screen.ScrollBar:GetScroll() + 1 >= Console.Screen.ScrollBar.CanvasSize * 0.95 then
-- 			Console.Screen:Rebuild()
-- 			Console.Screen.ScrollBar:SetScroll(Console.Screen.Text:GetTall())
-- 		end
-- 	end
-- 	io.print(...)
-- end
function io.print(...)
	return print(...)
end

function LoadDir(dir)
	for k, v in pairs(love.filesystem.getDirectoryItems("lua/" .. dir)) do
		if not v:match("%.lua$") then
			goto cont
		end

		v = string.gsub(v, "%.lua", "")
		require(dir:gsub("/", ".") .. "." .. v)
		::cont::
	end

	print("\"" .. dir .. "/\" loaded")
end

function MakeFonts()
	local sizes = {10, 13, 15, 20, 25}

	for k, v in pairs(love.filesystem.getDirectoryItems("resources/fonts/")) do
		if not v:match("%.ttf$") then
			goto cont
		end

		local s = v:sub(1, -5)
		local fs = v:sub(1, 1):upper()
		s = fs .. s:sub(2, -1)

		for I = 1, #sizes do
			surface.CreateFont(s .. sizes[I], {
				font = "resources/fonts/" .. v,
				size = sizes[I]
			})
		end

		print("Font \"" .. s .. "\"")
		::cont::
	end

	surface.DefaultFont = "Helvetica15"
	print("Fonts created")
end

local UseCursorSystem = pcall(love.mouse.getSystemCursor, "arrow")

function MakeCursors()
	input.UseCursorSystem = UseCursorSystem

	if UseCursorSystem then
		local cursors = {"arrow", "ibeam", "wait", "waitarrow", "crosshair", "sizenwse", "sizenesw", "sizewe", "sizens", "sizeall", "no", "hand"}

		for k, v in pairs(cursors) do
			input.AddSystemCursor(v)
		end
	else
		local cursors = {{"arrow", 0, 0}, {"ibeam", 2, 8}, {"wait", 6, 10}, {"waitarrow", 0, 0}, {"crosshair", 11, 11}, {"sizenwse", 7, 7}, {"sizenesw", 8, 7}, {"sizewe", 10, 4}, {"sizens", 4, 10}, {"sizeall", 10, 10}, {"no", 9, 9}, {"hand", 5, 1}}

		for k, v in pairs(cursors) do
			input.AddImageCursor(v[1], v[2], v[3])
		end

		input.HideSystemCursor()
	end

	print("Cursors created")
	input.SetCursor("arrow")
end

function love.load()
	utf8 = require("utf8")
	ffi = require("ffi")
	love.graphics.setDefaultFilter("nearest", "nearest", 0)
	LoadDir("libraries/extensions")
	LoadDir("libraries/framework")
	LoadDir("libraries/modules")
	MakeFonts()

	if love.mouse.isCursorSupported() then
		MakeCursors()
	end

	LoadDir("gui/base")
	LoadDir("gui")
	LoadDir("autorun")
	hook.Run("PostInit")
	love.init = true
	--
	print("LOVE " .. game.GetLoveVersion() .. " | SparFramework is fully loaded")
	love.keyboard.setKeyRepeat(true)
	surface.SetBackgroundColor(Color(30, 30, 30))

	timer.Simple(0.5, function()
		if input.IsKeyDown("q") then
			game.ShowConsole()
			io.write(ConsoleLog)
		end
	end)

	-- timer.Simple(7,function()
	-- 	local t = 0
	-- 	for k,v in ipairs(gui.GetPanelsTree()) do
	-- 		if v.Think ~= EMPTYFUNCTION then print(v,topf(v.ThinkTime or 0)) end
	-- 		t = t + (v.ThinkTime or 0)
	-- 	end
	-- 	print("Total: "..topf(t))
	-- end)
	ffi.cdef([[
typedef long LONG_PTR;
typedef LONG_PTR LRESULT;
typedef void *PVOID;
typedef PVOID HANDLE;
typedef HANDLE HWND;
typedef unsigned int UINT;
typedef unsigned int UINT_PTR;
typedef UINT_PTR WPARAM;
typedef LONG_PTR LPARAM;
LRESULT DefWindowProcA(
  HWND   hWnd,
  UINT   Msg,
  WPARAM wParam,
  LPARAM lParam
);
	]])

	-- ffi.DefWindowProcA
end

function love.draw()
	if not game.IsLoaded() then return end
	surface.SetDrawColor(1, 1, 1, 1)
	hook.Run("HUDPaint")
	hook.Run("GUIPaint")
	hook.Run("PostPaint")
	surface.SetFont("Helvetica15")
	draw.SimpleText(FPS() .. " | " .. math.floor(collectgarbage("count")) .. " | " .. topf(love.MaxTick) .. " | " .. topf(love.MinTick) .. " | " .. topf(love.LastTick), surface.DefaultFont, 10, 10, COLOR_WHITE)
	draw.SimpleText("Think took: " .. topf(love.ThinkBench or 0), surface.DefaultFont, 10, 50, COLOR_WHITE)
	draw.SimpleText(string.format("Average frame time: %.3f s", AveragePerformance()), surface.DefaultFont, 10, 30, COLOR_WHITE)
	draw.SimpleText(string.format("SafeArea: %d %d %d %d %d %d", ScrW(),ScrH(),love.window.getSafeArea()), surface.DefaultFont, 10, 70, COLOR_WHITE)

	-- local pt = gui.GetPanelsTree()
	-- local C = 0
	-- for i=1, #pt do
	-- 	local p = pt[i]
	-- 	-- if p ~= EX.parent then goto cont end
	-- 	local a,b,c,d = p:GetScreenBounds()
	-- 	-- if a == 0 then goto cont end
	-- 	local s = math.abs(math.sin(SysTime()))*100
	-- 	C = C + 1
	-- 	surface.SetDrawColor(Color(C*25,255,0,s))
	-- 	surface.DrawRect(a,b,c,d)
	-- 	draw.SimpleText(string.format("%s: %d %d %d %d",p:GetName(),a,b,c,d),"Helvetica15",1000,100 + C*20,Color(255,255,255))
	-- 	::cont::
	-- end
	if not input.UseCursorSystem and input.CurrentCursorImage or not input.DrawCursor then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(input.CurrentCursorImage[1], input.DrawCursorX - input.CurrentCursorImage[2], input.DrawCursorY - input.CurrentCursorImage[3])
	end
end

function love.update(tick)
	love.CurTime = (love.CurTime or 0) + tick
	love.MaxTick = math.max(love.MaxTick or 0, tick - _ClockSpeed)
	love.MinTick = math.min(love.MinTick or math.huge, tick - _ClockSpeed)
	love.LastTick = tick
	hook.Run("Think", tick)
	-- game.SetName("SPAR [FPS:" .. FPS() .. "]")
end

function love.mousepressed(x, y, button, istouch, presses)
	if input.Listening then return input.ListenThink("mousepressed", x, y, button, istouch, presses) end
	hook.Run("MousePressed", x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	hook.Run("MouseReleased", x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch, presses)
	input.DrawCursorX, input.DrawCursorY = x, y
	hook.Run("MouseMoved", x, y, dx, dy, istouch, presses)
end

function love.wheelmoved(_, delta)
	hook.Run("MouseWheeled", delta)
end

function love.textinput(text)
	if text == "D" then
		debug.debug()
	end

	if text == "R" then
		game.Restart()
	end

	hook.Run("TextInput", text)
end

function love.keypressed(key, scancode, isrepeat)
	if input.Listening then return input.ListenThink("keypressed", key, scancode, isrepeat) end
	hook.Run("KeyPress", key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
	hook.Run("KeyRelease", key, scancode)
end

function love.focus(focus)
	hook.Run("WindowFocus", focus)
end

function love.mousefocus(focus)
	hook.Run("WindowMouseFocus", focus)
end

function love.visible(state)
	hook.Run("WindowVisible", state)
end

function love.resize(w, t)
	hook.Run("WindowResize", w, t)
end

DISPORIENT_UNKNOWN = "unknown"
DISPORIENT_LANDSCAPE = "landscape"
DISPORIENT_LANDSCAPEFLIPPED = "landscapeflipped"
DISPORIENT_PORTRAIT = "portrait"
DISPORIENT_PORTRAITFLIPPED = "portraitflipped"

function love.displayrotated(displayindex, orientation)
	hook.Run("DisplayRotated", displayindex, orientation)
end

function love.directorydropped(path)
	hook.Run("FolderDrop", path)
end

function love.filedropped(file)
	hook.Run("FileDrop", file)
end

-- function love.errhand(msg)
-- 	msg = FormatError and FormatError(msg, 1) or msg
-- 	if not game or not Console or not Console:IsInitCalled() then
-- 		love.window.close()
-- 		love.event.quit()
-- 		love.window.showMessageBox("Lua Error", msg, "error")
-- 		return
-- 	end
-- 	print(msg)
	-- game.Message("Lua Error",msg, MSG_ERROR)
-- end
_ClockSpeed = 0.01

function love.quit()
	return true
end

function love.run()
	love.math.setRandomSeed(os.time())
	math.randomseed(love.math.random(2 ^ 32))
	local TS, TE = 0, 0
	TS = love.timer.getTime()
	xpcall(love.load, love.errhand)
	TE = love.timer.getTime()
	print("Took " .. string.format("%.4f", love.timer.step()) .. " to boot LOVE. Load took: " .. string.format("%.4f", TE - TS))
	local exitcode = 0
	local EMPTYFUNCTION = EMPTYFUNCTION

	local function exitfunc()
		return exitcode
	end

	while true do
		love.event.pump()

		for name, a, b, c, d, e, f in love.event.poll() do
			if name == "quit" and love.quit() then
				exitcode = a or 0

				return exitfunc
			end

			xpcall(love[name] or EMPTYFUNCTION, love.errhand, a, b, c, d, e, f)
		end

		TS = SysTime()
		xpcall(love.update, love.errhand, love.timer.step())
		TE = SysTime()
		love.ThinkBench = TE - TS

		if love.graphics.isActive() then
			-- DrawCounter = (DrawCounter + 1) % IgnoreDraws
			-- if DrawCounter == 0 then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			xpcall(love.draw, love.errhand)
			love.graphics.present()
			-- end
		end

		if love.ThinkBench < _ClockSpeed then love.timer.sleep(_ClockSpeed) end
	end
end