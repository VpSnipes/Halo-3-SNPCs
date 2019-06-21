ENT.Base 			= "npc_vj_creature_base"
ENT.Type 			= "ai"
ENT.PrintName 		= "Flood Elite"
ENT.Author 			= "Mayhem"
ENT.Contact 		= "http://vrejgaming.webs.com/"
ENT.Purpose 		= "Let it eat you."
ENT.Instructions	= "Click on it to spawn it."
ENT.Category		= "Halo 3 SNPCs"

ENT.m_bArmorEnabled = true
ENT.m_nArmorRegenTime = 0
ENT.m_nArmorDownTime = 0
ENT.m_nArmor = 70
ENT.m_nArmorDelta = 70
ENT.m_nArmorMax = 70

if ( SERVER ) then
    util.AddNetworkString( "NpcArmor" )
   
    function ENT:SetArmor( iArmor )
        if ( !iArmor || !isnumber( iArmor ) ) then return end
       
        iArmor = math.Round( iArmor )
       
        if ( !self.m_nArmorMax ) then
            self.m_nArmorMax = iArmor
        end
 
        net.Start( "NpcArmor" )
        net.WriteInt( iArmor, 16 )
        net.WriteEntity( self )
        net.Broadcast()
       
        self.m_nArmor = iArmor
    end
end
 
if ( CLIENT ) then
    net.Receive( "NpcArmor", function( len, ply )
        local iValue = net.ReadInt( 16 )
       
        if ( !iValue ) then return end
       
        local npcTarget = net.ReadEntity()
       
        if ( !IsValid( npcTarget ) ) then return end
       
        if ( !npcTarget.m_nArmorMax ) then
            npcTarget.m_nArmorMax = iValue
        end
       
        npcTarget.m_nArmor = iValue
    end )
end
 
function ENT:Armor()
 
    if ( !self.m_nArmor ) then
        self.m_nArmor = 0
        return 0
    else
        return self.m_nArmor
    end
 
end

function ENT:CustomOnThink()
    if ( !SERVER ) then return end
 
    if ( !self.Armor ) then return end
   
    -- Create the delta value so we can make accurate comparisons.
    if ( !self.m_nArmorDelta ) then
        self.m_nArmorDelta = 0
    end
 
    -- Create timing referenes.
    if ( !self.m_nArmorRegenTime || !self.m_nArmorDownTime ) then
        self.m_nArmorRegenTime = 0
        self.m_nArmorDownTime = 0
    end
 
    -- Is it a player?
    local iMaxArmor = self.m_nArmorMax || 70
    local iCurArmor = self:Armor()

    -- Recharge shields if we haven't received damage in quite a while.
    if ( self.m_nArmorRegenTime < CurTime() ) && ( iCurArmor < iMaxArmor ) then
        -- For the initial regeneration, play the shield regen effect.
        if ( self.m_nArmorDownTime >= self.m_nArmorRegenTime ) then
            self:EmitSound( "mana.shield.recharge" )
           
            self:MakeEffect( "wraith_wirefade", self )
        end
 
        self:SetArmor( iCurArmor + 1 )
       
        self.m_nArmorRegenTime = CurTime() + 0.028
    end
   
    -- Deplete shields
    if ( iCurArmor < self.m_nArmorDelta ) || ( iCurArmor == 0 && self.m_nArmorRegenTime < CurTime() ) then
        if ( iCurArmor <= 0 ) then
            if ( bPlayer ) then
                self:EmitSound( "mana.shield.depleted" )
            else
                -- Shield deplete sound is louder for NPCs, to properly communicate the game state to the player.
                self:EmitSound( "mana.shield.depleted.npc" )
               
                -- NPCs that are in combat and have their shields broken will attempt to take cover.
                if !( self:GetCurrentSchedule() == SCHED_NPC_FREEZE ) && ( self:Health() > 0 ) && !( self:GetEnemy() == NULL ) then
                    self:SetSchedule( SCHED_TAKE_COVER_FROM_ENEMY )
                end
            end
           
            -- Shield break effect.
            self:MakeEffect( "wraith_wireflicker", self )
        else
            if ( bPlayer ) then
                self:EmitSound( "mana.shield.damage" )
            end
           
            -- Shield hurt effect.
            self:MakeEffect( "wraith_wireflicker_short", self )
        end
   
        -- We have taken damage. 4 seconds until we are able to recover.
        self.m_nArmorRegenTime = CurTime() + 5
        self.m_nArmorDownTime = CurTime() + 5
    end
 
    -- Shields have hit max. Player a sound to let the player know. (Technically this is also playing for NPCs, but who cares, really)
    if ( iCurArmor > self.m_nArmorDelta ) && ( iCurArmor == iMaxArmor ) then
        self:EmitSound( "mana.shield.maxed" )
    end
   
    -- Write current data into delta cache.
    self.m_nArmorDelta = iCurArmor
end

function ENT:CustomOnTakeDamage_BeforeDamage( dmginfo, hitgroup )
	if ( self:Armor() < 1 ) then return end
 
    local iDamage = dmginfo:GetDamage()
    local iArmor = self:Armor()
 
    local iDamageToShield = math.max( iArmor - iDamage, 0 )
    self:SetArmor( iDamageToShield )
 
    -- Acquire the damage position. This is basically only relevant for bullet traces, otherwise the world origin will be returned.
    local vDamageOrigin = dmginfo:GetDamagePosition()
    if ( !vDamageOrigin || vDamageOrigin:IsZero() ) then
        vDamageOrigin = self:GetPos() + ( self:EyePos() - self:GetPos() ) * 0.5
    end
   
    if ( self:Armor() > 0 ) then
        -- Take damage to shield
        if ( !vDamageOrigin:IsZero() ) then
            ParticleEffect( "npcarmor_hit", vDamageOrigin, Angle( 0, 0, 0 ), self )
        end
 
        dmginfo:ScaleDamage( 0 )
    else
        -- Shields down. Note, that the scripted effect is not applied here. See the OnThink() hook down below.
        ParticleEffectAttach( "hcea_shield_disperse", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
 
        -- Special particle effect if the incoming damage is high enough to knock out 100% of the shield in one hit.
        if ( iArmor == self.m_nArmorMax ) then
            ParticleEffect( "eml_generic_shock", vDamageOrigin, Angle( 0, 0, 0 ), NULL )
        end
    end
end

function ENT:MakeEffect( sEffectName, entParentOverride )
    local entParent = self
    
    if ( entParentOverride ) then
        entParent = entParentOverride
    end
    
    local fxData = EffectData()
    fxData:SetEntity( entParent )

    util.Effect( sEffectName, fxData )
end