--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/jmod_eft_inventory.lua <
    > Callstack:  <
]]

local lcl = SERVER and AddCSLuaFile or include
local lsv = SERVER and include or function() end
local lsh = function(path) lsv(path) lcl(path) end

lsv('jmod_eft/inventory/sv_inventory.lua')
lcl('jmod_eft/inventory/cl_gui.lua')
-- lsh('')
