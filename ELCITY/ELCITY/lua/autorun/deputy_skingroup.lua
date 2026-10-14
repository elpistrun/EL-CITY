--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/deputy_skingroup.lua <
    > Callstack:  <
]]

local mdl = { "models/gta5/player/deputy.mdl",
		"models/gta5/deputypol.mdl" }
hook.Add("PlayerSpawnedNPC","RandomBodyGroupDeputy",function(ply,npc)
	if table.HasValue( mdl, npc:GetModel() )					
		then npc:SetSkin( math.random(0,1) );
    end
end)
