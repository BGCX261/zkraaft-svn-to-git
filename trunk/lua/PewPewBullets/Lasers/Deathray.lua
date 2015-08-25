-- Deathray

local BULLET = {}

-- General Information
BULLET.Name = "Deathray"
BULLET.Author = "Free Fall"
BULLET.Description = "Combine laser and lightning. What do you get?"
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = nil
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = "npc/strider/fire.wav"
BULLET.FireEffect = nil
BULLET.ExplosionEffect = "big_splosion"
BULLET.ExplosionSound = nil

-- Movement
BULLET.Speed = nil
BULLET.Gravity = nil
BULLET.RecoilForce = nil
BULLET.Spread = nil

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 600
BULLET.Radius = 500
BULLET.RangeDamageMul = 0.3
BULLET.PlayerDamage = 140
BULLET.PlayerDamageRadius = 400

-- Reloading/Ammo
BULLET.Reloadtime = 8
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

BULLET.EnergyPerShot = 8000

-- Custom Functions 
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Wire Input
BULLET.WireInputOverride = false
function BULLET:WireInput( inputname, value )
	-- Nothing
end

-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self )
	local Dir, Pos = pewpew:GetFireDirection( self.Direction, self )
		
	self:EmitSound(self.Bullet.FireSound, 100, 100)
	
	local traceData = {}
	traceData.start = Pos
	traceData.endpos = self.Entity:GetPos() + Dir * 100000
	traceData.filter = self.Entity 
	local trace = util.TraceLine( traceData ) 
	
	if (!pewpew:FindSafeZone( self.Entity:GetPos() )) then
		local ent = ents.Create("pewpew_base_bullet")
		ent:SetPos(trace.HitPos)
		ent:SetAngles(trace.HitNormal:Angle() + Vector(90, 0, 0))
		ent:SetOptions(self.Bullet, self, self.Owner )
		ent:GetTable().MoreLeft = 20
		ent:Spawn()
		ent:Activate()
	
		if (trace.Entity and trace.Entity:IsValid()) then
			pewpew:PointDamage( trace.Entity, self.Bullet.Damage, self.Entity )
			pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, trace.Entity, self )
		else
			pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, nil, self )
		end
		
		-- Player Damage
		if (self.Bullet.PlayerDamageRadius and self.Bullet.PlayerDamage and pewpew.Damage) then
			util.BlastDamage( self.Entity, self.Entity, trace.HitPos + trace.HitNormal * 10, self.Bullet.PlayerDamageRadius, self.Bullet.PlayerDamage )
		end
	end
	
	local effectdata = EffectData()
	effectdata:SetOrigin(trace.HitPos)
	effectdata:SetStart(Pos)
	util.Effect( "Deathbeam", effectdata )
	
	local effectdata = EffectData()
	effectdata:SetOrigin(trace.HitPos)
	effectdata:SetStart(trace.HitPos +  trace.Normal * 10)
	util.Effect( self.Bullet.ExplosionEffect, effectdata )
end

-- Initialize (Is called when the bullet initializes)
BULLET.InitializeOverride = true
function BULLET:InitializeFunc(self)
	self.Entity:SetModel("models/weapons/w_bugbait.mdl") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:SetColor(100,100,100,255)
	
	self.FlightDirection = self.Entity:GetUp()
	self.Exploded = false
	self.Living = true
	
	self:SetNetworkedEntity("LaserTarget", self.Entity)
end

-- Think (Is called a lot of times :p)
BULLET.ThinkOverride = true
function BULLET:ThinkFunc( self )
	if (self.Living == false) then self:Remove() return false end
	
	if (self.MoreLeft > 0) then
		local trace = util.QuickTrace(self:GetPos() + self:GetUp() * 300, self:GetUp() * -900 + VectorRand() * 600, self.Entity)
		if trace.Hit then
			local ent = ents.Create("pewpew_base_bullet")
			ent:SetPos(trace.HitPos)
			ent:SetAngles(trace.HitNormal:Angle() + Vector(90, 0, 0))
			ent:SetOptions(self.Bullet, self, self.Owner )
			ent:GetTable().MoreLeft = self.MoreLeft - 1
			ent:Spawn()
			ent:Activate()
			
			self:SetNetworkedEntity("LaserTarget", ent)
			
			if (self.Bullet.PlayerDamageRadius and self.Bullet.PlayerDamage and pewpew.Damage) then
				util.BlastDamage(self.Entity, self.Entity, trace.HitPos, self.Bullet.PlayerDamageRadius / 2, self.Bullet.PlayerDamage / 6)
			end
			pewpew:BlastDamage(trace.HitPos, self.Bullet.Radius / 2, self.Bullet.Damage / 6, self.Bullet.RangeDamageMul, nil, self )
			
			self.MoreLeft = 0
		end
	end
	
	self.Living = false
	
	self:NextThink(CurTime() + 2)
	return true
end

-- Explode (Is called when the bullet explodes) Note: this will not run if you override the think function (unless you call it from there as well)
BULLET.ExplodeOverride = false

-- This is called when the bullet collides (Advanced users only. It only works if you first override initialize and change it to vphysics)
BULLET.PhysicsCollideOverride = false

-- Client side overrides:

BULLET.CLInitializeOverride = false

BULLET.CLThinkOverride = false

if (CLIENT) then
	local Laser = Material( "sprites/rollermine_shock" )

	BULLET.CLDrawOverride = true
	function BULLET:CLDrawFunc()
		local Pos = self:GetPos()
		
		local LaserTarget = self:GetNetworkedEntity("LaserTarget")
		if (not LaserTarget or not LaserTarget:IsValid()) then LaserTarget = self.Entity end
		
		render.SetMaterial(Laser)
		local DirMins = LaserTarget:GetPos() - Pos
		
		render.StartBeam(7)
		render.AddBeam(Pos, 64, 0, Color(255, 255, 255, 255))
		for i = 2, 6 do
			local CurPos = Pos + (i / 7) * DirMins + VectorRand() * 40
			render.AddBeam(CurPos, 64, CurTime() + (i / 5), Color(255, 255, 255, 255))
		end
		render.AddBeam(LaserTarget:GetPos(), 64, 1, Color(255, 255, 255, 255))
		render.EndBeam()
	end
end

pewpew:AddBullet( BULLET )