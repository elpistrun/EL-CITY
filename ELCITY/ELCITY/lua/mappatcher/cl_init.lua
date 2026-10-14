--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/cl_init.lua <
    > Callstack: lua/autorun/mappatcher.lua:88 <
]]

local BufferInterface = MapPatcher.Libs.BufferInterface

MapPatcher.CVarDraw = CreateClientConVar( "mappatcher_draw", "0", false, false, "should map patcher draw")
cvars.AddChangeCallback( "mappatcher_draw", function( convar_name, value_old, value_new )
    if not MapPatcher.HasAccess( LocalPlayer() ) then return end

    if tobool(value_new) then
        MapPatcher.Editor.LoadMapClipBrushes()
    end
end, "mappatcher_draw" )

net.Receive( "mappatcher_update", function( len )
    local n_objects = net.ReadUInt( 16 )
    for i = 1, n_objects do
        local object_id = net.ReadUInt( 16 )
        local object_class = net.ReadString()
        
        local object = MapPatcher.NewToolObject( object_class )
        object.ID = object_id
        MapPatcher.Objects[object_id] = object

        local buffer = BufferInterface("net")
        object:ReadFromBuffer( buffer )
        object:SessionReadFromBuffer( buffer )

        object:Initialize()
        
        MsgN( "[MapPatcher] Object update: id("..object_id..") class("..object_class..")" )
    end
    if MapPatcher.Editor.Enabled then
        MapPatcher.Editor.UpdateMenu( )
    end
end )

