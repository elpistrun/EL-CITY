--; ─────────────────────────────────────────────────────────────────────────────
--; Роль на следующий раунд (AdminPanel) — серверная часть.
--;
--;   zb.SetNextRole(ply, "traitor", admin)      — заявка админа
--;   zb.ConsumeNextRole(ply, "homicide"/"team")  — режим забирает заявку, она сгорает
--;   zb.NextRoleTeam(ply)                        — командные режимы: номер команды или TEAM_SPECTATOR
--;
--; Заявка хранится по SteamID и живёт zb_nextrole_ttl минут (0 = вечно).
--; Список ролей живёт ЗДЕСЬ (сервер — единственный источник правды) и уезжает
--; клиентам по сети, чтобы панель не зависела от загрузки sh_-файлов.
--; Клиент: cl_nextrole.lua, кнопка в F6-панели / консоль zb_admin_roles.
--; ─────────────────────────────────────────────────────────────────────────────

util.AddNetworkString("zb_nextrole_list")	--; сервер -> админ: какие роли бывают
util.AddNetworkString("zb_nextrole_sync")	--; сервер -> админ: список заявок
util.AddNetworkString("zb_nextrole_set")	--; админ -> сервер: поставить / сбросить / запросить список

zb = zb or {}
zb.NextRoles = zb.NextRoles or {}

--; context — какие режимы роль понимает:
--;   "homicide" — hmcd (в том числе тип soe)
--;   "team"     — командные режимы, где спавн раздаёт 0/1/2 через zb:BalancedChoice
--;   "any"      — во всех режимах

zb.NextRoleList = {
	{
		id = "traitor",
		name = "Предатель",
		context = "homicide",
		desc = "Homicide: главный предатель следующего раунда (подроль выбирается сам)",
		color = Color(190, 45, 45),
	},
	{
		id = "innocent",
		name = "Невиновный",
		context = "homicide",
		desc = "Homicide: невиновный — рандом предателей обходит его стороной",
		color = Color(60, 145, 220),
	},
	{
		id = "team0",
		name = "Красные",
		context = "team",
		team = 0,
		desc = "Командные режимы: команда 0 (красные)",
		color = Color(200, 50, 50),
	},
	{
		id = "team1",
		name = "Синие",
		context = "team",
		team = 1,
		desc = "Командные режимы: команда 1 (синие)",
		color = Color(50, 90, 200),
	},
	{
		id = "team2",
		name = "Зелёные",
		context = "team",
		team = 2,
		desc = "Командные режимы: команда 2 (зелёные)",
		color = Color(50, 180, 80),
	},
	{
		id = "spectator",
		name = "Наблюдатель",
		context = "any",
		spectator = true,
		desc = "Следующий раунд игрок смотрит свободной камерой",
		color = Color(160, 160, 160),
	},
}

function zb.NextRoleInfo(id)
	for i, info in ipairs(zb.NextRoleList) do
		if info.id == id then return info end
	end
end

function zb.NextRoleIs(id, context)
	local info = zb.NextRoleInfo(id)
	if not info then return false end
	if context == nil then return true end
	if not info.context or info.context == "any" then return true end

	return info.context == context
end

function zb.NextRoleLabel(id)
	local info = zb.NextRoleInfo(id)

	return info and info.name or (isstring(id) and id or "?")
end

function zb.NextRoleColor(id)
	local info = zb.NextRoleInfo(id)

	return info and info.color or Color(150, 150, 150)
end

--; чем сейчас является раунд: "homicide" или "team"
function zb.NextRoleContext()
	local round = CurrentRound and CurrentRound()
	if not round then return "team" end

	return (round.name == "hmcd" or round.RoleChooseRoundTypes) and "homicide" or "team"
end

local nextrole_ttl = CreateConVar("zb_nextrole_ttl", 30, FCVAR_ARCHIVE, "AdminPanel: сколько минут живёт заявка на роль следующего раунда (0 = пока не сгорит)")

--; админ-проверка мягче обычной: хост listen-сервера тоже должен попадать
local function is_admin(ply)
	if not IsValid(ply) then return false end

	return ply:IsAdmin() or ply:IsSuperAdmin() or ply:IsListenServerHost()
end

local function notify(ply, str)
	if IsValid(ply) then
		if ply.zChatPrint then
			ply:zChatPrint(str)
		else
			ply:ChatPrint(str)
		end
	end

	MsgN("[zb_nextrole] " .. str)
end

--; заявка с проверкой срока жизни
local function role_entry(ply)
	if not IsValid(ply) then return end

	local key = ply:SteamID()
	local entry = zb.NextRoles[key]
	if not entry then return end

	local max_age = nextrole_ttl:GetInt() * 60
	if max_age > 0 and (os.time() - (entry.time or 0)) > max_age then
		zb.NextRoles[key] = nil
		return
	end

	return entry
end

function zb.GetNextRole(ply)
	local entry = role_entry(ply)

	return entry and entry.role or nil
end

function zb.GetNextRoles()
	local list = {}

	for steamid64, entry in pairs(zb.NextRoles) do
		local ply = player.GetBySteamID(steamid64)

		list[#list + 1] = {
			steamid = steamid64,
			name = IsValid(ply) and ply:Nick() or (entry.name or "?"),
			role = entry.role,
			admin = entry.admin or "?",
			time = entry.time or 0,
			online = IsValid(ply),
		}
	end

	table.sort(list, function(a, b) return (a.name or "") < (b.name or "") end)

	return list
end

function zb.SetNextRole(ply, role, admin)
	if not IsValid(ply) then return false end
	if not zb.NextRoleInfo(role) then return false end

	zb.NextRoles[ply:SteamID()] = {
		role = role,
		name = ply:Nick(),
		admin = IsValid(admin) and admin:Nick() or "console",
		time = os.time(),
	}

	return true
