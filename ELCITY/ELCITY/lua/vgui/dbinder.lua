--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/dbinder.lua <
    > Callstack:  <
]]


local PANEL = {}

AccessorFunc( PANEL, "m_iSelectedNumber", "SelectedNumber" )
AccessorFunc( PANEL, "m_iDefaultNumber", "DefaultNumber" )

Derma_Install_Convar_Functions( PANEL )

function PANEL:Init()

	self:SetSelectedNumber( 0 )
	self:SetDefaultNumber( 0 )
	self:SetSize( 60, 30 )

	self:SetTooltip( "#dbinder.help" )

end

function PANEL:UpdateText()

	local str = input.GetKeyName( self:GetSelectedNumber() )
	if ( !str ) then str = "#dbinder.none" end

	str = language.GetPhrase( str )

	self:SetText( str )

end

function PANEL:DoClick()

	self:SetText( "#dbinder.press_a_key" )
	input.StartKeyTrapping()
	self.Trapping = true

end

function PANEL:DoMiddleClick()

	local def = self:GetDefaultNumber()
	if ( def != 0 ) then self:SetValue( def ) end

end

function PANEL:DoRightClick()

	self:SetValue( 0 )

end

function PANEL:SetSelectedNumber( iNum )

	self.m_iSelectedNumber = iNum
	self:ConVarChanged( iNum )
	self:UpdateText()
	self:OnChange( iNum )

end

function PANEL:SetConVar( strConVar )
	self.m_strConVar = strConVar

	if ( strConVar ) then
		local cvar = GetConVar( strConVar )
		if ( cvar ) then self:SetDefaultNumber( cvar:GetDefault() ) end
	end
end

function PANEL:Think()

	if ( input.IsKeyTrapping() and self.Trapping ) then

		local code = input.CheckKeyTrapping()
		if ( code ) then

			if ( code == KEY_ESCAPE ) then

				self:SetValue( self:GetSelectedNumber() )

			else

				self:SetValue( code )

			end

			self.Trapping = false

		end

	end

	self:ConVarNumberThink()

end

function PANEL:SetValue( iNumValue )

	self:SetSelectedNumber( iNumValue )

end

function PANEL:GetValue()

	return self:GetSelectedNumber()

end

function PANEL:OnChange( iNum )
end

derma.DefineControl( "DBinder", "", PANEL, "DButton" )

