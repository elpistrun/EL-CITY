--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/client/globals.lua <
    > Callstack: lua/includes/init.lua:117 <
]]



if ( SERVER ) then return end


function ScreenScale( width )
	return width * ( ScrW() / 640.0 )
end

function ScreenScaleH( height )
	return height * ( ScrH() / 480.0 )
end

SScale = ScreenScale

