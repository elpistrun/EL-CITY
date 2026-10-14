--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/tools/remove.lua <
    > Callstack: lua/mappatcher/shared.lua:43
lua/mappatcher/shared.lua:65
[C]:-1
lua/autorun/mappatcher.lua:86 <
]]

local TOOL = TOOL
--------------------------------------------------------------------------------
TOOL.Base = "base_brush"
TOOL.Description = "Removes any entities that touches this brush. Except for players, in which they would just silently die."
TOOL.VisibleInMenu = true
TOOL.MenuPriority = 10000
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(255,0,0,200)
TOOL.TextureText = "#mappatcher.tools.remove.title"
--------------------------------------------------------------------------------
function TOOL:EntSetup( ent )
    ent:SetSolidFlags( FSOLID_CUSTOMBOXTEST )
    if SERVER then ent:SetTrigger( true ) end
end

function TOOL:EntStartTouch( ent )
    if ent.MapPatcherObject then return end
    
    if ent:IsPlayer() then
        ent:KillSilent()
    else
        ent:Remove()
    end
end

function TOOL:EntShouldCollide( ent )
    return false
end

