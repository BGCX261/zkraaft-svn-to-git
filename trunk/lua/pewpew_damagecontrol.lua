-- Pewpew Damage Control
-- These functions take care of damage
------------------------------------------------------------------------------------------------------------

-- Entities in the Never Ever hit list will NEVER EVER take damage by PewPew weaponry.
pewpew.NeverEverList = { "pewpew_base_bullet", "gmod_ghost" }
-- Entity types in the blacklist will deal their damage to the first non-blacklisted entity they are constrained to. If they are not constrained to one, they take the damage themselves
pewpew.DamageBlacklist = { "gmod_wire" }
-- Entity types in the whitelist will ALWAYS be harmed by PewPew weaponry, even if they are in the blacklist as well.
pewpew.DamageWhitelist = { "gmod_wire_turret", "gmod_wire_forcer", "gmod_wire_grabber" }

------------------------------------------------------------------------------------------------------------

-- Blast Damage (A normal explosion)  (The damage formula is "clamp(Damage - (distance * RangeDamageMul), 0, Damage)")
function pewpew:BlastDamage( Position, Radius, Damage, RangeDamageMul, IgnoreEnt, DamageDealer )
		if (!self.Damage) then return end
	if (!Radius or Radius <= 0) then return end
	if (!Damage or Damage <= 0) then return end
	local targets = ents.FindInSphere( Position, Radius )
	if (!targets or table.Count(targets) == 0) then return end
	local DamagedProps = {}
	local n = 0
	for _, ent in ipairs( targets ) do
		if (self:CheckValid( ent )) then
			if (IgnoreEnt) then
				if (ent != IgnoreEnt) then
					n = n + 1
					DamagedProps[n] = ent
					--table.insert( DamagedProps, ent )
				end
			else
				n = n + 1
				DamagedProps[n] = ent
				--table.insert( DamagedProps, ent )
			end
		end
	end
	
	for _, ent in ipairs( DamagedProps ) do
		local Distance = Position:Distance( ent:GetPos() )
		local Dmg = math.Clamp( Damage - (Distance * RangeDamageMul), 0, Damage )
		Dmg = self:ReduceBlastDamage( Dmg, n )
		self:DealDamageBase( ent, Dmg, DamageDealer )
	end
end

-- Sub function. Used by BlastDamage
function pewpew:ReduceBlastDamage( Damage, NumberOfProps )
	if (!Damage or Damage == 0) then return 0 end
	local NrOfProps = math.max(NumberOfProps-5,2)
	Damage = Damage / NrOfProps
	return Damage
end

-- Point Damage - (Deals damage to 1 single entity)
function pewpew:PointDamage( TargetEntity, Damage, DamageDealer )
	if (!self.Damage) then return end
	if (TargetEntity:IsPlayer()) then
		if (DamageDealer and DamageDealer:IsValid()) then
			TargetEntity:TakeDamage( Damage, DamageDealer )
		end
	else
		self:DealDamageBase( TargetEntity, Damage, DamageDealer )
	end
end

-- Slice damage - (Deals damage to a number of entities in a line. It is stopped by the world)
function pewpew:SliceDamage( StartPos, Direction, Damage, NumberOfSlices, MaxRange, ReducedDamagePerSlice, DamageDealer )
	-- First trace
	local tr = {}
	tr.start = StartPos
	tr.endpos = StartPos + Direction * MaxRange
	local trace = util.TraceLine( tr )
	local Hit = trace.Hit
	local HitWorld = trace.HitWorld
	local HitPos = trace.HitPos
	local HitEnt = trace.Entity
	
	-- Check dmg
	if (!self.Damage) then
		if (Hit) then
			return HitPos
		else
			return StartPos + Direction * MaxRange
		end
	end
	
	local ret = HitPos
	for I=1, NumberOfSlices do
		if (HitEnt and HitEnt:IsValid()) then -- if the trace hit an entity
			if (StartPos:Distance(HitPos) > MaxRange) then -- check distance
				return StartPos + Direction * MaxRange
			else
				if (HitEnt:IsPlayer()) then
					HitEnt:TakeDamage( Damage, DamageDealer ) -- deal damage to players
				elseif (self:CheckValid( HitEnt )) then
					self:DealDamageBase( HitEnt, Damage, DamageDealer ) -- Deal damage to entities
				end
				-- Reduce damage after hit
				if (ReducedDamagePerSlice != 0) then
					Damage = Damage - ReducedDamagePerSlice
					if (Damage <= 0) then return HitPos end
				end
				
				-- new trace
				local tr = {}
				tr.start = HitPos
				tr.endpos = HitPos + Direction * MaxRange
				tr.filter = HitEnt
				ret = HitPos
				local trace = util.TraceLine( tr )
				Hit = trace.Hit
				HitWorld = trace.HitWorld
				HitPos = trace.HitPos
				HitEnt = trace.Entity
			end
		elseif (HitWorld) then-- if the trace hit the world
			if (StartPos:Distance(HitPos) > MaxRange) then -- check distance
				return StartPos + Direction * MaxRange
			else
				return HitPos
			end
		elseif (!Hit) then -- if the trace hit nothing
			return StartPos + Direction * MaxRange
		end
	end
	return ret or HitPos or StartPos + Direction * MaxRange
