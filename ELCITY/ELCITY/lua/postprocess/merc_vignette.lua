--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/postprocess/merc_vignette.lua <
    > Callstack:  <
]]

local mat_Vignette = Material( "effects/shaders/merc_vignette" )

local pp_vignette = CreateClientConVar( "pp_mercvignette", "0", false, false, "Enable vignette", 0, 1 )
local pp_vignette_outerring = CreateClientConVar( "pp_mercvignette_outerring", "1", false, false, "Vignette Outer Ring Pos", 0, 10 )
local pp_vignette_innerring = CreateClientConVar( "pp_mercvignette_innerring", "0.05", false, false, "Vignette Inner Ring Pos", 0, 10 )

function render.DrawMercVignette(orring, inring)
	render.UpdateScreenEffectTexture()
	mat_Vignette:SetFloat("$c0_x", orring)
	mat_Vignette:SetFloat("$c0_y", inring)
	render.SetMaterial(mat_Vignette)
	render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercvignette", function(cvar, old, new)
    if pp_vignette:GetBool() then

        hook.Add("RenderScreenspaceEffects", "merc_vignette_hook", function()
			render.DrawMercVignette(pp_vignette_outerring:GetFloat(), pp_vignette_innerring:GetFloat())
        end)
		
    else
        hook.Remove("RenderScreenspaceEffects", "merc_vignette_hook")
    end
end, "merc_vignette_callback")

list.Set( "PostProcess", "Vignette", {

	icon = "gui/postprocess/mercvignette.png",
	convar = "pp_mercvignette",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Darkens the edges around the screen" )
		CPanel:CheckBox( "Enable", "pp_mercvignette" )

		local options = {
			pp_vignette_outerring = "0.2",
			pp_vignette_inerring = "0.05",
		}
		CPanel:ToolPresets( "mercvignette", options )

		CPanel:NumSlider( "Outer Ring Pos", "pp_mercvignette_outerring", 0, 10, 3 )
		CPanel:NumSlider( "Inner Ring Pos", "pp_mercvignette_innerring", 0, 10, 3 )

	end

} )
