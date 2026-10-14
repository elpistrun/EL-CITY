GM.Name = "ZCity"
GM.Author = "uzelezz, sadsalat, Mr. Point, Zac90, Deka, Mannytko"
GM.Email = "N/A"
GM.Website = "N/A"

team.SetUp(0, "Players", Color(255, 0, 0))
team.SetUp(1, "Players2", Color(0, 0, 255))
team.SetUp(2, "Players3", Color(0, 255, 0))

DeriveGamemode("sandbox")

local blur = Material("pp/blurscreen")
local hg_potatopc -- НАДО ЭТО ГОВНО ПЕРЕПИСАТЬ НОРМАЛЬНО, И ВСЕ МЕНЮШКИ ОДИНАКОВЫЕ ТОЖЕ!!!

//\\ Подложка поверх размытия: "r g b a" (по умолчанию тёмное стекло 0,0,0,125), пустая строка — без подложки
//\\ shouldsave = false: у клиента не остаётся старого зашитого значения из cfg
local cv_blur_tint
if CLIENT then
	cv_blur_tint = GetConVar("hg_blur_tint") or CreateClientConVar("hg_blur_tint", "0 0 0 125", false, false, "Цвет подложки размытия: r g b a (пусто — без подложки)")

	//; у тех, кто уже играл со светлой подложкой, значение зашито в cfg — возвращаем дефолт
	if cv_blur_tint:GetString() == "255 255 255 60" then
		cv_blur_tint:SetString("0 0 0 125")
	end
end

local function BlurTintColor(minAlpha)
	if not cv_blur_tint then return end

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

function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	if not IsValid(panel) then return end

	local x, y = panel:LocalToScreen(0, 0)
	local w, h = panel:GetWide(), panel:GetTall()

	// вложенная панель: стекло в своей области уже нарисовал родитель в этом же кадре
	if w <= 0 or h <= 0 or BlurOverdraw(x, y, w, h) then return end

	if(hg_potatopc and hg_potatopc:GetBool())then
		// potato-режим: размытия нет, поэтому подложка должна быть плотной
		surface.SetDrawColor(BlurTintColor(235) or Color(0, 0, 0, 235))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		// blurscreen рисуем БЕЛЫМ: с тёмным цветом выходит затемнение вместо размытия
		surface.SetDrawColor(255, 255, 255, 255)

		for i = 0.34, 1, 0.33 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()
			
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end

		// подложка ложится поверх размытия
		local tint = BlurTintColor()

		if tint then
			surface.SetDrawColor(tint)
			surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		end
	end
end

local function BlockSpawn(ply, ent)
	if game.SinglePlayer() or ply:IsAdmin() then return true end

	return false
end

local spawn = {"PlayerGiveSWEP", "PlayerSpawnEffect", "PlayerSpawnNPC", "PlayerSpawnObject", "PlayerSpawnProp", "PlayerSpawnRagdoll", "PlayerSpawnSENT", "PlayerSpawnSWEP", "PlayerSpawnVehicle"}

for _, v in ipairs(spawn) do
	hook.Add(v, "BlockSpawn", BlockSpawn)
end

hook.Add( "PlayerNoClip", "FeelFreeToTurnItOff", function( ply, desiredState )
	if ( desiredState == false ) then -- the player wants to turn noclip off
		return true -- always allow
	elseif ( ply:IsAdmin() ) then
		return true -- allow administrators to enter noclip
	end

	return false
end )

if CLIENT then
	hook.Add( "PlayerBindPress", "PlayerBindPressExample", function( ply, bind, pressed )
		if ( string.find( bind, "+menu" ) ) then
			--return true
		end
	end )

	hook.Add( "SpawnMenuOpen", "SpawnMenuWhitelist", function()
		local ply = LocalPlayer()
		if ply:IsSuperAdmin() then return end
		if ply:IsAdmin() then return end
		return false
	end )
end

local team_GetAllTeams = team.GetAllTeams

function zb:CheckTeams()
	local tbl = {}
	for i, info in pairs(team_GetAllTeams()) do
		tbl[i] = {}
	end

	for _, ply in player.Iterator() do
		tbl[ply:Team()][#tbl[ply:Team()] + 1] = ply
	end
	return tbl
end

function zb:CheckAliveTeams(incapacitatedcheck)
	local tbl = {}

	for i, info in pairs(team_GetAllTeams()) do
		if i == TEAM_UNASSIGNED or i == TEAM_SPECTATOR then continue end
		tbl[i] = {}
	end

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if incapacitatedcheck and ply.organism and ply.organism.incapacitated then continue end

		tbl[ply:Team() or 0] = tbl[ply:Team() or 0] or {}
		tbl[ply:Team()][(#tbl[ply:Team() or 0] or 0) + 1] = ply
	end

	return tbl
end

function zb:CheckAlive(incapacitatedcheck)
	local tbl = {}
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if incapacitatedcheck and ply.organism and ply.organism.incapacitated then continue end
		tbl[#tbl + 1] = ply
	end
	return tbl
end

function zb:CheckPlaying()
	local tbl = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if not ply:Alive() then continue end
		
		tbl[#tbl + 1] = ply
	end
	return tbl
end

function GM:GrabEarAnimation(ply)
	hg.earanim(ply)
end