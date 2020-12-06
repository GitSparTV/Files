local input = [[
*redacted*
]]
local total = 0
local t, people = {}, 0

for l in string.gmatch(input, "([^\n]*)\n?") do
	if #l == 0 then
		if people == 0 then break end

		for k, v in pairs(t) do
			if v == people then
				total = total + 1
			end
		end

		t, people = {}, 0
	else
		people = people + 1

		string.gsub(l, "[a-z]", function(char)
			if not t[char] then
				t[char] = 0
			end

			t[char] = t[char] + 1
		end)
	end
end

print(total)
