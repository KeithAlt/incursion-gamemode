if (SERVER) then // This is where the init.lua stuff goes.
	AddCSLuaFile ("shared.lua")
	SWEP.Weight = 5	
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 end
SWEP.UseHands = true

if (CLIENT) then 
	SWEP.PrintName = "Flash Bang"
	SWEP.Slot = 4
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end
 
SWEP.Author = "Rogue Cheney"
SWEP.Contact = "baldursgate3@gmail.com"
SWEP.Purpose = "Shoots Rockets"
SWEP.Instructions = "Do not point at your face"
 

SWEP.Category = "Garry's Bombs 4"
 
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
 
SWEP.ViewModel = "models/weapons/gbombs/c_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl" 

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
 


			
function SWEP:Reload()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:EmitSound("weapons/flashbang/flashbang_draw.wav")

end
 
function SWEP:Think()	
	if (CLIENT) then 	
		function func_Aim()
		
			local r = math.Clamp(((255/3) *  math.Clamp(self:GetNWFloat("NextUse")-CurTime(),0,3)), 0, 255)
			local velocity = math.Clamp(50 - LocalPlayer():GetVelocity():Length() / 5, -10, 50)
			
			local function func_DrawAimCross()
			
				local values = {2.1, 1.9, 2.23, 1.8}	
				local v1, v12 = Vector(  (ScrW()/values[1] - velocity - (r/10)) , (ScrH()/values[1] - velocity - (r/10)), 0) , Vector( (ScrW()/values[3]  - (velocity*1.5 + (r/10)  ))  ,  (ScrH()/values[3]  - (velocity*1.5 + (r/10)))   , 0)
				local v2, v22 = Vector(  (ScrW()/values[2] + velocity + (r/10)) , (ScrH()/values[1] - velocity - (r/10)), 0) , Vector( (ScrW()/values[4]  + (velocity*1.5  + (r/10)))  , (ScrH()/values[3]    - (velocity*1.5+ (r/10)))   , 0)
				local v3, v32 = Vector(  (ScrW()/values[1] - velocity - (r/10)) , (ScrH()/values[2] + velocity + (r/10)), 0) , Vector( (ScrW()/values[3]  - (velocity*1.5  + (r/10) )) ,  (ScrH()/values[4]   + (velocity*1.5+ (r/10)))   , 0)
				local v4, v42 = Vector(  (ScrW()/values[2] + velocity + (r/10)) , (ScrH()/values[2] + velocity + (r/10)), 0) , Vector( (ScrW()/values[4]  + (velocity*1.5  + (r/10))) ,  (ScrH()/values[4]    +  (velocity*1.5+ (r/10)))  , 0)
			
				surface.SetDrawColor( 255, 25, 25, math.abs(255 * math.sin(CurTime() * 2))  )
				surface.DrawLine( v1.x, v1.y, v12.x, v12.y )
				surface.DrawLine( v2.x, v2.y, v22.x, v22.y )
				surface.DrawLine( v3.x, v3.y, v32.x, v32.y )
				surface.DrawLine( v4.x, v4.y, v42.x, v42.y )
			
			end
			
	
			local function func_DrawAimCircle()
				surface.SetDrawColor( r, 255-r, 25, 255 )
				for i=0, 360, 15 do
					local x, x2 = math.cos( math.rad(i) ) * (25 + velocity + (r/10)) + (ScrW()/2), (math.cos( math.rad(i) ) * (40+ (velocity*1.5) + (r/10)) )  + (ScrW()/2)  
					local y, y2 = math.sin( math.rad(i) ) * (25 + velocity + (r/10)) + (ScrH()/2), (math.sin( math.rad(i) ) * (40+ (velocity*1.5) + (r/10)) )  + (ScrH()/2)
				

					surface.DrawLine( x, y, x2, y2)
				end
				
			end
			local function func_DrawAimReload()
				surface.SetDrawColor( 255, 255, 255, 255 )
				
				r = 160+(100/255*r)
				local x, x2 = math.cos( math.rad(r) ) * (50 + velocity + (r/10)) + (ScrW()/2), (math.cos( math.rad(r) ) * (255+ (velocity*1.5) + (r/10)) )  + (ScrW()/2)  
				local y, y2 = math.sin( math.rad(r) ) * (50 + velocity + (r/10)) + (ScrH()/2), (math.sin( math.rad(r) ) * (255+ (velocity*1.5) + (r/10)) )  + (ScrH()/2)
			
				local x3, x32 = math.cos( math.rad(r+40) ) * (50 + velocity + (r/10)) + (ScrW()/2), (math.cos( math.rad(r+40) ) * (255+ (velocity*1.5) + (r/10)) )  + (ScrW()/2)  
				local y3, y32 = math.sin( math.rad(r+40) ) * (50 + velocity + (r/10)) + (ScrH()/2), (math.sin( math.rad(r+40) ) * (255+ (velocity*1.5) + (r/10)) )  + (ScrH()/2)
				
				surface.DrawLine( x3, y3, x32, y32 )
				surface.DrawLine( x, y, x2 , y2 )
			end	
		
			local function func_DrawAimText()
				
				
				

				
				draw.DrawText( "Ammo remaining: "..LocalPlayer():GetNWInt("ammo_flashbang"), "Rescaled", ScrW() / 1.99, ScrH() / (1.8 - (velocity / 300)) , Color(255,255,255,255), TEXT_ALIGN_CENTER )
			end
			
			func_DrawAimText()
			func_DrawAimCross()
			func_DrawAimCircle()

			

			
			
			hook.Remove("RenderScreenspaceEffects", "Aim", func_Aim)
			
		end
		hook.Add("RenderScreenspaceEffects", "Aim", func_Aim)

	end
