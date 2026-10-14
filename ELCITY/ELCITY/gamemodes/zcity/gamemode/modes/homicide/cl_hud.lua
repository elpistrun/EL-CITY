local MODE = MODE
local vgui_color_main = Color(150, 80, 0, 255)
local vgui_color_warning = Color(150, 0, 0, 255)
local vgui_color_bg = Color(50, 50, 50, 255)
local vgui_color_ready = Color(0, 150, 50, 255)
local vgui_color_notready = Color(0, 50, 0, 255)
local vgui_color_text_main = Color(150, 50, 0, 255)
local vgui_color_text_shadow = Color(0, 0, 0, 255)

local mat_gradientdown = Material("vgui/gradient_down")

local function draw_shadow_text(text, cx, cy)
	draw.DrawText(text, "HomigradFontMedium", cx + 1, cy + 1, vgui_color_text_shadow, TEXT_ALIGN_CENTER)
	draw.DrawText(text, "HomigradFontMedium", cx, cy, vgui_color_text_main, TEXT_ALIGN_CENTER)
end

local vector_one = Vector(1, 1, 1)

local function draw_RotatedText(text, font, x, y, color, ang, scale)
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	local m = Matrix()
	
	m:Translate(Vector(x, y, 0))
	m:Rotate(Angle(0, ang, 0))
	m:Scale(vector_one * (scale or 1))

	surface.SetFont(font)
	
	local w, h = surface.GetTextSize(text)

	m:Translate(Vector(-w / 2, -h / 2, 0))

	cam.PushModelMatrix(m, true)
		draw.DrawText(text, font, 0, 0, color)
	cam.PopModelMatrix()

	render.PopFilterMag()
	render.PopFilterMin()
end

