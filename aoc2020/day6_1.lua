local input = [[
*redacted*
]]
local total = 0
local t = {}

for l in string.gmatch(input, "([^\n]*)\n?") do
	if #l == 0 then
		for k, v in pairs(t) do
			total = total + 1
		end

		t = {}
	else
		string.gsub(l, "[a-z]", function(char)
			t[char] = true
		end)
	end
end

print(total)
