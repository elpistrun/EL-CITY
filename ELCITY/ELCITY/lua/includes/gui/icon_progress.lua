--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/gui/icon_progress.lua <
    > Callstack: lua/includes/init.lua:78 <
]]


local g_Progress = nil

hook.Add( "SpawniconGenerated", "SpawniconGenerated", function( lastmodel, imagename, modelsleft )

	if ( !IsValid( g_Progress ) ) then

		g_Progress = vgui.Create( "DPanel" )
		g_Progress:SetSize( 64 + 10, 64 + 10 + 20 )
		g_Progress:SetBackgroundColor( Color( 0, 0, 0, 100 ) )
		g_Progress:SetDrawOnTop( true )
		g_Progress:DockPadding( 5, 0, 5, 5 )
		g_Progress.Think = function()

			if ( SysTime() - g_Progress.LastTouch < 3 ) then return end

			g_Progress:Remove()
			g_Progress.LastTouch = SysTime()

		end

		local label = g_Progress:Add( "DLabel" )
		label:Dock( BOTTOM )
		label:SetText( "remaining" )
		label:SetTextColor( color_white )
		label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
		label:SetContentAlignment( 5 )
		label:SetHeight( 14 )
		label:SetFont( "DefaultSmall" )

		g_Progress.Label = g_Progress:Add( "DLabel" )
		g_Progress.Label:Dock( BOTTOM )
		g_Progress.Label:SetTextColor( color_white )
		g_Progress.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
		g_Progress.Label:SetContentAlignment( 5 )
		g_Progress.Label:SetFont( "DermaDefaultBold" )
		g_Progress.Label:SetHeight( 14 )

		g_Progress.icon = vgui.Create( "DImage", g_Progress )
		g_Progress.icon:SetSize( 64, 64 )
		g_Progress.icon:Dock( TOP )

	end

	g_Progress.LastTouch = SysTime()

	imagename = imagename:Replace( "materials\\", "" )
	imagename = imagename:Replace( "materials/", "" )

	g_Progress.icon:SetImage( imagename )

	g_Progress:AlignRight( 10 )
	g_Progress:AlignBottom( 10 )

	g_Progress.Label:SetText( modelsleft )

end )

