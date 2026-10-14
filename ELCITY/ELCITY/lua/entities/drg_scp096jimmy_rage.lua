-- "lua\\entities\\drg_scp096jimmy_rage.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

-- Basic Info --
ENT.PrintName = "SCP-096 (RAGE)"
ENT.Category = "SCP-096:SL Nextbot"
ENT.Models = {"models/scp_096/scp_096_final.mdl"}
ENT.ModelScale = 1
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = false
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 1
ENT.HearingCoefficient = 1
ENT.IsDrGEntity = true
ENT.IsDrGNextbot = true

-- Kill Icon --
ENT.Killicon = {
	icon = "effects/killicons/drg_scp096jimmy",
	color = Color(255, 25, 25, 155)
}
-- Sounds --
ENT.OnDamageSounds = {}
ENT.OnDeathSounds = {"jimmy096/death.wav"}
ENT.OnIdleSounds = {}

-- Stats --
ENT.SpawnHealth = 100000
ENT.HealthRegen = 150

-- AI --
ENT.Frightening = true
ENT.Omniscient = true
ENT.RangeAttackRange = 1600
ENT.MeleeAttackRange = 80
ENT.ReachEnemyRange = 80
ENT.SightRange = 0

-- Relationships --
ENT.DefaultRelationship = D_HT
ENT.Factions = {"FACTION_SCP096"}

-- Movements/animations --
ENT.ClimbLadders = true
ENT.ClimbLaddersUp = true
ENT.ClimbSpeed = 60
ENT.ClimbUpAnimation = "Jump"
ENT.WalkSpeed = 400
ENT.RunSpeed = 800
ENT.IdleAnimation = "Rage_Idle"
ENT.WalkAnimation = "Run"
ENT.WalkAnimRate = 0.75
ENT.RunAnimation = "Run"
ENT.RunAnimRate = 1
ENT.JumpAnimation = "Jump"
ENT.JumpHeight = 800
-- Detection --
ENT.EyeBone = "head"
ENT.EyeOffset = Vector(0, 0, 0)
ENT.EyeAngle = Angle(0, 0, 0)
-- Possession --
ENT.PossessionPrompt = true
ENT.PossessionEnabled = true 
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {
  {
    offset = Vector(0, 30,20),
    distance = 100
  },
  {
    offset = Vector(10.5, 0, 0),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{
		coroutine = true,
		onkeydown = function(self)
			if self:GetSequenceName(self:GetSequence())=="Swipe_1" or self:GetSequenceName(self:GetSequence())=="Swipe_2" then return end
			self:PlaySequenceAndMove("Swipe_"..tostring(math.random(1,2)),1.5,self.PossessionFaceForward)
		end
	}},
	[IN_ATTACK2] = {{
		coroutine = true,
		onkeydown = function(self)
			if self:GetSequenceName(self:GetSequence())=="Pound" then return end
			self:PlaySequenceAndMove("Pound")
		end
	}},
	[IN_RELOAD] = {{
		coroutine = true,
		onkeydown = function(self)
		if self:GetSequenceName(self:GetSequence())=="Charge" then return end
		if self.TimeTillNextCharge==nil then self.TimeTillNextCharge = CurTime() end
		
			if self.TimeTillNextCharge <= CurTime() then
			self.RunAnimation = "Charge"
			self.RunSpeed = 1000
			self.Acceleration = 950
				self:Timer(5,function()
					self.RunAnimation = "Run"
					self.RunSpeed = 800
					self.Acceleration = 700
				end)
			self.TimeTillNextCharge = CurTime()+15
			end
		end
	}},
	[IN_JUMP] = {{
		coroutine = true,
		onkeydown  = function(self)
			local jumppos=self:EyePos()+self:PossessorForward()*2000+self:PossessorUp()*50
			self:FaceTo( jumppos )
			self:Jump( jumppos )
			self:PauseCoroutine(0.2)
		end
	}}
}

