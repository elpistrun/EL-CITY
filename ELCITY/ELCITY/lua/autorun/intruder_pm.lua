--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/intruder_pm.lua <
    > Callstack:  <
]]

player_manager.AddValidModel( "Intruder", "models/humans/intruder/intruder_pm.mdl" )
player_manager.AddValidHands( "Intruder", "models/weapons/c_arms_intruder/c_arms_intruder.mdl", 0, "01000000" )

list.Set( "PlayerOptionsAnimations",  "Intruder", { "pose_standing_02", "pose_standing_03", "pose_standing_04" } )
