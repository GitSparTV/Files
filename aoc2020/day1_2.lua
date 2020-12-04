local input = [[
*truncated*
]]
local t, len = {}, 0

for l in string.gmatch(input, "[^\n]+") do
	l = tonumber(l)

	if l > 2020 then
		goto skip
	end

	len = len + 1
	t[len] = l
	::skip::
end

for k1 = 1, len do
	for k2 = 1, len do
		for k3 = 1, len do
			if k1 ~= k2 and k1 ~= k3 and k2 ~= k3 and t[k1] + t[k2] + t[k3] == 2020 then
				print("Found answer: ", k1, k2, k3, t[k1], t[k2], t[k3], t[k1] * t[k2] * t[k3])
			end
		end
	end
end
