if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

include( "autorun/meleewoundautorun.lua" )

SWEP.Category = "NPC_WEAPONS"
SWEP.Author			= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.GrenadeTimer       = false
SWEP.ViewModel      = ""
SWEP.WorldModel   = "models/weapons/w_crowbar.mdl"
SWEP.RunAwayTimer          = false
SWEP.Primary.Damage		= math.random(20,40)
SWEP.StealthTimer           = false
SWEP.Primary.ClipSize		= -1					-- Size of a clip
SWEP.Primary.DefaultClip	= -1					-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true				-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1					-- Size of a clip
SWEP.Secondary.DefaultClip	= -1					-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				-- Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"
SWEP.BaseCombineHoldType    = false
SWEP.Slash = 1
SWEP.IsCombine              = false
SWEP.CooldownTimer          = false
SWEP.ShowWorldModel         = false

SWEP.WElements = {
	["ArmorPad"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1d.mdl", bone = "ValveBiped.Bip01_L_Forearm", rel = "", pos = Vector(-1.558, 1.557, -1.558), angle = Angle(0, -90, -92.338), size = Vector(0.237, 0.237, 0.237), color = Color(153, 171, 196, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["hat"] = { type = "Model", model = "models/player/items/humans/top_hat.mdl", bone = "ValveBiped.Bip01_Head1", rel = "", pos = Vector(-2.398, 2.197, 0.2), angle = Angle(0, 106.363, 92.337), size = Vector(1.22, 1.299, 1.299), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Sheath+++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1d.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(2.596, 5.3, -17.143), angle = Angle(19.87, 29.221, -17.532), size = Vector(0.172, 0.172, 0.82), color = Color(80, 101, 125, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["Sheath"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1d.mdl", bone = "ValveBiped.Bip01_Pelvis", rel = "", pos = Vector(5.714, -2.597, 5.714), angle = Angle(-180, 54.935, 0), size = Vector(0.107, 0.107, 0.82), color = Color(80, 101, 125, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["katana"] = { type = "Model", model = "models/models/danguyen/iaito.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -0.519), angle = Angle(171.817, -8.183, -85.325), size = Vector(0.885, 0.755, 0.885), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["mask+"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1c.mdl", bone = "ValveBiped.Bip01_Head1", rel = "", pos = Vector(-0.519, 3.635, 0), angle = Angle(0, -71.3, -90), size = Vector(0.25, 0.189, 0.129), color = Color(126, 151, 184, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["katana+"] = { type = "Model", model = "models/models/danguyen/iaito.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -0.519), angle = Angle(171.817, -8.183, -85.325), size = Vector(0.889, 0.759, 0.889), color = Color(255, 0, 0, 255), surpresslightning = false, material = "models/effects/comball_tape", skin = 0, bodygroup = {} },
	["Sheath++"] = { type = "Model", model = "models/models/danguyen/ninja.mdl", bone = "ValveBiped.Bip01_Pelvis", rel = "Sheath", pos = Vector(-1.558, 1, -1.558), angle = Angle(0, -180, 0), size = Vector(1.014, 1.014, 1.014), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["ArmorPad+"] = { type = "Model", model = "models/hunter/tubes/circle2x2.mdl", bone = "ValveBiped.Bip01_L_Forearm", rel = "", pos = Vector(5.714, 0.518, 3.635), angle = Angle(0, -180, -171.818), size = Vector(0.237, 0.237, 0.237), color = Color(191, 217, 255, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["skull"] = { type = "Model", model = "models/gibs/agibs.mdl", bone = "ValveBiped.Bip01_Pelvis", rel = "", pos = Vector(-9.87, -2.398, 0.518), angle = Angle(180, 50.259, -97.014), size = Vector(1.08, 1.08, 1.08), color = Color(194, 146, 148, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["mask"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1c.mdl", bone = "ValveBiped.Bip01_Head1", rel = "", pos = Vector(4.675, 1.157, 0), angle = Angle(0, 111.039, -90), size = Vector(0.172, 0.172, 0.172), color = Color(126, 151, 184, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["ArmorPad+++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1d.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(-12.988, -3.636, 4.675), angle = Angle(-156, -101.689, -82.987), size = Vector(0.237, 0.432, 0.367), color = Color(161, 189, 216, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["Sheath++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1d.mdl", bone = "ValveBiped.Bip01_Pelvis", rel = "Sheath+++", pos = Vector(-3.901, 3.9, 0), angle = Angle(0, -180, 0), size = Vector(0.172, 0.172, 0.82), color = Color(80, 101, 125, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} },
	["Sheath+"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1d.mdl", bone = "ValveBiped.Bip01_Pelvis", rel = "Sheath", pos = Vector(-2.398, 2.397, 0), angle = Angle(0, -180, 0), size = Vector(0.107, 0.107, 0.82), color = Color(80, 101, 125, 255), surpresslightning = false, material = "models/props_wasteland/quarryobjects01", skin = 0, bodygroup = {} }
}
function SWEP:Initialize()
if CLIENT then
	
		-- // Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) -- create viewmodels
		self:CreateModels(self.WElements) -- create worldmodels
		
		-- // init view model bone build function
		if IsValid(self.Owner) and self.Owner:IsPlayer() then
		if self.Owner:Alive() then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				-- // Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					-- // however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
			
		end
		end
		
	end
end
 
function SWEP:DrawWorldModel()
	local offset, rotate
if not IsValid( self.Owner ) then
self:DrawModel( )
return
end


	
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
			-- // when the weapon is dropped
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
				-- //model:SetModelScale(v.size)
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
			
			-- // Technically, if there exists an element with the same name as a bone
			-- // you can get in an infinite loop. Let's just hope nobody's that stupid.
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
				ang.r = -ang.r --// Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		-- // Create the clientside models here because Garry says we can't do it in the render hook
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
				-- // make sure we create a unique name based on the selected options
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
			
			-- // !! WORKAROUND !! --//
			-- // We need to check all model names :/
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
			//!! ----------- !! --
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				-- // !! WORKAROUND !! --//
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
				//!! ----------- !! --
				
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

function SWEP:PrimaryAttack()
if !self:IsValid() or !self.Owner:IsValid() then return;end 
	pos = self.Owner:GetShootPos()
	ang = self.Owner:GetAimVector()
	pain = self.Primary.Damage
			self.Owner:EmitSound("katanaslash2.mp3")--slash in the wind sound here
			self.Owner:EmitSound("npc/combine_gunship/ping_search.wav")
			local chaosaura		= EffectData()
			chaosaura:SetEntity(self.Owner)
			chaosaura:SetOrigin(self.Owner:GetPos())
			chaosaura:SetNormal(self.Owner:GetPos())
			util.Effect("phys_unfreeze", chaosaura)
				if SERVER and IsValid(self.Owner) then
						local slash = {}
						slash.start = pos
						slash.endpos = pos + (ang * 90)
						slash.filter = self.Owner
						slash.mins = Vector(-5, -5, 0)
						slash.maxs = Vector(5, 5, 5)
						local slashtrace = util.TraceHull(slash)
						if slashtrace.Hit then
							targ = slashtrace.Entity
							if targ:IsPlayer() or targ:IsNPC() then
								self.Owner:EmitSound("ambient/machines/slicer4.wav")
								paininfo = DamageInfo()
								paininfo:SetDamage(pain)
								paininfo:SetDamageType(DMG_SLASH)
								paininfo:SetAttacker(self.Owner)
								paininfo:SetInflictor(self.Weapon)
						  local RandomForce = math.random(1000,20000)
								paininfo:SetDamageForce(slashtrace.Normal * RandomForce)
								if targ:IsPlayer() then
									if targ:GetNWBool("MAGuardening") == true or targ:GetNWBool("MeleeArtShieldening") == true then
										self.Owner:EmitSound("swordclash1.wav")
										--self.Owner:SetNPCState(NPC_STATE_SCRIPT)
										self:Stun()
									else
									if targ:IsPlayer() and targ:GetNWBool("MeleeArtArmoredWarrior")==false then 
										local bleedDmg=(0.5*(6/3))
										MAWoundage:AddStatus(targ, self.Owner, "bleed", 6,bleedDmg)
										end
										targ:ViewPunch( Angle( -10, -20, 0 ) )
									end
								end
								local blood = targ:GetBloodColor()	
								local fleshimpact		= EffectData()
								fleshimpact:SetEntity(self.Weapon)
								fleshimpact:SetOrigin(slashtrace.HitPos)
								fleshimpact:SetNormal(slashtrace.HitPos)
								if blood >= 0 then
									fleshimpact:SetColor(blood)
									util.Effect("BloodImpact", fleshimpact)
								end
								
								if SERVER then targ:TakeDamageInfo(paininfo) end
							end
						end
					end
	end

function SWEP:Think()
	self:SecondThink()
end

function SWEP:SecondThink()
	if self.Owner:GetNWBool("MAGuardening") then
		self.WElements["katana++"].color  = Color(255, 255, 255, 255)
	else
		self.WElements["katana++"].color  = Color(255, 255, 255, 0)
	end
end
	
function SWEP:IsBaseCombineHoldType()
self.BaseCombineHoldType = true
end


function SWEP:ChaseFailed()
self.FailedChase = true
end