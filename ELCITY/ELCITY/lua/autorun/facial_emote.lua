-- "lua\\autorun\\facial_emote.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- IF YOU ARE HERE TO LOOK ABOUT MY CODE
-- HE'S NOT OPTIMISED SO DONT COME AT ME AND TELL ME HOW I SHOULD DO
-- Thank ;D

if ( CLIENT ) then
	local g_grds, g_wgrd, g_sz
	function draw.GradientBox(x, y, w, h, al, ...)
		g_grds = {...}
		al = math.Clamp(math.floor(al), 0, 1)
		if(al == 1) then
			local t = w
			w, h = h, t
		end
		g_wgrd = w / (#g_grds - 1)
		local n
		for i = 1, w do
			for c = 1, #g_grds do
				n = c
				if(i <= g_wgrd * c) then
					break
				end
			end
			g_sz = i - (g_wgrd * (n - 1))
			surface.SetDrawColor(
				Lerp(g_sz/g_wgrd, g_grds[n].r, g_grds[n + 1].r),
				Lerp(g_sz/g_wgrd, g_grds[n].g, g_grds[n + 1].g),
				Lerp(g_sz/g_wgrd, g_grds[n].b, g_grds[n + 1].b),
				Lerp(g_sz/g_wgrd, g_grds[n].a, g_grds[n + 1].a))
			if(al == 1) then
				surface.DrawRect(x, y + i, h, 1)
			else
				surface.DrawRect(x + i, y, 1, h)
			end
		end
	end 
  
	-- CircleFacialEmote is for avoiding overwritting any other function named the same ( from other addons )
	-- Optimisation idea : create table where you put circle poly indexed by their size and then copy the table instead of recalculate
	function draw.CircleFacialEmote( x, y, radius, quality )
		local circle = {}
		local tmp = 0
		for i=1,quality do
			tmp = math.rad(i*360)/quality
			circle[i] = {x = x + math.cos(tmp)*radius,y = y + math.sin(tmp)*radius}
		end
		surface.DrawPoly( circle )
		return circle
	end	
end

local function includeModule( filePath, side )
	local path = "facial_emote/" .. filePath .. ".lua"
	MsgC( Color( 255, 255, 0 ), "[FacialEmote] : Distribute file (" .. path ..")[" .. side .. "]\n" )
	
	if ( side == "client" ) then
		if ( SERVER ) then
			AddCSLuaFile( path ) 
		end
		
		if ( CLIENT ) then
			include( path )
		end
	elseif ( side == "server" ) then
		if ( SERVER ) then
			include( path )
		end
	else
		if ( SERVER ) then
			AddCSLuaFile( path )
			include( path )
		else
			include( path )
		end
	end 
end 
 
 

   
-- The main table of the mod
facialEmote 			= {}
facialEmote.data 		= {}
facialEmote.debug 		= {}
facialEmote.face 		= {}
facialEmote.network 	= {}
facialEmote.lang 		= {}
facialEmote.interface 	= {}
facialEmote.hooks 		= {}
facialEmote.util 		= {}
facialEmote.parameters 	= {}
facialEmote.version 	= "1.0.1"

-- Load all the modules
includeModule( "network/init", "shared" )
includeModule( "data/main", "shared" )
includeModule( "parameters/main", "shared" )
	
includeModule( "debug/main", "shared" )

includeModule( "commands/main", "shared" )

includeModule( "face/sv_calc", "server" )
includeModule( "face/sv_data", "server" )
includeModule( "face/cl_data", "client" )

includeModule( "lang/init", "shared" )

includeModule( "interface/init", "client" )

includeModule( "interface/cl_fonts", "client" )
includeModule( "interface/cl_materials", "client" )

includeModule( "interface/vgui/DButton_FacialEmote", "client" )
includeModule( "interface/vgui/DNumSlider_FacialEmote", "client" )
includeModule( "interface/vgui/DScrollPanel_FacialEmote", "client" )
includeModule( "interface/vgui/DImageButton_FacialEmote", "client" )
includeModule( "interface/vgui/DCheckBox_FacialEmote", "client" )

includeModule( "interface/cl_menu_choose_model", "client" ) 
includeModule( "interface/cl_menu_choose_emote", "client" ) 
includeModule( "interface/cl_menu_choice", "client" )
includeModule( "interface/cl_menu_emotion_editor", "client" ) 
includeModule( "interface/cl_parameters", "client" ) 
includeModule( "interface/cl_menu", "client" ) 
includeModule( "interface/cl_wheel", "client" )
 

includeModule( "hook/main", "shared" )

includeModule( "network/sv_commands_list", "server" )
includeModule( "network/cl_commands_list", "client" )

list.Set( "DesktopWindows", "facialEmoteContext", {
	title = "Facial Emote",
	icon = "facial_emote/ui/context_button.png",
	init = function( icon, window )
		facialEmote.interface.openMenu()
	end
} )