-- "lua\\entities\\lvs_wheeldrive_dodsherman\\sh_turret.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

include("entities/lvs_tank_wheeldrive/modules/sh_turret.lua")

ENT.TurretAimRate = 25

ENT.TurretRotationSound = "vehicles/tank_turret_loop1.wav"

ENT.TurretPitchPoseParameterName = "turret_pitch"
ENT.TurretPitchMin = -15
ENT.TurretPitchMax = 15
ENT.TurretPitchMul = 1
ENT.TurretPitchOffset = 0

ENT.TurretYawPoseParameterName = "turret_yaw"
ENT.TurretYawMul = 1
ENT.TurretYawOffset = 0