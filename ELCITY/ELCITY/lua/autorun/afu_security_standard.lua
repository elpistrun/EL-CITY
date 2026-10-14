-- "lua\\autorun\\afu_security_standard.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Ukrainian Soldier", "models/player/afu_security_standard.mdl" )

local Category = "Armed Forces of Ukraine"

local NPC =
{
	Name = "Ukrainian Soldier (Friendly)",
	Class = "npc_citizen",
	Health = "100",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/afu_security_standard_f.mdl",
	Category = Category
}

list.Set( "NPC", "afu_security_standard_friendly", NPC )

local NPC =
{
	Name = "Ukrainian Soldier (Enemy)",
	Class = "npc_combine_s",
	Health = "100",
	Numgrenades = "4",
	Model = "models/npc/afu_security_standard_e.mdl",
	Category = Category
}

list.Set( "NPC", "afu_security_standard_enemy", NPC )
