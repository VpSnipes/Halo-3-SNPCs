/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "Halo 3 SNPCs"
local AddonName = "Halo 3 SNPCs"
local AddonType = "SNPC"
local AutorunFile = "autorun/h3_autorun.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')
	local vCat = "Halo 3"
	
	if(steamid != "STEAM_0:0:22688298") or (steamid != "STEAM_0:0:38270154") then
	--==__Covenant__==--
		VJ.AddNPC("Hunter","npc_vj_h3_cov_hunter",vCat)
		VJ.AddNPC("Hunter Golden","npc_vj_h3_cov_hunter_gold",vCat)
		VJ.AddNPC("Scarab","npc_vj_h3_cov_scarab",vCat)
	end

	-- precache -- 
game.AddParticles( "particles/npcarmor.pcf" )
PrecacheParticleSystem( "npcarmor_break" )
PrecacheParticleSystem( "npcarmor_hit" )
game.AddParticles("particles/halo_beam.pcf")
	local particlename = {
		"halo_beam_main",
		"halo_beam_trail_1",
		"halo_beam_trail_2",
		"halo_beam_trail_3",
		"halo_beam_trail_glow_1",
		"halo_beam_trail_glow_2",
		"halo_beam_trail_glow_3",
		
		"hcea_flood_car_death",
		"hcea_flood_inf_death",
		
		"hcea_hunter_charge",
		"hcea_hunter_frnade_hit",
		"hcea_hunter_frnade_nade",
		"hcea_hunter_frnade_nade_beam_2",
		"hcea_hunter_frnade_nade_embers"
	}
for _,v in ipairs(particlename) do PrecacheParticleSystem(v) end

sound.Add( {
	name = "mana.shield.depleted",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {97, 103},
	sound = "player/shield_deplete.wav"
} )

sound.Add( {
	name = "mana.shield.recharge",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = {97, 103},
	sound = "player/shield_recharge.wav"
} )

sound.Add( {
	name = "mana.shield.damage",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 50,
	pitch = {100, 120},
	sound = "player/shield_damage_2.wav"
} )

sound.Add( {
	name = "mana.shield.maxed",
	channel = CHAN_STATIC,
	volume = 1,
	level = 60,
	pitch = PITCH_NORM,
	sound = "player/shield_maxed.wav"
} )

sound.Add( {
	name = "mana.shield.depleted.npc",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {97, 103},
	sound = "player/shield_deplete.wav"
} )

sound.Add( {
	name = "mana.shield.damage.npc",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	pitch = {100, 120},
	sound = "player/shield_damage_2.wav"
} )

-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("VJ Base is not installed")
				VJF:SetSize(900,800)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end
				local VJURL = vgui.Create("DHTML")
				VJURL:SetParent(VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				local x,y = VJF:GetSize()
				VJURL:SetSize(x*0.99,y*0.96)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end