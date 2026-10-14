-- "lua\\entities\\outlast_ai\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ENT.Base = "base_entity" 
ENT.Type = "ai"
 
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
 
ENT.AutomaticFrameAdvance = true
 
function ENT:OnRemove()
end

function ENT:PhysicsCollide(data, physobj)
end

function ENT:PhysicsUpdate(physobj)
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end