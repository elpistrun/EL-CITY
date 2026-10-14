--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/entities/mc_tnt/shared.lua <
    > Callstack: lua/entities/mc_tnt/cl_init.lua:2 <
]]


ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "TNT"
ENT.Author			= "Dj Lukis.LT"
ENT.Information		= "Highly explosive block o' dynamite!"
ENT.Category		= "Minecraft"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true
ENT.timer				= 0
ENT.ignited				= 0
ENT.health				= 0

cleanup.Register("mc_tnts")

