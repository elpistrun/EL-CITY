local MODE = MODE
MODE.name = "hmcd"
MODE.PrintName = "Homicide"

--\\
MODE.TraitorExpectedAmtBits = 13
--//

--\\Sub Roles
MODE.ConVarName_SubRole_Traitor_SOE = "hmcd_subrole_traitor_soe"
MODE.ConVarName_SubRole_Traitor = "hmcd_subrole_traitor"

if(CLIENT)then
	MODE.ConVar_SubRole_Traitor_SOE = CreateClientConVar(MODE.ConVarName_SubRole_Traitor_SOE, "traitor_default_soe", true, true, "Select traitor role in State of Emergency homicide mode")
	MODE.ConVar_SubRole_Traitor = CreateClientConVar(MODE.ConVarName_SubRole_Traitor, "traitor_default", true, true, "Select murder role in Standard homicide modes")
end

--; TODO
--; Инженер - шахид бомба + иеды

--\\ Поджигатель: канистра бензина. Лужи кладём в hg.gasolinePath
--\\ (lua/homigrad/liquidystuff) — тот же бензин, что течёт из простреленных
--\\ канистр на карте, поэтому огонь, распространение и эффекты уже готовы.
MODE.ArsonistFuelMax = 20		--; полная канистра = столько луж
MODE.ArsonistFuelRegen = 10		--; секунд на +1 литр
MODE.ArsonistSpillDelay = 0.25	--; задержка между порциями, пока держишь ALT + E
MODE.ArsonistSpillReach = 140	--; на сколько далеко по прицелу можно лить
MODE.ArsonistIgniteReach = 220	--; с какого расстояния поджигается лужа

--\\ Мясник: жрёт трупы. Сытость (org.satiety) гоняет метаболизм из
--\\ sv_metabolism — пока он сыт, кровь и здоровье возвращаются сами,
--\\ поэтому отдельного лечения роли не нужно, только мясо в желудке.
MODE.ButcherEatTime = 8			--; секунд на одно тело
MODE.ButcherEatReach = 85		--; с какого расстояния достаёт труп
MODE.ButcherNoiseEvery = 1.1	--; как часто чавканье уходит в мир
MODE.ButcherHeal = 15			--; мгновенное мясо в добавок к метаболизму

