-- "lua\\entities\\ladder_small3\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if (SERVER) then
	AddCSLuaFile();
end;

ENT.Type 			= "anim";
ENT.Base 			= "ladder_base";
ENT.PrintName		= "Ladder (Small - Runged)"
ENT.Category		= "Ladders"
ENT.Spawnable		= true
ENT.AdminOnly		= false
ENT.Model			= Model("models/props/cs_militia/ladderrung.mdl");
ENT.RenderGroup 	= RENDERGROUP_BOTH;