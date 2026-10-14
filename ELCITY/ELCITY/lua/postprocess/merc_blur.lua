--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/postprocess/merc_blur.lua <
    > Callstack:  <
]]

local mat_blur = Material( "effects/shaders/merc_blur" )

local pp_blur = CreateClientConVar( "pp_mercblur", "0", false, false, "Enable blur", 0, 1 )
local pp_blur_strength = CreateClientConVar( "pp_mercblur_strength", "0.3", false, false, "Blur Strength", 0, 1 )

function render.DrawMercBlur(strength)
    render.UpdateScreenEffectTexture()
    mat_blur:SetFloat("$c0_x", strength)
    render.SetMaterial(mat_blur)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercblur", function(cvar, old, new)
    if pp_blur:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_blur_hook", function()
            render.DrawMercBlur(pp_blur_strength:GetFloat())
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_blur_hook")
    end
end, "merc_blur_callback")

list.Set( "PostProcess", "Blur", {

	icon = "gui/postprocess/mercvideoglitch.png",
	convar = "pp_mercblur",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "A simple blur effect." )
		CPanel:CheckBox( "Enable", "pp_mercblur" )

        CPanel:ToolPresets( "pp_mercblur", { pp_mercblur_strength = "0.3" } )

        CPanel:NumSlider("Strength", "pp_mercblur_strength", 0, 1, 4)

	end

} )
