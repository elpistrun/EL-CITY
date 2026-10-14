
local allowedchars = {
	"ah",
	"AH",
	"ghh",
	"GH",
	"AHHH",
}

local audible_pain = {
	"АААААГХ..БЛЯ.. БОЛИТ.",
	"Я БОЛЬШЕ НЕ МОГУ ЭТО ТЕРПЕТЬ!",
    "ПРЕКРАТИ Прекрати ПРЕКРАТИ ПРЕКРАТИ ЭТО",
    "Почему это НЕ ПРЕКРАЩАЕТСЯ",
    "Вырубите меня. ПОЖАЛУЙСТА",
    "Зачем я рождён, чтобы чувствовать это... зачем...",
    "Я бы всё отдал, чтобы это прекратилось... ВСЁ.",
    "Это не жизнь, это ПЫТКА",
    "Мне плевать, лишь бы ПРЕКРАТИЛАСЬ БОЛЬ",
    "Ничто не важно, кроме ТОГО ЧТОБЫ ЭТО ПРЕКРАТИЛОСЬ...",
    "Каждая секунда — вечность ОГНЯ.",
    "СМЕРТЬ БЫЛА БЫ МИЛОСЕРДИЕМ СЕЙЧАС...",
    "Хотя бы один миг без боли..",
	"КАК ЖЕ Я ХОЧУ ОБЕЗБОЛИВАЮЩЕЕ. БЛЯ.",
}

local sharp_pain = {
	"AAAHH",
	"AAAH",
	"AAaaAH",
	"AAaaAH",
	"AAaaAAAGH",
	"AAaaAH",
	"AAaAaaH",
	"AAAAAaaH",
	"AAaaAHHHH",
	"AAaAA",
	"AAAAAa",
	"AAAAaAAAaaaaghh",
	"AAAaaAa",
	"AaaAAaghf",
	"aaAaaAaff",
	"aaahhh",
	"AAAaaGHHH",
	"AAAaaAAHH",
	"AAAaaAAAAAaGHHHH",
	"AAAaaAAAAAaGHAAAHHH",
	"AAAaaAAAAAaGHHAAAAAAHH",
	"AAAaaAAAAAaGHHHH",
	"AAAaaAAAaaAAAaGHHHH",
	"AAAaaAAAaaAAAaAAAAAAAGHHHH",
	"AAAaaAAAAAaGHHHH",
	"AAAaaAAAAAAAAAHHH",
	"AAAaaAAAAAaGHAaaaHH",
	"AAAaaAAAAAaAaaaaaAAAAHH",
	"AAAaaAAAAAaAAAAAAAADGHHHH",
	"AAAaaAAAaaAAAaAAAAAAAAAAAAGGGGGGAGHHHH",
	"AAAaaAAAaaAAAaAAAAAAAAAAAAAAAAAAH",
}

hg.sharp_pain = sharp_pain

local random_phrase = {
	"Тут как-то холодно...",
	"Всё кажется слишком тихим...",
	"Дышать удивительно приятно прямо сейчас.",
	"Что если эта тишина будет вечной?",
	"Почему ничего не происходит?",
	"Я слышу биение собственного сердца...",
	"Тишина почти оглушает.",
	"Время... как-то иначе течёт.",
	"Есть тут вообще кто-нибудь?",
	"Сколько я уже тут стою?",
	"Воздух на вкус как застоявшийся.",
	"Я не помню, как я сюда попал.",
	"Ничто не меняется, да?",
	"Я сейчас вообще в сознании?",
	"Тени кажутся темнее обычного.",
	"В этой тишине мои мысли такие громкие.",
	"Когда успело так стемнеть?",
	"Мне кажется, за мной кто-то наблюдает.",
	"Всё ровно там, где было раньше.",
	"Кто-нибудь знает, что я здесь?",
	"Стены будто стали ближе.",
	"О чём я думал?",
	"Время здесь движется так странно.",
	"Не помню, когда что-то вообще менялось.",
	"Тишина начинает казаться живой.",
}


