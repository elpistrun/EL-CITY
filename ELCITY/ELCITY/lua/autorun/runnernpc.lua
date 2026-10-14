--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/runnernpc.lua <
    > Callstack:  <
]]

local Category = "the runners"

local NPC =
{
	Name = "the runner (fren)",
	Class = "npc_citizen",
	Model = "models/runner/playerm/npc/runnernpc.mdl",
	KeyValues = {citizentype = 4},
	Weapons = { "weapon_shotgun", "weapon_ar2" },
	Health = "110",
	Category = Category
}

    list.Set( "NPC", "runner_friendly", NPC )

local NPC =
{
	Name = "the runner (not fren)",
	Class = "npc_combine_s",
	Numgrenades = "4",
	Model = "models/runner/playerm/npc/runnernpc.mdl",
	Weapons = { "weapon_shotgun" , "weapon_ar2" },
	Health = "110",
	Category = Category
}

	list.Set( "NPC", "runner_enemy", NPC )
