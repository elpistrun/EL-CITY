-- why are you in my code, hi

local S = HGSurrender
if not S then
	ErrorNoHalt("[ZCITY / Surrender] lua/autorun/hg_surrender_shared.lua is missing - the addon is not installed correctly.\n")
	return
end
local T      = S.Timing
local CD     = S.Cooldown
local HBH    = S.HBHVariant

local inSurrender    = false
local inKneel        = false
local kneelExiting   = false
local kneelReady     = false
local handsBehind    = false
local transitioning  = false

local surrVariant    = 1
local prevVariant    = 1
local kneelVariant   = 1

local surrenderStart = 0
local kneelBaseYaw   = 0

local queuedExit     = false
local autoExiting    = false
local nextForceHands = 0
local armedSince     = 0

local serverAcked    = false
local ackDeadline    = 0

local nextSurrender  = 0
local nextKneel      = 0
local nextStand      = 0
local nextHBH        = 0

local EnterSurrender, ExitSurrender
local EnterKneel, ExitKneel
local EnterHandsBehind, ExitHandsBehind
local StartSurrenderLoop, StartKneelLoop
local RequestStandUp, RequestStopSurrender, AutoExit, ResetAll

local function ShowText()
	local cvar = GetConVar("surrender_text")
	return cvar and cvar:GetBool()
end

local function PlayVoice()
	local cvar = GetConVar("surrender_voicel")
	return cvar and cvar:GetBool()
end

local function Notify(msg)
	if not ShowText() then return end
	chat.AddText(color_white, msg)
end

local function CanAct()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return false end
	if ply.organism and ply.organism.otrub then return false end
	if hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(ply) ~= ply then return false end
	return true
end

local function Foley(ply)
	if (ply.NextFoley or 0) > CurTime() then return end
	ply.NextFoley = CurTime() + 2.5
	ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
end

local function HoldRemaining()
	if not inSurrender then return 0 end
	return math.max(0, (surrenderStart + S.GetMinTime()) - CurTime())
end

local IsArmed = S.IsArmed

local remoteKneeling = {}

net.Receive("hg_surrender_anim", function()
	local ent     = net.ReadEntity()
	local variant = net.ReadUInt(4)
	local phase   = net.ReadUInt(3)

	if not IsValid(ent) or ent == LocalPlayer() then return end

	S.PlaySurr(ent, variant, phase)

	if phase == S.PHASE_BEGIN then
		timer.Simple(T.SurrBegin, function()
			if IsValid(ent) then S.PlaySurr(ent, variant, S.PHASE_LOOP) end
		end)
	end
end)
net.Receive("hg_kneel_anim", function()
	local ent     = net.ReadEntity()
	local variant = net.ReadUInt(4)
	local phase   = net.ReadUInt(3)

	if not IsValid(ent) or ent == LocalPlayer() then return end

	if phase == S.PHASE_BEGIN then
		remoteKneeling[ent] = variant
		S.PlayKneel(ent, variant, S.PHASE_BEGIN)

		timer.Simple(T.KneelBegin, function()
			if IsValid(ent) and remoteKneeling[ent] then
				S.PlayKneel(ent, remoteKneeling[ent], S.PHASE_LOOP)
			end
		end)
		return
	end

	if phase == S.PHASE_END then
		remoteKneeling[ent] = nil
	elseif phase == S.PHASE_LOOP then
		remoteKneeling[ent] = variant
	end

	S.PlayKneel(ent, variant, phase)
end)

hook.Add("EntityRemoved", "hg_surrender_forget_remote", function(ent)
	remoteKneeling[ent] = nil
end)

net.Receive("hg_surrender_hull", function()
	local ent   = net.ReadEntity()
	local hmins = net.ReadVector()
	local hmaxs = net.ReadVector()
	local dmins = net.ReadVector()
	local dmaxs = net.ReadVector()

	if not IsValid(ent) or not ent.SetHull then return end

	ent:SetHull(hmins, hmaxs)
	ent:SetHullDuck(dmins, dmaxs)
end)

