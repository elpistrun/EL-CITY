zb = zb or {}
include("shared.lua")
include("loader.lua")

if not ConVarExists("hg_newspectate") then
    CreateClientConVar("hg_newspectate", "1", true, false, "Enables smooth spectator camera transitions", 0, 1)
end

function CurrentRound()
	return zb.modes[zb.CROUND]
end

zb.ROUND_STATE = 0
--0 = players can join, 1 = round is active, 2 = endround
local vecZero = Vector(0.2, 0.2, 0.2)
local vecFull = Vector(1, 1, 1)
spect,prevspect,viewmode = nil,nil,1
local hullscale = Vector(0,0,0)
net.Receive("ZB_SpectatePlayer", function(len)
	spect = net.ReadEntity()
	prevspect = net.ReadEntity()
	viewmode = net.ReadInt(4)

	timer.Simple(0.1,function()
		-- LocalPlayer():BoneScaleChange()
		LocalPlayer():SetHull(-hullscale,hullscale)
		LocalPlayer():SetHullDuck(-hullscale,hullscale)

		if viewmode == 3 then
			LocalPlayer():SetMoveType(MOVETYPE_NOCLIP)
		end
	end)
end)

zb.ROUND_TIME = zb.ROUND_TIME or 400
zb.ROUND_START = zb.ROUND_START or CurTime()
zb.ROUND_BEGIN = zb.ROUND_BEGIN or CurTime() + 5

net.Receive("updtime",function()
	local time = net.ReadFloat()
	local time2 = net.ReadFloat()
	local time3 = net.ReadFloat()

	zb.ROUND_TIME = time
	zb.ROUND_START = time2
	zb.ROUND_BEGIN = time3
end)

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local hg_potatopc

//\\ Подложка поверх размытия: "r g b a". По умолчанию тёмное стекло (0,0,0,125) — как фоны списков в Tab,
//\\ пустая строка — чистый размытый экран без подложки, "255 255 255 60" — светлое молоко
//\\ ВАЖНО: shouldsave = false, иначе у клиента остаётся зашитое в cfg/blur_tint старое значение и дефолт не виден
local cv_blur_tint = GetConVar("hg_blur_tint") or CreateClientConVar("hg_blur_tint", "0 0 0 125", false, false, "Цвет подложки размытия: r g b a (пусто — без подложки)")

//; у тех, кто уже играл со светлой подложкой, значение зашито в cfg — возвращаем дефолт
if cv_blur_tint:GetString() == "255 255 255 60" then
	cv_blur_tint:SetString("0 0 0 125")
end

local function BlurTintColor(minAlpha)
	local raw = cv_blur_tint:GetString() or ""

	if string.Trim(raw) == "" then return end

	local r, g, b, a = string.match(raw, "(%d+)[%s,]+(%d+)[%s,]+(%d+)[%s,]+(%d+)")

	if not r then return end

	return Color(math.Clamp(tonumber(r), 0, 255), math.Clamp(tonumber(g), 0, 255), math.Clamp(tonumber(b), 0, 255), math.Clamp(math.max(tonumber(a), minAlpha or 0), 0, 255))
end

//;\ Стекло за один кадр рисуется один раз: вложенная панель (список/скролл внутри окна)
//;\ получает уже готовую подложку родителя. Иначе подложка и размытие накладываются
//;\ дважды и вложенная панель превращается в чёрную плиту (видно на меню конца раунда)
local blur_frame = -1
local blur_drawn = {}

local function BlurOverdraw(x, y, w, h)
	local frame = FrameNumber()

	if frame ~= blur_frame then
		blur_frame = frame
		blur_drawn = {}
	end

	for i = 1, #blur_drawn do
		local r = blur_drawn[i]

		if x >= r[1] - 1 and y >= r[2] - 1 and x + w <= r[1] + r[3] + 1 and y + h <= r[2] + r[4] + 1 then
			return true
		end
	end

	blur_drawn[#blur_drawn + 1] = {x, y, w, h}

	return false
end

hg = hg or {}
function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	// old blur
	if not IsValid(panel) then return end

	local x, y = panel:LocalToScreen(0, 0)
	local w, h = panel:GetWide(), panel:GetTall()

	// potato-режим размытие не отключает, а только ослабляет
	amount = (amount or 5) * ((hg_potatopc and hg_potatopc:GetBool()) and 0.5 or 1)

	if w > 0 and h > 0 and not BlurOverdraw(x, y, w, h) then
		// blurscreen обязательно рисуем БЕЛЫМ: с чёрным цветом вместо размытия выходит затемнение
		surface.SetMaterial(blur)
		surface.SetDrawColor(255, 255, 255, 255)

		for i = 0.34, 1, 0.33 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end

		// подложка ложится ПОВЕРХ размытия; цвет и прозрачность берём из hg_blur_tint
		local tint = BlurTintColor()

		if tint then
			surface.SetDrawColor(tint)
			surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		end
	end

	--surface.SetMaterial(blur2)
	--surface.SetDrawColor(color_white)
	--local x, y = panel:LocalToScreen(0, 0)
--
	--// those are currently hardcoded cuz it would be too much of a hassle to change this
	--blur2:SetFloat("$c0_x", (amount or 5) * 2500) // density
	--blur2:SetFloat("$c0_y", (passes or 0.2) * 2000) // noise (inverted)
	--blur2:SetFloat("$c0_z", 1) // blending
--
	--render.UpdateScreenEffectTexture()
	--surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())

	-- surface.SetDrawColor(0, 0, 0, alpha or 125)
	-- surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
end

BlurBackground = BlurBackground or hg.DrawBlur

local keydownattack
local keydownattack2
local keydownreload

//\\ Язык интерфейса: свой конвар hg_localization (ru / en), иначе — стандартный gmod_language.
//\\ Через hg.LangText идут подсказки, которые сборка рисует сама (без .properties)
if not ConVarExists("hg_localization") then
	CreateClientConVar("hg_localization", "ru", true, false, "Язык интерфейса: ru / en")
end

function hg.IsEnglish()
	local cv = ConVarExists("hg_localization") and GetConVar("hg_localization") or (ConVarExists("gmod_language") and GetConVar("gmod_language") or nil)
	local lang = string.lower(cv and cv:GetString() or "")

	return string.sub(lang, 1, 2) == "en" or lang == "english"
end

function hg.LangText(ru, en)
	return hg.IsEnglish() and en or ru
end

//\\ Сколько на сервере реально играющих: наблюдатели в счёт не идут. Со стороны сервера
//\\ правило то же самое (zb:PlayingCount в libraries/sv_roundsystem.lua)
function zb.PlayingCount()
	local count = 0

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		count = count + 1
	end

	return count
end

//\\ Минимум играющих для старта раунда. Пока играющих меньше, раунд не начинается,
//\\ а сверху по центру висит подсказка — иначе одинокий игрок просто умирал на старте
//\\
//\\ Считаются только те, кто реально в игре: наблюдатель (TEAM_SPECTATOR) в счёт не идёт.
//\\ Правило то же, что у сервера при старте раунда (zb:PlayingCount):
//\\   1 игрок + 1 наблюдатель              -> надпись есть (играющий один, нужно 2)
//\\   2 игрока + 1 наблюдатель              -> надписи нет (играющих двое)
//\\   1 игрок + 2 наблюдателя               -> надпись есть (играющий один, нужно 2)
local MIN_ROUND_PLAYERS = 2

