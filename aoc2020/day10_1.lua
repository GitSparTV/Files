io.output():setvbuf("no")
local input = [[
*truncated*
]]
local joltsmap = {}
local adapters = {}

local max = -1
for l in string.gmatch(input, "[^\n]+") do
	local adapter = tonumber(l)
	adapters[#adapters + 1] = adapter
	if adapter > max then
		max = adapter
	end
end

joltsmap[max + 3] = max + 3

for k, v in ipairs(adapters) do
	joltsmap[v] = v
end

local onediff, threediff = 0, 0
local jolts = 0

local function AddDiff(j, n)
	local diff = n - j

	if diff == 1 then
		onediff = onediff + 1
	elseif diff == 3 then
		threediff = threediff + 1
	end
end

while true do
	local next1, next2, next3 = joltsmap[jolts + 1], joltsmap[jolts + 2], joltsmap[jolts + 3]
	io.write("Jolt: ", jolts, " ", "Next: ", next1 or "nil", " ", next2 or "nil", " ", next3 or "nil", "\n")

	if next1 then
		AddDiff(jolts, next1)
		jolts = next1
	elseif next2 then
		AddDiff(jolts, next2)
		jolts = next2
	elseif next3 then
		AddDiff(jolts, next3)
		jolts = next3
	else
		io.write("no adapter for ", jolts, "\n")
		break
	end
end

io.write(onediff, " ", threediff, " ", onediff * threediff, "\n")
