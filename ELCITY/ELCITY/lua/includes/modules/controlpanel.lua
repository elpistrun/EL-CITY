--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/includes/modules/controlpanel.lua <
    > Callstack: lua/includes/init.lua:67 <
]]


local ControlPanels = {}

module( "controlpanel", package.seeall )

-- A hack for a very annoying race condition where spawnmenu_reload deletes the controlpanels on the next frame
-- But some panels are updated "this" frame after spawnmenu reloaded
local function ShouldReCreate( pnl )
	if ( !IsValid( pnl ) || pnl:IsMarkedForDeletion() ) then return true end

	local p = pnl
	-- Can't use IsValid because it's false for marked for deletion panels
	while ( IsValid( p ) && p:GetParent() != nil ) do
		if ( p:GetParent():IsMarkedForDeletion() ) then return true end
		p = p:GetParent()
	end

	return false
end

function Get( name )

	if ( ShouldReCreate( ControlPanels[ name ] ) ) then
		local cp = vgui.Create( "ControlPanel" )
		if ( !cp ) then

			debug.Trace()
			Error( "controlpanel.Get() - Error creating a ControlPanel!\nYou're calling this function too early! Call it in a hook!\n" )
			return nil

		end

		cp:SetVisible( false )
		cp.Name = name
		ControlPanels[ name ] = cp

	end

	return ControlPanels[ name ]

end

function Clear()

	ControlPanels = {}

end

