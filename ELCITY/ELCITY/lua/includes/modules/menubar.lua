--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/modules/menubar.lua <
    > Callstack: lua/includes/init.lua:69 <
]]


menubar = {}

function menubar.Init()

	menubar.Control = vgui.Create( "DMenuBar" )
	menubar.Control:Dock( TOP )
	menubar.Control:SetVisible( false )
	
	hook.Run( "PopulateMenuBar", menubar.Control )

end

function menubar.ParentTo( pnl )

	// I don't like this
	if ( !IsValid( menubar.Control ) ) then
		menubar.Init()
	end

	menubar.Control:SetParent( pnl )
	menubar.Control:MoveToBack()
	menubar.Control:SetHeight( 30 )
	menubar.Control:SetVisible( true )

end

function menubar.IsParent( pnl )

	return menubar.Control:GetParent() == pnl

end


hook.Add( "OnGamemodeLoaded", "CreateMenuBar", function()

	menubar.Init()

end )

