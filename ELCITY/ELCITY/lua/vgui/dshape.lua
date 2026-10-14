--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dshape.lua <
    > Callstack:  <
]]


local PANEL = {}

AccessorFunc( PANEL, "m_Color", "Color" )
AccessorFunc( PANEL, "m_BorderColor", "BorderColor" )
AccessorFunc( PANEL, "m_Type", "Type" )

local RenderTypes = {}

function RenderTypes.Rect( pnl )
	local pnlColor = pnl:GetColor()

	surface.SetDrawColor( pnlColor.r, pnlColor.g, pnlColor.b, pnlColor.a )
	surface.DrawRect( 0, 0, pnl:GetSize() )
end

function PANEL:Init()

	self:SetColor( color_white )

	self:SetMouseInputEnabled( false )
	self:SetKeyboardInputEnabled( false )

end

function PANEL:Paint()

	RenderTypes[ self.m_Type ]( self )

end

derma.DefineControl( "DShape", "A shape", PANEL, "DPanel" )

-- Convenience function
function VGUIRect( x, y, w, h )
	local shape = vgui.Create( "DShape" )
	shape:SetType( "Rect" )
	shape:SetPos( x, y )
	shape:SetSize( w, h )
	return shape
end

