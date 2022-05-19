local M = {{3}, {1, 1}, {0, 1, 1}, {0, 0, 1, 1}, {0, 0, 0, 1, 1}, {0, 0, 0, 0, 1, 1}, {0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1, 1, 4}}
local WasHere = {{}, {}, {}, {}, {}, {}, {}, {}}
NOTILE = 0
ORANGE = 1
BLUE = 2
PLAYER = 4
STAR = 3
local LEFT = 0
local UP = 1
local RIGHT = 2
local DOWN = 3

local ColorToColor = {
	[ORANGE] = Color(200, 100, 0),
	[BLUE] = Color(0, 100, 200),
	[NOTILE] = Color(20, 20, 20)
}

local AngleToAngle = {
	[LEFT] = -90,
	[UP] = 0,
	[RIGHT] = 90,
	[DOWN] = 180
}

local tileM = {}
tileM.__index = tileM

function tileM:GetColor()
	return self.Color
end

function tileM:HasStar()
	return self.Star
end

function tileM:SetColor(c)
	self.Color = c
end

function tileM:AddStar()
	self.Star = true
end

function tile()
	return setmetatable({}, tileM)
end

local playerM = {}
playerM.__index = playerM

function playerM:SetAngle(a)
	self.Angle = a
end

function playerM:GetAngle()
	return self.Angle
end

function playerM:SetPos(x, y)
	self.x = x
	self.y = y
end

function playerM:GetPos()
	return self.x, self.y
end

function playerM:Move()
	self.x, self.y = self.x + (self.Angle == LEFT and -1 or (self.Angle == RIGHT and 1 or 0)), self.y + (self.Angle == UP and -1 or (self.Angle == DOWN and 1 or 0))
end

function playerM:Left()
	self.Angle = self.Angle - 1

	if self.Angle < 0 then
		self.Angle = 3
	end
end

function playerM:Right()
	self.Angle = self.Angle + 1

	if self.Angle > 3 then
		self.Angle = 0
	end
end

function player()
	return setmetatable({}, playerM)
end

local PLY = player()
PLY:SetAngle(LEFT)
local GameM = {}

for y, yv in ipairs(M) do
	GameM[y] = {}

	for x = 1, 13 do
		local xv = yv[x]
		local T = tile()
		T:SetColor(xv or NOTILE)

		if xv == STAR then
			T:AddStar()
			T:SetColor(ORANGE)
		end

		if xv == PLAYER then
			T:SetColor(ORANGE)
			PLY:SetPos(x, y)
			PLY.Origin = {PLY.x, PLY.y}
		end

		GameM[y][x] = T
	end
end

hook.Add("HUDPaint", "21", function()
	for y, yv in ipairs(GameM) do
		for x, tile in ipairs(yv) do
			draw.RoundedBox(0, 200 + x * 30, 300 + y * 30, 30, 30, Color(100, 100, 100))
			draw.RoundedBox(0, 201 + x * 30, 301 + y * 30, 28, 28, ColorToColor[tile:GetColor()])

			if tile:HasStar() then
				draw.RoundedBox(0, 200 + x * 30 + 10, 300 + y * 30 + 10, 10, 10, Color(255, 255, 255))
			end
		end
	end

	for y, yv in pairs(WasHere) do
		for x, tile in pairs(yv) do
			if tile then
				draw.RoundedBox(4, 200 + x * 30 + 4, 300 + y * 30 + 4, 22, 22, Color(100, 100, 100, 100))
				draw.RoundedBox(4, 200 + x * 30 + 5, 300 + y * 30 + 5, 20, 20, Color(200, 100, 100, 100))
			end
		end
	end

	local x, y = PLY:GetPos()
	local angle = PLY:GetAngle()
	surface.SetDrawColor(Color(0, 255, 0))
	love.graphics.arc("fill", 215 + x * 30, 315 + y * 30, 10, math.rad(-45 + AngleToAngle[angle]), math.rad(270 - 45 + AngleToAngle[angle]), 100)
end)