local function SendSurrAnim(variant, phase)
	net.Start("hg_surrender_anim")
		net.WriteUInt(variant, 4)
		net.WriteUInt(phase, 3)
	net.SendToServer()
end

local function SendKneelAnim(variant, phase)
	net.Start("hg_kneel_anim")
		net.WriteUInt(variant, 4)
		net.WriteUInt(phase, 3)
	net.SendToServer()
end

local function SendSurrState(active)
	net.Start("hg_surrender_state")
		net.WriteBool(active)
	net.SendToServer()
end
local function SendKneelState(active)
	net.Start("hg_kneel_state")
		net.WriteBool(active)
	net.SendToServer()
end

local SCARED_LINES = {
	"vo/episode_1/npc/male01/cit_evac_casualty10.wav",
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/startle01.wav",
	"vo/npc/male01/startle02.wav",
	"vo/episode_1/npc/male01/cit_alert_head06.wav",
	"vo/episode_1/npc/male01/cit_buddykilled04.wav",
	"vo/episode_1/npc/male01/cit_evac_casualty09.wav",
}

local function SendScaredLine(ply)
	if not PlayVoice() then return end

	local phrase = SCARED_LINES[math.random(#SCARED_LINES)]

	if isfunction(ThatPlyIsFemale) and ThatPlyIsFemale(ply) then
		phrase = string.Replace(phrase, "male01", "female01")
	end

	net.Start("hg_surrender_voice")
		net.WriteBool(ply.armors and ply.armors["face"] == "mask2" or false)
		net.WriteUInt(math.Clamp(math.floor(ply.VoicePitch or 100), 0, 255), 8)
		net.WriteString(phrase)
	net.SendToServer()
end

function StartSurrenderLoop()
	if not inSurrender then return end

	S.PlaySurr(LocalPlayer(), surrVariant, S.PHASE_LOOP)

	timer.Create("hg_surrender_loop", T.SurrLoop, 0, function()
		if not inSurrender or not IsValid(LocalPlayer()) then
			timer.Remove("hg_surrender_loop")
			return
		end

		if transitioning then return end

		S.PlaySurr(LocalPlayer(), surrVariant, S.PHASE_LOOP)
		SendSurrAnim(surrVariant, S.PHASE_LOOP)
	end)
end
function EnterSurrender()
	if inSurrender or not CanAct() then return end

	local ply = LocalPlayer()

	surrVariant    = math.random(S.SurrRandomMax)
	prevVariant    = surrVariant
	inSurrender    = true
	handsBehind    = false
	transitioning  = false
	queuedExit     = false
	autoExiting    = false
	armedSince     = 0
	surrenderStart = CurTime()
	serverAcked    = false
	ackDeadline    = CurTime() + 3

	S.PlaySurr(ply, surrVariant, S.PHASE_BEGIN)
	SendSurrAnim(surrVariant, S.PHASE_BEGIN)
	SendSurrState(true)

	SendScaredLine(ply)
	Foley(ply)
	Notify("You raise your hands.")

	timer.Create("hg_surrender_begin", T.SurrBegin, 1, StartSurrenderLoop)
end

function ExitSurrender(silent)
	if not inSurrender then return end

	inSurrender   = false
	handsBehind   = false
	transitioning = false
	queuedExit    = false
	armedSince    = 0

	timer.Remove("hg_surrender_loop")
	timer.Remove("hg_surrender_begin")
	timer.Remove("hg_surrender_hbh")

	S.PlaySurr(LocalPlayer(), surrVariant, S.PHASE_END)
	SendSurrAnim(surrVariant, S.PHASE_END)
	SendSurrState(false)

	nextSurrender = CurTime() + CD.Surrender
	surrVariant   = 1
	prevVariant   = 1

	if not silent then Notify("You lower your hands.") end
end

function StartKneelLoop()
	if not inKneel then return end

	S.PlayKneel(LocalPlayer(), kneelVariant, S.PHASE_LOOP)

	timer.Create("hg_kneel_loop", T.KneelLoop, 0, function()
		if not inKneel or not IsValid(LocalPlayer()) then
			timer.Remove("hg_kneel_loop")
			return
		end

		if transitioning then return end

		S.PlayKneel(LocalPlayer(), kneelVariant, S.PHASE_LOOP)
		SendKneelAnim(kneelVariant, S.PHASE_LOOP)
	end)
end
function EnterKneel()
	if inKneel or kneelExiting or not CanAct() then return end
	if CurTime() < nextKneel or CurTime() < nextStand then return end

	local ply = LocalPlayer()

	kneelVariant = surrVariant
	inKneel      = true
	kneelExiting = false
	kneelReady   = false
	kneelBaseYaw = ply:EyeAngles().y
	nextKneel    = CurTime() + CD.Kneel

	S.PlayKneel(ply, kneelVariant, S.PHASE_BEGIN)
	SendKneelAnim(kneelVariant, S.PHASE_BEGIN)
	SendKneelState(true)

	Foley(ply)
	Notify("You kneel down.")

	timer.Create("hg_kneel_begin", T.KneelBegin, 1, function()
		if not inKneel or not IsValid(LocalPlayer()) then return end

		kneelReady = true
		StartKneelLoop()

		SendKneelState(true)

		if inSurrender then
			S.PlaySurr(LocalPlayer(), surrVariant, S.PHASE_LOOP)
		end
	end)
end

function ExitKneel(silent)
	if not inKneel then return end

	inKneel      = false
	kneelReady   = false
	kneelExiting = true
	nextKneel    = CurTime() + CD.Kneel
	nextStand    = CurTime() + CD.Stand

	timer.Remove("hg_kneel_loop")
	timer.Remove("hg_kneel_begin")

	S.PlayKneel(LocalPlayer(), kneelVariant, S.PHASE_END)
	SendKneelAnim(kneelVariant, S.PHASE_END)
	SendKneelState(false)

	Foley(LocalPlayer())

	timer.Create("hg_kneel_exit", T.KneelExit, 1, function()
		kneelExiting = false
		if silent then return end

		Notify(inSurrender and "You stand back up, hands still raised." or "You stand back up.")
	end)

	kneelVariant = 1
end

local function BeginHBHSwap(fromVI, toVI, onDone)
	local ply = LocalPlayer()

	transitioning = true
	nextHBH       = CurTime() + CD.HBH

	timer.Remove("hg_surrender_loop")
	timer.Remove("hg_kneel_loop")
	timer.Remove("hg_surrender_hbh")
	local function finish()
		transitioning = false

		if not inSurrender or not IsValid(LocalPlayer()) then return end

		surrVariant = toVI
		if onDone then onDone() end
		StartSurrenderLoop()
	end
	if inKneel then

		local entering = toVI == HBH
		local baseVI   = entering and fromVI or toVI

		S.PlayKneel(ply, baseVI, entering and S.PHASE_HBH_IN or S.PHASE_HBH_OUT)
		SendKneelAnim(baseVI, entering and S.PHASE_HBH_IN or S.PHASE_HBH_OUT)

		S.PlaySurr(ply, toVI, S.PHASE_BEGIN)
		SendSurrAnim(toVI, S.PHASE_BEGIN)

		timer.Create("hg_surrender_hbh", T.HBHKneelSwap, 1, function()
			if not inSurrender or not IsValid(LocalPlayer()) then
				transitioning = false
				return
			end

			kneelVariant = toVI
			StartKneelLoop()
			SendKneelAnim(kneelVariant, S.PHASE_LOOP)
			finish()
		end)
		return
	end

	S.PlaySurr(ply, fromVI, S.PHASE_END)
	SendSurrAnim(fromVI, S.PHASE_END)

	timer.Create("hg_surrender_hbh", T.HBHSwap, 1, function()
		if not inSurrender or not IsValid(LocalPlayer()) then
			transitioning = false
			return
		end

		S.PlaySurr(LocalPlayer(), toVI, S.PHASE_BEGIN)
		SendSurrAnim(toVI, S.PHASE_BEGIN)

		timer.Create("hg_surrender_hbh", T.SurrBegin, 1, finish)
	end)
end

function EnterHandsBehind()
	if not inSurrender or handsBehind or transitioning then return end
	if CurTime() < nextHBH then return end
	if inKneel and not kneelReady then return end
	prevVariant = surrVariant

	BeginHBHSwap(surrVariant, HBH, function()
		handsBehind = true
		Notify("You put your hands behind your head.")
	end)
end

function ExitHandsBehind()
	if not inSurrender or not handsBehind or transitioning then return end
	if CurTime() < nextHBH then return end
	if inKneel and not kneelReady then return end

	BeginHBHSwap(HBH, prevVariant, function()
		handsBehind = false
		Notify("You raise your hands back up.")
	end)
end

function RequestStandUp()
	if not inKneel or kneelExiting or transitioning then return end

	if not kneelReady then return end

	ExitKneel(false)
end

function RequestStopSurrender()
	if not (inSurrender or inKneel) then return end
	if transitioning or kneelExiting then return end

	local left = HoldRemaining()
	if left > 0 then
		Notify(string.format("You cannot lower your hands yet (%is).", math.ceil(left)))
		return
	end
	if inKneel then
		if not kneelReady then return end
		ExitKneel(true)
		if inSurrender then
			timer.Simple(T.KneelExit, function() ExitSurrender(false) end)
		end
	else
		ExitSurrender(false)
	end
end

function AutoExit()
	if autoExiting then return end
	autoExiting = true

	Notify("You lower your hands to reach for your weapon.")
	if inKneel then
		ExitKneel(true)

		timer.Simple(T.KneelExit * 0.6, function()
			ExitSurrender(true)
			timer.Simple(T.SurrExit, function() autoExiting = false end)
		end)
	else
		ExitSurrender(true)
		timer.Simple(T.SurrExit, function() autoExiting = false end)
	end
end

net.Receive("hg_surrender_force_exit", function()
	local hard = net.ReadBool()

	if hard then
		ResetAll()
		return
	end

	if not (inSurrender or inKneel) then return end
	AutoExit()
end)

local BLOCKED_MOVE = IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT + IN_JUMP

hook.Add("SetupMove", "hg_kneel_movelock", function(ply, mv)
	if ply ~= LocalPlayer() then return end
	if not (inKneel or kneelExiting) then return end

	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)
	mv:SetUpSpeed(0)
	mv:SetVelocity(Vector(0, 0, mv:GetVelocity().z))
	mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(BLOCKED_MOVE)))
