-- Smoke Emitter

local BULLET = {}

-- General Information
BULLET.Name = "Smoke Emitter"
BULLET.Author = "Divran"
BULLET.Description = "Need to hide?"
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

BULLET.FireEffect = "pewpew_bigsmoke"

-- Reloading/Ammo
BULLET.Reloadtime = 9
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0
-- Overrides


-- Fire (Is called before the cannon is about to fire)
BULLET.FireOverride = true
function BULLET:Fire( self )
	self:EmitSound( "weapons/smokegrenade/sg_explode.wav" )

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( self.Bullet.FireEffect, effectdata )
end

pewpew:AddBullet( BULLET )