//; надпись намеренно полупрозрачная: она висит поверх игры и не должна загораживать картинку
//; (больше — заметнее, 255 — как обычный HUD)
local NEED_PLAYERS_ALPHA = 130

hook.Add("HUDPaint", "ZB_NeedMorePlayers", function()
	//; в идущем раунде подсказка не нужна
	if zb.ROUND_STATE == 1 then return end
	if zb.PlayingCount() >= MIN_ROUND_PLAYERS then return end

	local txt = hg.LangText("Необходимо 2 игрока чтобы начать играть", "Need 2 players to start playing")

	surface.SetFont("ZB_InterfaceLarge")

	local tw = surface.GetTextSize(txt)
	local x, y = ScrW() / 2 - tw / 2, ScrH() * 0.05

	//; тень, но тоже приглушённая — иначе она делает текст почти непрозрачным обратно
	surface.SetTextColor(0, 0, 0, NEED_PLAYERS_ALPHA * 0.7)
	surface.SetTextPos(x + 2, y + 2)
	surface.DrawText(txt)

	surface.SetTextColor(255, 255, 255, NEED_PLAYERS_ALPHA)
	surface.SetTextPos(x, y)
	surface.DrawText(txt)
end)

//\\ Диагностика: hg_playingcount печатает, кого клиент считает игроком, а кого наблюдателем.
//\\ Если надпись «Необходимо 2 игрока» не появляется — она подскажет, кто в счёте лишний
concommand.Add("hg_playingcount", function()
	local playing, spectating = 0, 0

	for _, ply in player.Iterator() do
		local spect = (ply:Team() == TEAM_SPECTATOR)

		if spect then spectating = spectating + 1 else playing = playing + 1 end

		MsgN(string.format("[Z-City] %s (%s): команда %d — %s", ply:Nick(), ply:SteamID(), ply:Team(),
			spect and "наблюдатель" or "игрок"))
	end

	MsgN(string.format("[Z-City] играющих: %d (нужно %d), наблюдателей: %d, состояние раунда: %s",
		playing, MIN_ROUND_PLAYERS, spectating, tostring(zb.ROUND_STATE)))
end)

hook.Add("HUDPaint","FUCKINGSAMENAMEUSEDINHOOKFUCKME",function()
    if LocalPlayer():Alive() then return end
	local spect = LocalPlayer():GetNWEntity("spect")
	if not IsValid(spect) then return end
	if viewmode == 3 then return end
	
	surface.SetFont("HomigradFont")
	surface.SetTextColor(255, 255, 255, 255)
	local txt = "Spectating player: "..spect:Name()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7)
	surface.DrawText(txt)
	local txt = "In-game name: "..spect:GetPlayerName()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7 + h)
	surface.DrawText(txt)
end)

hook.Add("HG_CalcView", "zzzzzzzUwU", function(ply, pos, angles, fov)
	if not lply:Alive() then
		if lply:KeyDown(IN_ATTACK) then
			if not keydownattack then
				keydownattack = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_ATTACK,32)
				net.SendToServer()
			end
		else
			keydownattack = false
		end

		if lply:KeyDown(IN_ATTACK2) then
			if not keydownattack2 then
				keydownattack2 = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_ATTACK2,32)
				net.SendToServer()
			end
		else
			keydownattack2 = false
		end

		if lply:KeyDown(IN_RELOAD) then
			if not keydownreload then
				keydownreload = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_RELOAD,32)
				net.SendToServer()
			end
		else
			keydownreload = false
		end

		local spect = lply:GetNWEntity("spect",spect)
		if not IsValid(spect) then return end

		local viewmode = lply:GetNWInt("viewmode",viewmode)
		
		if viewmode == 3 then
			if lply:GetMoveType()!=MOVETYPE_NOCLIP then
				lply:SetMoveType(MOVETYPE_NOCLIP)
			end
			lply:SetObserverMode(OBS_MODE_ROAMING)
			return
		else
			lply:SetPos(spect:GetPos())
		end
		
		local ent = hg.GetCurrentCharacter(spect)
		if not IsValid(ent) then return end
		
		local headBone = ent:LookupBone("ValveBiped.Bip01_Head1") or ent:LookupBone("ValveBiped.Bip01_Spine1") or 1
		local bon = ent:GetBoneMatrix(headBone)
		
		if not bon then 
			local eyePos = ent:EyePos()
			if eyePos and eyePos ~= vector_origin then
				pos = eyePos
				ang = ent:EyeAngles()
			else
				pos = ent:GetPos() + Vector(0, 0, 64)
				ang = ent:GetAngles()
			end
		else
			pos, ang = bon:GetTranslation(), bon:GetAngles()
		end

		local eyePos, eyeAng = lply:EyePos(), lply:EyeAngles()
		
		local tr = {}
		tr.start = pos
		tr.endpos = pos + eyeAng:Forward() * -120
		tr.filter = {ent, lply, spect}
		tr.mins = Vector(-4, -4, -4)
		tr.maxs = Vector(4, 4, 4)
		tr = util.TraceHull(tr)

		if viewmode == 2 then
			pos = tr.HitPos + eyeAng:Forward() * 8
			ang = eyeAng
		elseif viewmode == 1 then
			if ent ~= spect and IsValid(ent) then
				local eyeAtt = ent:GetAttachment(ent:LookupAttachment("eyes"))
				if eyeAtt then
					ang = eyeAtt.Ang
				else
					ang = spect:EyeAngles()
				end
			else
				ang = spect:EyeAngles()
			end
			pos = pos + spect:EyeAngles():Forward() * 8
		else
			pos = eyePos
			ang = eyeAng
		end
		
		ang[3] = 0
		
		local view
		local hg_newspectate = GetConVar("hg_newspectate")
		if hg_newspectate and hg_newspectate:GetBool() then
			if not lply.spectLastPos then
				lply.spectLastPos = pos
				lply.spectLastAng = ang
			end
			
			local lerpFactor = FrameTime() * 10
			lply.spectLastPos = LerpVector(lerpFactor, lply.spectLastPos, pos)
			lply.spectLastAng = LerpAngle(lerpFactor, lply.spectLastAng, ang)

			view = {
				origin = lply.spectLastPos,
				angles = lply.spectLastAng,
				fov = fov,
			}
		else
			view = {
				origin = pos,
				angles = ang,
				fov = fov,
			}
		end

		return view
	else
		lply.spectLastPos = nil
		lply.spectLastAng = nil
		lply:SetObserverMode(OBS_MODE_NONE)
	end
end)

zb.fade = zb.fade or 0

hook.Add("RenderScreenspaceEffects", "huyhuyUwU", function()
	if zb.fade > 0 then
		zb.fade = math.Approach(zb.fade, 0, FrameTime() * 1)

		surface.SetDrawColor(0, 0, 0, 255 * math.min(zb.fade, 1))
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end
end)

