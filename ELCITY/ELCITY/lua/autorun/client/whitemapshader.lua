--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/client/whitemapshader.lua <
    > Callstack:  <
]]

-- lua_refresh_file autorun/client/whitemapshader.lua
-- Basic
local pp_whitemapshader = CreateClientConVar( "pp_whitemapshader", 0, false, false )
local wms_whitemode = CreateClientConVar( "pp_whitemapshader_whitemode", 0, true, false )
local wms_invert_filters = CreateClientConVar( "pp_whitemapshader_invert_filters", 0, true, false )
local wms_bg_only = CreateClientConVar( "pp_whitemapshader_background_only", 0, true, false )
local wms_random_colors = CreateClientConVar( "pp_whitemapshader_random_colors", 0, true, false )
local wms_render_distance = CreateClientConVar( "pp_whitemapshader_render_distance", 0, true, false )

-- Specific filters
local wms_gmod = CreateClientConVar( "pp_whitemapshader_render_gmod", 0, true, false)
local wms_ragdolls = CreateClientConVar( "pp_whitemapshader_render_ragdolls", 1, true, false)
local wms_bonemerge = CreateClientConVar( "pp_whitemapshader_render_bonemerge", 1, true, false)
local wms_props = CreateClientConVar( "pp_whitemapshader_render_props", 1, true, false)
local wms_other = CreateClientConVar( "pp_whitemapshader_render_other", 1, true, false)
local wms_viewmodel = CreateClientConVar( "pp_whitemapshader_render_viewmodel", 0, true, false)
local wms_effects = CreateClientConVar( "pp_whitemapshader_render_effects", 0, true, false)

local wms_modellist_blacklist = CreateClientConVar( "pp_whitemapshader_render_modellist_blacklist", 0, true, false)
local wms_modellist = {}

list.Set( "PostProcess", "White Map", {
	icon = "ds/whitemapshader.png",
	convar = "pp_whitemapshader",
	category = "#shaders_pp",
	cpanel = function( panel )
		panel:CheckBox("#motion_blur_pp.enable", "pp_whitemapshader")

		panel:Help(" ")
		panel:Help("General settings")
		panel:CheckBox("White background", "pp_whitemapshader_whitemode")
		panel:CheckBox("Random colors", "pp_whitemapshader_random_colors")
		panel:CheckBox("Original materials", "pp_whitemapshader_background_only")
		panel:CheckBox("Invert render selection", "pp_whitemapshader_invert_filters")
		panel:NumSlider("Render distance", "pp_whitemapshader_render_distance", 0, 10000, 2)
		panel:ControlHelp("Relative to player view. 0 for entire map.")

		panel:Help(" ")
		panel:Help("Filter by type")
		panel:CheckBox("Screen Effects", "pp_whitemapshader_render_effects")
		panel:CheckBox("Ragdolls", "pp_whitemapshader_render_ragdolls")
		panel:CheckBox("Props", "pp_whitemapshader_render_props")
		panel:CheckBox("Bonemerge", "pp_whitemapshader_render_bonemerge")
		panel:CheckBox("Player/NPC/Guns", "pp_whitemapshader_render_other")
		panel:CheckBox("Viewmodel (ignores camera!)", "pp_whitemapshader_render_viewmodel")
		panel:CheckBox("Gmod_ entites", "pp_whitemapshader_render_gmod")

		panel:Help(" ")
		panel:CheckBox("Activate Blacklist", "pp_whitemapshader_render_modellist_blacklist")
		panel:ControlHelp("Filter by model name, includes file path. Does not save / stay on map change!")
		local modelList = vgui.Create( "DListView")
		modelList:SetMultiSelect( false )
		modelList:AddColumn("Model name")
		modelList:SetHeight(ScrH()/3)

		local modelNameField = vgui.Create( "DTextEntry")
		modelNameField:SetPlaceholderText("nature")
		panel:AddItem(modelNameField)

		local addModelButton = vgui.Create( "DButton")
		addModelButton:SetText( "Add model" )	
		addModelButton.DoClick = function()
			local modelString = string.lower(modelNameField:GetValue())
			if not (modelString:Trim() == "") and not (table.HasValue(wms_modellist, modelString)) then
				table.insert(wms_modellist, modelString)
				modelList:AddLine(modelString)
			end
		end
		panel:AddItem(addModelButton)
		
		
		local removeModelButton = vgui.Create( "DButton")
		removeModelButton:SetText( "Remove selected model" )	
		removeModelButton.DoClick = function()
			local selID = modelList:GetSelectedLine()
			if selID == nil then return end
			local modelName = modelList:GetLine(selID):GetColumnText(1)
			table.remove(wms_modellist, table.KeyFromValue(wms_modellist, modelName))
			modelList:RemoveLine(selID)
		end
		panel:AddItem(removeModelButton)
		
		panel:AddItem(modelList)
	end
})

