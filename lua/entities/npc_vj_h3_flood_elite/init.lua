AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/halo3/flood/elite/h3_flood_elite.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 200
ENT.HullType = HULL_MEDIUM
---------------------------------------------------------------------------------------------------------------------------------------------
	-- ====== Blood-Related Variables ====== --
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
	-- Types: "Red" || "Yellow" || "Green" || "Orange" || "Blue" || "Purple" || "White" || "Oil"
-- Use the following variables to customize the blood the way you want it:
ENT.HasBloodParticle = true -- Does it spawn a particle when damaged?
ENT.Immune_Dissolve = true -- Immune to Dissolving | Example: Combine Ball
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation
ENT.HasBloodPool = false -- Does it have a blood pool?

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_PARASITE"} -- NPCs with the same class with be allied to each other

	-- Melee Attack ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 100
ENT.MeleeAttackAngleRadius = 50 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageAngleRadius = 45 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.MeleeAttackDamageDistance = 100
ENT.AnimTbl_MeleeAttack = {"Combat_Melee_Var1", "Combat_Melee_Var2", "Combat_Melee_Var3", "Combat_Melee_Var4", "Combat_Melee_Var5"}
ENT.TimeUntilMeleeAttackDamage = false
ENT.NextAnyAttackTime_Melee = false
ENT.MeleeAttackAnimationFaceEnemy = false
ENT.MeleeAttackDamage = 75
ENT.MeleeAttackDamageType = DMG_SLASH

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {
}

ENT.SoundTbl_Pain = {
}

ENT.SoundTbl_Impact = {
}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(30, 30, 80), Vector(-30, -30, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	if self.LeapCoroutine and coroutine.status(self.LeapCoroutine) == "suspended" then -- the npc is leaping
		coroutine.resume(self.LeapCoroutine)
	else
		if IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) <= 800 && self:GetPos():Distance(self:GetEnemy():GetPos()) > 300 then
			self:Leap()
			return
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsLeaping()
    return self.LeapCoroutine ~= nil and coroutine.status(self.LeapCoroutine) == "suspended"
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Trajectory(start, goal, v)
  local g = physenv.GetGravity():Length()
  local vec = Vector(goal.x - start.x, goal.y - start.y, 0)
  local x = vec:Length()
  local y = goal.z - start.z
  local res = math.sqrt(v^4 - g*(g*x*x + 2*y*v*v))
  if res == res then
        local s1 = math.atan((v*v + res)/(g*x))
      local s2 = math.atan((v*v - res)/(g*x))
      pitch = s1 > s2 and s2 or s1
      vec.z = math.tan(pitch)*x
      local calc = v*math.sin(pitch)
      return vec:GetNormalized()*v, (calc+math.sqrt(calc^2-2*g*y))/g
    else return self:Trajectory(start, goal, v*1.1) end  
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Leap()
	local aimAt = self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()
    local dist = self:GetPos():Distance(aimAt)
    local vel = self:Trajectory(self:GetPos(), aimAt+self:GetEnemy():GetVelocity()*(dist/3000), 1000)
    vel.z = vel.z*2
    self:SetVelocity(vel)
	self.LeapCoroutine = coroutine.create(function()
	self:VJ_ACT_PLAYACTIVITY("Combat_Leap_Start",true,false,false) -- play start leaping animation
	if self:IsOnGround() then
		coroutine.yield()
	end
    
	while not self:IsOnGround() do
		self:VJ_ACT_PLAYACTIVITY("Combat_Leap_Airborne",true,false,false)
		if enemyInMeleeRange then
		-- leap attack code
		return
    end
            coroutine.yield()
        end
        self:VJ_ACT_PLAYACTIVITY("Combat_Leap_Land",true,false,false) -- play landing animation
    end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "Step" then
		self:EmitSound("infested_shared/walk/walk"..math.random(1,6)..".wav", 70, 100, 1)
	
	elseif key == "Melee1" then
		self:EmitSound("infested_elite/stand_pistol_melee_1/stand_pistol_melee_1.wav", 70, 100, 1)
		self:EmitSound("infested_shared/melee/melee"..math.random(1,6)..".wav", 70, 100, 1)
	
	elseif key == "Melee2" then
		self:EmitSound("infested_elite/stand_pistol_melee_2/stand_pistol_melee_2.wav", 70, 100, 1)
		self:EmitSound("infested_shared/melee/melee"..math.random(1,6)..".wav", 70, 100, 1)	
		
	elseif key == "Hit" then
		self:MeleeAttackCode()
	
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/