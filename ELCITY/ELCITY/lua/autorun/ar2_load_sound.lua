--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/ar2_load_sound.lua <
    > Callstack:  <
]]

AddCSLuaFile();
if (SERVER) then 
	sound.Add( {
		name = "Weapon_AR2.Single",
		channel = 1,
		volume = 1,
		level = SNDLVL_GUNFIRE,
		pitch = {95, 105},
		sound = "weapons/ar2/fire1.wav"
	} )
	sound.Add( {
		name = "Weapon_IRifle.Single",
		channel = 1,
		volume = 1,
		level = SNDLVL_GUNFIRE,
		sound = "weapons/irifle/irifle_fire2.wav"
	} )
	sound.Add( {
		name = "NPC_CombineBall.Explosion",
		channel = 6,
		volume = 1,
		level = 95,
		pitch = {95, 105},
		sound = "weapons/physcannon/energy_sing_explosion2.wav"
	} )
end