MODE.SubRoles = {
	--=\\Traitor
	--==\\
	--; https://youtu.be/zP7ux8WsYYI?si=S-Uw2EAehGR5WD3D
	["traitor_default"] = {
		Name = "Дефоко",
		Description = [[Стандарт.
Ты долго готовился к этому.
Ты экипирован различным оружием, ядами и взрывчаткой, гранатами, любимым тяжёлым ножом и сигнальным пистолетом "Зораки" для убийства.]],
		Objective = "Ты укомплектован предметами, ядами, взрывчаткой и оружием, спрятанными в твоих карманах. Убей всех здесь.",
		SpawnFunction = function(ply)
			local wep = ply:Give("weapon_zoraki")
			
			timer.Simple(1, function()
				wep:ApplyAmmoChanges(2)
			end)
			
			ply:Give("weapon_buck200knife")	
			ply:Give("weapon_hg_rgd_tpik")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_shuriken")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_suit")
			ply:Give("weapon_hg_jam")
			-- ply:Give("weapon_traitor_poison2")
			-- ply:Give("weapon_traitor_poison3")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_default_soe"] = {
		Name = "Дефоко",
		Description = [[Стандарт.
Ты долго готовился к этому моменту.
Ты экипирован различным оружием, ядами и взрывчаткой, гранатами, любимым тяжёлым ножом и пистолетом с глушителем и дополнительным магазином для убийства.]],
		Objective = "Ты укомплектован предметами, ядами, взрывчаткой и оружием, спрятанными в твоих карманах. Убей всех здесь.",
		SpawnFunction = function(ply)
			if not IsValid(ply) then return end
			local p22 = ply:Give("weapon_p22")
			if not IsValid(p22) then return end
			ply:GiveAmmo(p22:GetMaxClip1() * 1, p22:GetPrimaryAmmoType(), true)
			
			hg.AddAttachmentForce(ply, p22, "supressor4")
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory",inv)
		end,
	},
	--==//
	
	--==\\
	["traitor_infiltrator"] = {
		Name = "Инфильтратор",
		Description = [[Может ломать шеи со спины.
Может полностью перевоплощаться в других игроков, если они в рагдолле.
Не имеет оружия или инструментов, кроме ножа, эпиначала и дымовой гранаты.
Для тех, кому нравится играть в шахматы.]],
		Objective = "Ты эксперт по диверсиям. Действуй незаметно и убивай по одному.",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_infiltrator_soe"] = {
		Name = "Инфильтратор",
		Description = [[Может ломать шеи со спины.
Может полностью перевоплощаться в других игроков, если они в рагдолле.
Имеет дымовую гранату, рацию, нож, электрошокер с двумя дополнительными боеголовками и эпиначало.
Для тех, кому нравится играть в шахматы.]],
		Objective = "Ты эксперт по диверсиям. Действуй незаметно и убивай по одному.",
		SpawnFunction = function(ply)
			local taser = ply:Give("weapon_taser")
			
			ply:GiveAmmo(taser:GetMaxClip1() * 2, taser:GetPrimaryAmmoType(), true)
			ply:Give("weapon_sogknife")
			-- ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	--==//
	
	--==\\
	--; СДЕЛАТЬ ЕМУ ЛУТ ДРУГИХ ИГРОКОВ ДАЖЕ ПОКА У НИХ НЕТ ПУШКИ В РУКАХ
	--; Сделать ему вырубание по вагус нерву
	["traitor_assasin"] = {
		Name = "Ассасин",
		Description = [[Может быстро обезоруживать людей с любого угла.
Быстрее обезоруживает со спины.
Быстрее обезоруживает спереди, если жертва в рагдолле.
Опытен в стрельбе из оружия.
Имеет дополнительную выносливость (+80 к другим предателям).
Экипирован рацией.
Для тех, кому нравится играть в шашки.]],
		Objective = "Ты эксперт по оружию и обезоруживанию. Обезоруживай вооружённых и используй их оружие против других.",
		SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")	
			-- ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.8
			ply.organism.stamina.max = 300
			--local inv = ply:GetNetVar("Inventory", {}) // WHY SOMEONE COMMENTED THIS
			--inv["Weapons"]["hg_flashlight"] = true
			
			--ply:SetNetVar("Inventory", inv) // BUT NOT THIS???
		end,
	},
	["traitor_assasin_soe"] = {
		Name = "Ассасин",
		Description = [[Может быстро обезоруживать людей с любого угла.
Быстрее обезоруживает со спины.
Быстрее обезоруживает спереди, если жертва в рагдолле.
Опытен в стрельбе из оружия.
Имеет дополнительную выносливость (+80 к другим предателям).
Экипирован рацией, ножом, эпиначалом и фонариком.
Для тех, кому нравится играть в шашки.]],
		Objective = "Ты эксперт по оружию и обезоруживанию. Обезоруживай вооружённых и используй их оружие против других.",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_walkie_talkie")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.4
			ply.organism.stamina.max = 300
			--local inv = ply:GetNetVar("Inventory", {}) // WHY SOMEONE COMMENTED THIS
			--inv["Weapons"]["hg_flashlight"] = true
			
			--ply:SetNetVar("Inventory", inv) // BUT NOT THIS???
		end,
	},
	--==//
	
	--==\\
	["traitor_chemist"] = {
		Name = "Химик",
		Description = [[Имеет несколько химических агентов, эпиначало и нож.
Устойчив в определённой степени ко всем упомянутым химическим агентам.
Может определять наличие и концентрацию химических агентов в воздухе.]],
		Objective = "Ты химик, решивший использовать свои знания во вред другим. Отрави всё.",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			ply:Give("weapon_traitor_poison4")
			ply:Give("weapon_traitor_poison_consumable")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
			CleanChemicalsOfPlayer(ply)
		end,
	},
	--==//
	
	--==\\
	["traitor_arsonist"] = {
		Name = "Поджигатель",
		Description = [[Пироман с канистрой бензина.
Разливает горючее (ALT + E) и поджигает его (ALT + R).
Бензин в лужах горит сам и перекидывается на соседние лужи.
Облитые бензином игроки и предметы загораются охотнее.
От собственного бензина не загорается.
Канистра медленно наполняется заново.
Экипирован спичками, тяжёлым ножом, дымовой гранатой и эпиначалом.
Для тех, кому нравится смотреть, как горит карта.]],
		Objective = "Ты пироман. Сожги всё, где они прячутся, и тех, кто оттуда выбежит.",
		SpawnFunction = function(ply)
			ply:Give("weapon_matches")
			ply:Give("weapon_sogknife")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_adrenaline")
			
			ply.organism.stamina.max = 220
			
			ply.ArsonistFuel = MODE.ArsonistFuelMax
			ply:SetNWInt("ArsonistFuel", MODE.ArsonistFuelMax)
			
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_arsonist_soe"] = {
		Name = "Поджигатель",
		Description = [[Пироман с канистрой бензина.
Разливает горючее (ALT + E) и поджигает его (ALT + R).
Бензин в лужах горит сам и перекидывается на соседние лужи.
Облитые бензином игроки и предметы загораются охотнее.
От собственного бензина не загорается.
Канистра медленно наполняется заново.
Экипирован пистолетом с глушителем, спичками, ножом, дымовой гранатой и эпиначалом.
Для тех, кому нравится смотреть, как горит карта.]],
		Objective = "Ты пироман. Сожги всё, где они прячутся, и тех, кто оттуда выбежит.",
		SpawnFunction = function(ply)
			ply:Give("weapon_matches")
			ply:Give("weapon_sogknife")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_adrenaline")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			
			ply.ArsonistFuel = MODE.ArsonistFuelMax
			ply:SetNWInt("ArsonistFuel", MODE.ArsonistFuelMax)
			
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	--==//
	
	--==\\
	["traitor_butcher"] = {
		Name = "Мясник",
		Description = [[Жрёт трупы: наводится на тело, держит ALT + E — тело исчезает.
Сытость сама возвращает кровь и здоровье, пока он сыт.
Тела — это улики: чем меньше трупов, тем меньше вопросов к нему.
Пока он ест, он почти не двигается и громко чавкает.
Экипирован мачете, эпиначалом, дымовой гранатой и фонариком.
Для тех, кому мало просто убить.]],
		Objective = "Ты мясник. Убивай и поедай: тела не должны ничего рассказать.",
		SpawnFunction = function(ply)
			ply:Give("weapon_hg_machete")
			ply:Give("weapon_hg_headbag")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.stamina.max = 220
			
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_butcher_soe"] = {
		Name = "Мясник",
		Description = [[Жрёт трупы: наводится на тело, держит ALT + E — тело исчезает.
Сытость сама возвращает кровь и здоровье, пока он сыт.
Тела — это улики: чем меньше трупов, тем меньше вопросов к нему.
Пока он ест, он почти не двигается и громко чавкает.
Экипирован пистолетом с глушителем, мачете, эпиначалом, дымовой гранатой и фонариком.
Для тех, кому мало просто убить.]],
		Objective = "Ты мясник. Убивай и поедай: тела не должны ничего рассказать.",
		SpawnFunction = function(ply)
			ply:Give("weapon_hg_machete")
			ply:Give("weapon_hg_headbag")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	--==//
	-- ["traitor_demoman"] = {
		-- Name = "Demoman",
		-- Description = [[Has many explosives.
-- Can rig certain items with bombs
-- (Radio, certain consumables, etc.)]],
		-- Objective = "You're the ultimate chemist who decided to use knowledge to hurt others.",
		-- SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")
			-- ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_hg_pipebomb_tpik")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_traitor_ied")
			-- ply:Give("weapon_walkie_talkie")
			
			-- ply.organism.stamina.max = 220
			-- local inv = ply:GetNetVar("Inventory", {})
			-- inv["Weapons"]["hg_flashlight"] = true
			
			-- ply:SetNetVar("Inventory", inv)
		-- end,
	-- },
	["traitor_zombie"] = {
		Name = "Зомби",
		Description = [[Может незаметно заражать других игроков.
Заражённых игроков может вылечить врач.
Если всех игроков вылечат, зомби проиграет.
Вместо смерти будет случайно телепортирован в тело другого заражённого игрока.
Не имеет оружия или инструментов.
Несмотря на то, что он зомби, выглядит как обычный человек.]],
		Objective = "Ты зомби. Зарази всех, чтобы победить. Избегай врача.",
		SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")	
			-- ply:Give("weapon_adrenaline")
			
			-- ply.organism.stamina.max = 220
			-- local inv = ply:GetNetVar("Inventory", {})
			-- inv["Weapons"]["hg_flashlight"] = true
			
			-- ply:SetNetVar("Inventory", inv)
		end,
	},
	--=//
}
--//

--\\Professions
MODE.ProfessionsRoundTypes = {
	["standard"] = true,
	["soe"] = true,
}

MODE.Professions = {
	["doctor"] = {
		Name = "Врач",
		SpawnFunction = function(ply)	--; TODO MAKE IT WORK
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["huntsman"] = {
		Name = "Охотник",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["engineer"] = {
		Name = "Инженер",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["cook"] = {
		Name = "Повар",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["builder"] = {
		Name = "Строитель",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
}
--//

--\\
--; Названия перменных чуть чуть конченные получились, нужно будет подумать как улучшить
--; ужас
MODE.FadeScreenTime = 1.5
MODE.DefaultRoundStartTime = 6
MODE.RoleChooseRoundStartTime = 10

MODE.RoleChooseRoundTypes = {
	["standard"] = {
		TraitorDefaultRole = "traitor_default",
		Traitor = {
			["traitor_default"] = true,
			["traitor_infiltrator"] = true,
			["traitor_chemist"] = true,
			["traitor_assasin"] = true,
			["traitor_arsonist"] = true,
			["traitor_butcher"] = true,
			--; ОБЪЕДЕНИТЬ ХИМИКА И ДИВЕРСАНТА!!! наверное
			-- ["traitor_demoman"] = true,
		},
		Professions = {
			["doctor"] = {
				Chance = 1,
			},
			["huntsman"] = {
				Chance = 1,
			},
			["engineer"] = {
				Chance = 1,
			},
			["cook"] = {
				Chance = 1,
			},
			["builder"] = {
				Chance = 1,
			},
		},
	},
	["soe"] = {
		TraitorDefaultRole = "traitor_default_soe",
		Traitor = {
			["traitor_default_soe"] = true,
			["traitor_infiltrator_soe"] = true,
			-- ["traitor_chemist_soe"] = true,
			["traitor_assasin_soe"] = true,
			["traitor_arsonist_soe"] = true,
			["traitor_butcher_soe"] = true,
			-- ["traitor_demoman_soe"] = true,
		},
		Professions = {
			["doctor"] = {
				Chance = 1,
			},
			["huntsman"] = {
				Chance = 1,
			},
			["engineer"] = {
				Chance = 1,
			},
			["cook"] = {
				Chance = 1,
			},
		},
	},
}
--//

MODE.Roles = {}
MODE.Roles.soe = {
	traitor = {
		name = "Предатель",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Невиновный",
		color = Color(158,0,190)
	},

	innocent = {
		name = "Невиновный",
		color = Color(0,120,190)
	},
}

MODE.Roles.standard = {
	traitor = {
		objective = "Ты долго готовился к этому. Убей всех.",
		name = "Убийца",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Очевидец",
		color = Color(158,0,190)
	},

	innocent = {
		name = "Очевидец",
		color = Color(0,120,190)
	},
}

MODE.Roles.wildwest = {
	traitor = {
		objective = "Ты долго готовился к этому. Убей всех.",
		name = "Убийца",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Очевидец",
		color = Color(159,85,0)
	},

	innocent = {
		name = "Очевидец",
		color = Color(159,85,0)
	},
}

MODE.Roles.gunfreezone = {
	traitor = {
		name = "Убийца",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Невиновный",
		color = Color(0,120,190)
	},

	innocent = {
		name = "Невиновный",
		color = Color(0,120,190)
	},
}

MODE.Roles.supermario = {
	traitor = {
		objective = "Ты злой Марио! Прыгай и расправляйся со всеми.",
		name = "Марио-предатель",
		color = Color(190,0,0)
	},

	gunner = {
		objective = "Ты герой Марио! Используй свою способность прыгать, чтобы остановить предателя.",
		name = "Марио-герой",
		color = Color(158,0,190)
	},

	innocent = {
		objective = "Ты обычный Марио, выживи и избегай ловушек предателя!",
		name = "Невинный Марио",
		color = Color(0,120,190)
	},
}

function MODE.GetPlayerTraceToOther(ply, aim_vector, dist)
	local trace = hg.eyeTrace(ply, dist, nil, aim_vector)
	
	if(trace)then
		local aim_ent = trace.Entity
		local other_ply = nil
		
		if(IsValid(aim_ent))then
			if(aim_ent:IsPlayer())then
				other_ply = aim_ent
			elseif(aim_ent:IsRagdoll())then
				if(IsValid(aim_ent.ply))then
					other_ply = aim_ent.ply
				end
			end
		end
		
		return aim_ent, other_ply, trace
	else
		return nil
	end
end