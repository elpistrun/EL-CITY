-- "lua\\autorun\\afu_security_heavy.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Ukrainian Soldier Heavy", "models/player/afu_security_heavy.mdl" )

local Category = "Armed Forces of Ukraine"

local NPC =
{
	Name = "Ukrainian Soldier Heavy (Friendly)",
	Class = "npc_citizen",
	Health = "150",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/afu_security_heavy_f.mdl",
	Category = Category
}

list.Set( "NPC", "afu_security_heavy_friendly", NPC )

local NPC =
{
	Name = "Ukrainian Soldier Heavy (Enemy)",
	Class = "npc_combine_s",
	Health = "150",
	Numgrenades = "4",
	Model = "models/npc/afu_security_heavy_e.mdl",
	Category = Category
}

list.Set( "NPC", "afu_security_heavy_enemy", NPC )
