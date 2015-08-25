-- Fist

local BULLET = {}

-- General Information
BULLET.Name = "Fist"
BULLET.Author = "Divran"
BULLET.Description = "The damage of this weapon depends on its impact speed. Will not damage constrained entities. The wire inputs do nothing."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = nil
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"sound1", "sound2","sound3","and so on"}
BULLET.ExplosionSound = nil
BULLET.FireEffect = "cannon_flare"
BULLET.ExplosionEffect = "big_splosion"
BULLET.EmptyMagSound = {"sound1","sound2","sound3","and so on"}

-- Movement
BULLET.Speed = nil
BULLET.Gravity = nil
BULLET.RecoilForce = nil
BULLET.Spread = nil

-- Damage
BULLET.DamageType = "PointDamage"
BULLET.Damage = nil
BULLET.Radius = nil
BULLET.RangeDamageMul = nil
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.Duration = nil
BULLET.PlayerDamage = 500
BULLET.PlayerDamageRadius = 300

-- Reloading/Ammo
BULLET.Reloadtime = nil
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

-- Other
BULLET.Lifetime = nil
BULLET.ExplodeAfterDeath = nil
BULLET.EnergyPerShot = nil

BULLET.CustomInputs = nil
BULLET.CustomOutputs = nil

-- Custom Functions (Only for adv users)
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)
-- I suggest you erase any functions you are not using to minimize file size.

-- Cannon Think (Is run on: Cannon)
BULLET.CannonThinkOverride = true
function BULLET:CannonThink( self ) end

BULLET.CannonPhysicsCollideOverride = true
function BULLET:CannonPhysicsCollideFunc( Data, PhysObj )
	if (pewpew.Firing and pewpew.Damage) then
		if (!self.LastHit) then self.LastHit = 0 end
		if (CurTime() > self.LastHit) then
			local Target = Data.HitEntity
			
			if (Target:IsWorld()) then return end
			if (!pewpew:CheckValid(Target)) then return end
			
			local Ent = self.Entity
			
			-- Check constrained entities
			if (constraint.HasConstraints( Target ) and constraint.HasConstraints( Ent )) then
				local const = constraint.GetAllConstrainedEntities( Target )
				if (table.Count(const)) then
					for k,v in pairs(const) do
						if (v == Ent) then return false end
					end
				end
			end
			
			local TargetVel = Data.TheirOldVelocity
			local SelfVel = Data.OurOldVelocity
			local Vel = (TargetVel - SelfVel):Length()
			
			local Damage = math.Clamp(Vel ^ 2 / 450,1,10000)

			pewpew:PointDamage( Target, Damage, self )
			
			self.LastHit = CurTime() + 0.25
		end
	end
end

pewpew:AddBullet( BULLET )