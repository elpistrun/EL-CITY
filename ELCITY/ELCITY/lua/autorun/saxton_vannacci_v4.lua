--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: lua/autorun/saxton_vannacci_v4.lua <
    > Callstack:  <
]]

-- Saxton Vannacci V4: native player, citizen NPCs and ragdoll registrations.
if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("autorun/client/saxton_vannacci_v4_firstperson.lua")
end

local name = "Saxton Vannacci V4"
local playerModel = "models/player/aarmy/saxton_vannacci_v4.mdl"
local npcModel = "models/player/aarmy/saxton_vannacci_v4_npc.mdl"
local handsModel = "models/weapons/aarmy/c_arms_saxton_vannacci_v4.mdl"

player_manager.AddValidModel(name, playerModel)
player_manager.AddValidHands(name, handsModel, 0, "00000000")
list.Set("PlayerOptionsModel", name, playerModel)

list.Set("NPC", "saxton_vannacci_v4_friendly", {
    Name = "Saxton Vannacci - Friendly",
    IconOverride = "entities/saxton_vannacci_v4_friendly.png",
    Class = "npc_citizen",
    Model = npcModel,
    Health = "300",
    Category = name,
    KeyValues = { citizentype = 4, SquadName = "resistance" },
    Weapons = { "weapon_smg1", "weapon_pistol", "weapon_shotgun", "weapon_ar2" }
})

-- Hostile is the native citizen-reskin option used by GMod's own NPC registry.
list.Set("NPC", "saxton_vannacci_v4_hostile", {
    Name = "Saxton Vannacci - Ostile",
    IconOverride = "entities/saxton_vannacci_v4_hostile.png",
    Class = "npc_citizen",
    Model = npcModel,
    Health = "300",
    Category = name,
    KeyValues = { citizentype = 4, SquadName = "overwatch", Hostile = "1" },
    Weapons = { "weapon_smg1", "weapon_pistol", "weapon_shotgun", "weapon_ar2" }
})

if CLIENT then
    list.Set("ContentCategoryIcons", name, "icon16/user_suit.png")
    hook.Add("PopulatePropMenu", "SaxtonVannacciV4_Ragdoll", function()
        spawnmenu.AddPropCategory("saxton_vannacci_v4", name, {
            { type = "header", text = "Saxton Vannacci - Ragdoll" },
            { type = "model", model = playerModel }
        }, "icon16/user_suit.png")
    end)
end