local fear_hurt_ironic = {
	"Наверняка в этом есть урок... если я выживу.",
	"Мой будущий биограф не поверит в эту часть.",
	"Ну, это глупый способ умереть.",
	"По крайней мере, моя жизнь не была скучной.",
	"Заметка себе: Больше никогда так не делай.",
	"Это не худший день, чтобы умереть.",
	"Всё в порядке. Всё отлично.",
	"По крайней мере, умру зная, что был прав.",
	"Наверное, я это заслужил.",
	"Ну, я просил приключений.",
	"Они наверняка посмеются на этих похоронах.",
	"По крайней мере, будет что рассказать... если кто-то доживёт.",
	"Я выживал и в худшем дерьме... наверное.",
}

local fear_phrases = {
	"Не так уж и страшно... да?",
	"Я не хочу так умереть.",
	"Неужели это конец?",
	"Это плохо.",
	"Неужели это действительно конец?",
	"Я не хочу так умереть.",
	"Хотел бы я, чтобы был выход.",
	"Я так о многом жалею.",
	"Этого не может быть.",
	"Не могу поверить, что это происходит со мной.",
	"Надо было относиться к этому серьёзнее.",
	"А что если я не справлюсь..?",
	"Всё хуже, чем я думал.",
	"Это так несправедливо.",
	"Я не могу сдаться сейчас.",
	"Я и представить не мог, что будет так.",
	"Надо было слушать свои инстинкты.",
	"Дыши. Просто дыши.",
	"Холодные руки. Уверенные руки.",
}

local is_aimed_at_phrases = {
    "О Господи. Это конец.",
    "Не. двигайся.",
    "Неужели я так умру?",
    "Надо было бежать. Почему я не побежал?",
    "Только не нажимай на курок. Пожалуйста.",
    "Я вижу его палец на курке.",
    "Я не хочу умирать. Не так.",
    "Если я начну умолять, станет только хуже?",
    "Это не может быть правдой. Это не может быть правдой.",
    "Кто-нибудь, помогите мне. Пожалуйста. Кто-нибудь.",
    "Я не хочу умирать в таком месте.",
    "Я не хочу, чтобы моей последней мыслью был страх.",
    "Я не хочу умирать.",
}

local near_death_poetic = {
	"Пытаюсь встать... но не могу...",
	"Дыхание — просто поверхностные глотки пустоты...",
	"Не могу понять, открыты ли у меня глаза...",
	"Последнее, что я почувствую — вкус собственной крови и меди.",
	"Глаза всё время соскальзывают с предметов.",
	"Не могу вспомнить, как это — стоять.",
	"Всё эхом отдаётся внутри черепа.",
	"Моргание занимает слишком много времени.",
	"Пальцы не сжимаются ни вокруг чего.",
	"Лёгкие отказываются наполняться.",
	"Сожаления теперь бессмысленны.",
}

local near_death_positive = {
	"Я не хочу умирать.",
	"Я должен выжить.",
	"Ещё есть шанс.",
	"Я не дам страху победить.",
	"Ещё одна попытка.",
	"Я отказываюсь умирать здесь.",
	"Так... думай об этом спокойно.",
	"Просто не двигайся. От движения хуже.",
	"Дыши медленно. Паника не поможет.",
	"Ещё не всё кончено.",
	"Боль — просто сигнал. Игнорируй его.",
	"Если это всё... хотя бы будет быстро.",
	"Я переживал и худшее. Наверное.",
	"Я не так это себе представлял.",
}

local broken_limb = {
	"БЛЯ. БЛЯ. ТОЧНО СЛОМАНО!",
	"Я ЧУВСТВУЮ, КАК ШЕВЕЛЯТСЯ ОСКОЛКИ КОСТИ!",
	"ЭТО БЛЯТЬ СЛОМАНО. КАЖЕТСЯ..",
	"Болит даже от мысли об этом. Точно сломано.",
	"Оно не должно так сгибаться.",
	"Ох, бля. Оно сломалось.",
	"Открытого перелома не вижу, но чувствую, что что-то сломал",
}

local dislocated_limb = {
	"Да, так оно сгибаться не должно.",
	"Надо вернуть эту кость на место.",
	"Нет... надо вправить её обратно.",
	"Там просто очень болит. Может, стоит провериться.",
	"Моя конечность не на месте.",
}

local hungry_a_bit = {
    "Мгх, я голоден...",
    "Было бы неплохо поесть...",
    "Я голоден...",
    "Надо что-нибудь съесть.",
}

