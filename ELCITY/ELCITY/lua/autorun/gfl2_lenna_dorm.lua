-- "lua\\autorun\\gfl2_lenna_dorm.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Girls Frontline 2 Lenna Dorm (UMP9)", "models/player/gfl2_lenna_dorm.mdl" )
player_manager.AddValidHands( "Girls Frontline 2 Lenna Dorm (UMP9)", "models/arms/gfl2_lenna_dorm_arms.mdl", 0, "00000000" )

local Category = "Girls Frontline 2"

local NPC =
{
	Name = "Lenna Dorm (Friendly)",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/gfl2_lenna_dorm_npc.mdl",
	Category = Category
}

list.Set( "NPC", "gfl2_lenna_dorm_friendly", NPC )

local NPC =
{
	Name = "Lenna Dorm (Enemy)",
	Class = "npc_combine_s",
	Numgrenades = "4",
	Model = "models/npc/gfl2_lenna_dorm_npc.mdl",
	Category = Category
}

list.Set( "NPC", "gfl2_lenna_dorm_enemy", NPC )