zb.ROUND_STATE = 0
net.Receive("RoundInfo", function()
	local rnd = net.ReadString()
	
	hook.Run("RoundInfoCalled", rnd)

	if zb.CROUND ~= rnd then
		if hg.DynaMusic then
			hg.DynaMusic:Stop()
		end
	end

	zb.CROUND = rnd

	zb.ROUND_STATE = net.ReadInt(4)
	
	if zb.ROUND_STATE == 0 then
		zb.fade = 7
	end

	if zb.CROUND ~= "" then
		if CurrentRound() then
			if zb.ROUND_STATE == 3 then
				if CurrentRound().EndRound then
					CurrentRound():EndRound()
				end
			elseif zb.ROUND_STATE == 1 then
				if CurrentRound().RoundStart then
					CurrentRound():RoundStart()
				end
			end
		end
	end
end)

if IsValid(scoreBoardMenu) then
	scoreBoardMenu:Remove()
	scoreBoardMenu = nil
end

hook.Add("Player Disconnected","retrymenu",function(data)
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
end)

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Rubik", true, false, "Change UI text font")

--\\ переезд на Rubik: старый Bahnschrift в конфиге меняем один раз, до создания шрифтов
if hg_font and hg_font:GetString() == "Bahnschrift" then
	hg_font:SetString("Rubik")
end

local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Rubik"
    local usefont = hg_font:GetString()

    --\\ старый Bahnschrift из конфига и пустое значение считаем дефолтом
    if usefont == "" or usefont == "Bahnschrift" then
        usefont = "Rubik"
    end

    return usefont
end

surface.CreateFont("ZB_InterfaceSmall", {
    font = font(),
    size = ScreenScale(6),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceMedium", {
    font = font(),
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_ScrappersMedium", {
    font = font(),
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceMediumLarge", {
    font = font(),
    size = 35,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceLarge", {
    font = font(),
    size = ScreenScale(20),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceHumongous", {
    font = font(),
    size = 200,
    weight = 400,
    antialias = true
})

//\\ Иконки FontAwesome (шрифт идёт вместе с игрой) — используются в списке игроков на Tab
//\\ имя семейства именно "FontAwesome" — так он же зарегистрирован в ULib/ULX на этом клиенте
surface.CreateFont("ZB_Icons", {
    font = "FontAwesome",
    size = ScreenScale(9),
    weight = 400,
    antialias = true,
    extended = true
})

//\\ Font Awesome 5 не подключаем: на этом клиенте он регистрируется Regular-лицом,
//\\ а в нём глифов динамика нет ни одного — вместо значка выходит пустая рамка (notdef).
//\\ У FA4 (семейство "FontAwesome") все нужные глифы на месте, и он уже работает у всех

//\\ Глифы через UTF-8 escape'ы, чтобы не тащить юникод в исходник:
//\\ U+F028 — динамик с тремя волнами, U+F027 — с одной (тихо),
//\\ U+F026 — динамик с крестом: и заглушённый игрок, и выставленный ему ноль
local FA_VOLUME_UP = "\239\128\168"
local FA_VOLUME_DOWN = "\239\128\167"
local FA_VOLUME_OFF = "\239\128\166"
local CLR_SOUND_ON = Color(255, 255, 255)
local CLR_SOUND_QUIET = Color(255, 200, 60)
local CLR_SOUND_MUTED = Color(255, 70, 70)

//\\ Громкость игрока 0..1 — ровно та цифра, которую крутит слайдер в меню
//\\ (ПКМ по динамику в списке игроков); у неизвестного игрока считаем полной
function hg.VoiceVolume(ply)
	if not IsValid(ply) then return 1 end

	local info = hg.playerInfo and hg.playerInfo[ply:SteamID()]
	local vol = istable(info) and tonumber(info[2])

	return math.Clamp(vol or 1, 0, 1)
end

//\\ Иконка динамика берётся из громкости, а не из одного флага «заглушен»:
//\\ 0 — перечёркнутый, до половины — «тихий» с одной волной, выше — обычный с тремя.
//\\ Перечёркивание у FA4 нарисовано внутри самого глифа, поэтому линиями мы его не дублируем
function hg.VoiceIcon(ply)
	if not IsValid(ply) then return FA_VOLUME_UP, CLR_SOUND_ON, 255 end

	//; заглушённый галочкой и выставленный ноль — один глиф с крестом: различимых
	//; глифов динамика в FA4 ровно три, а состояние «выключено» одно — разводим их яркостью
	if ply:IsMuted() then return FA_VOLUME_OFF, CLR_SOUND_ON, 255 end

	local vol = hg.VoiceVolume(ply)

	if vol <= 0 then return FA_VOLUME_OFF, CLR_SOUND_ON, 255 end

	local alpha = 255

	if vol <= 0.5 then return FA_VOLUME_DOWN, CLR_SOUND_ON, alpha end

	return FA_VOLUME_UP, CLR_SOUND_ON, alpha
end

//; запасные значки динамика: если лица FontAwesome с нужным глифом на клиенте нет,
//; вместо значка выходит пустая рамка (notdef) — «иконка не показывается». Тогда рисуем png
local SOUND_MATS = {Material("icon16/sound.png"), Material("icon16/sound_mute.png")}

//; «пустышка»: отсутствующий глиф рисуется рамкой notdef, и её ширина совпадает
//; с шириной заведомо отсутствующего символа \1 — этим и отличаем битый глиф от рабочего
local function IconGlyphBroken(tw, th)
	if tw <= 0 or th <= 0 then return true end

	surface.SetFont("ZB_Icons")

	return tw == surface.GetTextSize("\1")
end

//\\ Значок звука в списке игроков: глиф динамика из FA4, цвет и яркость идут за громкостью
function hg.DrawSoundIcon(ply, w, h, hovered)
	if not IsValid(ply) then return end

	local icon, color, alpha = hg.VoiceIcon(ply)

	//; при наведении значок только немного ярче: раньше он разом становился белым 255,
	//; и тогда яркость переставала показывать громкость именно в момент, когда смотришь
	if hovered then alpha = math.min(255, alpha + 45) end

	//; значок рисуем тем же FA4, что и остальные глифы сборки (ZB_Icons)
	surface.SetFont("ZB_Icons")

	local tw, th = surface.GetTextSize(icon)

	//; битый или недошедший глиф — рисуем обычный png из icon16, чтобы значок был виден
	//; в любом случае (проверить, что видит клиент, можно командой hg_voiceicons)
	if IconGlyphBroken(tw, th) then
		local silent = ply:IsMuted() or hg.VoiceVolume(ply) <= 0

		surface.SetDrawColor(color.r, color.g, color.b, alpha)
		surface.SetMaterial(SOUND_MATS[silent and 2 or 1])

		local size = math.min(w, h) * 0.9

		surface.DrawTexturedRect(w / 2 - size / 2, h / 2 - size / 2, size, size)

		return
	end

	local tx, ty = w / 2 - tw / 2, h / 2 - th / 2

	surface.SetTextColor(color.r, color.g, color.b, alpha)
	surface.SetTextPos(tx, ty)
	surface.DrawText(icon)
