--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/properties/editentity.lua <
    > Callstack: lua/autorun/properties.lua:12 <
]]


AddCSLuaFile()

properties.Add( "editentity", {
	MenuLabel = "#entedit",
	Order = 90001,
	PrependSpacer = true,
	MenuIcon = "icon16/pencil.png",

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( !ent.Editable ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "editentity", ent ) ) then return false end

		return true

	end,

	Action = function( self, ent )

		if ( !IsValid( ent ) ) then return end

		local printName = ent.PrintName

		if ( !isstring( printName ) ) then
			printName = ent:GetClass()
		end

		printName = language.GetPhrase( printName )
		printName = string.format( "%s [%d]", printName, ent:EntIndex() )

		local window = g_ContextMenu:Add( "DFrame" )
		window:SetSize( 320, 400 )
		window:SetTitle( printName )
		window:Center()
		window:SetSizable( true )

		local control = window:Add( "DEntityProperties" )
		control:SetEntity( ent )
		control:Dock( FILL )

		control.OnEntityLost = function()

			window:Remove()

		end

	end
} )

