AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/halo3/cov/hunter/h3_hunter.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 250
ENT.HullType = HULL_LARGE

	-- ====== Blood-Related Variables ====== --
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Orange" -- The blood type, this will detemine what it should use (decal, particle, etc.)

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasAllies = true -- Put to false if you want it not to have any allies
ENT.VJ_NPC_Class = {"CLASS_COV"} -- NPCs with the same class with be allied to each other

	-- Melee Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 100
ENT.MeleeAttackAngleRadius = 50 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageAngleRadius = 40 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageDistance = 100
ENT.AnimTbl_MeleeAttack = {"Melee_Var_1", "Melee_Var_2", "Melee_Var_3"}
ENT.TimeUntilMeleeAttackDamage = false
ENT.NextAnyAttackTime_Melee = false
ENT.MeleeAttackAnimationFaceEnemy = false
ENT.MeleeAttackDamage = 75
ENT.MeleeAttackDamageType = DMG_SLASH	

	-- Range Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.RangeToMeleeDistance = 300 -- How close does it have to be until it uses melee?
ENT.RangeDistance = 1300
ENT.AnimTbl_RangeAttack = {"vjges_gesture_fire_weapon"} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_h3_beam_proj" -- The entity that is spawned when range attacking
ENT.TimeUntilRangeAttackProjectileRelease = false -- How much time until the projectile code is ran?
ENT.NextAnyAttackTime_Range = 2.3 -- How much time until it can use any attack?
ENT.NextRangeAttackTime = 5 -- How much time until it can use a range attack?
ENT.NextRangeAttackTime_DoRand = 8 -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer
ENT.RangeAttackAnimationStopMovement = false -- Should it stop moving when performing a range attack?
ENT.RangeUseAttachmentForPos = false -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "Cannon" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.RangeAttackReps = 1 -- How many times does it run the projectile code?
ENT.RangeAttackAngleRadius = 100 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC

	-- ====== No Chase After Certain Distance Variables ====== --
ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = 1300 -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = 300 -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "OnlyRange" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack

