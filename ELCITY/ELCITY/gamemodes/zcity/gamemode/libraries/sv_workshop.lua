//\\ Мастерская Steam на сервере: админ вставляет ссылку или ID — сервер начинает раздавать
//\\ этот предмет клиентам (resource.AddWorkshop) и запоминает его в data-файле, чтобы список
//\\ пережил перезапуск.
//\\
//\\ Чего сервер сделать не может: скачать аддон сам. resource.AddWorkshop только заставляет
//\\ КЛИЕНТОВ скачать предмет с Мастерской. Чтобы карта появилась на сервере, её .bsp нужен
//\\ ему заранее — host_workshop_collection в командной строке или steamcmd
//\\ (+workshop_download_item 4000 <id>). Про это команда честно пишет в ответе.

//; файл серверный, но вместе со сборкой он может приехать и на клиент — там он не нужен
//; вовсе, поэтому тихо выходим, а не создаём полусерверные команды на клиенте
if not SERVER then return end

local DATA_FILE = "zbattle/workshop_extra.txt"

local extra = {}

local function LoadList()
	local raw = file.Read(DATA_FILE, "DATA")

	if not raw or raw == "" then return end

	for id in string.gmatch(raw, "%d+") do
		table.insert(extra, id)
	end
end

local function SaveList()
	file.CreateDir("zbattle")
	file.Write(DATA_FILE, table.concat(extra, "\n"))
end

local function FindIndex(id)
	for i, v in ipairs(extra) do
		if v == id then return i end
	end
end

local function FindByText(text)
	for i, v in ipairs(extra) do
		if v == text then return i, v end
	end

	//; разрешаем найти и по ссылке, а не только по голому ID — так удобнее вычищать список
	local parsed = hg.Workshop.ParseID(text)

	if parsed then return FindIndex(parsed), parsed end
end

local function AddID(id)
	if not hg.Workshop.IsID(id) then return false end
	if FindIndex(id) then return false end

	table.insert(extra, id)
	resource.AddWorkshop(id)
	SaveList()

	return true
end

local function RemoveID(id)
	local index = FindIndex(id)

	if not index then return false end

	table.remove(extra, index)
	SaveList()

	return true
end

//; раздаём всё, что админы добавили раньше. resource.AddWorkshop работает и после старта —
//; подключённые клиенты получат список при следующем подключении
LoadList()

for _, id in ipairs(extra) do
	resource.AddWorkshop(id)
end

concommand.Add("hg_workshop_add", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then
		ply:ChatPrint("Нет доступа")

		return
	end

	local text = table.concat(args, " ")
	local id = hg.Workshop.ParseID(text)

	local function Report(msg)
		if IsValid(ply) then ply:ChatPrint(msg) else print("[Z-City] " .. msg) end
	end

	if not id then
		Report("Мастерская: не понял ссылку или ID — " .. tostring(text))

		return
	end

	if hg.Workshop.LooksLikeCollection(text) then
		Report("Мастерская: это похоже на коллекцию, нужен ID отдельного предмета")
	end

	if AddID(id) then
		Report("Мастерская: id " .. id .. " раздаётся клиентам (уже подключённые получат при следующем подключении)")
		Report("Мастерская: если это карта — положи её .bsp серверу (steamcmd/host_workshop_collection), без него карта не запустится")
	else
		Report("Мастерская: id " .. id .. " уже в списке")
	end
end, nil, "Мастерская Steam: раздавать предмет клиентам (ссылка или ID)")

concommand.Add("hg_workshop_remove", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then
		ply:ChatPrint("Нет доступа")

		return
	end

	local text = table.concat(args, " ")
	local index, id = FindByText(text)

	local function Report(msg)
		if IsValid(ply) then ply:ChatPrint(msg) else print("[Z-City] " .. msg) end
	end

	if not index or not id then
		Report("Мастерская: такого id в списке нет")

		return
	end

	RemoveID(id)
	Report("Мастерская: id " .. id .. " больше не раздаётся (Steam уже скачал его клиентам, отменить это сервер не может)")
end, nil, "Мастерская Steam: убрать предмет из раздачи (ссылка или ID)")

concommand.Add("hg_workshop_list_server", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then
		ply:ChatPrint("Нет доступа")

		return
	end

	local function Report(msg)
		if IsValid(ply) then ply:ChatPrint(msg) else print("[Z-City] " .. msg) end
	end

	Report("Мастерская: в раздаче " .. #extra .. " предмет(ов)")

	for i, id in ipairs(extra) do
		Report(string.format("  %d) https://steamcommunity.com/sharedfiles/filedetails/?id=%s", i, id))
	end
end, nil, "Мастерская Steam: что сервер раздаёт клиентам")
