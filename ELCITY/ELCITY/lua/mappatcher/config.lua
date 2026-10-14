--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/config.lua <
    > Callstack: lua/mappatcher/shared.lua:2
[C]:-1
lua/autorun/mappatcher.lua:86 <
]]

local CONFIG = {}

--------------------------------------------------------------------------------
-- CONFIG BEGIN ----------------------------------------------------------------
--------------------------------------------------------------------------------

-- If you have ULX or ServerGuard installed, you don't need to change any access 
-- configs bellow, you can modify command access directly through admin panel.

CONFIG.AccessSuperAdmin = true -- Change it to true to allow superadmins
CONFIG.AccessAdmin      = false -- Change it to true to allow admins
CONFIG.AccessSteamID = {        -- Add/replace steamid's to give access to individual players
    "STEAM_0:0:0",
    "STEAM_0:0:0",
}
CONFIG.AccessUserGroup = {
    --"owner",
    --"superadmin",
}

-- Advanced --------------------------------------------------------------------

-- Loads map clip brushes as single renderable object
CONFIG.MapClipBrushesAsSingleObject = true 

--------------------------------------------------------------------------------
-- CONFIG END ------------------------------------------------------------------
--------------------------------------------------------------------------------

return CONFIG

