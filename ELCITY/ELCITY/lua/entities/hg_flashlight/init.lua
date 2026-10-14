AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)
	self:SetModelScale(0.75)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:OnRemove()
end

function ENT:Use(activator)
	if not IsValid(activator) or (self.UseCD or 0) > CurTime() then return end
	self.UseCD = CurTime() + 0.5

	self:TakeByPlayer(activator)
end

function ENT:Think()
end

function ENT:TakeByPlayer(activator)
	if IsValid(activator) and activator:IsPlayer() then-- and not table.HasValue(activator.inventory.Attachments, self.name) then
		activator.inventory = activator:GetNetVar("Inventory") or activator.inventory
		if not istable(activator.inventory) or not istable(activator.inventory["Weapons"]) then return end

		activator.inventory["Weapons"]["hg_flashlight"] = true
		activator:SetNetVar("Inventory",activator.inventory)
		activator:SetNetVar("flashlight",self:GetNetVar("enabled"))
		activator:ViewPunch(AngleRand(-1, 1))
		self:EmitSound("snd_jack_tinyequip.wav", 65, math.random(95, 105), 1, CHAN_ITEM)
		self:Remove()
	end
end