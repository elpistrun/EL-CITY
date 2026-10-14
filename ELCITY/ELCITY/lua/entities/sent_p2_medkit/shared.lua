-- "lua\\entities\\sent_p2_medkit\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Medkit"
ENT.Author = "Lenoax-Nahuel-BSH"
ENT.Contact = "Steam"
ENT.Purpose = "It heals you"
ENT.Instructions = "E" 
ENT.Category = "Postal 2"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

function ENT:SetupModel()

	self.Entity:SetModel("models/Postal2/CrackPipe.mdl")
	
end