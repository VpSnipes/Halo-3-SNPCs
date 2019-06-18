AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/halo3/cov/scarab/scarabrigged.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 3000
ENT.HullType = HULL_LARGE
ENT.ConstantlyFaceEnemy = true
ENT.SightDistance = 40000 -- How far it can see

	-- ====== Blood-Related Variables ====== --
ENT.Bleeds = false -- Does the SNPC bleed? (Blood decal, particle, etc.)

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasAllies = true -- Put to false if you want it not to have any allies
ENT.VJ_NPC_Class = {"CLASS_COV"} -- NPCs with the same class with be allied to each other

	-- Melee Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?

	-- Range Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.RangeToMeleeDistance = 0 -- How close does it have to be until it uses melee?
ENT.RangeDistance = 8000
ENT.AnimTbl_RangeAttack = {""} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_h3_beam_proj" -- The entity that is spawned when range attacking
ENT.TimeUntilRangeAttackProjectileRelease = 0.8 -- How much time until the projectile code is ran?
ENT.NextAnyAttackTime_Range = 1.5 -- How much time until it can use any attack?
ENT.NextRangeAttackTime = 5 -- How much time until it can use a range attack?
ENT.NextRangeAttackTime_DoRand = 8 -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer
ENT.RangeAttackAnimationStopMovement = false -- Should it stop moving when performing a range attack?
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "Cannon" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.RangeAttackReps = 1 -- How many times does it run the projectile code?
ENT.RangeAttackExtraTimers = {0.85, 0.9, 0.95, 1, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5} -- Extra range attack timers | it will run the projectile code after the given amount of seconds
ENT.RangeAttackAngleRadius = 100 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC

	-- ====== No Chase After Certain Distance Variables ====== --
ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = 8000 -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = 0 -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "OnlyRange" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack

ENT.PoseParameterLooking_Names = {pitch={},yaw={},roll={}} -- Custom pose parameters to use, can put as many as needed
ENT.NextMoveTime = 0
ENT.CanMoveAgain = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRangeAttack_BeforeStartTimer()
	ParticleEffectAttach("hcea_hunter_frg_charge",PATTACH_POINT_FOLLOW,self,1)
	
	timer.Simple(0.8,function() if self:IsValid() then 
			self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_cannon_loop/hunter_cannon/in.wav", 80, 100, 1)

		end 
	end)
	
	self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_charge.wav", 80, 100, 1)
	
	timer.Simple(1.5,function() if self:IsValid() then 
			self:StopParticles() 
			self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_cannon_loop/hunter_cannon/out.wav", 80, 100, 1) 
		end 
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	return (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()-self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos):GetNormal()*2000
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	if self.CanMoveAgain == false then
		if CurTime() > self.NextMoveTime then
			self.CanMoveAgain = true
			self.NextMoveTime = CurTime() + math.random(6,8) -- Time until scythe can be recasted
		end
	end
	
	if self:GetEnemy() != nil && self.VJ_IsBeingControlled == false then	
		if CurTime() > self.NextMoveTime && self:Visible(self:GetEnemy()) && self.CanMoveAgain == true then
			local checkdist = self:VJ_CheckAllFourSides(8000)
			local randmove = {}
			if checkdist.Backward == true then randmove[#randmove+1] = "Backward" end
			if checkdist.Right == true then randmove[#randmove+1] = "Right" end
			if checkdist.Left == true then randmove[#randmove+1] = "Left" end
			local pickmove = VJ_PICKRANDOMTABLE(randmove)
			if pickmove == "Backward" then self:SetLastPosition(self:GetPos() + self:GetForward()*math.random(-2000,-4000)) end
			if pickmove == "Right" then self:SetLastPosition(self:GetPos() + self:GetRight()*math.random(2000,4000)) end
			if pickmove == "Left" then self:SetLastPosition(self:GetPos() + self:GetRight()*math.random(-2000,-4000)) end
			if pickmove == "Backward" or pickmove == "Right" or pickmove == "Left" then
				self.NextMoveTime = CurTime() + math.random(3,4)
				self.CanMoveAgain = false
				self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH",function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.ConstantlyFaceEnemy = true end)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize()
	self:SetCollisionBounds(Vector(45, 45, 115), Vector(-45, -45, 0))
	self:ManipulateBoneJiggle(14, 1)
	self:ManipulateBoneJiggle(8, 1)
	self:ManipulateBoneJiggle(27, 1)
	self:ManipulateBoneJiggle(21, 1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)
	if dmginfo:GetDamageType() == DMG_BLAST then
		dmginfo:ScaleDamage(2)
	else
		dmginfo:ScaleDamage(0.05)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.SoundTbl_Alert = {
}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "Step" then
		self:EmitSound("halo3/cov/hunter/run/walk"..math.random(1,6)..".wav", 80, 90, 1)
		self:EmitSound("halo3/cov/hunter/shortmove/move"..math.random(1,31)..".wav", 80, 90, 1)
		
	elseif key == "PreStep_LiftOff" then
		self:EmitSound("halo3/cov/hunter/hard_metal_thick_cov_hunter/hard_metal_thick_cov_hunter"..math.random(1,4)..".wav", 80, 100, 1)
	
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/