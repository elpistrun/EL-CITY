--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/matproxy/sky_paint.lua <
    > Callstack:  <
]]


matproxy.Add( {
	name = "SkyPaint",

	init = function( self, mat, values )
	end,

	bind = function( self, mat, ent )

		local skyPaint = g_SkyPaint
		if ( not IsValid( skyPaint ) ) then return end

		mat:SetVector( "$TOPCOLOR",		skyPaint:GetDTVector( 0 ) )
		mat:SetVector( "$BOTTOMCOLOR",	skyPaint:GetDTVector( 1 ) )
		mat:SetVector( "$DUSKCOLOR",	skyPaint:GetDTVector( 4 ) )
		mat:SetFloat( "$DUSKSCALE",		skyPaint:GetDTFloat( 2 ) )
		mat:SetFloat( "$DUSKINTENSITY",	skyPaint:GetDTFloat( 3 ) )
		mat:SetFloat( "$FADEBIAS",		skyPaint:GetDTFloat( 0 ) )
		mat:SetFloat( "$HDRSCALE",		skyPaint:GetDTFloat( 1 ) )

		mat:SetVector( "$SUNNORMAL",	skyPaint:GetDTVector( 2 ) )
		mat:SetVector( "$SUNCOLOR",		skyPaint:GetDTVector( 3 ) )
		mat:SetFloat( "$SUNSIZE",		skyPaint:GetDTFloat( 4 ) )

		if ( not skyPaint:GetDTBool( 0 ) ) then
			return mat:SetInt( "$STARLAYERS", 0 )
		end

		mat:SetInt( "$STARLAYERS",		skyPaint:GetDTInt( 0 ) )

		local star = skyPaint:GetDTAngle( 0 )
		mat:SetFloat( "$STARSCALE",		star.p )
		mat:SetFloat( "$STARFADE",		star.y )
		mat:SetFloat( "$STARPOS",		star.r * RealTime() )

		mat:SetTexture( "$STARTEXTURE",	skyPaint:GetDTString( 0 ) )

	end
} )

