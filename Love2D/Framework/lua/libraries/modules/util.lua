utf8 = require("utf8")
local InternalType = type

function type(any)
	local t = InternalType(any)
	if t == "table" or t == "cdata" then
		return any.__type
	else
		return t
	end
end

function printt(table, tab, antiloop)
	if not istable(table) then return end
	tab = tab or 0
	local t = string.rep("\t", tab)

	for k, v in pairs(table) do
		if istable(v) and antiloop ~= v then
			print(t .. tostring(k) .. ":")
			antiloop = v
			printt(v, tab + 1, antiloop)
			antiloop = nil
		else
			if antiloop == v then
				print(t .. tostring(k) .. " = ANTILOOP")
			else
				print(t .. tostring(k) .. " = " .. tostring(v))
			end
		end
	end
end

function forkv(t, func)
	for k, v in pairs(t) do
		func(k, v)
	end
end

function os.capture(cmd)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()

	return s
end

function table.Count(t)
	local n = 0

	for k, v in pairs(t) do
		n = n + 1
	end

	return n
end

function table.Copy(t, lookup_table)
	if not t then return end
	local copy = {}
	setmetatable(copy, debug.getmetatable(t))

	for i, v in pairs(t) do
		if (not istable(v)) then
			copy[i] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[t] = copy

			if (lookup_table[v]) then
				copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
			else
				copy[i] = table.Copy(v, lookup_table) -- not yet copied. copy it.
			end
		end
	end

	return copy
end

local function fnPairsSorted(pTable, Index)
	if (Index == nil) then
		Index = 1
	else
		for k, v in pairs(pTable.__SortedIndex) do
			if (v == Index) then
				Index = k + 1
				break
			end
		end
	end

	local Key = pTable.__SortedIndex[Index]

	if (not Key) then
		pTable.__SortedIndex = nil

		return
	end

	Index = Index + 1

	return Key, pTable[Key]
end

function RandomPairs(pTable, Desc)
	pTable = table.Copy(pTable)
	local SortedIndex = {}

	for k, v in pairs(pTable) do
		table.insert(SortedIndex, {
			key = k,
			val = math.random(1, 1000)
		})
	end

	if (Desc) then
		table.sort(SortedIndex, function(a, b) return a.val > b.val end)
	else
		table.sort(SortedIndex, function(a, b) return a.val < b.val end)
	end

	for k, v in pairs(SortedIndex) do
		SortedIndex[k] = v.key
	end

	pTable.__SortedIndex = SortedIndex

	return fnPairsSorted, pTable, nil
end

