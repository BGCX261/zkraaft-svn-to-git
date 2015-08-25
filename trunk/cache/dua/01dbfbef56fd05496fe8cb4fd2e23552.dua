-- Warhead

local BULLET = {}

-- General Information
BULLET.Name = "Warhead"
BULLET.Author = "Divran"
BULLET.Description = "Warhead. Low damage, high radius."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = nil
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"weapons/explode1.wav","weapons/explode2.wav"}
BULLET.ExplosionSound = nil
BULLET.FireEffect = "scud_splosion"
BULLET.ExplosionEffect = nil

-- Movement
BULLET.Speed = nil
BULLET.Gravity = nil
BULLET.RecoilForce = nil
BULLET.Spread = nil

-- Damage
BULLET.DamageType = "BlastDamage" -- Look in gcombat_damagecontrol.lua for available damage types
BULLET.Damage = 950
BULLET.Radius = 1000
BULLET.RangeDamageMul = 0.8
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = 500
BULLET.PlayerDamageRadius = 250

-- Reloading/Ammo
BULLET.Reloadtime = 1
BULLET.Ammo = 0
BULLET.AmmoReloadtime = nil

BULLET.EnergyPerShot = 10000

-- Custom Functions 
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self )
	local Pos = self.Entity:GetPos()
	local Norm = self.Entity:GetUp()
	
	-- Sound
	soundpath = table.Random(self.Bullet.FireSound)
	self:EmitSound( soundpath )
		
	-- Effect
	local effectdata = EffectData()
	effectdata:SetOrigin( Pos )
	effectdata:SetNormal( Norm )
	util.Effect( self.Bullet.FireEffect, effectdata )
	
	-- Damage
	if (pewpew.Damage) then
		util.BlastDamage( self.Entity, self.Entity, Pos + Norm * 10, self.Bullet.PlayerDamageRadius, self.Bullet.PlayerDamage )
	end
	pewpew:BlastDamage( Pos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, self.Entity, self )
	
	-- Still here?
	if (self.Entity:IsValid()) then
		self.Entity:Remove()
	end
end

pewpew:AddBullet( BULLET )