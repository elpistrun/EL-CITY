--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/gfrk_gordon_autorun.lua <
    > Callstack:  <
]]


--Add Playermodel
player_manager.AddValidModel( "Gordon Freeman Restored (Game Quality)", "models/gfreakman/gordonf.mdl" )
player_manager.AddValidHands( "Gordon Freeman Restored (Game Quality)", "models/gfreakman/gordonf_hands.mdl", 0, "00000000" )
player_manager.AddValidModel( "Gordon Freeman Restored (Citizen)", "models/gfreakman/gordonf_cit.mdl" )

player_manager.AddValidModel( "Gordon Freeman Restored", "models/gfreakman/gordonf_highpoly.mdl" )
player_manager.AddValidHands( "Gordon Freeman Restored", "models/gfreakman/gordonf_hands.mdl", 0, "00000000" )
if SERVER then
end

local gfreeman =
{
	Name = "Gordon Freeman",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/gfreakman/gordonf_highpoly.mdl",
	Category = "Gordon Freeman Restored"
}

list.Set( "NPC", "npc_gordon_restored", gfreeman )

local gfreeman2 =
{
	Name = "Gordon Freeman (Game Quality)",
	Class = "npc_citizen",
	KeyValues = { citizentype = 4 },
	Model = "models/gfreakman/gordonf.mdl",
	Category = "Gordon Freeman Restored"
}

list.Set( "NPC", "npc_gordon_game", gfreeman2 )