local funcM = {}
funcM.__index = funcM

function funcM:SetAction(a)
	self.Action = a
end

function funcM:SetCondition(c)
	self.IF = c
end

function funcM:GetAction()
	if not self.Action then
		return function() end
	else
		return self.Action
	end
end

function funcM:CheckIF(cl)
	if not self.IF then return true end

	return self.IF == cl:GetColor()
end

local CURACTION = 0
A_MOVE = function() return PLY:Move() end
A_LEFT = function() return PLY:Left() end
A_RIGHT = function() return PLY:Right() end

A_GOTO = function()
	CURACTION = 0
end

function action(act, cond)
	local a = setmetatable({}, funcM)
	a:SetAction(act)
	a:SetCondition(cond)

	return a
end

local SEQ = {}
prtSEQ = ""
SEQid = ""
local ACT_RAND = {A_MOVE, A_LEFT, A_RIGHT, A_GOTO, false}

local _ACT_RAND = {
	[A_MOVE] = "A_MOVE",
	[A_LEFT] = "A_LEFT",
	[A_RIGHT] = "A_RIGHT",
	[A_GOTO] = "A_GOTO",
	[false] = "false"
}

local C_RAND = {ORANGE, BLUE, false}

local _C_RAND = {
	[ORANGE] = "ORANGE",
	[BLUE] = "BLUE",
	[false] = "false"
}

local Iteration = 0
local IterPos = {PLY:GetPos()}
local TimerUnchanged = 0
knownList = {}

function Reassemble(notadd)
	local x, y = PLY:GetPos()
	WasHere[y][x] = true
	PLY:SetPos(PLY.Origin[1], PLY.Origin[2])
	PLY:SetAngle(LEFT)
	CURACTION = 0

	if not notadd then
		knownList[SEQid] = true
	end

	SEQ = {}
	SEQid = ""
	Iteration = 0
	IterPos = {PLY:GetPos()}
	TimerUnchanged = 0

	for I = 1, 6 do
		local ract = math.random(5)
		local rcond = math.random(3)
		SEQid = SEQid .. ract .. rcond .. " "

		if ract == 5 then
			SEQ[I] = nil
			goto cont
		end

		if rcond == 3 then
			rcond = nil
		end

		local act = action(ACT_RAND[ract], C_RAND[rcond]);
		SEQ[I] = act
		::cont::
	end

	if knownList[SEQid] then return Reassemble(true) end

	prtSEQ = ""
	for I = 1, 6 do
		if SEQ[I] then
			prtSEQ = prtSEQ .. "Action " .. I .. ": " .. (SEQ[I] and _ACT_RAND[SEQ[I]:GetAction()] or "none") .. " if " .. (SEQ[I] and _C_RAND[SEQ[I].IF] or "any") .. "\n"
		else
			prtSEQ = prtSEQ .. "Action " .. I .. ": \n"
		end
	end
end

timer.Simple(0, function()
	Reassemble()

	hook.Add("Think", "PlayerMove", function()
		Iteration = Iteration + 1
		CURACTION = CURACTION + 1
		if CURACTION > 6 then return Reassemble() end
		local x, y = PLY:GetPos()
		if not GameM[y] or not GameM[y][x] or GameM[y][x]:GetColor() == NOTILE then return Reassemble() end

		if GameM[y][x]:HasStar() then
			print("----------------------")
			print(prtSEQ)
			print("----------------------")
			hook.Remove("Think", "PlayerMove")
			game.MakePopup()

			return
		end

		if Iteration > 100 then return Reassemble() end

		if x == IterPos[1] and y == IterPos[2] then
			TimerUnchanged = TimerUnchanged + 1
		else
			TimerUnchanged = 0
			IterPos = {x, y}
		end

		if TimerUnchanged > 18 then return Reassemble() end
		local act = SEQ[CURACTION]

		if act and act:CheckIF(GameM[y][x]) then
			act:GetAction()()
		end
	end)
end)