-- Basic Missile

local BULLET = {}

-- General Information
BULLET.Name = "Firework"
BULLET.Author = "Kouta"
BULLET.Description = "Dazzle enemies with random colours!"
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/combatmodels/tankshell.mdl"
BULLET.Material = "phoenix_storms/gear"
BULLET.Color = Color(math.random(50,255),math.random(50,255),math.random(50,255))
BULLET.Trail = {StartSize=30, EndSize=0, Length=0.75, Texture="trails/smoke.vmt", Color=Color(255,255,255)}

-- Effects / Sounds
BULLET.FireSound = {"weapons/flaregun_shoot.wav"}
BULLET.ExplosionSound = {"ambient/explosions/explode_8.wav","ambient/explosions/explode_9.wav"}
BULLET.FireEffect = nil
BULLET.ExplosionEffect = "confetti"

-- Movement
BULLET.Speed = 30
BULLET.Gravity = 0
BULLET.RecoilForce = 0
BULLET.Spread = 5

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 150
BULLET.Radius = 300
BULLET.RangeDamageMul = 0.5
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = 100
BULLET.PlayerDamageRadius = 400

-- Reloading/Ammo
BULLET.Reloadtime = 0.3
BULLET.Ammo = 6
BULLET.AmmoReloadtime = 8

-- Other
BULLET.Lifetime = {2,3}
BULLET.ExplodeAfterDeath = true
BULLET.EnergyPerShot = 650

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
	self.TraceDelay = CurTime() + self.Bullet.Speed / 1000 / 2
	
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
	
	-- Material
	if (self.Bullet.Material) then
		self.Entity:SetMaterial( self.Bullet.Material )
	end
	
	-- Color
	if (self.Bullet.Color) then
		self.Entity:SetColor(math.random(50,255), math.random(50,255), math.random(50,255), 255)
	end

	-- Trail
	if (self.Bullet.Trail) then
		local trail = self.Bullet.Trail
		util.SpriteTrail( self.Entity, 0, Color(math.random(50,255),math.random(50,255),math.random(50,255)), false, trail.StartSize, trail.EndSize, trail.Length, 1/(trail.StartSize+trail.EndSize)*0.5, trail.Texture )
	end
end

pewpew:AddBullet( BULLET )