-- "lua\\autorun\\right_sector.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Right Sector", "models/player/right_sector.mdl" )

local Category = "Azov, Right Sector, Security Serivce of Ukraine"

local NPC =
{
	Name = "Right Sector (Friendly)",
	Class = "npc_citizen",
	Health = "70",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/right_sector_f.mdl",
	Category = Category
}

list.Set( "NPC", "right_sector_friendly", NPC )

local NPC =
{
	Name = "Right Sector (Enemy)",
	Class = "npc_combine_s",
	Health = "70",
	Numgrenades = "4",
	Model = "models/npc/right_sector_e.mdl",
	Category = Category
}

list.Set( "NPC", "right_sector_enemy", NPC )
