HGSurrender = HGSurrender or {}
local S = HGSurrender
S.Version = "2.0"
S.WorkshopID = "3702088753"

S.SurrVariants = {
	{ "G_Surrender",  "g_surrenderloopArms",  "G_Surrenderend"  },
	{ "G_Surrender2", "g_surrenderloopArms2", "G_Surrenderend2" },
	{ "G_Surrender3", "g_surrenderloopArms3", "G_Surrenderend3" },
}
S.KneelVariants = {
	{ "kneeldown",  "kneeldownloop",  "kneeldownEND"  },
	{ "kneeldown2", "kneeldown2loop", "kneeldown2END" },
	{ "kneeldown3", "kneeldown3loop", "kneeldown3end" },
}

S.KneelHBHTransitions = {
	[1] = { "kneeldownTransition",  "kneeldownTransitionBack"  },
	[2] = { "kneeldown2Transition", "kneeldown2TransitionBack" },
}

S.HBHVariant = 3
S.SurrRandomMax = 2

S.Timing = {
	SurrBegin    = 0.8,
	SurrLoop     = 1.8,
	SurrExit     = 0.6,
	KneelBegin   = 1.3,
	KneelLoop    = 1.8,
	KneelExit    = 1.3,
	HBHSwap      = 0.5,
	HBHKneelSwap = 0.39,

	SurrFadeIn   = 0.12,
	SurrFadeOut  = 0.25,
	KneelFadeIn  = 0.20,
	KneelFadeOut = 0.45,
}
S.Cooldown = {
	Surrender = 4.0,
	Kneel     = 2.0,
	Stand     = 1.5,
	HBH       = 1.2,
}

S.PHASE_BEGIN   = 1
S.PHASE_LOOP    = 2
S.PHASE_END     = 3
S.PHASE_HBH_IN  = 4
S.PHASE_HBH_OUT = 5

S.SurrSlot   = GESTURE_SLOT_ATTACK_AND_RELOAD
S.KneelSlot  = GESTURE_SLOT_CUSTOM
S.HandsClass = "weapon_hands_sh"

S.UnarmedClasses = {
	[S.HandsClass]          = true,
	["weapon_hg_coolhands"] = true,
	["weapon_zombclaws"]    = true,
}

S.ArmedGrace     = 1.5
S.ArmedTolerance = 1.5

S.ActIn  = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
S.ActOut = ACT_GMOD_GESTURE_ITEM_PLACE

if SERVER then
	S.MinTimeCVar = CreateConVar(
		"surrender_min_time",
		"5",
		{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },
		"Сколько секунд нужно продержаться в сдаче, прежде чем опустить руки.",
		0,
		300
	)

	S.ViewClampCVar = CreateConVar(
		"surrender_view_clamp",
		"20",
		{ FCVAR_REPLICATED, FCVAR_ARCHIVE },
		"На сколько градусов стоящий на коленях может повернуть голову в сторону.",
		0,
		180
	)
end

function S.GetMinTime()
	local cvar = GetConVar("surrender_min_time")
	return cvar and cvar:GetFloat() or 5
end

function S.GetViewClamp()
	local cvar = GetConVar("surrender_view_clamp")
	return cvar and cvar:GetFloat() or 20
end

function S.IsUnarmedWeapon(wep)
	if not IsValid(wep) then return true end
	if S.UnarmedClasses[wep:GetClass()] then return true end

	return isfunction(wep.GetFists)
end

function S.IsArmed(ply)
	if not IsValid(ply) then return false end

	return not S.IsUnarmedWeapon(ply:GetActiveWeapon())
end

function S.GetHands(ply)
	if not IsValid(ply) then return end

	local hands = ply:GetWeapon(S.HandsClass)
	if IsValid(hands) then return hands end

	for _, wep in ipairs(ply:GetWeapons()) do
		if S.IsUnarmedWeapon(wep) then return wep end
	end
end

function S.CanHolster(ply)
	return IsValid(S.GetHands(ply))
end

function S.PlayGesture(ent, slot, seqName, fallbackAct)
	if not IsValid(ent) or not seqName then return end

	local seq = ent:LookupSequence(seqName)

	if seq and seq > 0 then
		ent:AddVCDSequenceToGestureSlot(slot, seq, 0, false)
	else
		ent:AnimRestartGesture(slot, fallbackAct, false)
	end
end

local layer = {}

