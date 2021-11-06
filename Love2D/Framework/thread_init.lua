chan = {}

function chan.Get(name) return love.thread.getChannel(name) end

function chan:Request(ch,timeout) return self:demand(timeout) end
function chan:Send(ch,val,timeout) return self:supply(val,timeout) end
function chan:Clear(ch) return self:Clear() end
function chan:Len(ch) return self:getCount() end
function chan:Exists(ch,id) return self:hasRead(id) end
function chan:Read(ch) return self:peek() end
function chan:Pop(ch,val) return self:pop(val) end
function chan:Push(ch,val) return self:push(val) end
function chan:Perform(ch,...) return self:performAtomic(...) end

IsThread = true
ThreadArgs = {...}

function LoadDir(dir)
	for k, v in pairs(file and file.Find(dir) or love.filesystem.getDirectoryItems(dir)) do
		-- print("\tFile "..v)
		v = string.gsub(v, "%.lua", "")
		require(dir .. "." .. v)
	end
end

LoadDir("modules")