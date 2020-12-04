local input = [[
*truncated*
]]
local M = {}
M.__index = M

function M:HasAllFields()
	return self.byr ~= nil and self.iyr ~= nil and self.eyr ~= nil and self.hgt ~= nil and self.hcl ~= nil and self.ecl ~= nil and self.pid ~= nil
end

local validkeys = {
	["byr"] = true,
	["iyr"] = true,
	["eyr"] = true,
	["hgt"] = true,
	["hcl"] = true,
	["ecl"] = true,
	["pid"] = true,
	["cid"] = true
}

local function Passport()
	return setmetatable({}, M)
end

local cur = Passport()
local valid = 0

for l in string.gmatch(input, "([^\n]*)\n?") do
	if #l == 0 then
		local res = cur:HasAllFields()

		if res then
			valid = valid + 1
		end

		cur = Passport()
	end

	for k, v in string.gmatch(l, "([^:]+):([^%s]+)%s?") do
		assert(validkeys[k], "unkown key" .. k)
		cur[k] = v
	end
end

print("Valid:", valid)
