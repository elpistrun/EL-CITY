--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/playeryukicompa.lua <
    > Callstack:  <
]]

player_manager.AddValidModel( "Compa","models/player_compa.mdl" )
player_manager.AddValidHands( "Compa", "models/compa_arms.mdl", 0, "00000000" )

--Add NPC
local NPC =
{
	Name = "Compa",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "Models/npc_compa.mdl",
	Category = "Neptunia NPCs"
}

list.Set( "NPC", "npc_compa", NPC )



