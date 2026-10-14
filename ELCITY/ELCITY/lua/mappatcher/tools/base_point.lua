--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/tools/base_point.lua <
    > Callstack: lua/mappatcher/shared.lua:43
lua/mappatcher/shared.lua:65
[C]:-1
lua/autorun/mappatcher.lua:86 <
]]

local TOOL = TOOL
--------------------------------------------------------------------------------
TOOL.Base = "base"
--------------------------------------------------------------------------------
function TOOL:ShouldSave( )
    if self:IsObject() and self.point and self.point ~= Vector() then
        return true
    end
    return false
end
--------------------------------------------------------------------------------
function TOOL:ObjectCreated()
    self.point = nil
end

function TOOL:LeftClick( pos )
    self.point = pos
end
--------------------------------------------------------------------------------
function TOOL:WriteToBuffer( buffer )
    buffer:WriteVector( self.point or Vector() )
end

function TOOL:ReadFromBuffer( buffer, len )
    self.point = buffer:ReadVector( )
end

