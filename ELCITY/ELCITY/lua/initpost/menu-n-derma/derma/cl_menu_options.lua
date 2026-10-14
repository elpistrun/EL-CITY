hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}

function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString, category, strHelp )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false, category, strHelp }
end
local hg_firstperson_death = CreateClientConVar("hg_firstperson_death", "0", true, false, "Toggle first-person death camera view", 0, 1)
local hg_font = CreateClientConVar("hg_font", "Rubik", true, false, "change every text font to selected because ui customization is cool")
local hg_attachment_draw_distance = CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "distance to draw attachments", 0, 4096)

xbars = 17
ybars = 30

gradient_l = Material("vgui/gradient-l")

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local sw, sh = ScrW(), ScrH()

local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Rubik"
    local usefont = hg_font:GetString()

    --\\ старый Bahnschrift из конфига и пустое значение считаем дефолтом
    if usefont == "" or usefont == "Bahnschrift" then
        usefont = "Rubik"
    end

    return usefont
end

surface.CreateFont("ZCity_setiings_tiny", {
	font = font(),
	size = ScreenScale(8),
	weight = 200
})

surface.CreateFont("ZCity_setiings_fine", {
	font = font(),
	size = ScreenScale(11),
	weight = 200
})

surface.CreateFont("ZCity_setiings_category", {
	font = font(),
	size = ScreenScale(15),
	weight = 200
})


hg.settings:AddOpt("Геймплей","hg_old_notificate", "Старые уведомления")
hg.settings:AddOpt("Геймплей","hg_cheats", "Включить читы")
hg.settings:AddOpt("Геймплей","hg_showthoughts", "Показывать мысли")
hg.settings:AddOpt("Геймплей","hg_hints", "Показывать подсказки")
hg.settings:AddOpt("Геймплей","hg_gary", "Центрировать оружие в фейке")
hg.settings:AddOpt("Геймплей","hg_deathfadeout", "Затемнение при смерти")
--hg_gary
--hg_deathfadeout
if not game.IsDedicated() then
	hg.settings:AddOpt("Серверные настройки","hg_toughnpcs", "Живучие NPC")
	hg.settings:AddOpt("Серверные настройки","hg_thirdperson", "Третье лицо (в разработке)")
	hg.settings:AddOpt("Серверные настройки","hg_legacycam", "Старая камера")
	hg.settings:AddOpt("Серверные настройки","hg_ragdollcombat", "Режим боя в рагдолле")
	hg.settings:AddOpt("Серверные настройки","hg_movement_stamina_debuff", "Замедление при низкой выносливости")
	hg.settings:AddOpt("Серверные настройки","hg_furcity", "Фурсити")
	hg.settings:AddOpt("Серверные настройки","hg_appearance_access_for_all", "Полный доступ к внешности для всех", nil, nil, "bool")
	hg.settings:AddOpt("Серверные настройки","hg_healanims", "Анимации лечения и еды")
	hg.settings:AddOpt("Серверные настройки","hg_aimtoshoot", "Стрельба только при прицеливании: 0 — выкл; 1 — от бедра; 2 — в прицеле", nil, nil, "int")
	hg.settings:AddOpt("Серверные настройки","hg_slings", "Система ремней")
	hg.settings:AddOpt("Серверные настройки","hg_allow_gopro", "Разрешить камеру в стиле GoPro")
	hg.settings:AddOpt("Серверные настройки","hg_allow_gopro_pos", "Разрешить менять позицию GoPro-камеры")
	hg.settings:AddOpt("Серверные настройки","hg_giveammomul", "Множитель патронов для оружия из меню спавна")
	hg.settings:AddOpt("Серверные настройки","hg_ixanims", "Анимации в стиле Helix для NPC-моделей игроков (эксперимент)")
	hg.settings:AddOpt("Серверные настройки","hg_coolhands", "Давать крутые кулаки вместо обычных")
	hg.settings:AddOpt("Серверные настройки","hg_loadcontent", "Загрузка контента клиентам через resource.AddWorkshop (нужен перезапуск сервера)")
    hg.settings:AddOpt("Серверные настройки","homicide_traitoramount", "Homicide: количество предателей", nil, nil, "int")
