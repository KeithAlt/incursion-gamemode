if (SERVER) then // This is where the init.lua stuff goes.
	AddCSLuaFile ("shared.lua")
	SWEP.Weight = 5	
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 end
 
if (CLIENT) then 
	SWEP.PrintName = "Bazooka RPG"
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
 
SWEP.ViewModel = "models/weapons/v_RPG.mdl"
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
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self.entity_Target = nil
	self.Owner:SetNWEntity("entity_LockedOn", "gay")
	
end
 
function SWEP:Think()
	if (CLIENT) then 	
		function func_Aim()
		
			local r = math.Clamp(((255/3) *  math.Clamp(self:GetNWFloat("NextUse")-CurTime(),0,3)), 0, 255)
			local velocity = 1 + LocalPlayer():GetVelocity():Length() / 10
			
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
				
				draw.DrawText( "STATS\n Distance: "..math.Round(LocalPlayer():GetEyeTrace().HitPos:Distance(LocalPlayer():GetPos())*0.01905).."m".."\n Accuracy (+-): "..(math.Round(LocalPlayer():GetEyeTrace().HitPos:Distance(LocalPlayer():GetPos())*0.01905 + (LocalPlayer():GetVelocity():Length() ))/25  ).."m\nRange: 213m\n Can reach:               ", "Rescaled", ScrW() / (1.75 - (velocity / 500)), ScrH() / 2.2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
				
				local color_Indicator = Color(255,255,255,255)
				local text            = ""
				
				if math.Round(LocalPlayer():GetEyeTrace().HitPos:Distance(LocalPlayer():GetPos())*0.01905) > 213 then
					color_Indicator = Color(255,0,0,255)
					text            = " false"
				else
					color_Indicator = Color(0,255,0,255)
					text            = " true"
				end
				
				draw.DrawText( text, "Rescaled", ScrW() / (1.71 - (velocity / 500)), ScrH() / 1.946, color_Indicator, TEXT_ALIGN_CENTER )
				
				draw.DrawText( "Ammo remaining: "..LocalPlayer():GetNWInt("ammo_bazrocket"), "Rescaled", ScrW() / 1.99, ScrH() / (1.8 - (velocity / 300)) , Color(255,255,255,255), TEXT_ALIGN_CENTER )
			end
			
			func_DrawAimText()
			func_DrawAimCross()
			func_DrawAimCircle()
			func_DrawAimReload()
			
			
			local function func_DrawAimLockon()
				print(LocalPlayer():GetNWEntity("entity_LockedOn"))
				local lockon_1 = surface.GetTextureID("hud/lockon_1")
				local lockon_2 = surface.GetTextureID("hud/lockon_2")
				local lockon_3 = surface.GetTextureID("hud/lockon_3")
				local entity =  LocalPlayer():GetNWEntity("entity_LockedOn")
				local entitypos = LocalPlayer():GetNWEntity("entity_LockedOn"):GetPos():ToScreen()
				
				surface.SetDrawColor( 255, 255, 255, 255/100 * entity:GetNWFloat("health") )
				
				
				
				surface.SetTexture(lockon_1)
				surface.DrawTexturedRectRotated( entitypos.x, entitypos.y, 150, 150,CurTime()*60 )
				
				
				surface.SetTexture(lockon_2)
				surface.DrawTexturedRectRotated( entitypos.x, entitypos.y, 256, 256,CurTime()*-60 )
				
				
				surface.SetTexture(lockon_3)
				
				

				surface.DrawTexturedRectRotated( entitypos.x, entitypos.y, 200, 200, math.sin(CurTime())*360 )
	
				
			end

			if LocalPlayer():GetNWEntity("entity_LockedOn")!=nil and LocalPlayer():GetNWEntity("entity_LockedOn")!="gay" then 
				
				if !LocalPlayer():GetNWEntity("entity_LockedOn"):IsValid()==false then 
					func_DrawAimLockon() 
				end	
			end
			

			
			
			hook.Remove("RenderScreenspaceEffects", "Aim", func_Aim)
			
		end
		hook.Add("RenderScreenspaceEffects", "Aim", func_Aim)

		
	elseif (SERVER) then
		self:Taunt()
	end
end
function SWEP:CanUse()
	if !(SERVER) then return end
	if self.NextUse==nil then self.NextUse = CurTime() - 3 end
	
	if CurTime() > self.NextUse then self.NextUse = CurTime() + 3 self:SetNWFloat("NextUse", CurTime() + 3) return true else return false end
	
end
 
function SWEP:TakeAmmo()
	if !self.Owner:IsValid() then return end

	
	if self.Owner:GetNWInt("ammo_bazrocket") > 0 then
		self.Owner:SetNWInt("ammo_bazrocket", self.Owner:GetNWInt("ammo_bazrocket") - 1 )
		return true
	else
		return false
	end
	
end
function SWEP:Taunt()
	if self.NextTaunt==nil then self.NextTaunt = CurTime() - 9 end
	if !self.Owner:KeyDown(IN_USE) then return end
	

	if CurTime() > self.NextTaunt then self.Owner:EmitSound(table.Random({"sweps/rpg_taunt_01.wav","sweps/rpg_taunt_02.wav", "sweps/rpg_taunt_03.wav"}), 100, math.random(90,110)) self.NextTaunt = CurTime() + 9 end
end


function SWEP:Recoil()
	if !self.Owner:IsValid() then return end
	self.Owner:SetVelocity(self.Owner:GetVelocity() - self.Owner:GetForward() * 100)
	
	
end

function SWEP:PrimaryAttack()
	if !(SERVER) then return end
	if !self:CanUse() then return end
	if !self:TakeAmmo() then return end
	self:Recoil()
	
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:EmitSound("sweps/rpg_launch.wav")
	
	local ent = ents.Create("gb_bazrocket")
	ent:SetAngles(self.Owner:GetAngles())
	ent:SetPos(self:GetAttachment(self:LookupAttachment("laser")).Pos + Vector(0,0,100))
	ent:Spawn()
	ent:Launch()
	ent.GBOWNER=self.Owner
	ent.entity_Target = self.entity_Target
	ent:SetPhysicsAttacker( self.Owner, 0 )
	ent:GetPhysicsObject():SetVelocity(ent:GetForward() * 500)
	
		
	ent:GetPhysicsObject():AddAngleVelocity( Vector(math.random(-100, 100)/100,math.random(-100, 100)/100,math.random(-100, 100)/100)* ( self.Owner:GetVelocity():Length()/ 10))
	timer.Simple(self:SequenceDuration(), function()
		if self:IsValid()==false  then return end
		if self.Owner:IsValid()==false then return end
		
		if self.Owner:GetActiveWeapon():GetClass() != self:GetClass() then return end
	
		self:Reload()
	end)
end
 

function SWEP:SecondaryAttack()	
	if !self.Owner:GetEyeTrace().Entity.isWacAircraft then return end
	self.Owner:ChatPrint("Locked onto ".. self.Owner:GetEyeTrace().Entity:GetClass())
	self.entity_Target = self.Owner:GetEyeTrace().Entity
	self.Owner:SetNWEntity("entity_LockedOn", self.entity_Target)

	self.entity_Target:EmitSound("ambient/alarms/warningbell1.wav")

end
  
 function SWEP:Holster()
	return true
 
 end