local function deps_mask_render()
 if !pp_whitemapshader:GetBool() then return end

	local renderWhite = wms_whitemode:GetBool()
	local renderRandomColors = wms_random_colors:GetBool()
	local renderBGOnly = wms_bg_only:GetBool()
	local invertFilters = wms_invert_filters:GetBool()

	local renderRagdolls = wms_ragdolls:GetBool()
	local renderBonemerge = wms_bonemerge:GetBool()
	local renderProps = wms_props:GetBool()
	local renderOther = wms_other:GetBool()
	local renderViewmodel = wms_viewmodel:GetBool()
	local renderGmod = wms_gmod:GetBool()

	local renderStringBlacklist = wms_modellist_blacklist:GetBool()

    cam.Start2D()
    if !renderWhite then
		surface.SetDrawColor(0, 0, 0, 255)
	else
		surface.SetDrawColor(255, 255, 255, 255)
	end
    surface.DrawRect(0, 0, ScrW(), ScrH())
    cam.End2D()

    cam.Start3D()
	render.ClearDepth()
	render.OverrideDepthEnable(true, true)

	local entsCache = nil 
	local renderDistance = wms_render_distance:GetInt()
	if renderDistance == 0 then
		entsCache = ents.GetAll()
	else
		entsCache = ents.FindInSphere(LocalPlayer():GetViewEntity():GetPos(), renderDistance)
	end

	for _, ent in ipairs(entsCache) do
		if not IsValid(ent) or ent:IsWorld() then continue end
		local class = ent:GetClass():lower()

		local renderWMS =
			class:find("prop") and ((ent:IsRagdoll() and renderRagdolls) or (not ent:IsRagdoll() and renderProps))
			or renderBonemerge and (class:find("bonemerge") or class:find("composite"))
			or renderOther and (ent:IsPlayer() or  ent:IsNPC() or ent:IsWeapon())
			or renderViewmodel and (class:find("viewmodel") or class:find("physgun"))
			or renderGmod and class:find("gmod_")
		--if !renderWMS then print(class) end -- DEBUG
		if renderWMS and renderStringBlacklist then 
			local modelName = ent:GetModel()
			if modelName then
				for _, modelString in ipairs(wms_modellist) do
					if modelName:find(modelString) then
						renderWMS = false
						break
					end
				end
			end
		end
		if invertFilters then renderWMS = !renderWMS end
		if renderWMS then
			if not renderBGOnly then
				render.SuppressEngineLighting(true)
				if renderRandomColors then
					local r_key = ent:EntIndex()
					local r_high = 1
					local r_low = 0.1
					if renderWhite then r_high = 0.75 r_low = 0 end
					render.SetColorModulation(util.SharedRandom("r", r_low, r_high, r_key), util.SharedRandom("g", r_low, r_high, r_key), util.SharedRandom("b", r_low, r_high, r_key))
				else
					if not renderWhite then
						render.SetColorModulation(1, 1, 1)
					else
						render.SetColorModulation(0, 0, 0)
					end
				end
				render.SetBlend(1) -- Default, does not need to be reset

				render.MaterialOverride(Material("models/debug/debugwhite"))
			end
			ent:DrawModel()
		end
	end
	
	render.SuppressEngineLighting(false)
	render.MaterialOverride(nil)
	render.OverrideDepthEnable(false) 
    cam.End3D()
end

hook.Add("PreDrawEffects", "deps_mask_pre_effects", function()
   if wms_effects:GetBool() then deps_mask_render() end
end)

hook.Add("PostDrawEffects", "deps_mask_post_effects", function()
   if !wms_effects:GetBool() then deps_mask_render() end
end)
