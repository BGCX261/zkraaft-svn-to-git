AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   
	if (CAF and CAF.GetAddon("Resource Distribution") and CAF.GetAddon("Life Support")) then
		self.BaseClass.Initialize(self)
		CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(self.Entity)
	end
	self.Entity:PhysicsInit( SOLID_VPHYSICS )  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )      

	if (!self.Bullet) then return end
	
	-- Adjust wire inputs
	if (self.Bullet.CustomInputs) then
		self.Inputs = WireLib.CreateInputs( self.Entity, self.Bullet.CustomInputs )
		self.InputsChanged = self.Bullet.Name
	else
		if (!self.InputsChanged) then
			self.Inputs = WireLib.CreateInputs( self.Entity, { "Fire", "Reload" } )
			self.InputsChanged = "default"
		end
	end
	
	-- Adjust wire outputs
	if (self.Bullet.CustomOutputs) then
		self.Outputs = WireLib.CreateOutputs( self.Entity, self.Bullet.CustomOutputs )
		self.OutputsChanged = self.Bullet.Name
	else
		if (!self.OutputsChanged) then
			self.Outputs = WireLib.CreateOutputs( self.Entity, { "Can Fire", "Ammo", "Last Fired [ENTITY]", "Last Fired EntID", "Cannon [ENTITY]" } )
			self.OutputsChanged = "default"
			WireLib.TriggerOutput( self.Entity, "Ammo", self.Ammo )
			WireLib.TriggerOutput( self.Entity, "Can Fire", 1 )
			WireLib.TriggerOutput( self.Entity, "Cannon", self.Entity )
		end
	end
	
	self.CanFire = true
	self.LastFired = 0
	self.Firing = false
	self.SoundTimer = 0
	if (!self.Direction) then self.Direction = 1 end
end

function ENT:SetOptions( BULLET, ply, firekey, reloadkey, FireDirection )
 	self.Bullet = table.Copy(BULLET)
	self.Owner = ply
	self.Direction = tonumber(FireDirection) or 1
	
	-- No ammo at all?
	if (!self.Ammo) then
		self.Ammo = self.Bullet.Ammo
	end
	
	-- Too much ammo?
	if (self.Ammo) then
		if (self.Ammo > self.Bullet.Ammo) then self.Ammo = self.Bullet.Ammo end
	end
	
	-- Remove old numpads (if there are any)
	if (self.FireDown) then
		numpad.Remove( self.FireDown )
	end
	if (self.FireUp) then
		numpad.Remove( self.FireUp )
	end
	if (self.ReloadDown) then
		numpad.Remove( self.ReloadDown )
	end
	if (self.ReloadUp) then
		numpad.Remove( self.ReloadUp )
	end
	
	-- Create new numpads
	if (firekey) then
		self.FireKey = firekey
		self.FireDown = numpad.OnDown( 	 ply, 	firekey, 	"PewPew_Cannon_Fire_On", 	self )
		self.FireUp = numpad.OnUp( 	 ply, 	firekey, 	"PewPew_Cannon_Fire_Off", 	self )
	end
	if (reloadkey) then
		self.ReloadKey = reloadkey
		self.ReloadDown = numpad.OnDown( 	 ply, 	reloadkey, 	"PewPew_Cannon_Reload_On", 	self )
		self.ReloadUp =	numpad.OnUp( 	 ply, 	reloadkey, 	"PewPew_Cannon_Reload_Off", 	self )
	end
	
	-- Adjust wire inputs
	if (self.Bullet.CustomInputs) then
		if (self.InputsChanged and self.InputsChanged != self.Bullet.Name) then
			self.Inputs = WireLib.AdjustInputs( self.Entity, self.Bullet.CustomInputs )
			self.InputsChanged = self.Bullet.Name
		end
	else
		if (self.InputsChanged and self.InputsChanged != "default") then
			self.Inputs = WireLib.AdjustInputs( self.Entity, { "Fire", "Reload" } )
			self.InputsChanged = "default"
		end
	end
	
	-- Adjust wire outputs
	if (self.Bullet.CustomOutputs) then
		if (self.OutputsChanged and self.OutputsChanged != self.Bullet.Name) then
			self.Outputs = WireLib.AdjustOutputs( self.Entity, self.Bullet.CustomOutputs )
			self.OutputsChanged = self.Bullet.Name
		end
	else
		if (self.OutputsChanged and self.OutputsChanged != "default") then
			self.Outputs = WireLib.AdjustOutputs( self.Entity, { "Can Fire", "Ammo", "Last Fired [ENTITY]", "Last Fired EntID" } )
			self.OutputsChanged = "default"
		end
	end
	
	self:SetNWString( "BulletName", self.Bullet.Name )
	self:SetNWString( "PewPew_OwnerName", ply:Nick() )
