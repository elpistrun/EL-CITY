//\\ Мастерская Steam на клиенте: вставляешь ссылку или ID предмета — он скачивается и сразу
//\\ подключается как контент (модели, материалы, карты) для этого клиента.
//\\
//\\ Качает Steam своими силами (steamworks.DownloadUGC), мы только монтируем готовый .gma
//\\ через game.MountGMA — поэтому выходить из игры и перезапускать её не нужно.
//\\
//\\ Про карты честно: клиент скачает карту только себе. Чтобы играть на ней на этом сервере,
//\\ её .bsp должен быть у сервера (host_workshop_collection / steamcmd), а раздать её
//\\ подключённым клиентам можно командой админа hg_workshop_add — см. sv_workshop.lua

hg = hg or {}
hg.Workshop = hg.Workshop or {}

local HISTORY_FILE = "zcity_workshop.txt"

hg.Workshop.history = hg.Workshop.history or {}
hg.Workshop.info = hg.Workshop.info or {}
hg.Workshop.busy = hg.Workshop.busy or {}

local CLR_GOOD = Color(0, 255, 0)
local CLR_BAD = Color(255, 70, 70)
local CLR_WARN = Color(255, 200, 60)

//\\\\ Строки в чат в стиле сборки + дубль в консоль, чтобы можно было копировать трейсы
local function Say(text, color)
	color = color or CLR_GOOD

	chat.AddText(CLR_GOOD, "[Мастерская] ", color, text)
	MsgN("[Z-City] [Мастерская] " .. text)
end

//\\\\ Сколько весит предмет — в мегабайтах, как в магазине
local function SizeText(bytes)
	if not isnumber(bytes) then return "размер неизвестен" end

	return string.format("%.1f МБ", bytes / 1024 / 1024)
end

//\\\\ История скачанного: чтобы можно было подключить заново, не качая повторно
function hg.Workshop.LoadHistory()
	local raw = file.Read(HISTORY_FILE, "DATA")
	local tbl = raw and util.JSONToTable(raw)

	if istable(tbl) then
		hg.Workshop.history = tbl
	end
end

function hg.Workshop.SaveHistory()
	file.Write(HISTORY_FILE, util.TableToJSON(hg.Workshop.history or {}, true))
end

function hg.Workshop.Remember(id, title, path)
	local list = hg.Workshop.history

	for i = #list, 1, -1 do
		if list[i].id == id then table.remove(list, i) end
	end

	table.insert(list, 1, {id = id, title = title or id, path = path})

	hg.Workshop.SaveHistory()
end

function hg.Workshop.Forget(id)
	local list = hg.Workshop.history

	for i = #list, 1, -1 do
		if list[i].id == id then table.remove(list, i) end
	end

	hg.Workshop.SaveHistory()
end

//\\\\ Монтируем скачанный .gma: после этого контент доступен здесь и сейчас
function hg.Workshop.Mount(path)
	if not isstring(path) or path == "" then return false end

	//; game.MountGMA есть и на клиенте, но на старых сборках может ругаться — оборачиваем
	local ok, err = pcall(game.MountGMA, path)

	if not ok then
		Say("не удалось подключить " .. path .. ": " .. tostring(err), CLR_BAD)

		return false
	end

	return true
end

//\\\\ Название и вес предмета — просто чтобы игрок видел, что скачивает
function hg.Workshop.Resolve(id, callback)
	if not steamworks then return end

	id = tostring(id)

	steamworks.FileInfo(id, function(data)
		if not data then return end

		hg.Workshop.info[id] = data

		Say(string.format("«%s» — %s", tostring(data.title or id), SizeText(data.size)), CLR_WARN)

		if callback then callback(data) end

		if IsValid(hg.Workshop.frame) then hg.Workshop.frame:Status() end
	end)
end

//\\\\ Главное действие: скачать и подключить
function hg.Workshop.Fetch(id)
	id = tostring(id)

	if not steamworks then
		Say("steamworks недоступен — скачивание работает только на живом клиенте", CLR_BAD)

		return
	end

	if hg.Workshop.busy[id] then
		Say("«" .. id .. "» уже качается", CLR_WARN)

		return
	end

	hg.Workshop.busy[id] = true

	Say("качаю id " .. id .. "…", CLR_WARN)

	if IsValid(hg.Workshop.frame) then hg.Workshop.frame:Status() end

	//; Steam отдаёт готовый .gma; прогресс в байтах он не сообщает, поэтому состояние
	//; показываем текстом, а размер — из FileInfo выше
	steamworks.DownloadUGC(id, function(path, fileobj)
		hg.Workshop.busy[id] = nil

		if not path then
			Say("скачать id " .. id .. " не вышло: предмет закрыт, удалён или Steam недоступен", CLR_BAD)

			if IsValid(hg.Workshop.frame) then hg.Workshop.frame:Status() end

			return
		end

		hg.Workshop.Mount(path)

		local info = hg.Workshop.info[id]
		local title = info and info.title or id

		hg.Workshop.Remember(id, title, path)

		Say("«" .. tostring(title) .. "» подключено как контент", CLR_GOOD)
		Say("если это карта — серверу нужен её .bsp, иначе играть на ней здесь не получится", CLR_WARN)

		if IsValid(hg.Workshop.frame) then hg.Workshop.frame:Refresh() end

		hook.Run("ZB_WorkshopDownloaded", id, path, title)
	end)
