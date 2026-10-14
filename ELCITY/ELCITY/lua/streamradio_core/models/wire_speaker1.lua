-- "lua\\streamradio_core\\models\\wire_speaker1.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Wire Speaker 1
-- Addon: https://steamcommunity.com/sharedfiles/filedetails/?id=160250458
RADIOMDL.model = "models/cheeze/wires/speaker.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false

return true

