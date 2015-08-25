-- Basic Laser

local BULLET = {}

-- General Information
BULLET.Name = "Laser Nuke"
BULLET.Author = "Divran"
BULLET.Description = "BLAAAAAARGH"
BULLET.AdminOnly = true
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = nil
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"npc/strider/fire.wav"}
BULLET.ExplosionSound = { "ambient/explosions/citadel_end_explosion1.wav", "ambient/explosions/citadel_end_explosion2.wav" }
BULLET.FireEffect = "Deathbeam2"
BULLET.ExplosionEffect = "breachsplode"

-- Movement
BULLET.Speed = nil
BULLET.Gravity = nil
BULLET.RecoilForce = nil
BULLET.Spread = nil

-- Damage
BULLET.DamageType = "BlastDamage" -- custom
BULLET.Damage = 100000
BULLET.Radius = 7000
BULLET.RangeDamageMul = 0.6
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = 5000
BULLET.PlayerDamageRadius = 5000

-- Reloading/Ammo
BULLET.Reloadtime = 11
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

BULLET.EnergyPerShot = 11000000

-- Custom Functions 
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self, Pos, Dir )
	local Dir, startpos = pewpew:GetFireDirection( self.Direction, self )
	
	-- Start a trace
	local tr = {}
	tr.start = startpos
	tr.endpos = startpos + Dir * 50000
	tr.filter = self.Entity
	local trace = util.TraceLine( tr )
	
	local HitPos = trace.HitPos
	
	-- Effects
	self:EmitSound( self.Bullet.FireSound[1] )
	local effectdata = EffectData()
	effectdata:SetOrigin( HitPos or (startpos + Dir * 50000 ) )
	effectdata:SetStart( startpos )
	util.Effect( self.Bullet.ExplosionEffect, effectdata )
	
	local effectdata = EffectData()
	effectdata:SetOrigin( HitPos )
	effectdata:SetStart( startpos )
	util.Effect( self.Bullet.FireEffect, effectdata )
	
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
	
	if (pewpew.Damage and !pewpew:FindSafeZone( self.Entity:GetPos() )) then
		if (trace.Entity and trace.Entity:IsValid()) then
			pewpew:PointDamage( trace.Entity, self.Bullet.Damage, self )
			pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, trace.Entity, self )
		else
			pewpew:BlastDamage( trace.HitPos, self.Bullet.Radius, self.Bullet.Damage, self.Bullet.RangeDamageMul, self.Entity, self )
		end
		util.BlastDamage( self.Entity, self.Entity, trace.HitPos + trace.HitNormal * 10, self.Bullet.PlayerDamageRadius, self.Bullet.PlayerDamage )
	end
end

pewpew:AddBullet( BULLET )