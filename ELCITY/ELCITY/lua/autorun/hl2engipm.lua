--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/hl2engipm.lua <
    > Callstack:  <
]]

--Add Playermodel
player_manager.AddValidModel( "worker_04", "models/worker_04/worker_04.mdl" )
player_manager.AddValidHands( "worker_04", "models/worker_04/c_worker_arms.mdl", 0, "00000000" )


-- Add a client side hook that changes the skin of the players hands to their player model skin

-- I've only added this as a workaround as player_manager.AddValidHands doesn't work for multiple skins

-- so it'd always set the skin of the hands to 0 rather than their selected skin

hook.Add("PreDrawPlayerHands", "PlayerModelPreDrawPlayerHands", function(hands, vm, ply, weapon)

-- Get the players current model, we don't want to mess with other player models, just my own

if ply:GetModel() == "models/gman_spy/spy_04.mdl" then

if hands:GetModel() == "models/gman_spy/c_spy_arms.mdl" then

local hs = hands:GetSkin()

local ps = ply:GetSkin()

-- When the players skin has changed, usually via the player model selector

-- we need to change the skin used by the hands too, so they match.

if hs != ps then

hands:SetSkin(ps)

end

end

end

end)



