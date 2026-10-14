--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/modules/baseclass.lua <
    > Callstack: lua/includes/init.lua:15 <
]]



--
-- The baseclass module uses upvalues to give the impression of inheritence.
--
-- At the top of your class file add 
--
-- DEFINE_BASECLASS( "base_class_name" )
--
-- Now the local variable BaseClass will be available.
-- ( in engine DEFINE_BASECLASS is replaced with "local BaseClass = baseclass.Get" )
--
-- Baseclasses are added using baseclass.Set - this is done automatically for:
--
--		> widgets
--		> panels
--		> drive modes
--		> entities
--		> weapons
-- 
-- Classes don't have to be created in any particular order. The system is 
-- designed to work with whatever order the classes are defined.
--
-- The only caveat is that classnames must be unique. 
-- eg Creating a panel and widget with the same name will cause problems.
--

module( "baseclass", package.seeall )

local BaseClassTable = {}

function Get( name )

	if ( ENT )	then ENT.Base = name end
	if ( SWEP ) then SWEP.Base = name end
	
	BaseClassTable[name] = BaseClassTable[name] or {}
	
	return BaseClassTable[name]
	
end

function Set( name, tab )

	if ( !BaseClassTable[name] ) then

		BaseClassTable[name] =  tab

	else

		table.Merge( BaseClassTable[name], tab )
		setmetatable( BaseClassTable[name], getmetatable(tab) )

	end

	BaseClassTable[name].ThisClass = name

end
