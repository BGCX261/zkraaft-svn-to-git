AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	-- Check for damage blocked areas
	if (pewpew:FindSafeZone(self.Entity:GetPos())) then
		self.Bullet.Damage = 0
	end
	
	-- Spacebuild 3 is way too slow at this.
	if (self.Bullet.AffectedBySBGravity) then
		if (CAF and CAF.GetAddon("Spacebuild")) then
			CAF.GetAddon("Spacebuild").PerformEnvironmentCheckOnEnt(self.Entity)
			CAF.GetAddon("Spacebuild").OnEnvironmentChanged(self.Entity)
			self.Entity.environment:UpdateGravity(self.Entity)
			self.Entity.environment:UpdatePressure(self.Entity)
		end
	end
	
	if (self.Bullet.InitializeOverride) then
		-- Allows you to override the Initialize function
		self.Bullet:InitializeFunc( self )
	else
		self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )    
		self.FlightDirection = self.Entity:GetUp()
		self.Exploded = false
		self.TraceDelay = CurTime() + self.Bullet.Speed / 1000 / 4
		
		-- Lifetime
		self.Lifetime = false
		if (self.Bullet.Lifetime) then
			if (self.Bullet.Lifetime[1] > 0 and self.Bullet.Lifetime[2] > 0) then
				if (self.Bullet.Lifetime[1] == self.Bullet.Lifetime[2]) then
					self.Lifetime = CurTime() + self.Bullet.Lifetime[1]
				else
					self.Lifetime = CurTime() + math.Rand(self.Bullet.Lifetime[1],self.Bullet.Lifetime[2])
				end
			end
		end
		
		-- Trail
		if (self.Bullet.Trail) then
			local trail = self.Bullet.Trail
			util.SpriteTrail( self.Entity, 0, trail.Color, false, trail.StartSize, trail.EndSize, trail.Length, 1/(trail.StartSize+trail.EndSize)*0.5, trail.Texture )
		end
		
		-- Material
		if (self.Bullet.Material) then
			self.Entity:SetMaterial( self.Bullet.Material )
		end
		
		-- Color
		if (self.Bullet.Color) then
			local C = self.Bullet.Color
			self.Entity:SetColor( C.r, C.g, C.b, C.a or 255 )
		end
	end
	self.Entity:NextThink( CurTime() )
end   

function ENT:SetOptions( BULLET, Cannon, ply )
	self.Bullet = table.Copy(BULLET)
	self.Cannon = Cannon
	self.Owner = ply
	self.Entity:SetNWString("BulletName", self.Bullet.Name)
	local name = "- error -"
	if (ply and ply:IsValid()) then name = ply:Nick() end
	self:SetNWString( "PewPew_OwnerName", name )
end

