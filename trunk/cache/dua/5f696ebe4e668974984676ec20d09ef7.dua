-- Manual Defense

local BULLET = {}

-- General Information
BULLET.Name = "Manual Defense"
BULLET.Author = "Divran"
BULLET.Description = "This defense will kill the target PewPew bullet if it is in range. Has 3000 range."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Effects / Sounds
BULLET.FireSound = {"col32/gun4.wav"}
BULLET.FireEffect = "pewpew_defensebeam"

-- Damage
BULLET.DamageType = "DefenseDamage"
BULLET.Damage = 100
BULLET.Radius = nil
BULLET.RangeDamageMul = nil
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.Duration = nil
BULLET.PlayerDamage = nil
BULLET.PlayerDamageRadius = nil

-- Reloading/Ammo
BULLET.Reloadtime = 0.25
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

-- Other
BULLET.Lifetime = nil
BULLET.ExplodeAfterDeath = false
BULLET.EnergyPerShot = 5000

BULLET.CustomInputs = { "Fire", "Target [ENTITY]" }
BULLET.CustomOutputs = nil

-- Custom Functions (Only for adv users)
-- (If you set the override var to true, the cannon/bullet will run these instead. Use these functions to do stuff which is not possible with the above variables)

-- Wire Input (This is called whenever a wire input is changed)
BULLET.WireInputOverride = true
function BULLET:WireInput( self, inputname, value )
	if (inputname == "Target") then
		if (value and value:IsValid() and value:GetClass() == "pewpew_base_bullet") then
			self.Target = value
		end
	else
		self:InputChange( inputname, value )
	end
end

-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self )
	local Distance = 3500
	if (self.Target) then
		Distance = self.Target:GetPos():Distance(self.Entity:GetPos())
	end
	if (Distance < 3000) then
		local tr = {}
		tr.start = self.Entity:GetPos()
		tr.endpos = self.Target:GetPos()
		tr.filter = self.Entity
		local trace = util.TraceLine( tr )
		if (trace.Hit) then
			if (trace.Entity and pewpew:CheckValid(trace.Entity)) then
				-- Damage
				pewpew:PointDamage( trace.Entity, self.Bullet.Damage / 3, self.Entity )
				-- Sound
				self:EmitSound( self.Bullet.FireSound[1] )
				
				-- Effect
				local effectdata = EffectData()
				effectdata:SetOrigin( trace.HitPos )
				effectdata:SetStart( self.Entity:GetPos() )
				util.Effect( self.Bullet.FireEffect, effectdata )
			end
		else
			-- Damage
			pewpew:DefenseDamage( self.Target, self.Bullet.Damage )
					
			-- Sound
			self:EmitSound( self.Bullet.FireSound[1] )
			
			-- Effect
			local effectdata = EffectData()
			effectdata:SetOrigin( self.Target:GetPos() )
			effectdata:SetStart( self.Entity:GetPos() )
			util.Effect( self.Bullet.FireEffect, effectdata )
		end
	end
end

-- Initialize (Is called when the bullet initializes)
BULLET.InitializeOverride = false
function BULLET:InitializeFunc( self )   
	-- Nothing
end

pewpew:AddBullet( BULLET )