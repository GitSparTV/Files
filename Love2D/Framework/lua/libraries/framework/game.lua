game = {}
game.IsVisible = love.window.isVisible
game.SetSize = love.window.setMode
game.MakePopup = love.window.requestAttention
game.Hide = love.window.minimize
game.SetName = love.window.setTitle
game.GetName = love.window.getTitle
game.GetIcon = love.window.getIcon
game.SetIcon = love.window.setIcon
game.Capture = love.graphics.newScreenshot
game.OpenURL = love.system.openURL
game.SetClipboardText = love.system.setClipboardText
game.GetClipboardText = love.system.getClipboardText
game.ShowConsole = love._openConsole
game.GetScreenSize = love.window.getDesktopDimensions
game.GetOrientation = love.window.getDisplayOrientation
game.HasFocus = love.window.hasFocus
game.HasMouseFocus = love.window.hasMouseFocus
ScrW = love.graphics.getWidth
ScrH = love.graphics.getHeight
FPS = love.timer.getFPS
AveragePerformance = love.timer.getAverageDelta

function game.GetLoveVersion()
	local maj, min, r = love.getVersion()

	return maj .. "." .. min .. (r ~= 0 and "." .. r or "")
end

function game.Close()
	love.window.close()
	love.event.quit()
end

function game.Restart()
	print(string.rep("\n", 5))
	print(string.rep("-", 48))
	print(string.rep("-", 20) .. "RESTART" .. string.rep("-", 21))
	print(string.rep("-", 48))
	love.event.quit("restart")
	-- game.OpenURL("file://C:\\Program Files\\LOVE\\SparFramework.lnk")
	-- game.Close()
end

function game.IsLoaded()
	return love.init
end

MSG_INFO = "info"
MSG_WARNING = "warning"
MSG_ERROR = "error"
MSG_ESC = "escapebutton"
MSG_ENTER = "enterbutton"
game.Message = love.window.showMessageBox

function game.Query(title, message, ...)
	local buttons = {...}

	for k, v in pairs(buttons) do
		if v == "enterbutton" then
			buttons.enterbutton = k
			buttons[k] = nil
		end

		if v == "escapebutton" then
			buttons.escapebutton = k
			buttons[k] = nil
		end
	end

	return game.Message(title, message, buttons)
end