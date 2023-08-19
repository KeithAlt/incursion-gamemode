//Credits to Draco_2k for the code.
SWEP.Author			= "Lenny"
SWEP.Category		= "Fallout SWEPs - Custom"
SWEP.Purpose		= ""
SWEP.Instructions	= "Left-Click: Fire\nReload: Regenerate Ammunition"
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.HoldType = "crossbow"
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cleansingflamer/c_cleansingflamer_len.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.WElements = {
	["cleansingflamer"] = { type = "Model", model = "models/weapons/cleansingflamer/c_cleansingflamer_len.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-1.986, 6.526, -5.407), angle = Angle(-3.912, 0, 180), size = Vector(0.76, 0.76, 0.76), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Ammo		= "none"
SWEP.Secondary.ClipSize		= 120
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo		= "ar2"

SWEP.ReloadDelay = 0


//Precache everything
function SWEP:Precache()

	util.PrecacheSound("ambient/machines/keyboard2_clicks.wav")

	util.PrecacheSound("ambient/machines/thumper_dust.wav")
	util.PrecacheSound("ambient/fire/mtov_flame2.wav")
	util.PrecacheSound("ambient/fire/ignite.wav")

	util.PrecacheSound("vehicles/tank_readyfire1.wav")

end


//Primary attack
function SWEP:PrimaryAttack()

if (SERVER) then
	if (self.Owner:GetAmmoCount("ar2") < 1) || (self.ReloadDelay == 1) then
	self:RunoutReload()
	return end
	end

		if (self.Owner:GetAmmoCount("ar2") > 0) && (self.ReloadDelay == 0) then

			self.Owner:RemoveAmmo( 1, self.Weapon:GetSecondaryAmmoType() )

			self.Owner:MuzzleFlash()

			self.Weapon:SetNextPrimaryFire( CurTime() + 0.08 )

	if (SERVER) then

		local trace = self.Owner:GetEyeTrace()
		local Distance = self.Owner:GetPos():Distance(trace.HitPos)

			if Distance < 1050 then


			//This is how we ignite stuff
			local Ignite = function()

				//Safeguard
				if !self:IsValid() then return end

				//Damage things in radius of impact
					local flame = ents.Create("point_hurt")
					flame:SetPos(trace.HitPos)
					flame:SetOwner(self.Owner)
					flame:SetKeyValue("DamageRadius",128*2)
					flame:SetKeyValue("Damage", 7)
					flame:SetKeyValue("DamageDelay",0.32)
					flame:SetKeyValue("DamageType",8)
					flame:Spawn()
					flame:Fire("TurnOn","",0) 
					flame:Fire("kill","",0.72)

					if trace.HitWorld then
					local nearbystuff = ents.FindInSphere(trace.HitPos, 100)

					for _, stuff in pairs(nearbystuff) do

					if stuff != self.Owner then

					if stuff:GetPhysicsObject():IsValid() && !stuff:IsNPC() && !stuff:IsPlayer() then
					if !stuff:IsOnFire() then stuff:Ignite(36, 100) end end

					if stuff:IsPlayer() then
					if stuff:GetPhysicsObject():IsValid() then
					stuff:Ignite(5, 100) end end

					if stuff:IsNPC() then
					if stuff:GetPhysicsObject():IsValid() then
					local npc = stuff:GetClass()
					if npc == "npc_antlionguard" || npc == "npc_hunter" || npc == "npc_kleiner"
					|| npc == "npc_gman" || npc == "npc_eli" || npc == "npc_alyx"
					|| npc == "npc_mossman" || npc == "npc_breen" || npc == "npc_monk"
					|| npc == "npc_vortigaunt" || npc == "npc_citizen" || npc == "npc_rebel"
					|| npc == "npc_barney" || npc == "npc_magnusson" then
					stuff:Fire("Ignite","",1)
					end
					stuff:Ignite(36, 100) end end

					end
					end
					end

					if trace.Entity:IsValid() then

					if trace.Entity:GetPhysicsObject():IsValid() && !trace.Entity:IsNPC() && !trace.Entity:IsPlayer() then
					if !trace.Entity:IsOnFire() then trace.Entity:Ignite(36, 100) end end

					if trace.Entity:IsPlayer() then
					if trace.Entity:GetPhysicsObject():IsValid() then
					trace.Entity:Ignite(5, 100) end end

					if trace.Entity:IsNPC() then
					if trace.Entity:GetPhysicsObject():IsValid() then
					local npc = trace.Entity:GetClass()
					if npc == "npc_antlionguard" || npc == "npc_hunter" || npc == "npc_kleiner"
					|| npc == "npc_gman" || npc == "npc_eli" || npc == "npc_alyx"
					|| npc == "npc_mossman" || npc == "npc_breen" || npc == "npc_monk"
					|| npc == "npc_vortigaunt" || npc == "npc_citizen" || npc == "npc_rebel"
					|| npc == "npc_barney" || npc == "npc_magnusson" then
					trace.Entity:Fire("Ignite","",5)
					end
					trace.Entity:Ignite(36, 100) end end

					end

					if (SERVER) then
						local firefx = EffectData()
						firefx:SetOrigin(trace.HitPos)
						util.Effect("swep_flamethrower_explosion",firefx,true,true)
						end

					end


					//Ignite stuff; based on how long it takes for flame to reach it
					timer.Simple(Distance/1520, Ignite)


			end
		end
	end
end



function SWEP:SecondaryAttack() end


//Play a nice sound on deployment
function SWEP:Deploy()
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	if (SERVER) then
		self.Owner:EmitSound( "ambient/machines/keyboard2_clicks.wav", 42, 100 )
	end

	return true
end


//Think function
function SWEP:Think()

	if self.Owner:KeyReleased(IN_ATTACK) && (self.Owner:GetAmmoCount("ar2") > 1) && (self.ReloadDelay != 1) then
		if (SERVER) then
		self.Owner:EmitSound( "ambient/fire/mtov_flame2.wav", 24, 100 )
		end
	end

	if (self.Owner:GetAmmoCount("ar2") > 0) && (self.ReloadDelay == 0) then

		if self.Owner:KeyPressed(IN_ATTACK) then
		if (SERVER) then
			self.Owner:EmitSound( "ambient/machines/thumper_dust.wav", 46, 100 )
		end
	end

	if self.Owner:KeyDown(IN_ATTACK) then
			if (SERVER) then
				self.Owner:EmitSound( "ambient/fire/mtov_flame2.wav", math.random(27,35), math.random(32,152) )
			end
			local trace = self.Owner:GetEyeTrace()
			if (SERVER) then
				local flamefx = EffectData()
				flamefx:SetOrigin(trace.HitPos)
				flamefx:SetStart(self.Owner:GetShootPos())
				flamefx:SetAttachment(1)
				flamefx:SetEntity(self.Weapon)
				util.Effect("cleansingflamer_flamethrower",flamefx,true,true)
			end
		end

	end
end


//Reload function
function SWEP:Reload()

	if (self.Owner:GetAmmoCount("ar2") > 74) || (self.ReloadDelay == 1) then return end

	self.ReloadDelay = 1

	if (SERVER) then
	self.Owner:EmitSound( "weapon_flamer_reload.ogg", 100, 100 )
	end

	timer.Simple(1.82, function() if self:IsValid() then self:ReloadSelf() end end)

end


//How to reload if running out of ammo
function SWEP:RunoutReload()

	if (self.Owner:GetAmmoCount("ar2") > 74) || (self.ReloadDelay == 1) then return end

	self.ReloadDelay = 1

	if (SERVER) then
	self.Owner:EmitSound( "ambient/machines/thumper_dust.wav", 48, 100 )
	self.Owner:EmitSound( "weapon_flamer_reload.ogg", 100, 100 )
	end

	timer.Simple(1.82, function() if self:IsValid() then self:ReloadSelf() end end)

end


//Finish reloading
function SWEP:ReloadSelf()

	//Safeguards
	if !self then return end
	if !self:IsValid() then return end

	if (SERVER) then
		local ammo = math.Clamp( (60 - self.Owner:GetAmmoCount("ar2")), 0, 60)
		self.Owner:GiveAmmo(ammo, "ar2")
	end
		self.ReloadDelay = 0
		if self.Owner:KeyDown(IN_ATTACK) then
			if (SERVER) then
			self.Owner:EmitSound( "ambient/machines/thumper_dust.wav", 46, 100 )
		end
	end

end

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/
function SWEP:Initialize()
        self:SetWeaponHoldType( self.HoldType )
	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end
end
function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end
function SWEP:OnRemove()
	self:Holster()
end
if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)
		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}
			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end
		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)
			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end