end

-- EMPDamage - (Electro Magnetic Pulse. Disables all wiring within the radius for the duration)
pewpew.EMPAffected = {}

-- Override TriggerInput
local OriginalFunc = WireLib.TriggerInput
function WireLib.TriggerInput(ent, name, value, ...)
	-- My addition
	if (pewpew.EMPAffected[ent:EntIndex()] and pewpew.EMPAffected[ent:EntIndex()][1]) then  -- if it is affected
		if (CurTime() < pewpew.EMPAffected[ent:EntIndex()][2]) then -- if the time isn't up yet
			return
		else -- if the time is up
			pewpew.EMPAffected[ent:EntIndex()] = nil 
		end
	end
	
	OriginalFunc( ent, name, value, ... )
end

-- Add to EMPAffected
function pewpew:EMPDamage( Position, Radius, Duration )
		-- Check damage
		if (!self.Damage) then return end
	-- Check for errors
	if (!Position or !Radius or !Duration) then return end
	
	-- Find all entities in the radius
	local ents = ents.FindInSphere( Position, Radius )
	
	-- Loop through all found entities
	for _, ent in pairs(ents) do
		if (ent.TriggerInput) then
			if (!self.EMPAffected[ent:EntIndex()]) then self.EMPAffected[ent:EntIndex()] = {} end
			if (self.EMPAffected[ent:EntIndex()][1]) then -- if it is already affected
				self.EMPAffected[ent:EntIndex()][2] = CurTime() + Duration -- edit the duration
			else
				self.EMPAffected[ent:EntIndex()][1] = true -- affect it
				self.EMPAffected[ent:EntIndex()][2] = CurTime() + Duration -- set duration
			end
		end
	end
end

-- Fire Damage (Damages an entity over time) (DO NOT USE THIS YET.)
function pewpew:FireDamage( TargetEntity, DPS, Duration )
		-- Check damage
		if (!self.Damage) then return end
	-- Check for errors
	if (!TargetEntity or !self:CheckValid(TargetEntity) or !DPS or !Duration) then return end
	
	-- Effect
	TargetEntity:Ignite( Duration )
	
	-- Initial damage
	self:DealDamageBase( TargetEntity, DPS/10 )
	
	-- Start a timer
	local timername = "pewpew_firedamage_"..TargetEntity:EntIndex()..CurTime()
	timer.Create( timername, 0.1, Duration*10, function( TargetEntity, DPS, timername ) 
		-- Damage
		pewpew:DealDamageBase( TargetEntity, DPS/10 )
		-- Auto remove timer if dead
		if (!TargetEntity or !TargetEntity:IsValid()) then timer.Remove( timername ) end
	end, TargetEntity, DPS, timername )
end