local function LayerWeight(ent, slot)
	local slots = layer[ent]
	local blend = slots and slots[slot]
	return blend and blend.weight or 0
end

local function LayerTo(ent, slot, from, to, duration, onDone)
	if not IsValid(ent) then return end

	local slots = layer[ent]

	if not slots then
		slots = {}
		layer[ent] = slots
	end

	slots[slot] = {
		weight = from,
		target = to,
		speed  = duration > 0 and (1 / duration) or 0,
		onDone = onDone,
	}

	ent:AnimSetGestureWeight(slot, from)
end

local function ResetSlot(ent, slot)
	if IsValid(ent) then ent:AnimResetGestureSlot(slot) end
end

local function SlotTimer(index, slot)
	return "hg_surrender_slotclear_" .. slot .. "_" .. index
end

hook.Add("Think", "hg_surrender_blend", function()
	if not next(layer) then return end
	local ft = FrameTime()

	for ent, slots in pairs(layer) do
		if not IsValid(ent) then
			layer[ent] = nil
			continue
		end

		local keep = false

		for slot, blend in pairs(slots) do
			if blend.weight ~= blend.target then
				blend.weight = blend.speed > 0
					and math.Approach(blend.weight, blend.target, blend.speed * ft)
					or blend.target

				ent:AnimSetGestureWeight(slot, blend.weight)

				if blend.weight == blend.target and blend.onDone then
					local done = blend.onDone
					blend.onDone = nil
					done(ent, slot)
				end
			end

			if blend.weight <= 0 and blend.target <= 0 then
				slots[slot] = nil
			else
				keep = true
			end
		end

		if not keep then layer[ent] = nil end
	end
end)

local function PlayLayered(ent, slot, seqName, ending, fadeIn, fadeOut, holdTime)
	if not IsValid(ent) or not seqName then return end

	local timerName = SlotTimer(ent:EntIndex(), slot)
	timer.Remove(timerName)

	S.PlayGesture(ent, slot, seqName, ending and S.ActOut or S.ActIn)

	if ending then
		if LayerWeight(ent, slot) < 1 then
			LayerTo(ent, slot, LayerWeight(ent, slot), 1, fadeIn)
		end

		timer.Create(timerName, math.max(0, holdTime - fadeOut), 1, function()
			if not IsValid(ent) then return end
			LayerTo(ent, slot, LayerWeight(ent, slot), 0, fadeOut, ResetSlot)
		end)
		return
	end

	if LayerWeight(ent, slot) >= 1 then
		LayerTo(ent, slot, 1, 1, 0)
	else
		LayerTo(ent, slot, LayerWeight(ent, slot), 1, fadeIn)
	end
end

function S.PlaySurr(ent, variant, phase)
	local set = S.SurrVariants[variant]
	if not set or not set[phase] or not IsValid(ent) then return end

	local T = S.Timing

	PlayLayered(ent, S.SurrSlot, set[phase], phase == S.PHASE_END,
		T.SurrFadeIn, T.SurrFadeOut, T.SurrExit)
end

function S.PlayKneel(ent, variant, phase)
	if not IsValid(ent) then return end

	local seqName, ending

	if phase == S.PHASE_HBH_IN or phase == S.PHASE_HBH_OUT then
		local set = S.KneelHBHTransitions[variant]
		if not set then return end
		seqName = set[phase == S.PHASE_HBH_IN and 1 or 2]
	else
		local set = S.KneelVariants[variant]
		if not set then return end
		seqName = set[phase]
		ending  = phase == S.PHASE_END
	end

	local T = S.Timing

	PlayLayered(ent, S.KneelSlot, seqName, ending,
		T.KneelFadeIn, T.KneelFadeOut, T.KneelExit)
end

function S.ForgetGestures(ent)
	if not ent or not layer[ent] then return end

	layer[ent] = nil

	local index = ent:EntIndex()
	timer.Remove(SlotTimer(index, S.SurrSlot))
	timer.Remove(SlotTimer(index, S.KneelSlot))
end

function S.ResetGestures(ent)
	if not IsValid(ent) then return end

	S.ForgetGestures(ent)
	ent:AnimResetGestureSlot(S.SurrSlot)
	ent:AnimResetGestureSlot(S.KneelSlot)
end

hook.Add("EntityRemoved", "hg_surrender_forget_gestures", S.ForgetGestures)
