--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/properties/collisions.lua <
    > Callstack: lua/autorun/properties.lua:9 <
]]


AddCSLuaFile()

properties.Add( "collision_off", {
	MenuLabel = "#collision_off",
	Order = 1500,
	MenuIcon = "icon16/collision_off.png",

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "collision", ent ) ) then return false end
		if ( ent:GetCollisionGroup() == COLLISION_GROUP_WORLD ) then return false end

		return true

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()

	end,

	Receive = function( self, length, ply )

		local ent = net.ReadEntity()
		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end

		ent:SetCollisionGroup( COLLISION_GROUP_WORLD )

	end

} )

properties.Add( "collision_on", {
	MenuLabel = "#collision_on",
	Order = 1500,
	MenuIcon = "icon16/collision_on.png",

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "collision", ent ) ) then return false end

		return ent:GetCollisionGroup() == COLLISION_GROUP_WORLD

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()

	end,

	Receive = function( self, length, ply )

		local ent = net.ReadEntity()
		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end

		ent:SetCollisionGroup( COLLISION_GROUP_NONE )

	end

} )

