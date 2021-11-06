Bot = {}
Bot.KEY = "redacted"
Bot.V = "5.85"
Bot.BLUE = "primary"
Bot.WHITE = "default"
Bot.RED = "negative"
Bot.GREEN = "positive"
Bot.Commands = {}
Bot.PayloadQueue = {}
Bot.TeacherData = database("mgppu/teachers.txt")
Bot.LessonsData = database("mgppu/lessons.txt")
Bot.CabsData = database("mgppu/cabs.txt")
Bot.ScheduleData = database("mgppu/schedule.txt")
Bot.TeacherData:Setup()
Bot.LessonsData:Setup()
Bot.CabsData:Setup()
Bot.ScheduleData:Setup()
Bot.Queue = {}

timer.Create("SparBot.Queue", 1.5, 0, function()
	if Bot.Queue[1] then
		Bot.Queue[1]()
		table.remove(Bot.Queue, 1)
	end
end)

function Bot.Send(chatid, text, keyboard)
	local request = {}
	request["peer_id"] = tostring(chatid)
	request["chat_id"] = tostring(chatid)
	request["message"] = text
	request["keyboard"] = keyboard
	request["access_token"] = Bot.KEY
	request["v"] = Bot.V

	table.insert(Bot.Queue, function()
		http.Post("https://api.vk.com/method/messages.send", request, function(txt)
			txt = util.JSONToTable(txt)

			-- if txt.error then timer.Simple(15,function() Bot.Send(chatid,text,keyboard) end) return end
			if keyboard then
				Bot.Delete(chatid, txt.response, true)
			else
				Bot.Delete(chatid, txt.response, false)
			end
		end, function(txt)
			print(txt)
		end)
	end)
end

function Bot.Delete(peer, msgid, perm)
	local request = {}
	request["group_id"] = tostring(peer)
	request["message_ids"] = tostring(msgid)
	request["delete_for_all"] = perm and "1" or "0"
	request["access_token"] = Bot.KEY
	request["v"] = Bot.V

	-- timer.Simple(5,function()
	http.Post("https://api.vk.com/method/messages.delete", request, function(txt)
		txt = util.JSONToTable(txt)
	end, function(txt)
		print(txt)
	end)
	-- end)
end

function Bot.Read(chatid, msgid)
	local request = {}
	request["peer_id"] = tostring(chatid)
	request["start_message_id"] = tostring(msgid)
	request["access_token"] = Bot.KEY
	request["v"] = Bot.V

	http.Post("https://api.vk.com/method/messages.markAsRead", request, function(txt)
		txt = util.JSONToTable(txt)
	end, function(txt)
		print(txt)
	end)
end

function Bot.PayloadProcessor(payload, peer, msgid)
	payload = payload.response

	if payload[1] == "cancel" then
		Bot.PayloadQueue = {}
		Bot.Read(peer, msgid)
		Bot.Delete(peer, msgid, false)

		return
	end

	if payload[1] == "next" then
		Bot.OpenKeyboard(peer, payload.id, Bot.PayloadQueue[payload.id].type, payload.page + 1, Bot.PayloadQueue[payload.id].setting)
		Bot.Delete(peer, msgid, false)

		return
	end

	if payload[1] == "nextday" then
		local day = Bot.PayloadQueue[payload.id].setting[2] + 86400

		if Bot.PayloadQueue[payload.id].type == "set" then
			Bot.ScheduleSet(peer, day)
		else
			Bot.ScheduleEdit(peer, day, Bot.PayloadQueue[payload.id].setting.what)
		end

		return
	end

	if payload.id then
		if Bot.PayloadQueue[payload.id] then
			Bot.PayloadQueue[payload.id].func(payload.option)
			Bot.PayloadQueue[payload.id] = nil
		else
			Bot.Send(peer, "Queue were cleared")
			Bot.Delete(peer, msgid, false)
		end
	end
end

--response and [[{"response":"]].."hello"..[["}]] or nil
function Bot.TimeToWeek(time)
	local dtow = {"Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"}

	return dtow[os.date("*t", time).wday]