end

function ENT:FireBullet()
	-- Is shooting disabled?
	if (!pewpew.Firing) then return end
	
	-- Is energy usage enabled?
	if (pewpew.EnergyUsage) then
		local amount = self:GetResourceAmount("energy")
		local req = self.Bullet.EnergyPerShot or 0
		if (amount < req and req > 0) then return end
		self:ConsumeResource("energy",req)
	end
	
	if (self.Bullet.FireOverride) then
		-- Allows you to override the fire function
		self.Bullet:Fire( self )
	else
		-- Create Bullet
		local ent = ents.Create( "pewpew_base_bullet" )
		if (!ent or !ent:IsValid()) then return end
		
		-- Set Model
		ent:SetModel( self.Bullet.Model )
		-- Set used bullet
		ent:SetOptions( self.Bullet, self, self.Owner )
		
		-- Calculate initial position of bullet
		local Dir, Pos = pewpew:GetFireDirection( self.Direction, self, ent )
	
		ent:SetPos( Pos )
		-- Add random angle offset
		local num = self.Bullet.Spread or 0
		local randomang = Angle(0,0,0)
		if (num) then 
			randomang = Angle( math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num) )
			Dir:Rotate(randomang)
		end	
		ent:SetAngles( Dir:Angle() + Angle(90,0,0) )
		-- Spawn
		ent:Spawn()
		ent:Activate()
		
		-- Recoil
		if (self.Bullet.RecoilForce and self.Bullet.RecoilForce > 0) then
			self.Entity:GetPhysicsObject():AddVelocity( Dir * -self.Bullet.RecoilForce )
		end
		
		-- Sound
 		if (self.Bullet.FireSound) then
			local soundpath = ""
			if (table.Count(self.Bullet.FireSound) > 1) then
				soundpath = table.Random(self.Bullet.FireSound)
			else
				soundpath = self.Bullet.FireSound[1]
			end
			self:EmitSound( soundpath )
		end
		
		-- Effect
		if (self.Bullet.FireEffect) then
			local effectdata = EffectData()
			effectdata:SetOrigin( Pos )
			effectdata:SetNormal( Dir )
			util.Effect( self.Bullet.FireEffect, effectdata )
		end
		
		if (self.Bullet.Ammo and self.Bullet.Ammo > 0) then
			self.Ammo = self.Ammo - 1
			WireLib.TriggerOutput( self.Entity, "Ammo", self.Ammo )
		end
		WireLib.TriggerOutput( self.Entity, "Last Fired", ent or nil )
		WireLib.TriggerOutput( self.Entity, "Last Fired EntID", ent:EntIndex() or 0 )
	end
end

function ENT:Think()
	if (!self.Bullet) then return end
	if (self.Bullet.CannonThinkOverride) then
		return self.Bullet:CannonThink( self )
	else
		if (CurTime() - self.LastFired > self.Bullet.Reloadtime and self.CanFire == false) then -- if you can fire
			if (self.Ammo <= 0 and self.Bullet.Ammo > 0) then -- check for ammo
				-- if we don't have any ammo left...
				if (self.Firing) then -- if you are holding down fire
					-- Sound
					if (self.Bullet.EmptyMagSound and self.SoundTimer and CurTime() > self.SoundTimer) then
						self.SoundTimer = CurTime() + self.Bullet.Reloadtime
						local soundpath = ""
						if (table.Count(self.Bullet.EmptyMagSound) > 1) then
							soundpath = table.Random(self.Bullet.EmptyMagSound)
						else
							soundpath = self.Bullet.EmptyMagSound[1]
						end
						self:EmitSound( soundpath )
					end			
				end
				self.CanFire = false
				WireLib.TriggerOutput( self.Entity, "Can Fire", 0)
				if (CurTime() - self.LastFired > self.Bullet.AmmoReloadtime) then -- check ammo reloadtime
					self.Ammo = self.Bullet.Ammo
					WireLib.TriggerOutput( self.Entity, "Ammo", self.Ammo )
					self.CanFire = true
					if (self.Firing) then 
						self.LastFired = CurTime()
						self.CanFire = false
						self:FireBullet()
					else
						WireLib.TriggerOutput( self.Entity, "Can Fire", 1)
					end
				end
			else
				-- if we DO have ammo left
				self.CanFire = true
				if (self.Firing) then
					self.LastFired = CurTime()
					self.CanFire = false
					self:FireBullet()
				else
					WireLib.TriggerOutput( self.Entity, "Can Fire", 1)
				end
			end
		end
		if (self.Bullet.Reloadtime and self.Bullet.Reloadtime < 0.5) then
			-- Run more often!
			self.Entity:NextThink( CurTime() )
			return true
		end
	end
