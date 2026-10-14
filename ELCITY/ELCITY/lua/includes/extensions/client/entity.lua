--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/client/entity.lua <
    > Callstack: lua/includes/init.lua:116 <
]]


if ( SERVER ) then return end

local meta = FindMetaTable( "Entity" )
if ( !meta ) then return end


--
-- You can set the render angles and render origin on
-- any entity. It will then render the entity at that
-- origin using those angles.
--
-- Set them to nil if you don't want to override anything.
--

AccessorFunc( meta, "m_RenderAngles", "RenderAngles" )
AccessorFunc( meta, "m_RenderOrigin", "RenderOrigin" )

