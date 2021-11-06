surface = {}
draw = {}
render = {}
surface.Fonts = {}
surface.TextObjects = {}
surface.MaterialLibrary = {}
surface.DrawLine = love.graphics.line
surface.DrawPoly = love.graphics.polygon
surface.DrawCircle = love.graphics.circle
surface.DrawArc = love.graphics.arc
render.Clear = love.graphics.clear
render.Erase = love.graphics.discard
render.Reset = love.graphics.reset
render.GetRenderTarget = love.graphics.getCanvas
render.SetRenderTarget = love.graphics.setCanvas
render.SetScissorRect = love.graphics.setScissor
render.PushRenderTarget = love.graphics.push
render.PopRenderTarget = love.graphics.pop
render.Rotate = love.graphics.rotate
render.Scale = love.graphics.scale
render.Shear = love.graphics.shear
render.Translate = love.graphics.translate
render.SetIScissorRect = love.graphics.intersectScissor
render.GetScissorRect = love.graphics.getScissor
render.SetDebugMode = love.graphics.setWireframe
DRAW_FILL = "fill"
DRAW_LINE = "line"
RT_PUSH_ALL = "all"
RT_PUSH_TRANSFORM = "transform"
local LastFont, LastMaterial
local f = math.floor

function Floor4(x, y, w, t)
	return f(x or 0), f(y or 0), f(w or 0), f(t or 0)
end

function Floor2(x, y)
	return f(x or 0), f(y or 0)
end

function surface.CreateFont(font, fontdata)
	local fontpath = fontdata.font
	local size = fontdata.size

	if not fontpath then
		error("No font path")
	end

	if not size then
		error("No font size")
	end

	surface.Fonts[font] = love.graphics.newFont(fontpath, size)
	surface.TextObjects[surface.Fonts[font]] = love.graphics.newText(surface.Fonts[font])
end

function surface.SetFont(fontname)
	fontname = fontname or surface.DefaultFont
	if surface.Fonts[fontname] == love.graphics.getFont() then return end
	LastFont = surface.Fonts[fontname]
	love.graphics.setFont(surface.Fonts[fontname])
end

function surface.GetTextObject(font)
	if isstring(font) then
		return surface.TextObjects[surface.Fonts[font]]
	else
		return surface.TextObjects[font]
	end
end

function surface.SetBackgroundColor(r, g, b, a)
	if iscolor(r) then
		love.graphics.setBackgroundColor(r:unpack())
	else
		love.graphics.setBackgroundColor(r / 255, g / 255, b / 255, a / 255)
	end
end

function surface.GetFont()
	return LastFont
end

function surface.GetTextSize(text, font, maxwide, line)
	if isstring(font) then
		font = surface.Fonts[font]
	else
		font = surface.GetFont()
	end

	local T = surface.GetTextObject(font)
	if not T then return 0, 0 end

	if maxwide then
		T:setf(text, maxwide, "left")

		return font:getWrap(text, maxwide), T:getHeight(line)
	end

	T:set(text)
	-- local w,t = T:getDimensions()
	-- return T:getWidth(),T:getHeight() -- + font:getDescent()

	return T:getWidth(), font:getBaseline()
end

function surface.SetDrawColor(r, g, b, a)
	if iscolor(r) then
		love.graphics.setColor(r:unpack())
	else
		love.graphics.setColor(r / 255, g / 255, b / 255, (a or 255) / 255)
	end
end

function surface.DrawRect(x, y, w, t)
	love.graphics.rectangle(DRAW_FILL, x, y, w, t)
end

function surface.DrawOutlinedRect(x, y, w, t)
	love.graphics.rectangle(DRAW_LINE, x - 0.5, y - 0.5, w + 1, t + 1)
end

function draw.DrawBox(x, y, w, t, color)
	if w <= 0 or t <= 0 then return end
	x, y, w, t = Floor4(x, y, w, t)
	surface.SetDrawColor(color)
	surface.DrawRect(x, y, w, t)
end

function draw.OutlinedBox(x, y, w, t, color, size)
	if w <= 0 or t <= 0 then return end
	x, y, w, t = Floor4(x, y, w, t)
	surface.SetDrawColor(color)
	love.graphics.setLineWidth(size or 1)
	surface.DrawOutlinedRect(x, y, w, t)
