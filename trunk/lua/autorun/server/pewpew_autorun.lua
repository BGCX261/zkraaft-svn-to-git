-- PewPew Autorun
-- Initialize variables
pewpew = {}

include("pewpew_damagecontrol.lua")
include("pewpew_safezones.lua")
include("pewpew_convars.lua")
include("pewpew_weaponhandler.lua")
include("pewpew_damagelog.lua")
include("pewpew_deathnotice.lua")

AddCSLuaFile("pewpew_weaponhandler.lua")
pewpew:LoadBullets()

AddCSLuaFile("pewpew_damagecontrol.lua")
AddCSLuaFile("autorun/client/pewpew_autorun_client.lua")
AddCSLuaFile("autorun/client/pewpew_menu.lua")


-- Compability
AddCSLuaFile("pewpew_gcombatcompability.lua")
include("pewpew_gcombatcompability.lua")

-- Tags
local tags = GetConVar( "sv_tags" ):GetString()
if (!string.find( tags, "PewPew" )) then
	RunConsoleCommand( "sv_tags", tags .. ",PewPew" )
end

-- If we got this far without errors, it's safe to assume the addon is installed.
pewpew.Installed = true