-- Burst Machinegun

local BULLET = {}

-- General Information
BULLET.Name = "Burst Machinegun"
BULLET.Author = "Divran"
BULLET.Description = "Fires 5 shots in quick succession followed by a brief pause."
BULLET.AdminOnly = false
BULLET.SuperAdminOnly = false

-- Appearance
BULLET.Model = "models/combatmodels/tankshell_25mm.mdl"
BULLET.Material = nil
BULLET.Color = nil
BULLET.Trail = nil
					

-- Effects / Sounds
BULLET.FireSound = {"arty/20mm.wav"}
BULLET.ExplosionSound = nil
BULLET.FireEffect = "muzzleflash"
BULLET.ExplosionEffect = "mghit"

-- Movement
BULLET.Speed = 120
BULLET.Gravity = 0.05
BULLET.RecoilForce = 55
BULLET.Spread = 0.1
BULLET.AffectedBySBGravity = true

-- Damage
BULLET.DamageType = "PointDamage"
BULLET.Damage = 45
BULLET.Radius = nil
BULLET.RangeDamageMul = nil
BULLET.NumberOfSlices = nil
BULLET.SliceDistance = nil
BULLET.PlayerDamage = nil
BULLET.PlayerDamageRadius = nil

-- Reloading/Ammo
BULLET.Reloadtime = 0.08
BULLET.Ammo = 5
BULLET.AmmoReloadtime = 0.8

BULLET.EnergyPerShot = 180

pewpew:AddBullet( BULLET )