end

//\\\\ Ссылка или ID -> скачивание. Коллекции предупреждаем отдельно: у них нужен ID предмета
function hg.Workshop.Start(text)
	local id = hg.Workshop.ParseID(text)

	if not id then
		Say("не понял ссылку или ID: " .. tostring(text), CLR_BAD)

		return
	end

	if hg.Workshop.LooksLikeCollection(text) then
		Say("это похоже на коллекцию — открой её в Steam и вставь ID отдельного предмета", CLR_WARN)
	end

	hg.Workshop.Resolve(id)
	hg.Workshop.Fetch(id)
end

//\\\\ Окно: вставить ссылку, посмотреть, что качается, и что уже подключено
local function MakeButton(parent, text, width, height, onclick)
	local btn = vgui.Create("DButton", parent)

	btn:SetText("")
	btn:SetSize(width, height)
	btn.hg_hover = 0

	btn.DoClick = onclick

	btn.Paint = function(self, w, h)
		self.hg_hover = Lerp(FrameTime() * 8, self.hg_hover or 0, self:IsHovered() and 1 or 0)

		local hover = self.hg_hover

		//; та же зелёная обводка и подсветка подписи, что у кнопок в Tab
		hg.DrawRoundedOutline(0, 0, w, h, 0, 2, Color(0, 255, 0, 150 + 105 * hover))

		surface.SetFont("ZB_InterfaceMedium")

		local tw, th = surface.GetTextSize(text)

		surface.SetTextColor(Lerp(hover, 255, 0), Lerp(hover, 255, 255), Lerp(hover, 255, 0), 255)
		surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
		surface.DrawText(text)
	end

	return btn
end

