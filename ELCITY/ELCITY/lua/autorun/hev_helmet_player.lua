-- "lua\\autorun\\hev_helmet_player.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function AddPlayerModel( name, model )

	list.Set( "PlayerOptionsModel", name, model )
	player_manager.AddValidModel( name, model )
	
end


AddPlayerModel( "HEV Helmet", 					"models/player/SGG/hev_helmet.mdl" )
player_manager.AddValidModel( "HEV Helmet", 						"models/player/SGG/hev_helmet.mdl" )
player_manager.AddValidHands( "HEV Helmet", 						"models/weapons/c_arms_hev.mdl", 0, "00000000" )