function ENT:Explode(trace)
	if (!trace) then
		local tr = {}
		tr.start = self.Entity:GetPos() - self.FlightDirection * self.Bullet.Speed
		tr.endpos = self.Entity:GetPos()
		tr.filter = self.Entity
		trace = util.TraceLine( tr )
	end
	if (self.Cannon:IsValid()) then
		if (pewpew:FindSafeZone( self.Cannon:GetPos() )) then
			self.Bullet.Damage = 0
		end
	end
	if (self.Bullet.ExplodeOverride) then
		-- Allows you to override the Explode function
		self.Bullet:Explode( self, trace )
	else
		-- Effects
		if (self.Bullet.ExplosionEffect) then
			local effectdata = EffectData()
			effectdata:SetOrigin( trace.HitPos + trace.HitNormal * 5 )
			effectdata:SetStart( trace.HitPos + trace.HitNormal * 5 )
			effectdata:SetNormal( trace.HitNormal )
			util.Effect( self.Bullet.ExplosionEffect, effectdata )
		end
		
		-- Sounds
		if (self.Bullet.ExplosionSound) then
			local soundpath = ""
			if (table.Count(self.Bullet.ExplosionSound) > 1) then
				soundpath = table.Random(self.Bullet.ExplosionSound)
			else
				soundpath = self.Bullet.ExplosionSound[1]
			end
			WorldSound( soundpath, trace.HitPos+trace.HitNormal*5,100,100)
		end
			
		-- Damage
		local damagetype = self.Bullet.DamageType
		if (damagetype and type(damagetype) == "string") then
			if (damagetype == "BlastDamage") then
				if (trace.Entity and trace.Entity:IsValid()) then
					pewpew:PointDamage( trace.Entity, self.Bullet.Damage, self )
					pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, trace.Entity, self )
				else
					pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, self )
				end
				
				-- Player Damage
				if (self.Bullet.PlayerDamageRadius and self.Bullet.PlayerDamage and pewpew.Damage) then
					util.BlastDamage( self.Entity, self.Entity, trace.HitPos + trace.HitNormal * 10, self.Bullet.PlayerDamageRadius, self.Bullet.PlayerDamage )
				end
			elseif (damagetype == "PointDamage") then
				pewpew:PointDamage( trace.Entity, self.Bullet.Damage, self )
			elseif (damagetype == "SliceDamage") then
				pewpew:SliceDamage( trace.HitPos, self.FlightDirection, self.Bullet.Damage, self.Bullet.NumberOfSlices or 1, self.Bullet.SliceDistance or 50, self.Bullet.ReducedDamagePerSlice or 0, self )
			elseif (damagetype == "EMPDamage") then
				pewpew:EMPDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Duration )
			elseif (damagetyp == "DefenseDamage") then
				pewpew:DefenseDamage( trace.Entity, self.Bullet.Damage )
			end
		end
		
		-- Remove the bullet
		self.Entity:Remove()
	end
end

function ENT:Think()
	if (self.Bullet.ThinkOverride) then
		-- Allows you to override the think function
		return self.Bullet:ThinkFunc( self )
	else
		-- Make it fly
		self.Entity:SetPos( self.Entity:GetPos() + self.FlightDirection * self.Bullet.Speed )
		local grav = self.Bullet.Gravity or 0
		
		-- Make the bullet not fall down in space
		if (self.Bullet.AffectedByNoGrav) then
			if (CAF and CAF.GetAddon("Spacebuild")) then
				if (self.environment) then
					grav = grav * self.environment:GetGravity()
				end
			end
		end
		
		if (grav and grav != 0) then -- Only pull it down if needed
			self.FlightDirection = self.FlightDirection - Vector(0,0,grav / (self.Bullet.Speed or 1))
		end
			
		self.Entity:SetAngles( self.FlightDirection:Angle() + Angle(90,0,0) )
		
		-- Lifetime
		if (self.Lifetime) then
			if (CurTime() > self.Lifetime) then
				if (self.Bullet.ExplodeAfterDeath) then
					local tr = {}
					tr.start = self.Entity:GetPos()-self.FlightDirection
					tr.endpos = self.Entity:GetPos()
					tr.filter = self.Entity
					local trace = util.TraceLine( tr )
					self:Explode( trace )
				else
					self.Entity:Remove()
				end
			end
		end
		
		if (CurTime() > self.TraceDelay) then
			-- Check if it hit something
			local tr = {}
			tr.start = self.Entity:GetPos() - self.FlightDirection * self.Bullet.Speed
			tr.endpos = self.Entity:GetPos()
			tr.filter = self.Entity
			local trace = util.TraceLine( tr )
			
			if (trace.Hit and !self.Exploded) then	
				self:Explode( trace )
				self.Exploded = true
			else			
				-- Run more often!
				self.Entity:NextThink( CurTime() )
				return true
			end
		else			
			-- Run more often!
			self.Entity:NextThink( CurTime() )
			return true
		end
	end
end

function ENT:PhysicsCollide(CollisionData, PhysObj)
	if (self.Bullet.PhysicsCollideOverride) then
		self.Bullet.PhysicsCollideFunc(self, CollisionData, PhysObj)
	end
end