if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

include( "autorun/meleewoundautorun.lua" )

SWEP.Category = "NPC_WEAPONS"
SWEP.Author			= ""

--SWEP.Tier=3
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.GrenadeTimer       = false
SWEP.ViewModel      = ""
SWEP.WorldModel   = "models/weapons/w_crowbar.mdl"
SWEP.RunAwayTimer          = false
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
--SWEP.Strength 				= 10

--[[
SWEP.WElements = {
	["harpoon1"] = { type = "Model", model = "models/models/danguyen/hfchampionshipbat.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -1.558), angle = Angle(-82.987, -33.896, 8.182), size = Vector(0.755, 0.755, 0.755), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}]]--
function SWEP:Initialize()
	timer.Simple(0.3, function()
		if CLIENT then
			-- // Create a new table for every weapon instance
			if self.Owner:GetNWInt("matier") == 1 then
				self.WElements = {
					["knife"] = { type = "Model", model = "models/models/danguyen/knife_shank.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, 3.635), angle = Angle(0, 101.688, -180), size = Vector(1.21, 1.21, 1.21), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
				}
			elseif self.Owner:GetNWInt("matier") == 2 then
				self.WElements = {
					["element_name"] = { type = "Model", model = "models/models/danguyen/w_gms_sickle.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.358, -7.792), angle = Angle(90, -115.714, 0), size = Vector(1.144, 1.144, 1.144), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
				}
			elseif self.Owner:GetNWInt("matier") == 3 then
				self.WElements = {
					["katana"] = { type = "Model", model = "models/models/danguyen/saber.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 1.557, -8.832), angle = Angle(-85.325, -8.183, 0), size = Vector(0.82, 0.82, 0.82), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
				}
			elseif self.Owner:GetNWInt("matier") == 4 then
				self.WElements = {
					["katana"] = { type = "Model", model = "models/models/danguyen/hattori.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.22, 1.074, -1.075), angle = Angle(176.376, 144.966, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
				}
			elseif self.Owner:GetNWInt("matier") == 0 then
				self.WElements = {
					["axe"] = { type = "Model", model = "models/models/danguyen/grognakaxe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 0.518, 3.635), angle = Angle(174.156, 101.688, -3.507), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
				}
			end
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
	end)
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

function SWEP:Equip()
	self.Tier = self.Owner:GetNWInt("matier")
	self.Strength = math.ceil(self.Tier+math.random(-1,2))
	print("Weapon Tier:"..self.Tier)
	print("Weapon Str:"..self.Strength)
end

function SWEP:OnRemove()
end

function SWEP:PrimaryAttack()
if !self:IsValid() or !self.Owner:IsValid() then return;end 
	pos = self.Owner:GetShootPos()
	ang = self.Owner:GetAimVector()
	pain = self.Tier*5+math.random(-2,10)
			self.Owner:EmitSound("WeaponFrag.Throw")--slash in the wind sound here
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
								self.Owner:EmitSound("ambient/machines/slicer2.wav")
								paininfo = DamageInfo()
								paininfo:SetDamage(pain)
								paininfo:SetDamageType(DMG_CLUB)
								paininfo:SetAttacker(self.Owner)
								paininfo:SetInflictor(self.Weapon)
						  local RandomForce = math.random(5000,8000)
								paininfo:SetDamageForce(slashtrace.Normal * RandomForce)
								if targ:IsPlayer() then
									if targ:GetNWBool("MAGuardening") == true or targ:GetNWBool("MeleeArtShieldening") == true then
										self.Owner:EmitSound("physics/wood/wood_plank_impact_hard1.wav")
										--self.Owner:SetNPCState(NPC_STATE_SCRIPT)
										self:Stun()
									else
									if targ:IsPlayer() and targ:GetNWBool("MeleeArtArmoredWarrior")==false then 
										local bleedDmg=(0.5*(self.Strength/3))
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
									util.Effect("bloodsplat", fleshimpact)
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
end
	
function SWEP:IsBaseCombineHoldType()
self.BaseCombineHoldType = true
end


function SWEP:ChaseFailed()
self.FailedChase = true
end
