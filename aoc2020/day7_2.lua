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
			b[#b + 1] = {tonumber(amount), color}
		end
	end
end

for k, v in pairs(bagreg) do
	for K, V in ipairs(v) do
		V[2] = bagreg[V[2]]
	end
end

local function RecursiveScan(t)
	local count = 0
	for k, v in ipairs(t) do
		count = count + v[1] * (RecursiveScan(v[2]) + 1)
	end

	return count
end

print(RecursiveScan(bagreg["shiny gold"]))