end

function zb.ClearNextRole(ply)
	local key = IsValid(ply) and ply:SteamID() or (isstring(ply) and ply or nil)
	if not key or not zb.NextRoles[key] then return false end

	zb.NextRoles[key] = nil

	return true
end

--; режим забирает заявку: чужая роль (например "traitor" в командном раунде) остаётся ждать своего
function zb.ConsumeNextRole(ply, context)
	local entry = role_entry(ply)
	if not entry then return end
	if not zb.NextRoleIs(entry.role, context) then return end

	zb.ClearNextRole(ply)

	return entry.role
end

--; командные режимы: заявка -> номер команды (или TEAM_SPECTATOR)
function zb.NextRoleTeam(ply)
	local role = zb.ConsumeNextRole(ply, "team")
	if not role then return end

	local info = zb.NextRoleInfo(role)
	if not info then return end

	if info.spectator then return TEAM_SPECTATOR end

	return info.team
end

local function send_nextrole_list(ply)
	net.Start("zb_nextrole_list")
	net.WriteString(zb.NextRoleContext())
	net.WriteUInt(math.min(#zb.NextRoleList, 255), 8)

	for i, info in ipairs(zb.NextRoleList) do
		local col = info.color or Color(150, 150, 150)

		net.WriteString(info.id)
		net.WriteString(info.name)
		net.WriteString(info.context or "any")
		net.WriteUInt(col.r, 8)
		net.WriteUInt(col.g, 8)
		net.WriteUInt(col.b, 8)
	end

	net.Send(ply)
end

local function send_nextroles(ply)
	net.Start("zb_nextrole_sync")

	local list = zb.GetNextRoles()
	net.WriteUInt(math.min(#list, 255), 8)

	for i, entry in ipairs(list) do
		net.WriteString(entry.steamid or "")
		net.WriteString(entry.name or "")
		net.WriteString(entry.role or "")
		net.WriteString(entry.admin or "")
	end

	net.Send(ply)
end

function zb.SyncNextRoles(target)
	for i, ply in player.Iterator() do
		if not is_admin(ply) then continue end
		if IsValid(target) and target != ply then continue end

		send_nextrole_list(ply)
		send_nextroles(ply)
	end
end

local function find_target(ply, str)
	if not str or str == "" or str == "me" then return ply end

	local by_steam = player.GetBySteamID(str)
	if IsValid(by_steam) then return by_steam end

	local id = tonumber((str:gsub("#", "")))
	if id then
		local by_id = player.GetByID(id)
		if IsValid(by_id) then return by_id end
	end

	local lower = string.lower(str)
	for i, target in player.Iterator() do
		if string.find(string.lower(target:Nick()), lower, 1, true) then return target end
	end
end

net.Receive("zb_nextrole_set", function(len, ply)
	if not is_admin(ply) then return end

	local action = net.ReadString()
	local steamid64 = net.ReadString()
	local role = net.ReadString()

	if action == "req" then
		zb.SyncNextRoles(ply)
		return
	end

	local target = (steamid64 == "" and ply) or player.GetBySteamID(steamid64)

	if not IsValid(target) then
		notify(ply, "Игрок не в игре.")
		return
	end

	if action == "clear" then
		if zb.ClearNextRole(target) then
			notify(ply, "Заявка снята: " .. target:Nick())
		end
	elseif action == "set" then
		if zb.SetNextRole(target, role, ply) then
			notify(ply, "Следующий раунд" .. ((target == ply) and " (ты)" or " (" .. target:Nick() .. ")") .. ": " .. zb.NextRoleLabel(role))
		end
	end

	zb.SyncNextRoles()
end)

concommand.Add("hg_nextrole", function(ply, cmd, args)
	if IsValid(ply) and not is_admin(ply) then return end

	local role = args[1]
	local info = zb.NextRoleInfo(role)

	if not info then
		local ids = {}
		for i, v in ipairs(zb.NextRoleList) do ids[#ids + 1] = v.id end

		notify(ply, "Использование: hg_nextrole <" .. table.concat(ids, "|") .. "> [ник|#id] (без цели — себе)")
		return
	end

	local target = find_target(ply, args[2])

	if not IsValid(target) then
		notify(ply, "Игрок не найден.")
		return
	end

	if zb.SetNextRole(target, role, ply) then
		notify(ply, (target == ply and "Ты" or target:Nick()) .. ": следующий раунд — " .. info.name)
	end

	zb.SyncNextRoles()
end)

concommand.Add("hg_nextrole_clear", function(ply, cmd, args)
	if IsValid(ply) and not is_admin(ply) then return end

	local target = find_target(ply, args[1])

	if not IsValid(target) then
		notify(ply, "Игрок не найден.")
		return
	end

	if zb.ClearNextRole(target) then
		notify(ply, "Заявка снята: " .. target:Nick())
	end

	zb.SyncNextRoles()
end)

concommand.Add("hg_nextrole_list", function(ply)
	if IsValid(ply) and not is_admin(ply) then return end

	for i, entry in ipairs(zb.GetNextRoles()) do
		notify(ply, entry.name .. " (" .. entry.steamid .. ") -> " .. zb.NextRoleLabel(entry.role) .. " [поставил " .. entry.admin .. "]")
	end
end)

hook.Add("PlayerInitialSpawn", "zb_nextrole_sync", function(ply)
	if not is_admin(ply) then return end

	timer.Simple(3, function()
		if IsValid(ply) then zb.SyncNextRoles(ply) end
	end)
end)
