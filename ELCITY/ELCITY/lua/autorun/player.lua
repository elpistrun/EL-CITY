-- "lua\\autorun\\player.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
player_manager.AddValidModel( "player.mdl", "models/player.mdl" )
player_manager.AddValidHands( "player.mdl",	"models/weapons/c_arms_hev.mdl", 0, "0000000" )

list.Set( "PlayerOptionsModel", "player.mdl", "models/player.mdl" )