hook.Add("HUDPaint", "HMCD_SubRoles_Abilities", function()
	local ply = LocalPlayer()
	local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOther(ply)
	local after_text_offset = 5
	local y_offset = 30
	y_offset = y_offset + ScreenScale(15)
	
	surface.SetFont("HomigradFontMedium")
	
	if(ply:Alive())then
		if(ply.isTraitor)then
			if(ply.SubRole == "traitor_infiltrator" or ply.SubRole == "traitor_infiltrator_soe")then
				local text = "(HOLD)[ALT + E] Break Neck"
				local tw, th = surface.GetTextSize(text)
				local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
				cy = cy + y_offset
				
				if((IsValid(aim_ent) and other_ply and MODE.CanPlayerBreakOtherNeck(ply, aim_ent)) or ply.Ability_NeckBreak)then
					draw_shadow_text(text, cx, cy)
					
					if(ply.Ability_NeckBreak)then
						local frac = ply.Ability_NeckBreak.Progress / 100
						
						surface.SetDrawColor(vgui_color_text_main)
						surface.DrawRect(cx - tw / 2, cy, tw * frac, th)
					end
				
					y_offset = y_offset + th + after_text_offset
				end
				
				if(IsValid(aim_ent))then
					if(aim_ent:IsRagdoll())then
						local text = "[ALT + R] Exchange Appearances"
						local tw, th = surface.GetTextSize(text)
						local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
						
						draw_shadow_text(text, cx, cy + y_offset)
						
						y_offset = y_offset + th + after_text_offset
					end
				end
			end
			
			if(ply.SubRole == "traitor_assasin" or ply.SubRole == "traitor_assasin_soe" or ply.PlayerClassName == "sc_infiltrator")then
				local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOther(ply, nil, MODE.DisarmReach)
				local text = "(HOLD)[ALT + E] Disarm"
				local tw, th = surface.GetTextSize(text)
				local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
				cy = cy + y_offset
				
				if((IsValid(aim_ent) and other_ply and MODE.CanPlayerDisarmOtherPly(ply, other_ply, MODE.DisarmReach) and MODE.CanPlayerDisarmOther(ply, aim_ent, MODE.DisarmReach)) or ply.Ability_Disarm)then
					draw_shadow_text(text, cx, cy)
					
					if(ply.Ability_Disarm)then
						local frac = ply.Ability_Disarm.Progress / 100
						
						surface.SetDrawColor(vgui_color_text_main)
						surface.DrawRect(cx - tw / 2, cy, tw * frac, th)
					end
					
					y_offset = y_offset + th + after_text_offset
				end
			end
			
			if(ply.SubRole == "traitor_chemist")then
				local after_side_bar_offset = 5
				local bar_border = 5
				local bar_width = ScreenScale(20)
				local bar_height = ScreenScale(80)
				local bar_y = (ScrH() - bar_height) / 2
				local bar_x = ScrW() - after_side_bar_offset
				ply.PassiveAbility_ChemicalAccumulation = ply.PassiveAbility_ChemicalAccumulation or {}
				ply.PassiveAbility_VGUI_ChemicalAccumulation = ply.PassiveAbility_VGUI_ChemicalAccumulation or {}
				
				for chemical_name, amt in pairs(ply.PassiveAbility_ChemicalAccumulation) do
					ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] = ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] or 0
					ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] = Lerp(FrameTime() * 3, ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name], amt)
					if(ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] > 0.1)then
						surface.SetDrawColor(vgui_color_bg)
						surface.DrawRect(bar_x - bar_width, bar_y, bar_width, bar_height)
						
						local frac = math.min(ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] / 100, 1)
						local y_end = bar_y + bar_border + bar_height - bar_border * 2
						local y_start = y_end - ((bar_height - bar_border * 2) * frac)
						local height = y_end - y_start
						
						surface.SetDrawColor(vgui_color_main)
						surface.DrawRect(bar_x - bar_width + bar_border, y_start, bar_width - bar_border * 2, height)
						
						render.SetScissorRect(bar_x - bar_width + bar_border, y_start, bar_x - bar_border, y_start + height, true)
							surface.SetDrawColor(vgui_color_warning)
							surface.SetMaterial(mat_gradientdown)
							surface.DrawTexturedRect(bar_x - bar_width + bar_border, bar_y + bar_border, bar_width - bar_border * 2, bar_height - bar_border * 2)
						render.SetScissorRect(0, 0, 0, 0, false)
						
						local tcx, tcy = bar_x - bar_width / 2, bar_y + bar_height / 2
						
						draw_RotatedText(chemical_name, "HomigradFontMedium", tcx, tcy, vgui_color_text_shadow, 90, 1)
						
						bar_x = bar_x - bar_width - after_side_bar_offset
					end
				end
			end
		end
		
		if(ply.isTraitor and (ply.SubRole == "traitor_arsonist" or ply.SubRole == "traitor_arsonist_soe"))then
			local fuel_max = MODE.ArsonistFuelMax or 1
			local fuel = math.Clamp(ply:GetNWInt("ArsonistFuel", 0), 0, fuel_max)
			local fuel_frac = math.min(fuel / fuel_max, 1)
			
			--; канистра: полоска справа, как химические бары у химика
			local bar_border = 5
			local bar_width, bar_height = ScreenScale(20), ScreenScale(80)
			local bar_x = ScrW() - bar_width - ScreenScale(5)
			local bar_y = (ScrH() - bar_height) / 2
			
			surface.SetDrawColor(vgui_color_bg)
			surface.DrawRect(bar_x, bar_y, bar_width, bar_height)
			
			local y_end = bar_y + bar_height - bar_border
			local y_start = y_end - ((bar_height - bar_border * 2) * fuel_frac)
			
			surface.SetDrawColor(fuel > 0 and vgui_color_main or vgui_color_warning)
			surface.DrawRect(bar_x + bar_border, y_start, bar_width - bar_border * 2, y_end - y_start)
			
			draw_RotatedText("FUEL", "HomigradFontMedium", bar_x + bar_width / 2, bar_y + bar_height / 2, vgui_color_text_shadow, 90, 1)
			draw.SimpleText(fuel .. "/" .. fuel_max, "HomigradFontMedium", bar_x + bar_width / 2, bar_y - ScreenScale(4), vgui_color_text_main, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			
			--; есть ли рядом лужа под спичку: список луж приходит на клиент раз в секунду
			local puddle_near = false
			local eye_pos = ply:GetShootPos()
			
			for _, path in ipairs(hg.gasolinePath or {}) do
				if(path[2])then continue end
				
				if((path[1] - eye_pos):Length() <= (MODE.ArsonistIgniteReach or 220))then
					puddle_near = true
					break
				end
			end
			
			if(trace and trace.HitPos)then
				local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
				
				surface.SetFont("HomigradFontMedium")
				
				local spill_text = fuel > 0 and "(HOLD)[ALT + E] Spill Gasoline" or "[ALT + E] Can Is Empty"
				local _, th = surface.GetTextSize(spill_text)
				
				draw_shadow_text(spill_text, cx, cy + y_offset)
				y_offset = y_offset + th + after_text_offset
				
				local ignite_text = puddle_near and "[ALT + R] Ignite Gasoline" or "[ALT + R] No Gasoline Nearby"
				draw_shadow_text(ignite_text, cx, cy + y_offset)
			end
		end
		
		if(ply.isTraitor and (ply.SubRole == "traitor_butcher" or ply.SubRole == "traitor_butcher_soe"))then
			local progress = ply:GetNWFloat("ButcherProgress", 0)
			local corpse = IsValid(aim_ent) and aim_ent:IsRagdoll() and MODE.CorpseOwnerOf(aim_ent)
			
			if((corpse or progress > 0) and trace and trace.HitPos)then
				local text = "(HOLD)[ALT + E] Devour Body"
				local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
				
				surface.SetFont("HomigradFontMedium")
				
				local tw, th = surface.GetTextSize(text)
				
				draw_shadow_text(text, cx, cy + y_offset)
				
				if(progress > 0)then
					surface.SetDrawColor(vgui_color_warning)
					surface.DrawRect(cx - tw / 2, cy + y_offset, tw * math.min(progress / 100, 1), th)
				end
			end
		end
		
		--\\Professions
		
		--//
	end
end)


