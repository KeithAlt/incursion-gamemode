-------------------------------------
---------------- Cuffs --------------
-------------------------------------
-- Copyright (c) 2015 Nathan Healy --
-------- All rights reserved --------
-------------------------------------
-- weapon_cuff_base.lua     SHARED --
--                                 --
-- Base swep for handcuffs.        --
-------------------------------------

AddCSLuaFile()

SWEP.Base = "weapon_cuff_base"

SWEP.Category = "Handcuffs"
SWEP.Author = "my_hat_stinks"
SWEP.Instructions = ""

SWEP.Slot = 3
SWEP.PrintName = "UnnamedLeash"

SWEP.IsLeash = true

local Col = {
	Text = Color(255,255,255), TextShadow = Color(0,0,0),
	
	BoxOutline = Color(0,0,0), BoxBackground = Color(255,255,255,20), BoxLeft = Color(255,0,0), BoxRight = Color(0,255,0),
}
local matGrad = Material( "gui/gradient" )
function SWEP:DrawHUD()
	if not self:GetIsCuffing() then
		if self:GetCuffTime()<=CurTime() then return end
		
		local w,h = (ScrW()/2), (ScrH()/2)
		
		surface.SetDrawColor( Col.BoxOutline )
		surface.DrawOutlinedRect( w-101, h+54, 202, 22 )
		surface.SetDrawColor( Col.BoxBackground )
		surface.DrawRect( w-100, h+55, 200, 20 )
		
		local CuffingPercent = math.Clamp( ((self:GetCuffTime()-CurTime())/self.CuffRecharge), 0, 1 )
		render.SetScissorRect( w-100, h+55, (w-100)+(CuffingPercent*200), h+75, true )
			surface.SetDrawColor( Col.BoxRight )
			surface.DrawRect( w-100,h+55, 200,20 )
			
			surface.SetMaterial( matGrad )
			surface.SetDrawColor( Col.BoxLeft )
			surface.DrawTexturedRect( w-100,h+55, 200,20 )
		render.SetScissorRect( 0,0,0,0, false )
		
		return
	end
	
	local w,h = (ScrW()/2), (ScrH()/2)
	
	draw.SimpleText( "Leashing target...", "HandcuffsText", w+1, h+31, Col.TextShadow, TEXT_ALIGN_CENTER )
	draw.SimpleText( "Leashing target...", "HandcuffsText", w, h+30, Col.Text, TEXT_ALIGN_CENTER )
	
	surface.SetDrawColor( Col.BoxOutline )
	surface.DrawOutlinedRect( w-101, h+54, 202, 22 )
	surface.SetDrawColor( Col.BoxBackground )
	surface.DrawRect( w-100, h+55, 200, 20 )
	
	local CuffingPercent = math.Clamp( 1-((self:GetCuffTime()-CurTime())/self.CuffTime), 0, 1 )
	
	render.SetScissorRect( w-100, h+55, (w-100)+(CuffingPercent*200), h+75, true )
		surface.SetDrawColor( Col.BoxRight )
		surface.DrawRect( w-100,h+55, 200,20 )
		
		surface.SetMaterial( matGrad )
		surface.SetDrawColor( Col.BoxLeft )
		surface.DrawTexturedRect( w-100,h+55, 200,20 )
	render.SetScissorRect( 0,0,0,0, false )
end