end

function Bot.Button(text, color, response)
	local button = {
		action = {
			type = "text",
			payload = response and util.TableToJSON({
				response = response
			}) or nil,
			label = text
		},
		color = color
	}

	return "[" .. util.TableToJSON(button) .. "]"
end

function Bot.Keyboard(one, ...)
	local txt = "{\"buttons\":[ " .. string.Implode(", ", {...}) .. " ],\"one_time\":" .. tostring(one) .. "}"

	return txt
end

function Bot.MainKeyboard(peer)
	Bot.Send(peer, ".", Bot.Keyboard(false, Bot.Button("!schedule today", Bot.WHITE), Bot.Button("!schedule tomorrow", Bot.WHITE), Bot.Button("!schedule next", Bot.WHITE), Bot.Button("!schedule add " .. os.date("%d %m %Y", os.time()), Bot.WHITE), Bot.Button("!schedule remove " .. os.date("%d %m %Y", os.time() + 86400), Bot.WHITE)))
end

function Bot.OpenKeyboard(peer, id, type, page, setting)
	local buttons = {}
	local count = 0
	local buttonCount = 9

	local typeToList = {
		teacher = Bot.TeacherData:GetTable(),
		lessons = Bot.LessonsData:GetTable(),
		cabs = Bot.CabsData:GetTable(),
		class = {
			["1. 09:00 - 10:30"] = true,
			["2. 10:40 - 12:10"] = true,
			["3. 13:00 - 14:30"] = true,
			["4. 14:40 - 16:10"] = true,
			["5. 16:20 - 17:50"] = true
		},
		lesson_type = {
			["Lecture"] = true,
			["Practice"] = true,
			["Seminar"] = true,
			["Autonomy"] = true,
			["Exam"] = true
		}
	}

	if setting and type == "class" then
		for k, v in SortedPairs(typeToList.class) do
			if setting[1][tonumber(string.sub(k, 0, 1))] then
				typeToList.class[k] = "set"
			end
		end
	end

	if setting and setting.LastClass and type == "lessons" then
		buttonCount = 8

		table.insert(buttons, Bot.Button("Repeat", Bot.GREEN, {
			id = id,
			option = "lastclass"
		}))
	end

	if setting and setting.Last then
		buttonCount = 8

		table.insert(buttons, Bot.Button(setting.Last, Bot.GREEN, {
			id = id,
			option = setting.Last
		}))
	end

	local list = typeToList[type]
	page = page or 1

	if table.Count(list) - (page - 1) * buttonCount < 0 then
		page = 1
	end

	if table.Count(list) > buttonCount then
		for k, v in SortedPairs(list) do
			count = count + 1
			if count - (page - 1) * (buttonCount) <= 0 then continue end

			table.insert(buttons, Bot.Button(itext.lenfold(k, 37), type == "class" and (v == "set" and Bot.RED or Bot.GREEN) or Bot.WHITE, {
				id = id,
				option = k
			}))

			if count - (page - 1) * (buttonCount) == buttonCount - 1 then break end
		end

		table.insert(buttons, Bot.Button("Next (" .. page .. "/" .. math.ceil(table.Count(list) / buttonCount) .. ")", Bot.BLUE, {
			"next",
			id = id,
			page = page
		}))
	else
		for k, v in SortedPairs(list) do
			table.insert(buttons, Bot.Button(k, type == "class" and (v == "set" and Bot.RED or Bot.GREEN) or Bot.WHITE, {
				id = id,
				option = k
			}))

			count = count + 1
			if count == buttonCount - 1 then break end
		end
	end

	if type == "class" then
		table.insert(buttons, Bot.Button("Next Day (" .. os.date("%d/%m/%Y", setting[2] + 86400) .. ") (" .. Bot.TimeToWeek(setting[2] + 86400) .. ")", Bot.BLUE, {
			id = id,
"nextday"
		}))
	end

	table.insert(buttons, Bot.Button("Cancel", Bot.RED, {"cancel"}))
	-- file.Write("mgtest.txt",Bot.Keyboard(true,unpack(buttons)))
	Bot.Send(peer, ".", Bot.Keyboard(true, unpack(buttons)))
