include('shared.lua')

SWEP.PrintName			= "Tomahawk"						// 'Nice' Weapon name (Shown on HUD)	
SWEP.Slot				= 0							// Slot in the weapon selection menu
SWEP.SlotPos			= 2							// Position in the slot

// Override this in your SWEP to set the icon in the weapon selection
if (file.Exists("materials/weapons/weapon_mad_knife.vmt","GAME")) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_knife")
end

///////////
//CUSTOM CROSSHAIR CREATED FOR CODFAG PLEASING PURPOSES//
function SWEP:DrawHUD()

	self:SecondDrawHUD()
	self:DrawFuelHUD()

	if (self.Weapon:GetDTBool(1)) or (cl_crosshair_t:GetBool() == false) or (LocalPlayer():InVehicle()) then return end

	local hitpos = util.TraceLine ({
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 4096,
		filter = LocalPlayer(),
		mask = MASK_SHOT
	}).HitPos

	local screenpos = hitpos:ToScreen()
	
	local x = screenpos.x
	local y = screenpos.y
	
	if self.Primary.Cone < 0.005 then
		self.Primary.Cone = 0.005
	end
	
	local gap = ((self.Primary.Cone * 275) + (((self.Primary.Cone * 275) * (ScrH() / 720))) * (1 / self:CrosshairAccuracy())) * 0.75

	gap = math.Clamp(gap, 0, (ScrH() / 2) - 100)
	local length = cl_crosshair_l:GetInt()

	self:DrawCrosshairHUD(x - gap - (length/2), y - 1, (length/2), 3) 	// Left
	self:DrawCrosshairHUD(x + gap + 1, y - 1, (length/2), 3)	// Right
 	self:DrawCrosshairHUD(x - 1, y - gap - length, 3, length) 	// Top 
 	self:DrawCrosshairHUD(x - 1, y + gap + 1, 3, length) 		// Bottom
end