if SERVER then

	local function SpawnPhysicsDoor(self,ent,m)
		if !IsValid(ent) then return end
		local model,pos,angles,skin = (IsValid(m) and m:GetModel() or ent:GetModel()),ent:GetPos()+self:GetForward()*50,(IsValid(m) and m:GetAngles() or ent:GetAngles()),ent:GetSkin()
		local velocity = math.Round(self:GetVelocity():Length())
		local forwardvel = Vector(self:GetForward().x,self:GetForward().y,self:GetForward().z)*velocity*1.5
		if IsValid(ent) then ent:Remove() end

		local propdoor = ents.Create( "prop_physics" )
		if propdoor then 
		propdoor:SetModel( model ) 
		propdoor:SetPos( pos )
		propdoor:SetAngles( angles )
		if skin!=nil then propdoor:SetSkin(skin) end
		propdoor:Spawn()
		propdoor:Activate()
							
		propdoor:EmitSound("physics/metal/metal_box_break"..math.random(1,2)..".wav")
			if IsValid(propdoor:GetPhysicsObject()) then
				propdoor:GetPhysicsObject():EnableMotion( true )
				propdoor:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				propdoor:GetPhysicsObject():AddVelocity(forwardvel)
			end	
			SafeRemoveEntityDelayed(propdoor,10)
		end	
	end
	
	local function FaceNow(self,pos)
		local angle = (pos - self:GetPos()):Angle():SnapTo( "y", 90 )
		self:SetAngles(Angle(0, angle.y, 0))
	end	
						
	local function OpenDoor(self,door,pos)
		self:CallInCoroutine(function(nextbot, delay)
			if delay>0.1 then return end
									
			local min,max = (door["Entity"]):GetModelBounds()
			local c_forward, z_min = Vector(math.Round(nextbot:GetForward().x,0),math.Round(nextbot:GetForward().y,0),0)*40, Vector(0,0,min.z)
			
			local newpos = pos-c_forward+z_min
			
			if math.abs(nextbot:GetForward().x)>=0.5 and math.abs(nextbot:GetForward().y)>=0.5 then return end
			--print(pos,nextbot:GetForward(),c_forward,min.z,newpos)
			
			FaceNow(nextbot,pos+Vector(0,0,min.z))
			nextbot:SetSpeed(0)
			nextbot:SetPos(newpos)
			nextbot:SetSpeed(0)
			FaceNow(nextbot,pos+Vector(0,0,min.z))
			door["Entity"]:EmitSound("jimmy096/dooropen.wav",80)
									
			door:Open(nil)
			for _,door1 in ipairs(ents.FindInBox(self:GetPos(),self:GetPos()+self:GetForward()*100)) do
				if door1:GetClass()=="func_door" and door1:GetInternalVariable( "m_toggle_state" )!=0 then
					door1:Fire("Open")
				end
			end
							
			nextbot:PlaySequenceAndWait("Pry",1)
			nextbot:SetPos(nextbot:GetPos()+nextbot:GetForward()*75)
		end)
	end

	function ENT:SeeCond(ent) -- if true then we don't want to run
		if !IsValid(ent) then return true end
		if !( ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() ) then return true end
		if ( ent:Health()<=0 ) or ( ent:GetModel()==self:GetModel() ) then return true end
		if (ent.IsDrGNextbot and ent:IsBlind()) then return true end
		if (self:IsPossessed() and self:GetPossessor()==ent) then return true end
		if self:IsAlly(ent) or self:IsAfraidOf(ent) then return true end
		if self:IsIgnored(ent) then return true end
	--	if util.IsInWorld(ent:GetPos())==false then return true end
		return false
	end

	function ENT:AttackFunc()
		self:Attack({
			damage = 2000,
			viewpunch = Angle(40, 0, 0),
			type = DMG_CRUSH,range=85,angle=190,
			force=Vector(1000*self:GetVelocity():Length(), 0, 120),	
		}, function(self, hit)
		
			if #hit == 0 then 
				self:EmitSound("jimmy096/swing.wav") 
				return
			else
				for k,ent in ipairs(hit) do
					if !( ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() ) then continue end
					self:EmitSound("jimmy096/kill.wav") 
					break
				end
			end	
			
		end)
	end
	
	function ENT:PoundFunc()
		self:Attack({
			damage = 500,
			viewpunch = Angle(40, 0, 0),
			type = DMG_CRUSH,range=60,angle=190,
			force=Vector(0, 0, -120),	
		}, function(self, hit)
			self:EmitSound("jimmy096/bang1.mp3") 
			util.ScreenShake( self:GetPos(), 5, 5, 1, 1000 )	
		end)
	end
	
	function ENT:ChargeFunc()
		self:Attack({
			damage = 200,
			viewpunch = Angle(40, 0, 0),
			type = DMG_CRUSH,range=20,angle=190,
			force=Vector(1000*self:GetVelocity():Length(), 0, 120),	
		}, function(self, hit)

		end)
	end

  -- Init/Think --
	function ENT:CustomInitialize()
		self.Opening=false
		self:SetModelRelationship(self:GetModel(), D_LI, 1)
		self:SetClassRelationship("npc_drg_scp682", D_FR, 1)

		self:SequenceEvent("Swipe_1",{0.3},self.AttackFunc)  	
		self:SequenceEvent("Swipe_2",{0.3},self.AttackFunc)   
		self:SequenceEvent("Docile_Walk",{0.1,0.6},function() self:EmitSound("npc/fast_zombie/foot"..math.random(1,4)..".wav") end) 
		self:SequenceEvent("Run",{0.1,0.6},function() self:EmitSound("npc/fast_zombie/foot"..math.random(1,4)..".wav") end) 
		self:SequenceEvent("Charge",{0.1,0.6},function() self:EmitSound("npc/fast_zombie/foot"..math.random(1,4)..".wav") end) 
		self:SequenceEvent("Pound",{0.1,0.25,0.42,0.6,0.75,0.9},self.PoundFunc) 

			if self.ThemeSongLoop ==nil then 	
					local filter = RecipientFilter()
					filter:AddAllPlayers()
						
					local vol =( GetConVar("scp096j_chasevolume"):GetFloat() or 1 )
				
					self.ThemeSongLoop = CreateSound(self,Sound("jimmy096/chase_theme.wav"), filter)
					self.ThemeSongLoop:SetSoundLevel(0)
					self.ThemeSongLoop:Play()
					self.ThemeSongLoop:ChangeVolume( vol,0 )
				end

				if self.ScreamSound ==nil then 
					local filter = RecipientFilter()
					filter:AddAllPlayers()
				
					local vol =( GetConVar("scp096j_screamvolume"):GetFloat() or 1 )
				
					self.ScreamSound = CreateSound(self, Sound("jimmy096/rageloop.wav"), filter)
					self.ScreamSound:SetSoundLevel( 80 )
					self.ScreamSound:Play()
					self.ScreamSound:ChangeVolume( vol,0 )
				end
		
		self:SetSightFOV(220)
		self:SetSightRange((GetConVar("drgbase_ai_radius"):GetInt()/5))	
		self.LastPos = self:GetPos()
		self.DoorOpenTime=CurTime()+5 
	end

	function ENT:OnStuck()
		if self:GetSequence()==2 then return end
		if navmesh.IsLoaded() then
			self:SetPos( navmesh.GetNearestNavArea(self.LastPos):GetClosestPointOnArea(self.LastPos) )
		else
			self:SetPos( self.LastPos )
		end	
		self:ClearStuck()
	end
	
	function ENT:UpdateAI()
		self:SetSightRange((GetConVar("drgbase_ai_radius"):GetInt()/5))
		self:UpdateHostilesSight()
		self:UpdateEnemy()
		
		if !self:IsStuck() and self:GetSequence()!=2 then
			if self:IsJumping() and self.LastPos==self:GetPos() then self:SetPos(self:GetPos()-self:GetForward()*50) end
			self.LastPos = self:GetPos()
		end
	end

	function ENT:CustomThink()
	
		if self:GetCreationTime()+GetConVar("scp096j_graceperiod"):GetFloat()>CurTime() then self:SetSpeed(0) return end
		
		if self.RunAnimation == "Charge" and self:IsRunning() and math.random(4)==4 then
					for i,ent in ipairs(ents.FindInSphere(self:GetPos(),50)) do
						if !self:SeeCond(ent) then 
							self:ChargeFunc()
						end
					end
				end
		
			for i,ent in ipairs(ents.FindInBox(self:GetPos(),self:GetPos()+self:GetForward()*(25-(self:GetSpeed()/80)))) do -- *(20-(self:GetSpeed()/80))
			
					if ent:DrG_IsDoor() then
						local door = DrGBase.WrapDoor(ent)
						local pos = (door["Entity"]):GetPos() 
						if door:GetDouble() then pos = door:GetDouble():GetPos() end
						
						if door:GetChildren()[1]!=nil then
							if string.find(door:GetChildren()[1]:GetModel(),"lcz_door")==nil and door:GetChildren()[1]:GetModel()!="models/foundation/doors/cell_door.mdl" then 
								if door:GetInternalVariable( "m_toggle_state" )==0 then continue end
								door:Open(nil)
								continue
							end
						end
						
						if (door["Entity"]):GetClass()=="func_door" then
							if GetConVar("scp096j_opendoors"):GetInt()==1 and self.RunAnimation != "Charge" then
								if ( door:GetInternalVariable( "m_toggle_state" )!=0 and door:GetVelocity():Length()<=0 ) then
									OpenDoor(self,door,pos)
								else
									door:Open(nil)
								end
							else
								if door:GetChildren()[1]!=nil then
									SpawnPhysicsDoor(self,door,door:GetChildren()[1])		
								elseif IsValid(door) then
									(door["Entity"]):Remove()
								end
							end	
						elseif door:GetClass() == "prop_door_rotating" then
							SpawnPhysicsDoor(self,door)
						end	
						
					end	
				
				end
						
	end

	function ENT:OnTakeDamage(dmg, hitgroup)
		if !( dmg:GetAttacker():IsNPC() or dmg:GetAttacker():IsPlayer() or dmg:GetAttacker():IsNextBot() ) then return end
		if (dmg:GetAttacker():Health()<=0) then return end
		  
		if IsValid(dmg:GetAttacker()) then
			self:SetEnemy(dmg:GetAttacker())
		end
			
	end
	
	function ENT:OnContact(ent)
		if string.find( ent:GetClass():lower(), "prop_*" ) or (ent:GetClass() == "func_physbox") or (ent:GetClass() == "func_breakable") then
			if IsValid(ent) then
				local velocity = math.Round(self:GetVelocity():Length())*2
				local forwardvel = Vector(1,1,0.1)*velocity
					
				if IsValid(ent:GetPhysicsObject()) then
					if ent:GetPhysicsObject():GetMass()>15000 then return end
					constraint.RemoveAll( ent )
					ent:GetPhysicsObject():EnableMotion( true )
					ent:TakeDamage( ent:Health(), self,self )
					self:PushEntity(ent, forwardvel)
				end
				
			end
		end
		if ent:GetClass() == "prop_combine_ball" then 
			if IsValid(ent:GetPhysicsObject()) then 
				ent:GetPhysicsObject():SetVelocity(VectorRand()*1000) 
			end 
		end
	end

	function ENT:OnMeleeAttack(enemy)
		if self:GetCreationTime()+GetConVar("scp096j_graceperiod"):GetFloat()>CurTime() then return end
		self:PlaySequenceAndMove("Swipe_"..tostring(math.random(1,2)),1.5,self.FaceEnemy)
	end

	function ENT:OnEnemyUnreachable(enemy) 
		--self:FollowPath(self:GetPos():DrG_Away(enemy:GetPos()))
	end
	
	function ENT:JumpTo(pos)
		self:FaceTo(pos)
		self:PauseCoroutine(0.5)
		self:Jump(pos)
	end
	
	function ENT:OnRangeAttack(enemy)
		if self:GetCreationTime()+GetConVar("scp096j_graceperiod"):GetFloat()>CurTime() then return end
		if self:IsJumping() then return end
		if !enemy:IsOnGround() then return end
		local epos=enemy:GetPos()
		local spos=self:GetPos()
		local z=(epos.z-spos.z)	
		local dist=( spos:DistToSqr(epos) - ( Vector(0,0,spos.z):DistToSqr(Vector(0,0,epos.z)) ) )

		if z>200 and z<=self.JumpHeight and dist>(650^2) then
			local var=10
			self:JumpTo( enemy:EyePos()+Vector(math.random(-var,var),math.random(-var,var),0) )
		end
	end

	function ENT:OnIdle()
		self:AddPatrolPos(self:RandomPos(5000))
	end
	
	function ENT:OnReachedPatrol()
		self:Wait(math.random(2,5))
	end
	
	function ENT:OnPatrolUnreachable(pos,patrol)
		self:RemovePatrol(patrol)
	end
	
