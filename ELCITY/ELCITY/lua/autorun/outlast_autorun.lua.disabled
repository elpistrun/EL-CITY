-- "lua\\autorun\\outlast_autorun.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if SERVER then
	require("soundscripts")
	require("tconvars")
	
	soundscripts.AddSoundscript("NPC_Chris_Walker.Footstep", {"npc/chris_walker/footstep1.wav", "npc/chris_walker/footstep2.wav", "npc/chris_walker/footstep3.wav", "npc/chris_walker/footstep4.wav", "npc/chris_walker/footstep5.wav", "npc/chris_walker/footstep6.wav", "npc/chris_walker/footstep7.wav", "npc/chris_walker/footstep8.wav"})

	tconvars.AddHealthConVar("sk_chris_walker_health", "7500", "npc_chris_walker")
	tconvars.AddDamageConVar("sk_chris_walker_dmg_punch", "35", "npc_chris_walker")
end

CreateConVar("chris_walker_always_fatality", "0")
CreateConVar("chris_walker_doorbash_enable", "1")
CreateConVar("chris_walker_enemy_maxhealth", "400", FCVAR_NONE, "Sets a limit on the HP the enemy can have in order to be grabbed", 0, nil)
CreateConVar("chris_walker_fatality_enable", "1")
CreateConVar("chris_walker_gib_model", "models/gibs/humans/heart_gib.mdl")
CreateConVar("chris_walker_grab_nonbiped", "1")
CreateConVar("chris_walker_music_enable", "1")
CreateConVar("chris_walker_vault_enable", "1")
CreateConVar("chris_walker_view_dsitance", "1000", FCVAR_NONE, "", 0, nil)
