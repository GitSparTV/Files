shader = {}
shader.Library = {}

function shader.Create(name,code)
	shader.Library[name] = love.graphics.newShader(code)
	if shader.GetError(name) then
	-- print(#shader.GetError(name))
		-- ErrorNoHalt(shader.GetError(name))
	end
end

function shader.Push(name)
	if not shader.Library[name] then return end
	love.graphics.setShader(shader.Library[name])
end

shader.Pop = love.graphics.setShader

function shader.GetError(name)
	if not shader.Library[name] then return end
	local war = shader.Library[name]:getWarnings()
	if war == "" then return end
	return war
end

function shader.Send(name,id,...)
	if not shader.Library[name] then return end
	shader.Library[name]:send(id,...)
end

function shader.Get(name,id)
	if not shader.Library[name] then return end
	shader.Library[name]:getExternVariable(name,t)
end