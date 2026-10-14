--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/file.lua <
    > Callstack: lua/includes/init.lua:97 <
]]


function file.Read( filename, path )

	if ( path == true ) then path = "GAME" end
	if ( path == nil || path == false ) then path = "DATA" end

	local f = file.Open( filename, "rb", path )
	if ( !f ) then return nil end

	local str = f:Read( f:Size() )

	f:Close()

	if ( !str ) then str = "" end
	return str

end

function file.Write( filename, contents )

	local f = file.Open( filename, "wb", "DATA" )
	if ( !f ) then return false end

	f:Write( contents )
	f:Close()

	return true

end

function file.Append( filename, contents )

	local f = file.Open( filename, "ab", "DATA" )
	if ( !f ) then return false end

	f:Write( contents )
	f:Close()

	return true

end