end
--hg_appearance_access_for_all
--hg_furcity
--hg_legacycam
--hg_toughnpcs

hg.settings:AddOpt("Отладка","hg_show_hitposmuzzle", "Показывать точку попадания")
hg.settings:AddOpt("Отладка","hg_setzoompos", "Настройка позиции прицеливания (результат в консоли)")
hg.settings:AddOpt("Отладка","hg_show_hitbox", "Показывать хитбоксы")

hg.settings:AddOpt("Оптимизация","hg_potatopc", "Режим слабого ПК")
hg.settings:AddOpt("Оптимизация","hg_anims_draw_distance", "Дистанция отрисовки анимаций", true, nil, "int")
hg.settings:AddOpt("Оптимизация","hg_anim_fps", "FPS анимаций", nil, nil, "int")
hg.settings:AddOpt("Оптимизация","hg_attachment_draw_distance", "Дистанция отрисовки обвесов", true, nil, "int")
hg.settings:AddOpt("Оптимизация","hg_maxsmoketrails", "Максимум дымных следов", nil, nil, "int")
hg.settings:AddOpt("Оптимизация","hg_tpik_distance", "Дистанция отрисовки TPIK", true, nil, "int")

hg.settings:AddOpt("Кровь","hg_blood_draw_distance", "Дистанция отрисовки крови")
hg.settings:AddOpt("Кровь","hg_blood_fps", "FPS отрисовки крови")
hg.settings:AddOpt("Кровь","hg_blood_sprites", "Спрайты крови (отключено для всех)")
hg.settings:AddOpt("Кровь","hg_old_blood", "Старая кровь")

hg.settings:AddOpt("Интерфейс","hg_font", "Свой шрифт интерфейса", false, true)

hg.settings:AddOpt("Оружие","hg_weaponshotblur_enable", "Размытие при стрельбе")
hg.settings:AddOpt("Оружие","hg_dynamic_mags", "Динамический осмотр патронов")
hg.settings:AddOpt("Оружие","hg_zoomsensitivity", "Чувствительность в прицеле")
hg.settings:AddOpt("Оружие","hg_highpitchgunfire", "Высокий звук выстрелов в зданиях")

hg.settings:AddOpt("Вид","hg_firstperson_death", "Вид от первого лица при смерти")
hg.settings:AddOpt("Вид","hg_fov", "Угол обзора", nil, nil, "int", "Ширина обзора от первого лица: 60 — узко, 120 — широко")
hg.settings:AddOpt("Вид","hg_newspectate", "Плавная камера наблюдателя")
hg.settings:AddOpt("Вид","hg_cshs_fake", "Ragdoll-камера C'sHS")
hg.settings:AddOpt("Вид","hg_gun_cam", "Камера оружия (только админ)")
hg.settings:AddOpt("Вид","hg_nofovzoom", "Отключить/включить зум FOV")
hg.settings:AddOpt("Вид","hg_realismcam", "Камера реализма")
hg.settings:AddOpt("Вид","hg_gopro", "GoPro-камера")
hg.settings:AddOpt("Вид","hg_newfakecam", "Новая камера фейка")
hg.settings:AddOpt("Вид","hg_leancam_mul", "Множитель наклона камеры", true, nil, "int")
hg.settings:AddOpt("Вид","hg_gun_cam", "Камера оружия (WIP, только админ)")
--hg_hints
--hg_leancam_mul
  --hg_newfakecam
hg.settings:AddOpt("Звук","hg_dmusic", "Динамическая музыка")
hg.settings:AddOpt("Звук","hg_quietshots", "Тихие звуки выстрелов")
hg.settings:AddOpt("Звук","hg_volume_round", "Громкость звуков раунда", nil, nil, "int")
hg.settings:AddOpt("Звук","hg_volume_shot", "Громкость выстрелов", nil, nil, "int")
hg.settings:AddOpt("Звук","hg_volume_explosion", "Громкость взрывов", nil, nil, "int")

