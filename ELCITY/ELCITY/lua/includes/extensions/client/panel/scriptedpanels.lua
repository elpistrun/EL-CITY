--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/extensions/client/panel/scriptedpanels.lua <
    > Callstack: lua/includes/extensions/client/panel.lua:5
[C]:-1
lua/includes/init.lua:118 <
]]


if ( SERVER ) then return end

local PanelFactory = {}

local panel_metatable = FindMetaTable( "Panel" )

baseclass.Set( "Panel",				panel_metatable )
baseclass.Set( "Label",				panel_metatable )
baseclass.Set( "EditablePanel",		panel_metatable )

-- Keep the old function
vgui.CreateX = vgui.Create

function vgui.GetControlTable( classname )
	return PanelFactory[ classname ]
end

function vgui.Exists( classname )
	return PanelFactory[ classname ] != nil
end

function vgui.Create( classname, parent, name )

	-- Is this a user-created panel?
	if ( PanelFactory[ classname ] ) then

		local metatable = PanelFactory[ classname ]

		local panel = vgui.Create( metatable.Base, parent, name or classname )
		if ( !panel ) then
			Error( "Tried to create panel with invalid base '" .. metatable.Base .. "'\n" )
		end

		table.Merge( panel:GetTable(), metatable )
		panel.BaseClass = PanelFactory[ metatable.Base ]
		panel.ClassName = classname

		-- Call the Init function if we have it
		if ( panel.Init ) then
			panel:Init()
		end

		panel:Prepare()

		return panel

	end

	return vgui.CreateX( classname, parent, name or classname )

end

function vgui.CreateFromTable( metatable, parent, name )

	if ( !istable( metatable ) ) then return nil end

	local panel = vgui.Create( metatable.Base, parent, name )

	table.Merge( panel:GetTable(), metatable )
	panel.BaseClass = PanelFactory[ metatable.Base ]

	-- Call the Init function if we have it
	if ( panel.Init ) then
		panel:Init()
	end

	panel:Prepare()

	return panel

end

function vgui.Register( classname, mtable, base )

	-- Remove the global
	PANEL = nil

	-- Default base is Panel
	mtable.Base = base or "Panel"
	mtable.Init = mtable.Init or function() end

	PanelFactory[ classname ] = mtable
	baseclass.Set( classname, mtable )

	local mt = {}
	mt.__index = function( t, k )

		if ( PanelFactory[ mtable.Base ] && PanelFactory[ mtable.Base ][k] ) then return PanelFactory[ mtable.Base ][k] end
		return panel_metatable[k]

	end

	setmetatable( mtable, mt )

	return mtable

end

function vgui.RegisterTable( mtable, base )

	-- Remove the global
	PANEL = nil

	mtable.Base = base or "Panel"
	mtable.Init = mtable.Init or function() end

	return mtable

end

function vgui.RegisterFile( filename )

	local OldPanel = PANEL

	PANEL = {}

	-- The included file should fill the PANEL global.
	include( filename )

	local mtable = PANEL
	PANEL = OldPanel

	mtable.Base = mtable.Base or "Panel"
	mtable.Init = mtable.Init or function() end

	return mtable

end

