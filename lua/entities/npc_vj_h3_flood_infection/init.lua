AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/halo3/flood/infection_form/h3_flood_infection_form.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 10
ENT.HullType = HULL_TINY
---------------------------------------------------------------------------------------------------------------------------------------------
	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_PARASITE"} -- NPCs with the same class with be allied to each other
	-- ====== Gibs ====== --
ENT.GibOnDeathDamagesTable = {"All"} -- Damages that it gibs from | "UseDefault" = Uses default damage types | "All" = Gib from any damage
ENT.HasGibOnDeathSounds = false -- Does it have gib sounds? | Mostly used for the settings menu

---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasDeathRagdoll = false -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.PushProps = false -- Should it push props when trying to move?
ENT.EntitiesToNoCollide = {"npc_vj_h3_flood_infection"}
ENT.NextLeapTime = 0
ENT.CanLeapAgain = true

	-- Melee Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 20
ENT.MeleeAttackAngleRadius = 50 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageAngleRadius = 45 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageDistance = 20
ENT.AnimTbl_MeleeAttack = {"Melee_Var1"}
ENT.TimeUntilMeleeAttackDamage = false
ENT.NextAnyAttackTime_Melee = false
ENT.MeleeAttackAnimationFaceEnemy = false
ENT.MeleeAttackDamage = 10
ENT.MeleeAttackDamageType = DMG_SLASH
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {
"infection_form/infector_sound/infector/loop/infector_sound1.wav",
"infection_form/infector_sound/infector/loop/infector_sound2.wav",
"infection_form/infector_sound/infector/loop/infector_sound3.wav",
"infection_form/infector_sound/infector/loop/infector_sound4.wav",
"infection_form/infector_sound/infector/loop/infector_sound5.wav",
"infection_form/infector_sound/infector/loop/infector_sound6.wav",
"infection_form/infector_sound/infector/loop/infector_sound7.wav",
"infection_form/infector_sound/infector/loop/infector_sound8.wav",
"infection_form/infector_sound/infector/loop/infector_sound9.wav",
"infection_form/infector_sound/infector/loop/infector_sound10.wav",
"infection_form/infector_sound/infector/loop/infector_sound11.wav",
"infection_form/infector_sound/infector/loop/infector_sound12.wav",
"infection_form/infector_sound/infector/loop/infector_sound13.wav",
"infection_form/infector_sound/infector/loop/infector_sound14.wav",
"infection_form/infector_sound/infector/loop/infector_sound15.wav",
"infection_form/infector_sound/infector/loop/infector_sound16.wav",
"infection_form/infector_sound/infector/loop/infector_sound17.wav",
"infection_form/infector_sound/infector/loop/infector_sound18.wav",
"infection_form/infector_sound/infector/loop/infector_sound19.wav",
"infection_form/infector_sound/infector/loop/infector_sound20.wav",
"infection_form/infector_sound/infector/loop/infector_sound21.wav",
"infection_form/infector_sound/infector/loop/infector_sound22.wav",
"infection_form/infector_sound/infector/loop/infector_sound23.wav",
"infection_form/infector_sound/infector/loop/infector_sound24.wav",
"infection_form/infector_sound/infector/loop/infector_sound25.wav",
"infection_form/infector_sound/infector/loop/infector_sound26.wav",
"infection_form/infector_sound/infector/loop/infector_sound27.wav",
"infection_form/infector_sound/infector/loop/infector_sound28.wav",
"infection_form/infector_sound/infector/loop/infector_sound29.wav",
"infection_form/infector_sound/infector/loop/infector_sound30.wav"
}

ENT.SoundTbl_LeapAttackDamage = {
"infection_form/infector_bite/infector_bite1.wav",
"infection_form/infector_bite/infector_bite2.wav",
"infection_form/infector_bite/infector_bite3.wav",
"infection_form/infector_bite/infector_bite4.wav",
"infection_form/infector_bite/infector_bite5.wav",
"infection_form/infector_bite/infector_bite6.wav",
"infection_form/infector_bite/infector_bite7.wav",
"infection_form/infector_bite/infector_bite8.wav",
"infection_form/infector_bite/infector_bite9.wav",
"infection_form/infector_bite/infector_bite10.wav",
"infection_form/infector_bite/infector_bite11.wav"
}

ENT.SoundTbl_Death = {
"infection_form/infection_pop/pop1.wav",
"infection_form/infection_pop/pop2.wav",
"infection_form/infection_pop/pop3.wav",
"infection_form/infection_pop/pop4.wav",
"infection_form/infection_pop/pop5.wav",
"infection_form/infection_pop/pop6.wav",
"infection_form/infection_pop/pop7.wav",
"infection_form/infection_pop/pop8.wav",
"infection_form/infection_pop/pop9.wav",
"infection_form/infection_pop/pop10.wav"
}
ENT.NextSoundTime_Idle1 = 1
ENT.NextSoundTime_Idle2 = 2
---------------------------------------------------------------------------------------------------------------------------------------------
/*function ENT:CustomOnKilled(dmginfo,hitgroup)
	ParticleEffect("hcea_flood_inf_death", self:LocalToWorld(Vector(0,0,10)), self:GetAngles(), self)
	//ParticleEffectAttach("hcea_flood_inf_death",PATTACH_POINT_FOLLOW,self,0)
end*/
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	if self.HasGibDeathParticles == true then
		ParticleEffect("hcea_flood_infected_death", self:LocalToWorld(Vector(0,0,20)), self:GetAngles(), nil)
		//ParticleEffect("doom_mancu_blast", self:LocalToWorld(Vector(0,0,20)), self:GetAngles(), nil)
		//ParticleEffect("hound_explosion", self:LocalToWorld(Vector(0,0,20)), self:GetAngles(), nil)
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	if self.LeapCoroutine and coroutine.status(self.LeapCoroutine) == "suspended" then -- the npc is leaping
		coroutine.resume(self.LeapCoroutine)
	else
		if IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) <= 200 && CurTime() > self.NextLeapTime && self:Visible(self:GetEnemy()) && self.CanLeapAgain == true && self.MeleeAttacking == false then
			self:Leap()
			return
		end
	end
	
	if self.CanLeapAgain == false then
		self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH",function(x) x.ConstantlyFaceEnemy = true end)
		
		if CurTime() > self.NextLeapTime then
			self.CanLeapAgain = true
			self.NextLeapTime = CurTime() + math.random(6,8) -- Time until scythe can be recasted
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsLeaping()
    return self.LeapCoroutine ~= nil and coroutine.status(self.LeapCoroutine) == "suspended"
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Leap()
    self:SetVelocity(self:GetForward()*1500 + self:GetUp()*250)
	self.LeapCoroutine = coroutine.create(function()
	self:VJ_ACT_PLAYACTIVITY("Leap_Start",true,false,false) -- play start leaping animation
	self.NextLeapTime = CurTime() + math.random(3,4)
	self.CanLeapAgain = false
	
	if self:IsOnGround() then
		coroutine.yield()
	end
    
	while not self:IsOnGround() do
		self:VJ_ACT_PLAYACTIVITY("Leap_Airborne",true,false,false)
		if enemyInMeleeRange then
		return
    end
            coroutine.yield()
        end
        self:VJ_ACT_PLAYACTIVITY("Leap_Land",true,false,false) -- play landing animation
    end)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/