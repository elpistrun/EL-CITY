--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/drive/drive_base.lua <
    > Callstack: lua/includes/init.lua:40 <
]]


AddCSLuaFile()

drive.Register( "drive_base",
{
	--
	-- You should override these :)
	-- see drive_noclip.lua for help
	--
	Init = function( self, cmd )						end,
	SetupControls = function( self, cmd )				end,
	StartMove = function( self, mv, cmd )				end,
	Move = function( self, mv )							end,
	FinishMove = function( self, mv )					end,
	CalcView = function( self, view )					end,


	--
	-- Utility methods
	--


	--
	-- Call this in your drive method at
	-- any point to stop driving.
	--
	Stop = function( self )
		self.StopDriving = true
	end,

	--
	-- A generic thirdperson view
	--
	-- > view			- the view passed into CalcView
	-- > dist			- the ideal distance from the center
	-- > hullsize		- the size of the hull to trace so we don't go through walls (0 for no trace)
	-- > entityfilter	- usually the self.Entity - so our trace doesn't hit the entity in question
	--
	CalcView_ThirdPerson = function( self, view, dist, hullsize, entityfilter )

		--
		-- > Get the current position (teh center of teh entity)
		-- > Move the view backwards the size of the entity
		--
		local neworigin = view.origin - self.Player:EyeAngles():Forward() * dist


		if ( hullsize && hullsize > 0 ) then

			--
			-- > Trace a hull (cube) from the old eye position to the new
			--
			local tr = util.TraceHull( {
				start	= view.origin,
				endpos	= neworigin,
				mins	= Vector( hullsize, hullsize, hullsize ) * -1,
				maxs	= Vector( hullsize, hullsize, hullsize ),
				filter	= entityfilter
			} )

			--
			-- > If we hit something then stop there
			--		[ stops the camera going through walls ]
			--
			if ( tr.Hit ) then
				neworigin = tr.HitPos
			end

		end

		--
		-- Set our calculated origin
		--
		view.origin		= neworigin

		--
		-- Set the angles to our view angles (not the entities eye angles)
		--
		view.angles		= self.Player:EyeAngles()

	end

} )
