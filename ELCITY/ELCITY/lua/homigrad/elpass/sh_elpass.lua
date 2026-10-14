--\\\\ ElPass — теперь это роль, а не магазин: покупок, уровней и склада больше нет
--\ Перки роли (все серверные):
--\  1) улучшенный лут — множитель редкости hg_elpass_loot_mul (по умолчанию 1.5);
--\  2) карма от guilt не ухудшает лут и не вызывает рвоту (см. sv_lootspawn.lua / sv_guilt.lua);
--\  3) бан за низкую карму короче на hg_elpass_ban_reduce минут (по умолчанию 5).
--\ Кто получает перки: игрок в ULX-группе elpass, в любой группе из списка hg_elpass_group
--\ (через запятую) или с SteamID из PASS.SteamIDs ниже. Группу заводит ULX:
--\ 	ulx addgroup elpass
--\ 	ulx adduser <ник> elpass
--\ Список групп уезжает клиентам (нужен для показа роли в Tab), поэтому после правки списка
--\ в игре достаточно выполнить hg_elpass_resend.
hg.ElPass = hg.ElPass or {}

local PASS = hg.ElPass

--\\ Ручная выдача в обход ULX-группы: ["STEAM_0:1:123456"] = true
PASS.SteamIDs = {
	-- ["STEAM_0:1:123456"] = true,
}

if SERVER then
	PASS.GroupConVar = CreateConVar("hg_elpass_group", "elpass", {FCVAR_ARCHIVE}, "ULX-группа(ы) с перками ElPass, через запятую")
	PASS.LootMulConVar = CreateConVar("hg_elpass_loot_mul", "1.5", {FCVAR_ARCHIVE}, "Множитель редкости лута для ElPass")
	PASS.BanCutConVar = CreateConVar("hg_elpass_ban_reduce", "5", {FCVAR_ARCHIVE}, "На сколько минут короче бан за низкую карму у ElPass")
end

local function ConVarFloat(name, default)
	local cv = GetConVar(name)

	return (cv and cv:GetFloat()) or default
end

--\\ Группы пере-парсим только когда строка изменилась: на сервере она из конвара,
--\\ на клиенте — из нет-сообщения (конвар сервер-онли)
local cached_raw, cached_groups = nil, {}

local function RawGroups()
	if PASS.raw_groups then return PASS.raw_groups end

	return (PASS.GroupConVar and PASS.GroupConVar:GetString()) or ""
end

local function GetGroups()
	local raw = RawGroups()

	if cached_raw == raw then return cached_groups end

	cached_raw = raw
	cached_groups = {}

	for _, name in ipairs(string.Explode(",", raw)) do
		name = string.lower(string.Trim(name))

		if name != "" then
			cached_groups[name] = true
		end
	end

	return cached_groups
end

function PASS.IsMember(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end

	if PASS.SteamIDs[ply:SteamID()] then return true end

	local group = string.lower(ply:GetUserGroup() or "")

	--; сама группа elpass работает всегда, даже если список с сервера ещё не дошёл
	if group == "elpass" then return true end

	return GetGroups()[group] or false
end

function PASS.GetLootMul()
	return math.max(1, ConVarFloat("hg_elpass_loot_mul", 1.5))
end

function PASS.GetBanCut()
	return math.max(0, ConVarFloat("hg_elpass_ban_reduce", 5))
end

if SERVER then
	util.AddNetworkString("hg_elpass_groups")

	local function SendGroups(ply)
		net.Start("hg_elpass_groups")
			net.WriteString(PASS.GroupConVar:GetString())
		net.Send(ply)
	end

	hook.Add("PlayerInitialSpawn", "hg_elpass_groups", function(ply)
		timer.Simple(3, function()
			if IsValid(ply) then SendGroups(ply) end
		end)
	end)

	local function FindTarget(arg, caller)
		arg = string.lower(string.Trim(arg or ""))

		if arg == "" then return IsValid(caller) and caller or nil end

		for _, ply in ipairs(player.GetAll()) do
			if string.lower(ply:SteamID()) == arg or string.lower(ply:Name()) == arg then
				return ply
			end
		end
	end

	concommand.Add("hg_elpass_resend", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then return end

		for _, target in ipairs(player.GetAll()) do
			SendGroups(target)
		end

		MsgC(Color(0, 155, 0), "[ElPass] Список групп отправлен клиентам\n")

		if IsValid(ply) then ply:ChatPrint("Список групп ElPass отправлен клиентам") end
	end)

	concommand.Add("hg_elpass_check", function(ply, cmd, args)
		if IsValid(ply) and not ply:IsAdmin() then return end

		local function Say(msg)
			MsgC(Color(0, 155, 0), "[ElPass] ", Color(255, 255, 255), msg .. "\n")

			if IsValid(ply) then ply:ChatPrint(msg) end
		end

		if args[1] then
			local target = FindTarget(args[1], ply)

			if not IsValid(target) then
				Say("Игрок не найден (нужен онлайн-игрок, ник или STEAMID)")
				return
			end

			Say(target:Name().." | "..target:SteamID().." | группа: "..target:GetUserGroup().." | ElPass: "..(PASS.IsMember(target) and "да" or "нет"))
			return
		end

		local list = {}

		for _, target in ipairs(player.GetAll()) do
			if PASS.IsMember(target) then
				list[#list + 1] = target:Name().." ("..target:GetUserGroup()..")"
			end
		end

		Say("ElPass сейчас: "..(#list > 0 and table.concat(list, ", ") or "никого"))
		Say("Группы: "..((PASS.GroupConVar and PASS.GroupConVar:GetString()) or "").." | лут x"..PASS.GetLootMul().." | бан короче на "..PASS.GetBanCut().." мин")
	end)
else
	net.Receive("hg_elpass_groups", function()
		PASS.raw_groups = net.ReadString()
		cached_raw = nil
	end)
end
