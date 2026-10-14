-- "lua\\autorun\\afu_security_light.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Ukrainian Soldier Light", "models/player/afu_security_light.mdl" )

local Category = "Armed Forces of Ukraine"

local NPC =
{
	Name = "Ukrainian Soldier Light (Friendly)",
	Class = "npc_citizen",
	Health = "70",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/afu_security_light_f.mdl",
	Category = Category
}

list.Set( "NPC", "afu_security_light_friendly", NPC )

local NPC =
{
	Name = "Ukrainian Soldier Light (Enemy)",
	Class = "npc_combine_s",
	Health = "70",
	Numgrenades = "4",
	Model = "models/npc/afu_security_light_e.mdl",
	Category = Category
}

list.Set( "NPC", "afu_security_light_enemy", NPC )
