-- "lua\\tempmod\\sh_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()

local meta = FindMetaTable("Entity")

function meta:IsTemperatureAvaiable()
    return self:GetClass() == "prop_physics"
end

function meta:GetTemperature()
    return self:GetNW2Int("Temperature", 0)
end