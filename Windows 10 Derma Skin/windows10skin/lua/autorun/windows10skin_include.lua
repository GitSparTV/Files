-- http://wiki.garrysmod.com/page/Derma_Skin_Creation
if SERVER then
	AddCSLuaFile("skins/windows10.lua")
else
	include("skins/windows10.lua")
	hook.Add("ForceDermaSkin","Windows10SkinForce",function()
		return "Windows" -- This will paint all Derma objects to new skin
	end)
end