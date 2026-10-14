local MODE = MODE

util.AddNetworkString("HMCD_BeingVictimOfNeckBreak")	--; А тут я значит рещил без скобок да крутой кодинг стиль вопросы?
util.AddNetworkString("HMCD_BreakingOtherNeck")
util.AddNetworkString("HMCD_BeingVictimOfDisarmament")
util.AddNetworkString("HMCD_DisarmingOther")
util.AddNetworkString("HMCD_UpdateChemicalResistance")

--\\Chemical resistance
	function MODE.NetworkChemicalResistanceOfPlayer(ply)
		ply.PassiveAbility_ChemicalAccumulation = ply.PassiveAbility_ChemicalAccumulation or {}
		
		net.Start("HMCD_UpdateChemicalResistance")
		
		for chemical_name, amt in pairs(ply.PassiveAbility_ChemicalAccumulation) do
			net.WriteString(chemical_name)
			net.WriteUInt(math.Round(amt), MODE.NetSize_ChemicalResistanceBits)
		end
		
		net.WriteString("")
		net.Send(ply)
	end
--//

--\\Поджигатель: разливает бензин в hg.gasolinePath — тот же горючий след,
--\\ что течёт из простреленных канистр на карте (lua/homigrad/liquidystuff).
--\\ Игнорирование этого горючего самим поджигателем — там же, в ignition loop.
	function MODE.IsArsonist(ply)
		return ply.SubRole == "traitor_arsonist" or ply.SubRole == "traitor_arsonist_soe"
	end

	function MODE.SetArsonistFuel(ply, amount)
		amount = math.Clamp(amount or 0, 0, MODE.ArsonistFuelMax)
		
		ply.ArsonistFuel = amount
		ply:SetNWInt("ArsonistFuel", amount)
		
		return amount
	end

	--; чтобы одна и та же точка не превратилась в сотню луж
	function MODE.ArsonistPuddleNear(pos, dist)
		local dist_sqr = dist * dist
		
		for _, path in ipairs(hg.gasolinePath or {}) do
			if((path[1] - pos):LengthSqr() <= dist_sqr)then
				return true
			end
		end
		
		return false
	end

	--; пролить порцию бензина: лужа ложится туда, куда смотрит прицел
	function MODE.ArsonistSpill(ply)
		if((ply.ArsonistFuel or 0) <= 0)then return false end
		
		--; hg.eyeTrace — то же зрение, что у остального режима (шея, кастомная камера)
		local trace = hg.eyeTrace(ply, MODE.ArsonistSpillReach)
		
		if(!trace or !trace.Hit)then return false end
		if(MODE.ArsonistPuddleNear(trace.HitPos, 32))then return false end
		
		--; во что попали — то и пропитали: пропитанное горит охотнее
		local ent = trace.Entity
		if(IsValid(ent) and ent != ply and (ent:IsPlayer() or ent:IsNPC() or ent:IsRagdoll()))then
			ent.shouldburn = (ent.shouldburn or 0) + 1
		end
		
		--; третий элемент — кто разлил: этот же игрок считается источником огня
		hg.gasolinePath = hg.gasolinePath or {}
		table.insert(hg.gasolinePath, {trace.HitPos, false, ply})
		
		ply:EmitSound("player/footsteps/wade3.wav", 60, math.random(70, 90), 0.4)
		MODE.SetArsonistFuel(ply, ply.ArsonistFuel - 1)
		
		return true
	end

	--; поджечь ближайшую лужу — дальше огонь идёт сам по цепочке (liquidystuff)
	function MODE.ArsonistIgnite(ply)
		local eye = ply:GetShootPos()
		local best, best_dist
		
		for _, path in ipairs(hg.gasolinePath or {}) do
			if(path[2])then continue end	--; уже горит или уже прогорело
			
			local dist = (path[1] - eye):Length()
			
			if(dist <= MODE.ArsonistIgniteReach and (!best_dist or dist < best_dist))then
				best, best_dist = path, dist
			end
		end
		
		if(!best)then return false end
		
		best[2] = CurTime()
		best[3] = ply
		
		ply:EmitSound("f_firematch_strike.wav", 60, 100, 0.6)
		
		return true
	end
--//

