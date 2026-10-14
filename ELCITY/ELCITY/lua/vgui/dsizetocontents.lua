--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dsizetocontents.lua <
    > Callstack:  <
]]


local PANEL = {}
AccessorFunc( PANEL, "m_bSizeX", "SizeX", FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizeY", "SizeY", FORCE_BOOL )

function PANEL:Init()

	self:SetMouseInputEnabled( true )

	self:SetSizeX( true )
	self:SetSizeY( true )

end

function PANEL:PerformLayout()

	self:SizeToChildren( self.m_bSizeX, self.m_bSizeY )

end

derma.DefineControl( "DSizeToContents", "", PANEL, "Panel" )

