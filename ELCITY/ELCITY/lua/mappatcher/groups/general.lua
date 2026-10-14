--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/groups/general.lua <
    > Callstack: lua/mappatcher/groups.lua:39
lua/mappatcher/groups.lua:42
[C]:-1
lua/autorun/mappatcher.lua:87 <
]]

-- These should be rewriten by ulx.lua, if ULX is enabled
MapPatcher.Groups.Register("everyone", function(ply) return true end, "#mappatcher.groups.general.everyone" )
MapPatcher.Groups.Register("admin", function(ply) return ply:IsAdmin() end, "#mappatcher.groups.general.admin" )
MapPatcher.Groups.Register("superadmin", function(ply) return ply:IsSuperAdmin() end, "#mappatcher.groups.general.superadmin" )

