--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/vgui/ddrawer.lua <
    > Callstack:  <
]]


local PANEL = {}

AccessorFunc( PANEL, "m_iOpenSize", "OpenSize" )
AccessorFunc( PANEL, "m_fOpenTime", "OpenTime" )

function PANEL:Init()

	self.m_bOpened = false

	self:SetOpenSize( 100 )
	self:SetOpenTime( 0.3 )
	self:SetPaintBackground( false )
	self:SetSize( 0, 0 )

	self.ToggleButton = vgui.Create( "DButton", self:GetParent() )
	self.ToggleButton:SetSize( 18, 18 )
	self.ToggleButton:SetText( "" )
	self.ToggleButton:SetIcon( "icon16/bullet_arrow_up_high.png" )
	self.ToggleButton.DoClick = function()

		self:Toggle()

	end

	self.ToggleButton.Think = function()

		self.ToggleButton:CenterHorizontal()
		self.ToggleButton.y = self.y - 8

	end

end

function PANEL:OnRemove()

	self.ToggleButton:Remove()

end

function PANEL:Think()

	local w, h = self:GetParent():GetSize()
	self:SetPos( 0, h - self:GetTall() )
	self:SetWide( w )

end

function PANEL:Toggle()

	if ( self.m_bOpened ) then
		self:Close()
	else
		self:Open()
	end

end

function PANEL:Open()

	if ( self.m_bOpened == true ) then return end

	self.m_bOpened = true
	self:SizeTo( self:GetWide(), self.m_iOpenSize, self.m_fOpenTime )
	self.ToggleButton:MoveToFront()
	self.ToggleButton:SetIcon( "icon16/bullet_arrow_down.png" )

end

function PANEL:Close()

	if ( self.m_bOpened == false ) then return end

	self.m_bOpened = false
	self:SizeTo( self:GetWide(), 0, self.m_fOpenTime )
	self.ToggleButton:MoveToFront()
	self.ToggleButton:SetIcon( "icon16/bullet_arrow_up_high.png" )

end

derma.DefineControl( "DDrawer", "", PANEL, "DPanel" )

