--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/homelander.lua <
    > Callstack:  <
]]

player_manager.AddValidModel("The Boys - Homelander", "models/bread/cod/characters/the_boys/homelander.mdl")
player_manager.AddValidHands("The Boys - Homelander", "models/breadarms/weapons/homelander_viewmodel.mdl", 0, "0")

list.Set("NPC", "homelander_f", {
	Name = "Homelander (Friendly)",
	Class = "npc_citizen",
	Model = "models/bread/cod/characters/the_boys/npc/homelander_f.mdl",
	KeyValues = {citizentype = 4},
	Category = "The Boys"
})

list.Set("NPC", "homelander_h", {
	Name = "Homelander (Hostile)",
	Class = "npc_combine_s",
	Model = "models/bread/cod/characters/the_boys/npc/homelander_h.mdl",
	Weapons = {"weapon_smg1", "weapon_ar2"},
	Numgrenades = "4",
	Category = "The Boys"
})
