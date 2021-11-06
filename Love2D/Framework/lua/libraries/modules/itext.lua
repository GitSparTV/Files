itext = {}
utf8.n = "\n"
utf8.space = " "
utf8.hyphen = "-"
utf8.dash = utf8.char(8212)
utf8.dot = "."
utf8.dot3 = "..."
--[[itext.RSuff.Kit--------------------------------------------------------]]
--
-- Конструктор Русских Окончаний
-- 1) Цифры 0 и 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
-- 2) Цифра 1
-- 3) Цифры 2,3,4
itext.RSuff = {}

function itext.RSuff.Kit(var05, var1, var234)
	return function(num)
		num = num % 100
		local m10 = num % 10
		if m10 == 0 or (num >= 11 and num <= 14) or m10 >= 5 then return var05 end

		return m10 == 1 and var1 or var234
	end
end

-- Т, Д
-- через 0 минут, 1 минуту, 2 минуты
-- через 0 секунд, 1 секунду, 2 секунды
itext.RSuff.YU = itext.RSuff.Kit("", "у", "ы")
-- С
-- через 0 часов, 1 час, 2 часа
itext.RSuff.AOV = itext.RSuff.Kit("ов", "", "а")
-- Д
-- через 0 дней, 1 день, 2 дня
itext.RSuff.DAY = itext.RSuff.Kit("дней", "день", "дня")

