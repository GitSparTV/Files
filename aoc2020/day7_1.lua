local input = [[
*truncated*
]]
local bagreg = {}

for l in string.gmatch(input, "[^\n]+") do
	local bag, contains = string.match(l, "^(.-)%s*bags contain%s*(.-).$")
	local b = {}
	bagreg[bag] = b

	if contains ~= "no other bags" then
		for amount, color in string.gmatch(contains, "%s*(%d+)%s*(.-)%s*bags?,?") do
			b[#b + 1] = color
		end
	end
end

for k, v in pairs(bagreg) do
	for K, V in ipairs(v) do
		v[K] = bagreg[V]
	end
end

local key = bagreg["shiny gold"]
local cache, total = {}, 0

local function RecursiveScan(t, root)
	local count = 0

	for k, v in ipairs(t) do
		if v == key then
			count = 1
			break
		end

		if RecursiveScan(v, false) == 1 then
			count = 1
			break
		end
	end

	if root then
		total = total + count
	end

	return count
end

for k, v in pairs(bagreg) do
	RecursiveScan(v, true)
end

p(total)
