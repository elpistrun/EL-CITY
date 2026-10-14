--\\; Проверка звуков за убийства: команда, которая за пару секунд говорит,
--\\; на каком именно шаге пропадает звук.
--\\;
--\\;   hg_soundtest        — в консоли сервера
--\\;   hg_soundtest в игре — админ/суперадмин, звуки придут только ему
--\\;
--\\; Что проверяется:
--\\;   1. лежат ли сами mp3 на сервере — если нет, клиентам нечего скачивать;
--\\;   2. включены ли уведомления (fun_headshotnotify / fun_killstreaknotify);
--\\;   3. две пробы net-сообщений у вызывающего: звук хедшота (его играет даже
--\\;      старый клиент из воркшопа) и elpatron (его играет только клиентская
--\\;      часть сборки — gamemodes/zcity/gamemode/libraries/cl_killsound.lua).
--\\;
--\\; Как читать результат: хедшот слышно, elpatron нет — значит у клиента нет
--\\; либо клиентского файла сборки, либо файла звука (не догрузил после рестарта
--\\; сервера). Слышно оба — провод в порядке, дело было не в музыке.
if not SERVER then return end

local SOUND_FILES = { "funsound/headshot.mp3", "funsound/melee.mp3", "funsound/elpatron.mp3" }
for i = 1, 8 do SOUND_FILES[#SOUND_FILES + 1] = "funsound/" .. i .. ".mp3" end

local function PrintTo(target, txt)
	if IsValid(target) then
		target:PrintMessage(HUD_PRINTCONSOLE, "[SoundTest] " .. txt)
	else
		Msg("[SoundTest] " .. txt .. "\n")
	end
end

local function MissingFiles()
	local missing = {}

	for _, snd in ipairs(SOUND_FILES) do
		if not file.Exists("sound/" .. snd, "GAME") then
			missing[#missing + 1] = snd
		end
	end

	return missing
end

--\\; разовая строка при старте сервера: видно сразу, всё ли на месте
timer.Simple(2, function()
	local missing = MissingFiles()

	if #missing == 0 then
		MsgC(Color(0, 200, 0), "[Z-City] килл-звуки: все " .. #SOUND_FILES ..
			" файлов на месте, клиенты получат их через resource.AddFile\n")
	else
		MsgC(Color(255, 60, 60), "[Z-City] килл-звуки: НЕТ на сервере " .. table.concat(missing, ", ") ..
			" — положи файлы в sound/funsound/\n")
	end
end)

concommand.Add("hg_soundtest", function(ply, cmd, args)
	if IsValid(ply) and not (ply:IsAdmin() or ply:IsSuperAdmin()) then return end

	local missing = MissingFiles()

	if #missing == 0 then
		PrintTo(ply, "файлы на сервере: все " .. #SOUND_FILES .. " на месте")
	else
		PrintTo(ply, "файлов НЕТ на сервере: " .. table.concat(missing, ", ") ..
			" — без них клиент ничего не услышит")
	end

	local head = GetConVar("fun_headshotnotify")
	local streak = GetConVar("fun_killstreaknotify")

	PrintTo(ply, "fun_headshotnotify = " .. (head and head:GetInt() or "нет") ..
		", fun_killstreaknotify = " .. (streak and streak:GetInt() or "нет"))
	PrintTo(ply, "у клиента должен быть включён fun_sound (0 — звук убийств выключен вручную)")

	if not IsValid(ply) then
		PrintTo(ply, "звук не отправляю: запусти команду в игре, чтобы услышать пробу")
		return
	end

	PrintTo(ply, "проба 1/2: звук хедшота (играется даже старым клиентом из воркшопа)")
	net.Start("HG_HeadshotPlay")
	net.Send(ply)

	timer.Simple(1.8, function()
		if not IsValid(ply) then return end

		PrintTo(ply, "проба 2/2: elpatron (играется только клиентским файлом сборки)")
		net.Start("HG_PistolKill")
		net.Send(ply)

		PrintTo(ply, "услышал оба звука — провод рабочий, дело было не в раздаче")
	end)
end)
