if SERVER then AddCSLuaFile() end

SWEP.PrintName = "Head Bag"
SWEP.Category = "ZCity Other"
SWEP.Instructions = [[Мешок с верёвкой для тех, кто уже в наручниках.
LMB — поставить на колени, второй раз — надеть мешок.
RMB — снять мешок.
Пленник ничего не видит, не может драться и еле идёт. Наручники снимут — мешок спадёт сам.]]

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.HoldType = "slam"

SWEP.WorldModel = "models/balaclava_hood/balaclava_hood.mdl"
SWEP.ViewModel = ""

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_mask")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_mask"
	SWEP.BounceWeaponIcon = false
end

local REACH = 90

local BAG_MODEL = "models/balaclava_hood/balaclava_hood.mdl"
local BAG_BONE = "ValveBiped.Bip01_Head1"
local BAG_POS = Vector(-27, -5, 0)
local BAG_ANG = Angle(180, 100, 90)

--\\\\ Поза на коленях: таз вниз, ноги под себя. Углы нарочно небольшие — цель
--\\\\ ещё и держит IN_DUCK на сервере, так что перебор ломает модель.
local KNEEL_LAYER = "kneel"
local knee_bones = {
	{ "ValveBiped.Bip01_Pelvis", Vector(0, 0, -14), Angle(0, 0, 0) },
	{ "ValveBiped.Bip01_L_Thigh", Vector(0, 0, 0), Angle(0, -70, 0) },
	{ "ValveBiped.Bip01_R_Thigh", Vector(0, 0, 0), Angle(0, -70, 0) },
	{ "ValveBiped.Bip01_L_Calf", Vector(0, 0, 0), Angle(0, 70, 0) },
	{ "ValveBiped.Bip01_R_Calf", Vector(0, 0, 0), Angle(0, 70, 0) },
}

local headbagmodels = {}

--; цель — только живой игрок в наручниках: без наручников мешок не держится
function SWEP:GetTarget()
	local ply = self:GetOwner()
	if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() then return end

	local trace = hg.eyeTrace(ply, REACH)
	if !trace then return end

	local ent = trace.Entity
	if !IsValid(ent) then return end

	local target = ent:IsPlayer() and ent or hg.RagdollOwner(ent)

	if !IsValid(target) or !target:IsPlayer() or !target:Alive() then return end
	if !target:GetNetVar("handcuffed", false) then return end

	return target
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.6)

	if !SERVER then return end

	local ply = self:GetOwner()
	local target = self:GetTarget()

	if !IsValid(target) then
		if IsValid(ply) and ply:IsPlayer() then ply:ChatPrint("Нужен живой игрок в наручниках.") end
		return
	end

	if !target:GetNWBool("kneel", false) then
		target:SetNWBool("kneel", true)
		target:EmitSound("physics/flesh/flesh_impact_hard1.wav", 60, math.random(80, 95), 0.6)
		ply:ChatPrint(target:Name() .. " поставлен на колени.")
		return
	end

	target:SetNWBool("headbag", true)
	target:EmitSound("snd_jack_hmcd_disguise.wav", 60, math.random(95, 110), 0.8)
	ply:ChatPrint("Мешок надет на " .. target:Name() .. ".")
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.6)

	if !SERVER then return end

	local ply = self:GetOwner()
	local target = self:GetTarget()

	if !IsValid(target) then return end

	target:SetNWBool("headbag", false)
	target:EmitSound("snd_jack_hmcd_disguise.wav", 60, math.random(95, 110), 0.8)
	ply:ChatPrint("Мешок снят с " .. target:Name() .. ".")
end

--\\\\ Рендер мешка и позы на коленях для всех игроков: вызывается из
--\\\\ lua/homigrad/fake/sh_render.lua рядом с hg.CuffedAnim.
function hg.HeadbagAnim(ent, ply)
	if !IsValid(ent) or !IsValid(ply) then return end

	local id = ply:EntIndex()
	local kneeling = ply:GetNWBool("kneel", false)
	local bagged = ply:GetNWBool("headbag", false)

	if !kneeling and !bagged then
		--; флаги сняли — убираем модель, чтобы не висела у чужой головы
		local stale = headbagmodels[id]
		if IsValid(stale) then
			stale:Remove()
			headbagmodels[id] = nil
		end

		return
	end

	if kneeling then
		for _, bone in ipairs(knee_bones) do
			hg.bone.Set(ent, bone[1], bone[2], bone[3], KNEEL_LAYER, 0.15)
		end
	end

	if !bagged then return end

	local boneid = ent:LookupBone(BAG_BONE)
	if !boneid then return end

	local mat = ent:GetBoneMatrix(boneid)
	if !mat then return end

	local model = headbagmodels[id]

	if !IsValid(model) then
		model = ClientsideModel(BAG_MODEL)
		if !IsValid(model) then return end

		model:SetNoDraw(true)
		headbagmodels[id] = model
	end

	local pos, ang = LocalToWorld(BAG_POS, BAG_ANG, mat:GetTranslation(), mat:GetAngles())

	model:SetPos(pos)
	model:SetAngles(ang)
	model:SetRenderOrigin(pos)
	model:SetRenderAngles(ang)
	model:SetupBones()
	model:DrawModel()
end

if SERVER then
	--; на коленях: присед, без прыжков, шаг в пол-силы
	hook.Add("StartCommand", "hg_headbag_kneel", function(ply, cmd)
		if !ply:GetNWBool("kneel", false) then return end

		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))
		cmd:RemoveKey(IN_JUMP)
		cmd:SetForwardMove(cmd:GetForwardMove() * 0.45)
		cmd:SetSideMove(cmd:GetSideMove() * 0.45)
	end)

	--; связанному нечем драться
	hook.Add("PlayerBindPress", "hg_headbag_binds", function(ply, bind, pressed)
		if !pressed then return end
		if !ply:GetNWBool("headbag", false) and !ply:GetNWBool("kneel", false) then return end

		if bind == "+attack" or bind == "+attack2" or bind == "+reload" or bind == "+use" then return true end
	end)

	--; наручники сняли — мешок и колени держаться больше не могут
	hook.Add("PlayerPostThink", "hg_headbag_clear", function(ply)
		if !ply:GetNWBool("headbag", false) and !ply:GetNWBool("kneel", false) then return end
		if ply:GetNetVar("handcuffed", false) then return end

		ply:SetNWBool("headbag", false)
		ply:SetNWBool("kneel", false)
	end)

	hook.Add("PlayerDeath", "hg_headbag_death", function(ply)
		ply:SetNWBool("headbag", false)
		ply:SetNWBool("kneel", false)
	end)
else
	--; свои глаза завязаны — экран чёрный, пока мешок на голове
	hook.Add("HUDPaint", "zzz_headbag_blind", function()
		local ply = LocalPlayer()
		if !IsValid(ply) or !ply:GetNWBool("headbag", false) then return end

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, ScrW(), ScrH())

		surface.SetFont("DermaDefault")
		surface.SetTextColor(170, 170, 170, 255)
		surface.SetTextPos(ScrW() / 2 - 55, ScrH() * 0.72)
		surface.DrawText("Мешок на голове")
	end)

	hook.Add("HUDShouldDraw", "hg_headbag_hud", function(name)
		local ply = LocalPlayer()
		if !IsValid(ply) or !ply:GetNWBool("headbag", false) then return end

		if name == "CHudCrosshair" or name == "CHudWeaponSelection" or name == "CHudAmmo" then return false end
	end)
end
