--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dtree_node_button.lua <
    > Callstack:  <
]]


local PANEL = {}

function PANEL:Init()

	self:SetTextInset( 32, 0 )
	self:SetContentAlignment( 4 )

end

function PANEL:Paint( w, h )

	derma.SkinHook( "Paint", "TreeNodeButton", self, w, h )

	--
	-- Draw the button text
	--
	return false

end

function PANEL:UpdateColours( skin )

	if ( self:IsSelected() ) then return self:SetTextStyleColor( skin.Colours.Tree.Selected ) end
	if ( self.Hovered ) then return self:SetTextStyleColor( skin.Colours.Tree.Hover ) end

	return self:SetTextStyleColor( skin.Colours.Tree.Normal )

end

function PANEL:GenerateExample()

	-- Do nothing!

end

derma.DefineControl( "DTree_Node_Button", "Tree Node Button", PANEL, "DButton" )

