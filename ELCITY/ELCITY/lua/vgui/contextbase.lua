--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/contextbase.lua <
    > Callstack:  <
]]


local PANEL = {}

function PANEL:Init()

	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "" )
	self.Label:SetDark( true )

end

function PANEL:SetConVar( cvar )
	self.ConVarValue = cvar
end

function PANEL:ConVar()
	return self.ConVarValue
end

function PANEL:ControlValues( kv )

	self:SetConVar( kv.convar or "" )
	self.Label:SetText( kv.label or "" )

end

function PANEL:PerformLayout()

	local y = 5
	self.Label:SetPos( 5, y )
	self.Label:SetWide( self:GetWide() )

	y = y + self.Label:GetTall()
	y = y + 5

	return y

end

function PANEL:TestForChanges()

	-- You should override this function and use it to
	-- check whether your convar value changed

end

function PANEL:Think()

	if ( self.NextPoll && self.NextPoll > CurTime() ) then return end

	self.NextPoll = CurTime() + 0.1

	self:TestForChanges()

end

vgui.Register( "ContextBase", PANEL, "Panel" )

