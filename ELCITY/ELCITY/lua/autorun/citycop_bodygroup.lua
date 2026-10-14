--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/citycop_bodygroup.lua <
    > Callstack:  <
]]

local mdl = { "models/gta5/player/citycop.mdl",
		"models/gta5/citycoppol.mdl" }	
hook.Add("PlayerSpawnedNPC","RandomBodyGroupCityCop",function(ply,npc)
	if table.HasValue( mdl, npc:GetModel() )					
		then npc:SetSkin( math.random(0,1) )
			npc:SetBodygroup( 2, math.random(0,1) );
    end
end)
