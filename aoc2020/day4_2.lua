local input = [[
*truncated*
]]
local M = {}
M.__index = M

function M:HasAllFields()
	return self.byr ~= nil and self.iyr ~= nil and self.eyr ~= nil and self.hgt ~= nil and self.hcl ~= nil and self.ecl ~= nil and self.pid ~= nil
end

local validecl = {
	["amb"] = true,
	["blu"] = true,
	["brn"] = true,
	["gry"] = true,
	["grn"] = true,
	["hzl"] = true,
	["oth"] = true
}

function M:Validate()
	do
		local byr = tonumber(self.byr)
		if byr < 1920 or byr > 2002 then return false, "invalid byr" end
	end

	do
		local iyr = tonumber(self.iyr)
		if iyr < 2010 or iyr > 2020 then return false, "invalid iyr" end
	end

	do
		local eyr = tonumber(self.eyr)
		if eyr < 2020 or eyr > 2030 then return false, "invalid eyr" end
	end

	do
		local num, unit = string.match(self.hgt, "^(%d+)(%w+)$")
		if not num or not unit then return false, "invalid hgt, num or unit not found" end
		num = tonumber(num)

		if unit == "cm" then
			if num < 150 or num > 193 then return false, "invalid hgt, not in range of cm" end
		elseif unit == "in" then
			if num < 59 or num > 76 then return false, "invalid hgt, not in range of inches" end
		else
			return false, "invalid hgt, unknown unit"
		end
	end

	do
		local found = string.match(self.hcl, "^#([0-9a-f]+)$")
		if not found or #found ~= 6 then return false, "invalid hcl" end
	end

	do
		if not validecl[self.ecl] then return false, "invalid ecl" end
	end

	do
		local found = string.match(self.pid, "^(%d+)$")
		if not found or #found ~= 9 then return false, "invalid pid" end
	end

	return true
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
		local res1 = cur:HasAllFields()

		if not res1 then
			goto skip
		end

		-- print("Has all fields:", res1)
		do
			local res2, err = cur:Validate()

			-- print("Validated:", res2, err)
			-- print()
			if res1 and res2 then
				valid = valid + 1
			end
		end

		::skip::
		cur = Passport()
	end

	for k, v in string.gmatch(l, "([^:]+):([^%s]+)%s?") do
		assert(validkeys[k], "unkown key" .. k)
		assert(#v ~= 0, "value with 0 length? " .. v)
		cur[k] = v
	end
end

print("Valid:", valid)
