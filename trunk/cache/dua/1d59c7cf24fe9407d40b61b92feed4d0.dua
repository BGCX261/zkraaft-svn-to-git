-- Basic Cannon

local BULLET = {}

-- General Information
BULLET.Name = "Laser Sword"
BULLET.Author = "Divran"
BULLET.Description = "May the force be with you."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = nil
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = nil
BULLET.ExplosionSound = nil
BULLET.FireEffect = "pewpew_swordeffect"
BULLET.ExplosionEffect = nil
BULLET.EmptyMagSound = nil

-- Movement
BULLET.Speed = nil
BULLET.Gravity = nil
BULLET.RecoilForce = nil
BULLET.Spread = nil

-- Damage
BULLET.DamageType = "SliceDamage"
BULLET.Damage = 200
BULLET.Radius = nil
BULLET.RangeDamageMul = nil
BULLET.NumberOfSlices = 3
BULLET.SliceDistance = 500
BULLET.ReducedDamagePerSlice = 0
BULLET.Duration = nil
BULLET.PlayerDamage = nil
BULLET.PlayerDamageRadius = nil

-- Reloading/Ammo
BULLET.Reloadtime = 0.05
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

BULLET.EnergyPerShot = 75

-- Custom Functions 
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self )
	local Dir, startpos = pewpew:GetFireDirection( self.Direction, self )
	
	-- Deal damage
	if (!pewpew:FindSafeZone(self.Entity:GetPos())) then
		local HitPos = pewpew:SliceDamage( startpos, Dir, self.Bullet.Damage, self.Bullet.NumberOfSlices, self.Bullet.SliceDistance, self.Bullet.ReducedDamagePerSlice, self )
	end
	
	local effectdata = EffectData()
	effectdata:SetStart( startpos )
	effectdata:SetOrigin( HitPos or (startpos + Dir * self.Bullet.SliceDistance) )
	effectdata:SetEntity( self.Entity )
	util.Effect( self.Bullet.FireEffect, effectdata )
end

pewpew:AddBullet( BULLET )