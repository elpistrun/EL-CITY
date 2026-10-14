--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/derma/derma_example.lua <
    > Callstack: lua/derma/init.lua:48 <
]]


local PANEL = {}

function PANEL:Init()

	self:SetTitle( "Derma Initiative Control Test" )
	self.ContentPanel = vgui.Create( "DPropertySheet", self )
	self.ContentPanel:Dock( FILL )

	self:InvalidateLayout( true )
	local w, h = self:GetSize()

	local Controls = table.Copy( derma.GetControlList() )

	for key, ctrl in SortedPairs( Controls ) do

		local Ctrls = _G[ key ]
		if ( Ctrls && Ctrls.GenerateExample ) then

			Ctrls:GenerateExample( key, self.ContentPanel, w, h )

		end

	end

	self:SetSize( 600, 450 )

end

function PANEL:SwitchTo( name )
	self.ContentPanel:SwitchToName( name )
end

local vguiExampleWindow = vgui.RegisterTable( PANEL, "DFrame" )

--
-- This is all to open the actual window via concommand
--
local DermaExample = nil

local DermaControlsSuffix = ""

if ( MENU_DLL ) then -- Not all controls are available in menu state
	DermaControlsSuffix = "_menu"
end

concommand.Add( "derma_controls" .. DermaControlsSuffix, function( player, command, arguments, args )

	if ( IsValid( DermaExample ) ) then
		DermaExample:Remove()
	return end

	DermaExample = vgui.CreateFromTable( vguiExampleWindow )
	DermaExample:SwitchTo( args )
	DermaExample:MakePopup()
	DermaExample:Center()

end, nil, "", { FCVAR_DONTRECORD } )