end

function SWEP:CanUse()
	if !(SERVER) then return end
	if self.NextUse==nil then self.NextUse = CurTime() - 3 end
	
	if CurTime() > self.NextUse then self.NextUse = CurTime() + 3 self:SetNWFloat("NextUse", CurTime() + 3) return true else return false end
	
end
 
function SWEP:TakeAmmo()
	if !self.Owner:IsValid() then return end

	
	if self.Owner:GetNWInt("ammo_flashbang") > 0 then
		self.Owner:SetNWInt("ammo_flashbang", self.Owner:GetNWInt("ammo_flashbang") - 1 )
		return true
	else
		return false
	end
	
end


function SWEP:PrimaryAttack()
	if !(SERVER) then return end
	if !self:CanUse() then return end
	if !self:TakeAmmo() then return end
	
	self:EmitSound("weapons/flashbang/pinpull.wav")
	self:SendWeaponAnim(ACT_VM_THROW)
	
	
	local ent = ents.Create("gb_flashbng")
	ent:SetAngles(self.Owner:GetAngles())
	ent:SetPos(self:GetBonePosition(self:LookupBone("ValveBiped.Grenade_body")) + self.Owner:GetForward() * 50)
	ent:Spawn()
	ent.GBOWNER=self.Owner
	ent:Arm()
	

	ent:SetPhysicsAttacker( self.Owner, 0 )
	self.Owner:ChatPrint( (5 - math.Clamp(self.Owner:GetVelocity():Length(), 0, 5)))
	ent:GetPhysicsObject():AddVelocity( self.Owner:GetVelocity() + self.Owner:GetAimVector() * 500 + (Vector(math.random(-100,100)/2,math.random(-100,100)/2,math.random(-100,100)/2) * (5 - math.Clamp(self.Owner:GetVelocity():Length(), 0, 5)) ))
	ent:GetPhysicsObject():AddAngleVelocity(Vector(0,1000,0))
	
	timer.Simple(self:SequenceDuration(), function()
		if self:IsValid()==false  then return end
		if self.Owner:IsValid()==false then return end
		
		if self.Owner:GetActiveWeapon():GetClass() != self:GetClass() then return end
	
		self:Reload()
	end)
end
 
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_IDLE)
end


function SWEP:Holster()
	return true
 end