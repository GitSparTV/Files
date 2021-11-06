w, t = 0, 0
local SysTime = love.timer.getTime
local GridW, GridT = 200, 200
local x, y = GridW / 2, GridT / 2
LEFT = 0
UP = 1
RIGHT = 2
DOWN = 3
local angle = UP
local rules = {}
-- love._openConsole()
local Done
PixelData = love.image.newImageData(GridW, GridT)
RT = love.graphics.newImage(PixelData)

function UpdateImage() RT:replacePixels(PixelData) end

function GridEmpty()
	PixelData:mapPixel(function(x, y, r, g, b, a) return 0, 0, 0, 0 end)
end

function love.load()
	w, t = love.window.getMode()
	w, t = math.floor(w / 2), math.floor(t / 2)
end

function Char4(r, g, b, a)
	return string.char(r, g, b, a)
end

function GenerateRules(t)
	for i = 1, #t do
		local rule = t[i]

		rules[Char4(rule.color.r, rule.color.g, rule.color.b, rule.color.a)] = {
			dir = rule.dir,
			next = (i == #t and t[1].color or t[i + 1].color)
		}
	end

	rules["first"] = Char4(t[1].color.r, t[1].color.g, t[1].color.b, t[1].color.a)
end

function Rule(r, g, b, dir)
	return {
		color = {
			r = r,
			g = g,
			b = b,
			a = 255
		},
		dir = dir
	}
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", w - GridW / 2 - 1, t - GridT / 2 - 1, GridW + 1, GridT + 1)
	love.graphics.draw(RT, w - GridW / 2, t - GridT / 2)
	local s = math.abs(math.sin(SysTime() * 5))
	love.graphics.setColor(s, s, s)
	love.graphics.points(w - GridW / 2 + 0.5 + x, t - GridT / 2 + 0.5 + y)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(Done and "Done" or "Generating...", w - GridW / 2, t - GridT / 2 - 30)
	love.graphics.print(love.timer.getFPS(), 100, 100)
end

function rotate(a)
	angle = (angle + (a == LEFT and -1 or 1)) % 4
end

function clamp(x, a, b)
	return math.max(math.min(x, b), a)
end

function CheckForEmpty()
	for i = 0, GridW - 1 do
		for I = 0, GridT - 1 do
			local r, g, b, a = PixelData:getPixel(i, I)
			if r == 0 and g == 0 and b == 0 and a == 0 then return true,i,I end
		end
	end

	return false
end

function RandomEmpty()
	if not CheckForEmpty() then return 0,0 end
	while true do
		local x, y = love.math.random(0, GridW - 1), love.math.random(0, GridT - 1)
		local r, g, b, a = PixelData:getPixel(x, y)
		if r == 0 and g == 0 and b == 0 and a == 0 then return x, y end
	end
end

function love.update(dt)
	if Done then return end
	local s = SysTime()

	while SysTime() - s < 0.015 do
		local r,g,b,a = PixelData:getPixel(x, y)
		local rule = rules[Char4(r * 255, g * 255, b * 255, a * 255)]

		if not rule then
			rule = rules[rules["first"]]
			-- goto cont
		end

		PixelData:setPixel(x, y, rule.next.r / 255, rule.next.g / 255, rule.next.b / 255, rule.next.a / 255)
		rotate(rule.dir)
		x, y = (angle == LEFT and -1 or (angle == RIGHT and 1 or 0)) + x, (angle == DOWN and -1 or (angle == UP and 1 or 0)) + y

		if x < 0 or y < 0 or x > GridW - 1 or y > GridT - 1 then
			x, y = RandomEmpty()
		end

		::cont::
	end

	if not CheckForEmpty() then
		Done = true

		return
	end
	UpdateImage()
end

function CreateRules()
	rules = {}
	local r = {}

	for i = 255, 0, -1 do
		r[#r + 1] = Rule(i,i,i, love.math.random(0, 1) == 1 and LEFT or RIGHT)
	end

	-- for i = 255, 0, -1 do
	-- 	r[#r + 1] = Rule(255 - i, i, 255 - i, math.random(0, 1) == 1 and LEFT or RIGHT)
	-- end

	GenerateRules(r)
end

CreateRules()

function math.Remap(value, inMin, inMax, outMin, outMax)
	return outMin + (((value - inMin) / (inMax - inMin)) * (outMax - outMin))
end

function love.textinput(t)
	if t == "R" then
		GridEmpty()
		UpdateImage()
		Done = false
		CreateRules()
	elseif t == "s" then
		x, y = RandomEmpty()
	elseif t == "m" then
		PixelData:mapPixel(function(x,y,r,g,b,a) r = math.Remap(r,0,255,50,150) return r,r,r,255 end)
		UpdateImage()
	end
end

------------------------
function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
		math.randomseed(os.time())
	end

	if love.load then
		xpcall(love.load, love.errhand)
	end

	if love.timer then
		love.timer.step()
	end

	local dt = 0

	while true do
		if love.event then
			love.event.pump()

			for name, a, b, c, d, e, f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then return function() return 0 end end
				end

				xpcall(love.handlers[name], love.errhand, a, b, c, d, e, f)
			end
		end

		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		if love.update then
			xpcall(love.update, love.errhand, dt)
		end

		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()

			if love.draw then
				xpcall(love.draw, love.errhand)
			end

			love.graphics.present()
		end

		if love.timer then
			love.timer.sleep(0.0001)
		end
	end
end
