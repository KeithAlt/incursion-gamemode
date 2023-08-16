////////////////////////////////////////////////////////////////
// Tactical Nuke, Weapon
// By Svn
///////////////////////////////////////////////////////////////
//Editing this file will invalidate your support warranty.////
------------------------------------------------------------------------
-- Weapon Variables
SWEP.PrintName 				= "Event"
SWEP.Category 				= "Cutscene"
SWEP.Author 				= "Svn"
SWEP.Spawnable 				= true
SWEP.AdminOnly   			= true
SWEP.DrawCrosshair			= false
SWEP.DrawAmmo 				= false
SWEP.AllowsAutoSwitchFrom  	= false
SWEP.Primary.Ammo			= ""
SWEP.Secondary.Ammo         = ""
SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
------------------------------------------------------------------------
-- SCK Variables
SWEP.ViewModelFOV 				= 54
SWEP.ViewModelFlip 				= true
SWEP.UseHands 					= true
SWEP.ViewModel 					= "models/weapons/c_slam.mdl"
SWEP.WorldModel 				= "models/props_c17/suitcase_passenger_physics.mdl"
SWEP.ShowViewModel 				= true
SWEP.ShowWorldModel 			= false
SWEP.ViewModelBoneMods 			= {
	["Slam_base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(-16.852, 6.48, -1.668), angle = Angle(0, 0, 0) }
}
SWEP.VElements = {
}
SWEP.WElements = {
}
------------------------------------------------------------------------
-- Primary
function SWEP:PrimaryAttack()
	ply = self.Owner
	tr = ply:GetEyeTrace()
	local pos = tr.HitPos + tr.HitNormal * 2
	local ang = ply:EyeAngles()
	ang.p = 0
	ang.y = ang.y + 180
	local distance = ply:GetPos():Distance(pos)
	if distance > 16000 then
		if CLIENT then
			self:EmitSound("common/wpn_denyselect.wav")
		end
		return
	end
	if SERVER then
		if ply:IsValid() == false or timer.Exists("MiscCommand_nuketimer") == true then
			return false
		end
		for k,v in pairs(player.GetHumans()) do
			net.Start("TNUKE_NETWORK_CLIENT")
			net.Send(v)
		end
		timer.Create("MiscCommand_nuketimer",45,1,function()
			local ent = ents.Create("")
			ent:SetPos(pos)
			ent:SetOwner(ply)
			ent:Spawn()
		end)
		self:Remove()
		return false
	end
end
------------------------------------------------------------------------
-- Reload
function SWEP:Reload()
	return
end
------------------------------------------------------------------------
-- Secondary
function SWEP:SecondaryAttack()
	return
end
------------------------------------------------------------------------
-- Facepunch Code
function SWEP:MakeGhostEntity( model, pos, angle )
	util.PrecacheModel( model )
	if ( SERVER && !game.SinglePlayer() ) then return end
	if ( CLIENT && game.SinglePlayer() ) then return end
	if ( self.GhostEntityLastDelete && self.GhostEntityLastDelete + 0.1 > CurTime() ) then return end
	self:ReleaseGhostEntity()
	if ( !util.IsValidProp( model ) ) then return end
	if ( CLIENT ) then
		self.GhostEntity = ents.CreateClientProp( model )
	else
		self.GhostEntity = ents.Create( "prop_physics" )
	end
	if ( !IsValid( self.GhostEntity ) ) then
		self.GhostEntity = nil
		return
	end
	self.GhostEntity:SetModel( model )
	self.GhostEntity:SetModelScale(1,0)
	self.GhostEntity:SetPos( pos )
	self.GhostEntity:SetAngles( angle )
	self.GhostEntity:Spawn()
	self.GhostEntity:SetSolid( SOLID_VPHYSICS )
	self.GhostEntity:SetMaterial("models/wireframe")
	self.GhostEntity:SetMoveType( MOVETYPE_NONE )
	self.GhostEntity:SetNotSolid( true )
	self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.GhostEntity:SetColor( Color( 255, 80, 80, 255 ) )
end
function SWEP:StartGhostEntity(ent)
	if ( SERVER && !game.SinglePlayer() ) then return end
	if ( CLIENT && game.SinglePlayer() ) then return end
	self:MakeGhostEntity( ent:GetModel(), ent:GetPos(), ent:GetAngles() )
end
function SWEP:ReleaseGhostEntity()
	if ( self.GhostEntity ) then
		if ( !IsValid( self.GhostEntity ) ) then self.GhostEntity = nil return end
		self.GhostEntity:Remove()
		self.GhostEntity = nil
		self.GhostEntityLastDelete = CurTime()
	end
	if ( self.GhostEntities ) then
		for k,v in pairs( self.GhostEntities ) do
			if ( IsValid( v ) ) then v:Remove() end
			self.GhostEntities[ k ] = nil
		end
		self.GhostEntities = nil
		self.GhostEntityLastDelete = CurTime()
	end
	if ( self.GhostOffset ) then
		for k,v in pairs( self.GhostOffset ) do
			self.GhostOffset[ k ] = nil
		end
	end
end
function SWEP:UpdateGhostEntity()
	if ( self.GhostEntity == nil ) then return end
	if ( !IsValid( self.GhostEntity ) ) then self.GhostEntity = nil return end
	local trace = self:GetOwner():GetEyeTrace()
	if ( !trace.Hit ) then return end
	local Ang1, Ang2 = self:GetNormal( 1 ):Angle(), ( trace.HitNormal * -1 ):Angle()
	local TargetAngle = self:GetEnt( 1 ):AlignAngles( Ang1, Ang2 )
	self.GhostEntity:SetPos( self:GetEnt( 1 ):GetPos() )
	self.GhostEntity:SetAngles( TargetAngle )
	local TranslatedPos = self.GhostEntity:LocalToWorld( self:GetLocalPos( 1 ) )
	local TargetPos = trace.HitPos + ( self:GetEnt( 1 ):GetPos() - TranslatedPos ) + trace.HitNormal
	self.GhostEntity:SetPos( TargetPos )
end
function SWEP:UpdateGhostItem( ent, ply )
	if ( !IsValid( ent ) ) then return end
	local trace = ply:GetEyeTrace()
	if ( !trace.Hit || IsValid( trace.Entity ) ) then
		ent:SetNoDraw( true )
		return
	end
	ply = self.Owner
	tr = ply:GetEyeTrace()
	local pos = tr.HitPos + tr.HitNormal * 2
	local ang = ply:EyeAngles()
	ang.p = 0
	local distance = ply:GetPos():Distance(pos)
	local ent = self.GhostEntity
	if distance > 16000 then
		ent:SetNoDraw( true )
		return
	end
	local CurPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint( CurPos - ( trace.HitNormal * 512 ) )
	local DrawOffset = CurPos - NearestPoint
	ent:SetPos( trace.HitPos + DrawOffset )
	ent:SetAngles(ang)
	ent:SetNoDraw( false )
end
function SWEP:Think()
	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != "models/hunter/misc/sphere025x025.mdl" ) then
		self:MakeGhostEntity( "models/hunter/misc/sphere025x025.mdl", Vector(0,0,0), Angle(0,0,0))
	end
	self:UpdateGhostItem( self.GhostEntity, self.Owner )
end
------------------------------------------------------------------------
-- SCK, By Clavus
function SWEP:Initialize()
	self:SetHoldType("normal")
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
	if self.GhostEntity == nil then return true end
	if self:IsValid() == false or self == NULL then return end
	self.GhostEntity:SetNoDraw(true)
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
