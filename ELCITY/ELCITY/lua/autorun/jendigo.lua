--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/jendigo.lua <
    > Callstack:  <
]]

--[[
       _            _                              _       
      | |          | |                            | |      
      | | __ _  ___| | ____ _ _ __ _   _ _ __   __| | __ _ 
  _   | |/ _` |/ __| |/ / _` | '__| | | | '_ \ / _` |/ _` |
 | |__| | (_| | (__|   < (_| | |  | |_| | | | | (_| | (_| |
  \____/ \__,_|\___|_|\_\__,_|_|   \__,_|_| |_|\__,_|\__,_| 2023

     _       _                 _                  ____              _       
    / \   __| |_   _____ _ __ | |_ _   _ _ __ ___| __ )  ___   ___ | |_ ___ 
   / _ \ / _` \ \ / / _ \ '_ \| __| | | | '__/ _ \  _ \ / _ \ / _ \| __/ __|
  / ___ \ (_| |\ V /  __/ | | | |_| |_| | | |  __/ |_) | (_) | (_) | |_\__ \
 /_/   \_\__,_| \_/ \___|_| |_|\__|\__,_|_|  \___|____/ \___/ \___/ \__|___/ 2025

--]]

AddCSLuaFile()

if (SERVER) then
	THE_ANCIENT_WENDIGO = THE_ANCIENT_WENDIGO or nil
	local ItsHere = false--IsValid(THE_ANCIENT_WENDIGO)
	
	-- Array of trigger phrases
	local TriggerPhrases = {
		"it's here",
		"its here",
		"wendigo",
		"skin walker",
		"skinwalker",
		"bloxwich",
		"was that"
	}

	hook.Add("PlayerSay", "Jendigo_PlayerSay", function(ply, txt)
		if (txt and not ItsHere) then
			local lowerText = string.lower(txt)
			
			-- Check if any trigger phrase is found in the message
			for _, phrase in ipairs(TriggerPhrases) do
				if string.find(lowerText, string.lower(phrase), 1, true) then
					for k, v in pairs(player.GetAll()) do
						if IsValid(v) and v:Alive() then
							v:EmitSound("jendigo/scream" .. math.random(1, 2) .. ".wav", 90, math.random(90, 110))
						end
					end
					ItsHere = true
					break
				end
			end
		end
	end)

	local NextThink = 100
	hook.Add("Think", "Jendigo_Think", function()
		if not(ItsHere) then return end
		local Time = CurTime()
		if (NextThink > Time) then return end
		NextThink = Time + 100

		if (IsValid(THE_ANCIENT_WENDIGO)) then
			SafeRemoveEntity(THE_ANCIENT_WENDIGO)
		end
		THE_ANCIENT_WENDIGO = ents.Create("jendigo")
		THE_ANCIENT_WENDIGO:SetPos(Vector(0, 0, 0))
		THE_ANCIENT_WENDIGO:SetAngles(Angle(0, 0, 0))
		THE_ANCIENT_WENDIGO:Spawn()
		THE_ANCIENT_WENDIGO:Activate()
	end)

	--[[hook.Add("JMod_ShouldAttack", "Jendigo_agressive", function(self, ent, vehiclesOnly, peaceWasNeverAnOption)
		if IsValid(THE_ANCIENT_WENDIGO) and ent == THE_ANCIENT_WENDIGO then
			return math.random(1, 10000) == 1
		end
	end)--]]
end

