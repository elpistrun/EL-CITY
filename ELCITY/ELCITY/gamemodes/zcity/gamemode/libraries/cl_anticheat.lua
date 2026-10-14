--\\ El-Anti-Cheat — клиентская часть.
--\\ Сервер присылает запрос (токен + сигнатуры), мы ищем совпадения у себя
--\\ в garrysmod/lua и garrysmod/data и отвечаем отчётом:
--\\   файлы  - имя файла / подстроки в содержимом;
--\\   runtime - глобалы, конвары, консольные команды, хуки уже загруженного чита.
--\\ Сканирование разбито на тики (timer), чтобы не подвесить клиент.

if not CLIENT then return end

local CH_ASK = "ElAC_Ask"
local CH_REPORT = "ElAC_Rep"

local CH_SHOT_ASK = "ElAC_ShotAsk"
local CH_SHOT = "ElAC_Shot"

local MAX_FILES = 8000   -- сколько файлов вообще перебираем
local MAX_READS = 600    -- сколько файлов читаем целиком
local MAX_BYTES = 16 * 1024 * 1024  -- общий бюджет чтения за один скан
local MAX_HITS  = 100    -- сколько совпадений отдаём
local MAX_READ_FILE = 1024 * 1024  -- файлы больше этого не читаем

local STATE = nil

local function SendReport(token, data)
	net.Start(CH_REPORT)
		net.WriteUInt(token, 32)
		net.WriteTable(data)
	net.SendToServer()
end

