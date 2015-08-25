-- Railgun

local BULLET = {}

-- General Information
BULLET.Name = "Plasma Cannon"
BULLET.Author = "Colonel Thirty Two"
BULLET.Description = "Shoots balls of plasma at people"
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/combatmodels/tankshell_230mm.mdl"
BULLET.Material = nil
BULLET.Color = Color(150,150,255,255)
BULLET.Trail = { StartSize = 10,
				 EndSize = 2,
				 Length = 0.6,
				 Texture = "trails/smoke.vmt",
				 Color = Color( 150, 150, 255, 255 ) }

-- Effects / Sounds
BULLET.FireSound = {"col32/bomb3.wav"}
BULLET.ExplosionSound = {"weapons/explode1.wav","weapons/explode2.wav"}
BULLET.FireEffect = "muzzleflash"
BULLET.ExplosionEffect = "Enersplosion"

-- Movement
BULLET.Speed = 160
BULLET.PitchChange = 0
BULLET.RecoilForce = 500
BULLET.Spread = 0
BULLET.Gravity = 0.03
BULLET.AffectedBySBGravity = true

-- Damage
BULLET.DamageType = "BlastDamage"
BULLET.Damage = 280
BULLET.Radius = 500
BULLET.RangeDamageMul = 0.6
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = 99
BULLET.PlayerDamageRadius = 100

-- Reload/Ammo
BULLET.Reloadtime = 3
BULLET.Ammo = 0
BULLET.AmmoReloadtime = 0

BULLET.Lifetime = nil
BULLET.ExplodeAfterDeath = true
BULLET.EnergyPerShot = 6000

BULLET.CustomInputs = nil
BULLET.CustomOutputs = nil

pewpew:AddBullet( BULLET )