end

//\\ Диагностика значка: hg_voiceicons печатает, какую громкость клиент видит у игроков
//\\ (если команда неизвестна — значит эта версия файла до клиента не доехала).
//\\ Заодно печатает размер глифа: 0x0 значит, что шрифт ZB_Icons до клиента не дошёл
concommand.Add("hg_voiceicons", function()
	surface.SetFont("ZB_Icons")

	for _, ply in player.Iterator() do
		local vol = hg.VoiceVolume(ply)
		local raw = hg.playerInfo and hg.playerInfo[ply:SteamID()]
		local icon = hg.VoiceIcon(ply)
		local tw, th = surface.GetTextSize(icon)

		MsgN(string.format("[Z-City] %s (%s): громкость %d%% (%s в таблице), заглушен %s, глиф %s %dx%d, время игры %s",
			ply:Nick(), ply:SteamID(), math.Round(vol * 100), tostring(raw and raw[2]),
			ply:IsMuted() and "да" or "нет",
			vol <= 0 and "off" or (vol <= 0.5 and "down" or "up"),
			tw, th, hg.PlaytimeText(hg.GetPlaytime(ply)) or "нет данных"))
	end
end)

//\\ Время игры на сервере: сервер считает секунды и присылает таблицу steamid64 -> секунды
//\\ (libraries/sv_playtime.lua). Клиентская половина живёт здесь, а не отдельным файлом
//\\ в libraries/: новый файл там доезжает до игроков только после перезагрузки сервера,
//\\ а cl_init.lua у клиента обновляется вместе со сборкой — иначе в Tab падает вызов
hg.Playtime = hg.Playtime or {}

//; сервер шлёт строку «steamid=секунды;…» — так типы не портятся (см. sv_playtime.lua).
//; pcall нужен на время перехода: сервер, который ещё не перезапущен, шлёт таблицу,
//; и такой пакет лучше молча пропустить, чем ругаться ошибкой чтения в консоли
net.Receive("zb_playtime", function()
	local ok, raw = pcall(net.ReadString)

	if not ok or not raw then return end

	local tbl = {}

	for sid, secs in string.gmatch(raw, "(%d+)=(%d+)") do
		tbl[sid] = tonumber(secs)
	end

	hg.Playtime = tbl
	hg.PlaytimeBytes = #raw
end)

//; сколько секунд игрок уже наиграл на сервере; nil — данных нет (бот или сервер не прислал)
function hg.GetPlaytime(ply)
	if not IsValid(ply) or ply:IsBot() then return end

	local sid = ply:SteamID64()

	if not sid then return end

	//; числовой ключ — страховка от старых вариантов передачи (net.WriteTable терял тип)
	return tonumber(hg.Playtime[sid]) or tonumber(hg.Playtime[tonumber(sid)])
end

//\\ Формат «1.5h» = 1 час 50 минут: цифра после точки — это десятки минут, а не доля часа.
//\\ Так, по примерам: 10 минут — «0.1h», 1 час 50 минут — «1.5h», меньше 10 минут — «0.0h»
function hg.PlaytimeText(secs)
	if not secs then return end

	local mins = math.max(0, math.floor(secs / 60))
	local hours = math.floor(mins / 60)
	local tens = math.floor((mins % 60) / 10)

	return hours.."."..tens.."h"
end

//\\ Диагностика: hg_playtime печатает в консоль, что клиент знает о времени игры
//\\ (если везде «нет данных» — значит таблица с сервера не доехала)
concommand.Add("hg_playtime", function()
	local count = 0

	for _, ply in player.Iterator() do
		if ply:IsBot() then continue end

		count = count + 1

		MsgN(string.format("[Z-City] %s (%s): %s", ply:Nick(), ply:SteamID(),
			hg.PlaytimeText(hg.GetPlaytime(ply)) or "нет данных"))
	end

	MsgN(string.format("[Z-City] записей в таблице: %d, игроков в списке: %d, последняя посылка: %d байт",
		table.Count(hg.Playtime), count, hg.PlaytimeBytes or 0))
end)

hg.playerInfo = hg.playerInfo or {}

local function addToPlayerInfo(ply, muted, volume)
	hg.playerInfo[ply:SteamID()] = {muted and true or false, volume}

	local json = util.TableToJSON(hg.playerInfo)
	file.Write("zcity_muted.txt", json)

	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")

		if json then
			hg.playerInfo = util.JSONToTable(json)
		end
	end

	//PrintTable(hg.playerInfo)
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "zcityhuy", function(data)
	local ply = Player(data.userid)
	if IsValid(ply) and ply.SetMuted and hg.playerInfo and hg.playerInfo[data.networkid] then
		ply:SetMuted(hg.playerInfo[data.networkid][1])
		ply:SetVoiceVolumeScale(hg.playerInfo[data.networkid][2])
	end
end)

hook.Add("InitPostEntity", "furryhuy", function()
	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")

		if json then
			hg.playerInfo = util.JSONToTable(json)
		end

		if hg.playerInfo then
			for i, ply in player.Iterator() do
				if not istable(hg.playerInfo[ply:SteamID()]) then
					local muted = hg.playerInfo[ply:SteamID()]
					hg.playerInfo[ply:SteamID()] = {}
					hg.playerInfo[ply:SteamID()][1] = muted
					hg.playerInfo[ply:SteamID()][2] = 1
				end//compatibility with old json

				if hg.playerInfo[ply:SteamID()] then
					ply:SetMuted(hg.playerInfo[ply:SteamID()][1])
					ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
				end
			end	
		end
	end
end)

local colGray = Color(122,122,122,255)
local colBlue = Color(10,130,10)
local colBlueUp = Color(30,160,30)
local col = Color(255,255,255,255)

