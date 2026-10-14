--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/properties/keep_upright.lua <
    > Callstack: lua/autorun/properties.lua:5 <
]]


AddCSLuaFile()

properties.Add( "keepupright", {
	MenuLabel = "#keepupright",
	Order = 900,
	MenuIcon = "icon16/arrow_up.png",

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "prop_physics" ) then return false end
		if ( ent:GetNWBool( "IsUpright" ) ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "keepupright", ent ) ) then return false end

		return true
	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()

	end,

	Receive = function( self, length, ply )

		local ent = net.ReadEntity()

		if ( !IsValid( ent ) ) then return end
		if ( !IsValid( ply ) ) then return end
		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( ent:GetClass() != "prop_physics" ) then return end
		if ( ent:GetNWBool( "IsUpright" ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end

		local Phys = ent:GetPhysicsObjectNum( 0 )
		if ( !IsValid( Phys ) ) then return end

		local constraint = constraint.Keepupright( ent, Phys:GetAngles(), 0, 999999 )

		-- I feel like this is not stable enough
		-- This cannot be implemented without a custom constraint.Keepupright function or modification for proper duplicator support.
		--print( constraint:GetSaveTable().m_worldGoalAxis )
		--constraint:SetSaveValue( "m_localTestAxis", constraint:GetSaveTable().m_worldGoalAxis ) --ent:GetAngles():Up() )
		--constraint:SetSaveValue( "m_worldGoalAxis", Vector( 0, 0, 1 ) )
		--constraint:SetSaveValue( "m_bDampAllRotation", true )

		if ( constraint ) then

			ply:AddCleanup( "constraints", constraint )
			ent:SetNWBool( "IsUpright", true )

		end

	end

} )

properties.Add( "keepupright_stop", {
	MenuLabel = "#keepupright_stop",
	Order = 900,
	MenuIcon = "icon16/arrow_rotate_clockwise.png",

	Filter = function( self, ent )
		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "prop_physics" ) then return false end
		if ( !ent:GetNWBool( "IsUpright" ) ) then return false end
		return true
	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()

	end,

	Receive = function( self, length, ply )

		local ent = net.ReadEntity()

		if ( !IsValid( ent ) ) then return end
		if ( !IsValid( ply ) ) then return end
		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( ent:GetClass() != "prop_physics" ) then return end
		if ( !ent:GetNWBool( "IsUpright" ) ) then return end

		constraint.RemoveConstraints( ent, "Keepupright" )

		ent:SetNWBool( "IsUpright", false )

	end

} )