end)

hook.Add("CreateMove", "hg_kneel_viewlimit", function(cmd)
	if not inKneel then return end
	local clamp = S.GetViewClamp()
	if clamp >= 180 then return end
	local ang = cmd:GetViewAngles()
	ang.y = kneelBaseYaw + math.Clamp(math.NormalizeAngle(ang.y - kneelBaseYaw), -clamp, clamp)
	ang.p = math.Clamp(ang.p, -100, 100)
	cmd:SetViewAngles(ang)
end)

local function ForceHands(ply)
	if CurTime() < nextForceHands then return end

	local hands = S.GetHands(ply)
	if not IsValid(hands) or ply:GetActiveWeapon() == hands then return end
	nextForceHands = CurTime() + 0.25

	input.SelectWeapon(hands)
	RunConsoleCommand("use", hands:GetClass())
end

hook.Add("Think", "hg_surrender_weaponwatch", function()
	if not (inSurrender or inKneel) then
		queuedExit  = false
		autoExiting = false
		armedSince  = 0
		return
	end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	if inSurrender and not autoExiting then
		if ply:GetNWBool("Surrendering", false) then
			serverAcked = true
		elseif serverAcked or CurTime() > ackDeadline then

			if inKneel then SendKneelAnim(kneelVariant, S.PHASE_END) end
			SendSurrAnim(surrVariant, S.PHASE_END)

			ResetAll()
			return
		end
	end

	if not ply:Alive() or (hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(ply) ~= ply) then
		ResetAll()
		return
	end

	if not inSurrender then return end

	if not IsArmed(ply) or not S.CanHolster(ply) then
		armedSince = 0

		if queuedExit then
			queuedExit = false
			Notify("Your hands are empty again.")
		end

		return
	end

	local left = HoldRemaining()

	if armedSince == 0 then armedSince = CurTime() end
	if left > 0 then ForceHands(ply) end

	if CurTime() - surrenderStart < S.ArmedGrace then return end
	if CurTime() - armedSince < S.ArmedTolerance then return end

	if left > 0 then
		if not queuedExit then
			queuedExit = true
			Notify(string.format("You are still holding a weapon - your hands come down in %is.", math.ceil(left)))
		end

		return
	end

	AutoExit()
end)

