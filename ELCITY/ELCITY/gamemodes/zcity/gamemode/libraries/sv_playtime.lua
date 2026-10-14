//\\ Время игры на сервере: сколько каждый игрок уже наиграл (клиент показывает его в Tab).
//\\ Считаем по сессиям: при входе запоминаем момент, раз в минуту отдаём разницу в таблицу
//\\ и сохраняем в data/zcity_playtime.json (steamid64 -> секунды). Отдельный файл, а не
//\\ таблица zb_experience в MySQL: учёт идёт с этого момента и ничего в базе не меняет
if not SERVER then return end

zb = zb or {}

//; steamid64 -> всего секунд на сервере
zb.Playtime = zb.Playtime or {}

local FILE = "zcity_playtime.json"
local FLUSH_TIME = 60

//; ply -> {started = unix-время последней записи}
local sessions = {}

util.AddNetworkString("zb_playtime")

local function LoadStore()
	local raw = file.Read(FILE, "DATA")

	if not raw or raw == "" then return end

	local tbl = util.JSONToTable(raw)

	if not istable(tbl) then return end

	for sid, secs in pairs(tbl) do
		zb.Playtime[sid] = tonumber(secs) or 0
	end
end

local function SaveStore()
	file.Write(FILE, util.TableToJSON(zb.Playtime, true))
end

//; ключ, под которым копим время: у ботов и у игроков без SteamID записи нет
local function SessionKey(ply)
	if not IsValid(ply) or ply:IsBot() then return end

	local sid = ply:SteamID64()

	if not sid or sid == "" then return end

	return sid
end

//; снимок для клиента: сохранённое время плюс то, что игрок уже насидел в текущей сессии
//; (в саму копилку это не пишется — иначе она росла бы на каждой синхронизации)
local function Snapshot()
	local snap = {}

	for sid, secs in pairs(zb.Playtime) do
		snap[sid] = secs
	end

	local now = os.time()

	for ply, sess in pairs(sessions) do
		local sid = SessionKey(ply)

		if sid then
			snap[sid] = (snap[sid] or 0) + math.max(0, now - (sess.started or now))
		end
	end

	return snap
end

//\ Таблицу шлём строкой, а не net.WriteTable: он приводит значения к типу по содержимому,
//\ и ключ-steamid64 (строка из цифр) приезжает на клиент уже числом — поиск по нему мажет.
//\ В своём формате «steamid=секунды;…» типы не теряются: sid всегда строка, секs всегда число
local function Encode(snap)
	local parts = {}

	for sid, secs in pairs(snap) do
		parts[#parts + 1] = sid.."="..math.floor(secs)
	end

	return table.concat(parts, ";")
end

//\\ строка уходит целиком: записей столько же, сколько игроков заходило, это пара килобайт
local function Sync(target)
	net.Start("zb_playtime")
		net.WriteString(Encode(Snapshot()))

	if target then
		net.Send(target)
	else
		net.Broadcast()
	end
end

//; добавляет в копилку время с прошлой записи; save — писать ли сразу на диск
//; возвращает true, если что-то реально добавилось
local function Flush(ply, save)
	local sid = SessionKey(ply)
	local sess = sessions[ply]

	if not sid or not sess then return end

	local now = os.time()
	local delta = now - (sess.started or now)

	sess.started = now

	if delta <= 0 then return end

	zb.Playtime[sid] = (zb.Playtime[sid] or 0) + delta

	if save then SaveStore() end

	return true
end

LoadStore()

hook.Add("PlayerInitialSpawn", "zb_playtime_join", function(ply)
	local sid = SessionKey(ply)

	if not sid then return end

	//; запись заводим сразу, чтобы в Tab у него была цифра с первой секунды («0.0h» у нового)
	zb.Playtime[sid] = zb.Playtime[sid] or 0

	sessions[ply] = {started = os.time()}

	Sync()

	//; в момент первого спавна клиент ещё догружается — дублируем чуть позже
	timer.Simple(3, function()
		if IsValid(ply) then Sync() end
	end)
end)

hook.Add("PlayerDisconnected", "zb_playtime_leave", function(ply)
	if sessions[ply] then
		Flush(ply, true)
		sessions[ply] = nil
	end

	timer.Simple(1, function() Sync() end)
end)

timer.Create("zb_playtime_flush", FLUSH_TIME, 0, function()
	local changed = false

	for ply in pairs(sessions) do
		if IsValid(ply) then
			if Flush(ply, false) then changed = true end
		else
			//; игрок вышел, а Flush на выходе не отработал (например, был кикнут с ошибкой)
			sessions[ply] = nil
		end
	end

	if changed then
		SaveStore()
		Sync()
	end
end)

hook.Add("ShutDown", "zb_playtime_save", function()
	for ply in pairs(sessions) do
		if IsValid(ply) then Flush(ply, false) end
	end

	SaveStore()
end)
