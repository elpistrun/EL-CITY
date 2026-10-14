--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/vector.lua <
    > Callstack: lua/includes/init.lua:108 <
]]

local meta = FindMetaTable( "Vector" )

-- Nothing in here, still leaving this file here just in case

--[[---------------------------------------------------------
	Converts Vector To Color - alpha precision lost, must reset
-----------------------------------------------------------]]
function meta:ToColor( )

	return Color( self.x * 255, self.y * 255, self.z * 255 )

end

