--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/dexter_morgan_pm.lua <
    > Callstack:  <
]]

player_manager.AddValidModel( "Dexter Morgan", "models/Dexter_Morgan.mdl" )
player_manager.AddValidHands( "Dexter Morgan", "models/Dexter_Morgan_Arms.mdl", 0, "0" )

local Category = "Commissions"
local NPC = {    Name = "Dexter Morgan", 
                Class = "npc_citizen", 
                Model = "models/Dexter_Morgan.mdl",                 
Health = "250",                 KeyValues = { citizentype = 4 },                 
Category = Category }  list.Set( "NPC", "Dexter_Morgan_npc", NPC ) 