-- Defense Damage (Used to destroy PewPew bullets. Each PewPew Bullet has 100 health.)
function pewpew:DefenseDamage( TargetEntity, Damage )
	-- Check for errors
	if (!TargetEntity or TargetEntity:GetClass() != "pewpew_base_bullet" or !Damage or Damage == 0 or !TargetEntity.Bullet) then return end
	-- Does it have health?
	if (!TargetEntity.pewpewHealth) then TargetEntity.pewpewHealth = 100 end
	
	-- Damage
	TargetEntity.pewpewHealth = TargetEntity.pewpewHealth - Damage
	-- Did it die?
	if (TargetEntity.pewpewHealth <= 0) then
		if (TargetEntity.Bullet.ExplodeAfterDeath and TargetEntity.Bullet.ExplodeAfterDeath == true) then
			TargetEntity:Explode()
		else
			TargetEntity:Remove()
		end
	end
end

------------------------------------------------------------------------------------------------------------
-- Base Code

-- Base code for dealing damage
function pewpew:DealDamageBase( TargetEntity, Damage, DamageDealer )
		if (!self.Damage) then return end
	-- Check for errors
	if (!Damage or Damage == 0) then return end
	if (!self:CheckValid( TargetEntity )) then return end
	-- Check if allowed
	if (self:FindSafeZone( TargetEntity:GetPos() )) then return end
	if (!self:CheckNeverEverList( TargetEntity )) then return end
	if (!self:CheckAllowed( TargetEntity )) then
		local temp = constraint.GetAllConstrainedEntities( TargetEntity )
		local OldEnt = TargetEntity
		for _, ent in pairs( temp ) do
			if (self:CheckAllowed( ent )) then
				TargetEntity = ent
				break
			end
		end
	end
	Damage = Damage * self.DamageMul
	if (!TargetEntity.pewpewHealth) then
		self:SetHealth( TargetEntity )
	end
	-- Check if the entity has too much health
	self:ReduceHealth( TargetEntity )
	-- Check if the entity has a core
	if (TargetEntity.pewpew.Core and self:CheckValid(TargetEntity.pewpew.Core)) then
		self:DamageCore( TargetEntity.pewpew.Core, Damage )
		return
	end
	if (self.CoreDamageOnly) then return end
	
	-- If Prop Protection Damage is on, only deal damage if the owner of the damaged entity has the owner of the weapon in their PP friends list
	if (self.PropProtDamage) then
		local TargetEntityOwner = TargetEntity:CPPIGetOwner()
		local Friends = TargetEntityOwner:CPPIGetFriends()
		local WeaponOwner = DamageDealer.Owner
		if (!TargetEntityOwner or !Friends or !WeaponOwner) then print("Prop Prot Damage error!") return end
		local Found = false
		if (TargetEntityOwner == WeaponOwner) then 
			Found = true
		else
			for k,v in pairs( Friends ) do
				if (v == WeaponOwner) then
					Found = true
					break
				end
			end
		end
		if (!Found) then return end
	end
	
	-- Deal damage
	TargetEntity.pewpewHealth = TargetEntity.pewpewHealth - math.abs(Damage)
	TargetEntity:SetNWInt("pewpewHealth",TargetEntity.pewpewHealth)
	self:CheckIfDead( TargetEntity )
	
	-- Damage Log
	pewpew:DamageLogAdd( TargetEntity, Damage, DamageDealer )
end



------------------------------------------------------------------------------------------------------------
-- Core

-- Dealing damage to cores
function pewpew:DamageCore( ent, Damage )
	if (!self:CheckValid( ent )) then return end
	if (!ent.pewpew) then ent.pewpew = {} end
	if (ent:GetClass() != "pewpew_core") then return end
	ent.pewpew.CoreHealth = ent.pewpew.CoreHealth - math.abs(Damage) * self.CoreDamageMul
	ent:SetNWInt("pewpewHealth",ent.pewpew.CoreHealth)
	-- Wire Output
	WireLib.TriggerOutput( ent, "Health", ent.pewpew.CoreHealth or 0 )
	self:CheckIfDeadCore( ent )
end

