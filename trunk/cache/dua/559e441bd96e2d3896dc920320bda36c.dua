-- Basic Cannon

local BULLET = {}

-- General Information
BULLET.Name = "Water Balloons"
BULLET.Author = "Kouta"
BULLET.Description = "Soak your childhood enemies"
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/dav0r/balloon/balloon.mdl"
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"weapons/stickybomblauncher_shoot.wav"}
BULLET.ExplosionSound = {"ambient/water/water_splash1.wav","ambient/water/water_splash2.wav","ambient/water/water_splash3.wav"}
BULLET.FireEffect = "MuzzleFlash"
BULLET.ExplosionEffect = ""

-- Movement
BULLET.Speed = 25
BULLET.Gravity = 0.25
BULLET.RecoilForce = 0
BULLET.Spread = 1.5
BULLET.AffectedBySBGravity = true

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 120
BULLET.Radius = 50
BULLET.RangeDamageMul = 0.95
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = 150
BULLET.PlayerDamageRadius = 50

-- Reloading/Ammo
BULLET.Reloadtime = 0.45
BULLET.Ammo = 6
BULLET.AmmoReloadtime = 5

BULLET.EnergyPerShot = 400

-- Initialize (Is called when the bullet initializes)
BULLET.InitializeOverride = true
function BULLET:InitializeFunc( self )   
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )     
	self.FlightDirection = self.Entity:GetUp()
	self.Exploded = false
	self.TraceDelay = CurTime() + self.Bullet.Speed / 1000 / 2
	self.Entity:SetColor(math.random(25,255), math.random(25,255), math.random(25,255), 255)
end

-- Explode (Is called when the bullet explodes)
BULLET.ExplodeOverride = true
function BULLET:Explode(self, trace)

	local Pos = self.Entity:GetPos()
	local Norm = self.Entity:GetUp()

	if (pewpew.Damage) then
		util.BlastDamage(self.Entity, self.Entity, Pos+Norm*10, self.Bullet.Damage, self.Bullet.Radius)
		pewpew:BlastDamage(Pos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, self.Entity, self )
	end
	
	local vOffset = trace.HitPos+Vector(0,0,2)
	local splash = math.random(13,16)

	self.Entity:EmitSound("weapons/ar2/npc_ar2_altfire.wav", 80, 130)

	local effectdata = EffectData()
		effectdata:SetOrigin(vOffset)
		effectdata:SetStart(vOffset)
		effectdata:SetNormal(Norm)
		effectdata:SetRadius(splash)
		effectdata:SetScale(splash)

	util.Effect( "watersplash", effectdata )

	self.Entity:Remove()
end

pewpew:AddBullet( BULLET )