--\\ El-Anti-Cheat — детект клиентских чит-lua (серверная часть).
--\\
--\\ Сервер не имеет доступа к диску клиента, поэтому проверка двухступенчатая:
--\\   1) клиенту шлётся запрос: случайный токен + таблица сигнатур;
--\\   2) клиент ищет совпадения в своём garrysmod/lua и garrysmod/data
--\\      (имя файла, размер файла, подстроки содержимого, рантайм-маркеры);
--\\   3) клиент шлёт отчёт, сервер считает вес, и при весе >= порога
--\\      банит навсегда с причиной "Cheats | El-Anti-Cheat".
--\\
--\\ Сигнатуры живут ТОЛЬКО на сервере: в запрос уходит лишь то, что нужно
--\\ для поиска, чтобы чит не мог их прочитать из файлов аддона.
--\\ Отчёт формально подделывается (чит перехватит net.Receive), поэтому это
--\\ дешёвый детектор массовых сборок, а не защита. Жёстко блокировать
--\\ клиентские lua может только sv_allowcslua 0.
--\\
--\\ Маркеры взяты из garrysmod/detlua: SilkWare, Nasvai, kernell,
--\\ client.lua(BZKdia/mayrr), Z4XRvw, brokencore script/amfetomine.

if not SERVER then return end

zb = zb or {}
zb.AntiCheat = zb.AntiCheat or {}

local BRAND = "[El-Anti-Cheat]"
local BAN_REASON = "Cheats | El-Anti-Cheat"
local LOG_FILE = "elanticheat.txt"

local cvar_enable    = CreateConVar("zb_anticheat", "1", FCVAR_ARCHIVE, "El-Anti-Cheat: детект клиентских lua (0/1)", 0, 1)
local cvar_threshold = CreateConVar("zb_anticheat_threshold", "5", FCVAR_ARCHIVE, "El-Anti-Cheat: суммарный вес для бана", 1, 1000)
local cvar_join      = CreateConVar("zb_anticheat_join", "30", FCVAR_ARCHIVE, "El-Anti-Cheat: скан через N секунд после входа", 0, 600)
local cvar_rescan    = CreateConVar("zb_anticheat_rescan", "300", FCVAR_ARCHIVE, "El-Anti-Cheat: интервал повторного скана", 5, 86400)
local cvar_log       = CreateConVar("zb_anticheat_log", "1", FCVAR_ARCHIVE, "El-Anti-Cheat: писать отчёты в garrysmod/data/" .. LOG_FILE, 0, 1)
local cvar_dryrun    = CreateConVar("zb_anticheat_dryrun", "0", FCVAR_ARCHIVE, "El-Anti-Cheat: 1 = только лог, без бана (для теста)", 0, 1)
local cvar_admins    = CreateConVar("zb_anticheat_admins", "0", FCVAR_ARCHIVE, "El-Anti-Cheat: 1 = не банить админов", 0, 1)
local cvar_webhook   = CreateConVar("zb_anticheat_webhook", "https://discord.com/api/webhooks/1552248996028878858/A-OGH-eawWs1w0nB8y-WVhH-CXVcqsMbR8VeuyQIjnNN54BUjysrr3LxvemY-YiukExX", FCVAR_ARCHIVE, "El-Anti-Cheat: Discord-вебхук для уведомлений, пустая строка = выключено")
local cvar_shot       = CreateConVar("zb_anticheat_shot", "1", FCVAR_ARCHIVE, "El-Anti-Cheat: слать скриншот экрана при находке (0/1)", 0, 1)
local cvar_shot_time  = CreateConVar("zb_anticheat_shot_timeout", "4", FCVAR_ARCHIVE, "El-Anti-Cheat: сколько секунд ждать скриншот перед баном", 1, 30)
local cvar_mention    = CreateConVar("zb_anticheat_mention", "", FCVAR_ARCHIVE, "El-Anti-Cheat: упоминание при детекте (<@&ID> роль, <@ID> юзер, @here), пусто = без упоминания")