-- Repairs the entity by the set amount
function pewpew:RepairCoreHealth( ent, amount )
	-- Check for errors
	if (!self:CheckValid( ent )) then return end
	if (!ent.pewpew) then ent.pewpew = {} end
	if (ent:GetClass() != "pewpew_core") then return end
	if (!ent.pewpew.CoreHealth or !ent.pewpew.CoreMaxHealth) then return end
	if (!amount or amount == 0) then return end
	-- Add health
	ent.pewpew.CoreHealth = math.Clamp(ent.pewpew.CoreHealth+math.abs(amount),0,ent.pewpew.CoreMaxHealth)
	ent:SetNWInt("pewpewHealth",ent.pewpew.CoreHealth or 0)
		-- Wire Output
	WireLib.TriggerOutput( ent, "Health", ent.pewpew.CoreHealth or 0 )
end

function pewpew:CheckIfDeadCore( ent )
	if (!ent.pewpew) then ent.pewpew = {} return end
	if (ent.pewpew.CoreHealth <= 0) then
		ent:RemoveAllProps()
	end	
end

------------------------------------------------------------------------------------------------------------
-- Health

-- Set the health of a spawned entity
function pewpew:SetHealth( ent )
	if (!self:CheckValid( ent )) then return end
	if (!ent.pewpew) then ent.pewpew = {} end
	local health = self:GetHealth( ent )
	local phys = ent:GetPhysicsObject()
	if (!phys:IsValid()) then return 0 end
	local mass = phys:GetMass() or 0
	ent.pewpewHealth = health
	ent.pewpewMaxMass = mass
	ent:SetNWInt("pewpewHealth",health)
	ent:SetNWInt("pewpewMaxHealth",health)
end

-- Repairs the entity by the set amount
function pewpew:RepairHealth( ent, amount )
	-- Check for errors
	if (!self:CheckValid( ent )) then return end
	if (!self:CheckAllowed( ent )) then return end
	if (!ent.pewpew) then ent.pewpew = {} end
	if (!ent.pewpewHealth or !ent.pewpewMaxMass) then return end
	if (!amount or amount == 0) then return end
	-- Get the max allowed health
	local maxhealth = self:GetMaxHealth( ent )
	-- Add health
	ent.pewpewHealth = math.Clamp(ent.pewpewHealth+math.abs(amount),0,maxhealth)
	-- Make the health changeable again with weight tool
	if (ent.pewpewHealth == maxhealth) then
		ent.pewpewHealth = nil
		ent.pewpewMaxMass = nil
	end
	ent:SetNWInt("pewpewHealth",ent.pewpewHealth or 0)
	ent:SetNWInt("pewpewMaxHealth",maxhealth or 0)
end

-- Returns the health of the entity without setting it
function pewpew:GetHealth( ent )
	if (!self:CheckValid( ent )) then return 0 end
	if (!self:CheckAllowed( ent )) then return 0 end
	if (!ent.pewpew) then ent.pewpew = {} end
	local phys = ent:GetPhysicsObject()
	if (!phys:IsValid()) then return 0 end
	local mass = phys:GetMass() or 0
	local volume = phys:GetVolume() / 1000
	if (ent.pewpewHealth) then
		-- Check if the entity has too much health (if the player changed the mass to something huge then back again)
		if (ent.pewpewHealth > mass / 5 + volume) then
			return (mass / 5 + volume) * (mass/ent.pewpewMaxMass)
		end
		return ent.pewpewHealth
	else
		return (mass / 5 + volume)
	end
end

-- Returns the maximum health of the entity without setting it
function pewpew:GetMaxHealth( ent )
	if (!self:CheckValid( ent )) then return 0 end
	if (!self:CheckAllowed( ent )) then return 0 end
	local phys = ent:GetPhysicsObject()
	if (!phys:IsValid()) then return 0 end
	local volume = phys:GetVolume() / 1000
	local mass = phys:GetMass() or 0
	if (ent.pewpewMaxMass) then
		if (mass >= ent.pewpewMaxMass) then
			return ent.pewpewMaxMass / 5 + volume
		else
			return (mass / 5 + volume) * (mass/ent.pewpewMaxMass)
		end
	else
		local mass = phys:GetMass() or 0
		return mass / 5 + volume
	end
end

-- Reduce the health if it's too much (if the player changed the mass to something huge then back again)
function pewpew:ReduceHealth( ent )
	if (!self:CheckValid( ent )) then return end
	if (!self:CheckAllowed( ent )) then return end
	if (!ent.pewpewHealth) then return end
	local maxhp = self:GetMaxHealth( ent )
	if (ent.pewpewHealth > maxhp) then
		ent.pewpewHealth = maxhp
		ent:SetNWInt("pewpewHealth",ent.pewpewHealth or 0)
		ent:SetNWInt("pewpewMaxHealth",maxhp or 0)
	end