--\\ Описания настроек (под заголовком)
hg.settings.helps = {
	["hg_old_notificate"] = "Старый вид всплывающих уведомлений",
	["hg_cheats"] = "Включает читы, если это разрешено на сервере",
	["hg_showthoughts"] = "Показывать мысли персонажа",
	["hg_hints"] = "Показывать подсказки интерфейса",
	["hg_gary"] = "Центрировать оружие, пока вы в фейке",
	["hg_deathfadeout"] = "Затемнять экран после смерти",
	["hg_toughnpcs"] = "Сделать NPC более живучими",
	["hg_thirdperson"] = "Вид от третьего лица, в разработке",
	["hg_legacycam"] = "Старая версия камеры",
	["hg_ragdollcombat"] = "Режим боя в рагдолле: ходьба, бег и т.д.",
	["hg_movement_stamina_debuff"] = "Множитель замедления при низкой выносливости",
	["hg_furcity"] = "Режим фурсити",
	["hg_appearance_access_for_all"] = "Полный доступ к редактору внешности для всех игроков",
	["hg_healanims"] = "Анимации лечения и приёма еды",
	["hg_aimtoshoot"] = "Стрельба как в DarkRP: 0 — выключено; 1 — только от бедра; 2 — только в прицеле",
	["hg_slings"] = "Система ремней для оружия",
	["hg_allow_gopro"] = "Разрешить камеру от первого лица в стиле GoPro",
	["hg_allow_gopro_pos"] = "Разрешить менять положение GoPro-камеры",
	["hg_giveammomul"] = "Множитель выдаваемых патронов для оружия из меню спавна",
	["hg_ixanims"] = "Анимации в стиле Helix для NPC-моделей игроков. Экспериментально",
	["hg_coolhands"] = "Выдавать крутые кулаки вместо обычных при спавне",
	["hg_loadcontent"] = "Загрузка контента клиентам через resource.AddWorkshop (нужен перезапуск сервера)",
	["homicide_traitoramount"] = "Homicide: количество предателей в раунде",
	["hg_show_hitposmuzzle"] = "Показывать точку попадания оружия",
	["hg_setzoompos"] = "Настройка позиции прицеливания, результат выводится в консоль",
	["hg_show_hitbox"] = "Показывать хитбоксы",
	["hg_potatopc"] = "Режим слабого ПК: снижает качество эффектов",
	["hg_anims_draw_distance"] = "Дистанция отрисовки анимаций",
	["hg_anim_fps"] = "Частота кадров анимаций",
	["hg_attachment_draw_distance"] = "Дистанция отрисовки обвесов",
	["hg_maxsmoketrails"] = "Максимальное число дымных следов",
	["hg_tpik_distance"] = "Дистанция отрисовки TPIK",
	["hg_blood_draw_distance"] = "Дистанция отрисовки крови",
	["hg_blood_fps"] = "Частота кадров отрисовки крови",
	["hg_blood_sprites"] = "Спрайты крови, отключено для всех",
	["hg_old_blood"] = "Старый вид крови",
	["hg_font"] = "Свой шрифт для всего интерфейса",
	["hg_weaponshotblur_enable"] = "Размытие экрана при стрельбе",
	["hg_dynamic_mags"] = "Показывать динамический остаток патронов при стрельбе",
	["hg_zoomsensitivity"] = "Множитель чувствительности мыши при прицеливании",
	["hg_highpitchgunfire"] = "Высокий звук выстрелов внутри зданий",
	["hg_firstperson_death"] = "Вид от первого лица после смерти",
	["hg_fov"] = "Угол обзора",
	["hg_newspectate"] = "Плавная камера наблюдателя",
	["hg_cshs_fake"] = "Ragdoll-камера C'sHS",
	["hg_gun_cam"] = "Камера оружия, только для админов",
	["hg_nofovzoom"] = "Отключить или включить зум при прицеливании",
	["hg_realismcam"] = "Камера реализма",
	["hg_gopro"] = "Камера в стиле GoPro",
	["hg_newfakecam"] = "Новая камера для фейка",
	["hg_leancam_mul"] = "Множитель наклона камеры",
	["hg_dmusic"] = "Динамическая музыка",
	["hg_quietshots"] = "Тихие звуки выстрелов",
	["hg_volume_round"] = "Громкость заставок начала и конца раунда и боевой музыки, 100 — обычная",
	["hg_volume_shot"] = "Громкость выстрелов, 100 — обычная",
	["hg_volume_explosion"] = "Громкость взрывов, 100 — обычная",
}
--//