hook.Add("PlayerSwitchWeapon", "hg_surrender_lockweapon", function(ply, old, new)
	if ply ~= LocalPlayer() then return end
	if not (inSurrender or inKneel) then return end
	if HoldRemaining() <= 0 then return end
	if S.IsUnarmedWeapon(new) then return end
	ForceHands(ply)
	return true
end)
hook.Add("CreateMove", "hg_surrender_inputlock", function(cmd)
	if not (inSurrender or inKneel) then return end
	if HoldRemaining() <= 0 then return end
	cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_USE + IN_ATTACK + IN_ATTACK2)))
	cmd:SetImpulse(0)
end)

hook.Add("PlayerBindPress", "hg_surrender_bindlock", function(ply, bind, pressed)
	if ply ~= LocalPlayer() then return end
	if not (inSurrender or inKneel) then return end
	bind = string.lower(bind)

	if string.find(bind, "+attack", 1, true) then
		if pressed and not vgui.CursorVisible() and not gui.IsGameUIVisible() then
			RequestStopSurrender()
		end
		return true
	end

	if inKneel and string.find(bind, "hg_kick", 1, true) then return true end
	if string.find(bind, "fake", 1, true) then return true end
end)

hook.Add("radialOptions", "hg_surrender_option", function()
	if not hg or not hg.radialOptions then return end
	if not CanAct() then return end

	local opts = hg.radialOptions

	if kneelExiting then
		opts[#opts + 1] = { function() return -1 end, "Getting Up..." }
		return
	end

	if transitioning then
		opts[#opts + 1] = { function() return -1 end, "..." }
		return
	end

	if inSurrender or inKneel then
		local left  = HoldRemaining()
		local title

		if inKneel then
			title = handsBehind and "Kneeling + Hands Behind Head" or "Kneeling + Hands Up"
		else
			title = handsBehind and "Surrendering (Hands Behind Head)" or "Surrendering"
		end

		title = title .. (left > 0 and string.format("\nHold for %is", math.ceil(left)) or "\nRMB - Options")

		opts[#opts + 1] = {
			function(mouseClick)
				if mouseClick ~= 2 then

					if inKneel then
						RequestStandUp()
					else
						RequestStopSurrender()
					end
					return
				end

				if not hg.CreateRadialMenu then return -1 end

				local sub = {}

				if inKneel then
					sub[#sub + 1] = { function() RequestStandUp() end, "Stand Up" }

					if inSurrender then
						sub[#sub + 1] = { function() RequestStopSurrender() end, "Stop Surrendering" }
					end
				else
					sub[#sub + 1] = { function() RequestStopSurrender() end, "Stop Surrendering" }
					sub[#sub + 1] = { function() EnterKneel() end,           "Kneel Down" }
				end

				if handsBehind then
					sub[#sub + 1] = { function() ExitHandsBehind() end, "Hands Up (normal)" }
				else
					sub[#sub + 1] = { function() EnterHandsBehind() end, "Hands Behind Head" }
				end

				hg.CreateRadialMenu(sub)
				return -1
			end,
			title,
		}

		return
	end

	opts[#opts + 1] = {
		function(mouseClick)
			if CurTime() < nextSurrender or CurTime() < nextStand then return -1 end
			nextSurrender = CurTime() + CD.Surrender

			local ply     = LocalPlayer()
			local alsoKneel = mouseClick == 2

			if IsArmed(ply) then RunConsoleCommand("dropweapon") end

			timer.Simple(0.15, function()
				if not CanAct() then return end

				EnterSurrender()
				if alsoKneel then
					timer.Simple(0.25, function()
						if inSurrender then EnterKneel() end
					end)
				end
			end)
		end,
		"Surrender\nRMB - Kneel+Surrender",
	}
end)

function ResetAll(ply)
	if IsValid(ply) and ply ~= LocalPlayer() then return end

	timer.Remove("hg_surrender_loop")
	timer.Remove("hg_surrender_begin")
	timer.Remove("hg_surrender_hbh")
	timer.Remove("hg_kneel_loop")
	timer.Remove("hg_kneel_begin")
	timer.Remove("hg_kneel_exit")

	local lp = LocalPlayer()

	S.ResetGestures(lp)

	local wasActive = inSurrender or inKneel

	inSurrender   = false
	inKneel       = false
	kneelExiting  = false
	kneelReady    = false
	handsBehind   = false
	transitioning = false
	queuedExit    = false
	autoExiting   = false
	armedSince    = 0

	surrVariant   = 1
	prevVariant   = 1
	kneelVariant  = 1
	kneelBaseYaw  = 0
	nextKneel     = 0
	nextStand     = 0
	nextHBH       = 0
	serverAcked   = false
	ackDeadline   = 0

	if wasActive then
		SendKneelState(false)
		SendSurrState(false)
	end
end

hook.Add("HG_OnOtrub", "hg_surrender_reset_otrub",   ResetAll)
hook.Add("Fake",       "hg_surrender_reset_ragdoll", ResetAll)
gameevent.Listen("player_spawn")

hook.Add("player_spawn", "hg_surrender_reset_spawn", function(data)
	local ply = Player(data.userid)
	if IsValid(ply) and ply == LocalPlayer() then ResetAll() end
end)

concommand.Add("surrender_toggle", function()
	if not CanAct() then return end

	if inSurrender then
		RequestStopSurrender()
		return
	end

	if CurTime() < nextSurrender then return end
	nextSurrender = CurTime() + CD.Surrender

	if IsArmed(LocalPlayer()) then RunConsoleCommand("dropweapon") end

	timer.Simple(0.15, function()
		if CanAct() then EnterSurrender() end
	end)
end)

concommand.Add("kneel_toggle", function()
	if not CanAct() or kneelExiting then return end

	if inKneel then
		RequestStandUp()
		return
	end

	if inSurrender then
		EnterKneel()
		return
	end
	if CurTime() < nextSurrender or CurTime() < nextStand then return end
	nextSurrender = CurTime() + CD.Surrender

	if IsArmed(LocalPlayer()) then RunConsoleCommand("dropweapon") end

	timer.Simple(0.15, function()
		if not CanAct() then return end

		EnterSurrender()
		timer.Simple(0.25, function()
			if inSurrender then EnterKneel() end
		end)
	end)
end)

concommand.Add("surrender_handsbehindhead", function()
	if not CanAct() or not inSurrender then return end

	if handsBehind then
		ExitHandsBehind()
	else
		EnterHandsBehind()
	end
end)
