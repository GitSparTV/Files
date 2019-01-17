#!/usr/local/bin/lua

local b,err = pcall(function()

	function io.IsDir(path)
		if type(path)~="string" then return false end
		path = FormatPath(path)
		local exist = os.rename(path,path)
		if not exist or ValidFile(path) then return false end 
		return true
	end

	function string.Explode(separator, str, withpattern)
		if ( withpattern == nil ) then withpattern = false end

		local ret = {}
		local current_pos = 1

		for i = 1, string.len( str ) do
			local start_pos, end_pos = string.find( str, separator, current_pos, not withpattern )
			if ( not start_pos ) then break end
			ret[ i ] = string.sub( str, current_pos, start_pos - 1 )
			current_pos = end_pos + 1
		end

		ret[ #ret + 1 ] = string.sub( str, current_pos )

		return ret
	end

	function string.Replace( str, tofind, toreplace )
		local tbl = string.Explode( tofind, str )
		if ( tbl[ 1 ] ) then return table.concat( tbl, toreplace ) end
		return str
	end
	function FormatPath(path) if string.sub(path,1,2) == " \"" then return string.sub(path,3,-2) end return FormatFile(path) end
	function FormatFile(path) return string.Replace(path,"\\","/") end
	function FormatType(path,t)
		if string.sub(path,-(string.len(t))) ~= t then return path..t end
		return path
	end
	function ValidFile(path)
		local temp = io.open(path)
		if temp and temp:read() ~= nil then temp:close() return true end
		return false
	end

	function table.Count(t) local i = 0 for k in pairs( t ) do i = i + 1 end return i end

	function string.ToTable(str)
		local exit = {}
		str=" "..str.."\n"
		str=str:gsub("%s(%S-)=","\n%1=")
		for k, v in string.gmatch(str, "(%S-)=(.-)\n") do
			exit[k] = v
		end
		return exit
	end

	function os.capture(cmd)
	  local f = assert(io.popen(cmd, 'r'))
	  local s = assert(f:read('*a'))
	  f:close()
	  return s
	end

	------------------------------------------------------------------------------------

	local Local = {}
	Local.SelfPath = string.match(arg[0],"^(.*[/\\])[^/\\]-$")
	Local.ConfigFile = io.open(Local.SelfPath.."lua_workshopper.cfg")
	Local.Mode = "file"
	Local.Functions = {}
	Local.GMPublishErrors = {
				[1] = "success",
				[2] = "generic failure",
				[3] = "no/failed network connection",
				[4] = "OBSOLETE - removed",
				[5] = "password/ticket is invalid",
				[6] = "same user logged in elsewhere",
				[7] = "protocol version is incorrect",
				[8] = "a parameter is incorrect",
				[9] = "file was not found",
				[10] = "called method busy - action not taken",
				[11] = "called object was in an invalid state",
				[12] = "name is invalid",
				[13] = "email is invalid",
				[14] = "name is not unique",
				[15] = "access is denied",
				[16] = "operation timed out",
				[17] = "VAC2 banned",
				[18] = "account not found",
				[19] = "steamID is invalid",
				[20] = "The requested service is currently unavailable",
				[21] = "The user is not logged on",
				[22] = "Request is pending (may be in process, or waiting on third party)",
				[23] = "Encryption or Decryption failed",
				[24] = "Insufficient privilege",
				[25] = "Too much of a good thing",
				[26] = "Access has been revoked (used for revoked guest passes)",
				[27] = "License/Guest pass the user is trying to access is expired",
				[28] = "Guest pass has already been redeemed by account, cannot be acked again",
				[29] = "The request is a duplicate and the action has already occurred in the past, ignored this time",
				[30] = "All the games in this guest pass redemption request are already owned by the user",
				[31] = "IP address not found",
				[32] = "failed to write change to the data store",
				[33] = "failed to acquire access lock for this operation",
				[34] = "k_EResultLogonSessionReplaced",
				[35] = "k_EResultConnectFailed",
				[36] = "k_EResultHandshakeFailed",
				[37] = "k_EResultIOFailure",
				[38] = "k_EResultRemoteDisconnect",
				[39] = "failed to find the shopping cart requested",
				[40] = "a user didn't allow it",
				[41] = "target is ignoring sender",
				[42] = "nothing matching the request found",
				[43] = "k_EResultAccountDisabled",
				[44] = "this service is not accepting content changes right now",
				[45] = "account doesn't have value, so this feature isn't available",
				[46] = "allowed to take this action, but only because requester is admin",
				[47] = "A Version mismatch in content transmitted within the Steam protocol.",
				[48] = "The current CM can't service the user making a request, user should try another.",
				[49] = "You are already logged in elsewhere, this cached credential login has failed.",
				[50] = "You are already logged in elsewhere, you must wait",
				[51] = "Long running operation (content download) suspended/paused",
				[52] = "Operation canceled (typically by user: content download)",
				[53] = "Operation canceled because data is ill formed or unrecoverable",
				[54] = "Operation canceled - not enough disk space.",
				[55] = "an remote call or IPC call failed",
				[56] = "Password could not be verified as it's unset server side",
				[57] = "External account (PSN, Facebook...) is not linked to a Steam account",
				[58] = "PSN ticket was invalid",
				[59] = "External account (PSN, Facebook...) is already linked to some other account, must explicitly request to replace/delete the link first",
				[60] = "The sync cannot resume due to a conflict between the local and remote files",
				[61] = "The requested new password is not legal",
				[62] = "new value is the same as the old one ( secret question and answer )",
				[63] = "account login denied due to 2nd factor authentication failure",
				[64] = "The requested new password is not legal",
				[65] = "account login denied due to auth code invalid",
				[66] = "account login denied due to 2nd factor auth failure - and no mail has been sent",
				[67] = "k_EResultHardwareNotCapableOfIPT",
				[68] = "k_EResultIPTInitError",
				[69] = "operation failed due to parental control restrictions for current user",
				[70] = "Facebook query returned an error",
				[71] = "account login denied due to auth code expired",
				[72] = "k_EResultIPLoginRestrictionFailed",
				[73] = "k_EResultAccountLockedDown",
				[74] = "k_EResultAccountLogonDeniedVerifiedEmailRequired",
				[75] = "k_EResultNoMatchingURL",
				[76] = "parse failure, missing field, etc.",
				[77] = "The user cannot complete the action until they re-enter their password",
				[78] = "the value entered is outside the acceptable range",
				[79] = "something happened that we didn't expect to ever happen",
				[80] = "The requested service has been configured to be unavailable",
				[81] = "The set of files submitted to the CEG server are not valid !"
}

	function Local.RegisterFunction(cmd,help,func)
		Local.Functions[cmd] = {help=help or "",func=func}
	end

	function Local.Exec(trigger)
		if not trigger then return end
		local func = Local.Functions[trigger]
		if not func then return end
		Local.LastExec = trigger
		return func.func()
	end

	function Local.Relative()
		if Local.Mode == "file" then return "name relative to the folder where LuaWorkshopper is located" end 
		if Local.Mode == "path" then return "path starting from disk (C:/)" end 
	end

	function Local.RelPath() if Local.Mode == "file" then return Local.SelfPath else return "" end end

	function Local.ParseGMAD()
		local text = Local.GMAD
		-- print(text)
		local errors = {
			"No files found, can't continue",
			"Not allowed by whitelist",
			"Filename contains captial letters",
			"seems to be empty %(or we couldn't read it%)",
			"Failed to create the addon",
			"Couldn't save to file",
			"addon%.json error: Couldn't find file"
		}
		local RealErrors = {}
		for k,v in pairs(errors) do
			for V in string.gmatch(text,v) do
				RealErrors[V] = RealErrors[V] and RealErrors[V]+1 or 1
			end
		end
		if table.Count(RealErrors) == 0 then return print("[Lua Workshopper] No errors") end
		print("[Lua Workshopper] Found "..table.Count(RealErrors).." error(s) or hint(s) on creating:")
		for k,v in pairs(RealErrors) do
			print("\t"..k.." - "..v.." time(s)")
		end
		print("If you want to see gmad.exe log type \"gma log\"")
	end

	function Local.OpenGMPublish()
		local url = Local.GMPublish
		for k in string.gmatch(url,"UID:%s%d+") do
			url = string.sub(k,6)
			os.execute([[start steam://nav/media]])
			os.execute([[start steam://openurl/http://steamcommunity.com/sharedfiles/filedetails/?id=]]..url)
			print("[LuaWorkshopper] Link to new addon was opened in Steam App")
			return
		end
		print("[LuaWorkshopper] Can't find UID.")
	end

	------------------------------------------------------------------------------------

	------------ GMA LOG

	Local.RegisterFunction("gma log","Returns last gmad.exe log. Available after gmad.exe build.",function()
		print(Local.GMAD and Local.GMAD or "[Lua Workshopper] No log available.")
	end)

	------------ WORKSHOP LOG

	Local.RegisterFunction("workshop log","Returns last gmpublish.exe log. Available after gmpublish.exe executing.",function()
		print(Local.GMPublish and Local.GMPublish or "[Lua Workshopper] No log available.")
	end)

	------------ WORKSHOP ERRORS

	Local.RegisterFunction("workshop error","Return error description by number",function()
		os.execute("cls")
		print("[LuaWorkshopper] If gmpublish.exe return you error number, you can check it description. Type number there. Type \"cancel\" to exit.")
		repeat
			local num = io.read()
			if num == "cancel" then return Local.Logo(true) end
			num = tonumber(num)
			if not Local.GMPublishErrors[num] then print("No error to this number") else
				print("Error number "..num.." means \""..Local.GMPublishErrors[num].."\"")
			end
		until false == true
	end)

	------------ EXIT

	Local.RegisterFunction("exit","Exit program",function()
		os.execute("cls")
		print("Created by Spar on Lua.\n.exe compiler: srlua 5.1 pre-compiled")
		local sleep = os.clock()
		while os.clock() - sleep <= 3 do end
		os.exit()
	end)

	------------ HELP

	Local.RegisterFunction("help","Return available commands",function()
		print("-\t-\t-\t-\t-")
		print("Arguments accepted after command execution.")
		print("Available commands:")

		local keys = {}
		for k in pairs(Local.Functions) do table.insert(keys, k) end
		table.sort(keys)
		for K,V in ipairs(keys) do
			local v = Local.Functions[V]
			print(V.." | "..v.help)
		end
		print("-\t-\t-\t-\t-")
	end)

	------------ CREATE GMA

	Local.RegisterFunction("gma","Creates .gma",function()
			os.execute("cls")
			local q = "\""
		repeat
			print("[Lua Workshopper] Enter folder "..Local.Relative()..(Local.Mode == "file" and ". Type \"self\" to use this folder" or "")..". Type \"cancel\" to exit.")
			local folder = io.read()
			if folder == "cancel" then Local.Logo(true) return end
			if Local.Mode == "file" and folder == "self" then folder = "/" end
			folder = FormatPath(folder)
			local valid = io.IsDir(Local.RelPath()..folder)
			if not valid or folder == " " then print("Folder isn't valid or not a folder!") else
				-- print(q..q..Local.Config.."\\gmad.exe"..q.." create -folder "..q..Local.SelfPath..folder..q.." -out "..q..Local.SelfPath..q..q)
				Local.GMAD = os.capture(q..q..Local.Config.."\\gmad.exe"..q.." create -folder "..q..Local.RelPath()..folder..q.." -out "..q..Local.RelPath()..folder..".gma"..q..q)
				return Local.Logo(true)
			end 
		until true == false

	end)

	------------ WORKSHOP LIST

	Local.RegisterFunction("workshop list","Returns list of Workshop Items",function()
		os.execute("cls")
		local q = "\""
		os.execute(q..q..Local.Config.."\\gmpublish.exe"..q.." list"..q)
	end)

	------------ WORKSHOP NEW

	Local.RegisterFunction("workshop create","Creates new Workshop Item",function()
			os.execute("cls")
			local q = "\""
		repeat
			print("[Lua Workshopper] Enter .gma file "..Local.Relative()..". Type \"cancel\" to exit.")
			local file = io.read()
			if file == "cancel" then Local.Logo(true) return end
			file = FormatPath(file)
			file = FormatType(file,".gma")
			local valid = ValidFile(Local.RelPath()..file)
			if not valid then print("File isn't valid or not .gma!") else
				repeat
					print("[Lua Workshopper] Enter .jpg file "..Local.Relative()..". Type \"cancel\" to exit.")
					local png = io.read()
					if png == "cancel" then Local.Logo(true) return end
					png = FormatPath(png)
					png = FormatType(png,".jpg")
					local valid = ValidFile(Local.RelPath()..png)
					if not valid then print("File isn't valid or not .jpg!") else
					-- print(q..q..Local.Config.."\\gmpublish.exe"..q.." create -addon "..q..Local.RelPath()..file..q.." -icon "..q..Local.RelPath()..png..q..q)
					Local.GMPublish = os.capture(q..q..Local.Config.."\\gmpublish.exe"..q.." create -addon "..q..Local.RelPath()..file..q.." -icon "..q..Local.RelPath()..png..q..q)
					return Local.Logo(true)
						end
				until true == false
			end 
		until true == false
	end)

	------------ WORKSHOP UPDATE

	function Local.UpdateAddon(info)
		local q = "\""
		local left = q..q..Local.Config.."\\gmpublish.exe"..q.." update "
		local right = q
		local args = ""

		for k,v in pairs(info) do
			args = args..k.." "..q..v..q.." "
		end

		Local.GMPublish = os.capture(left..args..right)
		os.execute([[start steam://nav/media]])
		os.execute([[start steam://openurl/http://steamcommunity.com/sharedfiles/filedetails/?id=]]..info["-id"])
		return Local.Logo(true)
	end

	Local.RegisterFunction("workshop update","Updates new Workshop Item",function()
			os.execute("cls")
			local UpdateInfo = {}
		repeat
			print("[Lua Workshopper] Enter Addon ID. Forget? Type \"list\". Type \"cancel\" to exit.")
			local ID = io.read()
			if ID == "cancel" then Local.Logo(true) return end
			if ID == "list" then Local.Exec("workshop list") end
			if tostring(tonumber(ID)) == ID then
				UpdateInfo["-id"] = ID
				print("[Lua Workshopper] Would you like to update image? (512x512 and .jpg) (y/n)")
				local DO = io.read()
				if DO == "y" then
					repeat
						local done = false
						print("[Lua Workshopper] Enter .jpg file "..Local.Relative()..". Type \"cancel\" to exit.")
						local image = io.read()
						if image == "cancel" then Local.Logo(true) return end
						image = FormatPath(image)
						image = FormatType(image,".jpg")
						local valid = ValidFile(Local.RelPath()..image)
						if not valid then print("File isn't valid or not .jpg!") else
							print("Image added to queue.")
							UpdateInfo["-icon"] = Local.RelPath()..image
							done = true
						end
					until done

					print("[Lua Workshopper] Would you like to update addon .gma? (y/n)")
					local DO = io.read()
					if DO == "y" then
						repeat
							local done = false
							print("[Lua Workshopper] Enter .gma file "..Local.Relative()..". Type \"cancel\" to exit.")
							local file = io.read()
							if file == "cancel" then Local.Logo(true) return end
							file = FormatPath(file)
							file = FormatType(file,".gma")
							local valid = ValidFile(Local.RelPath()..file)
							if not valid then print("File isn't valid or not .gma!") else
								print("Addon added to queue.")
								UpdateInfo["-addon"] = Local.RelPath()..file
								done = true
							end
						until done

						print("[Lua Workshopper] Would you like add changes text? You can edit it later in changelog. (y/n)")
						local DO = io.read()
						if DO == "y" then
							print("[Lua Workshopper] Enter changes. Type \"cancel\" to exit.")
							local text = io.read()
							if text == "cancel" then Local.Logo(true) return end
							text = FormatPath(text)
							print("Changes added to queue.")
							UpdateInfo["-changes"] = image
						end
					end
				else
					repeat
						local done = false
						print("[Lua Workshopper] Enter .gma file "..Local.Relative()..". Type \"cancel\" to exit.")
						local file = io.read()
						if file == "cancel" then Local.Logo(true) return end
						file = FormatPath(file)
						file = FormatType(file,".gma")
						local valid = ValidFile(Local.RelPath()..file)
						if not valid then print("File isn't valid or not .gma!") else
							print("Addon added to queue.")
							UpdateInfo["-addon"] = Local.RelPath()..file
							done = true
						end
					until done

					print("[Lua Workshopper] Would you like add changes text? You can edit it later in changelog. (y/n)")
					local DO = io.read()
					if DO == "y" then
						print("[Lua Workshopper] Enter changes. Type \"cancel\" to exit.")
						local text = io.read()
						if text == "cancel" then Local.Logo(true) return end
						text = FormatPath(text)
						print("Changes added to queue.")
						UpdateInfo["-changes"] = text
					end
				end

				if UpdateInfo["-icon"] or UpdateInfo["-addon"] then return Local.UpdateAddon(UpdateInfo) end
			end
		until true == false
	end)

	------------ SWITCH MODE

	Local.RegisterFunction("mode","Switches input mode filename/path",function()
		if Local.Mode == "file" then
			Local.Mode = "path"
			print("[LuaWorkshopper] Current mode: path input.")
			print("This mode require full path starin from disk (C:/).")
			print("LuaWorkshopper will find files and folders by their path. Quoutes will stripped automatically.")
		else
			Local.Mode = "file"
			print("[LuaWorkshopper] Current mode: filename input.")
			print("This mode require only file or folder name.")
			print("LuaWorkshopper will find files and folders in same folder where this file located")
			print("LuaWorkshopper located in: "..tostring(Local.SelfPath))
		end
	end)

	------------------------------------------------------------------------------------

	if Local.ConfigFile then
		Local.Config = Local.ConfigFile:read()
		Local.ConfigFile:close()
		if Local.Config ~= nil then
			Local.Config = string.ToTable(Local.Config)
			if Local.Config["binfolder"] ~= nil then 
				local folder = Local.Config["binfolder"]
				if string.sub(folder,1,2) == " \"" then folder = string.sub(folder,3,-2) end
				io.write("Config file found. Binfolder set as \""..folder.."\"\nValidating...")
					local gmad = io.open(folder.."\\gmad.exe")
					local gmpublish = io.open(folder.."\\gmpublish.exe")
					if not gmad or not gmpublish then print("Can't find gmad.exe or gmpublish.exe") Local.ConfigFile = nil else
						io.write(" Files gmad.exe and gmpublish.exe found.\n")
						gmad:close()
						gmpublish:close()
						Local.Config = folder
				end
			else
				print("[LuaWorkshopper] Config file isn't valid. Erasing...")
				Local.ConfigFile = nil
			end
		else
			print("[LuaWorkshopper] Config file isn't valid. Erasing...")
			Local.ConfigFile = nil
		end
	end

	if not Local.ConfigFile then 
			Local.ConfigFile = io.open(Local.SelfPath.."lua_workshopper.cfg","w+")
			print("[LuaWorkshopper] No Config file found or not valid. You need to configure.\n")
			print(">>> >>> >>>\t\t\t<<< <<< <<<")
			print(">>> >>> >>>\t\t\t<<< <<< <<<")
			print(">>> >>> >>>\t\t\t<<< <<< <<<")
		repeat
			print("Please, give me \"steamapps/Garry's Mod/bin\" folder\n")
			local done = false
			local folder = io.read()
			if string.sub(folder,1,1) == "\"" then folder = string.sub(folder,2,-2) end
				print("[LuaWorkshopper] Finding gmad.exe and gmpublish.exe")
				local gmad = io.open(folder.."\\gmad.exe")
				local gmpublish = io.open(folder.."\\gmpublish.exe")
				if not gmad or not gmpublish then print("[LuaWorkshopper] Can't find gmad.exe or gmpublish.exe") else
					gmad:close()
					gmpublish:close()
					if Local.ConfigFile then
						Local.ConfigFile:write("binfolder= \""..folder.."\"")
						Local.ConfigFile:flush()
					else
						print("Warning! Config file won't be available if LuaWorkshopper is in protected directory. You'll need to configure it everytime. Or run LuaWorkshopper as Administrator for best experience or move LuaWorkshopper to unporotected direcotry such as Desktop.")
						print("\n")
					end
					done = true
			end
		until done 
		Local.Config = Local.ConfigFile:read()
		Local.ConfigFile:close()
	end

	function Local.Logo(b)
		if b then os.execute("cls") end
		print([[

|     _   \    / _  _|  _|_  _  _  _  _  _
|_|_|(_|   \/\/ (_)| |<_\| |(_)|_)|_)(/_| 
                               |  |       
Version 1.0

Type command on blinking
		]])
		if Local.GMAD and Local.LastExec == "gma" then
			Local.ParseGMAD()
		end
		if Local.GMPublish and Local.LastExec == "workshop create" then
			Local.OpenGMPublish()
		end
	end

	Local.Logo()
	print("[LuaWorkshopper] Current mode: filename input.")
	print("This mode require only file or folder name.")
	print("LuaWorkshopper will find files and folders in same folder where this file located")
	print("LuaWorkshopper located in: "..tostring(Local.SelfPath))
	Local.Exec("help")

	repeat
		io.write("Input: ")
		local input = io.read()
		if Local.Functions[input] then
			Local.Exec(input)
		else
			if input ~= "" and input ~= " " then print("[LuaWorkshopper] Unknown command: "..input) end
		end
	until false == true
end)
if not b then
	xpcall(function()
		local file = io.open(string.match(arg[0],"^(.*[/\\])[^/\\]-$").."lua_workshopper.log","a")
		file:write(err.."\n\n")
		file:close()
	end,function()
		os.execute("cls")
		print("LuaWorkshopper caught error.\n\nSeems like it's stored in protected directory.\nError will displayed here:\n\n\t"..err)
		print("\nPress enter to close program.\nFor best experience run LuaWorkshopper as Administrator or move LuaWorkshopper to unporotected direcotry such as Desktop.")
		io.read()
	end)
end