local clr_category = Color(255,255,255,245)
local clr_1 = Color(255,255,255,235)
local clr_2 = Color(150,150,150,215)
local clr_3 = Color(28,28,28)
local clr_4 = Color(0, 0, 0, 30)
local clr_5 = Color(30, 29, 29, 30)
local clr_6 = Color(255, 255, 255, 100)
local clr_7 = Color(255, 255, 255, 200)
local clr_8 = Color(70, 130, 180)
local green_select = Color(0, 192, 0)

--\\ Действия, которые можно назначить на клавишу
--\ Движковые bind/unbind вызывать из Lua нельзя (GMod их блокирует),
--\ поэтому код клавиши храним в своём конваре и опрашиваем его в Think.
local bindableActions = {
    {cmd = "fake", title = "Фейк (притвориться мёртвым)", convar = "hg_bind_fake"},
    {cmd = "hg_kick", title = "Пинок ногой", convar = "hg_bind_kick"},
}

for _, action in ipairs(bindableActions) do
    if not ConVarExists(action.convar) then
        CreateClientConVar(action.convar, "0", true, false, "Клавиша для действия: " .. action.title)
    end

    action.pressed = false
end

local function GetActionKey(action)
    local convar = GetConVar(action.convar)
    local code = convar and convar:GetInt() or 0
    return code ~= 0 and code or nil
end

local function SetActionKey(action, code)
    RunConsoleCommand(action.convar, tostring(code or 0))
end

local function GetActionKeyName(action)
    local code = GetActionKey(action)
    if not code then return nil end

    return input.GetKeyName(code)
end

--\ Клавиша могла остаться в конфиге от старой версии (движковый bind),
--\ тогда её обрабатывает сама игра — здесь показываем её и не вызываем действие дважды.
local function GetEngineBind(action)
    local key = input.LookupBinding(action.cmd)
    if not key or key == "" then return nil end

    return key
end

local function GetActionDisplayKey(action)
    return GetActionKeyName(action) or GetEngineBind(action)
end

local function IsActionKeyDown(code)
    if not code then return false end

    --\ так работают и клавиши, и кнопки мыши
    return input.IsKeyDown(code) or input.IsMouseDown(code)
end

hook.Add("Think", "hg_bindable_actions", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local blocked = vgui.CursorVisible() or gui.IsGameUIVisible() or (ply.organism and ply.organism.otrub)

    for _, action in ipairs(bindableActions) do
        local ownKey = GetActionKeyName(action)
        local engineKey = GetEngineBind(action)
        local double_fire = ownKey and engineKey and string.lower(ownKey) == string.lower(engineKey)

        if double_fire then
            action.pressed = false
            continue
        end

        local down = (not blocked) and IsActionKeyDown(GetActionKey(action)) or false

        if down and not action.pressed then
            action.pressed = true
            RunConsoleCommand(action.cmd)
        elseif not down then
            action.pressed = false
        end
    end
end)

