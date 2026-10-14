-- "lua\\entities\\lvs_wheeldrive_pz2c\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
include("shared.lua")
include("sh_turret.lua")
include("sh_tracks.lua")
include("cl_tankview.lua")
include("cl_optics.lua")

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/pz2/engine_start.wav", 75, 100,  LVS.EngineVolume )
	else
		self:EmitSound( "lvs/vehicles/pz2/engine_stop.wav", 75, 100,  LVS.EngineVolume )
	end
end