ENT.IsCrouching = false
ENT.NextCrouchTime = 0
ENT.NextMoveTime = 0
ENT.CanMoveAgain = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
    local speed = 2000
    local aimAt = self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()
    return (aimAt-TheProjectile:GetPos()):GetNormalized()*speed
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	if self.IsCrouching == false then
		self.RangeAttackPos_Up = 62.207741 -- Up/Down spawning position for range attack
		self.RangeAttackPos_Forward = 2.561404 -- Forward/ Backward spawning position for range attack
		self.RangeAttackPos_Right = 22 -- Right/Left spawning position for range attack
		
		if IsValid(self:GetEnemy())then
			self.AnimTbl_IdleStand = {ACT_IDLE}
			self.AnimTbl_Run = {ACT_RUN}
			self.AnimTbl_Walk = {ACT_WALK}
			
		else
			self.AnimTbl_IdleStand = {ACT_IDLE_RELAXED}
			self.AnimTbl_Run = {ACT_RUN}
			self.AnimTbl_Walk = {ACT_WALK_RELAXED}
			
		end
	end
	
	if self.IsCrouching == true then
		self.RangeAttackPos_Up = 43.067856 -- Up/Down spawning position for range attack
		self.RangeAttackPos_Forward = 2.561404 -- Forward/ Backward spawning position for range attack
		self.RangeAttackPos_Right = 25 -- Right/Left spawning position for range attack
        self.AnimTbl_IdleStand = {ACT_IDLE_ANGRY}
        self.AnimTbl_Run = {ACT_WALK_CROUCH}
        self.AnimTbl_Walk = {ACT_WALK_CROUCH}
    end

	if self.RangeAttacking == false && self.IsCrouching == false && self.MeleeAttacking == false && self.Dead == false && self:GetEnemy() != nil && self.VJ_IsBeingControlled == false	then
		local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
		if EnemyDistance <= 1300 && math.random(1,30) == 1 && CurTime() > self.NextCrouchTime then -- Random movement
			self:VJ_ACT_PLAYACTIVITY("Idle_To_Crouch",true,false,false) -- Right dodge anim
			self.IsCrouching = true
			self.NextCrouchTime = CurTime() + math.random(8,16) -- Time until scythe can deactivate
		end
	end
	
	if self.RangeAttacking == false && self.IsCrouching == true && self.MeleeAttacking == false && self.Dead == false && self.VJ_IsBeingControlled == false	then
		if math.random(1,3) == 1 && CurTime() > self.NextCrouchTime then -- Random movement
			self:VJ_ACT_PLAYACTIVITY("Crouch_To_Idle",true,false,false) -- Right dodge anim
			self.IsCrouching = false
			self.NextCrouchTime = CurTime() + math.random(5,10) -- Time until scythe can be recasted
		end
	end
	
	if self.CanMoveAgain == false then
		if CurTime() > self.NextMoveTime then
			self.CanMoveAgain = true
			self.NextMoveTime = CurTime() + math.random(6,8) -- Time until scythe can be recasted
		end
	end
	
	if self:GetEnemy() != nil && self.VJ_IsBeingControlled == false then	
		if self:GetPos():Distance(self:GetEnemy():GetPos()) <= 300	then
			self.ConstantlyFaceEnemy = false
		else
			self.ConstantlyFaceEnemy = true
		end
		
		if self:GetPos():Distance(self:GetEnemy():GetPos()) <= 1300 && math.random(1,30) == 1 && CurTime() > self.NextMoveTime && self:Visible(self:GetEnemy()) && self.CanMoveAgain == true && self.MeleeAttacking == false then
			local checkdist = self:VJ_CheckAllFourSides(200)
			local randmove = {}
			if checkdist.Backward == true then randmove[#randmove+1] = "Backward" end
			if checkdist.Right == true then randmove[#randmove+1] = "Right" end
			if checkdist.Left == true then randmove[#randmove+1] = "Left" end
			local pickmove = VJ_PICKRANDOMTABLE(randmove)
			if pickmove == "Backward" then self:SetLastPosition(self:GetPos() + self:GetForward()*math.random(-200,-600)) end
			if pickmove == "Right" then self:SetLastPosition(self:GetPos() + self:GetRight()*math.random(200,600)) end
			if pickmove == "Left" then self:SetLastPosition(self:GetPos() + self:GetRight()*math.random(-200,-600)) end
			if pickmove == "Backward" or pickmove == "Right" or pickmove == "Left" then
				self.NextMoveTime = CurTime() + math.random(3,4)
				self.CanMoveAgain = false
				self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH",function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.ConstantlyFaceEnemy = true end)
			end
		end
	end
	
	
	//print(self:WorldToLocal(self:GetAttachment(self:LookupAttachment("Cannon")).Pos))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize()
	//self:SetPos(Vector(0,0,0))
	//self:SetAngles(Angle(0,0,0))
	self:SetCollisionBounds(Vector(45, 45, 115), Vector(-45, -45, 0))	
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)
	if hitgroup == 11 then
		dmginfo:ScaleDamage(0)
		self:EmitSound("halo3/cov/hunter/hard_metal_thick_cov_hunter/hard_metal_thick_cov_hunter"..math.random(1,4)..".wav", 80, 100, 1)
	end
	
	if dmginfo:GetDamageType() == DMG_SLASH then
		dmginfo:ScaleDamage(0.15)
	end
	
	if hitgroup == 12 then
		dmginfo:ScaleDamage(0.3)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.SoundTbl_Alert = {
"halo3/cov/hunter/seefoe/warn1.wav",
"halo3/cov/hunter/seefoe/warn2.wav",
"halo3/cov/hunter/seefoe/warn3.wav",
"halo3/cov/hunter/seefoe/warn4.wav",
"halo3/cov/hunter/seefoe/warn5.wav",
"halo3/cov/hunter/seefoe/warn6.wav",
"halo3/cov/hunter/seefoe/warn7.wav",
"halo3/cov/hunter/seefoe/warn8.wav",
"halo3/cov/hunter/seefoe/warn9.wav"
}

ENT.SoundTbl_MeleeAttack = {
"halo3/cov/hunter/hunter_melee_hits/hunter_melee_hit1.wav",
"halo3/cov/hunter/hunter_melee_hits/hunter_melee_hit2.wav",
"halo3/cov/hunter/hunter_melee_hits/hunter_melee_hit3.wav",
"halo3/cov/hunter/hunter_melee_hits/hunter_melee_hit4.wav",
"halo3/cov/hunter/hunter_melee_hits/hunter_melee_hit5.wav",
"halo3/cov/hunter/hunter_melee_hits/hunter_melee_hit6.wav"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "Step" then
		self:EmitSound("halo3/cov/hunter/run/walk"..math.random(1,6)..".wav", 80, 90, 1)
		self:EmitSound("halo3/cov/hunter/shortmove/move"..math.random(1,31)..".wav", 80, 90, 1)
		
	elseif key == "Impact_Metal" then
		self:EmitSound("halo3/cov/hunter/hard_metal_thick_cov_hunter/hard_metal_thick_cov_hunter"..math.random(1,4)..".wav", 80, 100, 1)
		
	elseif key == "Melee_Vox" then
		self:EmitSound("halo3/cov/hunter/melee/melee"..math.random(1,22)..".wav", 80, 90, 1)
	
	elseif key == "Melee_Var_1" then
		self:EmitSound("halo3/cov/hunter/melee_var1/melee_var1_"..math.random(1,3)..".wav", 80, 90, 1)
	
	elseif key == "Melee_Var_2" then
		self:EmitSound("halo3/cov/hunter/melee_var2/melee_var2_"..math.random(1,3)..".wav", 80, 90, 1)
	
	elseif key == "Melee_Var_3" then
		self:EmitSound("halo3/cov/hunter/melee_var3/melee_var3_"..math.random(1,3)..".wav", 80, 90, 1)
		
	elseif key == "Posing_Var_1" then
		self:EmitSound("halo3/cov/hunter/posing_var1/posing_var1_"..math.random(1,3)..".wav", 80, 90, 1)
	
	elseif key == "Posing_Var_2" then
		self:EmitSound("halo3/cov/hunter/posing_var2/posing_var2_"..math.random(1,3)..".wav", 80, 90, 1)
	
	elseif key == "Posing_Var_3" then
		self:EmitSound("halo3/cov/hunter/posing_var3/posing_var3_"..math.random(1,3)..".wav", 80, 90, 1)
		
	elseif key == "Posing_Var_4" then
		self:EmitSound("halo3/cov/hunter/posing_var4/posing_var4_"..math.random(1,3)..".wav", 80, 90, 1)
		
	elseif key == "Charge_Weapon" then
		ParticleEffectAttach("hcea_hunter_frg_charge",PATTACH_POINT_FOLLOW,self,1)
		self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_charge.wav", 80, 100, 1)
	
	elseif key == "Laser_Start" then
		self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_cannon_loop/hunter_cannon/in.wav", 80, 100, 1)
		
	elseif key == "Laser_End" then
		self:StopParticles() 
		self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_cannon_loop/hunter_cannon/out.wav", 80, 100, 1) 
	
	elseif key == "Hit" then
		self:MeleeAttackCode()
		util.ScreenShake(self:GetPos(),5,100,0.5,250)
	
	elseif key == "Fire_Weapon" then
		self:RangeAttackCode()
		
	elseif key == "TrackingOn" then
		self.MeleeAttackAnimationFaceEnemy = true
	
	elseif key == "TrackingOff" then
		self.MeleeAttackAnimationFaceEnemy = false
	
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/