end

------------------------------------------------------------------------------------------------------------
-- Checks

-- Check if the entity should be removed
function pewpew:CheckIfDead( ent )
	if (!ent.pewpew) then ent.pewpew = {} end
	if (ent.pewpewHealth <= 0) then
		local effectdata = EffectData()
		effectdata:SetOrigin( ent:LocalToWorld(ent:OBBCenter()) )
		effectdata:SetScale( (ent:OBBMaxs() - ent:OBBMins()):Length() )
		util.Effect( "pewpew_deatheffect", effectdata )
		ent:Remove()
	end
end

function pewpew:CheckAllowed( entity )
	for _, str in pairs( self.DamageWhitelist ) do
		if (entity:GetClass() == str) then return true end
	end
	for _, str in pairs( self.DamageBlacklist ) do
		if (string.find( entity:GetClass(), str )) then return false end
	end
	return true
end

function pewpew:CheckNeverEverList( entity )
	for _, str in pairs( self.NeverEverList ) do
		if (entity:GetClass() == str) then return false end
	end
	return true
end

function pewpew:CheckValid( entity )
	if (!entity:IsValid()) then return false end
	if (entity:IsWorld()) then return false end
	if (entity:GetMoveType() != MOVETYPE_VPHYSICS) then return false end
	if (!entity:GetPhysicsObject():IsValid()) then return false end
	if (!entity:GetPhysicsObject():GetVolume()) then return false end
	if (!entity:GetPhysicsObject():GetMass()) then return false end
	return true
end

------------------------------------------------------------------------------------------------------------
-- Other useful functions

-- FindInCone (Note: copied from E2 then edited)
 function pewpew:FindInCone( Pos, Dir, Dist, Degrees )
	local found = ents.FindInSphere( Pos, Dist )
	local ret = {}

	local cosDegrees = math.cos(math.rad(Degrees))
	
	for _, v in pairs( found ) do
		if (Dir:Dot( ( v:GetPos() - Pos):GetNormalized() ) > cosDegrees) then
			ret[#ret+1] = v
		end	
	end
	
	return ret	
end

-- Get the fire direction
function pewpew:GetFireDirection( Index, Ent, Bullet )
	local Dir
	local Pos
	local boxsize = Ent:OBBMaxs()-Ent:OBBMins()
	local bulletboxsize = Vector(0,0,0)
	
	if (Bullet) then
		bulletboxsize = Bullet:OBBMaxs()-Bullet:OBBMins()
	end
	
	if (Index == 1) then -- Up
		Dir = Ent:GetUp()
		Pos = Ent:LocalToWorld(Ent:OBBCenter()) + Dir * (boxsize.z/2+bulletboxsize.z/2)
	elseif (Index == 2) then -- Down
		Dir = Ent:GetUp() * -1
		Pos = Ent:LocalToWorld(Ent:OBBCenter()) + Dir * (boxsize.z/2+bulletboxsize.z/2)
	elseif (Index == 3) then -- Left
		Dir = Ent:GetRight() * -1
		Pos = Ent:LocalToWorld(Ent:OBBCenter()) + Dir * (boxsize.y/2+bulletboxsize.y/2)
	elseif (Index == 4) then -- Right
		Dir = Ent:GetRight()
		Pos = Ent:LocalToWorld(Ent:OBBCenter()) + Dir * (boxsize.y/2+bulletboxsize.y/2)
	elseif (Index == 5) then -- Forward
		Dir = Ent:GetForward()
		Pos = Ent:LocalToWorld(Ent:OBBCenter()) + Dir * (boxsize.x/2+bulletboxsize.x/2)
	elseif (Index == 6) then -- Back
		Dir = Ent:GetForward() * -1
		Pos = Ent:LocalToWorld(Ent:OBBCenter()) + Dir * (boxsize.x/2+bulletboxsize.x/2)
	end
	
	return Dir, Pos
end