-- "lua\\autorun\\security_service_of_ukraine.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Security Service of Ukraine", "models/player/security_service_of_ukraine.mdl" )

local Category = "Azov, Right Sector, Security Serivce of Ukraine"

local NPC =
{
	Name = "Security Service of Ukraine (Friendly)",
	Class = "npc_citizen",
	Health = "100",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/security_service_of_ukraine_f.mdl",
	Category = Category
}

list.Set( "NPC", "security_service_of_ukraine_friendly", NPC )

local NPC =
{
	Name = "Security Service of Ukraine (Enemy)",
	Class = "npc_combine_s",
	Health = "100",
	Numgrenades = "4",
	Model = "models/npc/security_service_of_ukraine_e.mdl",
	Category = Category
}

list.Set( "NPC", "security_service_of_ukraine_enemy", NPC )
