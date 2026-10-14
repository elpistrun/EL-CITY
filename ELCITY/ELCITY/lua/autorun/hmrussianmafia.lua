-- "lua\\autorun\\hmrussianmafia.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
player_manager.AddValidModel( "Russian Mafia 02", "models/hotlinemiami/russianmafia/mafia02pm.mdl" )
player_manager.AddValidModel( "Russian Mafia 04", "models/hotlinemiami/russianmafia/mafia04pm.mdl" )
player_manager.AddValidModel( "Russian Mafia 06", "models/hotlinemiami/russianmafia/mafia06pm.mdl" )
player_manager.AddValidModel( "Russian Mafia 07", "models/hotlinemiami/russianmafia/mafia07pm.mdl" )
player_manager.AddValidModel( "Russian Mafia 08", "models/hotlinemiami/russianmafia/mafia08pm.mdl" )
player_manager.AddValidModel( "Russian Mafia 09", "models/hotlinemiami/russianmafia/mafia09pm.mdl" )

local models = {
	russianmafia_models = {
		"models/hotlinemiami/russianmafia/mafia02b.mdl",
		"models/hotlinemiami/russianmafia/mafia04b.mdl",
		"models/hotlinemiami/russianmafia/mafia06b.mdl",
		"models/hotlinemiami/russianmafia/mafia07b.mdl",
		"models/hotlinemiami/russianmafia/mafia08b.mdl",
		"models/hotlinemiami/russianmafia/mafia09b.mdl",
	}
}
local nextName
local tbNPCs = {}
hook.Add("PlayerSpawnNPC", "russianmafiabSpawnGetName", function(ply, name) nextName = name end)

hook.Add("PlayerSpawnedNPC", "russianmafiabSpawnSetRandomModel", function(ply, npc)
	if (!nextName) then return end
	if (tbNPCs[nextName]) then
			local min, max = npc:GetCollisionBounds()
			local hull = npc:GetHullType()
			if (nextName == "Russian Mafia (Hostile)") then
				npc:SetModel(table.Random(models.russianmafia_models))
			end
		npc:SetSolid(SOLID_BBOX)
		npc:SetHullType(hull)
		npc:SetHullSizeNormal()
		npc:SetCollisionBounds(min,max)
		npc:DropToFloor()
		end
	nextName = nil
end)

local function AddNPC(category, name, class, model, keyvalues, weapons, spawnflags)
		list.Set("NPC",name,{Name = name,Class = class,Model = model,Category = category,KeyValues = keyvalues,Weapons = weapons, SpawnFlags = spawnflags})
		tbNPCs[name] = model
end

AddNPC("Russian Mafia", "Russian Mafia (Hostile)", "npc_metropolice", "models/hotlinemiami/russianmafia/mafia02b.mdl", {citizentype = CT_UNIQUE, SquadName = "combine"}, {"weapon_stunstick","weapon_pistol","weapon_smg1"})

--good bois
local models = {
	russianmafia_modelsg = {
		"models/hotlinemiami/russianmafia/mafia02.mdl",
		"models/hotlinemiami/russianmafia/mafia04.mdl",
		"models/hotlinemiami/russianmafia/mafia06.mdl",
		"models/hotlinemiami/russianmafia/mafia07.mdl",
		"models/hotlinemiami/russianmafia/mafia08.mdl",
		"models/hotlinemiami/russianmafia/mafia09.mdl",
	}
}
local nextName
local tbNPCs = {}
hook.Add("PlayerSpawnNPC", "russianmafiaSpawnGetName", function(ply, name) nextName = name end)

hook.Add("PlayerSpawnedNPC", "russianmafiaSpawnSetRandomModel", function(ply, npc)
	if (!nextName) then return end
	if (tbNPCs[nextName]) then
			local min, max = npc:GetCollisionBounds()
			local hull = npc:GetHullType()
			if (nextName == "Russian Mafia (Friendly)") then
				npc:SetModel(table.Random(models.russianmafia_modelsg))
			end
		npc:SetSolid(SOLID_BBOX)
		npc:SetHullType(hull)
		npc:SetHullSizeNormal()
		npc:SetCollisionBounds(min,max)
		npc:DropToFloor()
		end
	nextName = nil
end)

local function AddNPC(category, name, class, model, keyvalues, weapons, spawnflags)
		list.Set("NPC",name,{Name = name,Class = class,Model = model,Category = category,KeyValues = keyvalues,Weapons = weapons, SpawnFlags = spawnflags})
		tbNPCs[name] = model
end

AddNPC("Russian Mafia", "Russian Mafia (Friendly)", "npc_citizen", "models/hotlinemiami/russianmafia/mafia02.mdl", {citizentype = CT_UNIQUE, SquadName = "ru"}, {"weapon_crowbar","weapon_pistol","weapon_smg1"})


















