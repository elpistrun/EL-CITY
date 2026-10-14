--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/postprocess/sobel.lua <
    > Callstack:  <
]]


local SobelMaterial = Material( "pp/sobel" )
SobelMaterial:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )

local pp_sobel = CreateClientConVar( "pp_sobel", "0", false, false )
local pp_sobel_threshold = CreateClientConVar( "pp_sobel_threshold", "0.11", true, false )

function DrawSobel( threshold )

	render.CopyRenderTargetToTexture( render.GetScreenEffectTexture() )

	-- update threshold value
	SobelMaterial:SetFloat( "$threshold", threshold )

	render.SetMaterial( SobelMaterial )
	render.DrawScreenQuad()

end

hook.Add( "RenderScreenspaceEffects", "RenderSobel", function()

	if ( !pp_sobel:GetBool() ) then return end
	if ( !GAMEMODE:PostProcessPermitted( "sobel" ) ) then return end

	DrawSobel( pp_sobel_threshold:GetFloat() )

end )

list.Set( "PostProcess", "#sobel_pp", {

	icon = "gui/postprocess/sobel.png",
	convar = "pp_sobel",
	category = "#shaders_pp",

	cpanel = function( CPanel )

		CPanel:Help( "#sobel_pp.desc" )
		CPanel:CheckBox( "#sobel_pp.enable", "pp_sobel" )

		CPanel:ToolPresets( "sobel", { pp_sobel_threshold = "0.11" } )

		CPanel:NumSlider( "#sobel_pp.threshold", "pp_sobel_threshold", 0, 1 )

	end

} )

