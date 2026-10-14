--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/mymy_npcs.lua <
    > Callstack:  <
]]

local Category = "Ongezellig - Mymy"

local NPC = {   Name = "mymy - Friendly", 
                Class = "npc_citizen",
                Model = "models/blop/mymy/mymy_npc.mdl", 
                Health = "100", 
                KeyValues = { citizentype = 4 }, 
                Weapons = { "/models/weapons/c_smg1.mdl" }, 
                Category = Category }
                               
list.Set( "NPC", "npc_mymy_ally", NPC )

local Category = "Ongezellig - Mymy"
 
local NPC = {   Name = "mymy - Hostile", 
                Class = "npc_combine",
                Model = "models/blop/mymy/mymy_npc.mdl",
                Health = "100", 
                Weapons = { "/models/weapons/c_smg1.mdl" }, 
                Category = Category }
                               
list.Set( "NPC", "npc_mymy_hostile", NPC )

