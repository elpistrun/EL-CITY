--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dexpandbutton.lua <
    > Callstack:  <
]]


local PANEL = {}

AccessorFunc( PANEL, "m_bExpanded", "Expanded", FORCE_BOOL )
Derma_Hook( PANEL, "Paint", "Paint", "ExpandButton" )

function PANEL:Init()

	self:SetSize( 15, 15 )
	self:SetText( "" )

end

-- No example for this control
function PANEL:GenerateExample( class, tabs, w, h )
end

derma.DefineControl( "DExpandButton", "", PANEL, "DButton" )