end

function Bot.PayloadCallback(id, type, callback, setting)
	local ID = table.insert(Bot.PayloadQueue, {
		func = callback,
		type = type,
		setting = setting
	})

	Bot.OpenKeyboard(id, ID, type, nil, setting)
end

function Bot.ArgProcessor(text)
	local cache = ""
	local cacheOn = false
	local cacheStart = 0
	local cacheKeysToDel = {}
	text = string.Explode(" ", text)

	for k, v in pairs(text) do
		if cacheOn then
			cache = cache .. " " .. v
		end

		if string.StartWith(v, [["]]) then
			cache = v
			cacheOn = true
			cacheStart = k
		end

		if string.EndsWith(v, [["]]) and not string.EndsWith(v, [[\"]]) then
			text[cacheStart] = string.sub(string.sub(cache, 2), 0, -2)

			for I = cacheStart + 1, k do
				table.insert(cacheKeysToDel, I)
			end

			cache = ""
			cacheOn = false
			cacheStart = 0
		end
	end

	for k, v in SortedPairs(cacheKeysToDel, true) do
		table.remove(text, v)
	end

	return text
end

function Bot.RegisterCommand(trigger, callback, needargs, help)
	Bot.Commands[trigger] = {
		callback = callback,
		help = help or "",
		needargs = needargs
	}
end

function Bot.CommandProccesor(cmd, args, id)
	if not Bot.Commands[cmd] then return end

	if Bot.Commands[cmd].needargs and #args == 0 then
		Bot.Send(id, Bot.Commands[cmd].help ~= "" and Bot.Commands[cmd].help or "Need args")

		return
	end

	Bot.Commands[cmd].callback(args, id)
end

function Bot.InputProcessor(t)
	if not t or t.text == "" then return end
	t = t.object
	local input = Bot.ArgProcessor(t.text)
	local peer_id = t.peer_id
	if peer_id ~= 17928733 then return end
	local payload = t.payload

	if t.text == "." then
		Bot.MainKeyboard(peer_id)
	end

	if t.text == "Cancel" then
		Bot.PayloadQueue = {}
		Bot.Read(peer_id, t.conversation_message_id)
		Bot.Delete(peer_id, t.conversation_message_id, false)
		Bot.MainKeyboard(peer_id)

		return
	end

	if payload then
		payload = util.JSONToTable(payload)
		Bot.PayloadProcessor(payload, peer_id, t.conversation_message_id)

		return
	end

	local cmd = table.remove(input, 1)
	Bot.CommandProccesor(cmd, input, peer_id)
	Bot.Delete(peer_id, t.conversation_message_id, false)
end

Bot.RegisterCommand("!teacher", function(args, id)
	local subcmd = table.remove(args, 1)

	if subcmd == "add" then
		Bot.TeacherData:EditKey(args[1], {
			phone = args[2]
		})

		Bot.Send(id, "Added teacher \"" .. args[1] .. "\"")
	elseif subcmd == "show" then
		local list = {}

		for k, v in pairs(Bot.TeacherData:GetTable()) do
			local info = ""

			for K, V in pairs(v) do
				info = info .. "\n" .. K .. ": " .. V
			end

			table.insert(list, k .. info)
		end

		Bot.Send(id, "Teacher list:\n" .. string.Implode("\n--\n", list))
	elseif subcmd == "delete" then
		Bot.TeacherData:EditKey(args[1], nil)
		Bot.Send(id, "Teacher \"" .. args[1] .. "\" was deleted")
	elseif subcmd == "edit" then
		local info = Bot.TeacherData:GetKey(args[1])
		local cache = info[args[2]]
		info[args[2]] = args[3]
		Bot.TeacherData:EditKey(args[1], info)
		Bot.Send(id, "Changed for \"" .. args[1] .. "\"\nVariable: " .. args[2] .. "\nOld value: " .. tostring(cache) .. "\nNew value: " .. args[3])
	elseif subcmd == "rename" then
		local oldteacher = Bot.TeacherData:GetKey(args[1])
		Bot.TeacherData:EditKey(args[1], nil)
		Bot.TeacherData:EditKey(args[2], oldteacher)
		Bot.Send(id, "Teacher \"" .. args[1] .. "\" was renamed to \"" .. args[2] .. "\"")
	end
end, true)

Bot.RegisterCommand("!lesson", function(args, id)
	local subcmd = table.remove(args, 1)

	if subcmd == "add" then
		Bot.LessonsData:EditKey(args[1], {})
		Bot.Send(id, "Added lesson \"" .. args[1] .. "\"")
	elseif subcmd == "show" then
		local list = {}

		for k, v in pairs(Bot.LessonsData:GetTable()) do
			local info = ""

			for K, V in pairs(v) do
				info = info .. "\n" .. K .. ": " .. V
			end

			table.insert(list, k .. info)
		end

		Bot.Send(id, "Lessons list:\n" .. string.Implode("\n--\n", list))
	elseif subcmd == "delete" then
		Bot.PayloadCallback(id, "lessons", function(lesson)
			Bot.LessonsData:EditKey(args[1], nil)
			Bot.Send(id, "Deleted lesson \"" .. lesson .. "\"")
		end)
	elseif subcmd == "assign" then
		Bot.PayloadCallback(id, "lessons", function(lesson)
			Bot.PayloadCallback(id, "teacher", function(teacher)
				Bot.LessonsData:EditKey(lesson, {
					AssignedTeacher = teacher
				})

				Bot.Send(id, "Assigned \"" .. teacher .. "\" for \"" .. lesson .. "\"")
			end)
		end)
	end
end, true)

Bot.RegisterCommand("!cab", function(args, id)
	local subcmd = table.remove(args, 1)

	if subcmd == "add" then
		Bot.CabsData:EditKey(args[1], true)
		Bot.Send(id, "Added cab \"" .. args[1] .. "\"")
	elseif subcmd == "delete" then
		Bot.PayloadCallback(id, "cabs", function(cab)
			Bot.CabsData:EditKey(cab, nil)
			Bot.Send(id, "Deleted cab \"" .. cab .. "\"")
		end)
	elseif subcmd == "show" then
		local list = {}

		for k, v in SortedPairs(Bot.CabsData:GetTable()) do
			table.insert(list, k)
		end

		Bot.Send(id, "Cabs list:\n" .. string.Implode("\n", list))
	end
end, true)

function Bot.ScheduleSet(id, time, lastclass)
	local day = Bot.ScheduleData:GetKey(time, {})
	local info = ""

	for k, v in SortedPairs(day) do
		info = info .. "\n" .. k .. ". [" .. v.Cab .. "] \"" .. v.LessonName .. "\" (" .. v.LessonType .. ") -- " .. v.TeacherName
	end

	Bot.Send(id, "Schedule for " .. os.date("%d/%m/%Y", time) .. info)

	Bot.PayloadCallback(id, "class", function(class)
		local num = string.sub(class, 0, 1)

		Bot.PayloadCallback(id, "lessons", function(lesson)
			if lesson == "lastclass" then
				day[num] = lastclass
				Bot.ScheduleData:EditKey(time, day)
				Bot.ScheduleSet(id, time, day[num])
				Bot.Send(id, "Add to schedule for " .. os.date("%d/%m/%Y", time) .. "\nClass: " .. num .. "\nLesson: [" .. day[num].Cab .. "] " .. day[num].LessonName .. " (" .. day[num].LessonType .. ")\nTeacher: " .. day[num].TeacherName)

				return
			end

			Bot.PayloadCallback(id, "lesson_type", function(type)
				Bot.PayloadCallback(id, "cabs", function(cab)
					local teacher

					if Bot.LessonsData:GetTable()[lesson].AssignedTeacher then
						teacher = Bot.LessonsData:GetTable()[lesson].AssignedTeacher

						day[num] = {
							LessonName = lesson,
							LessonType = type,
							TeacherName = teacher,
							Cab = cab
						}

						Bot.Send(id, "Add to schedule for " .. os.date("%d/%m/%Y", time) .. "\nClass: " .. num .. "\nLesson: [" .. cab .. "] " .. lesson .. " (" .. type .. ")\nTeacher: " .. teacher)
						Bot.ScheduleData:EditKey(time, day)
						Bot.ScheduleSet(id, time, day[num])
					else
						Bot.PayloadCallback(id, "teacher", function(teacher)
							day[num] = {
								LessonName = lesson,
								LessonType = type,
								TeacherName = teacher,
								Cab = cab
							}

							Bot.Send(id, "Add to schedule for " .. os.date("%d/%m/%Y", time) .. "\nClass: " .. num .. "\nLesson: [" .. cab .. "] " .. lesson .. " (" .. type .. ")\nTeacher: " .. teacher)
							Bot.ScheduleData:EditKey(time, day)
							Bot.ScheduleSet(id, time, day[num])
						end)
					end
				end)
			end)
		end, {
			LastClass = lastclass and true or false
		})
	end, {
		day,
		time,
		type = "set"
	})
end

function Bot.ScheduleEdit(id, time, what, Last)
	local day = Bot.ScheduleData:GetKey(time, {})
	local info = ""

	for k, v in SortedPairs(day) do
		info = info .. "\n" .. k .. ". [" .. v.Cab .. "] \"" .. v.LessonName .. "\" (" .. v.LessonType .. ") -- " .. v.TeacherName
	end

	Bot.Send(id, "Schedule for " .. os.date("%d/%m/%Y", time) .. info)

	Bot.PayloadCallback(id, "class", function(class)
		local num = tonumber(string.sub(class, 0, 1))

		Bot.PayloadCallback(id, what, function(got)
			if what == "cabs" then
				day[num].Cab = got
			end

			Bot.Send(id, "Changed for " .. os.date("%d/%m/%Y", time) .. "\nClass: " .. num .. "\nLesson: [" .. day[num].Cab .. "] " .. day[num].LessonName)
			Bot.ScheduleData:EditKey(time, day)
			Bot.ScheduleEdit(id, time, what, got)
		end, {
			Last = Last
		})
	end, {
		day,
		time,
		type = "edit",
		what = what
	})
end

Bot.RegisterCommand("!schedule", function(args, id)
	local subcmd = table.remove(args, 1)

	if not subcmd then
		Bot.Send(id, "1. 09:00 - 10:30\n2. 10:40 - 12:10\n3. 13:00 - 14:30\n4. 14:40 - 16:10\n5. 16:20 - 17:50")
	end

	if subcmd == "add" then
		local time = os.time({
			day = args[1],
			month = args[2],
			year = args[3],
			hour = 0,
			isdst = false,
			min = 0,
			sec = 0
		})

		Bot.ScheduleSet(id, time)
	elseif subcmd == "remove" then
		local time = os.time({
			day = args[1],
			month = args[2],
			year = args[3],
			hour = 0,
			isdst = false,
			min = 0,
			sec = 0
		})

		local day = Bot.ScheduleData:GetKey(time, {})

		Bot.PayloadCallback(id, "class", function(class)
			local num = string.sub(class, 0, 1)
			day[tonumber(num)] = nil
			Bot.ScheduleData:EditKey(time, day)
			Bot.Send(id, "Class " .. num .. " was deleted from " .. os.date("%d/%m/%Y", time))
		end, {day, time})
	elseif subcmd == "today" then
		local now = os.date("*t")

		local time = os.time({
			day = now.day,
			month = now.month,
			year = now.year,
			hour = 0,
			isdst = false,
			min = 0,
			sec = 0
		})

		local day = Bot.ScheduleData:GetKey(time, {})
		local info = ""

		for k, v in SortedPairs(day) do
			info = info .. "\n" .. k .. ". [" .. v.Cab .. "] \"" .. v.LessonName .. "\" (" .. v.LessonType .. ") -- " .. v.TeacherName
		end

		Bot.Send(id, "Schedule for " .. os.date("%d/%m/%Y", time) .. info)
	elseif subcmd == "tomorrow" then
		local offset = 0
		local day, now, time
		repeat
			offset = offset + 1
			now = os.date("*t")

			time = os.time({
				day = now.day,
				month = now.month,
				year = now.year,
				hour = 0,
				isdst = false,
				min = 0,
				sec = 0
			}) + 86400 * offset

			day = Bot.ScheduleData:GetKey(time, false)

			if offset > 4 then
				Bot.Send(id, "No lessons for next 4 days")

				return
			end
		until istable(day)
		local info = ""

		for k, v in SortedPairs(day) do
			info = info .. "\n" .. k .. ". [" .. v.Cab .. "] \"" .. v.LessonName .. "\" (" .. v.LessonType .. ") -- " .. v.TeacherName
		end

		Bot.Send(id, "Schedule for " .. os.date("%d/%m/%Y", time) .. info)
	elseif subcmd == "show" then
		local time = os.time({
			day = args[1],
			month = args[2],
			year = args[3],
			hour = 0,
			isdst = false,
			min = 0,
			sec = 0
		})

		local day = Bot.ScheduleData:GetKey(time, {})
		local info = ""

		for k, v in SortedPairs(day) do
			info = info .. "\n" .. k .. ". [" .. v.Cab .. "] \"" .. v.LessonName .. "\" (" .. v.LessonType .. ") -- " .. v.TeacherName
		end

		Bot.Send(id, "Schedule for " .. os.date("%d/%m/%Y", time) .. info)
	elseif subcmd == "wshow" then
		local time = os.time({
			day = args[1],
			month = args[2],
			year = args[3],
			hour = 0,
			isdst = false,
			min = 0,
			sec = 0
		})

		local lasttime = 0
		local infos = {}

		local ScheduleClass = {
			{
				StartTime = {9, 0},
				EndTime = {10, 30}
			},
			{
				StartTime = {10, 40},
				EndTime = {12, 10}
			},
			{
				StartTime = {13, 0},
				EndTime = {14, 30}
			},
			{
				StartTime = {14, 40},
				EndTime = {16, 10}
			},
			{
				StartTime = {16, 20},
				EndTime = {17, 50}
			}
		}

		for I = 0, 5 do
			local D = os.date("*t", time + 86400 * I)

			local time1 = os.time({
				day = D.day,
				month = D.month,
				year = D.year,
				hour = 0,
				isdst = false,
				min = 0,
				sec = 0
			})

			lasttime = time1
			local day = Bot.ScheduleData:GetKey(time1, {})
			local info = os.date("%d/%m/%Y", time1)

			for k, v in SortedPairs(day) do
				local start = os.time({
					day = D.day,
					month = D.month,
					year = D.year,
					hour = ScheduleClass[k].StartTime[1],
					isdst = false,
					min = ScheduleClass[k].StartTime[2],
					sec = 0
				})

				local endt = os.time({
					day = D.day,
					month = D.month,
					year = D.year,
					hour = ScheduleClass[k].EndTime[1],
					isdst = false,
					min = ScheduleClass[k].EndTime[2],
					sec = 0
				})

				info = info .. "\n" .. k .. ". (" .. os.date("%H:%M", start) .. " - " .. os.date("%H:%M", endt) .. ")> [" .. v.Cab .. "] \"" .. v.LessonName .. "\" (" .. v.LessonType .. ") -- " .. v.TeacherName
			end

			table.insert(infos, info)
		end

		Bot.Send(id, "Schedule for week from " .. os.date("%d/%m/%Y", time) .. " -- " .. os.date("%d/%m/%Y", lasttime) .. "\n-- -- --\n" .. string.Implode("\n-- --\n", infos))
	elseif subcmd == "edit" then
		local time = os.time({
			day = args[1],
			month = args[2],
			year = args[3],
			hour = 0,
			isdst = false,
			min = 0,
			sec = 0
		})

		Bot.ScheduleEdit(id, time, args[4])
	elseif subcmd == "next" then
		local offset = args[1] or 0

		Bot.PayloadCallback(id, "lessons", function(lesson)
			if Bot.LessonsData:GetKey(lesson).AssignedTeacher then
				for k, v in SortedPairs(Bot.ScheduleData:GetTable()) do
					if os.time() > k then continue end
					local cont = false

					for K, V in SortedPairs(v) do
						if cont then break end

						if V.LessonName == lesson and V.TeacherName == Bot.LessonsData:GetKey(lesson).AssignedTeacher then
							if offset ~= 0 then
								offset = offset - 1
								cont = true
							end

							Bot.Send(id, "Found lesson (" .. V.LessonType .. ") on " .. os.date("%d/%m/%Y", k) .. " (" .. Bot.TimeToWeek(k) .. "), class " .. K .. ", cab " .. V.Cab)

							return
						end
					end
				end

				Bot.Send(id, "No future lessons found. Maybe schedule isn't completed")
			else
				Bot.PayloadCallback(id, "teacher", function(teacher)
					for k, v in SortedPairs(Bot.ScheduleData:GetTable()) do
						local cont = false

						for K, V in SortedPairs(v) do
							if cont then break end

							if V.LessonName == lesson and V.TeacherName == teacher then
								if offset ~= 0 then
									offset = offset - 1
									cont = true
								end

								Bot.Send(id, "Found lesson (" .. V.LessonType .. ") on " .. os.date("%d/%m/%Y", k) .. " (" .. Bot.TimeToWeek(k) .. "), class " .. K .. ", cab " .. V.Cab)

								return
							end
						end
					end
				end)
			end
		end)
	end
end, false)

Bot.RegisterCommand("!ping", function(args, id)
	Bot.Send(id, "Pong")
end, false)

function Bot.BotLoop(t)
	SparBotLastUpdate = os.time()
	local request = {}
	request.key = t.response.key
	request.act = "a_check"
	request.ts = t.response.ts
	request.wait = "15"

	http.Post(t.response.server, request, function(q, w, e, r)
		local T = util.JSONToTable(q)

		if T.failed then
			SparBotON = false
			Bot.GetLongPoll()

			return
		end

		if T.updates and T.updates[1] then
			if tonumber(T.updates[1].object.conversation_message_id) == tonumber(Bot.LastID) then
				print("Killed shadow")

				return
			end

			Bot.LastID = T.updates[1].object.conversation_message_id
			Bot.InputProcessor(T.updates[1])
		end

		Bot.BotLoop({
			response = {
				key = t.response.key,
				server = t.response.server,
				ts = T.ts
			}
		})
	end, function(txt)
		print("fail", txt)
		SparBotON = false
		Bot.GetLongPoll()
	end)
end

local request = {}
request["group_id"] = "171360836"
request["access_token"] = Bot.KEY
request["v"] = Bot.V

function Bot.GetLongPoll()
	http.Post("https://api.vk.com/method/groups.getLongPollServer", request, function(txt)
		if SparBotON then return end
		if game.GetIPAddress() ~= "46.174.53.187:27016" then return end
		local t = util.JSONToTable(txt)
		print("[SparBot] Server fetched")
		SparBotON = true
		Bot.BotLoop(t)
	end, function(txt)
		print(txt)
	end)
end

if os.time() - (SparBotLastUpdate or 0) > 16 then
	SparBotON = false
	Bot.GetLongPoll()
end

Bot.GetLongPoll()

timer.Create("SparBot.LongPollCheck", 16, 0, function()
	if game.GetIPAddress() ~= "46.174.53.187:27016" then return end

	if os.time() - (SparBotLastUpdate or 0) > 16 then
		SparBotON = false
		Bot.GetLongPoll()
	end
end)

hook.Add("Think", "SparBot.Time", function()
	if game.GetIPAddress() ~= "46.174.53.187:27016" then return end
	if Bot.Time and (Bot.Time.min or 0) == os.date("*t").min then return end
	Bot.Time = os.date("*t")

	local day = os.time({
		day = Bot.Time.day,
		month = Bot.Time.month,
		year = Bot.Time.year,
		hour = 0,
		isdst = false,
		min = 0,
		sec = 0
	})

	local sched = Bot.ScheduleData:GetKey(day, false)
	if sched == false then return end

	local ScheduleClass = {
		{
			StartTime = {9, 0},
			EndTime = {10, 30}
		},
		{
			StartTime = {10, 40},
			EndTime = {12, 10}
		},
		{
			StartTime = {13, 0},
			EndTime = {14, 30}
		},
		{
			StartTime = {14, 40},
			EndTime = {16, 10}
		},
		{
			StartTime = {16, 20},
			EndTime = {17, 50}
		}
	}

	local first = true

	for k, v in SortedPairs(sched) do
		local start = os.time({
			day = Bot.Time.day,
			month = Bot.Time.month,
			year = Bot.Time.year,
			hour = ScheduleClass[k].StartTime[1],
			isdst = false,
			min = ScheduleClass[k].StartTime[2],
			sec = 0
		})

		local endt = os.time({
			day = Bot.Time.day,
			month = Bot.Time.month,
			year = Bot.Time.year,
			hour = ScheduleClass[k].EndTime[1],
			isdst = false,
			min = ScheduleClass[k].EndTime[2],
			sec = 0
		})

		local nstart
		local nendt

		if sched[k + 1] then
			nstart = os.time({
				day = Bot.Time.day,
				month = Bot.Time.month,
				year = Bot.Time.year,
				hour = ScheduleClass[k + 1].StartTime[1],
				isdst = false,
				min = ScheduleClass[k + 1].StartTime[2],
				sec = 0
			})

			nendt = os.time({
				day = Bot.Time.day,
				month = Bot.Time.month,
				year = Bot.Time.year,
				hour = ScheduleClass[k + 1].EndTime[1],
				isdst = false,
				min = ScheduleClass[k + 1].EndTime[2],
				sec = 0
			})
		end

		local curr = os.time({
			day = Bot.Time.day,
			month = Bot.Time.month,
			year = Bot.Time.year,
			hour = Bot.Time.hour,
			isdst = false,
			min = Bot.Time.min,
			sec = 0
		})

		if (first or k == 3) and start - curr == 600 then
			Bot.Send("17928733", "Lesson \"" .. v.LessonName .. "\" (" .. v.LessonType .. ") will start in 10 min.\n[" .. v.Cab .. "] " .. v.TeacherName .. "\n" .. os.date("%H:%M", start) .. " - " .. os.date("%H:%M", endt))

			return
		end

		if endt == curr then
			local add = ""

			if sched[k + 1] then
				if table.Compare(sched[k + 1], v) then
					add = "Next lesson in the same place"
				else
					if sched[k + 1].LessonType == "Autonomy" then
						add = "No more lessons for today. But this day assigned an autonomy lesson:\n\"" .. sched[k + 1].LessonName .. "\" (" .. sched[k + 1].LessonType .. ")\n[" .. sched[k + 1].Cab .. "] " .. sched[k + 1].TeacherName
					else
						add = "Next lesson: \"" .. sched[k + 1].LessonName .. "\" (" .. sched[k + 1].LessonType .. ")\n[" .. sched[k + 1].Cab .. "] " .. sched[k + 1].TeacherName
					end
				end
			else
				add = "No more lessons today"
			end

			Bot.Send("17928733", "Class " .. k .. " ended\n" .. add .. "\n" .. (add == "No more lessons today" and "" or (os.date("%H:%M", nstart) .. " - " .. os.date("%H:%M", nendt))))

			return
		end

		first = false
	end
end)
-- Bot.Send("17928733",".",
-- 	Bot.Keyboard(true,
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("1234567890123456789012345678901234567890",Bot.BLUE),
-- 		Bot.Button("Next (1/2)",Bot.BLUE),
-- 		Bot.Button("Cancel",Bot.BLUE)
-- 	)
-- )
