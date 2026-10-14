--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/ulx/modules/sh/mappatcher.lua <
    > Callstack: addons/l2n3zf6/lua/ulx/cl_init.lua:17
[C]:-1
addons/l2n3zf6/lua/ulib/modules/ulx_init.lua:4
[C]:-1
addons/h9k8rfq2bt5/lua/ulib/cl_init.lua:24
[C]:-1
addons/h9k8rfq2bt5/lua/autorun/ulib_init.lua:5 <
]]

local CATEGORY_NAME = "Map Patcher"

function MapPatcher.ulx_mappatcher( calling_ply )
    MapPatcher.StartEditMode( calling_ply )
end
local ulx_mappatcher = ulx.command( CATEGORY_NAME, "ulx mappatcher", MapPatcher.ulx_mappatcher )
ulx_mappatcher:defaultAccess( ULib.ACCESS_SUPERADMIN )
ulx_mappatcher:help( "Open map patcher editor." )