end

function ENT:OnRemove()
	if SERVER then
	
		if self.ThemeSongLoop!= nil then
		self.ThemeSongLoop:Stop()
		end
		
		if self.ScreamSound != nil then
		self.ScreamSound:Stop()
		end
		
	end
end

function ENT:PossessionHalos() 
if !CLIENT then return end
halo.Add( ents.FindByClass( "player" ), Color( 255, 0, 0 ), 1, 1, 1, true, true )
halo.Add( ents.FindByClass( "npc_*" ), Color( 255, 0, 0 ), 1, 1, 1, true, true )
end

function ENT:PossessionRender()
	if !CLIENT then return end

	local tab = {
		[ "$pp_colour_addr" ] = 0.1,
		[ "$pp_colour_addg" ] = 0,
		[ "$pp_colour_addb" ] = 0,
		[ "$pp_colour_brightness" ] = 0.1,
		[ "$pp_colour_contrast" ] = 1,
		[ "$pp_colour_colour" ] = 1,
		[ "$pp_colour_mulr" ] = 0,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
		}

	DrawColorModify( tab )	
	
end

--[[
function ENT:PossessionThink()
if !CLIENT then return end
local view,data=self:CurrentViewPreset()
	if view==2 then
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.pos = self:EyePos()+self:GetForward()*50
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.brightness = 0
			dlight.Decay = 100000
			dlight.Size = 200
			dlight.DieTime = CurTime()+(1/66)
		end	
	end
end
--]]

function ENT:OnPossessed()
	self:Timer(0,function() -- hack	
	
		if CLIENT then
			if self:IsPossessedByLocalPlayer() then
			  chat.AddText( Color( 100, 100, 255 ), 
				[[ CONTROLS:
					Left Click - Swipe Attack
					Right Click - Pound Attack
					R - Charge Attack
					Space - Jump
				]]
				)
			end
		end
		
	end)
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)