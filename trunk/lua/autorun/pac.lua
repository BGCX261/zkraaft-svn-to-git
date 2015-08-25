if SERVER then
	include("pac/sv_core.lua")
	include("pac/sh_core.lua")
	AddCSLuaFile("pac/cl_core.lua")
	AddCSLuaFile("pac/cl_rendering.lua")
	AddCSLuaFile("pac/sh_core.lua")
	AddCSLuaFile("pac/cl_mctrl.lua")
	AddCSLuaFile("autorun/pac.lua")
else
	include("pac/cl_core.lua")
	include("pac/cl_mctrl.lua")
	include("pac/sh_core.lua")
	include("pac/cl_rendering.lua")
end