local function BuildMenu()
	if IsValid(hg.Workshop.frame) then return hg.Workshop.frame end

	local frame = vgui.Create("ZFrame")

	hg.Workshop.frame = frame

	frame:SetSize(math.Clamp(ScrW() * 0.34, 520, 780), math.Clamp(ScrH() * 0.52, 340, 600))
	frame:Center()
	frame:SetTitle("")
	frame:MakePopup()
	frame:SetSizable(false)
	frame:SetKeyboardInputEnabled(true)

	local pad = ScreenScale(8)

	local header = vgui.Create("DLabel", frame)

	header:Dock(TOP)
	header:DockMargin(pad, pad, pad, 0)
	header:SetTall(ScreenScaleH(22))
	header:SetFont("ZB_InterfaceLarge")
	header:SetTextColor(CLR_GOOD)
	header:SetText("Мастерская Steam")

	local hint = vgui.Create("DLabel", frame)

	hint:Dock(TOP)
	hint:DockMargin(pad, 0, pad, 0)
	hint:SetTall(ScreenScaleH(20))
	hint:SetFont("ZB_InterfaceSmall")
	hint:SetTextColor(Color(200, 200, 200))
	hint:SetText("Вставь ссылку или ID предмета — он скачается и подключится как контент")

	//; строка ввода и кнопка «Скачать»
	local row = vgui.Create("DPanel", frame)

	row:Dock(TOP)
	row:DockMargin(pad, ScreenScaleH(6), pad, 0)
	row:SetTall(ScreenScaleH(26))
	row.Paint = function() end

	local entry = vgui.Create("DTextEntry", row)

	entry:Dock(FILL)
	entry:DockMargin(0, 0, ScreenScale(6), 0)
	entry:SetFont("ZB_InterfaceMedium")

	if entry.SetPlaceholderText then
		entry:SetPlaceholderText("https://steamcommunity.com/sharedfiles/filedetails/?id=…")
	end

	local paste = function()
		local text = entry:GetText()

		if text == "" then return end

		hg.Workshop.Start(text)
	end

	local download = MakeButton(row, "Скачать", ScreenScale(70), ScreenScaleH(26), paste)

	download:Dock(RIGHT)

	entry.OnEnter = paste

	//; строка состояния: что качаем, что подключено
	local status = vgui.Create("DLabel", frame)

	status:Dock(TOP)
	status:DockMargin(pad, ScreenScaleH(4), pad, 0)
	status:SetTall(ScreenScaleH(20))
	status:SetFont("ZB_InterfaceSmall")
	frame.status = status

	frame.Status = function(self, text, color)
		local lines = {}

		for id, _ in pairs(hg.Workshop.busy) do
			table.insert(lines, "качается: " .. id)
		end

		if text then
			table.insert(lines, text)
		end

		self.status:SetTextColor(color or Color(170, 170, 170))
		self.status:SetText(#lines > 0 and table.concat(lines, "  ·  ") or "")
	end

	//; список того, что уже скачано — можно подключить заново или забыть
	local list = vgui.Create("DScrollPanel", frame)

	list:Dock(FILL)
	list:DockMargin(pad, ScreenScaleH(8), pad, ScreenScaleH(8))

	frame.list = list

	frame.Refresh = function(self)
		self.list:Clear()
		self:Status()

		for _, item in ipairs(hg.Workshop.history) do
			local but = vgui.Create("DButton", self.list)

			but:SetText("")
			but:SetTall(ScreenScaleH(22))
			but:Dock(TOP)
			but:DockMargin(0, 0, 0, ScreenScaleH(4))

			but.Paint = function(panel, w, h)
				//; зелёная полоса под строкой, как у строк в списке игроков
				surface.SetDrawColor(panel:IsHovered() and 30 or 20, panel:IsHovered() and 160 or 130, 20, 255)
				surface.DrawRect(0, 0, w, h)

				surface.SetFont("ZB_InterfaceMediumLarge")

				local info = hg.Workshop.info[item.id]

				local title = info and info.title or item.title or item.id

				local _, title_h = surface.GetTextSize(title)

				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(10, h / 2 - title_h / 2)
				surface.DrawText(title)

				surface.SetFont("ZB_InterfaceSmall")

				local right = item.id .. (hg.Workshop.busy[item.id] and "  (качается)" or "")

				local right_w, right_h = surface.GetTextSize(right)

				surface.SetTextColor(180, 180, 180, 255)
				surface.SetTextPos(w - right_w - 10, h / 2 - right_h / 2)
				surface.DrawText(right)
			end

			but.DoClick = function()
				if item.path and hg.Workshop.Mount(item.path) then
					Say("подключил заново: " .. tostring(item.title or item.id), CLR_GOOD)
				else
					hg.Workshop.Fetch(item.id)
				end
			end

			but.DoRightClick = function()
				local menu = DermaMenu()

				menu:AddOption("Открыть в Steam", function()
					if steamworks then steamworks.ViewFile(item.id) end
				end)

				menu:AddOption("Скопировать ID", function()
					SetClipboardText(item.id)
				end)

				menu:AddOption("Подключить заново", function()
					if item.path then hg.Workshop.Mount(item.path) end
				end)

				menu:AddOption("Скачать заново", function()
					hg.Workshop.Fetch(item.id)
				end)

				menu:AddOption("Убрать из списка", function()
					hg.Workshop.Forget(item.id)

					if IsValid(hg.Workshop.frame) then hg.Workshop.frame:Refresh() end
				end)

				menu:Open()
			end
		end
	end

	local close = MakeButton(frame, "Закрыть", ScreenScale(80), ScreenScaleH(22), function()
		frame:Close()
	end)

	close:Dock(BOTTOM)
	close:DockMargin(pad, 0, pad, pad)

	frame.OnClose = function()
		hg.Workshop.frame = nil
	end

	frame:Refresh()
	frame:Status()

	entry:RequestFocus()

	return frame
end

hg.Workshop.Open = BuildMenu

//\\\\ Консоль: hg_workshop — окно, hg_workshop <ссылка|ID> — скачать сразу
concommand.Add("hg_workshop", function(ply, cmd, args)
	local text = table.concat(args, " ")

	if string.Trim(text) == "" then
		BuildMenu()

		return
	end

	hg.Workshop.Start(text)
end, nil, "Мастерская Steam: скачать предмет по ссылке или ID (без аргумента — открыть окно)")

concommand.Add("hg_workshop_list", function()
	Say("подключено предметов: " .. #hg.Workshop.history, CLR_WARN)

	for _, item in ipairs(hg.Workshop.history) do
		MsgN(string.format("[Z-City] %s — %s", item.id, tostring(item.title or "без названия")))
	end
end, nil, "Мастерская Steam: что уже скачано и подключено")

hg.Workshop.LoadHistory()
