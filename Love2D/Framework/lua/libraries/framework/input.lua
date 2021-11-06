input = {}
input.CursorsLibrary = {}
input.MouseX = love.mouse.getX
input.MouseY = love.mouse.getY
input.GetCursorPos = love.mouse.getPosition
input.IsKeyDown = love.keyboard.isDown
input.SetMouseX = love.mouse.setX
input.SetMouseY = love.mouse.setY
input.SetCursorPos = love.mouse.setPosition
input.GetKeyName = love.keyboard.getKeyFromScancode
input.CurrentCursor = "arrow"
input.DrawCursor = true
input.DrawCursorX = 0
input.DrawCursorY = 0
MOUSE_LEFT = 1
MOUSE_RIGHT = 2
MOUSE_MIDDLE = 3

function input.SetCursor(name)
	local cur = input.CursorsLibrary[name]
	if not cur or input.CurrentCursorImage == cur then return end
	input.CurrentCursor = name
	if input.UseCursorSystem then love.mouse.setCursor(cur) else input.CurrentCursorImage = cur end
end

function input.AddSystemCursor(name)
	input.CursorsLibrary[name] = love.mouse.getSystemCursor(name)
end

function input.AddImageCursor(name,ox,oy)
	input.CursorsLibrary[name] = {love.graphics.newImage("resources/cursors/" .. name .. ".png"),ox,oy}
end

function input.NameToType(name)
	if name:sub(1, -2) == "MOUSE" then
		return true, name:sub(-1, -1)
	else
		return false, name
	end
end

function input.HideSystemCursor() return love.mouse.setVisible(false) end
function input.ShowSystemCursor() return love.mouse.setVisible(true) end
function input.HideCursor() if input.UseCursorSystem then input.HideSystemCursor() else input.DrawCursor = false end end
function input.ShowCursor() if input.UseCursorSystem then input.ShowSystemCursor() else input.DrawCursor = true end end

function input.Listen()
	input.Listening = true
	input.Listened = nil
end

function input.ListenThink(event, ...)
	if event == "mousepressed" then
		local _, _, button = ...
		input.Listened = "MOUSE" .. button
		input.Listening = false
	elseif event == "keypressed" then
		local _, scancode, isrepeat = ...
		if isrepeat then return end
		input.Listened = scancode
		input.Listening = false
	end
end

function input.GetListenedKey()
	return input.Listened
end