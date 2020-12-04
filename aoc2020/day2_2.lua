local input = [[
*trucated*
]]

local valid = 0
for l in string.gmatch(input, "[^\n]+") do
	local rangeS, rangeE, letter, password = string.match(l, "(%d+)%-(%d+) (%w): (.+)")
	rangeS, rangeE = tonumber(rangeS), tonumber(rangeE)
	local charA, charB = password:sub(rangeS, rangeS), password:sub(rangeE, rangeE)

	local a, b = charA == letter, charB == letter
	if a and not b or not a and b then valid = valid + 1 end
end
print("Valid: ", valid)
