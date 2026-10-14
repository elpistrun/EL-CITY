--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/oogachakababy_pm.lua <
    > Callstack:  <
]]





player_manager.AddValidModel( "Oogachaka Baby",     "models/player/norrland/oogachakaBaby_pm.mdl" );
list.Set( "PlayerOptionsModel", "Oogachaka Baby",   "models/player/norrland/oogachakaBaby_pm.mdl" );
player_manager.AddValidHands( "Oogachaka Baby", "models/player/norrland/arms/oogachakaBaby_arms.mdl", 0, "00000000" )
--Add NPC
local Category = "Oogachaka Baby"

local NPC = { 	Name = "Oogachaka Baby (Ally)", 
				Class = "npc_citizen",
				Model = "models/player/norrland/oogachakaBaby_pm.mdl",
				Health = "10",
                KeyValues = { citizentype = 4 }, 
                Weapons = { "weapon_pistol" }, 
                Category = Category }

list.Set( "NPC", "Oogachaka Baby Ally", NPC )

local Category = "Oogachaka Baby"

local NPC = { 	Name = "Oogachaka Baby (Hostile)", 
				Class = "npc_combine_s",
				Model = "models/player/norrland/oogachakaBaby_pm.mdl",
				Health = "10",
                KeyValues = { citizentype = 4 }, 
                Weapons = { "weapon_pistol" }, 
                Category = Category }

list.Set( "NPC", "Oogachaka Baby Hostile", NPC )
