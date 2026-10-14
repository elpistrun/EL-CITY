-- sorry for messy code, even tho its not

local S = HGSurrender
if not S then
	ErrorNoHalt("[ZCITY / Surrender] lua/autorun/hg_surrender_shared.lua is missing - the addon is not installed correctly.\n")
	return
end
util.AddNetworkString("hg_surrender_anim")
util.AddNetworkString("hg_surrender_state")
util.AddNetworkString("hg_surrender_voice")
util.AddNetworkString("hg_surrender_force_exit")
util.AddNetworkString("hg_kneel_anim")
util.AddNetworkString("hg_kneel_state")
util.AddNetworkString("hg_surrender_hull")

local T = S.Timing

local enforceWeapons = CreateConVar(
	"surrender_enforce_weapons",
	"1",
	{ FCVAR_ARCHIVE, FCVAR_NOTIFY },
	"Забирать оружие у сдавшегося и снимать флаг сдачи, если он снова вооружился."
)

local ARMED_TOLERANCE = S.ArmedTolerance
local ARMED_GRACE     = S.ArmedGrace

local loadContent = CreateConVar(
	"surrender_loadcontent",
	"1",
	{ FCVAR_ARCHIVE, FCVAR_NOTIFY },
	"Отправлять клиентам контент анимаций сдачи через resource.AddWorkshop (нужен перезапуск сервера)"
)
if loadContent:GetBool() then
	resource.AddWorkshop(S.WorkshopID)
end

local surrendering  = {}
local kneeling      = {}
local kneelGrace    = {}
local kneelAnchor   = {}
local netThrottle   = {}
local lastEnter     = {}
local armedSince    = {}
local savedHull     = {}

local MAX_PHASE = 5

local HULL_PAD   = 2
local HULL_MIN_Z = 24
local HULL_LIMIT = 40

local function HullTimer(ply)
	return "hg_surrender_hullfit_" .. ply:EntIndex()
end

local function PoseBounds(ply)
	if ply.InvalidateBoneCache then ply:InvalidateBoneCache() end

	local count = ply:GetHitBoxCount(0)
	if not count or count < 1 then return end

	local mins, maxs

	for i = 0, count - 1 do
		local bone = ply:GetHitBoxBone(i, 0)
		if not bone then continue end

		local bmins, bmaxs = ply:GetHitBoxBounds(i, 0)
		if not bmins or not bmaxs then continue end

		local bpos, bang
		local matrix = ply:GetBoneMatrix(bone)

		if matrix then
			bpos, bang = matrix:GetTranslation(), matrix:GetAngles()
		else
			bpos, bang = ply:GetBonePosition(bone)
		end

		if not bpos then continue end

		for corner = 0, 7 do
			local point = LocalToWorld(Vector(
				bit.band(corner, 1) == 0 and bmins.x or bmaxs.x,
				bit.band(corner, 2) == 0 and bmins.y or bmaxs.y,
				bit.band(corner, 4) == 0 and bmins.z or bmaxs.z
			), angle_zero, bpos, bang)

			if not mins then
				mins = Vector(point)
				maxs = Vector(point)
				continue
			end

			mins.x = math.min(mins.x, point.x)
			mins.y = math.min(mins.y, point.y)
			mins.z = math.min(mins.z, point.z)
			maxs.x = math.max(maxs.x, point.x)
			maxs.y = math.max(maxs.y, point.y)
			maxs.z = math.max(maxs.z, point.z)
		end
	end

	return mins, maxs
end

local function SendHull(ply, hmins, hmaxs, dmins, dmaxs)
	net.Start("hg_surrender_hull")
		net.WriteEntity(ply)
		net.WriteVector(hmins)
		net.WriteVector(hmaxs)
		net.WriteVector(dmins)
		net.WriteVector(dmaxs)
	net.Broadcast()
end

local function StoreHull(ply)
	if savedHull[ply] then return savedHull[ply] end

	local hmins, hmaxs = ply:GetHull()
	local dmins, dmaxs = ply:GetHullDuck()

	savedHull[ply] = { Vector(hmins), Vector(hmaxs), Vector(dmins), Vector(dmaxs) }

	return savedHull[ply]
end

local function DropHull(ply, restore)
	timer.Remove(HullTimer(ply))

	local saved = savedHull[ply]
	if not saved then return end

	savedHull[ply] = nil

	SendHull(ply, saved[1], saved[2], saved[3], saved[4])
	if not restore then return end

	ply:SetHull(saved[1], saved[2])
	ply:SetHullDuck(saved[3], saved[4])
end