--// Сигнатуры маркеров:
--//   names       - подстрока имени файла (нижний регистр), бан по одному совпадению
--//   sizes       - размер файла в байтах, только триггер на чтение содержимого
--//   needles     - подстроки внутри файла, чтение подтверждает сигнатуру
--//   globals     - глобальные переменные в луа-состоянии клиента
--//   convars     - клиентские конвары
--//   concommands - консольные команды чита
--//   hookids     - пары {событие, id}: сверяем именно id чита, НЕ факт события
--//                 (событие вроде radialOptions добавляет наш геймод — дало ложный бан)
--//   wrappers    - перехванные ванильные функции (читы глушат скриншоты)
--//   weight      - сколько добавить в общий вес; бан при весе >= zb_anticheat_threshold
local SIGNATURES = {
	{ label = "SilkWare",              weight = 6, names = { "silkw" },   sizes = { 122173 }, needles = { "SilkWare", "SW_ESP_Tiny" },                    globals = { "SilkWare" } },
	{ label = "Nasvai",                weight = 6, names = { "nasvai" },  sizes = { 58788 },
	  needles = { "NasvaiCfg", "NasvaiSmall", "Nasvai_AntiScreengrab" },
	  globals = { "NasvaiCfg" }, hookids = { { "RenderScene", "Nasvai_AntiScreengrab" } } },
	{ label = "kernell.lua",           weight = 6, names = { "kernell" }, sizes = { 13819 },  needles = { "_G_AUTH", "_K = {C = {SA" } },
	--// client.lua = Kefir/mayrr (kefir.vip): точный размер + текстовые маркеры меню и логов
	{ label = "client.lua (Kefir)",    weight = 6, sizes = { 471286 },
	  needles = { "BZKdia", "kefir.vip", "kefir.rip", "Kefir:GetLangText", "Kefir:ConMsg", "kefir_red",
		"anti_fullsg", "Screengrabed", "zxcmodule", "mayrr module is not loaded",
		"Will be screengrabbed!", "runtimeApi", "FAQ_INDEX" },
	  globals = { "mayrr", "zxcmodule" } },
	{ label = "Z4XRvw",                weight = 6, names = { "z4xrvw" },  sizes = { 472286 }, needles = { "1789447431" },                                    globals = { "JJnavIQMhVdQscNZKkxLbAdxAqSu3uvM" } },
	--// brokencore.club script (Gamesense/Femboware): анти-скриншот gs_AntiScreenshot,
	--// ключи конфига, файлы gamesense_*/femboware_*, хуки Gamesense_*/zzz_radial_gs_color
	{ label = "brokencore script",     weight = 6, sizes = { 204123 }, names = { "gamesense", "femboware" },
	  needles = {
		-- анти-скриншот и перехватчики net/render
		"gs_AntiScreenshot", "misc_antiscreenshot", "GimmeThatScreen", "__screenshot_internal",
		-- хуки и ключи конфига
		"Gamesense_", "zzz_radial_gs_color", "radial_select_color", "radial_base_color",
		"rage_fovcircle_color", "esp_activation_style", "chams_player_material",
		"misc_lock_menu_layout", "custom_photo_enable", "misc_blockbot_style",
		"esp_line_of_sight_color", "effects_bullet_tracers_color", "wep_obves_enable",
		"rage_remove_recoil", "misc_thirdperson_bind", "other_dropped_weapons_color",
		"misc_safe_function", "misc_aspect_ratio_value",
		-- файлы, которые чит пишет на диск
		"gamesense_config.txt", "gamesense_friends.txt", "femboware_bg.jpg", "[Femboware]",
	  },
	  hookids = {
		{ "radialOptions", "zzz_radial_gs_color" }, { "Think", "Gamesense_RadialHide" },
		{ "Think", "Gamesense_UI" }, { "Think", "Gamesense_GTS" },
		{ "StartCommand", "Gamesense_AA" }, { "InitPostEntity", "gs_bullet_traj" },
		{ "HG_SupressorOverride", "gs_obves" }, { "PostHGCalcView", "Gamesense_AspectRatio" },
		{ "PostEntityFireBullets", "Gamesense" }, { "Think", "Gamesense_WeaponCustomize" },
		{ "Think", "Gamesense_LagFake" }, { "Think", "Femboware_PhotoPanel" },
		{ "SetupWorldFog", "Gamesense" }, { "Think", "Gamesense_FastZoom" },
	  } },
	{ label = "brokencore amfetomine", weight = 6, sizes = { 110954 }, needles = { "el_patron", "amfetamin_friends.txt", "amfetamin_loading" } },
	{ label = "kratos menu",           weight = 5, concommands = { "kratos_menu" } },
	{ label = "gs_fastloot",           weight = 5, convars = { "gs_fastloot" } },
	--// перехват ванильных функций (анти-screengrab: render.Capture, net.*, file.*).
	--// Вес 3 < порога: сам по себе не банит — только добавляет улики к остальным
	--// маркерам, чтобы чужой аддон не мог перевесить через одну обёртку
	{ label = "перехват функций (анти-screengrab)", weight = 3,
	  wrappers = { "render.Capture", "game.TakeScreenshot", "RunConsoleCommand",
		"net.Receive", "net.Start", "file.Read", "file.Write" } },
}