--// рекурсивный сбор файлов (file.Find не умеет ** надёжно)
local function Collect(root, dir, out, depth)
	local files, folders = file.Find(dir .. "*", root)
	if not files then return end

	for _, f in ipairs(files) do
		if #out >= MAX_FILES then return end
		out[#out + 1] = { root = root, path = dir .. f }
	end

	if depth <= 0 or not folders then return end

	for _, d in ipairs(folders) do
		if #out >= MAX_FILES then return end
		Collect(root, dir .. d .. "/", out, depth - 1)
	end
end

--// файл лежит в типичном для чита месте: garrysmod/lua/*.lua, autorun/
--// или руково распакованный addons/<название>/lua/...
local function IsTypicalDir(entry)
	if entry.root == "LUA" then
		if not string.find(entry.path, "/", 1, true) then return true end
		return string.find(entry.path, "autorun/", 1, true) == 1
	end

	if entry.root == "GAME" then
		return string.find(entry.path, "/lua/", 1, true) ~= nil
	end

	return false
end

--// "render.Capture" -> функция по пути
local function ResolvePath(path)
	local cur = _G

	for part in string.gmatch(path, "[^%.]+") do
		if not istable(cur) then return nil end
		cur = cur[part]
		if cur == nil then return nil end
	end

	return cur
end

local function RuntimeHits(sig)
	local hits = {}

	local okHooks, hooksTbl = pcall(hook.GetTable)
	if not okHooks then hooksTbl = nil end

	local okCC, ccTbl = pcall(concommand.GetTable)
	if not okCC then ccTbl = nil end

	for i, s in ipairs(sig) do
		for _, g in ipairs(s.g or {}) do
			local ok, val = pcall(rawget, _G, g)
			if ok and val ~= nil then hits[#hits + 1] = { i = i, k = "global", d = g } end
		end

		for _, v in ipairs(s.v or {}) do
			local ok, exists = pcall(ConVarExists, v)
			if ok and exists then hits[#hits + 1] = { i = i, k = "convar", d = v } end
		end

		for _, cc in ipairs(s.cc or {}) do
			if ccTbl and ccTbl[cc] then hits[#hits + 1] = { i = i, k = "concommand", d = cc } end
		end

		--// пары {событие, id}: сверяем именно id чита, а не факт события —
		--// событие вроде radialOptions добавляет наш геймод (давало ложный бан)
		for _, pair in ipairs(s.hi or {}) do
			local ev = istable(hooksTbl) and hooksTbl[pair[1]]

			if istable(ev) and ev[pair[2]] ~= nil then
				hits[#hits + 1] = { i = i, k = "hookid", d = pair[1] .. " :: " .. pair[2], m = pair[2] }
			end
		end

		--// перехват ванильных функций (анти-screengrab): у чита render.Capture/net.*
		--// превращены в луа-обёртку с чужим источником вместо C или includes/
		for _, w in ipairs(s.w or {}) do
			local f = ResolvePath(w)

			if isfunction(f) then
				local ok, info = pcall(debug.getinfo, f, "S")

				if ok and istable(info) and info.what ~= "C" then
					local src = info.short_src or ""

					if not string.find(src, "includes/", 1, true) then
						hits[#hits + 1] = { i = i, k = "wrapper", d = w, m = w .. " перехвачена" }
					end
				end
			end
		end
	end

	return hits
end

--// m — конкретный маркер (подстрока/имя файла/название хука), d — где найдено
local function AddHit(state, i, kind, detail, marker)
	if #state.hits >= MAX_HITS then return end
	state.hits[#state.hits + 1] = { i = i, k = kind, d = detail, m = marker }
end

local function ProcessFile(state, entry)
	--// file.Size может вернуть nil или ошибиться на недоступных путях — глушим
	local okSize, size = pcall(file.Size, entry.path, entry.root)
	if not okSize or not isnumber(size) or size <= 0 then return end

	local name = string.lower(string.GetFileFromFilename(entry.path) or "")

	for i, s in ipairs(state.sig) do
		local nameHit, namePat = false, nil

		for _, pat in ipairs(s.n or {}) do
			if string.find(name, pat, 1, true) then
				nameHit = true
				namePat = pat
				break
			end
		end

		if nameHit then
			AddHit(state, i, "file", entry.path, namePat)
		end

		--// размер только подсказывает, что файл стоит прочитать
		local sizeHit = false
		for _, z in ipairs(s.z or {}) do
			if math.abs(size - z) <= 1024 then
				sizeHit = true
				break
			end
		end

		local wantRead = nameHit or sizeHit
		if not wantRead and IsTypicalDir(entry) and size <= MAX_READ_FILE then
			wantRead = true
		end

		if wantRead and state.reads < MAX_READS and state.bytes < MAX_BYTES and size <= MAX_READ_FILE then
			local ok, content = pcall(file.Read, entry.path, entry.root)

			if ok and isstring(content) and #content > 0 then
				state.reads = state.reads + 1
				state.bytes = state.bytes + #content

				for _, nd in ipairs(s.c or {}) do
					if string.find(content, nd, 1, true) then
						AddHit(state, i, "content", entry.path, nd)
						break
					end
				end
			end
		end

		if #state.hits >= MAX_HITS then return end
	end
end

local function Finish(state)
	SendReport(state.token, {
		files = state.hits,
		runtime = RuntimeHits(state.sig),
		info = { total = #state.files, reads = state.reads, bytes = state.bytes },
	})

	STATE = nil
end

net.Receive(CH_ASK, function()
	local token = net.ReadUInt(32)
	local sig = net.ReadTable()
	if not istable(sig) then return end

	local files = {}
	Collect("LUA", "", files, 6)
	Collect("DATA", "", files, 3)
	Collect("GAME", "addons/", files, 6)

	local state = { token = token, sig = sig, files = files, i = 0, reads = 0, bytes = 0, hits = {} }
	STATE = state

	local timerName = "ElAC_Scan"
	timer.Remove(timerName)

	timer.Create(timerName, 0.05, 0, function()
		local st = STATE
		if not st then
			timer.Remove(timerName)
			return
		end

		--// 60 файлов за тик, 0.05 сек между тиками
		for _ = 1, 60 do
			st.i = st.i + 1

			local entry = st.files[st.i]
			if not entry then
				Finish(st)
				timer.Remove(timerName)
				return
			end

			ProcessFile(st, entry)
		end
	end)
end)

--\\ Скриншот: сервер просит — снимаем экран в PostRender (вне рендера
--\\ буфер очищен и вышел бы чёрный кадр), кроем на куски и шлём обратно.
local SHOT_CHUNK = 30000
local shotSession = nil

net.Receive(CH_SHOT_ASK, function()
	shotSession = net.ReadUInt(16)
end)

hook.Add("PostRender", "ElAC_Shot", function()
	local session = shotSession
	if not session then return end
	shotSession = nil

	local ok, data = pcall(render.Capture, {
		format = "jpg",
		quality = 0.3,
		x = 0,
		y = 0,
		w = ScrW(),
		h = ScrH(),
	})

	--\\ nil возвращается при открытом escape-меню — тогда отдаём пустоту,
	--\\ сервер завершит скриншот сразу, не дожидаясь таймаута
	if not ok or not isstring(data) or #data == 0 then data = "" end

	local total = math.max(1, math.ceil(#data / SHOT_CHUNK))
	local offset = 0

	for i = 1, total do
		local chunk = string.sub(data, offset + 1, offset + SHOT_CHUNK)
		offset = offset + SHOT_CHUNK

		net.Start(CH_SHOT)
			net.WriteUInt(session, 16)
			net.WriteUInt(i, 16)
			net.WriteUInt(total, 16)
			net.WriteUInt(#chunk, 32)
			net.WriteData(chunk, #chunk)
		net.SendToServer()
	end
end)
