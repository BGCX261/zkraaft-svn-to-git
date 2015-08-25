-- Railgun

local BULLET = {}

-- General Information
BULLET.Name = "Railgun"
BULLET.Author = "Divran"
BULLET.Description = "Fires extremely fast moving rounds with deadly accuracy. Slices through armor like a hot knife through butter."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/combatmodels/tankshell_120mm.mdl"
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = { StartSize = 10,
				 EndSize = 2,
				 Length = 0.3,
				 Texture = "trails/smoke.vmt",
				 Color = Color( 255, 255, 255, 255 ) }

-- Effects / Sounds
BULLET.FireSound = {"arty/railgun.wav"}
BULLET.ExplosionSound = nil
BULLET.FireEffect = nil
BULLET.ExplosionEffect = "HEATsplode"

-- Movement
BULLET.Speed = 300
BULLET.Gravity = 0.02
BULLET.RecoilForce = 100
BULLET.Spread = 0
BULLET.AffectedBySBGravity = true

-- Damage
BULLET.DamageType = "SliceDamage"
BULLET.Damage = 800
BULLET.Radius = nil
BULLET.RangeDamageMul = nil
BULLET.NumberOfSlices = 5
BULLET.SliceDistance = 750
BULLET.PlayerDamageRadius = nil
BULLET.PlayerDamage = nil

-- Reload/Ammo
BULLET.Reloadtime = 6.2
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

BULLET.EnergyPerShot = 5500

pewpew:AddBullet( BULLET )