local input = [[

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
		local invalid = nums[i]
		print("Number " .. i .. " (" .. nums[i] .. ") has no sum in previous values")
		local array, len, sum = {}, 0, 0

		for i = 1, #nums do
			for l = 1, len do
				array[l] = nil
			end

			local a = nums[i]
			len = 1
			array[len] = a
			sum = a

			for j = i + 1, #nums do
				local b = nums[j]

				sum = sum + b
				len = len + 1
				array[len] = b
				if sum == invalid then
					print("SUM FOUND")
					table.sort(array)
					print(array[1] + array[len])
					return
				elseif sum > invalid then
					break
				end
			end
		end
		print("?????")

		return
	end
end
