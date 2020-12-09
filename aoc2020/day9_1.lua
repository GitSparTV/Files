local input = [[
*truncated*
]]
local nums = {}

for l in string.gmatch(input, "[^\n]+") do
	nums[#nums + 1] = tonumber(l)
end

local preamble = 25

for i = preamble + 1, #nums do
	local v, found = nums[i], false

	for j1 = i - preamble, i - 1 do
		for j2 = i - preamble, i - 1 do
			local a, b = nums[j1], nums[j2]

			if a ~= b and a + b == v then
				found = true
				print("Found " .. i .. " (" .. nums[i] .. ")")
				goto foundjmp
			end
		end
	end

	::foundjmp::

	if not found then
		print("Number " .. i .. " (" .. nums[i] .. ") has no sum in previous values")
	end
end
