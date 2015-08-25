-- Pewpew ConVars
-- These functions add the admin only console commands
------------------------------------------------------------------------------------------------------------

-- Default Values
pewpew.Damage = true
pewpew.Firing = true
pewpew.Numpads = true
pewpew.DamageMul = 1
pewpew.CoreDamageMul = 1
pewpew.CoreDamageOnly = false
pewpew.RepairToolHeal = 75
pewpew.RepairToolHealCores = 200
pewpew.EnergyUsage = false
pewpew.PropProtDamage = false
pewpew.WeaponDesigner = false

if (CAF and CAF.GetAddon("Resource Distribution") and CAF.GetAddon("Life Support")) then
	pewpew.EnergyUsage = true
end

local function JoinCmds( ply )
	-- 1/0
	local val = "0"
	if (pewpew.Damage) then val = "1" end
	ply:ConCommand( "pewpew_cltgldamage " .. val )
	local val = "0"
	if (pewpew.Firing) then val = "1" end
	ply:ConCommand( "pewpew_cltglfiring " .. val )
	local val = "0"
	if (pewpew.Numpads) then val = "1" end
	ply:ConCommand( "pewpew_cltglnumpads " .. val )
	local val = "0"
	if (pewpew.EnergyUsage) then val = "1" end
	ply:ConCommand( "pewpew_cltglenergyusage " .. val )
	local val = "0"
	if (pewpew.CoreDamageOnly) then val = "1" end
	ply:ConCommand( "pewpew_cltglcoredamageonly " .. val )
	local val = "0"
	if (pewpew.DamageLogSend) then val = "1" end
	ply:ConCommand( "pewpew_cltgldamagelog " .. val )
	local val = "0"
	if (pewpew.PropProtDamage) then val = "1" end
	ply:ConCommand( "pewpew_cltglppdamage " .. val )
	
	-- Vars
	ply:ConCommand( "pewpew_cldmgmul " .. pewpew.DamageMul )
	ply:ConCommand( "pewpew_cldmgcoremul " .. pewpew.CoreDamageMul )
	ply:ConCommand( "pewpew_clrepairtoolheal " .. pewpew.RepairToolHeal )
	ply:ConCommand( "pewpew_clrepairtoolhealcores " .. pewpew.RepairToolHealCores )
end
hook.Add("PlayerInitialSpawn","PewPew_Convars_at_spawn",JoinCmds)
		
-- Toggle Damage
local function ToggleDamage( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (!arg[1]) then return end
		local bool = false
		if (tonumber(arg[1]) != 0) then bool = true end
		local OldSetting = pewpew.Damage
		pewpew.Damage = bool
		if (OldSetting != pewpew.Damage) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed PewPew Damage and it is now "
			local onoff = "ON!"
			local cmd = "1"
			if (pewpew.Damage == false) then onoff = "OFF!" cmd = "0" end
			for _,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. onoff )
				v:ConCommand( "pewpew_cltgldamage " .. cmd )
			end
		end
	end
end
concommand.Add("PewPew_ToggleDamage", ToggleDamage)

-- Toggle Firing
local function ToggleFiring( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (!arg[1]) then return end
		local bool = false
		if (tonumber(arg[1]) != 0) then bool = true end
		local OldSetting = pewpew.Firing
		pewpew.Firing = bool
		if (OldSetting != pewpew.Firing) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed PewPew Firing and it is now "
			local onoff = "ON!"
			local cmd = "1"
			if (pewpew.Firing == false) then onoff = "OFF!" cmd = "0" end
			for _,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. onoff )
				v:ConCommand( "pewpew_cltglfiring " .. cmd )
			end
		end
	end
end
concommand.Add("PewPew_ToggleFiring", ToggleFiring)

-- Toggle Numpads
local function ToggleNumpads( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (!arg[1]) then return end
		local bool = false
		if (tonumber(arg[1]) != 0) then bool = true end
		local OldSetting = pewpew.Numpads
		pewpew.Numpads = bool
		if (OldSetting != pewpew.Numpads) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed PewPew Numpads and they are now "
			local onoff = "ENABLED!"
			local cmd = "1"
			if (pewpew.Numpads == false) then onoff = "DISABLED!" cmd = "0" end
			for _,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. onoff )
				v:ConCommand( "pewpew_cltglnumpads " .. cmd )
			end
		end
	end
end
concommand.Add("PewPew_ToggleNumpads", ToggleNumpads)

-- Damage Multiplier
local function DamageMul( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if ( !arg[1] ) then return end
		local OldSetting = pewpew.DamageMul
		pewpew.DamageMul = math.max( arg[1], 0.01 )
		if (OldSetting != pewpew.DamageMul) then
			local name = "Console"
			local msg = " has changed the PewPew Damage Multiplier to "
			if (ply:IsValid()) then name = ply:Nick() end
			for _, v in pairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. pewpew.DamageMul)
				v:ConCommand( "pewpew_cldmgmul " .. tostring(pewpew.DamageMul) )
			end
		end
	end
end
concommand.Add("PewPew_DamageMul",DamageMul)

-- Damage Multiplier vs cores
local function CoreDamageMul( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if ( !arg[1] ) then return end
		local OldSetting = pewpew.CoreDamageMul
		pewpew.CoreDamageMul = math.max( arg[1], 0.01 )
		if (OldSetting != pewpew.CoreDamageMul) then
			local name = "Console"
			local msg = " has changed the PewPew Core Damage Multiplier to "
			if (ply:IsValid()) then name = ply:Nick() end
			for _, v in pairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. pewpew.CoreDamageMul)
				v:ConCommand( "pewpew_cldmgcoremul " .. tostring(pewpew.CoreDamageMul) )
			end
		end
	end
