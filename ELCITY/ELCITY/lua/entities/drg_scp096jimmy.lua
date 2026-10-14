-- "lua\\entities\\drg_scp096jimmy.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

-- Basic Info --
ENT.PrintName = "SCP-096"
ENT.Category = "SCP-096:SL Nextbot"
ENT.Models = {"models/scp_096/scp_096_final.mdl"}
--ENT.CollisionBounds = Vector(40, 40, 80)
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
ENT.DefaultRelationship = D_NU
ENT.Factions = {"FACTION_SCP096"}

-- Movements/animations --
ENT.Acceleration = 1000
ENT.Deceleration = 12000
ENT.ClimbLadders = true
ENT.ClimbLaddersUp = true
ENT.ClimbSpeed = 60
ENT.ClimbUpAnimation = "Jump"
ENT.WalkSpeed = 50
ENT.RunSpeed = 120
ENT.IdleAnimation = "Docile_Idle"
ENT.WalkAnimation = "Docile_Walk"
ENT.WalkAnimRate = 0.5
ENT.RunAnimation = "Docile_Walk"
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
			if self.IsAngry==false then return end
			if self:GetSequenceName(self:GetSequence())=="Swipe_1" or self:GetSequenceName(self:GetSequence())=="Swipe_2" then return end
			self:PlaySequenceAndMove("Swipe_"..tostring(math.random(1,2)),1.5,self.PossessionFaceForward)
		end
	}},
	[IN_ATTACK2] = {{
		coroutine = true,
		onkeydown = function(self)
			if self.IsAngry==false then return end
			if self:GetSequenceName(self:GetSequence())=="Pound" then return end
			self:PlaySequenceAndMove("Pound")
		end
	}},
	[IN_RELOAD] = {{
		coroutine = true,
		onkeydown = function(self)
			if self.IsAngry == false then return end
			if self:GetSequenceName(self:GetSequence())=="Charge" then return end
			
			if self.TimeTillNextCharge==nil then self.TimeTillNextCharge = CurTime() end
		
			if self.TimeTillNextCharge <= CurTime() then
			self.RunAnimation = "Charge"
			self.RunSpeed = 1000
				self:Timer(5,function()
					self.RunAnimation = "Run"
					self.RunSpeed = 800
				end)
			self.TimeTillNextCharge = CurTime()+15
			end
		end
	}},
	[IN_DUCK] = {{
    coroutine = true,
    onkeydown = function(self)
		if self.IsAngry==true then return end
	
		local trace=util.QuickTrace(self:EyePos(),self:GetForward()*15,self)
		if !trace.Hit then return end

		self:CallInCoroutine(function(self, delay) 
			if self.CryLoop != nil then
				self.CryLoop:ChangeVolume(0,1)
			end
			self.IdleAnimation="Idle_Wall"
			self.RunSpeed=0
			self.WalkSpeed=0
			
				self:Timer(5,function()
					if self.IsAngry==true then return end
					self.IdleAnimation = "Docile_Idle"
					self.RunSpeed = 120
					self.WalkSpeed = 50
						
					if self.CryLoop != nil then
						self.CryLoop:ChangeVolume(1,1)
					end	
				end)
		end)
    end
	}},
	[IN_JUMP] = {{
		coroutine = true,
		onkeydown  = function(self)
			if self.IsAngry==false then self:Jump(100) return end
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
		if !( ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() ) then return true end		if ( ent:Health()<=0 ) or ( ent:GetModel()==self:GetModel() ) then return true end
		if (ent.IsDrGNextbot and ent:IsBlind()) then return true end
		if (self:IsPossessed() and self:GetPossessor()==ent) then return true end
		if self:IsAlly(ent) or self:IsAfraidOf(ent) then return true end
		if self:IsIgnored(ent) then return true end
	--	if util.IsInWorld(ent:GetPos())==false then return true end
		return false
	end

	function ENT:Calm()
		self:CallInCoroutine(function(self, delay) 
			if self.IsAngry==false then return end
			if GetConVar("scp096j_limited_anger"):GetInt()>0 and self:GetNWInt( "RageTimer", 0 )>0 then return end
			if GetConVar("scp096j_limited_anger"):GetInt()<=0 and !table.IsEmpty(self:GetEnemies(true)) then return end
		
			local vol =( GetConVar("scp096j_screamvolume"):GetFloat() or 1 )
			self:EmitSound("jimmy096/calmdown.wav",nil,nil,vol)   
			self.IsAngry = false 
			self:PlaySequenceAndMove("Calm",1)
			if self.IsAngry==true then return end
			self.WalkAnimation = "Docile_Walk"
			self.RunAnimation = "Docile_Walk"
			self.JumpAnimation = "Jump"
			self.IdleAnimation = "Docile_Idle"
			self.WalkSpeed = 50
			self.WalkAnimRate = 0.5
			self.RunSpeed = 60
			self.RunAnimRate = 0.8

			if self.IsTriggered != true then
				if self.CryLoop ==nil then 	
					local filter = RecipientFilter()
					filter:AddAllPlayers()
											
					self.CryLoop = CreateSound(self,Sound(	"jimmy096/docileloop.wav"), filter)
					self.CryLoop:SetSoundLevel(70)
					self.CryLoop:Play()
				end
			end
			
		end) 
	end
	
	function ENT:Rage(enemy)
		if self.IsAngry==true then return end
		if GetConVar("scp096j_limited_anger"):GetInt()>0 and self:GetNWInt( "RageTimer", 0 )<=0 then return end
		self:CallInCoroutine(function(self, delay)
			if self.IsAngry==true then return end
		
			if enemy then
			--	self:FaceTo(enemy)
				self:SetEnemy(enemy)
			end
		
			if self.TriggerSound==nil then 
				local filter = RecipientFilter()
				filter:AddAllPlayers()

				local vol =( GetConVar("scp096j_screamvolume"):GetFloat() or 1 )
				self.TriggerSound = CreateSound(self, Sound("jimmy096/trigger.wav"), filter)
				self.TriggerSound:SetSoundLevel( 80 )
				self.TriggerSound:Play()
				self.TriggerSound:ChangeVolume( vol, 0 )
			end
			
			if self.CryLoop != nil then
				self.CryLoop:Stop()
				self.CryLoop=nil
			end
			
			if !IsValid(self) then return end
			self:PlaySequenceAndMove("Trigger",1)
			if !IsValid(self) then return end
			self:PlaySequenceAndMove("Rage_Idle",2,self.FaceEnemy)			
			if !IsValid(self) then return end
			
			self.WalkSpeed = 800
			self.WalkAnimRate = 1
			self.RunSpeed = 800
			self.RunAnimRate = 1
			self.IdleAnimation = "Rage_Idle"
			self.WalkAnimation = "Run"
			self.RunAnimation = "Run"
			self.JumpAnimation = "Jump"
			self.IsAngry = true
			self.IsTriggered = false
			
	--		self:SetDefaultRelationship(D_HT)
			
		end)
	end

	function ENT:InstantRage(enemy)
		if self.IsAngry==true then return end
		if GetConVar("scp096j_limited_anger"):GetInt()>0 and self:GetNWInt( "RageTimer", 0 )<=0 then return end
		
		if enemy then
			self:FaceTo(enemy)
			self:SetEnemy(enemy)
		end
	--	self:SetDefaultRelationship(D_HT)

		self.WalkSpeed = 800
		self.WalkAnimRate = 1
		self.RunSpeed = 800
		self.RunAnimRate = 1
		self.IdleAnimation = "Rage_Idle"
		self.WalkAnimation = "Run"
		self.RunAnimation = "Run"
		self.JumpAnimation = "Jump"
		self.IsAngry = true
		self.IsTriggered = false
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
			
			self:Calm()
		end)
	end
	
	function ENT:PoundFunc()
		self:Attack({
			damage = 500,
			viewpunch = Angle(40, 0, 0),
			type = DMG_CRUSH,range=60,angle=185,
			force=Vector(0, 0, -120),	
		}, function(self, hit)
			self:EmitSound("jimmy096/bang1.mp3") 
			util.ScreenShake( self:GetPos(), 5, 5, 1, 1000 )	
				
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
			
			self:Calm()	
		end)
	end
	
	function ENT:ChargeFunc()
		self:Attack({
			damage = 200,
			viewpunch = Angle(40, 0, 0),
			type = DMG_CRUSH,range=20,angle=190,
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
			
			self:Calm()	
		end)
	end
	  
	-----------------------------------------------------------------------------  
	-----------------------------------------------------------------------------  
	-----------------------------------------------------------------------------  
	
  -- Init/Think --
	function ENT:CustomInitialize()
	
		self:SetModelRelationship(self:GetModel(), D_LI, 1)
		self:SetClassRelationship("npc_drg_scp682", D_FR, 1)
		
		self:SequenceEvent("Swipe_1",{0.3},self.AttackFunc)  	
		self:SequenceEvent("Swipe_2",{0.3},self.AttackFunc)   
		self:SequenceEvent("Docile_Walk",{0.1,0.6},function() self:EmitSound("npc/fast_zombie/foot"..math.random(1,4)..".wav") end) 
		self:SequenceEvent("Run",{0.1,0.6},function() self:EmitSound("npc/fast_zombie/foot"..math.random(1,4)..".wav") end) 
		self:SequenceEvent("Charge",{0.1,0.6},function() self:EmitSound("npc/fast_zombie/foot"..math.random(1,4)..".wav") end) 
		self:SequenceEvent("Pound",{0.1,0.25,0.45,0.6,0.75,0.9},self.PoundFunc) 
		
		self:SetSightFOV(220)
		self:SetSightRange(GetConVar("drgbase_ai_radius"):GetInt())
		self.IsAngry = false
		self.IsTriggered = false	
		self.LastPos = self:GetPos()
		self:SetNWInt( "RageTimer", 15 )
		
		self:Timer(.1,function()
			if GetConVar("drgbase_ai_radius"):GetInt()<1000 and IsValid(self:GetCreator()) then
				DrGBase.Error("WARNING: The ConVar 'drgbase_ai_radius' is below an optimal level for SCP-096. Increase this ConVar over 1000 for better sight-detection from SCP-096.", {player = self:GetCreator(), color = DrGBase.CLR_GREEN, chat = true})
			end
		end)

		if self.CryLoop ==nil then 	
			local filter = RecipientFilter()
			filter:AddAllPlayers()
									
			self.CryLoop = CreateSound(self,Sound(	"jimmy096/docileloop.wav"), filter)
			self.CryLoop:SetSoundLevel(70)
			self.CryLoop:Play()
		end
	end

	function ENT:OnStuck()
		if self:GetSequence()==2 then return end
		
		for i,ent in ipairs(ents.FindInSphere(self:GetPos(),50)) do
			if ent:GetClass()!="func_door" then continue end
			if ent:GetInternalVariable( "m_toggle_state" )==1 then ent:Fire("Open") end
		end
		
		if navmesh.IsLoaded() then
			self:SetPos( navmesh.GetNearestNavArea(self.LastPos):GetClosestPointOnArea(self.LastPos) )
		else
			self:SetPos( self.LastPos )
		end	
		self:ClearStuck()
	end
	
	function ENT:OnUpdateEnemy()
		local ent = self:GetEnemy()
		if self:SeeCond(ent) then 
			self:SetEntityRelationship(ent,D_NU)
			self:LoseEntity(ent)
		end
		return self:FetchEnemy()
	end
	
	function ENT:UpdateAI()
		self:SetSightRange(GetConVar("drgbase_ai_radius"):GetInt())
		
		if !self:IsStuck() and self:GetSequence()!=2 then
			if self:IsJumping() and self.LastPos==self:GetPos() then self:SetPos(self:GetPos()-self:GetForward()*50) end
			self.LastPos = self:GetPos()
		end
	
		self:UpdateEnemy()
		self:UpdateSight(true)
		
		if self.IsAngry==true then -- maybe try using self:EnemiesLeft(true)==0 or self:HostilesLeft(true) idk
			if self:EnemiesLeft(true)==0 or (self:GetNWInt( "RageTimer", 0 )<=0 and GetConVar("scp096j_limited_anger"):GetInt()>0) then self:Calm() end			
			if GetConVar("scp096j_limited_anger"):GetInt()>0 then self:SetNWInt( "RageTimer", math.max(0,self:GetNWInt( "RageTimer", 0 )-1) ) end
		elseif self.IsAngry==false then			if self:EnemiesLeft(true)!=0 and (self:GetNWInt( "RageTimer", 0 )!=0 and GetConVar("scp096j_limited_anger"):GetInt()>0) then self:Rage() end
			if GetConVar("scp096j_limited_anger"):GetInt()>0 then
				if self:GetNWInt( "RageTimer", 0 )==0 then self:Timer(15,function() self:SetNWInt( "RageTimer", 15 ) end) self:SetNWInt( "RageTimer", -1) end
			end	
		end
	end
	
	function ENT:OnSight(ent)
		self:SetEntityRelationship(ent,D_HT)
		self:SpotEntity(ent)
		--self:AddToEnemyList(ent)
		if self.IsAngry==true then return end
		self:Rage(ent)
	end	

	function ENT:IsInSight(ent)
		local view = ent:IsPlayer() and ent:GetViewEntity() or ent
				if self:GetCreationTime()+GetConVar("scp096j_graceperiod"):GetFloat()>=CurTime() then return false end -- grace period
		if self:SeeCond(ent) then return false end
		if ( self:GetSequence()==0 or self:GetSequence()==7 or self:GetSequence()==6 ) then return end
		
		local viewpos = view:EyePos()
		local eyepos = self:EyePos()
		if eyepos:DistToSqr(viewpos) > self:GetSightRange()^2 then return false end
		
		local angle = (eyepos + self:EyeAngles():Forward()):DrG_Degrees(view:WorldSpaceCenter(), eyepos)
		if angle > self:GetSightFOV()/2 then return false end

		if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
			local diff = eyepos - viewpos
			if !(view:EyeAngles():Forward():Dot(diff) / diff:Length()>=0.75) then return false end	
		end
		
		return self:Visible(view)
	end
	
	function ENT:CustomThink()
		--PrintTable(self:GetEnemies(true))
		--print(self:EnemiesLeft(true),self:GetEnemy())
	
		if self.IsAngry == false then
		
			if self.ThemeSongLoop!= nil then
				self.ThemeSongLoop:Stop()
				self.ThemeSongLoop=nil
			end
		
			if self.ScreamSound != nil then
				self.ScreamSound:Stop()
				self.ScreamSound=nil
			end
		
		elseif self.IsAngry == true then
		
			if (self:GetSequence()!=5 and self:GetSequence()!=0 and self:GetSequence()!=7 and self:GetSequence()!=6 ) then

				if self.TriggerSound != nil then
					self.TriggerSound:Stop()
					self.TriggerSound=nil
				end
				
				if self.CryLoop != nil then
					self.CryLoop:Stop()
					self.CryLoop=nil
				end
		
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
		
				if self.RunAnimation == "Charge" and self:IsRunning() and math.random(4)==4 then
					for i,ent in ipairs(ents.FindInSphere(self:GetPos(),50)) do
						if !self:SeeCond(ent) then 
							self:ChargeFunc()
						end
					end
				end
				
			--	local min,max = self:GetModelBounds()
		
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
			
		end
		
	end

	function ENT:OnTakeDamage(dmg, hitgroup)
		local ent = dmg:GetAttacker()	
		if !IsValid(ent) then return end
		if self:SeeCond(ent) then return end
	
		self:SetEntityRelationship(ent,D_HT)
		self:SpotEntity(ent)
	
		--self:AddToEnemyList(ent)
		if self.IsAngry==true then return end

		if IsValid(ent) then
			self:Rage(ent)
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
		if self.IsAngry!=true then return end
		self:PlaySequenceAndMove("Swipe_"..tostring(math.random(1,2)),1.5,self.FaceEnemy)
	end

	function ENT:OnEnemyUnreachable(enemy) 
	--	self:FollowPath(self:GetPos():DrG_Away(enemy:GetPos()))
	end
	
	function ENT:JumpTo(pos)
		self:FaceTo(pos)
		self:PauseCoroutine(0.5)
		self:Jump(pos)
	end
	
	function ENT:OnRangeAttack(enemy)
		if self:IsJumping() then return end		if !enemy:IsOnGround() then return end
		local epos=enemy:GetPos()
		local spos=self:GetPos()
		local z=(epos.z-spos.z)			local dist=( spos:DistToSqr(epos) - ( Vector(0,0,spos.z):DistToSqr(Vector(0,0,epos.z)) ) )

		if z>200 and z<=self.JumpHeight and dist>(650^2) then
			local var=10
			self:JumpTo( enemy:EyePos()+Vector(math.random(-var,var),math.random(-var,var),0) )
		end
	end
	
	function ENT:OnIdle()
		self:AddPatrolPos(self:RandomPos(200))
	end
	
	function ENT:OnReachedPatrol()
		self:Wait(math.random(5,30))
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
		
		if self.TriggerSound != nil then
		self.TriggerSound:Stop()
		end
		
		if self.CryLoop != nil then
		self.CryLoop:Stop()
		end

		self:StopSound("jimmy096/calmdown.wav")
		--[[
		for k,ent in ipairs(ents.GetAll()) do
			self:RemoveFromEnemyList(ent)
		end
		--]]
	end
	
end

function ENT:OnPossessed()
	self:Timer(0,function() -- hack	
	
		if CLIENT then
			if self:IsPossessedByLocalPlayer() then
			  chat.AddText( Color( 100, 100, 255 ), 
					[[ CONTROLS: 
					Left Click - Swipe Attack (enraged)
					Right Click - Pound Attack (enraged) 
					R - Charge Attack (enraged + 10 second cooldown)
					Space - Jump 
					Ctrl - Try Not To Cry (docile) ]] 
				)
			end
		end
	
		if SERVER then
			self:LoseEntity(self:GetPossessor()) -- check to see if we actually need this
			self:SetEntityRelationship(self:GetPossessor(),D_NU)
			
			--self:RemoveFromEnemyList(self:GetPossessor())
		end
	
	end)
end

function ENT:PossessionHalos() 
if !CLIENT then return end
local tbl = {}

	for k,ent in ipairs(ents.FindByClass( "npc_*" )) do
		if not (ent:IsNPC() or ent:IsNextBot()) then continue end
		if ent==self:GetEnemy() or ent:GetPos():DistToSqr(self:GetPos())<(8000*8000) then
			table.insert(tbl,ent)	
		end
	end
	
	for k,ent in ipairs(player.GetAll()) do
		if ent==self:GetEnemy() or ent:GetPos():DistToSqr(self:GetPos())<(8000*8000) then
			table.insert(tbl,ent)	
		end
	end

halo.Add( tbl, Color( 255, 0, 0 ), 1, 1, 1, true, true )

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

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end


-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
