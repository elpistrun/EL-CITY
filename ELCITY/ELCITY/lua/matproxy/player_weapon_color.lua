--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/matproxy/player_weapon_color.lua <
    > Callstack:  <
]]


local megaGravClr = Vector( 0.4, 1, 1 )

matproxy.Add( {
	name = "PlayerWeaponColor",

	init = function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind = function( self, mat, ent )

		if ( !IsValid( ent ) ) then return end

		local owner = ent:GetOwner()
		if ( !IsValid( owner ) or !owner:IsPlayer() ) then return end

		local col = owner:GetWeaponColor()
		if ( !isvector( col ) ) then return end

		-- A hack for the mega gravity gun
		local wep = owner:GetActiveWeapon()
		if ( IsValid( wep ) && wep:GetClass() == "weapon_physcannon" && !wep:IsScripted() ) then
			col = megaGravClr
		end

		local mul = ( 1 + math.sin( CurTime() * 5 ) ) * 0.5

		mat:SetVector( self.ResultTo, col + col * mul )

	end
} )

