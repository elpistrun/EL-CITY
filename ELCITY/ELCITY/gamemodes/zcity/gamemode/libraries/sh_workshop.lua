//\\ Мастерская Steam: общая часть для клиента и сервера — разбор того, что игрок вставил.
//\\ Клиентская половина (скачивание и окно) — в libraries/cl_workshop.lua,
//\\ серверная (раздача контента клиентам) — в libraries/sv_workshop.lua

hg = hg or {}
hg.Workshop = hg.Workshop or {}

//\\\\ ID предмета Мастерской можно вставить в любом виде — разбираем все ходовые варианты:
//\\\\   https://steamcommunity.com/sharedfiles/filedetails/?id=3657285193
//\\\\   https://steamcommunity.com/workshop/filedetails/?id=3657285193&searchtext=map
//\\\\   steam://url/CommunityFilePage/3657285193
//\\\\   3657285193
//\\\\ Возвращаем только сам номер, иначе nil (например, если прислали ссылку на коллекцию
//\\\\ без номера предмета или просто текст)
function hg.Workshop.ParseID(text)
	if not isstring(text) then return end

	text = string.Trim(text)

	if text == "" then return end

	//; голый номер. ID предметов Мастерской — от 8 цифр, но берём с запасом от 6,
	//; чтобы случайное короткое число из текста не улетело в Steam вместо ID
	local id = string.match(text, "^(%d%d%d%d%d%d+)$")

	//; любой адрес с ?id=… или &id=… — сюда попадают и sharedfiles, и workshop, и коллекции
	id = id or string.match(text, "[%?&]id=(%d+)")

	//; steam://url/CommunityFilePage/…
	id = id or string.match(text, "CommunityFilePage/(%d+)")

	//; на всякий случай — последнее число в строке (ссылки вида .../3657285193)
	id = id or string.match(text, "(%d%d%d%d%d%d%d+)%s*$")

	return id
end

function hg.Workshop.IsID(id)
	return isstring(id) and string.match(id, "^%d%d%d%d%d%d+$") ~= nil
end

//\\\\ «id_предмета» — это то, что принимает steamworks; отдельная проверка на коллекцию:
//\\\\ коллекции тоже отдают номер, но обычные функции скачивания их не понимают, поэтому
//\\\\ предупреждаем игрока прямо в тексте строки
function hg.Workshop.LooksLikeCollection(text)
	return isstring(text) and string.find(text, "/workshop/filedetails/", 1, true) ~= nil
		and string.find(text, "sharedfiles/filedetails", 1, true) == nil
end