end
concommand.Add("PewPew_CoreDamageMul",CoreDamageMul)

-- Core Damage only
local function ToggleCoreDamageOnly( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (!arg[1]) then return end
		local bool = false
		if (tonumber(arg[1]) != 0) then bool = true end
		local OldSetting = pewpew.CoreDamageOnly
		pewpew.CoreDamageOnly = bool
		if (OldSetting != pewpew.CoreDamageOnly) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed PewPew Core Damage Only and it is now "
			local onoff = "ON!"
			local cmd = "1"
			if (pewpew.CoreDamageOnly == false) then onoff = "OFF!" cmd = "0" end
			for _,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. onoff )
				v:ConCommand( "pewpew_cltglcoredamageonly " .. cmd )
			end
		end
	end
end
concommand.Add("PewPew_ToggleCoreDamageOnly", ToggleCoreDamageOnly)

-- Repair tool rate
local function RepairToolHeal( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if ( !arg[1] ) then return end
		local OldSetting = pewpew.RepairToolHeal
		pewpew.RepairToolHeal = math.max( arg[1], 20 )
		if (OldSetting != pewpew.RepairToolHeal) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed the speed at which the Repair Tool heals to "
			for _, v in pairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. pewpew.RepairToolHeal)
				v:ConCommand( "pewpew_clrepairtoolheal " .. tostring(pewpew.RepairToolHeal) )
			end
		end
	end
end
concommand.Add("PewPew_RepairToolHeal",RepairToolHeal)

-- Repair tool rate vs cores
local function RepairToolHealCores( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if ( !arg[1] ) then return end
		local OldSetting = pewpew.RepairToolHealCores
		pewpew.RepairToolHealCores = math.max( arg[1], 20 )
		if (OldSetting != pewpew.RepairToolHealCores) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed the speed at which the Repair Tool heals cores to "
			for _, v in pairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. pewpew.RepairToolHealCores)
				v:ConCommand( "pewpew_clrepairtoolhealcores " .. tostring(pewpew.RepairToolHealCores) )
			end
		end
	end
end
concommand.Add("PewPew_RepairToolHealCores",RepairToolHealCores)

-- Toggle Life Support
local function ToggleEnergyUsage( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (CAF and CAF.GetAddon("Resource Distribution") and CAF.GetAddon("Life Support")) then
			if (!arg[1]) then return end
			local bool = false
			if (tonumber(arg[1]) != 0) then bool = true end
			local OldSetting = pewpew.EnergyUsage
			pewpew.EnergyUsage = bool
			if (OldSetting != pewpew.EnergyUsage) then
				local name = "Console"
				if (ply:IsValid()) then name = ply:Nick() end
				local msg = " has changed PewPew Energy Usage and it is now "
				local onoff = "ENABLED!"
				local cmd = "1"
				if (pewpew.EnergyUsage == false) then onoff = "DISABLED!" cmd = "0" end
				for _,v in ipairs( player.GetAll() ) do
					v:ChatPrint( "[PewPew] " .. name .. msg .. onoff )
					v:ConCommand( "pewpew_cltglenergyusage " .. cmd )
				end
			end
		elseif (arg[1] != "0") then
			local msg = "You cannot enable Energy Usage, because the server does not have the required addons (Spacebuild 3 & co.)!"
			ply:ChatPrint( "[PewPew] " .. msg )
		end
	end
end
concommand.Add("PewPew_ToggleEnergyUsage", ToggleEnergyUsage)

-- Toggle Prop Protection
local function TogglePP( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (CPPI) then
			if (!arg[1]) then return end
			local bool = false
			if (tonumber(arg[1]) != 0) then bool = true end
			local OldSetting = pewpew.PropProtDamage
			pewpew.PropProtDamage = bool
			if (OldSetting != pewpew.PropProtDamage) then
				local name = "Console"
				if (ply:IsValid()) then name = ply:Nick() end
				local msg = " has changed PewPew Prop Protection Damage and it is now "
				local onoff = "ENABLED!"
				local cmd = "1"
				if (pewpew.PropProtDamage == false) then onoff = "DISABLED!" cmd = "0" end
				for _,v in ipairs( player.GetAll() ) do
					v:ChatPrint( "[PewPew] " .. name .. msg .. onoff )
					v:ConCommand( "pewpew_cltglppdamage " .. cmd )
				end
			end
		elseif (arg[1] != "0") then
			local msg = "You cannot enable Prop Protection Damage, because the server does not have the required addon(s)!"
			ply:ChatPrint( "[PewPew] " .. msg )
		end
	end
end
concommand.Add("PewPew_TogglePP", TogglePP)

-- Weapon Designer
local function ToggleWeaponDesigner( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (!arg[1]) then return end
		local bool = false
		if (tonumber(arg[1]) != 0) then bool = true end
		local OldSetting = pewpew.WeaponDesigner
		pewpew.WeaponDesigner = bool
		if (OldSetting != pewpew.WeaponDesigner) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed PewPew Weapon Designer and it is now "
			local onoff = "ENABLED!"
			local cmd = "1"
			if (pewpew.WeaponDesigner == false) then onoff = "DISABLED!" cmd = "0" end
			for _,v in ipairs( player.GetAll() ) do
				v:ChatPrint( "[PewPew] " .. name .. msg .. onoff )
				v:ConCommand( "pewpew_cltglweapondesigner " .. cmd )
			end
		end
	end
end
concommand.Add("PewPew_ToggleWeaponDesigner", ToggleWeaponDesigner)