-- "lua\\autorun\\boothill_pm.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
player_manager.AddValidModel( "Boothill (Honkai: Star Rail)", "models/hsr/Boothill/Boothill_pm.mdl" )
player_manager.AddValidHands( "Boothill (Honkai: Star Rail)", "models/hsr/Boothill/Boothill_pm_arms.mdl", 0, "00000000" )

local Category = "Honkai: Star Rail"

local NPC =
{
	Name = "Boothill (Friendly)",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/hsr/Boothill/Boothill_f_npc.mdl",
	Category = Category
}

list.Set( "NPC", "boothill_friendly", NPC )

local NPC =
{
	Name = "Boothill (Enemy)",
	Class = "npc_combine_s",
	Numgrenades = "5",
	Model = "models/hsr/Boothill/Boothill_h_npc.mdl",
	Category = Category
}

list.Set( "NPC", "boothill_enemy", NPC )