end

function ENT:PhysicsCollide( data, physobj )
	if (self.Bullet.CannonPhysicsCollideOverride) then
		self.Bullet.CannonPhysicsCollideFunc( self, data, physobj )
	end
end

function ENT:Touch( Ent )
	if (self.Bullet.CannonTouchOverride) then
		self.Bullet.CannonTouchFunc( self, Ent )
	end
end

function ENT:InputChange( name, value )
	if (name == "Fire") then
		if (value != 0) then
			self.Firing = true
		else
			self.Firing = false
		end
		if (value != 0 and self.CanFire == true) then
			self.LastFired = CurTime()
			self.CanFire = false
			WireLib.TriggerOutput(self.Entity, "Can Fire", 0)
			self:FireBullet()
		end
	elseif (name == "Reload") then
		if (self.Ammo and self.Ammo > 0 and self.Ammo < self.Bullet.Ammo) then
			if (self.Bullet.Ammo and self.Bullet.Ammo > 0 and self.Bullet.AmmoReloadtime and self.Bullet.AmmoReloadtime > 0) then
				if (value != 0) then
					if (self.Ammo and self.Ammo > 0) then
						self.Ammo = 0
						self.LastFired = CurTime() + self.Bullet.Reloadtime
						self.CanFire = false					
						WireLib.TriggerOutput( self.Entity, "Can Fire", 0)
						WireLib.TriggerOutput( self.Entity, "Ammo", 0 )
					end
				end
			end
		end
	end
end

-- Wiring
function ENT:TriggerInput(iname, value)
	if (self.Bullet.WireInputOverride) then
		self.Bullet:WireInput( self, iname, value )
	else
		self:InputChange( iname, value )
	end
end

-- Numpad
local function NumpadOn( ply, self )
	if (!pewpew.Numpads) then return end
	if (!self or !self:IsValid()) then return end
	if (self.Bullet.WireInputOverride) then
		self.Bullet:WireInput( self, "Fire", 1 )
	else
		self:InputChange( "Fire", 1 )
	end
end

local function NumpadOff( ply, self )
	if (!pewpew.Numpads) then return end
	if (!self or !self:IsValid()) then return end
	if (self.Bullet.WireInputOverride) then
		self.Bullet:WireInput( self, "Fire", 0 )
	else
		self:InputChange( "Fire", 0 )
	end
end

local function NumpadReloadOn( ply, self )
	if (!pewpew.Numpads) then return end
	if (!self or !self:IsValid()) then return end
	if (self.Bullet.WireInputOverride) then
		self.Bullet:WireInput( self, "Reload", 1 )
	else
		self:InputChange( "Reload", 1 )
	end
end

local function NumpadReloadOff( ply, self )
	if (!pewpew.Numpads) then return end
	if (!self or !self:IsValid()) then return end
	if (self.Bullet.WireInputOverride) then
		self.Bullet:WireInput( self, "Reload", 0 )
	else
		self:InputChange( "Reload", 0 )
	end
end

numpad.Register( "PewPew_Cannon_Fire_On", NumpadOn )
numpad.Register( "PewPew_Cannon_Fire_Off", NumpadOff )
numpad.Register( "PewPew_Cannon_Reload_On", NumpadReloadOn )
numpad.Register( "PewPew_Cannon_Reload_Off", NumpadReloadOff )

-- Open the use menu
function ENT:Use( User, caller )
	if (!self.UseDelay) then self.UseDelay = 0 end
	if (!self.Using) then self.Using = false end
	
	-- Was it a long time ago?
	if (self.Using and self.UseDelay + 1 < CurTime()) then
		self.Using = false
	end
	
	-- Check the delay
	if (self.UseDelay < CurTime()) then
		-- If the player is not holding use yet
		if (!self.Using) then
			self.UseDelay = CurTime() + 2
			self.Using = true
			User:ChatPrint("Hold down your use key for 2 seconds to see info about this PewPew Weapon.")
		else -- if the player has held use for 2 seconds
			self.UseDelay = CurTime() + 1
			self.Using = false
			User:ConCommand("PewPew_UseMenu " .. self.Bullet.Name)
		end
	end
