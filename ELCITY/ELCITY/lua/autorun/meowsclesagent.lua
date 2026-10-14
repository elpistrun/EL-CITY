--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/meowsclesagent.lua <
    > Callstack:  <
]]

if SERVER then
	AddCSLuaFile()
end

player_manager.AddValidModel("Meowscles", "models/konnie/asapgaming/meowscles.mdl")
player_manager.AddValidHands( "Meowscles", 	"models/weapons/arms/v_arms_meowscles.mdl", 0, "00000000" )

player_manager.AddValidModel("Meowscles Good", "models/konnie/asapgaming/meowscles_good.mdl")
player_manager.AddValidHands( "Meowscles Good", 	"models/weapons/arms/v_arms_meowscles_good.mdl", 0, "00000000" )

player_manager.AddValidModel("Meowscles Bad", "models/konnie/asapgaming/meowscles_bad.mdl")
player_manager.AddValidHands( "Meowscles Bad", 	"models/weapons/arms/v_arms_meowscles_bad.mdl", 0, "00000000" )
