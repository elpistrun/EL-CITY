--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/mappatcher/groups/ttt.lua <
    > Callstack: lua/mappatcher/groups.lua:39
lua/mappatcher/groups.lua:42
[C]:-1
lua/autorun/mappatcher.lua:87 <
]]

if not GAMEMODE_NAME == "terrortown" then return end

MapPatcher.Groups.Register("ttt_traitor", function(ply) return ply:IsTraitor() end, CLIENT and "[TTT] "..language.GetPhrase("#mappatcher.groups.ttt.traitor") )
MapPatcher.Groups.Register("ttt_detective", function(ply) return ply:IsDetective() end, CLIENT and "[TTT] "..language.GetPhrase("#mappatcher.groups.ttt.detective") ) 

