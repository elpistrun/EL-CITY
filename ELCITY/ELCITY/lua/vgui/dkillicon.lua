--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dkillicon.lua <
    > Callstack:  <
]]


local PANEL = {}

AccessorFunc( PANEL, "m_Name", "Name" )

function PANEL:Init()

	self.m_Name = ""
	self.m_fOffset = 0
	self:NoClipping( true )

end

function PANEL:SizeToContents()

	local w, h = killicon.GetSize( self.m_Name )
	self.m_fOffset = h * 0.1
	self:SetSize( w, 5 )

end

function PANEL:Paint()

	killicon.Draw( self:GetWide() * 0.5, self.m_fOffset, self.m_Name, 255 )

end

derma.DefineControl( "DKillIcon", "A kill icon", PANEL, "Panel" )