--\\Мясник: поедание трупов. Тело удаляется вместе со своими уликами,
--\\ а сытость (org.satiety) дальше сама лечит жирного предателя через
--\\ metabolism — см. lua/homigrad/organism/tier_1/modules/sv_metabolism.lua
	function MODE.StartButchering(ply, rag)
		ply.Ability_Butcher = {
			Ragdoll = rag,
			Progress = 0,
			NextSound = 0,
		}
	end

	function MODE.StopButchering(ply)
		if(!ply.Ability_Butcher)then return end
		
		ply.Ability_Butcher = nil
		ply:SetNWFloat("ButcherProgress", 0)
	end

	function MODE.ContinueButchering(ply)
		local ability = ply.Ability_Butcher
		local rag = ability.Ragdoll
		
		--; труп утащили, прицел ушёл или мы отошли — рвём трапезу
		local trace = hg.eyeTrace(ply, MODE.ButcherEatReach)
		local aim_rag = trace and trace.Entity
		
		if(!IsValid(rag) or aim_rag != rag or ply:GetShootPos():Distance(rag:GetPos()) > MODE.ButcherEatReach * 1.5)then
			MODE.StopButchering(ply)
			return
		end
		
		ability.Progress = ability.Progress + FrameTime() * (100 / MODE.ButcherEatTime)
		
		--; чавканье слышно вокруг — это и есть противовес роли
		if((ability.NextSound or 0) <= CurTime())then
			ability.NextSound = CurTime() + MODE.ButcherNoiseEvery
			
			ply:EmitSound("snd_jack_hmcd_eat" .. math.random(4) .. ".wav", 75, math.random(85, 105), 0.9)
		end
		
		ply:SetNWFloat("ButcherProgress", math.Clamp(ability.Progress, 0, 100))
		
		if(ability.Progress >= 100)then
			MODE.DevourCorpse(ply, rag)
			MODE.StopButchering(ply)
		end
	end

	function MODE.DevourCorpse(ply, rag)
		local owner_ply = MODE.CorpseOwnerOf(rag)
		local org = ply.organism
		
		--; сытость гоняет метаболизм: кровь и хп возвращаются сами (sv_metabolism)
		if(org)then
			org.satiety = math.min((org.satiety or 0) + 60, 100)
			org.hungry = math.max((org.hungry or 0) - 60, 0)
		end
		
		ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + MODE.ButcherHeal))
		ply:ChatPrint("Тело съедено. Улика исчезла, голод утих.")
		
		--; тело исчезает вместе с содеянным: чистим ссылки, как это делает Garbage
		if(IsValid(owner_ply))then
			owner_ply:SetNWEntity("RagdollDeath", NULL)
			owner_ply.RagdollDeath = nil
		end
		
		--; organism на трупе чистится сам через CallOnRemove
		if(IsValid(rag))then
			rag:Remove()
		end
	end
--//

