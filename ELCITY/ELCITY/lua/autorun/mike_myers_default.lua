--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/mike_myers_default.lua <
    > Callstack:  <
]]

player_manager.AddValidModel( "Mike Myers", "models/player/dewobedil/mike_myers/default_p.mdl" );
player_manager.AddValidHands( "Mike Myers", "models/player/dewobedil/mike_myers/c_arms/default_p.mdl", 0, "00000000" )

local Category = "Halloween"

local NPC =
{
	Name = "Mike Myers(Friendly)",
	Class = "npc_citizen",
	Health = "100",
	KeyValues = { citizentype = 4 },
	Model = "models/player/dewobedil/mike_myers/default_f.mdl",
	Category = Category
}

list.Set( "NPC", "npc_mike_myers_default_f", NPC )

local NPC =
{
	Name = "Mike Myers(Enemy)",
	Class = "npc_combine_s",
	Health = "100",
	Numgrenades = "4",
	Model = "models/player/dewobedil/mike_myers/default_e.mdl",
	Category = Category
}

list.Set( "NPC", "npc_mike_myers_default_e", NPC )

if SERVER then
	resource.AddWorkshop("791363115")
end
