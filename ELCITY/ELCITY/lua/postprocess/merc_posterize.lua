--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/postprocess/merc_posterize.lua <
    > Callstack:  <
]]

local mat_Posterize = Material( "effects/shaders/merc_posterize" )

local pp_posterize = CreateClientConVar( "pp_mercposterize", "0", false, false, "Enable posterize", 0, 1 )
local pp_posterize_steps = CreateClientConVar( "pp_mercposterize_steps", "8", false, false, "Posterize Steps", 1, 64 )
local pp_posterize_gamma = CreateClientConVar( "pp_mercposterize_gamma", "3", false, false, "Posterize Gamma", -50, 50 )

cvars.AddChangeCallback("pp_mercposterize", function(cvar, old, new)
    if pp_posterize:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_posterize_hook", function()
            render.UpdateScreenEffectTexture()
            mat_Posterize:SetInt("$c0_x", pp_posterize_steps:GetInt())
            mat_Posterize:SetFloat("$c0_y", pp_posterize_gamma:GetFloat())
            render.SetMaterial(mat_Posterize)
            render.DrawScreenQuad()
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_posterize_hook")
    end
end, "merc_posterize_callback")

list.Set( "PostProcess", "Posterize", {

	icon = "gui/postprocess/mercposterize.png",
	convar = "pp_mercposterize",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Lowers the amount of unique colors." )
		CPanel:CheckBox( "Enable", "pp_mercposterize" )

        CPanel:ToolPresets( "pp_mercposterize", {pp_mercposterize_steps = 8, pp_mercposterize_gamma = "3"} )

		CPanel:NumSlider( "Steps", "pp_mercposterize_steps", 1, 64, 0 )
        CPanel:NumSlider( "Gamma", "pp_mercposterize_gamma", -50, 50, 3 )

	end

} )