--[[itext.RSuff.Kit--------------------------------------------------------]]
--
function itext.Split(text, terminator, utf)
	terminator = terminator or " "
	local tbl, len, ss = {}, #text, 1

	if #terminator == 0 then
		if utf then
			for k, char in utf8.codes(text) do
				tbl[#tbl + 1] = utf8.char(char)
			end
		else
			for I = 1, len do
				tbl[I] = text:sub(I, I)
			end
		end

		return tbl
	end

	for I = 1, len do
		if text:sub(I, I) ~= terminator and I ~= len then
			goto cont
		end

		tbl[#tbl + 1] = text:sub(ss, I == len and I or I - 1)
		ss = I + 1
		::cont::
	end

	return tbl
end

-------------------
--  TEXT ASCII ENCODE
-------------------
function itext.ASCIIEncode(text)
	local tbl = {}

	for I = 1, #text do
		tbl[I] = text:sub(I, I):byte()
	end

	return table.concat(tbl, " ")
end

-------------------
--  TEXT ASCII TO TABLE
-------------------
function itext.ASCIIDecode(text)
	local exp = itext.Split(text)

	for I = 1, #exp do
		exp[I] = exp[I]:char()
	end

	return table.concat(exp)
end

-------------------
--  TEXT ASCII TO TABLE
-------------------
function itext.ASCIIToTable(text)
	local tbl = {}

	for I = 1, #text do
		tbl[I] = text:sub(I, I):byte()
	end

	return tbl
end

--[[
	for k,v in pairs(tbl) do
		if v != "" and v != nil and v != " " then
			if not table.HasValue(ignore,k) then
				if itext.IsASCII2Byte(tbl[k],tbl[k+1]) == 1 then
					table.insert(exit,tbl[k].." "..tbl[k+1])
					table.insert(ignore,k+1)
				else
					table.insert(exit,tostring(tbl[k]))
				end
			end
		end
	end
]]
-- -------------------
-- --  ASCII FINDER
-- -------------------
-- function itext.IsASCII2Byte(F,S)
-- if F == nil or S == nil then return 0 end
-- if F == "" or S == "" then return 0 end
-- if F == " " or S == " " then return 0 end
-- F = tonumber(F) or 0
-- S = tonumber(S) or 0
-- local b1,b2 = 0,0
-- if 194 <= F and F <= 223 and F != 10 then b1 = 1 end
-- if 128 <= S and S <= 191 and S != 10 then b2 = 1 end
-- 	return bit.band(b1,b2)
-- end
-------------------
--  TEXT SIZE IN PIXELS
-------------------
function itext.TextSize(text, font)
	surface.SetFont(font)

	return surface.GetTextSize(text)
end

-------------------
--  TEXT UTF-8 LENGTH 
-------------------
itext.len = utf8.len

-------------------
--  TEXT UTF-8 ENCODE
-------------------
function itext.Encode(text)
	local tbl = {}

	for k, v in utf8.codes(text) do
		tbl[#tbl + 1] = v
	end

	return table.concat(tbl, " ")
end

-------------------
--  TEXT UTF-8 DECODE
-------------------
function itext.Decode(text)
	local exp = istable(text) and text or itext.Split(text)

	for I = 1, #exp do
		exp[I] = utf8.char(tonumber(exp[I]))
	end

	return table.concat(exp)
end

-------------------
--  NIBBLE NUMERIC CONCATENATION ENCODING
-------------------
function itext.NNCEncode(...)
	local t = {...}

	for k, v in pairs(t) do
		if string.find(v, "[^%d]") then return print("FOUND") end
		local cache = ""

		if isstring(v) then
			cache = "1100"
		end

		v = tostring(v)

		for K, V in pairs(itext.ToTable(v)) do
			cache = cache .. math.DecToBin(V, 4)
		end

		t[k] = cache
	end

	return table.concat(t, "1011")
end

function itext.NNCDecode(line)
	local t1, t2 = {}, {}
	t1 = itext.Split
	local I, stringFlag = 1, false

	for k, v in pairs(t1) do
		if v == "1100" then
			stringFlag = true
			goto cont
		end

		if v == "1011" then
			I = I + 1

			if not stringFlag then
				t2[I] = tonumber(t2[I])
			end

			stringFlag = false
			goto cont
		end

		t2[I] = (t2[I] or "") .. tonumber(v, 2)
		::cont::
	end

	return t2
end

-------------------
--  FORCE ASCII FORMAT
-------------------
function itext.forceEncode(text)
	local s, pos = utf8.len(text)

	return s and text or text:sub(1, pos)
end

-------------------
--  TEXT WRAP BY LENGTH
-------------------
function itext.lenwrap(text, charlimit, hardness)
	local input, output, lastn, lastspaceo, lastspacec = itext.Split(text, "", true), {}, 0, 0

	for caret = 1, #input do
		local char, lookahead = input[caret], input[caret + 1]
		output[#output + 1] = char

		if char == utf8.n then
			lastn = caret
			lastspaceo, lastspacec = 0, 0
			goto cont
		elseif char == utf8.space then
			lastspaceo, lastspacec = #output, caret
		end

		if (caret - lastn) >= charlimit and lookahead then
			if lastspaceo ~= 0 and not hardness then
				output[lastspaceo] = utf8.n
				lastn = lastspacec
			else
				if lookahead ~= utf8.n then
					output[#output + 1] = utf8.n
				end

				lastn = caret
			end

			lastspaceo, lastspacec = 0, 0
		end

		::cont::
	end

	return table.concat(output)
end

-------------------
--  TEXT WRAP BY PIXELS
-------------------
function itext.wrap(text, font, maxW, hardness, maxY)
	local input, output, buf, lastspaceo, lastspacec, len, ncount, nsize = itext.Split(text, "", true), {}, "", 0, 0, 0, 0, 0
	surface.SetFont(font)

	if maxY then
		len, nsize = surface.GetTextSize(utf8.space)
	end

	for caret = 1, #input do
		local char, lookahead = input[caret], input[caret + 1]
		output[#output + 1] = char
		buf = buf .. char

		if char == utf8.n then
			lastn = caret
			lastspaceo, lastspacec = 0, 0
			ncount = ncount + 1
			goto cont
		elseif char == utf8.space then
			lastspaceo, lastspacec = #output, caret
		end

		len = surface.GetTextSize(lookahead and buf .. lookahead or buf)

		if len >= maxW then
			if lastspaceo ~= 0 and not hardness then
				output[lastspaceo] = utf8.n
				ncount = ncount + 1
				buf = ""
				lastn = lastspacec
			else
				if lookahead ~= utf8.n then
					output[#output + 1] = utf8.n
					ncount = ncount + 1
					if maxY and ncount * nsize >= maxY then return table.concat(output, "", 1, #output) end
				end

				buf = ""
				lastn = caret
			end

			lastspaceo, lastspacec = 0, 0
		end

		::cont::
	end

	return table.concat(output)
end

-------------------
--  TEXT FOLD BY LENGTH
-------------------
function itext.lenfold(text, cutsym)
	local input = itext.Split(text, "", true)
	cutsym = cutsym + 3
	if #input < cutsym then return text end
	input[cutsym] = utf8.dot3

	return table.concat(input, nil, nil, cutsym)
end

-------------------
--  TEXT FOLD BY PIXELS
-------------------
function itext.fold(text, font, sizex)
	surface.SetFont(font)
	if surface.GetTextSize(text) < sizex then return text end

	local lastfit,buf = ""
	sizex = math.floor(sizex) - surface.GetTextSize(utf8.dot3)
	for I = 1, #text do
		buf = text:sub(1,I)
		if surface.GetTextSize(buf) < sizex then lastfit = buf else return lastfit:sub(1,-2) .. utf8.dot3 end
	end
end

-------------------
--  TEXT FORMAT
-------------------
function itext.format(text)
	local input, output, skipc, textstart = itext.Split(text, "", true), {}, 0, false

	for I = 1, #input do
		local char, lookahead, lookback = input[I], input[I + 1], input[I - 1]

		if skipc > 0 then
			skipc = skipc - 1
			goto skip
		end

		if char == utf8.space then
			if not textstart then
				goto skip
			end

			if lookahead then
				if lookahead == utf8.space or lookahead == utf8.n then
					goto skip
				end
			else
				goto skip
			end

			if lookback == utf8.n then
				goto skip
			end
		elseif char == utf8.n and (not lookahead or lookahead == utf8.n) then
			goto skip
		elseif char == utf8.hyphen and lookahead == utf8.hyphen then
			skipc = 1
			output[#output + 1] = utf8.dash
			goto skip
		end

		textstart, textend = true, false
		output[#output + 1] = char
		::skip::
	end

	return table.concat(output)
end

if CLIENT then
	function itext.ScrollText(text, font, w, speed)
		local len, h = itext.TextSize(text, font)

		return (w) - (SysTime() * (speed or 120)) % ((w + len * 1.5))
	end
end

local CyrUppers = {
	["й"] = "Й",
	["ц"] = "Ц",
	["у"] = "У",
	["к"] = "К",
	["е"] = "Е",
	["н"] = "Н",
	["г"] = "Г",
	["ш"] = "Ш",
	["щ"] = "Щ",
	["з"] = "З",
	["х"] = "Х",
	["ъ"] = "Ъ",
	["ф"] = "Ф",
	["ы"] = "Ы",
	["в"] = "В",
	["а"] = "А",
	["п"] = "П",
	["р"] = "Р",
	["о"] = "О",
	["л"] = "Л",
	["д"] = "Д",
	["ж"] = "Ж",
	["э"] = "Э",
	["я"] = "Я",
	["ч"] = "Ч",
	["с"] = "С",
	["м"] = "М",
	["и"] = "И",
	["т"] = "Т",
	["ь"] = "Ь",
	["б"] = "Б",
	["ю"] = "Ю",
	["ё"] = "Ё"
}

function itext.CyrUpper(text)
	local output = {}

	for k, v in utf8.codes(text) do
		local char = utf8.char(v)
		output[#output + 1] = CyrUppers[char] and CyrUppers[char] or char:upper()
	end

	return table.concat(output)
end