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

local mul = len * 3 / #map[1]
print(mul)

for k = 1, len do
	local v = map[k]
	local L = #v

	for _ = 1, mul do
		for j = 1, L do
			v[#v + 1] = v[j]
		end
	end
end

local x, y = 1, 1
local trees = 0

while x <= len do
	assert(map[x][y])
	if map[x][y] == "#" then
		trees = trees + 1
	end

	x, y = x + 1, y + 3
end

print("trees", trees)
