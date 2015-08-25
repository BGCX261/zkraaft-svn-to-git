-- Modifiable Artillery

local BULLET = {}

-- General Information
BULLET.Name = "Modifiable Artillery"
BULLET.Author = "Divran"
BULLET.Description = "An artillery with a modifiable speed."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/combatmodels/tankshell.mdl"
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"arty/40mm.wav"}
BULLET.ExplosionSound = {"weapons/explode3.wav","weapons/explode4.wav", "weapons/explode5.wav"}
BULLET.FireEffect = "cannon_flare"
BULLET.ExplosionEffect = "HEATsplode"
BULLET.EmptyMagSound = nil

-- Movement
BULLET.Speed = "?"
BULLET.Gravity = 0.5
BULLET.RecoilForce = 500
BULLET.Spread = 0
BULLET.AffectedBySBGravity = true

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 350
BULLET.Radius = 300
BULLET.RangeDamageMul = 0.8
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.Duration = nil
BULLET.PlayerDamage = 150
BULLET.PlayerDamageRadius = 300

-- Reloading/Ammo
BULLET.Reloadtime = 2
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

-- Other
BULLET.Lifetime = nil
BULLET.ExplodeAfterDeath = false
BULLET.EnergyPerShot = 1000

BULLET.CustomInputs = { "Fire", "Reload", "Speed" }
BULLET.CustomOutputs = nil

-- Custom Functions (Only for adv users)
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Wire Input (This is called whenever a wire input is changed)
BULLET.WireInputOverride = true
function BULLET:WireInput( self, inputname, value )
	if (inputname == "Speed") then
		self.CustomSpeed = math.Clamp(value,10,200)
	else
		self:InputChange( inputname, value )
	end
end

-- Initialize (Is called when the bullet initializes)
BULLET.InitializeOverride = true
function BULLET:InitializeFunc( self ) 
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )    
	self.FlightDirection = self.Entity:GetUp()
	self.Exploded = false
		
	self.CustomSpeed = 100
	if (self.Cannon.CustomSpeed) then
		self.CustomSpeed = self.Cannon.CustomSpeed
	end
	
	self.TraceDelay = CurTime() + self.CustomSpeed / 1000 / 4
end

-- Think
BULLET.ThinkOverride = true
function BULLET:ThinkFunc( self )
	-- Make it fly
	self.Entity:SetPos( self.Entity:GetPos() + self.FlightDirection * self.CustomSpeed )
	self.FlightDirection = self.FlightDirection - Vector(0,0,(self.Bullet.Gravity or 0) / (self.CustomSpeed or 1))
	self.Entity:SetAngles( self.FlightDirection:Angle() + Angle(90,0,0) )
	
	if (CurTime() > self.TraceDelay) then
		-- Check if it hit something
		local tr = {}
		tr.start = self.Entity:GetPos() - self.FlightDirection * self.CustomSpeed
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