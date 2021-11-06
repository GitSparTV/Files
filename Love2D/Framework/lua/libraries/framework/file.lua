file = {}
file.Cache = {}

file.Append = love.filesystem.append
file.GetSymlinksEnabled = love.filesystem.areSymlinksEnabled
file.CreateDir = love.filesystem.createDirectory
FILE_APPDATA = love.filesystem.getAppdataDirectory()
file.GetPackageCPath = love.filesystem.getCRequirePath
file.Find = love.filesystem.getDirectoryItems
file.GetAppID = love.filesystem.getIdentity
file.GetInfo = love.filesystem.getInfo
file.GetRealDir = love.filesystem.getRealDirectory
file.GetPackagePath = love.filesystem.getRequirePath
FILE_STORAGE = love.filesystem.getSaveDirectory()
FILE_APP = love.filesystem.getSource()
FILE_BASE = love.filesystem.getSourceBaseDirectory()
FILE_USER = love.filesystem.getUserDirectory()
FILE_EXE = love.filesystem.getWorkingDirectory()
file.IsFused = love.filesystem.isFused
file.Lines = love.filesystem.lines
file.LoadLua = love.filesystem.load
file.Mount = love.filesystem.mount
file.Open = love.filesystem.newFile
file.OpenD = love.filesystem.newFileData
file.Read = love.filesystem.read
file.Remove = love.filesystem.remove
file.SetPackageCData = love.filesystem.setCRequirePath
file.SetAppID = love.filesystem.setIdentity
file.SetPackageData = love.filesystem.setRequirePath
	file.SetSource = love.filesystem.setSource
file.SetSymlinksEnabled = love.filesystem.setSymlinksEnabled
file.UnMount = love.filesystem.unmount
file.Write = love.filesystem.write

function file.IsDir(path)
	return file.Cache == love.filesystem.getInfo(path, "directory", file.Cache)
end

function file.IsFile(path)
	return file.Cache == love.filesystem.getInfo(path, "file", file.Cache)
end

function file.IsSymlink(path)
	return file.Cache == love.filesystem.getInfo(path, "symlink", file.Cache)
end

function file.IsDevice(path)
	return file.Cache == love.filesystem.getInfo(path, "other", file.Cache)
end

function file.Exists(path)
	return file.Cache == love.filesystem.getInfo(path, file.Cache)
end

function file.Time(path)
	local info = love.filesystem.getInfo(path, file.Cache)
	if not info then return end

	return info.modtime
end

function file.Size(path)
	local info = love.filesystem.getInfo(path, file.Cache)
	if not info then return end

	return info.size
end

function file.Type(path)
	local info = love.filesystem.getInfo(path, file.Cache)
	if not info then return end

	return info.type
end

function file.IsInAppFolder(path)
	return file.GetRealDir(path) == FILE_APP
end

function file.IsInDataFolder(path)
	return file.GetRealDir(path) == FILE_STORAGE
end

--[[
FILE_APPDATA: C:/Users/*User*/AppData/Roaming
FILE_STORAGE: C:/Users/*User*/AppData/Roaming/LOVE/SparFramework
FILE_APP: C:/Program Files/LOVE/game
FILE_BASE: C:/Program Files/LOVE
FILE_USER: C:\Users\*User*\
FILE_EXE: C:/Program Files/LOVE
]]