end

-------------------------
-- Dupe support! Thanks to Free Fall for helping
function ENT:DupeInfoTable()
	local ret = {}
	ret.BulletName = self.Bullet.Name
	ret.FireKey = self.FireKey
	ret.ReloadKey = self.ReloadKey
	ret.Direction = self.Direction
	local phys = self.Entity:GetPhysicsObject()
	if (phys) then
		ret.Mass = phys:GetMass()
	end
	return ret
end

function ENT:DupeSpawn( ply, ent, info )
	if ( !ply:CheckLimit( "pewpew" ) ) then 
		ent:Remove()
		return false
	end
	if (info.pewpewInfo) then
		local bullet = pewpew:GetBullet( info.pewpewInfo.BulletName )
		if (bullet) then
			if (bullet.AdminOnly and !ply:IsAdmin()) then 
				ply:ChatPrint("[PewPew] You must be an admin to spawn this PewPew weapon.")
				ent:Remove()
				return false
			end
			if (bullet.SuperAdminOnly and !ply:IsSuperAdmin()) then
				ply:ChatPrint("[PewPew] You must be a super admin to spawn this PewPew weapon.")
				ent:Remove()
				return false
			end
		else
			local blt = {
				Name = info.pewpewInfo.BulletName,
				Reloadtime = 2,
				Ammo = 0,
				AmmoReloadtime = 0,
				FireOverride = true
			}
			function blt:Fire(self) 
				self.Owner:ChatPrint("[Pewpew] This server does not have a bullet named '" .. info.pewpewInfo.BulletName .. "'.\nIn order to fire, you must update this cannon with a valid bullet.")
				self.Owner:ChatPrint("You may also leave it like this, and it might work on other servers (which have this bullet) after adv duplicating and uploading it to that server.")
			end
			ply:ChatPrint("[Pewpew] This server does not have a bullet named '" .. info.pewpewInfo.BulletName .. "'.\nIn order to fire, you must update this cannon with a valid bullet.")
			ply:ChatPrint("You may also leave it like this, and it might work on other servers (which have this bullet) after adv duplicating and uploading it to that server.\n--------------------")
			bullet = blt
		end
		self:SetOptions( bullet, ply, info.pewpewInfo.FireKey or "1", info.pewpewInfo.ReloadKey or "2", info.pewpewInfo.Direction )
		self:Initialize()
	end
	local phys = ent:GetPhysicsObject()
	if (phys) then
		if (info.pewpewInfo.Mass) then
			phys:SetMass(info.pewpewInfo.Mass)
		end
	end
	ply:AddCount("pewpew",ent)
end

-------------------------
-- Regular dupe functions
function ENT:BuildDupeInfo()
	local info = self.BaseClass.BuildDupeInfo(self) or {}
	info.pewpewInfo = self:DupeInfoTable()
	return info
end

function ENT:ApplyDupeInfo( ply, ent, info, GetEntByID )
	self:DupeSpawn( ply, ent, info )
	self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID )
end

-------------------------
-- SB3 dupe functions

if (CAF and CAF.GetAddon("Resource Distribution") and CAF.GetAddon("Life Support")) then
	function ENT:PreEntityCopy()
		self.BaseClass.PreEntityCopy(self) --use this if you have to use PreEntityCopy
		local RD = CAF.GetAddon("Resource Distribution")
		RD.BuildDupeInfo(self.Entity)
		if WireLib then
			local DupeInfo = WireLib.BuildDupeInfo(self.Entity)
			DupeInfo.pewpewInfo = self:DupeInfoTable()
			if DupeInfo then
				duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
			end
		end
	end

	function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
		self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities ) --use this if you have to use PostEntityPaste
		local RD = CAF.GetAddon("Resource Distribution")
		RD.ApplyDupeInfo(Ent, CreatedEntities)
		if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
			local info = Ent.EntityMods.WireDupeInfo
			WireLib.ApplyDupeInfo(Player, Ent, info, function(id) return CreatedEntities[id] end)
			self:DupeSpawn( Player, Ent, info )
		end
	end
end