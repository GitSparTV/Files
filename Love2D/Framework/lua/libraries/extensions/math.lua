if love.math then
	math.noise = love.math.noise
	math.Random = love.math.random
	math.NormalColor = love.math.colorFromBytes
	math.ColorFromNormal = love.math.colorToBytes
end
setfenv(1,math)

function Remap(value, inMin, inMax, outMin, outMax)
	return outMin + (((value - inMin) / (inMax - inMin)) * (outMax - outMin))
end

function Clamp(_in, low, high)
	return min(max(_in, low), high)
end

function sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

function square(n)
	return sign(sin(n))
end

function isnan(n)
	return n ~= n
end

function Round(num, idp)
	local mult = 10 ^ (idp or 0)

	return floor(num * mult + 0.5) / mult
end

function ifloor(n)
	return sign(n) * ceil(abs(n))
end