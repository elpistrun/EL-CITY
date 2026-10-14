-- "lua\\streamradio_core\\models\\wire_subwoofer_big.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Wire Subwoofer, Big
-- Addon: https://steamcommunity.com/sharedfiles/filedetails/?id=160250458
RADIOMDL.model = "models/bull/various/speaker.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.SpawnFlatOnWall = true

return true

