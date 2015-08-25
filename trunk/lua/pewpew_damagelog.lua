-- PewPew Damage Log
-- These functions take care of sending the information to the clients
-------------------------------------------------------------------------------------------------------------

if (!pewpew) then print("Fail.") return end
pewpew.LogStack = {}
pewpew.DamageLogSend = true

-- Add to log
function pewpew:DamageLogAdd( TargetEntity, Damage, DamageDealer )
	if (!Damage or Damage == 0) then return end
	if (!DamageDealer) then return end
	
	local DealerName
	if (DamageDealer.Owner) then 
		DealerName = DamageDealer.Owner:Nick() or "- Error -" 
	else
		DealerName = "- Error -"
	end
	
	local Weapon
	if (DamageDealer.Bullet) then
		Weapon = DamageDealer.Bullet.Name or "- Error -"
	else
		Weapon = "- Error -"
	end
	
	local VictimName
	if (CPPI) then
		if (TargetEntity:CPPIGetOwner()) then
			VictimName = TargetEntity:CPPIGetOwner():Nick() or "- Error -"
		else
			VictimName = "- Error -"
		end
	else
		VictimName = "- CPPI not installed -"
	end
	
	local DiedB = false
	if (!TargetEntity:IsValid() or self:GetHealth( TargetEntity ) < Damage) then
		DiedB = true
	end
	
	local Time = os.date( "%c", os.time() )
	
	if (#self.LogStack > 0) then
		if (self.LogStack[1] and self.LogStack[1][2] == TargetEntity:EntIndex()) then
			-- Time, EntID, Damage, Weapon, DealerName, VictimName, DiedB
			self.LogStack[1][1] = Time
			self.LogStack[1][3] = self.LogStack[1][3] + Damage
			self.LogStack[1][4] = Weapon
			self.LogStack[1][5] = DealerName
			self.LogStack[1][7] = DiedB
		else
			table.insert( self.LogStack, { Time, TargetEntity:EntIndex(), Damage, Weapon, DealerName, VictimName, DiedB } )
		end
	else
		table.insert( self.LogStack, { Time, TargetEntity:EntIndex(), Damage, Weapon, DealerName, VictimName, DiedB } )
	end
end

timer.Create( "PewPew_PopLogStack", 2.5, 0, function(self)
	if (table.Count(self.LogStack) > 0) then
		self:PopLogStack()
	end
end, pewpew)

-- Send the log
require("datastream")
function pewpew:PopLogStack()
	if (!pewpew.DamageLogSend) then return end
	if (table.Count(self.LogStack) > 0) then
		datastream.StreamToClients( player.GetAll(), "PewPew_Admin_Tool_SendLog", self.LogStack )
		--[[ Old broken umsg
		umsg.Start("PewPew_Admin_Tool_SendLog_Umsg")
			umsg.Short(table.Count(self.LogStack))
			for k,v in pairs( self.LogStack ) do
				local Time = v[1]
				local ID = v[2]
				local Dmg = v[3]
				local Wpn = v[4]
				local DealerName = v[5]
				local VictimName = v[6]
				local DiedB = v[7]
				umsg.String(Time)
				umsg.Short(ID)
				umsg.Long(math.Round(Dmg))
				umsg.String(Wpn)
				umsg.String(DealerName)
				umsg.String(VictimName)
				umsg.Bool(DiedB)
			end
		umsg.End()
		]]
		self.LogStack = {}
	end
end

-- Console command
local function ToggleDamageLog( ply, command, arg )
	if ( (ply:IsValid() and ply:IsAdmin()) or !ply:IsValid() ) then
		if (!arg[1]) then return end
		local bool = false
		if (tonumber(arg[1]) != 0) then bool = true end
		local OldSetting = pewpew.DamageLogSend
		pewpew.DamageLogSend = bool
		if (OldSetting != pewpew.DamageLogSend) then
			local name = "Console"
			if (ply:IsValid()) then name = ply:Nick() end
			local msg = " has changed Damage Log Sending and it is now "
			if (pewpew.DamageLogSend) then
				for _, v in pairs( player.GetAll() ) do
					v:ChatPrint( "[PewPew] " .. name .. msg .. "ON!")
					v:ConCommand("pewpew_cltgldamagelog","1")
				end
			else
				for _, v in pairs( player.GetAll() ) do
					v:ChatPrint( "[PewPew] " .. name .. msg .. "OFF!")
					v:ConCommand("pewpew_cltgldamagelog","0")
				end
			end
		end
	end
end
concommand.Add("PewPew_ToggleDamageLogSending", ToggleDamageLog)
