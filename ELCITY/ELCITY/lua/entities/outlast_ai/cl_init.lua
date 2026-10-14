-- "lua\\entities\\outlast_ai\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DrawModel()
end

net.Receive("outlast_death_force", function()
	local ragdoll = net.ReadEntity():BecomeRagdollOnClient()
	local root = ragdoll:GetPhysicsObjectNum(0)
	root:SetVelocity(net.ReadVector() / 10)
	ragdoll:SetNoDraw(false)
end)

net.Receive("outlast_death_force", function()
	local ent = net.ReadEntity()
	if IsValid(ent) then
		local ragdoll = ent:BecomeRagdollOnClient()
		ragdoll:SetNoDraw(false)
		ragdoll:DrawShadow(true)
	end
end)