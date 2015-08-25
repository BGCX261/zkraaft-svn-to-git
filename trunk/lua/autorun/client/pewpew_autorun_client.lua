-- PewPew Autorun
-- Initialize variables
pewpew = {}

include("pewpew_weaponhandler.lua")

pewpew:LoadBullets()

-- If we got this far without errors, it's safe to assume the addon is installed.
pewpew.Installed = true