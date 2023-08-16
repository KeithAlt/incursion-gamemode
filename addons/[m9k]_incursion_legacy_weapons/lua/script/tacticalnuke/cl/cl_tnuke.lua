////////////////////////////////////////////////////////////////
// Tactical Nuke, Client
// By Svn
///////////////////////////////////////////////////////////////
//Editing this file will invalidate your support warranty.////

//////////////////
if CLIENT then
/////////////////
------------------------------------------------------------------------
-- Scalars
------------------------------------------------------------------------
-- Resources
surface.CreateFont( "TNUKE_VGUI_BASE", {
	font = "BankGothic Md BT",
	extended 	= false,
	size 		= 60,
	weight 		= 500,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false,
})
------------------------------------------------------------------------
-- VGUI
local show = false
local time = nil
function TNUKE_ACTIVATETIMER()
	time = 45
	timer.Create("TNUKE_TIMER",1,0,function()
		time = time - 1
	end)
	timer.Simple(45,function()
		timer.Remove("TNUKE_TIMER")
		time = 45
	end)
end
function TNUKE_TRIGGER()
	surface.PlaySound("svn/war.mp3")
	timer.Create("TNUKE_TIMER_VGUI",1,1,function()
		show = true
		TNUKE_ACTIVATETIMER()
		timer.Simple(45,function()
			show = false
		end)
	end)
end
net.Receive("TNUKE_NETWORK_CLIENT",function()
	TNUKE_TRIGGER()
end)
local start = Material("svn/start.png")
local slide2 = Material("svn/slide2.png")
local slide3 = Material("svn/slide3.png")
local slide4 = Material("svn/slide4.png")
local slide5 = Material("svn/slide5.png")
local slide6 = Material("svn/slide6.png")
local slide7 = Material("svn/slide7.png")
local slide8 = Material("svn/slide8.png")
local slide9 = Material("svn/slide9.png")
local slide10 = Material("svn/slide10.png")
local slide11 = Material("svn/slide11.png")
hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
	if show == true then
		if time < 35.0 then
			surface.SetDrawColor(233,233,233,255)
			surface.SetMaterial(start)
			surface.SetTextPos(30, 30)
			surface.DrawTexturedRect(0, 0, 2000, 1200)
			surface.SetTextColor(0,165,255,255)
			surface.SetFont("TNUKE_VGUI_BASE")
		end
	end
if show == true then
	if time > 42.5 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(start)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 32.5 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide2)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 28.5 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide3)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 23.5 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide4)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 18.2 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide5)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 15.5 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide6)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 12.8 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide7)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 9 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide9)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 5 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide10)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end
if show == true then
	if time > 2 then
		return
	else
		surface.SetDrawColor(233,233,233,255)
		surface.SetMaterial(slide11)
		surface.SetTextPos(30, 25)
		surface.DrawTexturedRect(0, -50, 2000, 1200)
		surface.SetTextColor(0,165,255,255)
		surface.SetFont("TNUKE_VGUI_BASE")
	end
end

end)






////////
end
///////
