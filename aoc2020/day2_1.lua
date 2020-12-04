local input = [[
*truncated*
]]

local valid = 0
for l in string.gmatch(input, "[^\n]+") do
	local rangeS, rangeE, letter, password = string.match(l, "(%d+)%-(%d+) (%w): (.+)")
	rangeS, rangeE = tonumber(rangeS), tonumber(rangeE)
	local _, count = string.gsub(password, letter, "")
	if rangeS <= count and count <= rangeE then
		valid = valid + 1
	end 
end
print("Valid: ", valid)
