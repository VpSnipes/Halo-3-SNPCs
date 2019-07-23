if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "proj_drg_default"

-- Misc --
ENT.PrintName = "Beam"
ENT.Category = "Halo 3"

-- Physics --
ENT.Gravity = false
ENT.Physgun = false
ENT.Gravgun = false

-- Contact --
ENT.OnContactDelete = 0
ENT.OnContactDecals = {"Scorch"}

-- Sounds --
ENT.LoopSounds = {"halo3/cov/hunter/hunter_cannon/hunter_cannon_loop/hunter_cannon/loop.wav"}
ENT.OnContactSounds = {}
ENT.OnRemoveSounds = {
  "halo3/cov/weapons/fuel rod gun/explosion/fuelrod_explo1.wav",
  "halo3/cov/weapons/fuel rod gun/explosion/fuelrod_explo2.wav",
  "halo3/cov/weapons/fuel rod gun/explosion/fuelrod_explo3.wav"
}

-- Effects --
ENT.AttachEffects = {"hcea_hunter_frnade_nade"}
ENT.OnContactEffects = {}
ENT.OnRemoveEffects = {"hcea_hunter_frnade_hit"}

if SERVER then
  AddCSLuaFile()

  function ENT:CustomInitialize()
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
  end

  function ENT:OnContact(ent)
    if ent == self:GetOwner() then return end
    self:DynamicLight(Color(255, 150, 0), 300, 4)
    self:DealDamage(ent, 12, DMG_BLAST)
  end

end