local CH_ASK = "ElAC_Ask"
local CH_REPORT = "ElAC_Rep"

util.AddNetworkString(CH_ASK)
util.AddNetworkString(CH_REPORT)

--// скриншот экрана игрока: запрос клиенту и возврат кусками
local CH_SHOT_ASK = "ElAC_ShotAsk"
local CH_SHOT = "ElAC_Shot"

util.AddNetworkString(CH_SHOT_ASK)
util.AddNetworkString(CH_SHOT)

local pending = {}   -- ply -> token последнего запроса
local lastscan = {}  -- steamid -> CurTime последнего скана
local reports = {}   -- последние отчёты для команды zb_ac_report

zb.AntiCheat.SIGNATURES = SIGNATURES

local function Log(text)
	if not cvar_log:GetBool() then return end
	file.Append(LOG_FILE, os.date("[%Y-%m-%d %H:%M:%S] ") .. text .. "\n")
end

local function NotifyAdmins(text)
	Msg(BRAND .. " " .. text .. "\n")

	for _, admin in ipairs(player.GetAll()) do
		if IsValid(admin) and admin:IsAdmin() then
			admin:ChatPrint(BRAND .. " " .. text)
		end
	end
end

local function PushReport(text)
	reports[#reports + 1] = text
	if #reports > 100 then table.remove(reports, 1) end
end

--// Без allowed_mentions Discord не поднимает упоминание в пинг
local function BuildPayload(text)
	return util.TableToJSON({
		content = text,
		allowed_mentions = { parse = { "everyone", "roles", "users" } },
	})
end

--// Discord: простая строка + файл со скриншотом.
--// http.Post умеет только x-www-form-urlencoded, а вложение требует
--// multipart/form-data, поэтому для скриншота берём низкоуровневый HTTP.
local function SendDiscord(text, shotData, shotTried)
	local url = cvar_webhook:GetString()
	if not url or url == "" then return end

	local function onFail()
		--// если вложение не прошло (лимит, ошибка HTTP) — шлём хотя бы текст
		if shotData and not shotTried then
			SendDiscord(text, nil, true)
		end
	end

	if not shotData or #shotData == 0 then
		http.Post(url, { payload_json = BuildPayload(text) },
			function(body, size, headers, code)
				if isnumber(code) and code >= 400 then
					Msg(BRAND .. " webhook HTTP " .. tostring(code) .. ": " .. string.sub(body or "", 1, 200) .. "\n")
					onFail()
				end
			end,
			function(err)
				Msg(BRAND .. " webhook ошибка: " .. tostring(err) .. "\n")
			end
		)
		return
	end

	local boundary = "----ElAntiCheat" .. math.random(100000, 999999)
	local body = table.concat({
		"--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"payload_json\"\r\n\r\n" .. BuildPayload(text) .. "\r\n",
		"--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"elac_screenshot.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n" .. shotData .. "\r\n",
		"--" .. boundary .. "--\r\n",
	})

	HTTP({
		url = url,
		method = "POST",
		headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundary },
		body = body,
		success = function(code, resp)
			if isnumber(code) and code >= 400 then
				Msg(BRAND .. " webhook HTTP " .. tostring(code) .. ": " .. string.sub(resp or "", 1, 200) .. "\n")
				onFail()
			end
		end,
		failed = function(reason)
			Msg(BRAND .. " webhook ошибка: " .. tostring(reason) .. "\n")
			onFail()
		end,
	})
