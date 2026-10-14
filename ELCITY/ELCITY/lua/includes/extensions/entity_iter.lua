--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/entity_iter.lua <
    > Callstack: lua/includes/init.lua:96 <
]]


local inext = ipairs( {} )

local EntityCache = nil
function ents.Iterator()

	if ( EntityCache == nil ) then EntityCache = ents.GetAll() end

	return inext, EntityCache, 0

end

local PlayerCache = nil
function player.Iterator()

	if ( PlayerCache == nil ) then PlayerCache = player.GetAll() end

	return inext, PlayerCache, 0

end

-- Called by the engine just before OnEntityCreated & just after EntityRemoved hooks
function InvalidateInternalEntityCache( isPly )

	EntityCache = nil
	if ( isPly ) then PlayerCache = nil end

end

