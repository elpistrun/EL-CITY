--\\; Русский язык для аддона ZCITY / Surrender (воркшоп 3702088753).
--\\;
--\\; Почему перевод отдельным файлом, а не правкой самого аддона: его клиентская
--\\; половина лежит в воркшоп-предмете, то есть у игрока она своя, и GMod не
--\\; перезаписывает то, что уже есть. Поэтому русский навешивается поверх — на
--\\; те места, через которые проходят английские надписи:
--\\;   * чат аддона — глобальный chat.AddText;
--\\;   * подписи радиального меню — хук radialOptions (имя сортируется после
--\\;     hg_surrender_option) и hg.CreateRadialMenu для подменю;
--\\;   * настройки Options > Z-City > Surrender — DForm и заголовок вкладки.
if not CLIENT then return end

local DICT = {
	-- чат аддона
	["You raise your hands."]                    = "Вы поднимаете руки.",
	["You lower your hands."]                    = "Вы опускаете руки.",
	["You kneel down."]                          = "Вы встаёте на колени.",
	["You stand back up, hands still raised."]   = "Вы встаёте, руки всё ещё подняты.",
	["You stand back up."]                       = "Вы встаёте.",
	["You put your hands behind your head."]     = "Вы заводите руки за голову.",
	["You raise your hands back up."]            = "Вы снова поднимаете руки.",
	["You lower your hands to reach for your weapon."] = "Вы опускаете руки, чтобы взяться за оружие.",
	["Your hands are empty again."]              = "Руки снова пусты.",

	-- радиальное меню
	["Surrender"]                       = "Сдаться",
	["RMB - Kneel+Surrender"]           = "ПКМ — встать на колени и сдаться",
	["RMB - Options"]                   = "ПКМ — действия",
	["Getting Up..."]                   = "Встаю…",
	["..."]                             = "…",
	["Surrendering"]                    = "Сдаюсь",
	["Surrendering (Hands Behind Head)"] = "Сдаюсь (руки за головой)",
	["Kneeling + Hands Up"]             = "На коленях: руки вверх",
	["Kneeling + Hands Behind Head"]    = "На коленях: руки за головой",
	["Stand Up"]                        = "Встать",
	["Stop Surrendering"]               = "Перестать сдаваться",
	["Kneel Down"]                      = "Встать на колени",
	["Hands Up (normal)"]               = "Руки вверх (обычно)",
	["Hands Behind Head"]               = "Руки за голову",

	-- настройки
	["Chat messages"]                   = "Сообщения в чат",
	["Scared voice line"]               = "Испуганная реплика",
	["Prints what your character is doing and how long the hold has left."] = "Пишет в чат, что делает персонаж, и сколько осталось удержания.",
	["Plays a panicked line when you raise your hands."]                    = "Проигрывает паническую реплику, когда вы поднимаете руки.",
	["Minimum hold time is set by the server through surrender_min_time."]  = "Минимальное время удержания задаётся сервером (surrender_min_time).",
}

-- заголовок вкладки в меню спавна: одно слово, но по смыслу это «Сдача», а не «Сдаться»
local TAB = {
	["Surrender"] = "Сдача",
}

-- надписи, внутрь которых подставляются числа
local DYNAMIC = {
	{ "You cannot lower your hands yet %((%d+)%)%.", "Руки пока не опустить: ещё %1 с." },
	{ "You are still holding a weapon %- your hands come down in (%d+)s%.", "В руках всё ещё оружие — руки опустятся через %1 с." },
	{ "Hold for (%d+)s", "Удерживать %1 с" },
}

local function Dynamic(text)
	for _, rule in ipairs(DYNAMIC) do
		local new = string.gsub(text, rule[1], rule[2])
		if new ~= text then return new end
	end
end

local function Translate(text)
	if not isstring(text) or text == "" then return end

	if DICT[text] then return DICT[text] end

	-- заголовки вида "Сдаюсь\nУдерживать 3 с" собираются из строк, поэтому
	-- переводим построчно
	if string.find(text, "\n", 1, true) then
		local lines = string.Explode("\n", text)
		local changed = false

		for i, line in ipairs(lines) do
			local new = DICT[line] or Dynamic(line)
			if new then
				lines[i] = new
				changed = true
			end
		end

		if changed then return table.concat(lines, "\n") end
	end

	return Dynamic(text)
end

--; чат аддона пишется через chat.AddText(color, msg) — переводим строки,
--; цвета и всё остальное оставляем как было
if isfunction(chat.AddText) then
	local oldAddText = chat.AddText

	chat.AddText = function(...)
		local args = { ... }
		local changed = false

		for i, v in ipairs(args) do
			local new = Translate(v)
			if new then
				args[i] = new
				changed = true
			end
		end

		if changed then return oldAddText(unpack(args)) end

		return oldAddText(...)
	end
end

--; подписи радиалки рисуются через draw.DrawText — самая надёжная точка:
--; не зависит ни от порядка хуков, ни от того, кто и когда пересобирает опции
if isfunction(draw.DrawText) then
	local oldDrawText = draw.DrawText

	draw.DrawText = function(text, ...)
		return oldDrawText(Translate(text) or text, ...)
	end
end

--; опции радиалки: таблицы вида { функция, "надпись" }, у мультикнопок надписи
--; лежат в option[4]
local function TranslateOptions(options)
	if not istable(options) then return end

	for _, option in ipairs(options) do
		if istable(option) then
			local new = Translate(option[2])
			if new then option[2] = new end

			if istable(option[4]) then
				for i, sub in ipairs(option[4]) do
					local subNew = Translate(istable(sub) and sub[2] or sub)
					if subNew then
						if istable(sub) then
							sub[2] = subNew
						else
							option[4][i] = subNew
						end
					end
				end
			end
		end
	end
end

--; hook.GetTable()["radialOptions"] в cl_hud.lua обходится через SortedPairs,
--; то есть по имени хука: "zz_..." отработает после "hg_surrender_option"
hook.Add("radialOptions", "zz_surrender_ru", function()
	TranslateOptions(hg.radialOptions)
end)

--; подменю (правый клик по опции) строится в обход хуков, поэтому ловим его
--; на входе в hg.CreateRadialMenu
local function WrapRadialMenu()
	if not isfunction(hg.CreateRadialMenu) then return false end

	local oldCreate = hg.CreateRadialMenu

	hg.CreateRadialMenu = function(options, ...)
		TranslateOptions(options)

		return oldCreate(options, ...)
	end

	return true
end

if not WrapRadialMenu() then
	hook.Add("InitPostEntity", "zz_surrender_ru_wrap", WrapRadialMenu)
end

--; настройки: Options > Z-City > Surrender
if isfunction(spawnmenu.AddToolMenuOption) then
	local oldAddOption = spawnmenu.AddToolMenuOption

	spawnmenu.AddToolMenuOption = function(type_, folder, id, label, ...)
		return oldAddOption(type_, folder, id, TAB[label] or label, ...)
	end
end

local form = vgui.GetControlTable and vgui.GetControlTable("DForm")
if form then
	for _, name in ipairs({ "CheckBox", "ControlHelp", "Help" }) do
		local old = form[name]

		if isfunction(old) then
			form[name] = function(self, text, ...)
				return old(self, Translate(text) or text, ...)
			end
		end
	end
end