local function FitPoseHull(ply)
	if not IsValid(ply) or not ply:Alive() then return end

	local mins, maxs = PoseBounds(ply)
	if not mins then return end

	local pos = ply:GetPos()

	if maxs.z - mins.z < 20 then return end
	if math.abs(mins.x - pos.x) > 64 or math.abs(mins.y - pos.y) > 64 then return end

	local saved = StoreHull(ply)

	local hullMins = Vector(
		math.Clamp(mins.x - pos.x - HULL_PAD, -HULL_LIMIT, HULL_LIMIT - 8),
		math.Clamp(mins.y - pos.y - HULL_PAD, -HULL_LIMIT, HULL_LIMIT - 8),
		0
	)
	local hullMaxs = Vector(
		math.Clamp(maxs.x - pos.x + HULL_PAD, hullMins.x + 4, HULL_LIMIT),
		math.Clamp(maxs.y - pos.y + HULL_PAD, hullMins.y + 4, HULL_LIMIT),
		math.max(maxs.z - pos.z + HULL_PAD, HULL_MIN_Z)
	)

	local tr = util.TraceHull({
		start  = pos,
		endpos = pos,
		mins   = hullMins,
		maxs   = hullMaxs,
		mask   = MASK_PLAYERSOLID,
		filter = ply,
	})

	if tr.StartSolid then
		hullMins.x, hullMins.y = saved[1].x, saved[1].y
		hullMaxs.x, hullMaxs.y = saved[2].x, saved[2].y
	end

	ply:SetHull(hullMins, hullMaxs)
	ply:SetHullDuck(hullMins, hullMaxs)

	SendHull(ply, hullMins, hullMaxs, hullMins, hullMaxs)
end

local function ScheduleHullFit(ply, delay)
	timer.Create(HullTimer(ply), delay, 1, function()
		if IsValid(ply) and kneeling[ply] then FitPoseHull(ply) end
	end)
end

local function Throttle(ply, key, delay)
	local bucket = netThrottle[ply]
	if not bucket then
		bucket = {}
		netThrottle[ply] = bucket
	end
	local now = CurTime()
	if (bucket[key] or 0) > now then return false end
	bucket[key] = now + delay
	return true
end

local function ClearState(ply)
	if not IsValid(ply) then return end

	timer.Remove("hg_surrender_delayexit_" .. ply:EntIndex())

	DropHull(ply, ply:Alive() and not IsValid(ply.FakeRagdoll))

	surrendering[ply] = nil
	kneeling[ply]     = nil
	kneelGrace[ply]   = nil
	kneelAnchor[ply]  = nil
	netThrottle[ply]  = nil
	armedSince[ply]   = nil
	lastEnter[ply]    = nil

	ply.Kneeling = false
	ply:SetNWBool("Kneeling", false)
	ply:SetNWBool("Surrendering", false)

	S.ResetGestures(ply)
end

local function Relay(name, ply, variant, phase)
	net.Start(name)
		net.WriteEntity(ply)
		net.WriteUInt(variant, 4)
		net.WriteUInt(phase, 3)
	net.SendOmit(ply)
end

net.Receive("hg_surrender_anim", function(_, ply)
	local variant = net.ReadUInt(4)
	local phase   = net.ReadUInt(3)
	if not IsValid(ply) or not ply:Alive() then return end
	if variant < 1 or variant > #S.SurrVariants then return end
	if phase < 1 or phase > MAX_PHASE then return end

	local key   = phase == S.PHASE_LOOP and "surr_loop" or "surr_step"
	local delay = phase == S.PHASE_LOOP and T.SurrLoop * 0.5 or 0.2

	if not Throttle(ply, key, delay) then return end

	S.PlaySurr(ply, variant, phase)
	Relay("hg_surrender_anim", ply, variant, phase)
end)

net.Receive("hg_kneel_anim", function(_, ply)
	local variant = net.ReadUInt(4)
	local phase   = net.ReadUInt(3)

	if not IsValid(ply) or not ply:Alive() then return end
	if variant < 1 or variant > #S.KneelVariants then return end
	if phase < 1 or phase > MAX_PHASE then return end

	local key   = phase == S.PHASE_LOOP and "kneel_loop" or "kneel_step"
	local delay = phase == S.PHASE_LOOP and T.KneelLoop * 0.5 or 0.2

	if not Throttle(ply, key, delay) then return end

	S.PlayKneel(ply, variant, phase)
	Relay("hg_kneel_anim", ply, variant, phase)

	if phase == S.PHASE_LOOP and kneeling[ply] then FitPoseHull(ply) end
end)

net.Receive("hg_surrender_voice", function(_, ply)
	local muffled = net.ReadBool()
	local pitch   = net.ReadUInt(8)
	local phrase  = net.ReadString()

	if not IsValid(ply) or not ply:Alive() then return end
	if not surrendering[ply] then return end
	if not Throttle(ply, "voice", 2) then return end

	if not string.match(phrase, "^vo/[%w_/]+%.wav$") then return end

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	ent:EmitSound(phrase, muffled and 75 or 85, math.Clamp(pitch, 50, 255), 1, CHAN_AUTO, 0, muffled and 14 or 0)
end)

local function FinishSurrenderExit(ply)
	if not IsValid(ply) then return end
	surrendering[ply] = nil
	armedSince[ply]   = nil
	ply:SetNWBool("Surrendering", false)
end

