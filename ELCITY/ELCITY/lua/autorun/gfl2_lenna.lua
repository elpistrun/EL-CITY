-- "lua\\autorun\\gfl2_lenna.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Girls Frontline 2 Lenna (UMP9)", "models/player/gfl2_lenna.mdl" )
player_manager.AddValidHands( "Girls Frontline 2 Lenna (UMP9)", "models/arms/gfl2_lenna_arms.mdl", 0, "00000000" )

local Category = "Girls Frontline 2"

local NPC =
{
	Name = "Lenna (Friendly)",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/gfl2_lenna_npc.mdl",
	Category = Category
}

list.Set( "NPC", "gfl2_lenna_friendly", NPC )

local NPC =
{
	Name = "Lenna (Enemy)",
	Class = "npc_combine_s",
	Numgrenades = "4",
	Model = "models/npc/gfl2_lenna_npc.mdl",
	Category = Category
}

list.Set( "NPC", "gfl2_lenna_enemy", NPC )
