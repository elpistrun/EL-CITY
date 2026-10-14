--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/coroutine.lua <
    > Callstack: lua/includes/init.lua:112 <
]]


--
-- The client needs this file
--
AddCSLuaFile()

if ( !coroutine ) then return end

--
-- Name: coroutine.wait
-- Desc: Yield's the coroutine for so many seconds before returning.\n\nThis should only be called in a coroutine. This function uses CurTime() - not RealTime().
-- Arg1: number|seconds|The number of seconds to wait
-- Ret1: 
--
function coroutine.wait( seconds )

	local endtime = CurTime() + seconds
	while ( true ) do

		if ( endtime < CurTime() ) then return end

		coroutine.yield()

	end
	  
end

