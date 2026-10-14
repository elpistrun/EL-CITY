-- "lua\\entities\\ladder_small2\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if (SERVER) then
	AddCSLuaFile();
end;

ENT.Type 			= "anim";
ENT.Base 			= "ladder_base";
ENT.PrintName		= "Ladder (Small - Attached)"
ENT.Category		= "Ladders"
ENT.Spawnable		= true
ENT.AdminOnly		= false
ENT.Model			= Model("models/props_c17/metalladder002.mdl");
ENT.RenderGroup 	= RENDERGROUP_BOTH;