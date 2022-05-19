hook = {}
hook.Hooks = {}

function hook.GetTable()
	return hook.Hooks
end

function hook.Add(target, id, callback)
	if not target or not id or not callback then return end

	if not hook.Hooks[target] then
		hook.Hooks[target] = {}
	end

	hook.Hooks[target][id] = callback
end

function hook.Run(target, ...)
	local tbl = hook.Hooks[target]
	if not tbl then return end
	local a1, a2, a3, a4, a5, a6

	for k, v in pairs(tbl) do
		a1, a2, a3, a4, a5, a6 = v(...)
		if a1 ~= nil then return a1, a2, a3, a4, a5, a6 end
	end
end

function hook.Remove(target, id)
	if not target or not id or not hook.Hooks[target] then return end
	hook.Hooks[target][id] = nil
end