end

function draw.RoundedBox(round, x, y, w, t, color)
	draw.RoundedBoxEx(round, x, y, w, t, color, true, true, true, true)
end

function draw.RoundedBoxEx(round, x, y, w, t, color, top_left, top_right, btm_left, btm_right)
	top_left = top_left or false
	top_right = top_right or false
	btm_left = btm_left or false
	btm_right = btm_right or false
	if w <= 0 or t <= 0 then return end
	x, y, w, t = Floor4(x, y, w, t)

	if round <= 0 or (not top_left and not top_right and not btm_left and not btm_right) then
		surface.SetDrawColor(color)
		surface.DrawRect(x, y, w, t)

		return
	end

	local points, precision, hP = {}, (round + round), 0.5 * math.pi

	if round > 0.5 * w then
		round = 0.5 * w
	end

	if round > 0.5 * t then
		round = 0.5 * t
	end

	local X1, Y1, X2, Y2 = x + round, y + round, x + w - round, y + t - round

	if top_right then
		-- the four rounded corners
		for i = 0, precision do
			local a = (i / precision - 1) * hP
			points[#points + 1] = X2 + round * math.cos(a)
			points[#points + 1] = Y1 + round * math.sin(a)
		end
	else
		points[#points + 1] = x + w
		points[#points + 1] = y
	end

	if btm_right then
		for i = 0, precision do
			local a = (i / precision) * hP
			points[#points + 1] = X2 + round * math.cos(a)
			points[#points + 1] = Y2 + round * math.sin(a)
		end
	else
		points[#points + 1] = x + w
		points[#points + 1] = y + t
	end

	if btm_left then
		for i = 0, precision do
			local a = (i / precision + 1) * hP
			points[#points + 1] = X1 + round * math.cos(a)
			points[#points + 1] = Y2 + round * math.sin(a)
		end
	else
		points[#points + 1] = x
		points[#points + 1] = y + t
	end

	if top_left then
		for i = 0, precision do
			local a = (i / precision + 2) * hP
			points[#points + 1] = X1 + round * math.cos(a)
			points[#points + 1] = Y1 + round * math.sin(a)
		end
	else
		points[#points + 1] = x
		points[#points + 1] = y
	end

	surface.SetDrawColor(color)
	love.graphics.setLineWidth(3)
	love.graphics.polygon(DRAW_FILL, points)
	love.graphics.setLineWidth(1)
end

TALIGN_LEFT = 0
TALIGN_CENTER = 1
TALIGN_RIGHT = 2
TALIGN_TOP = 3
TALIGN_BOTTOM = 4

function draw.SimpleText(text, font, x, y, color, xAlign, yAlign)
	text = tostring(text)
	font = font or surface.DefaultFont
	x, y = Floor2(x, y)
	xAlign = xAlign or TALIGN_LEFT
	yAlign = yAlign or TALIGN_TOP
	surface.SetFont(font)
	surface.SetDrawColor(color)
	local len, h = surface.GetTextSize(text, LastFont)

	if xAlign == TALIGN_CENTER then
		x = x - div2f(len)
	elseif xAlign == TALIGN_RIGHT then
		x = x - len
	end

	if yAlign == TALIGN_CENTER then
		y = y - div2f(h)
	elseif yAlign == TALIGN_BOTTOM then
		y = y - h
	end

	love.graphics.print(text, math.floor(x), math.floor(y))

	return len, h
end

function draw.DrawText(text, maxwide, font, x, y, color, xAlign, yAlign)
	text = tostring(text)
	font = font or surface.DefaultFont
	x, y = Floor2(x, y)
	xAlign = xAlign or TALIGN_LEFT
	yAlign = yAlign or TALIGN_TOP
	surface.SetFont(font)
	surface.SetDrawColor(color)
	local len, h = surface.GetTextSize(text, LastFont, maxwide)

	if xAlign == TALIGN_CENTER then
		x = x - div2f(len)
	elseif xAlign == TALIGN_RIGHT then
		x = x - len
	end

	if yAlign == TALIGN_CENTER then
		y = y - div2f(h)
	elseif yAlign == TALIGN_BOTTOM then
		y = y - h
	end

	-- width, t = LastFont:getWrap(text, maxwide)
	local T = surface.GetTextObject(font)

	if maxwide then
		T:setf(text, maxwide, "left")
	else
		T:set(text)
	end

	love.graphics.draw(T, math.floor(x), math.floor(y))
end

function draw.DrawCircle(x, y, radius, color, segments)
	x, y = Floor2(x, y)
	surface.SetDrawColor(color)
	surface.DrawCircle(DRAW_FILL, x, y, radius, segments)
end

function draw.DrawArc(x, y, radius, ang1, ang2, color, segments)
	x, y = Floor2(x, y)
	surface.SetDrawColor(color)
	surface.DrawArc(DRAW_FILL, x, y, radius, ang1, ang2, segments)
end

function draw.DrawRectRotated(x, y, w, t, color, angle, anchorx, anchory)
	if not angle or angle % (math.pi * 2) == 0 then return draw.DrawBox(x, y, w, t, color) end
	x, y, w, t = Floor4(x, y, w, t)
	render.PushRenderTarget()
	love.graphics.translate(x + (anchorx or 0), y + (anchory or 0))
	love.graphics.rotate(angle)
	love.graphics.translate(-x + (anchorx and -anchorx or 0), -y + (anchory and -anchory or 0))
	draw.DrawBox(x, y, w, t, color)
	render.PopRenderTarget()
end

local lastscissors = {}

function DisableClipping(bool)
	if bool then
		lastscissors = {love.graphics.getScissor()}
		love.graphics.setScissor()
	else
		if lastscissors == {} then return end
		love.graphics.setScissor(unpack(lastscissors))
	end
end

function surface.AddMaterial(name)
	local path = "materials/" .. name
	if not file.IsFile(path) then return name end
	surface.MaterialLibrary[name] = love.graphics.newImage(path)
end

function Material(name)
	if not name then return end

	if not surface.MaterialLibrary[name] then
		surface.AddMaterial(name)
	end

	return name
end

surface.AddMaterial("missingmaterials.png")

function surface.SetMaterial(name)
	if not name or not surface.MaterialLibrary[name] then
		LastMaterial = surface.MaterialLibrary["missingmaterials.png"]

		return LastMaterial
	end

	LastMaterial = surface.MaterialLibrary[name]

	return LastMaterial
end

function surface.SetTextureFilter(name, mode, aniso)
	if not surface.MaterialLibrary[name] then return end
	surface.MaterialLibrary[name]:setFilter(mode, mode, aniso or 1)
end

TEXFILTER_LINEAR = "linear"
TEXFILTER_NEAREST = "nearest"
WRAP_CLAMP = "clamp"
WRAP_REPEAT = "repeat"
WRAP_MIRROREDREPEAT = "mirroredrepeat"
WRAP_CLAMPZERO = "clampzero"
local TexQuad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)

function surface.DrawTexturedRect(x, y, w, t, mode)
	if not LastMaterial then return surface.DrawRect(x, y, w, t) end
	x, y, w, t = Floor4(x, y, w, t)
	local matw, matt = LastMaterial:getDimensions()

	if (w == 0 and t == 0) or (w ~= matw or t ~= matt) then
		if mode and isstring(mode) then
			LastMaterial:setWrap(mode, mode)
			TexQuad:setViewport(x, y, w, t, LastMaterial:getDimensions())
			love.graphics.draw(LastMaterial, TexQuad, x, y)
			LastMaterial:setWrap("clamp", "clamp")
		else
			if mode then
				LastMaterial:setFilter(TEXFILTER_NEAREST, TEXFILTER_NEAREST, 0)
			end

			love.graphics.draw(LastMaterial, x, y, 0, math.Remap(w, 0, matw, 0, 1), math.Remap(t, 0, matt, 0, 1))

			if mode then
				LastMaterial:setFilter(TEXFILTER_LINEAR, TEXFILTER_LINEAR, 0)
			end
		end
	else
		love.graphics.draw(LastMaterial, x, y)
	end
end