--// Я ебал это делать

surface.CreateFont("TraitorPanelTitle", {
	font = "coolvetica",
	size = 22,
	weight = 500,
	antialias = true
})

surface.CreateFont("TraitorPanelText", {
	font = "coolvetica",
	size = 19,
	weight = 500,
	antialias = true
})

surface.CreateFont("TraitorPanelWords", {
	font = "coolvetica",
	size = 24,
	weight = 700,
	antialias = true,
	italic = false
})



local traitor_panel = {
    assistants = {},
    dead_anim = {}, 
    width = 300,
    height = 280,
    assist_height = 200,
    spacing = 26,
    padding = 15,
    left_padding = 90, 
    avatar_size = 24, 
    fade_speed = 3,
    instance = nil,
    visible = true,
    target_x = 0,
    smooth_toggle = 0,
    alpha = 255,
    last_toggle_time = 0,
    toggle_cooldown = 0.3,
    assistant_status_cache = {},
    assistant_avatars = {}, 
    avatar_materials = {}, 
    colors = {
        bg = Color(30, 0, 0, 230),
        border = Color(180, 0, 0, 255),
        border_inner = Color(90, 0, 0, 150),
        title = Color(255, 255, 255, 255),
        words = Color(255, 80, 80, 255),
        assistant = Color(200, 70, 70, 255)
    }
}


local function CreateAvatarPanel(steamid)
    if not steamid or steamid == "" then return nil end
    
    if traitor_panel.assistant_avatars[steamid] and IsValid(traitor_panel.assistant_avatars[steamid]) then
        return traitor_panel.assistant_avatars[steamid]
    end
    

    local avatar = vgui.Create("AvatarImage")
    avatar:SetSize(traitor_panel.avatar_size, traitor_panel.avatar_size)
    avatar:SetVisible(false) 
    
    local ply = player.GetBySteamID(steamid)
    if IsValid(ply) then
        avatar:SetPlayer(ply, traitor_panel.avatar_size)
    end
    
    traitor_panel.assistant_avatars[steamid] = avatar
    return avatar
