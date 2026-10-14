--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/groups/ulx.lua <
    > Callstack: lua/mappatcher/groups.lua:39
lua/mappatcher/groups.lua:42
[C]:-1
lua/autorun/mappatcher.lua:87 <
]]


local check_user = function(ply, group)
	if not IsValid(ply) then return false end

	return ply:CheckGroup(group)
end

hook.Add("UCLChanged", "MapPatcher_Groups_ULX", function()
	for group, perms in pairs(ULib.ucl.groups) do
		MapPatcher.Groups.Register(group, check_user, "[ULX] "..group )
	end
end)
