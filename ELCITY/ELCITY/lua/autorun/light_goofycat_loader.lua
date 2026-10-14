--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/light_goofycat_loader.lua <
    > Callstack:  <
]]

player_manager.AddValidModel("Goofy Cat", "models/lightshoro_workshop/goofycat/boykisser.mdl");
player_manager.AddValidHands("Goofy Cat", "models/lightshoro_workshop/goofycat/boykisser_c.mdl", 0, "00000000");

hook.Remove("PostPlayerDraw", "Goofy Cat Eradium Add")

hook.Add("PostPlayerDraw", "Goofy Cat Eradium Add", function(ply)
    if IsValid(ply) and ply:GetModel() == "models/lightshoro_workshop/goofycat/boykisser.mdl" then
        
        local skin = ply:GetSkin()

        -- get the list of all flexes names and ids and print them
    

        if skin == 0 then
            ply:SetFlexWeight(ply:GetFlexIDByName("YouLikeKissingBoys"), 0)
            ply:SetFlexWeight(ply:GetFlexIDByName("Scare.002"), 0)
        end

        if skin == 1 then
            ply:SetFlexWeight(ply:GetFlexIDByName("YouLikeKissingBoys"), 0)
            ply:SetFlexWeight(ply:GetFlexIDByName("Scare.002"), 1)
        end

        if skin == 2 then
            ply:SetFlexWeight(ply:GetFlexIDByName("YouLikeKissingBoys"), 1)
            ply:SetFlexWeight(ply:GetFlexIDByName("Scare.002"), 0)
        end
    end
end)