//; наблюдатели (и мёртвые, которые смотрят) — заметно темнее живых: строка сразу читается
local colSpect1 = Color(48,48,48,255)
local colSpect2 = Color(60,60,60,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

hg.muteall = false
hg.mutespect = false

local function OpenPlayerSoundSettings(selfa, ply)
	local Menu = DermaMenu()
	
	if not hg.playerInfo[ply:SteamID()] or not istable(hg.playerInfo[ply:SteamID()]) then addToPlayerInfo(ply, false, 1) end

	local mute = Menu:AddOption( "Заглушить", function(self)
		if hg.muteall || hg.mutespect then return end
		
		self:SetChecked(not ply:IsMuted())
		ply:SetMuted( not ply:IsMuted() )
		//; иконка в списке перерисуется сама — она смотрит на ply:IsMuted() в Paint
		addToPlayerInfo(ply, ply:IsMuted(), hg.playerInfo[ply:SteamID()][2])
	end ) -- get your stupid one line ass outta here

	mute:SetIsCheckable( true )
	mute:SetChecked( ply:IsMuted() )
	local volumeSlider = vgui.Create("DSlider", Menu)
	volumeSlider:SetLockY( 0.5 )
	volumeSlider:SetTrapInside( true )
	volumeSlider:SetSlideX(hg.playerInfo[ply:SteamID()][2]) 
	volumeSlider.OnValueChanged = function(self, x, y)
		if not IsValid(ply) then return end
		if hg.muteall or (hg.mutespect && !ply:Alive()) then return end
		hg.playerInfo[ply:SteamID()][2] = x
		ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
		addToPlayerInfo(ply, ply:IsMuted(), hg.playerInfo[ply:SteamID()][2])
	end

	function volumeSlider:Paint(w,h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
		draw.RoundedBox( 0, 0, 0, w*self:GetSlideX(), h, Color( 0, 192, 0 ) )
		draw.DrawText( ( math.Round( 100*self:GetSlideX(), 0 ) ).."%", "DermaDefault", w/2, h/4, color_white, TEXT_ALIGN_CENTER )
	end
	function volumeSlider.Knob.Paint(self) end

	Menu:AddPanel(volumeSlider)
	Menu:Open()
end



hook.Add("Player Getup", "nomorespect", function(ply)
	if not hg.mutespect then return end

	//ply:SetMuted(ply.oldmutedspect)
	ply:SetVoiceVolumeScale(!hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
	//ply.oldmutedspect = nil

	//if IsValid(ply.soundButton) then
		//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
	//end
end)

hook.Add("Player_Death", "fixSpectatorVoiceMute", function(ply)
	if not hg.mutespect then return end

	//ply.oldmutedspect = ply:IsMuted()
	//ply:SetMuted(hg.mutespect)
	ply:SetVoiceVolumeScale(0)
	//if IsValid(ply.soundButton) then
		//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
	//end
end)

hook.Add("Player_Death", "fixSpectatorVoiceEffect", function(ply)
	if eightbit and eightbit.EnableEffect and ply.UserID then
		eightbit.EnableEffect(ply:UserID(), 0)
	end
end)

//\\ Размытие фона у списка игроков (Tab)
local cv_scoreblur = CreateClientConVar("hg_scoreboard_blur", "1", true, false, "Размытие фона у списка игроков (Tab)", 0, 1)

function hg.ScoreboardBlur()
	return cv_scoreblur:GetBool()
end

//\\ Правый край строки занят: иконка звука с пингом. Роль рисуется
//\\ по центру, но в этот запас не заезжает — иначе они накладываются друг на друга
local TAB_RIGHT_RESERVE = 150

//\\ Роль игрока для списка в Tab: User / ElPass / Operator / Admin / Head Admin / SuperAdmin
local TAB_ROLES = {
	["user"] = {"User", Color(175, 175, 175)},
	["elpass"] = {"ElPass", Color(255, 200, 60)},
	["operator"] = {"Operator", Color(90, 190, 255)},
	["operatod"] = {"Operator", Color(90, 190, 255)}, -- на сервере группа записана с опечаткой «operatod»
	["admin"] = {"Admin", Color(255, 120, 60)},
	["headadmin"] = {"Head Admin", Color(215, 100, 255)},
	["head admin"] = {"Head Admin", Color(215, 100, 255)},
	["head_admin"] = {"Head Admin", Color(215, 100, 255)},
	["superadmin"] = {"SuperAdmin", Color(255, 60, 60)},
}

function hg.TabRole(ply)
	if not IsValid(ply) then return end
	if ply:IsBot() then return "Bot", Color(130, 130, 130) end

	local group = string.lower(ply:GetUserGroup() or "")
	local role = TAB_ROLES[group]
	local pass = (hg.ElPass and hg.ElPass.IsMember(ply)) and true or false

	//; ElPass видно даже у стаффа: «Admin · ElPass»
	if pass and role and group != "elpass" then
		return role[1].." · ElPass", role[2]
	end

	if role then return role[1], role[2] end
	if pass then return TAB_ROLES["elpass"][1], TAB_ROLES["elpass"][2] end

	// неизвестная ULX-группа — показываем её как есть, а не как User
	if group != "" then
		return string.upper(string.Left(group, 1))..string.sub(group, 2), TAB_ROLES["user"][2]
	end

	return TAB_ROLES["user"][1], TAB_ROLES["user"][2]
end

//\\ Скруглённая обводка: у surface.DrawOutlinedRect нет радиуса, поэтому рисуем
//\\ 4 прямых участка + 4 угловые дуги из коротких «мазков» (шаг ~1px)
function hg.DrawRoundedOutline(x, y, w, h, radius, thickness, color)
	surface.SetDrawColor(color)

	radius = math.Clamp(radius or 0, 0, math.min(w, h) / 2)
	thickness = math.max(thickness or 1, 1)
	local half = thickness / 2

	surface.DrawRect(x + radius, y, w - radius * 2, thickness)					-- верх
	surface.DrawRect(x + radius, y + h - thickness, w - radius * 2, thickness)	-- низ
	surface.DrawRect(x, y + radius, thickness, h - radius * 2)					-- лево
	surface.DrawRect(x + w - thickness, y + radius, thickness, h - radius * 2)	-- право

	if radius <= 0 then return end

	-- углы: дуга из мазков толщиной thickness
	local steps = math.max(3, math.ceil(radius * 1.5))

	local corners = {
		{ x + radius, y + radius, 180, 270 },			-- левый верх
		{ x + w - radius, y + radius, 270, 360 },		-- правый верх
		{ x + w - radius, y + h - radius, 0, 90 },		-- правый низ
		{ x + radius, y + h - radius, 90, 180 },			-- левый низ
	}

	for _, c in ipairs(corners) do
		for i = 0, steps do
			local ang = math.rad(c[3] + (c[4] - c[3]) * (i / steps))

			surface.DrawRect(c[1] + math.cos(ang) * radius - half, c[2] + math.sin(ang) * radius - half, thickness, thickness)
		end
	end
end

//\\ Кнопка перехода в игроки / наблюдатели: подпись по центру и плавная подсветка при наведении
local function MakeTeamButton(parent, text, x, y, right_anchor, to_spectator)
	local base_w, h = ScrW() / 20, ScrH() / 30

	//; кнопка выбора команды: зелёная обводка 2 px без скругления + подсветка подписи при наведении
	local hover_color = Color(0, 255, 0)

	// подбираем шрифт так, чтобы подпись влезала в кнопку
	surface.SetFont("ZB_InterfaceMedium")
	local text_w = surface.GetTextSize(text)
	local font_name = "ZB_InterfaceMedium"

	if text_w + 26 > base_w then
		font_name = "ZB_InterfaceSmall"

		surface.SetFont(font_name)
		text_w = surface.GetTextSize(text)
	end

	local w = math.max(base_w, text_w + 26)

	if right_anchor then
		x = x + base_w - w
	end

	local btn = vgui.Create("DButton", parent)
	btn:SetPos(x, y)
	btn:SetSize(w, h)
	btn:SetText("")
	btn.hg_hover = 0

	btn.DoClick = function()
		net.Start("ZB_SpecMode")
			net.WriteBool(to_spectator)
		net.SendToServer()

		if IsValid(scoreBoardMenu) then
			scoreBoardMenu:Remove()
		end

		scoreBoardMenu = nil
	end

	btn.Paint = function(self,bw,bh)
		self.hg_hover = Lerp(FrameTime() * 8, self.hg_hover or 0, self:IsHovered() and 1 or 0)

		local hover = self.hg_hover

		//; обводка: радиус 0 (без скругления), толщина 2, зелёный; при наведении только ярче
		hg.DrawRoundedOutline(0, 0, bw, bh, 0, 2, Color(hover_color.r, hover_color.g, hover_color.b, 150 + 105 * hover))

		//; подпись при наведении уходит в зелёный
		surface.SetFont( font_name )
		surface.SetTextColor(Lerp(hover, col.r, hover_color.r), Lerp(hover, col.g, hover_color.g), Lerp(hover, col.b, hover_color.b), col.a)

		local textW, textH = surface.GetTextSize(text)
		surface.SetTextPos(bw / 2 - textW / 2, bh / 2 - textH / 2)
		surface.DrawText(text)
	end

	return btn
end

//\\ Список игроков открывается тумблером: Tab открыл, второй Tab закрыл (а не пока держишь)
local score_lock = false
local score_blur_works = true

function GM:ScoreboardShow()
	if score_lock then
		score_lock = false

		self:ScoreboardHide()

		return
	end

	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
	Dynamic = 0
	score_lock = true
	scoreBoardMenu = vgui.Create("ZFrame")

	local sizeX,sizeY = ScrW() / 1.3 ,ScrH() / 1.2
	local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2

	scoreBoardMenu:SetPos(posX,posY)
	scoreBoardMenu:SetSize(sizeX,sizeY)
	scoreBoardMenu:MakePopup()
	scoreBoardMenu:SetKeyboardInputEnabled( false )
	scoreBoardMenu:ShowCloseButton( false )

	// фон: размытие игры за списком + затемнение сверху
	scoreBoardMenu.Paint = function(self,w,h)
		if not hg.ScoreboardBlur() or not score_blur_works then
			surface.SetDrawColor( 14, 14, 20, 235 )
			surface.DrawRect( 0, 0, w, h )

			return
		end

		score_blur_works = pcall(hg.DrawBlur, self, 5, nil, 150)
	end

	scoreBoardMenu.OnRemove = function()
		score_lock = false
	end

	//; кнопка «Заглушить всех» убрана из Tab — тот же тумблер остался консольной командой
	concommand.Add("hg_muteall", function()
		hg.muteall = not hg.muteall
		
		for i,ply in player.Iterator() do
			if hg.muteall then
				//ply.oldmutedspect = ply:IsMuted()

				ply:SetVoiceVolumeScale(0)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
			else
				ply:SetVoiceVolumeScale((!hg.mutespect or ply:Alive()) and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
				//ply:SetMuted(ply.oldmuted)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
				//ply.oldmuted = nil
			end
		end 

		chat.AddText(Color(0, 255, 0), "[Tab] Звук всех игроков: "..(hg.muteall and "выключен" or "включён"))
	end)

	//; кнопка «Заглушить наблюдателей» убрана — тумблер остался командой
	concommand.Add("hg_mutespect", function()
		hg.mutespect = not hg.mutespect
		
		for i,ply in player.Iterator() do
			if ply:Alive() then continue end

			if hg.mutespect then
				ply:SetVoiceVolumeScale(0)
				//ply.oldmutedspect = ply:IsMuted()

				//ply:SetMuted(true)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
			else
				ply:SetVoiceVolumeScale(!hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
				//ply:SetMuted(ply.oldmutedspect)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
				//ply.oldmutedspect = nil
			end
		end 

		chat.AddText(Color(0, 255, 0), "[Tab] Звук наблюдателей: "..(hg.mutespect and "выключен" or "включён"))
	end)

	//; кнопка «Размытие» убрана — тумблер и так висит на конваре: hg_scoreboard_blur 0/1

	local ServerName = GetHostName() or "EL-City | Dev сервер | #01"
	local tick

	//; подложка размытия светлая, поэтому подписи рисуем с тенью
	local function ShadowText(txt, x, y)
		surface.SetTextColor(0, 0, 0, 200)
		surface.SetTextPos(x + 1, y + 1)
		surface.DrawText(txt)

		surface.SetTextColor(col.r, col.g, col.b, col.a)
		surface.SetTextPos(x, y)
		surface.DrawText(txt)
	end

	scoreBoardMenu.PaintOver = function(self,w,h)
		surface.SetDrawColor( 0, 255, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )

		surface.SetFont( "ZB_InterfaceLarge" )
		local lengthX, lengthY = surface.GetTextSize(ServerName)
		ShadowText(ServerName, w / 2 - lengthX/2,10)

		surface.SetFont( "ZB_InterfaceSmall" )
		surface.SetTextColor(col.r,col.g,col.b,col.a*0.1)
		local txt = "Версия ZC: "..hg.Version
		local lengthX, lengthY = surface.GetTextSize(txt)
		surface.SetTextPos(w*0.01,h - lengthY - h*0.01)
		surface.DrawText(txt)

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		local lengthX, lengthY = surface.GetTextSize("Игроки:")
		ShadowText("Игроки:", w / 4 - lengthX/2, ScreenScale(25))

		local lengthX, lengthY = surface.GetTextSize("Наблюдатели:")
		ShadowText("Наблюдатели:", w * 0.75 - lengthX/2, ScreenScale(25))

		tick = math.Round(1 / engine.ServerFrameTime())
		local lengthX, lengthY = surface.GetTextSize("Тик сервера: " .. tick)
		ShadowText("Тик сервера: " .. tick, w * 0.5 - lengthX/2, ScreenScale(25))
	end
	-- TEAMSELECTION
	if LocalPlayer():Team() ~= TEAM_SPECTATOR then
		MakeTeamButton(scoreBoardMenu, "Спектатор", sizeX * 0.925, sizeY * 0.095, true, true)
	end

	if LocalPlayer():Team() == TEAM_SPECTATOR then
		MakeTeamButton(scoreBoardMenu, "Игрок", sizeX * 0.010, sizeY * 0.095, false, false)
	end

	--без матов

	local DScrollPanel = vgui.Create("DScrollPanel", scoreBoardMenu)
	DScrollPanel:SetPos(10, ScreenScaleH(58))
	DScrollPanel:SetSize(sizeX/2 - 10, sizeY - ScreenScaleH(72))
	function DScrollPanel:Paint( w, h )
		-- BlurBackground(self)

		surface.SetDrawColor(0, 0, 0, 125)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor( 0, 255, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	local disappearance = lply:GetNetVar("disappearance", nil)
	for i, ply in player.Iterator() do -- надо это говно переделать.
		if ply:Team() == TEAM_SPECTATOR then continue end
		if CurrentRound().name == "fear" and !ply:Alive() then continue end
		if disappearance and ply != lply then continue end

		local but = vgui.Create("DButton", DScrollPanel)
		but:SetSize(100, ScreenScaleH(22))
		but:Dock(TOP)
		but:DockMargin(8, 6, 8, -1)
		but:SetText("")
		
		//; иконка звука — глиф FontAwesome вместо png из icon16: состояние читается прямо в Paint
		local soundButton = vgui.Create("DButton", but)
		soundButton:Dock(RIGHT)
		soundButton:SetSize( 30, 0 )
		soundButton:DockMargin(5,10,45,10)
		soundButton:SetText("")

		soundButton.Paint = function(self, w, h)
			if not IsValid(ply) then return end

			//; значок показывает уровень войса этого игрока: заглушен / тихо / обычно
			//; значок показывает уровень войса: заглушен / тихо / обычно
			hg.DrawSoundIcon(ply, w, h, self:IsHovered())
		end
		soundButton.DoClick = function(self)
			OpenPlayerSoundSettings(self, ply) 
		end
		ply.soundButton = soundButton
	
		but.Paint = function(self, w, h)
			if not IsValid(ply) then return end
			local col_up = colBlueUp
			local col_down = colBlue
			surface.SetDrawColor(col_up.r, col_up.g, col_up.b, col_up.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(col_down.r, col_down.g, col_down.b, col_down.a)
			surface.DrawRect(0, h / 2, w, h / 2)
	
			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r, col.g, col.b, col.a)
			local lengthX, lengthY = surface.GetTextSize(ply:Name() or "Вышел...")
			surface.SetTextPos(15, h / 2 - lengthY / 2)
			surface.DrawText(ply:Name() or "Вышел...")
	
			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r, col.g, col.b, col.a)
			local lengthX, lengthY = surface.GetTextSize(ply:Ping() or "Вышел...")
			surface.SetTextPos(w - lengthX - 15, h / 2 - lengthY / 2)
			surface.DrawText(ply:Ping() or "Вышел...")


			//; роль игрока (User / ElPass / Operator / Admin / Head Admin / SuperAdmin) — по центру строки, крупно
			local role, role_col = hg.TabRole(ply)

			if role then
				//; тот же шрифт, что у ника и пинга — мелкий тут просто не читался
				surface.SetFont("ZB_InterfaceMediumLarge")
				local name_w = surface.GetTextSize(ply:Name() or "")
				local role_w, role_h = surface.GetTextSize(role)

				local role_x = w / 2 - role_w / 2

				//; длинный ник — сдвигаем вправо, но не под иконку звука и пинг
				if role_x < 15 + name_w + 8 then
					role_x = 15 + name_w + 8
				end

				if role_x + role_w < w - TAB_RIGHT_RESERVE then
					//; тень, иначе цветной текст теряется на зелёной полосе
					surface.SetTextColor(0, 0, 0, 190)
					surface.SetTextPos(role_x + 1, h / 2 - role_h / 2 + 1)
					surface.DrawText(role)

					surface.SetTextColor(role_col.r, role_col.g, role_col.b, role_col.a)
					surface.SetTextPos(role_x, h / 2 - role_h / 2)
					surface.DrawText(role)
				end
			end
		end

		function but:DoClick()
if ply:IsBot() then chat.AddText(Color(0,255,0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end

		function but:DoRightClick()
			--if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			local Menu = DermaMenu()
			Menu:AddOption( "Аккаунт", function(self)
				zb.Experience.AccountMenu( ply )
			end)
			Menu:AddOption( "Скопировать SteamID", function(self)
				SetClipboardText(ply:SteamID())
			end)

			Menu:Open()
		end
	
		DScrollPanel:AddItem(but)
	end
	-- SPECTATORS
	local DScrollPanel = vgui.Create("DScrollPanel", scoreBoardMenu)
	DScrollPanel:SetPos(sizeX/2 + 5, ScreenScaleH(58))
	DScrollPanel:SetSize(sizeX/2 - 15, sizeY - ScreenScaleH(72))
	function DScrollPanel:Paint( w, h )
		-- BlurBackground(self)

		surface.SetDrawColor(0, 0, 0, 125)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor( 0, 255, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then continue end
		if CurrentRound().name == "fear" and !ply:Alive() then continue end
		if disappearance and ply != lply then continue end

		local but = vgui.Create("DButton", DScrollPanel)
		but:SetSize(100, ScreenScaleH(22))
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")

		//; иконка звука — глиф FontAwesome вместо png из icon16: состояние читается прямо в Paint
		local soundButton = vgui.Create("DButton", but)
		soundButton:Dock(RIGHT)
		soundButton:SetSize( 30, 0 )
		soundButton:DockMargin(5,10,45,10)
		soundButton:SetText("")

		soundButton.Paint = function(self, w, h)
			if not IsValid(ply) then return end

			//; значок показывает уровень войса этого игрока: заглушен / тихо / обычно
			//; значок показывает уровень войса: заглушен / тихо / обычно
			hg.DrawSoundIcon(ply, w, h, self:IsHovered())
		end
		soundButton.DoClick = function(self)
			OpenPlayerSoundSettings(self, ply)
		end
		ply.soundButton = soundButton

		but.Paint = function(self,w,h)
			if not IsValid(ply) then return end
			surface.SetDrawColor(colSpect2.r,colSpect2.g,colSpect2.b,colSpect2.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(colSpect1.r,colSpect1.g,colSpect1.b,colSpect1.a)
			surface.DrawRect(0,h/2,w,h/2)

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:Name() or "Вышел..." )
			surface.SetTextPos(15,h/2 - lengthY/2)
			surface.DrawText(ply:Name() or "Вышел...")

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:Ping() or "Вышел..." )
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(ply:Ping() or "Вышел...")


			//; роль игрока (User / ElPass / Operator / Admin / Head Admin / SuperAdmin) — по центру строки, крупно
			local role, role_col = hg.TabRole(ply)

			if role then
				surface.SetFont( "ZB_InterfaceMediumLarge" )
				local name_w = surface.GetTextSize( ply:Name() or "" )
				local role_w, role_h = surface.GetTextSize( role )

				local role_x = w / 2 - role_w / 2

				if role_x < 15 + name_w + 8 then
					role_x = 15 + name_w + 8
				end

				if role_x + role_w < w - TAB_RIGHT_RESERVE then
					surface.SetTextColor(0, 0, 0, 190)
					surface.SetTextPos(role_x + 1, h/2 - role_h/2 + 1)
					surface.DrawText(role)

					surface.SetTextColor(role_col.r, role_col.g, role_col.b, role_col.a)
					surface.SetTextPos(role_x, h/2 - role_h/2)
					surface.DrawText(role)
				end
			end
		end

		function but:DoClick()
			if ply:IsBot() then chat.AddText("Это бот.") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end

		function but:DoRightClick()
			--if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			local Menu = DermaMenu()
			Menu:AddOption( "Аккаунт", function(self)
				zb.Experience.AccountMenu( ply )
			end)
			Menu:AddOption( "Скопировать SteamID", function(self)
				SetClipboardText(ply:SteamID())
			end)
			--Menu:AddOption( "Medal", function(self) 
			--	zb.Experience.OpenMenu(ply)
			--	timer.Simple( .1, function()
			--		zb.Experience.Menu(ply)
			--	end)
			--end) 

			Menu:Open()
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function GM:ScoreboardHide()
	// открыт тумблером — отпускание Tab его не закрывает
	if score_lock then
		if IsValid(scoreBoardMenu) then return end

		score_lock = false
	end

	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Close()
		scoreBoardMenu = nil
	end
end

-- свет от молнии а саму молнию я не сделал skill issue
if CLIENT then
	net.Receive("PunishLightningEffect", function()
		local target = net.ReadEntity()
		if not IsValid(target) then return end
		local dlight = DynamicLight(target:EntIndex())
		if dlight then
			dlight.pos = target:GetPos()
			dlight.r = 126
			dlight.g = 139
			dlight.b = 212
			dlight.brightness = 1
			dlight.Decay = 1000
			dlight.Size = 500
			dlight.DieTime = CurTime() + 1
		end
	end)
end

/*  -- а кстати зачем здесь нэт, это же можно было на клиенте полностью сделать...
	if CLIENT then
		net.Receive("PluvCommand", function()
			local specialSteamID = "STEAM_0:1:81850653" 
			local playerSteamID = LocalPlayer():SteamID() 

			local imageURLs = {"https://sadsalat.github.io/salatis/music/boof.gif", "https://i.ibb.co/drt1Lks/KtvCLSs.webp", "https://media.tenor.com/kG4PmVvJuRIAAAAC/rain-world-rain-world-saint.gif"} 
			local soundURLs = {"https://sadsalat.github.io/salatis/music/sus-rock.mp3", "https://sadsalat.github.io/salatis/music/tiktok-raaaah-scream.mp3", "https://sadsalat.github.io/salatis/music/sus-rock.mp3"} 

			local chosenImage = imageURLs[math.random(#imageURLs)]
			local chosenSound = soundURLs[math.random(#soundURLs)]

			sound.PlayURL(chosenSound, "", function(station)
				if IsValid(station) then
					station:Play()
				else
					print("Unable to play the sound.")
				end
			end)

			local html = vgui.Create("HTML")
			html:OpenURL(chosenImage)
			html:SetSize(ScrW(), ScrH())
			html:Center()
			html:MakePopup()

			timer.Simple(3, function()
				if IsValid(html) then
					html:Remove()
				end
			end)
		end)
	end
*/

local lightningMaterial = Material("sprites/lgtning")

net.Receive("AnotherLightningEffect", function()
    local target = net.ReadEntity()
	if not IsValid(target) then return end
    local points = {}
    for i = 1, 27 do
        points[i] = target:GetPos() + Vector(0, 0, i * 50) + Vector(math.Rand(-20,20),math.Rand(-20,20),math.Rand(-20,20))
    end
    hook.Add( "PreDrawTranslucentRenderables", "LightningExample", function(isDrawingDepth, isDrawingSkybox)
        if isDrawingDepth or isDrawingSkybox then return end
        local uv = math.Rand(0, 1)
        render.OverrideBlend( true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD )
        render.SetMaterial(lightningMaterial)
        render.StartBeam(27)
        for i = 1, 27 do
            render.AddBeam(points[i], 20, uv * i, Color(255,255,255,255))
        end
        render.EndBeam()
        render.OverrideBlend( false )
    end )
    timer.Simple(0.1, function()
        hook.Remove("PreDrawTranslucentRenderables", "LightningExample")
    end)
end)

function GM:AddHint( name, delay )
	return false
end

local snakeGameOpen = false

concommand.Add("zb_snake", function() -- вот как здесь!
    if snakeGameOpen then
        print("[Snake Game] Игра уже запущена!")
        return
    end

    local frame = vgui.Create("ZFrame")
    frame:SetTitle("Snake Game")
    frame:SetSize(400, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetDeleteOnClose(true)  
    snakeGameOpen = true  

    local gridSize = 20
    local gridWidth = 19  
    local gridHeight = 19  
    local snakePanel = vgui.Create("DPanel", frame)
    snakePanel:SetSize(380, 380)
    snakePanel:SetPos(10, 10)

    
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)

    local snake = {
        {x = 10, y = 10},
    }
	
    local snakeDirection = "RIGHT"
    local food = nil
    local score = 0
    local gameRunning = true

  
    local function spawnFood()
        local validPosition = false
        while not validPosition do
            local newFood = {
                x = math.random(0, gridWidth - 1), 
                y = math.random(0, gridHeight - 1)
            }
            validPosition = true

        
            for _, segment in ipairs(snake) do
                if segment.x == newFood.x and segment.y == newFood.y then
                    validPosition = false  
                    break
                end
            end

            
            if validPosition then
                food = newFood
            end
        end
    end

    
    local function drawSnake()
        surface.SetDrawColor(0, 255, 0, 255)
        for _, segment in ipairs(snake) do
            surface.DrawRect(segment.x * gridSize, segment.y * gridSize, gridSize - 1, gridSize - 1)
        end
    end

  
    local function drawFood()
        if food then
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawRect(food.x * gridSize, food.y * gridSize, gridSize - 1, gridSize - 1)
        end
    end

   
    local function moveSnake()
        if not gameRunning then return end

        local head = table.Copy(snake[1])

        if snakeDirection == "UP" then
            head.y = head.y - 1
        elseif snakeDirection == "DOWN" then
            head.y = head.y + 1
        elseif snakeDirection == "LEFT" then
            head.x = head.x - 1
        elseif snakeDirection == "RIGHT" then
            head.x = head.x + 1
        end

        
        if head.x < 0 or head.x >= gridWidth or head.y < 0 or head.y >= gridHeight then
            gameRunning = false
        end

       
        for _, segment in ipairs(snake) do
            if segment.x == head.x and segment.y == head.y then
                gameRunning = false
            end
        end

       
        table.insert(snake, 1, head)


        if food and head.x == food.x and head.y == food.y then
            score = score + 1
            spawnFood()  
        else
            
            table.remove(snake)
        end
    end


    local function resetGame()
        snake = {{x = 10, y = 10}}
        snakeDirection = "RIGHT"
        score = 0
        gameRunning = true
        spawnFood()  
    end


    function snakePanel:Paint(w, h)
        surface.SetDrawColor(50, 50, 50, 255)
        surface.DrawRect(0, 0, w, h)

        if gameRunning then
            drawSnake()
            drawFood()
        else
            draw.SimpleText("Игра окончена! Нажми R, чтобы начать заново", "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("Счёт: " .. score, "DermaDefault", 10, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end


    function frame:OnKeyCodePressed(key) -- ФУРИ МУВ теперь понятно почему лагает змейка
        if key == KEY_W and snakeDirection ~= "DOWN" then
            snakeDirection = "UP"
        elseif key == KEY_S and snakeDirection ~= "UP" then
            snakeDirection = "DOWN"
        elseif key == KEY_A and snakeDirection ~= "RIGHT" then
            snakeDirection = "LEFT"
        elseif key == KEY_D and snakeDirection ~= "LEFT" then
            snakeDirection = "RIGHT"
        elseif key == KEY_R then
            resetGame()
        end
    end


    timer.Create("SnakeGameTimer", 0.2, 0, function()
        if gameRunning then
            moveSnake()
        end
        snakePanel:InvalidateLayout(true)
    end)


    frame.OnClose = function()
        timer.Remove("SnakeGameTimer")
        snakeGameOpen = false  
        print("[Snake Game] Игра закрыта.") -- НЕ РАБОТАЕТ
    end


    resetGame()
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
	if ply == LocalPlayer() then
		system.FlashWindow()
	end
end)
