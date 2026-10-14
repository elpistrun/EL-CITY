--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/intruder_npc.lua <
    > Callstack:  <
]]

local NPC = { 	Name = "Intruder",
				Class = "npc_citizen",
				Model = "models/humans/intruder/intruder.mdl",
				Health = "100",
				Weapons = {""},
				KeyValues = { citizentype = 4 },
				Category = "Betabine's NPCs" }

list.Set( "NPC", "npc_intruder", NPC )

