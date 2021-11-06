local COLOR = {}
COLOR.__index = COLOR
debug.getregistry().Color = COLOR
COLOR.__type = "color"
COLOR.UseFFI = jit.status() -- FFI allows to safe RAM. 

if not COLOR.UseFFI then
	function Color(r, g, b, a)
		a = a or 255

		return setmetatable({
			r = math.Clamp(math.floor(tonumber(r)), 0, 255),
			g = math.Clamp(math.floor(tonumber(g)), 0, 255),
			b = math.Clamp(math.floor(tonumber(b)), 0, 255),
			a = math.Clamp(math.floor(tonumber(a)), 0, 255)
		}, COLOR)
	end

else
	ffi.cdef([[
	typedef struct Color {
		uint8_t r,g,b,a;
	} Color;]])
	
	local ColorMaker = ffi.metatype("Color",COLOR)

	function Color(r, g, b, a)
		return ColorMaker(r,g,b,a or 255)
	end
end

function COLOR:unpack()
	return self.r / 255, self.g / 255, self.b / 255, self.a / 255
end

function COLOR:__tostring()
	return self.r .. " " .. self.g .. " " .. self.b .. " " .. self.a
end

function COLOR:__add(s)
	if isnumber(s) then
		return Color(self.r + s, self.g + s, self.b + s, self.a)
	else
		return Color(self.r + s.r, self.g + s.g, self.b + s.b, self.a)
	end
end

function COLOR:__mul(s)
	if isnumber(s) then
		return Color(self.r * s, self.g * s, self.b * s, self.a)
	else
		return Color(self.r * s.r, self.g * s.g, self.b * s.b, self.a)
	end
end

function COLOR:SetAlpha(alpha)
	return Color(self.r,self.g,self.b,alpha)
end

function iscolor(any)
	return type(any) == "color"
end

COLOR_WHITE = Color(255,255,255)
COLOR_AWHITE = Color(255,255,255,0)
COLOR_BLACK = Color(0,0,0)
COLOR_ABLACK = Color(0,0,0,0)
COLOR_LIGHTGRAY = Color(200,200,200)
COLOR_GRAY = Color(150,150,150)
COLOR_DARKGRAY = Color(100,100,100)
COLOR_RED = Color(255,0,0)
COLOR_GREEN = Color(0,255,0)
COLOR_BLUE = Color(0,0,255)
COLOR_YELLOW = Color(255,255,0)
COLOR_PURPLE = Color(255,0,255)
COLOR_CYAN = Color(0,255,255)