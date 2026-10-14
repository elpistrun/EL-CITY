--\\\\ Громкость отдельных категорий звуков: звуки раунда, выстрелы, взрывы
--\\ Значения в процентах (0-200), 100 — как задумано автором
hg.Volumes = hg.Volumes or {}

local Volume = hg.Volumes

local function CreateVolumeConVar(name, help)
	if ConVarExists(name) then return GetConVar(name) end

	return CreateClientConVar(name, "100", true, false, help, 0, 200)
end

Volume.round = CreateVolumeConVar("hg_volume_round", "Громкость звуков начала и конца раунда и боевой музыки, 100 — обычная")
Volume.shot = CreateVolumeConVar("hg_volume_shot", "Громкость выстрелов, 100 — обычная")
Volume.explosion = CreateVolumeConVar("hg_volume_explosion", "Громкость взрывов, 100 — обычная")

local Categories = {
	{
		convar = "shot",
		patterns = {"fire", "shot", "gunfire", "gun_fire", "suppress", "silence", "musket", "win1892", "beretta", "muzzle", "revolver", "pistol", "rifle"},
		ignore = {"fire_extinguisher", "extinguish", "campfire", "fire_crackle", "fire_loop", "burning", "bonfire"},
	},
	{
		convar = "explosion",
		patterns = {"explosion", "explode", "explosive", "ied/", "grenade", "c4", "detonate", "bomb", "boom", "rocket", "rpg", "nuke", "mine_"},
		ignore = {},
	},
}

local function FindCategory(soundName)
	for _, category in ipairs(Categories) do
		local ignored = false

		for _, pattern in ipairs(category.ignore) do
			if string.find(soundName, pattern, 1, true) then
				ignored = true
				break
			end
		end

		if ignored then continue end

		for _, pattern in ipairs(category.patterns) do
			if string.find(soundName, pattern, 1, true) then
				return Volume[category.convar]
			end
		end
	end

	return nil
end

--\\ Множитель для конкретного звука (используется в hg.EmitSound)
function Volume.GetMul(soundName)
	if not soundName or soundName == "" then return 1 end

	local convar = FindCategory(string.lower(soundName))

	return convar and (convar:GetInt() / 100) or 1
end

--\\ Множитель для звуков раунда и музыки
function Volume.GetRoundMul()
	return Volume.round:GetInt() / 100
end

--\\ Проиграть 2D-звук с учётом настройки громкости раунда (заставки начала/конца раунда)
function Volume.Play2D(soundName, volume, level)
	if not soundName or soundName == "" then return end

	volume = (volume or 1) * Volume.GetRoundMul()
	if volume <= 0.001 then return end

	if IsValid(lply) then
		lply:EmitSound(soundName, level or 100, 100, volume, CHAN_AUTO)

		return
	end

	surface.PlaySound(soundName)
end

hg.PlayRoundSound = Volume.Play2D
