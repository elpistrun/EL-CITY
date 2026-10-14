--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/sh_jonkler.lua <
    > Callstack:  <
]]

AddCSLuaFile() 

local function AddPlayerModel( name, modelPath )
    list.Set( "PlayerOptionsModel", name, modelPath )
    player_manager.AddValidModel( name, modelPath )
end

AddPlayerModel( "Jonkler", "models/player/jonkler.mdl" )


--Add NPC
local Category = "Jonkler"

local NPC = { 	Name = "Hostile Jonkler", 
				Class = "npc_combine_s",
				Model = "models/player/jonkler.mdl",
				Health = "200",
				Squadname = "PLAGUE",
				Numgrenades = "67",
                Category = Category }

list.Set( "NPC", "Hostile_Jonkler", NPC )

local NPC = { 	Name = "Friendly Jonkler", 
				Class = "npc_citizen",
				Model = "models/player/jonkler.mdl",
				Health = "200",
				KeyValues = { citizentype = 4 },
                Category = Category }

list.Set( "NPC", "Friendly_Jonkler", NPC )
				

