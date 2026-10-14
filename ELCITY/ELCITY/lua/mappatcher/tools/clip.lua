--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/tools/clip.lua <
    > Callstack: lua/mappatcher/shared.lua:43
lua/mappatcher/shared.lua:65
[C]:-1
lua/autorun/mappatcher.lua:86 <
]]

local TOOL = TOOL
--------------------------------------------------------------------------------
TOOL.Base = "base_brush"
TOOL.Description = "Collides with everything."
TOOL.VisibleInMenu = true
TOOL.MenuPriority = 6000
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(100,100,100,200)
TOOL.TextureText = "#mappatcher.tools.clip.title"
--------------------------------------------------------------------------------
function TOOL:EntSetup( ent )
    ent:SetSolidFlags( FSOLID_CUSTOMBOXTEST + FSOLID_CUSTOMRAYTEST )
end

function TOOL:EntStartTouch( ent )
end

function TOOL:EntShouldCollide( ent )
    return true
end

