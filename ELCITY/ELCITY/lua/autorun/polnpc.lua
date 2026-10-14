--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/polnpc.lua <
    > Callstack:  <
]]

local Category = "Police Force Hostile"
local NPC = { 	Name = "Deputy", 
				Class = "npc_combine_s",	
				Model = "models/GTA5/DeputyPOL.mdl",
				Health = 100,
				Category = Category	}
list.Set( "NPC", "npc_deputy", NPC )


local Category = "Police Force Hostile"
local NPC = { 	Name = "LSPD Officer", 
				Class = "npc_combine_s",
				Model = "models/GTA5/CityCopPOL.mdl",
				Health = 100,
				Category = Category	}
list.Set( "NPC", "npc_citycop", NPC )


local Category = "Police Force Hostile"
local NPC = { 	Name = "LSPD Armored Officer", 
				Class = "npc_combine_s",
				Model = "models/GTA5/ArmoredCityCopPOL.mdl",
				Health = 150,
				Category = Category	}
list.Set( "NPC", "npc_armoredcitycop", NPC )

local Category = "Police Force Hostile"
local NPC = { 	Name = "Swat", 
				Class = "npc_combine_s",
				Model = "models/GTA5/SwatPOL.mdl",
				Health = 150,
				Category = Category	}
list.Set( "NPC", "npc_swat", NPC )

local Category = "Police Force Hostile"
local NPC = { 	Name = "Swat Tactical", 
				Class = "npc_combine_s",
				Model = "models/GTA5/SwatCOM.mdl",
				Health = 150,
				Category = Category	}
list.Set( "NPC", "npc_swatcombine", NPC )



local Category = "Police Force Friendly"
local NPC = { 	Name = "Deputy", 
				Class = "npc_citizen",	
				KeyValues = { citizentype = 4 } ,
				Model = "models/GTA5/npc/Deputy.mdl",
				Health = 100,
				Category = Category	}
list.Set( "NPC", "npc_deputy2", NPC )


local Category = "Police Force Friendly"
local NPC = { 	Name = "LSPD Officer", 
				Class = "npc_citizen",	
				KeyValues = { citizentype = 4 } ,
				Model = "models/GTA5/npc/CityCop.mdl",
				Health = 100,
				Category = Category	}
list.Set( "NPC", "npc_citycop2", NPC )


local Category = "Police Force Friendly"
local NPC = { 	Name = "LSPD Armored Officer", 
				Class = "npc_citizen",	
				KeyValues = { citizentype = 4 } ,
				Model = "models/GTA5/npc/ArmoredCityCop.mdl",
				Health = 100,
				Category = Category	}
list.Set( "NPC", "npc_armoredcitycop2", NPC )



local Category = "Police Force Friendly"
local NPC = { 	Name = "Swat", 
				Class = "npc_citizen",	
				KeyValues = { citizentype = 4 } ,
				Model = "models/GTA5/npc/swat.mdl",
				Health = 100,
				Category = Category	}
list.Set( "NPC", "npc_swat2", NPC )




