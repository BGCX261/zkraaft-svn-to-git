-- WTF BOOM

local BULLET = {}

-- General Information
BULLET.Name = "WTF BOOM"
BULLET.Author = "Divran"
BULLET.Description = "WHAT THE FUCK BOOOOOOOOOOOOOOM."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = true

-- Appearance
BULLET.Model = nil
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil

-- Effects / Sounds
BULLET.FireSound = {"wtfboom.mp3"}
BULLET.ExplosionSound = nil
BULLET.FireEffect = "pewpew_wtf_boom_explosion"
BULLET.ExplosionEffect = nil

-- Movement
BULLET.Speed = nil
BULLET.Gravity = nil
BULLET.RecoilForce = nil
BULLET.Spread = nil

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 100000000
BULLET.Radius = 5000
BULLET.RangeDamageMul = 1
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = 100000000
BULLET.PlayerDamageRadius = 5000

-- Reloading/Ammo
BULLET.Reloadtime = 1
BULLET.Ammo = 0
BULLET.AmmoReloadtime = nil

BULLET.EnergyPerShot = 100000000

-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self )
	-- Sound
	self:EmitSound( self.Bullet.FireSound[1] )
	
	timer.Create("wtf_boom_"..self.Entity:EntIndex().."_"..CurTime(),2,1,function( self ) 
		if (!self.Entity:IsValid()) then return end
		
		local Pos = self.Entity:GetPos()
		local Norm = self.Entity:GetUp()
			
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
	end, self)
end

pewpew:AddBullet( BULLET )