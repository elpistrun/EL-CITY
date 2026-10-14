-- "lua\\entities\\npc_chris_walker\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ENT.Base = "outlast_ai" 
ENT.Type = "ai"
 
ENT.PrintName		= "Chris Walker"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
 
ENT.AutomaticFrameAdvance = true

if CLIENT then
	language.Add("npc_chris_walker", "Chris Walker")
	killicon.Add("default", "HUD/killicons/default", Color(255, 80, 0, 255))
end