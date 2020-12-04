local input = [[
*truncated*
]]
local map, len = {}, 0

for l in string.gmatch(input, "[^\n]+") do
	len = len + 1
	local row = {}
	map[len] = row
	local cpos = 0

	for c in string.gmatch(l, ".") do
		cpos = cpos + 1
		row[cpos] = c
	end
end

local function traverse(stepy, stepx)
	local x, y = 1, 1
	local trees = 0

	while x <= len do
		local v = map[x][y]
		if not v then
			for k = 1, len do
				local V = map[k]
				local L = #V

				for j = 1, L do
					V[#V + 1] = V[j]
				end
			end
			v = map[x][y]
		end
		assert(v)

		if v == "#" then
			trees = trees + 1
		end

		x, y = x + stepx, y + stepy
	end

	return trees
end



local a = traverse(1, 1)
local b = traverse(3, 1)
local c = traverse(5, 1)
local d = traverse(7, 1)
local e = traverse(1, 2)

print(a, b, c, d, e, a * b * c * d * e)