local very_hungry = {
    "Мой желудок... Угх...",
    "Если я не поем, станет ещё хуже...",
    "Желудок... Чёрт... Меня тошнит",
}

local after_unconscious = {
    "Что произошло? Болит...",
	"Где я? Почему так болит...",
	"Я-я думал, что умираю...",
	"Моя голова... Что случилось?",
	"Я что, чуть не умер секунду назад?",
	"Было ощущение, что я умер.",
	"Небеса меня не забрали?",
	"Ох-бля... голова раскалывается...",
	"Ох, сейчас будет тяжело подняться... но надо...",
	"Я совсем не узнаю это место... или узнаю?",
	"Я НЕ хочу пережить это СНОВА!",
}

local slight_braindamage_phraselist = {
	"Я не понимаю...",
	"Это не имеет смысла...",
	"Где я?",
	"Э? Что это..?",
	"Я не знаю, что происходит...",
	"Алло?",
	"Угххх охххх...      хм...",
	"Что... происходит?",
}

local braindamage_phraselist = {
	"Bbbee.. wheea mgh?!",
	"Bmmeee... mehk...",
	"Mm--hhhh. Mmm?",
	"Ghmgh whhh...",
	"Ahgg...mg?",
	"Hgghh... D-Dmmh.",
	"Lmmmphf, mp-hf!",
	"Heeelllhhpphp...",
	"Nghh... Gmh?",
	"Ggg... Bgh..",
	"Bhrhraihin.",
}

local cold_phraselist = {
	"Становится очень холодно..",
	"Слишком холодно для меня.",
	"Я дрожу, охренел, чувак.",
	"Ужасно зябко тут..",
	"Нужно что-то, чтобы согреться...",
	"Мне довольно холодно...",
	"Меня от этого холода мутит, бля."
}

local freezing_phraselist = {
	"Я.. ни.. не ч-чувствую с-своё т-тело..",
	"Я не.. ч-чувствую н-ноги...",
	"Я з-за-мёр-з-з на-х-хер..",
	"Я-я ду-умаю, м-моё л-лицо он-неме-ело..",
	"Х-холод-дно..",
	"Я.. ни-иче-его не ч-чув-ствую..",
}

local numb_phraselist = {
	"Больше.. не холодно..",
	"Почему... мне тепло..?",
	"Кажется, я в порядке... кажется...",
	"Наконец-то тепло...",
	"Мне снова тепло... Откуда-то...",
	"Я только что замерзал... Откуда это тепло..?",
}

local hot_phraselist = {
	"Я весь мокрый от пота..",
	"Эта жара меня убивает..",
	"Моя одежда вся в поту, бля.",
	"От моего пота воняет, бля. Надо бы остыть...",
	"Слишком жарко, бля, чувак.",
	"Меня реально развозит от жары...",
	"Почему здесь так жарко?",
}

local heatstroke_phraselist = {
	"МНЕ НУЖНА ВОДА!!",
	"Пожалуйста... вода...",
	"Голова кружится... Бля-ять-",
	"МОЯ ГОЛОВА!- Болит..",
	"Голова раскалывается..",
}

local heatvomit_phraselist = {
	"От этой жары..- меня сейчас стошнит-",
	"Угхххх... меня сейчас вырвет-",
	"Бля.. Оуххх.. Мне плохо-"
}

local hg_showthoughts = ConVarExists("hg_showthoughts") and GetConVar("hg_showthoughts") or CreateClientConVar("hg_showthoughts", "1", true, true, "Toggle thoughts of your character", 0, 1)

