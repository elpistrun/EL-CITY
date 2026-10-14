-- "lua\\autorun\\azov.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Azov", "models/player/azov.mdl" )

local Category = "Azov, Right Sector, Security Serivce of Ukraine"

local NPC =
{
	Name = "Azov (Friendly)",
	Class = "npc_citizen",
	Health = "150",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/azov_f.mdl",
	Category = Category
}

list.Set( "NPC", "azov_friendly", NPC )

local NPC =
{
	Name = "Azov (Enemy)",
	Class = "npc_combine_s",
	Health = "150",
	Numgrenades = "4",
	Model = "models/npc/azov_e.mdl",
	Category = Category
}

list.Set( "NPC", "azov_enemy", NPC )