net.Receive("hg_surrender_state", function(_, ply)
	local active = net.ReadBool()
	if not IsValid(ply) then return end
	if not Throttle(ply, "surr_state", 0.2) then return end

	local timerName = "hg_surrender_delayexit_" .. ply:EntIndex()

	if active then
		if not ply:Alive() then return end

		if CurTime() < (lastEnter[ply] or 0) + S.Cooldown.Surrender then return end

		lastEnter[ply] = CurTime()

		timer.Remove(timerName)
		surrendering[ply] = CurTime()
		armedSince[ply]   = nil
		ply:SetNWBool("Surrendering", true)

		if enforceWeapons:GetBool() and S.IsArmed(ply) and hg and hg.drop then
			hg.drop(ply)
		end

		return
	end

	local started = surrendering[ply]

	if not started then
		FinishSurrenderExit(ply)
		return
	end
	local earliest = started + S.GetMinTime()

	if CurTime() < earliest - 0.5 then
		timer.Create(timerName, earliest - CurTime(), 1, function()
			FinishSurrenderExit(ply)
		end)
		return
	end

	timer.Remove(timerName)
	FinishSurrenderExit(ply)
end)

net.Receive("hg_kneel_state", function(_, ply)
	local active = net.ReadBool()
	if not IsValid(ply) then return end
	if not Throttle(ply, "kneel_state", 0.2) then return end

	if active then
		if not ply:Alive() then return end

		if not kneeling[ply] then
			ScheduleHullFit(ply, T.KneelBegin + 0.1)
		end

		kneeling[ply]    = true
		kneelGrace[ply]  = CurTime() + 1.5
		kneelAnchor[ply] = ply:GetPos()

		ply.Kneeling = true
		ply:SetNWBool("Kneeling", true)
	else

		if kneeling[ply] then
			kneelGrace[ply] = CurTime() + T.KneelExit
		end

		kneeling[ply]    = nil
		kneelAnchor[ply] = nil

		DropHull(ply, true)

		ply.Kneeling = false
		ply:SetNWBool("Kneeling", false)
	end
end)

timer.Create("hg_surrender_armedcheck", 0.5, 0, function()
	if not enforceWeapons:GetBool() then return end

	for ply, started in pairs(surrendering) do
		if not IsValid(ply) then
			surrendering[ply] = nil
			continue
		end
		if not S.IsArmed(ply) then
			armedSince[ply] = nil
			continue
		end

		local hands = S.GetHands(ply)

		if not IsValid(hands) then
			armedSince[ply] = nil
			continue
		end

		if CurTime() < started + S.GetMinTime() then
			ply:SelectWeapon(hands:GetClass())
		end

		if CurTime() - started < ARMED_GRACE then continue end

		armedSince[ply] = armedSince[ply] or CurTime()

		if CurTime() - armedSince[ply] < ARMED_TOLERANCE then continue end

		timer.Remove("hg_surrender_delayexit_" .. ply:EntIndex())
		FinishSurrenderExit(ply)

		net.Start("hg_surrender_force_exit")
			net.WriteBool(false)
		net.Send(ply)
	end
end)

-- hi

local BLOCKED_MOVE = IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT + IN_JUMP

hook.Add("SetupMove", "hg_kneel_movelock_sv", function(ply, mv)
	if not kneeling[ply] and (kneelGrace[ply] or 0) <= CurTime() then return end

	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)
	mv:SetUpSpeed(0)
	mv:SetVelocity(Vector(0, 0, mv:GetVelocity().z))
	mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(BLOCKED_MOVE)))
end)
hook.Add("FinishMove", "hg_kneel_poslock_sv", function(ply)
	local anchor = kneelAnchor[ply]
	if not anchor then return end

	local pos = ply:GetPos()
	if pos.x == anchor.x and pos.y == anchor.y then return end

	ply:SetPos(Vector(anchor.x, anchor.y, pos.z))
end)

hook.Add("PlayerDisconnected", "hg_surrender_cleanup_leave", ClearState)

hook.Add("PlayerDeath",        "hg_surrender_cleanup_death",  ClearState)
hook.Add("PlayerSpawn",        "hg_surrender_cleanup_spawn",  ClearState)
hook.Add("Fake",               "hg_surrender_cleanup_ragdoll", ClearState)

local function ClearEveryone()
	for _, ply in ipairs(player.GetAll()) do
		ClearState(ply)
	end

	net.Start("hg_surrender_force_exit")
		net.WriteBool(true)
	net.Broadcast()
end

hook.Add("ZB_PreRoundStart", "hg_surrender_roundreset", ClearEveryone)
hook.Add("ZB_StartRound",    "hg_surrender_roundstart", ClearEveryone)
hook.Add("PlayerRunConCommand", "hg_surrender_blockcmds", function(ply, cmd)
	if not IsValid(ply) then return end
	if cmd == "fake" and (surrendering[ply] or kneeling[ply]) then return true end
	if cmd == "hg_kick" and kneeling[ply] then return true end
end)

print("[ZCITY / Surrender] v" .. S.Version .. " loaded. Made by adodser! c:")