end


hook.Add("PlayerButtonDown", "TraitorPanelToggle", function(ply, btn)
    if ply ~= LocalPlayer() or btn ~= KEY_F4 then return end
    if not LocalPlayer().isTraitor then return end 
    

    local current_time = CurTime()
    if current_time - traitor_panel.last_toggle_time < traitor_panel.toggle_cooldown then
        return
    end
    
    traitor_panel.last_toggle_time = current_time
    traitor_panel.visible = not traitor_panel.visible
    
    if traitor_panel.visible then
        surface.PlaySound("buttons/button14.wav")
    end
end)




net.Receive("HMCD_UpdateTraitorAssistants", function()
    local count = net.ReadUInt(8)
    MODE.TraitorsLocal = {}
    
    for i = 1, count do
        local color = net.ReadColor()
        local name = net.ReadString()
        local steamID = net.ReadString()
        
        table.insert(MODE.TraitorsLocal, {color, name, steamID})
    end
end)


net.Receive("HMCD_TraitorDeathState", function()
    local traitor_name = net.ReadString()
    local is_alive = net.ReadBool()
    
    if traitor_name and traitor_name ~= "" then
        traitor_panel.assistant_status_cache[traitor_name] = is_alive
    end
end)

hook.Add("HUDPaint", "DrawTraitorPanel", function()
    local ply = LocalPlayer()
    if not ply.isTraitor or not ply:Alive() then 
        traitor_panel.visible = false 
        
       
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        
        return 
    end


    local target = traitor_panel.visible and 0 or traitor_panel.width + 40
    traitor_panel.smooth_toggle = Lerp(FrameTime() * 10, traitor_panel.smooth_toggle, target)
    
    local is_main = ply.MainTraitor
    local height = is_main and traitor_panel.height or traitor_panel.assist_height
    local x = ScrW() - traitor_panel.width - 20 + traitor_panel.smooth_toggle
    local y = ScrH() / 2 - (height / 2)
    

    if traitor_panel.smooth_toggle > traitor_panel.width + 30 then 
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        return 
    end
    

    draw.RoundedBox(6, x, y, traitor_panel.width, height, traitor_panel.colors.bg)
    surface.SetDrawColor(traitor_panel.colors.border_inner)
    surface.DrawOutlinedRect(x + 3, y + 3, traitor_panel.width - 6, height - 6, 1)
    surface.SetDrawColor(traitor_panel.colors.border)
    surface.DrawOutlinedRect(x, y, traitor_panel.width, height, 2)
    

    local title = is_main and "MAIN TRAITOR" or "TRAITOR'S ASSISTANT"
    draw.SimpleText(title, "TraitorPanelTitle", x + traitor_panel.width/2, y + 15, 
                    traitor_panel.colors.title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    

    surface.SetDrawColor(traitor_panel.colors.border)
    surface.DrawLine(x + 15, y + 30, x + traitor_panel.width - 15, y + 30)
    

    draw.SimpleText("Press F4 to toggle panel", "TraitorPanelText", x + traitor_panel.width/2, y + 42, 
                    Color(180, 180, 180, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    local word_y = y + 65
    draw.SimpleText("Secret Words:", "TraitorPanelText", x + traitor_panel.width/2, word_y, 
                    Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    word_y = word_y + 25
    local word1 = MODE.TraitorWord or "???"
    
    draw.SimpleText(word1, "TraitorPanelWords", x + traitor_panel.width/2, word_y, 
                    traitor_panel.colors.words, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    word_y = word_y + 30
    local word2 = MODE.TraitorWordSecond or "???"
    
    draw.SimpleText(word2, "TraitorPanelWords", x + traitor_panel.width/2, word_y, 
                    traitor_panel.colors.words, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    if is_main then
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        
        local assist_y = y + 150     
        local has_assistants = false
        MODE.TraitorsLocal = MODE.TraitorsLocal or {}
        
        if #MODE.TraitorsLocal > (ply.MainTraitor and 1 or 0) then
            has_assistants = true
        end
        
        if has_assistants then
            draw.SimpleText("Your Assistants:", "TraitorPanelText", x + traitor_panel.width/2, assist_y, 
                            Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            assist_y = assist_y + 25   
            
            for _, traitor_info in ipairs(MODE.TraitorsLocal) do
                if not traitor_info or #traitor_info < 2 then continue end
                
                if ply.MainTraitor and ply.CurAppearance and traitor_info[2] == ply.CurAppearance.AName then
                    continue
                end
                
                local color = traitor_info[1]
                local name = traitor_info[2]
                local steamID = traitor_info[3] or ""
                
                local player_found = nil
                for _, v in player.Iterator() do
                    if v.isTraitor and v.CurAppearance and v.CurAppearance.AName == name then
                        player_found = v
                        break
                    end
                end
                
                local is_alive = true
                if traitor_panel.assistant_status_cache[name] == false then
                    is_alive = false
                end
                
                if player_found then
                    is_alive = player_found:Alive() and (not player_found.organism or not player_found.organism.incapacitated)
                    traitor_panel.assistant_status_cache[name] = is_alive
                end
                
                if not is_alive then
                    traitor_panel.dead_anim[name] = traitor_panel.dead_anim[name] or 255
                    traitor_panel.dead_anim[name] = math.max(traitor_panel.dead_anim[name] - FrameTime() * 100 * traitor_panel.fade_speed, 0)
                    
                    if traitor_panel.dead_anim[name] <= 0 then continue end
                else
                    traitor_panel.dead_anim[name] = nil
                end
                
                local alpha = traitor_panel.dead_anim[name] or 255
                local display_color = is_alive and color or Color(150, 150, 150)
                display_color = Color(display_color.r, display_color.g, display_color.b, alpha)
                
                local status = is_alive and "" or " [DEAD]"


                local display_name = name
                if #name > 20 then
                    display_name = string.sub(name, 1, 18) .. ".."
                end
                

                if steamID and steamID ~= "" then
                    local avatar_player = player.GetBySteamID(steamID)
                    
                    if IsValid(avatar_player) then
                        local avatar = CreateAvatarPanel(steamID)
                        
                        if avatar then
                            avatar:SetPos(x + 15, assist_y - traitor_panel.avatar_size/2)
                            avatar:SetSize(traitor_panel.avatar_size, traitor_panel.avatar_size)
                            avatar:SetAlpha(alpha)
                            avatar:SetVisible(true)
                            
                            surface.SetDrawColor(50, 50, 50, alpha)
                            surface.DrawOutlinedRect(x + 15, assist_y - traitor_panel.avatar_size/2, 
                                                     traitor_panel.avatar_size, traitor_panel.avatar_size, 1)
                        end
                    end
                end
                
                draw.SimpleText(display_name..status, "TraitorPanelText", x + traitor_panel.left_padding, assist_y, 
                                display_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                assist_y = assist_y + 25   
                

                if assist_y > y + height - 30 then
                    break
                end
            end
        else

            draw.SimpleText("No assistants available", "TraitorPanelText", x + traitor_panel.width/2, assist_y, 
                            Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else

        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
    end
end)


hook.Add("PostPlayerDeath", "ClearTraitorPanel", function(ply)
    if ply == LocalPlayer() then
        traitor_panel.dead_anim = {}
        traitor_panel.smooth_toggle = 0
        traitor_panel.visible = false
        
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
    end
end)


hook.Add("Think", "UpdateTraitorAssistants", function()
	if not LocalPlayer().isTraitor or not LocalPlayer().MainTraitor then return end

	if not traitor_panel.next_assistant_check or traitor_panel.next_assistant_check < CurTime() then
		traitor_panel.next_assistant_check = CurTime() + 0.5
		
		for name, alpha in pairs(traitor_panel.dead_anim) do
			local is_alive = false
			for _, v in player.Iterator() do
				if v.isTraitor and v.CurAppearance and v.CurAppearance.AName == name then
					is_alive = v:Alive() and (not v.organism or not v.organism.incapacitated)
					break
				end
			end
			
			if is_alive then
				traitor_panel.dead_anim[name] = nil
			end
		end
	end
end)


hook.Add("Think", "RequestTraitorStatus", function()
	if not LocalPlayer().isTraitor or not LocalPlayer().MainTraitor then return end
	
	if not traitor_panel.next_status_request or traitor_panel.next_status_request < CurTime() then
		traitor_panel.next_status_request = CurTime() + 2
		
		net.Start("HMCD_RequestTraitorStatuses")
		net.SendToServer()
	end
end)


--\\ Имена предателей-союзников над их головами (красным)
local ally_name_col = Color(225, 35, 35)
local ally_nick_col = Color(255, 120, 120)
local ally_names = {}
local ally_names_next = 0
local ally_vec_up = Vector(0, 0, 78)

local function GetAllyPlayer(info)
    if not info or #info < 2 then return nil end

    local steamID = info[3]
    if steamID and steamID ~= "" then
        local by_steam = player.GetBySteamID(steamID)
        if IsValid(by_steam) then return by_steam end
    end

    local name = info[2]
    if not name then return nil end

    for _, ply in player.Iterator() do
        if ply.CurAppearance and ply.CurAppearance.AName == name then return ply end
    end

    return nil
end

local function RebuildAllyNames()
    table.Empty(ally_names)

    for _, info in ipairs(MODE.TraitorsLocal or {}) do
        local ally = GetAllyPlayer(info)

        if IsValid(ally) and ally ~= LocalPlayer() then
            ally_names[ally] = info[1] or ally_name_col
        end
    end
end

hook.Add("HUDPaint", "HMCD_TraitorAlliesNames", function()
    local ply = LocalPlayer()
    if not ply.isTraitor or not ply:Alive() then return end

    if ally_names_next < CurTime() then
        ally_names_next = CurTime() + 0.25
        RebuildAllyNames()
    end

    if table.IsEmpty(ally_names) then return end

    local eye_pos = ply:EyePos()

    for ally, color in pairs(ally_names) do
        if not IsValid(ally) or not ally:Alive() then continue end
        if ally:GetNetVar("disappearance", nil) then continue end

        local ent = hg.GetCurrentCharacter(ally) or ally
        local head_pos = (IsValid(ent) and ent or ally):GetPos() + ally_vec_up
        local screen = head_pos:ToScreen()

        if not screen.visible then continue end

        local distance = eye_pos:Distance(head_pos)
        if distance > 4000 then continue end

        local trace = util.TraceLine({
            start = eye_pos,
            endpos = head_pos,
            filter = {ply, ent, ally},
            mask = MASK_SHOT,
        })

        local visible_ = (not trace.Hit) or trace.Fraction > 0.98
        local alpha = (visible_ and 255 or 60) * math.Clamp(1 - (distance - 2500) / 1500, 0.15, 1)

        if alpha <= 5 then continue end

        local name = ally:GetPlayerName() or ""
        local nick = ally:Nick() or ""
        local name_col = Color(color.r, color.g, color.b, alpha)
        local nick_col = Color(ally_nick_col.r, ally_nick_col.g, ally_nick_col.b, alpha)
        local shadow_col = Color(0, 0, 0, alpha)

        draw.SimpleText(name, "TraitorPanelText", screen.x + 1, screen.y + 1, shadow_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "TraitorPanelText", screen.x, screen.y, name_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if nick ~= "" and nick ~= name then
            draw.SimpleText(nick, "TraitorPanelText", screen.x + 1, screen.y + 21, shadow_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(nick, "TraitorPanelText", screen.x, screen.y + 20, nick_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)
