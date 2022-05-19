timer = {}
timer.timers = {}

hook.Add("Think", "TimerThink", function()
	local cur = CurTime()
	local toRemove = {}

	for k, v in ipairs(timer.timers) do
		if v.time > cur - v.startTime then
			goto cont
		end

		if v.time == 0 and not v.kill0 then
			v.kill0 = true
			goto cont
		end

		if v.simple or v.times == 1 then
			table.remove(timer.timers, k)
		end

		if v.times then
			if v.times ~= 0 then
				v.times = v.times - 1
			end

			v.startTime = cur
		end

		local b, err = pcall(v.callback,v.arg)

		if not b then
			if not v.simple and v.times == 0 then table.remove(timer.timers, k) end
			local A,B = err:find("%[?.-%]?:%d-:")
				local prefix,suffix = "",err
			if B then
				prefix = err:sub(A,B)
				suffix = err:sub(B+2,-1)
			end
			err = prefix .. " [timer:" .. (v.simple and "simple" or v.name) .. "]: " .. suffix
			print(FormatError(err,3))
		end

		::cont::
	end
end)

-- for k,v in ipairs(toRemove) do table.remove(timer.timers,v) end
function timer.Simple(time, callback,arg)
	if not isnumber(time) then error("time must be a number") end
	if not isfunction(callback) then error("callback must be a function") end

	table.insert(timer.timers, {
		startTime = CurTime(),
		time = time,
		callback = callback,
		arg = arg,
		simple = true
	})
end

function timer.Create(name, time, times, callback)
	if not isstring(name) then error("name must be a number") end
	if not isnumber(time) then error("time must be a number") end
	if not isnumber(times) then error("times must be a number") end
	if not isfunction(callback) then error("callback must be a number") end

	table.insert(timer.timers, {
		startTime = CurTime(),
		time = time,
		callback = callback,
		simple = false,
		times = times,
		name = name
	})
end