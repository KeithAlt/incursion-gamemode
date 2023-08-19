AddCSLuaFile()
if SERVER then
	util.AddNetworkString("mininuke_abuse_warn")
end

net.Receive("mininuke_abuse_warn", function(ply)
	if CLIENT then
		chat.AddText(Color(255, 0, 0), "[ ! ]  ", Color(255, 255, 255), "Activating this bomb with intent on killing innocent bystanders will result in a ", Color(255,155,155), "MASS RDM", Color(255,255,255), " ban.")
	end
end)


SWEP.Category			= "Fallout SWEPs - Custom Orders"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Author 			= "Lenny"
SWEP.PrintName 			= "Rigged Mini Nuke"
SWEP.Instructions 	= "RMB to give to a victim | LMB to activate"

SWEP.HoldType = "knife"
SWEP.ViewModelFOV = 80
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/customorders3/c_unitynuke_len.mdl"
SWEP.ShowWorldModel = false

SWEP.WElements = {
	["nuke"] = { type = "Model", model = "models/weapons/customorders3/c_unitynuke_len.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-13.254, 4.479, -14.528), angle = Angle(0, 0, 180), size = Vector(0.921, 0.921, 0.921), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.PrimingTime = 12
SWEP.ExplotionRadius = 500
SWEP.Primary.Damage	= 250
SWEP.DrawAmmo = false

SWEP.IsDetonating = false

// Mininuke alert sound
sound.Add( {
	name = "mininuke_alert",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "unitynuke/ticking.mp3"
} )


function SWEP:Deploy()
	self.Weapon:SetHoldType( self.HoldType )
	self.IsDetonating = false
	self.createMininukeLight()
	if SERVER then
		net.Start( "mininuke_abuse_warn" )
		net.Send(self:GetOwner())
	end
end

function SWEP:createMininukeLight()
	if !IsValid(self) then return end
	local lightStatus = true

	  local light = ents.Create("light_dynamic")
	  light:Spawn()
	  light:Activate()
	  light:SetKeyValue("distance", 400) -- 'distance' is equivalent to the radius of your light
	  light:SetKeyValue("brightness", 2)
	  light:SetKeyValue("_light", "255 0 0 255") -- '_light' is the color of your light. This currently
	  light:Fire("TurnOn")

	  timer.Create("mininuke_light", 1, self.PrimingTime/60, function()
	    if !IsValid(self) or IsValid(light) then return end

	      if lightStatus then
	        light:Fire("TurnOff")
	                lightStatus = nil
	       return
	      else
	        light:Fire("TurnOn")
	                lightStatus = true
	        return
	      end
	        light:Remove()
	   end)
end


local function IsSuperMutant(ply)
	-- Checks health value which is 750 on Super Mutants; this should be rewritten
	if ply:Health() == 750 then return true end
end

-- Super Mutant scream
local mutantScream = {
	"unitynuke/choochoo.mp3",
	"unitynuke/stopmoving.mp3",
	"unitynuke/runlittleman.mp3",
	"unitynuke/cantescapeme.mp3"
}

if SERVER then
	function PLAYER:TakeWeapons()
		self.StrippedWeps = {}

		for k, v in pairs(self:GetWeapons()) do
			if v:GetClass() != "weapon_unitysuicide" then
				table.insert( self.StrippedWeps, v:GetClass() )
				self:StripWeapon(v:GetClass())
			end
		end
	end

	function PLAYER:GiveWeapons()
			for k, v in pairs(self.StrippedWeps) do
				self:Give(v)
			end
	end
end

function SWEP:PrimaryAttack()
	if self.IsDetonating then return end

	self.IsDetonating = true

	if SERVER then
			self.Owner:SetNWBool("DetonatingNuke", true)
			self.Owner:EmitSound("weapons/slam/mine_mode.wav")
			self.Owner:TakeWeapons()

			local light = ents.Create("light_dynamic")
			light:SetPos(self:GetPos())
			light:SetParent(self.Weapon)
			light:Spawn()
			light:Activate()
			light:SetKeyValue("distance", 400) -- 'distance' is equivalent to the radius of your light
			light:SetKeyValue("brightness", 2)
			light:SetKeyValue("_light", "255 0 0 255") -- '_light' is the color of your light. This currently
			light:SetKeyValue("style", 4)
			light:Fire("TurnOn")


		self.Owner:EmitSound("mininuke_alert")

		if IsSuperMutant(self.Owner) then
			random = math.random(1,4)
			self.Owner:EmitSound(mutantScream[random], 100, 100, 1.4)
		end

		timer.Simple( self.PrimingTime - .75, function()
			if IsValid(self.Weapon) then
				self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			end
		end)
	end

	timer.Simple(self.PrimingTime, function()
    	if !IsValid(self) or (!(self.Owner:GetActiveWeapon():GetClass() == self.Weapon:GetClass())) then return end

		self:Explode()
	end)
end

function SWEP:SecondaryAttack()
	if SERVER then
		local target = self.Owner:GetEyeTrace().Entity

		if self.IsDetonating and IsValid(target) and target:IsPlayer() and target:Alive() and target:GetPos():Distance(self.Owner:GetPos()) < 150 then
			self.Owner:GiveWeapons()

			target:Give("weapon_unitysuicide")
			target:SelectWeapon("weapon_unitysuicide")
			self.Owner:falloutNotify("You've handed off the mininuke!", "shelter/sfx/cheeringincident.ogg")
			target:falloutNotify("You've been tossed a live mininuke! GET RID OF IT!", "shelter/sfx/xmas_gift_bounce_0" .. math.random(1,4) .. ".ogg")
			self:Remove()

			timer.Simple(0.5, function()
				if target:Alive() then
					target:setWepRaised(true) -- Raises weapon (NS func)
					target:SelectWeapon("weapon_unitysuicide")
					target:GetActiveWeapon().PrimingTime = target:GetActiveWeapon().PrimingTime - 3
					target:GetActiveWeapon():PrimaryAttack()
					target:EmitSound(Sound("Flesh.ImpactHard"))
				end
			end)

		elseif !self.IsDetonating then
			self.Owner:falloutNotify("The mininuke must be activated to hand-off", "ui/notify.mp3")
		end
	end
end

function SWEP:Explode()
	local ply = self:GetOwner()

	local effectData = EffectData()
	effectData:SetScale(1)
	effectData:SetOrigin(ply:GetPos())
	util.Effect( "nuke_blastwave_fallout", effectData )

	if SERVER then
		util.BlastDamage(self, ply, ply:GetPos(), 1200, 1200)
		util.ScreenShake(ply:GetPos(), 50, 50, 5,  3000)
	end
end

function SWEP:Reload()
end

-- World element rendering code --
function SWEP:TranslateActivity(act)

	if (self.Owner:IsNPC()) then
		if (self.ActivityTranslateAI[act]) then
			return self.ActivityTranslateAI[act]
		end
		return -1
	end

	if (self.ActivityTranslate[act] != nil) then
		return self.ActivityTranslate[act]
	end
	return -1
end


function SWEP:Initialize()
	// other initialize code goes here

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
	if 	self.IsDetonating == true then
		self.Owner:SelectWeapon("weapon_unitysuicide")
		return
	end

	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	return true
end

function SWEP:OnRemove()
	local ply = self.Owner

	if IsValid(ply) and !ply:Alive() then
		self:Explode()
	end

	// Makes sure the UnitySuicideWeapon_DropNuke hook is called
	timer.Simple(0, function()
		ply:SetNWBool("DetonatingNuke", false)
		ply:StopSound("mininuke_alert")
	end)
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
				and file.Exists ("materials/ " .. v.sprite .. ".vmt", "GAME")) then

				local name = v.sprite .. "-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$" .. j] = 1
						name = name .. "1"
					else
						name = name .. "0"
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
					while (cur >= 0) do
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
		for i = 0, vm:GetBoneCount() do
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
