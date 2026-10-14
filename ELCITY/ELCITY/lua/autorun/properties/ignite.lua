--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/properties/ignite.lua <
    > Callstack: lua/autorun/properties.lua:8 <
]]


AddCSLuaFile()

local function CanEntityBeSetOnFire( ent )

	local class = ent:GetClass()

	-- func_pushable, func_breakable & func_physbox cannot be ignited
	if ( class == "item_item_crate" ) then return true end
	if ( class == "simple_physics_prop" ) then return true end
	if ( class:match( "prop_physics*" ) ) then return true end
	if ( class:match( "prop_ragdoll*" ) ) then return true end
	if ( ent:IsNPC() ) then return true end

	return false

end

properties.Add( "ignite", {
	MenuLabel = "#ignite",
	Order = 999,
	MenuIcon = "icon16/fire.png",

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !CanEntityBeSetOnFire( ent ) ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "ignite", ent ) ) then return false end

		return !ent:IsOnFire()
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

		ent:Ignite( 360 )

	end

} )

properties.Add( "extinguish", {
	MenuLabel = "#extinguish",
	Order = 999,
	MenuIcon = "icon16/water.png",

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "extinguish", ent ) ) then return false end

		return ent:IsOnFire()
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

		ent:Extinguish()

	end

} )

