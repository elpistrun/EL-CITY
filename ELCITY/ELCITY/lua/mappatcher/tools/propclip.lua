--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/tools/propclip.lua <
    > Callstack: lua/mappatcher/shared.lua:43
lua/mappatcher/shared.lua:65
[C]:-1
lua/autorun/mappatcher.lua:86 <
]]

local TOOL = TOOL
--------------------------------------------------------------------------------
TOOL.Base = "base_brush"
TOOL.Description = "Doesn't let entities pass through that has prop physics (e.g. props, grenades, etc)."
TOOL.VisibleInMenu = true
TOOL.MenuPriority = 3000
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(139,69,19,200)
TOOL.TextureText = "#mappatcher.tools.propclip.title"
--------------------------------------------------------------------------------
function TOOL:EntSetup( ent )
    ent:SetSolidFlags( FSOLID_CUSTOMBOXTEST )
end

function TOOL:EntStartTouch( ent )
end

function TOOL:EntShouldCollide( ent )
    return ent:GetMoveType() == MOVETYPE_VPHYSICS
end

