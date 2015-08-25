-- Rocket Battery

local BULLET = {}

-- General Information
BULLET.Name = "Rocket Battery"
BULLET.Author = "Divran"
BULLET.Description = "Rapid fire rocket battery with 12 dumb rockets."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/weapons/W_missile_launch.mdl"
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = { StartSize = 15,
				 EndSize = 0,
				 Length = 1,
				 Texture = "trails/smoke.vmt",
				 Color = Color( 255, 255, 255, 255 ) }

-- Effects / Sounds
BULLET.FireSound = {"weapons/stinger_fire1.wav" }
BULLET.ExplosionSound = nil
BULLET.FireEffect = nil
BULLET.ExplosionEffect = "explosion"
BULLET.EmptyMagSound = nil

-- Movement
BULLET.Speed = 80
BULLET.Gravity = 0
BULLET.RecoilForce = 200
BULLET.Spread = 0.4

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 200
BULLET.Radius = 145
BULLET.RangeDamageMul = 0.9
BULLET.PlayerDamage = 50
BULLET.PlayerDamageRadius = 100

-- Reloading/Ammo
BULLET.Reloadtime = 0.15
BULLET.Ammo = 12
BULLET.AmmoReloadtime = 8

-- Other
BULLET.Lifetime = {3,4}
BULLET.ExplodeAfterDeath = true
BULLET.EnergyPerShot = 200


-- Initialize (Is called when the bullet initializes) (Is run on: Bullet)
BULLET.InitializeOverride = true
function BULLET:InitializeFunc( self )   
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )    
	self.FlightDirection = self.Entity:GetForward()
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

-- Fire (Is called before the cannon is about to fire) (Is run on: Cannon)
BULLET.FireOverride = true
function BULLET:Fire( self )
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
	ent:SetAngles( Dir:Angle() )
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

-- Think (Is run on: Bullet)
BULLET.ThinkOverride = true
function BULLET:ThinkFunc( self )
	-- Make it fly
	self.Entity:SetPos( self.Entity:GetPos() + self.FlightDirection * self.Bullet.Speed )
	self.FlightDirection = self.FlightDirection - Vector(0,0,(self.Bullet.Gravity or 0) / (self.Bullet.Speed or 1))
	self.Entity:SetAngles( self.FlightDirection:Angle() )
	
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

pewpew:AddBullet( BULLET )