function MakeBindRow(action, parent, yPos)
    local row = vgui.Create('DButton', parent)
    row:SetSize(parent:GetWide() / 1.05, parent:GetTall() / 10)
    row:SetPos(parent:GetWide() / 2 - row:GetWide() / 2, yPos)
    row:SetText('')
    row:SetTextColor(clr_7)

    row.Paint = function(self, w, h)
        surface.SetDrawColor(43, 43, 43, 145)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(47, 47, 47, 145)
        surface.DrawRect(0, h - 3, w, 3)

        draw.SimpleText(action.title, 'ZCity_setiings_fine', 20, h / 2, clr_1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local key = self.capturing and "..." or (GetActionDisplayKey(action) or "НЕТ")
        draw.SimpleText(key, 'ZCity_setiings_fine', w - 20, h / 2, self.capturing and green_select or clr_7, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    row.DoClick = function(self)
        if self.capturing then
            self.capturing = false
            return
        end
        self.capturing = true
        input.StartKeyTrapping()
    end

    row.DoRightClick = function(self)
        self.capturing = false
        if GetActionKey(action) then
            SetActionKey(action, nil)
            action.pressed = false
            surface.PlaySound('glide/headlights_on.wav')
        end
    end

    row.Think = function(self)
        if self.capturing and input.IsKeyTrapping() then
            local code = input.CheckKeyTrapping()
            if code then
                if code == KEY_ESCAPE then
                    self.capturing = false
                    return
                end

                local modifiers = {[KEY_LSHIFT] = true, [KEY_RSHIFT] = true, [KEY_LCONTROL] = true, [KEY_RCONTROL] = true, [KEY_LALT] = true, [KEY_RALT] = true, [KEY_CAPSLOCK] = true, [KEY_LWIN] = true, [KEY_RWIN] = true}
                if modifiers[code] then return end

                local keyName = input.GetKeyName(code)
                if not keyName or keyName == "" or keyName == "???" then
                    self.capturing = false
                    return
                end

                SetActionKey(action, code)
                action.pressed = true
                self.capturing = false
                surface.PlaySound('glide/headlights_on.wav')
            end
        end
    end

    return row
end


function hg.CreateCategory(ctgName, ParentPanel, yPos)
    local pppanel = vgui.Create('DPanel', ParentPanel)
    pppanel:SetSize(ParentPanel:GetWide() / 1.05, ParentPanel:GetTall() * 0.07)
    pppanel:SetPos(ParentPanel:GetWide() / 2 -pppanel:GetWide() / 2, yPos)
    --pppanel:SetText(ctgName)
    pppanel.Paint = function(self,w,h)
        surface.SetDrawColor(60,60,60,145)
        surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(42, 42, 42, 184)
		surface.DrawRect(0, h-5, w, 5)
    
        draw.SimpleText(ctgName, 'ZCity_setiings_category', w / 2, h / 2, clr_category, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return pppanel
end

function hg.GetConVarType(convar)
    local stringv = convar:GetString()
    local floatVal = convar:GetFloat()
    local intVal = convar:GetInt()
    local boolVal = convar:GetBool()

    if (stringv == '0' and not boolVal) or (stringv == '1' and boolVal) then
        return 'bool'
    end

    if tonumber(stringv) and math.floor(stringv) == floatVal then
        if intVal == floatVal then
            return "int"
        end
    end

    return "string"
end

local function SetConVarValue(convar, value)
    if not convar then
        return
    end

    local name = convar.GetName and convar:GetName()
    if not name or name == "" then
        return
    end

    if isbool(value) then
        RunConsoleCommand(name, value and "1" or "0")
        return
    end

    RunConsoleCommand(name, tostring(value))
end

function hg.CreateButton(buttonData, convarName, ParentPanel, yPos)
    local convar = GetConVar(convarName)

    if not convar then 
        return 
    end
    local pppanel = vgui.Create('DPanel', ParentPanel)
    pppanel:SetSize(ParentPanel:GetWide()/1.05, ParentPanel:GetTall()/15)
    pppanel:SetPos(ParentPanel:GetWide()/2-pppanel:GetWide()/2, yPos)
    
    surface.SetFont('ZCity_setiings_fine')
    local width2, height2 = surface.GetTextSize(buttonData[3])
    local helpText = buttonData[7] or (hg.settings.helps and hg.settings.helps[convarName]) or convar:GetHelpText()
    
    convarType = buttonData[6] or hg.GetConVarType(convar)
    pppanel.Paint = function(self,w,h)
        surface.SetDrawColor(43, 43, 43,145)
        surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(47, 47, 47,145)
		surface.DrawRect(0, h-3, w, 3)
        
        draw.SimpleText(buttonData[3], 'ZCity_setiings_fine', 30, h / 2 -height2/2.5, clr_1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(helpText, 'ZCity_setiings_tiny', 30, h / 2+height2/2, clr_2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if convarType == 'bool' then
        local toggle = vgui.Create('DButton', pppanel)
        toggle:SetSize(pppanel:GetWide() / 18, pppanel:GetTall() / 2)

        
        toggle:SetPos(pppanel:GetWide() - toggle:GetWide()*1.4 - pppanel:GetWide() / 20, pppanel:GetTall() / 2 - toggle:GetTall() / 2)
        toggle:SetText('')
        
        local animProgress = convar:GetBool() and 1 or 0
        local targetProgress = animProgress
        
        function toggle:Paint(w, h)
            if animProgress ~= targetProgress then
                animProgress = Lerp(FrameTime() * 8, animProgress, targetProgress)
            end
            
            local bgColor = Color(
                Lerp(animProgress, 90, 0),  
                Lerp(animProgress, 130, 200),  
                Lerp(animProgress, 50, 0)   
            )
            
            local shadowColor = Color(0, 0, 0, Lerp(animProgress, 150, 40))
            surface.SetDrawColor(clr_3)
            draw.RoundedBox(0, 0, 0, w, h, clr_3)
            
            surface.SetDrawColor(clr_5)
            draw.RoundedBox(0, 2, 2, w - 4, h - 4, clr_4)
            
            local slsize = h - 12
            local slPos = Lerp(animProgress, 6, w - slsize - 6)
            surface.SetDrawColor(bgColor)
            draw.RoundedBox(0, slPos, 6, slsize, slsize, bgColor)
            surface.SetDrawColor(shadowColor)
            surface.DrawRect(slPos, slsize+4, slsize, 3)
    
            surface.SetDrawColor(clr_6)
        end
        
        function toggle:DoClick()
            if convar then
                local newValue = not convar:GetBool()
                SetConVarValue(convar, newValue)

                surface.PlaySound('glide/headlights_on.wav')
                targetProgress = newValue and 1 or 0
            end
        end
        
    elseif convarType == 'int' then
        local slider = vgui.Create('DNumSlider', pppanel)
        slider:SetSize(280, 30)
        slider:SetPos(pppanel:GetWide() - 300, pppanel:GetTall() / 2 - 15)
        slider:SetText('')
        
        local min = convar:GetMin() or 0
        local max = convar:GetMax() or 100
        local decimals = buttonData[4] and 2 or 0
        
        slider:SetMin(min)
        slider:SetMax(max)
        slider:SetDecimals(decimals)
        slider:SetValue(decimals > 0 and convar:GetFloat() or convar:GetInt())
        
        function slider:OnValueChanged(val)
            if convar then
                SetConVarValue(convar, decimals > 0 and math.Round(val, decimals) or math.Round(val))
            end
        end
        
        local valueLabel = vgui.Create('DLabel', pppanel)
        valueLabel:SetPos(pppanel:GetWide() - 350, pppanel:GetTall() / 2 - 8)
        valueLabel:SetSize(50, 20)
        valueLabel:SetText(convar:GetInt())
        valueLabel:SetTextColor(clr_7)
        valueLabel:SetFont('ZCity_setiings_tiny')
        
        slider.Think = function()
            if convar then
                valueLabel:SetText(convar:GetInt())
            end
        end
        
    elseif convarType == 'string' then
        local textEntry = vgui.Create('DTextEntry', pppanel)
        textEntry:SetSize(pppanel:GetWide()/8, pppanel:GetTall()/2)
        textEntry:SetPos(pppanel:GetWide()-pppanel:GetWide()/8-20, pppanel:GetTall()/2-textEntry:GetTall()/2)
        textEntry:SetText(convar:GetString())
        textEntry:SetUpdateOnType(true) 
        textEntry:SetFont('ZCity_Tiny')
        
    
        textEntry.Paint = function(self, w, h)
            surface.SetDrawColor(30, 30, 30, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(60, 60, 60, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
            
            self:DrawTextEntryText(color_white, clr_8, color_white)
        end
        
        function textEntry:OnValueChange(val)
            if convar then
                SetConVarValue(convar, val)
            end
        end
    end
    
    return pppanel
end

function hg.DrawSettings(ParentPanel)
    ParentPanel:SetAlpha(0)
    ParentPanel.Paint = function(self,w,h)

        surface.SetDrawColor(28,28,28,255)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(107, 107, 107,20)

        for i = 1, (ybars + 1) do
            surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
        end

        for i = 1, (xbars + 1) do
            surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
        end

        local border_size = ScreenScale(2)

        surface.SetDrawColor(0, 0, 0)
        surface.SetMaterial(gradient_l)
        surface.DrawTexturedRect(0, 0, border_size, sh)
		surface.SetMaterial(blur)
        surface.SetDrawColor(28,28,28,208)
        surface.DrawRect(0, 0, w, h)
    end
    hg.DrawBlur(ParentPanel, 5)
    ParentPanel:AlphaTo(255,0.15,0)
    local pppanel3 = vgui.Create('DScrollPanel', ParentPanel)
    pppanel3:SetSize(ParentPanel:GetWide(), ParentPanel:GetTall())
    pppanel3:SetPos(0,0)
    --pppanel3:SetAlpha(0)
    pppanel3.Paint = function()end
    -- 🥴 <- лучший смайлик

    local yOffset = pppanel3:GetTall()/100

    for categoryName, categoryTable in pairs(hg.settings.tbl) do
        local category = hg.CreateCategory(categoryName, pppanel3, yOffset)
        yOffset = yOffset + category:GetTall() + 12
        for convarName, settingData in pairs(categoryTable) do
            local vbv = hg.CreateButton(settingData,convarName,pppanel3,yOffset)
            if not vbv then continue end
            yOffset = yOffset + (vbv:GetTall()) + 12
        end
    end

    local bindsCategory = hg.CreateCategory("Управление", pppanel3, yOffset)
    yOffset = yOffset + bindsCategory:GetTall() + 12
    for _, action in ipairs(bindableActions) do
        local bindRow = MakeBindRow(action, pppanel3, yOffset)
        yOffset = yOffset + bindRow:GetTall() + 12
    end
    --\\ Порядок важен: шрифт и текст ставим до ширины, а SizeToContents у
    --\\ wrapped-лейбла НЕ вызываем — он схлопывает ширину до самой длинной
    --\\ строки переноса, и текст превращался в узкую вертикальную колонку.
    local bindsHint = vgui.Create('DLabel', pppanel3)
    bindsHint:SetFont('ZCity_setiings_tiny')
    bindsHint:SetColor(clr_2)
    bindsHint:SetWrap(true)
    bindsHint:SetAutoStretchVertical(true)
    bindsHint:SetText('Нажмите на действие, затем на клавишу — назначить. ПКМ — сбросить. Действие срабатывает в игре, когда не открыто меню. Если клавиша уже занята другой функцией — назначьте свободную.')
    bindsHint:SetWide(pppanel3:GetWide() / 1.05 - 60)
    bindsHint:SetPos(30, yOffset)
    bindsHint:InvalidateLayout(true)
    yOffset = yOffset + bindsHint:GetTall() + 24
    local pppanel23 = vgui.Create('DPanel', pppanel3)
    pppanel23:SetSize(0, 0)
    pppanel23:SetPos(0,yOffset+12)
end