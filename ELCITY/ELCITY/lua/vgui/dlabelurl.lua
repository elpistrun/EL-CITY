--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dlabelurl.lua <
    > Callstack:  <
]]


local PANEL = {}

AccessorFunc( PANEL, "m_colText", "TextColor" )
AccessorFunc( PANEL, "m_colTextStyle", "TextStyleColor" )

AccessorFunc( PANEL, "m_bAutoStretchVertical", "AutoStretchVertical" )

function PANEL:Init()

	self:SetTextStyleColor( Color( 0, 0, 255 ) )

	-- Nicer default height
	self:SetTall( 20 )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

end

function PANEL:ApplySchemeSettings()

	self:UpdateFGColor()

end

function PANEL:SetTextColor( clr )

	self.m_colText = clr
	self:UpdateFGColor()

end
PANEL.SetColor = PANEL.SetTextColor

function PANEL:GetColor()

	return self.m_colText or self.m_colTextStyle

end

function PANEL:OnCursorEntered()

	self:SetTextStyleColor( Color( 0, 50, 255 ) )
	self:UpdateFGColor()

end

function PANEL:OnCursorExited()

	self:SetTextStyleColor( Color( 0, 0, 255 ) )
	self:UpdateFGColor()

end

function PANEL:UpdateFGColor()

	local col = self:GetColor()
	self:SetFGColor( col.r, col.g, col.b, col.a )

end

derma.DefineControl( "DLabelURL", "A Label", PANEL, "URLLabel" )