function string.Random(length)
	local length = tonumber(length)

    if length < 1 then return end

    local result = {}

    for i = 1, length do
        result[i] = allowedchars[math.random(#allowedchars)]
    end

    return table.concat(result)
end

function hg.nothing_happening(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear < -0.6
end

function hg.fearful(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear > 0.5
end

function hg.likely_to_phrase(ply)
	local org = ply.organism

	local pain = org.pain
	local brain = org.brain
	local blood = org.blood
	local fear = org.fear
	local temperature = org.temperature
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone - CurTime()) < -3)

	return (broken_dislocated) and 5
		or (pain > 65) and 5
		or (temperature < 31 and 0.5)
		or (temperature > 38 and 0.5)
		or (blood < 3000 and 0.3)
		or (fear > 0.5 and 0.7)
		or (brain > 0.1 and brain * 5)
		or (fear < -0.5 and 0.05)
		or -0.1
end

function IsAimedAt(ply)
    return ply.aimed_at or 0
end

local function get_status_message(ply)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end

	local nomessage = hook.Run("HG_CanThoughts", ply) --ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"
	if nomessage ~= nil and nomessage == false then return "" end

    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism
	
	if not org or not org.brain then return "" end

	local pain = org.pain
	local brain = org.brain
	local temperature = org.temperature
	local blood = org.blood
	local hungry = org.hungry
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone + 3 - CurTime()) < -3)
	local fear = org.fear
	local adrenaline = org.adrenaline

	if broken_dislocated and org.just_damaged_bone then
		org.just_damaged_bone = nil
	end
	
	local broken_notify = (org.rarm == 1) or (org.larm == 1) or (org.rleg == 1) or (org.lleg == 1)
	local dislocated_notify = (org.rarm == 0.5) or (org.larm == 0.5) or (org.rleg == 0.5) or (org.lleg == 0.5)
	local after_unconscious_notify = org.after_otrub

	if not isnumber(pain) then return "" end

	local str = ""

	local most_wanted_phraselist
	
	if temperature < 35 then
		most_wanted_phraselist = temperature > 31 and cold_phraselist or (temperature < 28 and numb_phraselist or freezing_phraselist)
	elseif temperature > 38 then
		most_wanted_phraselist = temperature < 40 and hot_phraselist or heatstroke_phraselist
	end

	if not most_wanted_phraselist and hungry and hungry > 25 and math.random(3) == 1 then
		most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
	end

	if (blood < 3100) or (pain > 75) or (broken_dislocated) or (broken_notify) or (dislocated_notify) then
		if pain > 75 and (broken_dislocated) then
			most_wanted_phraselist = math.random(2) == 1 and audible_pain or (broken_notify and broken_limb or dislocated_limb)
		elseif pain > 75 then
			most_wanted_phraselist = audible_pain
		elseif broken_dislocated then
			most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
		end

		if pain > 100 then
			most_wanted_phraselist = sharp_pain
		end

		if not most_wanted_phraselist then
			if (broken_dislocated_notify) and (blood < 3100) then
				most_wanted_phraselist = blood < 2900 and (near_death_poetic) or (math.random(2) == 1 and (broken_notify and broken_limb or dislocated_limb) or near_death_poetic)
			--elseif(broken_dislocated_notify)then
				--most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
			elseif(blood < 3100)then
				if adrenaline > 1.3 and fear < 0.5 then
					most_wanted_phraselist = near_death_positive
				else
					most_wanted_phraselist = near_death_poetic
				end
			end
		end
	elseif after_unconscious_notify then
		most_wanted_phraselist = after_unconscious
	elseif hg.nothing_happening(ply) then
		most_wanted_phraselist = random_phrase

		if hungry and hungry > 25 and math.random(5) == 1 then
			most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
		end
	elseif hg.fearful(ply) then
		most_wanted_phraselist = ((IsAimedAt(ply) > 0.9) and is_aimed_at_phrases or (math.random(10) == 1 and fear_hurt_ironic or fear_phrases))
	end

	if brain > 0.1 then
		most_wanted_phraselist = brain < 0.2 and slight_braindamage_phraselist or braindamage_phraselist
	end
	
	if most_wanted_phraselist then
		str = most_wanted_phraselist[math.random(#most_wanted_phraselist)]

		return str
	else
		return ""
	end
end

local allowedlist_types = {
	heatvomit = heatvomit_phraselist,
}

function hg.get_phraselist(ply, type)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end
	
	local nomessage = ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"

	if nomessage then return "" end
    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism	
	if not org or not org.brain then return "" end

	if not isstring(type) or not allowedlist_types[type] then return "" end

	local needed_list = allowedlist_types[type]

	local str = needed_list[math.random(#needed_list)]
	return str
end

function hg.get_status_message(ply)
	local txt = get_status_message(ply)

	return txt
end
