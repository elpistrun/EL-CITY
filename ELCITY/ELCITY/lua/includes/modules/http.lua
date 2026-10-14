--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/modules/http.lua <
    > Callstack: lua/includes/init.lua:33 <
]]


local HTTP = HTTP

--[[---------------------------------------------------------
	HTTP Module. Interaction with HTTP.
-----------------------------------------------------------]]
module( "http" )

--[[---------------------------------------------------------

	Get the contents of a webpage.

	Callback should be

	function callback( (args optional), contents, size )

-----------------------------------------------------------]]
function Fetch( url, onsuccess, onfailure, header )

	local request = {
		url			= url,
		method		= "get",
		headers		= header or {},

		success = function( code, body, headers )

			if ( !onsuccess ) then return end

			onsuccess( body, body:len(), headers, code )

		end,

		failed = function( err )

			if ( !onfailure ) then return end

			onfailure( err )

		end
	}

	local success = HTTP( request )
	if ( !success && onfailure ) then onfailure( "HTTP failed" ) end

end

function Post( url, params, onsuccess, onfailure, header )

	local request = {
		url			= url,
		method		= "post",
		parameters	= params,
		headers		= header or {},

		success = function( code, body, headers )

			if ( !onsuccess ) then return end

			onsuccess( body, body:len(), headers, code )

		end,

		failed = function( err )

			if ( !onfailure ) then return end

			onfailure( err )

		end
	}

	local success = HTTP( request )
	if ( !success && onfailure ) then onfailure( "HTTP failed" ) end

end

--[[

Or use HTTP( table )

local request = {
	url			= "http://pastebin.com/raw.php?i=3jsf50nL",
	method		= "post",

	parameters = {
		id			= "548",
		country		= "England"
	}

	success = function( code, body, headers )

		Msg( "Request Successful\n" )
		Msg( "Code: ", code, "\n" )
		Msg( "Body Length:\n", body:len(), "\n" )
		Msg( "Body:\n", body, "\n" )
		PrintTable( headers )

	end,

	failed = function( reason )
		Msg( "Request failed: ", reason, "\n" )
	end
}

HTTP( request )

--]]

