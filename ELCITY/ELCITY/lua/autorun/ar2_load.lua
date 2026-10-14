--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/ar2_load.lua <
    > Callstack:  <
]]

AddCSLuaFile();
PrecacheParticleSystem("batsy_ar2")
PrecacheParticleSystem("batsy_ar2_npc")
PrecacheParticleSystem("batsy_ar2_cell")
PrecacheParticleSystem("batsy_ar2_cell_pop")
PrecacheParticleSystem("batsy_ar2_vent")
PrecacheParticleSystem("batsy_ar2_alt")
PrecacheParticleSystem("batsy_ar2_altfire")

if (CLIENT) then 
	game.AddParticles( "particles/batsy_ar2.pcf" )
end
if (SERVER) then 
	game.AddParticles( "particles/batsy_ar2.pcf" )
end
