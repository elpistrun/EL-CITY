-- "lua\\autorun\\gfl2_lenna_energetic_magic.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--Add Playermodel
player_manager.AddValidModel( "Girls Frontline 2 Lenna Energetic Magic (UMP9)", "models/player/gfl2_lenna_energetic_magic.mdl" )
player_manager.AddValidHands( "Girls Frontline 2 Lenna Energetic Magic (UMP9)", "models/arms/gfl2_lenna_energetic_magic_arms.mdl", 0, "00000000" )

local Category = "Girls Frontline 2"

local NPC =
{
	Name = "Lenna Energetic Magic (Friendly)",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/npc/gfl2_lenna_energetic_magic_npc.mdl",
	Category = Category
}

list.Set( "NPC", "gfl2_lenna_energetic_magic_friendly", NPC )

local NPC =
{
	Name = "Lenna Energetic Magic (Enemy)",
	Class = "npc_combine_s",
	Numgrenades = "4",
	Model = "models/npc/gfl2_lenna_energetic_magic_npc.mdl",
	Category = Category
}

list.Set( "NPC", "gfl2_lenna_energetic_magic_enemy", NPC )