hook.Add("PlayerPostThink", "HMCD_SubRoles_Abilities", function(ply)
	if(MODE.RoleChooseRoundTypes[MODE.Type])then
		if(ply:Alive() and ply.organism and not ply.organism.otrub)then
			if(ply.SubRole == "traitor_infiltrator" or ply.SubRole == "traitor_infiltrator_soe")then
				if(ply:KeyDown(IN_WALK))then
					if(ply:KeyPressed(IN_RELOAD))then
						local aim_ent, other_ply = hg.eyeTrace(ply,85).Entity
						other_ply = hg.RagdollOwner(aim_ent) or aim_ent
						
						if(IsValid(aim_ent) and aim_ent:IsRagdoll())then	--; REDO
							local other_appearance = aim_ent.CurAppearance
							local your_appearance = ply.CurAppearance

							local aMdl1,aMdl2 = your_appearance.AModel,other_appearance.AModel
							
							other_appearance.AModel = aMdl1
							your_appearance.AModel = aMdl2

							local aFace1,aFace2 = your_appearance.AFacemaps,other_appearance.AFacemaps

							other_appearance.AFacemaps = aFace1
							your_appearance.AFacemaps = aFace2

							hg.Appearance.ForceApplyAppearance(ply, other_appearance, true)
							local char = hg.GetCurrentCharacter(ply)
							if char:IsRagdoll() then
								hg.Appearance.ForceApplyAppearance(char, other_appearance, true)
							end
							ply:EmitSound("snd_jack_hmcd_disguise.wav",35,math.random(90,110),0.5)

							--local duplicator_data = duplicator.CopyEntTable(ply)
							--duplicator.DoGeneric(aim_ent, duplicator_data)
							aim_ent.CurAppearance = your_appearance

							hg.Appearance.ForceApplyAppearance(aim_ent, your_appearance, true)
							
							if other_ply:IsPlayer() and other_ply:Alive() then
								hg.Appearance.ForceApplyAppearance(other_ply, your_appearance, true)
							end
						end
					end
					
					if(ply:KeyPressed(IN_USE))then
						local aim_ent, other_ply = MODE.GetPlayerTraceToOther(ply)
						
						if(IsValid(aim_ent))then
							if(other_ply and MODE.CanPlayerBreakOtherNeck(ply, aim_ent))then
								MODE.StartBreakingOtherNeck(ply, other_ply)
							end
						end
					elseif(ply:KeyDown(IN_USE))then
						if(ply.Ability_NeckBreak)then
							MODE.ContinueBreakingOtherNeck(ply)
						end
					end
					
					if(ply:KeyReleased(IN_USE))then
						MODE.StopBreakingOtherNeck(ply)
					end
				else
					MODE.StopBreakingOtherNeck(ply)
				end
			end
			
			if(ply.SubRole == "traitor_assasin" or ply.SubRole == "traitor_assasin_soe")then
				if(ply:KeyDown(IN_WALK))then
					if(ply:KeyPressed(IN_USE))then
						local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOther(ply, nil, MODE.DisarmReach)
						
						if(IsValid(aim_ent))then
							if(other_ply and MODE.CanPlayerDisarmOther(ply, aim_ent, MODE.DisarmReach) and MODE.CanPlayerDisarmOtherPly(ply, other_ply, MODE.DisarmReach))then
								MODE.StartDisarmingOther(ply, other_ply)
							end
						end
					elseif(ply:KeyDown(IN_USE))then
						if(ply.Ability_Disarm)then
							MODE.ContinueDisarmingOther(ply)
						end
					end
					
					if(ply:KeyReleased(IN_USE))then
						MODE.StopDisarmingOther(ply)
					end
				else
					MODE.StopDisarmingOther(ply)
				end
			end
			
			if(ply.SubRole == "traitor_zombie")then
				if(ply:KeyDown(IN_WALK))then
					
				end
			end

			if(ply.SubRole == "traitor_chemist")then
				DegradeChemicalsOfPlayer(ply)
				
				if(!ply.PassiveAbility_ChemicalAccumulation_NextNetworkTime or ply.PassiveAbility_ChemicalAccumulation_NextNetworkTime <= CurTime())then
					MODE.NetworkChemicalResistanceOfPlayer(ply)

					ply.PassiveAbility_ChemicalAccumulation_NextNetworkTime = CurTime() + 1
				end
			end
			
			if(MODE.IsArsonist(ply))then
				--; канистра наполняется сама, пока поджигатель жив
				if(ply.ArsonistFuel == nil)then
					MODE.SetArsonistFuel(ply, MODE.ArsonistFuelMax)
				end
				
				if((ply.ArsonistNextFuelRegen or 0) <= CurTime())then
					if(ply.ArsonistFuel < MODE.ArsonistFuelMax)then
						MODE.SetArsonistFuel(ply, ply.ArsonistFuel + 1)
					end
					
					ply.ArsonistNextFuelRegen = CurTime() + MODE.ArsonistFuelRegen
				end
				
				if(ply:KeyDown(IN_WALK))then
					--; ALT + E (удерживать) — льём бензин по прицелу
					if(ply:KeyDown(IN_USE))then
						if((ply.ArsonistNextSpill or 0) <= CurTime())then
							if(MODE.ArsonistSpill(ply))then
								ply.ArsonistNextSpill = CurTime() + MODE.ArsonistSpillDelay
							end
						end
					end
					
					--; ALT + R — поджечь лужу под собой или рядом
					if(ply:KeyPressed(IN_RELOAD))then
						MODE.ArsonistIgnite(ply)
					end
				else
					ply.ArsonistNextSpill = nil
				end
			end
			
			if(MODE.IsButcher(ply))then
				if(ply:KeyDown(IN_WALK))then
					if(ply:KeyPressed(IN_USE))then
						local trace = hg.eyeTrace(ply, MODE.ButcherEatReach)
						local rag = trace and trace.Entity
						
						--; жрём только настоящий труп (RagdollDeath), фейковый не трогаем
						if(IsValid(rag) and rag:IsRagdoll() and MODE.CorpseOwnerOf(rag))then
							MODE.StartButchering(ply, rag)
						end
					elseif(ply:KeyDown(IN_USE))then
						if(ply.Ability_Butcher)then
							MODE.ContinueButchering(ply)
						end
					end
					
					if(ply:KeyReleased(IN_USE))then
						MODE.StopButchering(ply)
					end
				else
					MODE.StopButchering(ply)
				end
			end
		end
	end
end)