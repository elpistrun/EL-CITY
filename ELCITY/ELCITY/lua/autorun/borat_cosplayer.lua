--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/borat_cosplayer.lua <
    > Callstack:  <
]]


local function AddPlayerModel( name, model )

	list.Set( "PlayerOptionsModel", name, model )
	player_manager.AddValidModel( name, model )
	
end

list.Set( "PlayerOptionsModel", "Borat Cosplayer", "models/panman/borat_cosplayer_09.mdl" )
player_manager.AddValidModel( "Borat Cosplayer", "models/panman/borat_cosplayer_09.mdl" )
player_manager.AddValidHands( "Borat Cosplayer", "models/panman/borat_vm.mdl", 0, "00000000" )




