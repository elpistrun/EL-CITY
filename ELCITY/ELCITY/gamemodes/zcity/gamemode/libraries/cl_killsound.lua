--\\; Звуки за убийства + зелёная вспышка (клиент).
--\\;
--\\; Заменяет клиентскую половину аддона funsounds (воркшоп 3750329401): сервер
--\\; шлёт те же net-сообщения, но обработчики перебиваются здесь, потому что
--\\; у клиента лежит своя локальная копия аддона, и правки в ней до игроков не
--\\; доезжают. Отсюда два отличия от аддона: вспышка зелёная, а за убийство из
--\\; пистолета играет elpatron.mp3 вместо звука серии.
if not CLIENT then return end

local HEADSHOT_SOUND = "funsound/headshot.mp3"
local KNIFEKILL_SOUND = "funsound/melee.mp3"
local ELPATRON_SOUND = "funsound/elpatron.mp3"

local KILL_SOUNDS = {
	"funsound/1.mp3",
	"funsound/2.mp3",
	"funsound/3.mp3",
	"funsound/4.mp3",
	"funsound/5.mp3",
	"funsound/6.mp3",
	"funsound/7.mp3",
	"funsound/8.mp3",
}

--; Диагностика: если файла нет у клиента, surface.PlaySound молча ничего не играет.
--; Звуки обязан раздать сервер через resource.AddFile (см. addons/funsounds) —
--; например, в опубликованном воркшоп-предмете аддона нет elpatron.mp3, поэтому
--; без раздачи от сервера клиенту просто нечего играть.
do
	local all = { HEADSHOT_SOUND, KNIFEKILL_SOUND, ELPATRON_SOUND }
	for _, snd in ipairs(KILL_SOUNDS) do all[#all + 1] = snd end

	local missing = {}
	for _, snd in ipairs(all) do
		if not file.Exists("sound/" .. snd, "GAME") then missing[#missing + 1] = snd end
	end

	if #missing > 0 then
		MsgC(Color(255, 170, 0), "[Z-City] килл-звуки: клиентская часть загружена, но звуков нет: "
			.. table.concat(missing, ", ") .. " — их отдаёт сервер через resource.AddFile (нужен перезапуск сервера)\n")
	else
		MsgC(Color(0, 200, 0), "[Z-City] килл-звуки: клиентская часть загружена, все " .. #all .. " звуков на месте\n")
	end
end

--; те же имена и значения, что в аддоне: если аддона у игрока нет, настройки
--; всё равно должны существовать и сохраняться
local convar_sound = GetConVar("fun_sound") or CreateClientConVar("fun_sound", "1", true, false, "звук за убийство")
local convar_flash = GetConVar("fun_killflash") or CreateClientConVar("fun_killflash", "1", true, false, "вспышка при убийстве")

local killFlashTime = 0
local FLASH_TIME = 0.4 --; как в аддоне

local function PlaySound(snd, delay)
	if not convar_sound:GetBool() then return end

	if delay and delay > 0 then
		timer.Simple(delay, function() surface.PlaySound(snd) end)
	else
		surface.PlaySound(snd)
	end
end

--; вспышка: те же параметры, что у синей в аддоне, но зелёный канал вместо синего
hook.Remove("RenderScreenspaceEffects", "HG_KillFlashEffect")
hook.Add("RenderScreenspaceEffects", "ZB_KillFlashGreen", function()
	if not convar_flash:GetBool() then return end
	if killFlashTime <= CurTime() then return end

	local remaining = killFlashTime - CurTime()
	local intensity = math.Clamp(remaining / FLASH_TIME, 0, 1)

	DrawColorModify({
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0.35 * intensity,
		["$pp_colour_addb"] = 0.01 * intensity,
		["$pp_colour_brightness"] = 0.04 * intensity,
		["$pp_colour_contrast"] = 1 + (0.08 * intensity),
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	})
end)

net.Receive("HG_KillFlash", function()
	killFlashTime = CurTime() + FLASH_TIME
end)

net.Receive("HG_HeadshotPlay", function()
	PlaySound(HEADSHOT_SOUND)
end)

net.Receive("HG_KnifeKill", function()
	PlaySound(KNIFEKILL_SOUND, 0.5)
end)

--; убийство из пистолета: сервер шлёт это вместо звука серии
net.Receive("HG_PistolKill", function()
	PlaySound(ELPATRON_SOUND, 0.5)
end)

net.Receive("HG_KillPlay", function()
	local typ = net.ReadInt(8)
	local snd = KILL_SOUNDS[typ]
	if snd then PlaySound(snd, 0.5) end
end)
