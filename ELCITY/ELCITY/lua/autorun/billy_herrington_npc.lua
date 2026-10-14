--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/billy_herrington_npc.lua <
    > Callstack:  <
]]

local Category = "Vinrax NPCS"
local NPC = {
		 		Name = "Billy Herrington", 
				Class = "npc_citizen",
				KeyValues = { citizentype = 4 },
				Model = "models/vinrax/player/Billy_Herrington.mdl",
				Category = Category	
		}
list.Set( "NPC", "npc_billy_friend", NPC )

local Category = "Vinrax NPCS"

local NPC = {
		 		Name = "Billy Herrington Hostile", 
				Class = "npc_combine_s",
				Model = "models/vinrax/player/Billy_Herrington.mdl",
				Category = Category	
		}
list.Set( "NPC", "npc_billy_hostile", NPC )


