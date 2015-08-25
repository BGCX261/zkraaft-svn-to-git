-- Basic Cannon

local BULLET = {}

-- General Information
BULLET.Name = "Flak Cannon"
BULLET.Author = "Divran"
BULLET.Description = "Shoots bullets which explode in midair, making it easier to shoot down airplanes."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/combatmodels/tankshell.mdl"
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"arty/40mm.wav"}
BULLET.ExplosionSound = {"weapons/pipe_bomb1.wav","weapons/pipe_bomb2.wav","weapons/pipe_bomb3.wav"}
BULLET.FireEffect = "cannon_flare"
BULLET.ExplosionEffect = "pewpew_smokepuff"

-- Movement
BULLET.Speed = 135
BULLET.Gravity = 0.06
BULLET.RecoilForce = 400
BULLET.Spread = 1
BULLET.AffectedBySBGravity = true

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 250
BULLET.Radius = 850
BULLET.RangeDamageMul = 0.5
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = 500
BULLET.PlayerDamageRadius = 1000

-- Reloading/Ammo
BULLET.Reloadtime = 2
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

-- Other
BULLET.Lifetime = nil
BULLET.ExplodeAfterDeath = true
BULLET.EnergyPerShot = 2000

BULLET.CustomInputs = { "Fire", "Lifetime" }

pewpew:AddBullet( BULLET )

-- Wire Input (This is called whenever a wire input is changed)
BULLET.WireInputOverride = true
function BULLET:WireInput( self, inputname, value )
	if (inputname == "Lifetime") then
		self.Lifetime = value
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
	self.TraceDelay = CurTime() + self.Bullet.Speed / 1000 / 4
	
	-- Lifetime
	self.Lifetime = false
	if (self.Cannon.Lifetime) then
		self.Lifetime = CurTime() + self.Cannon.Lifetime
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
