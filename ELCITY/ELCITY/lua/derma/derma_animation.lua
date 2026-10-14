--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/derma/derma_animation.lua <
    > Callstack: lua/derma/init.lua:50 <
]]


local DermaAnimation = {}
DermaAnimation.__index = DermaAnimation

function DermaAnimation:Run()

	if ( !self.Running ) then return end

	local time = SysTime()
	local delta = ( time - self.StartTime ) / self.Length
	delta = delta ^ ( 1.0 - ( delta - 0.5 ) )

	-- If we have ended we run once more with the Finished member set
	-- This allows us to clean up in the same function..
	if ( time > self.EndTime ) then

		self.Finished = true
		self.Running = nil
		delta = 1

	end

	self.Func( self.Panel, self, delta, self.Data )
	self.Started = nil

end


function DermaAnimation:Start( Length, Data )

	if ( self.Length == 0 ) then return end

	self.Running = true
	self.Started = true
	self.Finished = nil
	self.Length = Length
	self.StartTime = SysTime()
	self.EndTime = SysTime() + Length

	self.Data = Data

end

function DermaAnimation:Stop()

	if ( !self.Running ) then return end

	self.Finished = true
	self.Running = nil

end

function DermaAnimation:Active()

	return self.Running

end

function Derma_Anim( name, panel, func )

	local anim = {}
	anim.Name = name
	anim.Panel = panel
	anim.Func = func

	setmetatable( anim, DermaAnimation )

	return anim

end