end

--// Скриншот: просим клиент снять экран в PostRender и вернуть кусками.
--// Возвращаем результат ровно один раз: либо по таймауту, либо по готовности.
local shotPend = {}

local function RequestScreenshot(ply, cb)
	if not IsValid(ply) or not cvar_shot:GetBool() then cb(nil) return end

	local uid = ply:UserID()
	local session = math.random(1, 65535)

	shotPend[uid] = { session = session, chunks = {}, got = 0, total = 0, cb = cb, ply = ply }

	net.Start(CH_SHOT_ASK)
		net.WriteUInt(session, 16)
	net.Send(ply)

	timer.Create("ElAC_Shot_" .. uid, cvar_shot_time:GetFloat(), 1, function()
		local pend = shotPend[uid]
		if not pend then return end

		shotPend[uid] = nil

		local data
		if pend.total > 0 and pend.got >= pend.total then
			data = table.concat(pend.chunks)
		end

		pend.cb(data)
	end)
end

net.Receive(CH_SHOT, function(len, ply)
	if not IsValid(ply) then return end

	local uid = ply:UserID()
	local pend = shotPend[uid]
	if not pend then return end

	local session = net.ReadUInt(16)
	if session ~= pend.session then return end

	local idx = net.ReadUInt(16)
	local total = net.ReadUInt(16)
	local size = net.ReadUInt(32)

	if total < 1 or total > 400 or idx < 1 or idx > total or size > 65536 then return end

	pend.total = total
	pend.chunks[idx] = net.ReadData(size)
	pend.got = pend.got + 1

	if pend.got >= total then
		timer.Remove("ElAC_Shot_" .. uid)
		shotPend[uid] = nil
		pend.cb(table.concat(pend.chunks))
	end
end)

--// Список того, что клиент должен искать у себя (без меток и весов).
local function BuildQuery()
	local q = {}

	for i, sig in ipairs(SIGNATURES) do
		q[i] = {
			n  = sig.names,
			z  = sig.sizes,
			c  = sig.needles,
			g  = sig.globals,
			v  = sig.convars,
			cc = sig.concommands,
			hi = sig.hookids,
			w  = sig.wrappers,
		}
	end

	return q
end

local QUERY = BuildQuery()

local function BanPlayer(ply, steamid, name)
	steamid = steamid or (IsValid(ply) and ply:SteamID())
	name = name or (IsValid(ply) and ply:Name())
	if not steamid then return end

	if ULib and ULib.addBan then
		-- 0 минут = перманентный бан, сам же кикает игрока
		ULib.addBan(steamid, 0, BAN_REASON, name or steamid, "El-Anti-Cheat")
	elseif IsValid(ply) and ply.Ban then
		ply:Ban(0, true)
	else
		game.KickID(steamid, BAN_REASON)
	end

	Msg(BRAND .. " " .. (name or steamid) .. " (" .. steamid .. ") забанен навсегда.\n")
end

function zb.AntiCheat.Scan(ply, reason)
	if not IsValid(ply) or ply:IsBot() then return false end
	if not cvar_enable:GetBool() then return false end

	local token = math.random(1, 2147483647)

	pending[ply] = token
	lastscan[ply:SteamID()] = CurTime()

	net.Start(CH_ASK)
		net.WriteUInt(token, 32)
		net.WriteTable(QUERY)
	net.Send(ply)

	return true
end

