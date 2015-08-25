-- Basic Cannon

local BULLET = {}

-- General Information
BULLET.Name = "Flamethrower"
BULLET.Author = "Divran"
BULLET.Description = "Kill it with fire!"
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/weapons/w_bugbait.mdl" 
BULLET.Material = nil
BULLET.Color = Color(255,255,255,0)
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"ambient/fire/mtov_flame2.wav"}
BULLET.ExplosionSound = nil
BULLET.FireEffect = nil
BULLET.ExplosionEffect = nil
BULLET.EmptyMagSound = nil

-- Movement
BULLET.Speed = 70
BULLET.Gravity = 0.08
BULLET.RecoilForce = 0
BULLET.Spread = 1
BULLET.AffectedBySBGravity = true

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 80
BULLET.Radius = 60
BULLET.RangeDamageMul = 1
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.Duration = nil
BULLET.PlayerDamage = 50
BULLET.PlayerDamageRadius = 80

-- Reloading/Ammo
BULLET.Reloadtime = 0.1
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

-- Other
BULLET.EnergyPerShot = 100

-- Custom Functions 
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Initialize (Is called when the bullet initializes)
BULLET.InitializeOverride = true
function BULLET:InitializeFunc( self )   
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )    
	self.FlightDirection = self.Entity:GetUp()
	self.Exploded = false
	self.TraceDelay = CurTime() + (self.Bullet.Speed*2)/1000
	self.Speed = 70
	self.Entity:SetColor(255,255,255,0)
end

-- Think
BULLET.ThinkOverride = true
function BULLET:ThinkFunc( self )
	-- Make it fly
	self.Speed = self.Speed - 0.5
	if (self.Speed < 3) then
		self.Exp = true
	end
	self.Entity:SetPos( self.Entity:GetPos() + self.FlightDirection * math.Clamp(self.Speed,4,70)/2 )
	self.FlightDirection = self.FlightDirection - Vector(0,0,self.Bullet.Gravity / self.Bullet.Speed)
	self.Entity:SetAngles( self.FlightDirection:Angle() + Angle(90,0,0) )
	
	if (CurTime() > self.TraceDelay) then
		-- Check if it hit something
		local tr = {}
		tr.start = self.Entity:GetPos() - self.FlightDirection * self.Speed
		tr.endpos = self.Entity:GetPos()
		tr.filter = self.Entity
		local trace = util.TraceLine( tr )
		
		if ((trace.Hit and !self.Exploded) or self.Exp) then	
			self.Exploded = true
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
			if (trace.Entity and trace.Entity:IsValid()) then
				pewpew:PointDamage( trace.Entity, self.Bullet.Damage, self.Entity )
				pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, trace.Entity, self )
			else
				pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, self.Entity, self )
			end
			
			-- Player Damage
			if (self.Bullet.PlayerDamageRadius and self.Bullet.PlayerDamage and pewpew.Damage) then
				util.BlastDamage( self.Entity, self.Entity, trace.HitPos + trace.HitNormal * 10, self.Bullet.PlayerDamageRadius, self.Bullet.PlayerDamage )
			end
			
			self.Entity:SetPos( trace.HitPos )
			-- Remove the bullet
			self.Entity:Remove()
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

-- Client side overrides:

BULLET.CLInitializeOverride = true
function BULLET:CLInitializeFunc()
	self.emitter = ParticleEmitter( Vector(0,0,0) )
	self.delta = 15
	self.delay = CurTime() + 0.01
end

BULLET.CLThinkOverride = true
function BULLET:CLThinkFunc()
	if (CurTime() > self.delay) then
		local add = 2
		if (self.delta > 100) then add = 4 end
		self.delta = math.Clamp(self.delta + add,2,180)
		local Pos = self.Entity:GetPos()
		local particle = self.emitter:Add("particles/flamelet" .. math.random(1,5), Pos)
		if (particle) then
			particle:SetLifeTime(0)
			particle:SetDieTime(1)
			particle:SetStartAlpha(math.random( 200, 255 ) )
			particle:SetEndAlpha(0)
			particle:SetStartSize(self.delta)
			particle:SetEndSize(self.delta-10)
			--particle:SetRoll(math.random(-5, 5))
			particle:SetRollDelta(math.random(-5, 5))
			particle:SetColor(255, 255, 255) 
		end
		self.delay = CurTime() + math.Rand(0.01,0.04)
	end
end

pewpew:AddBullet( BULLET )