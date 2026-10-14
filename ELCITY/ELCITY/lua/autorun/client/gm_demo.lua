--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/client/gm_demo.lua <
    > Callstack:  <
]]


concommand.Add( "gm_demo", function( ply, cmd, arg )

	if ( engine.IsRecordingDemo() ) then
		RunConsoleCommand( "stop" )
		return
	end

	local dynamic_name = game.GetMap() .. " " .. util.DateStamp()

	RunConsoleCommand( "record", "demos/" .. dynamic_name .. ".dem" )
	RunConsoleCommand( "record_screenshot", dynamic_name )

end, nil, "Start or stop recording a demo.", FCVAR_DONTRECORD )

local matRecording = nil
local drawicon = CreateConVar( "gm_demo_icon", 1, FCVAR_ARCHIVE + FCVAR_DONTRECORD, "If set to 1, display a 'RECORDING' icon during gm_demo." )
hook.Add( "HUDPaint", "DrawRecordingIcon", function()

	if ( !engine.IsRecordingDemo() || !drawicon:GetBool() ) then return end

	if ( !matRecording ) then
		matRecording = Material( "gmod/recording.png" )
	end

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( matRecording )
	surface.DrawTexturedRect( ScrW() - 512, 0, 512, 256 )

end )

