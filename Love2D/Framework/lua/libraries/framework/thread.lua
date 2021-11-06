thread = {}
thread.threads = {}

function thread.Create(name, code)
	thread.threads[name] = love.thread.newThread("require('thread_init')\n" .. code)
end

function thread.CreateAsFile(name, filep)
	thread.threads[name] = love.thread.newThread(filep)
end

function thread.Run(name, ...)
	if not thread.threads[name] then return end
	thread.threads[name]:start(...)
end

function thread.IsRunning(name)
	if not thread.threads[name] then return end

	return thread.threads[name]:isRunning()
end

function thread.Wait(name)
	if not thread.threads[name] then return end
	thread.threads[name]:wait()
end

chan = {}
local chanM = {}

function chanM:Request(timeout)
	return self:demand(timeout)
end

function chanM:Send(val, timeout)
	return self:supply(val, timeout)
end

function chanM:Clear()
	return self:Clear()
end

function chanM:Len()
	return self:getCount()
end

function chanM:Exists(id)
	return self:hasRead(id)
end

function chanM:Read()
	return self:peek()
end

function chanM:Pop(val)
	return self:pop(val)
end

function chanM:Push(val)
	return self:push(val)
end

function chanM:Perform(...)
	return self:performAtomic(...)
end

for k, v in pairs(chanM) do
	debug.getregistry().Channel.__index[k] = v
end

function chan.Get(name)
	return love.thread.getChannel(name)
end

function love.threaderror(thr, err)
	local name = "unknown"

	for k, v in pairs(thread.threads) do
		if v == thr then
			name = k
			break
		end
	end

	err = err:gsub("^string:%d+: ", "%[thread." .. name:PatternSafe() .. "%]: ")
	print(FormatError(err, nil, true))
end