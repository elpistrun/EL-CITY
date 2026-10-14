--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dprogress.lua <
    > Callstack:  <
]]


local PANEL = {}

AccessorFunc( PANEL, "m_fFraction", "Fraction" )

Derma_Hook( PANEL, "Paint", "Paint", "Progress" )

function PANEL:Init()

	self:SetMouseInputEnabled( false )
	self:SetFraction( 0 )

end

function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
	ctrl:SetFraction( 0.6 )
	ctrl:SetSize( 300, 20 )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DProgress", "", PANEL, "Panel" )

