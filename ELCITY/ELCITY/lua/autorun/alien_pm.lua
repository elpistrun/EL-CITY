--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/alien_pm.lua <
    > Callstack:  <
]]

player_manager.AddValidModel( "Alien", "models/electric/alien_pm.mdl" )
player_manager.AddValidHands( "Alien", "models/weapons/alien_carms.mdl", 0, "00000000" )

hook.Add("PreDrawPlayerHands", "(alien_carms.mdl)", function(hands, vm, ply, wpn)
if IsValid(hands) and hands:GetModel() == "models/weapons/alien_carms.mdl" then

hands:SetSkin(ply:GetSkin())
end

end)

list.Set("NPC", "npc_alien_f", {
	Name = "Alien (Friendly)",
	Class = "npc_citizen",
	Model = "models/electric/alien_f_npc.mdl",
	KeyValues = {citizentype = 4},
	Category = "Alien"
})

list.Set("NPC", "npc_alien_h", {
	Name = "Alien (Hostile)",
	Class = "npc_combine_s",
	Model = "models/electric/alien_h_npc.mdl",
	Weapons = {"weapon_smg1", "weapon_ar2"},
	Numgrenades = "4",
	Category = "Alien"
})
