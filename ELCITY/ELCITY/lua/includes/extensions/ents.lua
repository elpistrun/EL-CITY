--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/ents.lua <
    > Callstack: lua/includes/init.lua:101 <
]]


function ents.FindByClassAndParent( classname, entity )

	if ( !IsValid( entity ) ) then return end

	local out = {}

	for k, v in ipairs( ents.FindByClass( classname ) ) do

		if ( v:GetParent() == entity ) then
			table.insert( out, v )
		end

	end

	if ( out[1] == nil ) then return end

	return out

end

