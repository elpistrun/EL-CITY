--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/derma/derma_menus.lua <
    > Callstack: lua/derma/init.lua:49 <
]]


local tblOpenMenus = {}

function RegisterDermaMenuForClose( dmenu )

	table.insert( tblOpenMenus, dmenu )

end

function DermaMenu( parentmenu, parent )

	if ( !parentmenu ) then CloseDermaMenus() end

	return vgui.Create( "DMenu", parent )

end

function CloseDermaMenus()

	for k, dmenu in pairs( tblOpenMenus ) do

		if ( IsValid( dmenu ) ) then

			dmenu:SetVisible( false )
			if ( dmenu:GetDeleteSelf() ) then
				dmenu:Remove()
			end

		end

	end

	tblOpenMenus = {}
	hook.Run( "CloseDermaMenus" )

end

--
-- Here we detect when the mouse is pressed on another panel
-- This allows us to close the menus.
--
local function DermaDetectMenuFocus( panel, mousecode )

	if ( IsValid( panel ) ) then

		if ( panel.m_bIsMenuComponent ) then return end

		-- Is the parent a menu?
		return DermaDetectMenuFocus( panel:GetParent(), mousecode )

	end

	CloseDermaMenus()

end

hook.Add( "VGUIMousePressed", "DermaDetectMenuFocus", DermaDetectMenuFocus )