local function HandleReport(ply, data, reason)
	local files   = istable(data.files) and data.files or {}
	local runtime = istable(data.runtime) and data.runtime or {}
	local info    = istable(data.info) and data.info or {}

	local score, hits, labels, seen = 0, {}, {}, {}
	local markers, markerSeen = {}, {}
	local paths, pathSeen = {}, {}

	--// маркеры (что именно сработало) собираем все, а вес даём один раз за сигнатуру
	for _, list in ipairs({ files, runtime }) do
		for _, hit in ipairs(list) do
			local idx = istable(hit) and hit.i
			local sig = idx and SIGNATURES[idx]

			if sig then
				local marker = tostring(hit.m or hit.d or "")
				local where = isstring(hit.d) and hit.d or ""

				if marker ~= "" and not markerSeen[marker] then
					markerSeen[marker] = true
					markers[#markers + 1] = marker
				end

				if (hit.k == "file" or hit.k == "content") and where ~= "" and not pathSeen[where] then
					pathSeen[where] = true
					paths[#paths + 1] = where
				end

				hits[#hits + 1] = sig.label .. " [" .. tostring(hit.k or "?") .. "] " .. marker
					.. (where ~= "" and where ~= marker and (" -> " .. where) or "")

				if not seen[idx] then
					seen[idx] = true
					score = score + (sig.weight or 1)
					labels[#labels + 1] = sig.label
				end
			end
		end
	end

	local line = string.format(
		"%s (%s) вес=%d [%s] деталей:%d файлов:%s чтений:%s",
		ply:Name(), ply:SteamID(), score, reason or "-",
		#hits, tostring(info.total or 0), tostring(info.reads or 0)
	)

	if #hits > 0 then line = line .. " || " .. table.concat(hits, " ; ") end

	if score <= 0 then return end

	PushReport(line)

	if (info.total or 0) == 0 and score < cvar_threshold:GetInt() then
		--// клиент ничего не вернул: скорее всего не смог прочитать файлы
		NotifyAdmins("клиент не отдал список lua файлов (проверь скан вручную: zb_ac_scan " .. ply:Nick() .. ")")
	end

	--// решение о бане
	local shouldBan = score >= cvar_threshold:GetInt()

	if shouldBan and cvar_dryrun:GetBool() then
		shouldBan = false
		NotifyAdmins(line .. " || DRYRUN: бан пропущен")
	elseif shouldBan and cvar_admins:GetBool() and ply:IsAdmin() then
		shouldBan = false
		NotifyAdmins(line .. " || админ пропущен (zb_anticheat_admins 1)")
	elseif shouldBan then
		NotifyAdmins(line .. " || БАН НАВСЕГДА: " .. BAN_REASON)
	else
		Log(line .. " | ниже порога, бан не выдан")
	end

	--// упоминание + предупреждение + строка детекта
	--// в кавычках конкретный маркер (подстрока/хук/конвара), а не имя группы
	local mention = cvar_mention:GetString()
	local markerText = #markers > 0 and table.concat(markers, ", ") or table.concat(labels, ", ")

	local text = (mention ~= "" and (mention .. " ") or "")
		.. "⚠️ Следите за игроком, требуется проверка!\n"
		.. string.format('detected a hack to marker : "%s" | %s | %s',
			markerText, ply:Name(), ply:SteamID()
		)

	if #labels > 0 then
		text = text .. "\nсигнатура: " .. table.concat(labels, ", ")

		if #paths > 0 then
			local p = paths[1]
			if #paths > 1 then p = p .. " (и ещё " .. (#paths - 1) .. ")" end
			text = text .. " | файл: " .. p
		end
	end

	local steamid, name = ply:SteamID(), ply:Name()

	local function finish(shot)
		SendDiscord(text, shot)
		if shouldBan then BanPlayer(ply, steamid, name) end
	end

	--// скриншот снимаем при весе выше порога (в т.ч. в DRYRUN — иначе при
	--// тесте его не увидеть); бан ждёт его до таймаута
	if score >= cvar_threshold:GetInt() and cvar_shot:GetBool() then
		RequestScreenshot(ply, finish)
	else
		finish(nil)
	end
end

net.Receive(CH_REPORT, function(len, ply)
	if not IsValid(ply) then return end

	local token = net.ReadUInt(32)
	local data = net.ReadTable()

	--// отчёт принимается только по свежему токену, остальное игнорируем
	if pending[ply] ~= token then return end
	if not istable(data) then return end

	pending[ply] = nil
	HandleReport(ply, data, "auto")
end)

--// первый скан через N секунд после захода, потом периодический
hook.Add("PlayerInitialSpawn", "ElAC_Join", function(ply)
	local delay = cvar_join:GetInt()

	if delay <= 0 then
		zb.AntiCheat.Scan(ply, "join")
		return
	end

	timer.Simple(delay, function()
		if IsValid(ply) then zb.AntiCheat.Scan(ply, "join") end
	end)
end)

timer.Create("ElAC_Think", 15, 0, function()
	if not cvar_enable:GetBool() then return end

	local now = CurTime()
	local target, oldest

	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and not ply:IsBot() and not pending[ply] then
			local t = lastscan[ply:SteamID()] or 0

			if (now - t) > cvar_rescan:GetInt() and (oldest == nil or t < oldest) then
				target, oldest = ply, t
			end
		end
	end

	if target then zb.AntiCheat.Scan(target, "rescan") end
end)

local function FindPlayer(arg)
	if not arg or arg == "" then return end

	local byid = string.match(arg, "#(%d+)")
	if byid then return player.GetByID(tonumber(byid)) end

	local needle = string.lower(arg)
	for _, ply in ipairs(player.GetAll()) do
		if string.find(string.lower(ply:Nick()), needle, 1, true) then return ply end
	end
end

--// zb_ac_scan <ник|#id|*> — принудительный скан
--; скан заставляет КАЖДОГО клиента обходить garrysmod/lua и читать файлы,
--; поэтому команда под кулдауном: без него её можно было запустить в цикле и положить сервер
local scan_cooldown = CreateConVar("zb_anticheat_scancd", 30, FCVAR_ARCHIVE, "zb_ac_scan: кулдаун между принудительными сканами, сек")
local last_scan = 0

concommand.Add("zb_ac_scan", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end

	if last_scan > CurTime() then
		NotifyAdmins("zb_ac_scan: кулдаун, осталось " .. math.ceil(last_scan - CurTime()) .. " сек")
		return
	end

	last_scan = CurTime() + scan_cooldown:GetInt()

	local arg = args[1]
	if not arg or arg == "" or arg == "*" then
		local count = 0

		for _, target in ipairs(player.GetAll()) do
			if zb.AntiCheat.Scan(target, "manual") then count = count + 1 end
		end

		NotifyAdmins("принудительный скан запущен для " .. count .. " игроков")
		return
	end

	local target = FindPlayer(arg)

	if not IsValid(target) then
		NotifyAdmins("игрок не найден: " .. tostring(arg))
		return
	end

	zb.AntiCheat.Scan(target, "manual")
	NotifyAdmins("скан запущен: " .. target:Nick())
end)

--// zb_ac_report — последние находки
concommand.Add("zb_ac_report", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end

	if #reports == 0 then
		Msg(BRAND .. " отчётов пока нет\n")
		return
	end

	for i = math.max(1, #reports - 9), #reports do
		Msg(reports[i] .. "\n")
	end
end)

--// zb_ac_signatures — что сейчас загружено из detlua
concommand.Add("zb_ac_signatures", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end

	for i, sig in ipairs(SIGNATURES) do
		Msg(string.format("%d. %s | вес %d | имен:%d размеров:%d маркер:%d рантайм:%d\n",
			i, sig.label, sig.weight,
			(sig.names and #sig.names or 0),
			(sig.sizes and #sig.sizes or 0),
			(sig.needles and #sig.needles or 0),
			((sig.globals and #sig.globals or 0) + (sig.convars and #sig.convars or 0)
				+ (sig.concommands and #sig.concommands or 0) + (sig.hooks and #sig.hooks or 0))
		))
	end
end)

--// zb_ac_webhook_test — проверить, что вебхук живой
concommand.Add("zb_ac_webhook_test", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if cvar_webhook:GetString() == "" then
		Msg(BRAND .. " вебхук не задан (zb_anticheat_webhook)\n")
		return
	end

	SendDiscord("Тест El-Anti-Cheat | " .. GetHostName() .. " | " .. game.GetMap(), nil)

	Msg(BRAND .. " тестовое сообщение отправлено в вебхук\n")
end)

Msg(BRAND .. " загружен. Сигнатур: " .. #SIGNATURES .. ", причина бана: " .. BAN_REASON .. "\n")