local function sortkeys(t, cmp)
	local dt = {}

	for k in pairs(t) do
		dt[#dt + 1] = k
	end

	if cmp == true then
		table.sort(dt)
	elseif cmp then
		table.sort(dt, cmp)
	end

	return dt
end

function SortedPairs(t, cmp)
	local kt = sortkeys(t, cmp or true)
	local i = 0

	return function()
		i = i + 1

		return kt[i], t[kt[i]]
	end
end

function table.Merge(dest, source, antiloop)
	for k, v in pairs(source) do
		if istable(v) and istable(dest[k]) then
			antiloop = v
			table.Merge(dest[k], v, antiloop)
			antiloop = nil
		else
			dest[k] = v
		end
	end

	return dest
end

-- function table.Inherit( t, base )
-- 	for k, v in pairs( base ) do 
-- 		if ( t[ k ] == nil ) then t[ k ] = v end
-- 	end
-- 	t[ "BaseClass" ] = base
-- 	return t
-- end
function table.ReArrange(t)
	local temp = {}

	for k, v in pairs(t) do
		if isnumber(k) then
			table.insert(temp, v)
		end
	end

	return temp
end

function FindMetaTable(name)
	return debug.getregistry()[name]
end

function isbool(any)
	return type(any) == "bool"
end

function isfunction(any)
	return type(any) == "function"
end

function isnumber(any)
	return type(any) == "number"
end

function isstring(any)
	return type(any) == "string"
end

function istable(any)
	return type(any) == "table"
end

function ispanel(any)
	return type(any) == "panel"
end

do
	local format, gsub = string.format, string.gsub

	function topf(num)
		return (gsub(format("%f", num), "(%.-)0+$", ""))
	end
end

do
	local mathfloor = math.floor
	function div2f(n)
		return mathfloor(n/2)
	end
end

function table.RemoveByValue(t,V)
	for k,v in pairs(t) do
		if v == V then
			t[k] = nil
			return true
		end
	end
	return false
end

function SysTime()
	return love.timer.getTime()
end

function IsValid(any)
	if not any then return false end
	if not any.IsValid then return false end

	return any:IsValid()
end

function CurTime()
	return love.CurTime or 0
end

local boot = [[
	main%.lua:%d-: in function <main%.lua:%d->
	main%.lua:%d-: in function <main%.lua:%d->
	%[C%]: in function 'xpcall'
	main%.lua:%d-: in function <main%.lua:%d->
	%[C%]: in function 'xpcall'
	%[string "boot%.lua"%]:%d-: in function <%[string "boot%.lua"%]:%d->
	%[C%]: in function 'xpcall'
	%[string "boot%.lua"%]:%d-: in function <%[string "boot%.lua"%]:%d->]]
local boot1 = [[
	main%.lua:%d-: in function <main%.lua:%d->
	%[C%]: in function 'xpcall'
	main%.lua:%d-: in function <main%.lua:%d->
	%[C%]: in function 'xpcall'
]]

function FormatError(msg, skip, tr)
	msg = tostring(msg)
	local trace = (tr and msg or debug.traceback("", 2))
	local sanitizedmsg = {}

	for char in msg:gmatch(utf8.charpattern) do
		if char == "\n" then break end
		table.insert(sanitizedmsg, char)
	end

	sanitizedmsg = table.concat(sanitizedmsg)
	local err = {}
	table.insert(err, "\n[ERROR] " .. sanitizedmsg)

	if not tr and #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	trace = trace:gsub(boot, "")
	trace = trace:gsub(boot1, "")
	local line, skipfirst = 1

	for l in trace:gmatch("(.-)\n") do
		if tr and not skipfirst then
			skipfirst = true
			goto cont
		end

		if l:match("boot%.lua") then
			goto cont
		end

		l = l:gsub("stack traceback:", "")

		if l == "" then
			goto cont
		end

		table.insert(err, string.rep(" ", line) .. line .. ". " .. l)
		line = line + 1
		::cont::
	end

	if TraceSKIP and TraceSKIP ~= 0 then
		skip = (skip or 0) + TraceSKIP
	end

	TraceSKIP = 0

	if skip then
		for I = 1, skip do
			table.remove(err, #err)
		end
	end

	local p = table.concat(err, "\n")
	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	return p
end

function RunString(s, name, skip)
	if s == "" or s == nil then return end
	local b, err = loadstring(s, name or "RunString")

	if not b then
		print("\n" .. FormatError(err, skip))

		return
	end

	local r, err = pcall(b)

	if not r then
		print(FormatError(err))
	end
end

function ErrorNoHalt(...)
	local t = {...}
	print(FormatError(table.concat(t)))
end

function debug.getargs(func)
	local k = 2
	local t = {}
	local param = debug.getlocal(func, 1)

	while param ~= nil do
		table.insert(t, param)
		param = debug.getlocal(func, k)
		k = k + 1
	end

	return t
end

function debug.Trace()
	local level = 1
	print("\nTrace:")

	while true do
		local info = debug.getinfo(level, "Sln")
		if not info then break end

		if (info.what) == "C" then
			print(string.format("\t%i: C function\t\"%s\"", level, info.name))
		else
			print(string.format("\t%i: Line %d\t\"%s\"\t\t%s", level, info.currentline, info.name, info.short_src))
		end

		level = level + 1
	end

	print("\n")
end

FORCE_STRING = "s"

function GetSet(meta, IN, bool)
	if bool == FORCE_STRING then
		meta["Set" .. IN] = function(self, val)
			self[IN] = tostring(val)
		end
	else
		meta["Set" .. IN] = function(self, val)
			self[IN] = val
		end
	end

	meta["Get" .. IN] = function(self) return self[IN] end
end