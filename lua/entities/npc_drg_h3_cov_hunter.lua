if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Hunter NB"
ENT.Category = "Halo 3"
ENT.Models = {"models/halo3/cov/hunter/h3_hunter.mdl"}
ENT.Skins = {0}
ENT.ModelScale = 1
ENT.CollisionBounds = Vector(40, 40, 100)
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = true

-- Stats --
ENT.SpawnHealth = 250
ENT.HealthRegen = 0
ENT.DamageMultipliers = {
  [DMG_SLASH] = 0.15
}

-- Sounds --
ENT.OnSpawnSounds = {}
ENT.OnIdleSounds = {}
ENT.IdleSoundDelay = 2
ENT.ClientIdleSounds = false
ENT.OnDamageSounds = {}
ENT.DamageSoundDelay = 0.25
ENT.OnDeathSounds = {}

-- AI --
ENT.RangeAttackRange = 1300
ENT.MeleeAttackRange = 300
ENT.ReachEnemyRange = 1200
ENT.AvoidEnemyRange = 0

-- Movements/animations --
ENT.UseWalkframes = true

-- Relationships --
ENT.Factions = {"FACTION_COV"}

-- Detection --
ENT.EyeBone = "headextend"
ENT.EyeOffset = Vector(0, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(0, 60, 15),
    distance = 150
  },
  {
    offset = Vector(10, 0, 0),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {
  [IN_ATTACK] = {
    {
      coroutine = true,
      onkeydown = function(self)
        if self:IsAttacking() then return end
        self:PlaySequenceAndMove("Melee_Var_"..math.random(3), 1, function()
          if self.MeleeAttackAnimationFaceEnemy then self:PossessionFaceForward() end
        end)
      end
    }
  },
  [IN_ATTACK2] = {
    {
      coroutine = true,
      onkeydown = function(self)
        if self:IsAttacking() then return end
        if self:GetCooldown("RangeAttack") > 0 then return end
        self:PlaySequence("gesture_fire_weapon")
      end
    }
  },
  [IN_RELOAD] = {
    {
      coroutine = true,
      onkeydown = function(self)
        self:PlaySequenceAndWait("Taunt")
      end
    }
  },
  [IN_DUCK] = {
    {
      coroutine = true,
      onkeydown = function(self)
        self:SetCrouching(not self:IsCrouching())
      end
    }
  }
}

-- Misc --

function ENT:IsCrouching()
  return self:GetNW2Bool("Crouching")
end

if SERVER then

  -- Init/Think --

  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:SetAttack({"Melee_Var_1", "Melee_Var_2", "Melee_Var_3"}, true)
    self:SetAttack("gesture_fire_weapon", true)
    self:PrintAnimations()
  end
  function ENT:CustomThink()
    if self:IsPossessed() then return end
    if self:HasEnemy() then
      if math.random(1000) == 1 then
        self:SetCrouching(not self:IsCrouching())
      end
    else self:SetCrouching(false) end
  end

  -- AI --

  function ENT:OnRangeAttack(enemy)
    self:FaceTowards(enemy)
    if self:IsAttacking() then return end
    if self:GetCooldown("RangeAttack") > 0 then return end
    self:FaceTo(enemy)
    if not IsValid(enemy) then return end
    self:PlaySequence("gesture_fire_weapon")
  end

  function ENT:OnMeleeAttack(enemy)
    if self:IsInRange(enemy, 100) then
      self:PlaySequenceAndMove("Melee_Var_"..math.random(3), 1, function()
        if self.MeleeAttackAnimationFaceEnemy then self:FaceEnemy() end
      end)
    else self:FollowPath(enemy) end
  end

  function ENT:OnReachedPatrol()
    self:Wait(math.random(3, 7))
  end

  function ENT:OnIdle()
    self:AddPatrolPos(self:RandomPos(1500))
  end

  -- Attacks --

  function ENT:BeamAttack()
    local proj = self:CreateProjectile(nil, {}, "proj_drg_h3_beam")
    proj:SetPos(self:GetAttachment(1).Pos)
    local speed = 2000
    if self:IsPossessed() then proj:AimAt(self:PossessorTrace().HitPos, speed)
    elseif self:HasEnemy() then proj:AimAt(self:GetEnemy():WorldSpaceCenter(), speed)
    else proj:AimAt(self:GetPos() + self:GetForward()*1000, speed) end
  end

  -- Animations --

  function ENT:OnUpdateAnimation()
    if self:IsMoving() then
      if self:IsCrouching() then return ACT_WALK_CROUCH
      elseif (self:IsPossessed() or self:HasEnemy()) then
        if self:IsRunning() then return ACT_RUN
        else return ACT_WALK end
      else return ACT_WALK_RELAXED end
    elseif self:IsCrouching() then return ACT_IDLE_ANGRY
    else return ACT_IDLE end
  end

  function ENT:SetCrouching(crouching)
    if crouching == self:IsCrouching() then return end
    if coroutine.running() then
      if crouching then
        self:PlaySequenceAndMove("idle_to_crouch")
      else
        self:PlaySequenceAndMove("crouch_to_idle")
      end
      self:SetNW2Bool("Crouching", crouching)
    else
      self:CallInCoroutine(function(self)
        self:SetCrouching(crouching)
      end)
    end
  end

  -- Events --

  function ENT:HandleAnimEvent(event, time, cycle, type, options)
  	if options == "Step" then
      self:EmitSound("halo3/cov/hunter/shortmove/move"..math.random(1,31)..".wav", 80, 90, 1)
      if not self:IsOnGround() then return end
  		self:EmitSound("halo3/cov/hunter/run/walk"..math.random(1,6)..".wav", 80, 90, 1)
  	elseif options == "Impact_Metal" then
  		self:EmitSound("halo3/cov/hunter/hard_metal_thick_cov_hunter/hard_metal_thick_cov_hunter"..math.random(1,4)..".wav", 80, 100, 1)
  	elseif options == "Melee_Vox" then
  		self:EmitSound("halo3/cov/hunter/melee/melee"..math.random(1,22)..".wav", 80, 90, 1)
  	elseif options == "Melee_Var_1" then
  		self:EmitSound("halo3/cov/hunter/melee_var1/melee_var1_"..math.random(1,3)..".wav", 80, 90, 1)
  	elseif options == "Melee_Var_2" then
  		self:EmitSound("halo3/cov/hunter/melee_var2/melee_var2_"..math.random(1,3)..".wav", 80, 90, 1)
  	elseif options == "Melee_Var_3" then
  		self:EmitSound("halo3/cov/hunter/melee_var3/melee_var3_"..math.random(1,3)..".wav", 80, 90, 1)
  	elseif options == "Posing_Var_1" then
  		self:EmitSound("halo3/cov/hunter/posing_var1/posing_var1_"..math.random(1,3)..".wav", 80, 90, 1)
  	elseif options == "Posing_Var_2" then
  		self:EmitSound("halo3/cov/hunter/posing_var2/posing_var2_"..math.random(1,3)..".wav", 80, 90, 1)
  	elseif options == "Posing_Var_3" then
  		self:EmitSound("halo3/cov/hunter/posing_var3/posing_var3_"..math.random(1,3)..".wav", 80, 90, 1)
  	elseif options == "Posing_Var_4" then
  		self:EmitSound("halo3/cov/hunter/posing_var4/posing_var4_"..math.random(1,3)..".wav", 80, 90, 1)
  	elseif options == "Charge_Weapon" then
      self:SetCooldown("RangeAttack", 5)
      self:ParticleEffect("hcea_hunter_frg_charge", true, 1)
  		self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_charge.wav", 80, 100, 1)
  	elseif options == "Laser_Start" then
  		self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_cannon_loop/hunter_cannon/in.wav", 80, 100, 1)
  	elseif options == "Laser_End" then
  		self:StopParticles()
  		self:EmitSound("halo3/cov/hunter/hunter_cannon/hunter_cannon_loop/hunter_cannon/out.wav", 80, 100, 1)
  	elseif options == "Hit" then
  		self:Attack({
        damage = 75,
        range = 50,
        type = DMG_SLASH,
        force = Vector(500, 0, 250),
        viewpunch = Angle(20, math.random(-10, 10), 0)
      }, function(self, hit)
        if #hit == 0 then return end
        self:EmitSound("halo3/cov/hunter/hunter_melee_hits/hunter_melee_hit"..math.random(6)..".wav")
      end)
  		self:ScreenShake(5, 100, 0.5, 250)
  	elseif options == "Fire_Weapon" then
  		self:BeamAttack()
  	elseif options == "TrackingOn" then
  		self.MeleeAttackAnimationFaceEnemy = true
  	elseif options == "TrackingOff" then
  		self.MeleeAttackAnimationFaceEnemy = false
  	end
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
