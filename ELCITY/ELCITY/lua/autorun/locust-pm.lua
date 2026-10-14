--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/locust-pm.lua <
    > Callstack:  <
]]

player_manager.AddValidModel( "Locust", "models/doumty/locust/playermodel/locust_pm.mdl" )
list.Set( "PlayerOptionsModel", "Locust", "models/doumty/locust/playermodel/locust_pm.mdl" )
player_manager.AddValidHands( "Locust", "models/doumty/locust/playermodel/locust_arms.mdl", 0, "00000000")

local Category = "Doumty's NPC"

local NPC = 
{
    Name = "T.O.E Locust - Friendly",
    Class = "npc_citizen",
	Model = "models/doumty/locust/playermodel/locust_pm.mdl",
	Health = "250",
	KeyValues = { citizentype = 4 },
	Category = Category
}
list.Set( "NPC", "locust_friendly", NPC )

local NPC = 
{
    Name = "T.O.E Locust - Hostile",
	Class = "npc_combine_s",
	Model = "models/doumty/locust/playermodel/locust_pm.mdl",
	Health = "250",
	Category = Category
}
list.Set( "NPC", "locust_hostile", NPC )

