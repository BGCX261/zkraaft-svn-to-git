-- EMP

local BULLET = {}

-- General Information
BULLET.Name = "EMP Bomb"
BULLET.Author = "Divran"
BULLET.Description = "EMP Bomb. No damage, but disables wiring for 15 seconds."
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
BULLET.FireEffect = nil
BULLET.ExplosionEffect = "HEATsplode"

-- Movement
BULLET.Speed = nil
BULLET.Gravity = nil
BULLET.RecoilForce = nil
BULLET.Spread = nil

-- Damage
BULLET.DamageType = "EMPDamage"
BULLET.Damage = nil
BULLET.Radius = 500
BULLET.RangeDamageMul = nil
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.Duration = 15
BULLET.PlayerDamage = nil
BULLET.PlayerDamageRadius = nil

-- Reloading/Ammo
BULLET.Reloadtime = 1
BULLET.Ammo = 0
BULLET.AmmoReloadtime = nil

BULLET.EnergyPerShot = 15500

-- Custom Functions 
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self )
	local Pos = self.Entity:GetPos()
		
	-- Effect
	local effectdata = EffectData()
	effectdata:SetOrigin( Pos )
	util.Effect( self.Bullet.ExplosionEffect, effectdata )
	
	-- Damage
	pewpew:EMPDamage( Pos, self.Bullet.Radius, self.Bullet.Duration, self )
	
	-- Still here?
	if (self.Entity:IsValid()) then
		self.Entity:Remove()
	end
end

pewpew:AddBullet( BULLET )