-- "lua\\autorun\\creepergirl_pm.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--copied from tda hatsune miku v2

--Add Playermodel
list.Set( "PlayerOptionsModel", "Creeper Girl", "models/player/creepergirl/sour_creepergirl_player.mdl" )
player_manager.AddValidModel( "Creeper Girl", "models/player/creepergirl/sour_creepergirl_player.mdl" )
player_manager.AddValidHands( "Creeper Girl", "models/weapons/c_arms_creepergirl.mdl", 0, "0000000" )

--Add NPC
local NPC = { 	Name = "Creeper Girl", 
				Class = "npc_citizen",
				Weapons = { "weapon_smg1" },
				Model = "models/player/creepergirl/sour_creepergirl_npc.mdl",
				Health = "400",
				KeyValues = { citizentype = 4 },
                                Category = "Minecraft"    }

list.Set( "NPC", "npc_creepergirl", NPC )

-- https://steamcommunity.com/sharedfiles/filedetails/?id=609478456
-- Send this to clients automatically so server hosts don't have to
if SERVER then
	resource.AddWorkshop("609478456")
end