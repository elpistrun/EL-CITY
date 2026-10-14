--
-- Russian weapon names. Weapons that still have english, descriptive names get
-- translated here instead of editing every single weapon file.
--
hg = hg or {}

hg.weaponNames = {
	--\\\\ Кулаки
	["weapon_hands_sh"] = "Кулаки",
	["weapon_hg_coolhands"] = "Крутые кулаки",
	["stronk_fist"] = "Мощные кулаки",
	--//

	--\\\\ Ближний бой
	["weapon_melee"] = "Боевой нож",
	["weapon_buck200knife"] = "Кухонный нож",
	["weapon_sogknife"] = "Нож Предателя",
	["weapon_pocketknife"] = "Мини нож",
	["weapon_bat"] = "Бита",
	["weapon_brick"] = "Кирпич",
	["weapon_hammer"] = "Молоток",
	["weapon_hatchet"] = "Мини топор",
	["weapon_tomahawk"] = "Томагавк",
	["weapon_leadpipe"] = "Железная труба",
	["weapon_chair_leg"] = "Палка",
	["weapon_table_leg"] = "Палка",
	["weapon_gymnasticstick"] = "Гимнастическая палка",
	["weapon_pan"] = "Сковородка",
	["weapon_hg_bottle"] = "Бутылка",
	["weapon_hg_bottlebroken"] = "Сломанная бутылка",
	["weapon_hg_mug"] = "Кружка",
	["weapon_hg_glassshard"] = "Осколок стекла",
	["weapon_hg_glassshard_taped"] = "Осколок в изоленте",
	["weapon_hg_crowbar"] = "Монтировка",
	["weapon_hg_crowbar_gordon"] = "Монтировка",
	["weapon_hg_axe"] = "Топор",
	["weapon_hg_sledgehammer"] = "Кувалда",
	["weapon_hg_shovel"] = "Лопата",
	["weapon_hg_machete"] = "Мачете",
	["weapon_hg_spear"] = "Старое копьё",
	["weapon_hg_spear_pro"] = "Крутое копьё",
	["weapon_hg_spear_knife"] = "Копьё с ножом",
	["weapon_hg_tonfa"] = "Полицейская дубинка",
	["weapon_hg_stunstick"] = "Шоковая дубинка",
	["weapon_hg_shuriken"] = "Сюрикен",
	["weapon_hg_extinguisher"] = "Огнетушитель",
	["weapon_hg_crossbow"] = "Самодельный арбалет",
	["weapon_hg_bow"] = "Лук «Deer Hunter»",
	["weapon_thaumaturgic_arm"] = "Шприц",
	["weapon_ballistic_shield"] = "Баллистический щит",
	["weapon_shield"] = "Баллистический щит",
	["weapon_ram"] = "Таран",
	["weapon_taser"] = "Тазер X26",
	["weapon_grapplinghook"] = "Крюк-кошка",
	--//

	--\\\\ Медицина
	["weapon_bandage_sh"] = "Бинт",
	["weapon_bigbandage_sh"] = "Большой бинт",
	["weapon_medkit_sh"] = "Аптечка",
	["weapon_hg_medicine_base"] = "Медикаменты",
	["weapon_bloodbag"] = "Пакет крови",
	["weapon_tourniquet"] = "Жгут",
	["weapon_needle"] = "Игла для декомпрессии",
	["weapon_adrenaline"] = "Адреналин",
	["weapon_morphine"] = "Морфин",
	["weapon_painkillers"] = "Обезболивающие",
	["weapon_painkillers_tpik"] = "Обезболивающие",
	["weapon_naloxone"] = "Налоксон",
	["weapon_mannitol"] = "Маннитол",
	["weapon_thiamine"] = "Тиамин",
	["weapon_fentanyl"] = "Фентанил",
	["weapon_betablock"] = "Бета-блокатор",
	["weapon_fury16"] = "Норэпинефрин «Uber»",
	["weapon_tranquilizer"] = "Транквилизатор",
	--//

	--\\\\ Расходники и инструменты
	["weapon_smallconsumable"] = "Малый расходник",
	["weapon_smallconsumable_tpik"] = "Малый расходник",
	["weapon_bigconsumable"] = "Большой расходник",
	["weapon_bigconsumable_tpik"] = "Большой расходник",
	["weapon_ducttape"] = "Скотч",
	["weapon_matches"] = "Спичечный коробок",
	["weapon_handcuffs"] = "Наручники",
	["weapon_handcuffs_key"] = "Ключ от наручников",
	["weapon_walkie_talkie"] = "Рация",
	["weapon_hg_motiontracker"] = "Детектор движения",
	["weapon_hidebox"] = "Складной ящик",
	["weapon_spawnmenu_pda"] = "Планшет",
	["weapon_hg_jam"] = "Клин для двери",
	["weapon_traitor_suit"] = "Костюм",
	["weapon_hg_bugbait"] = "Феропод",
	["weapon_hg_snowball"] = "Снежок",
	--//

	--\\\\ Взрывчатка и тяжёлое
	["weapon_claymore"] = "Клеймор",
	["weapon_breachcharge"] = "Пробойный заряд",
	["weapon_traitor_ied"] = "Самодельное взрывное устройство",
	["weapon_hg_molotov_tpik"] = "Коктейль Молотова",
	["weapon_hg_pipebomb_tpik"] = "Бомба-труба",
	["weapon_hg_smokenade_tpik"] = "Дымовая шашка",
	["weapon_hg_flashbang_tpik"] = "Светошумовая граната",
	["weapon_hg_hl2nade_tpik"] = "Осколочная граната Альянса",
	["weapon_combinesniper"] = "Снайперская винтовка Альянса",
	["weapon_hg_rebelrpg"] = "РПГ повстанцев",
	["weapon_osipr"] = "О.С.И.П.Р.",
	["weapon_remington870_roullet"] = "Азартный дробовик",
	["weapon_akmwreked"] = "Подпольный AKM",
	--//

	--\\\\ Яды
	["weapon_traitor_poison1"] = "Шприц с тетродотоксином",
	["weapon_traitor_poison2"] = "Ампула с VX",
	["weapon_traitor_poison3"] = "Канистра с цианидом",
	["weapon_traitor_poison4"] = "Ампула с кураре",
	["weapon_traitor_poison_consumable"] = "Капсула с цианидом",
	--//
}

function hg.GetWeaponPrintName(wep)
	if not IsValid(wep) then return "" end

	local class = wep:GetClass()
	local name = hg.weaponNames[class]
	if name then return name end

	if wep.GetPrintName then return wep:GetPrintName() end

	return class
end

-- Makes the name show up everywhere that reads SWEP.PrintName / GetPrintName
local function ApplyWeaponNames()
	for class, name in pairs(hg.weaponNames) do
		if CLIENT then
			language.Add(class, name)
		end

		local wep = weapons.GetStored(class)
		if wep then
			wep.PrintName = name
		end
	end
end

hg.ApplyWeaponNames = ApplyWeaponNames

hook.Add("InitPostEntity", "hg_weaponnames", ApplyWeaponNames)
