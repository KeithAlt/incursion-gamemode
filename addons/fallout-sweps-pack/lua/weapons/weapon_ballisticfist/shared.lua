

AddCSLuaFile()



SWEP.PrintName = "Ballistic Fist"

SWEP.Author = "Kilburn, robotboy655, MaxOfS2D & Tenrys"

SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Category = "Fallout SWEPs Melee Weapons"



SWEP.Slot = 0

SWEP.SlotPos = 4



SWEP.Spawnable = true



SWEP.HoldType = "fist"

SWEP.ViewModelFOV = 50

SWEP.ViewModelFlip = false

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_arms.mdl"

SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.ShowViewModel = true

SWEP.ShowWorldModel = false

SWEP.ViewModelBoneMods = {}

SWEP.VElements = {

	["powerfist"] = { type = "Model", model = "models/halokiller38/fallout/weapons/melee/ballisticfist.mdl", bone = "ValveBiped.Bip01_R_Forearm", rel = "", pos = Vector(3.897, -0.267, -0.82), angle = Angle(86.458, -90, 0), size = Vector(1.108, 1.108, 1.108), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }

}

SWEP.WElements = {

	["powerfist"] = { type = "Model", model = "models/halokiller38/fallout/weapons/melee/ballisticfist.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-7.105, -1.117, -0.211), angle = Angle(0, -90, 3.167), size = Vector(1.241, 1.241, 1.241), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }

}



SWEP.Primary.ClipSize = -1

SWEP.Primary.DefaultClip = -1

SWEP.Primary.Automatic = true

SWEP.Primary.Ammo = "none"



SWEP.Secondary.ClipSize = -1

SWEP.Secondary.DefaultClip = -1

SWEP.Secondary.Automatic = true

SWEP.Secondary.Ammo = "none"



SWEP.DrawAmmo = false



SWEP.HitDistance = 300



local SwingSound = Sound( "WeaponFrag.Throw" )

local HitSound = Sound( "Flesh.ImpactHard" )



function SWEP:SetupDataTables()



	self:NetworkVar( "Float", 0, "NextMeleeAttack" )

	self:NetworkVar( "Float", 1, "NextIdle" )

	self:NetworkVar( "Int", 2, "Combo" )



end



function SWEP:UpdateNextIdle()



	local vm = self.Owner:GetViewModel()

	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )



end



function SWEP:PrimaryAttack( right )



	self.Owner:SetAnimation( PLAYER_ATTACK1 )



	local anim = "fists_left"

	if ( right ) then anim = "fists_right" end

	if ( self:GetCombo() >= 2 ) then

		anim = "fists_uppercut"

	end



	local vm = self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )



	self:EmitSound( SwingSound )



	self:UpdateNextIdle()

	self:SetNextMeleeAttack( CurTime() + 0.2 )



	self:SetNextPrimaryFire( CurTime() + 0.9 )

	self:SetNextSecondaryFire( CurTime() + 0.9 )



end



function SWEP:SecondaryAttack()



	self:PrimaryAttack( true )



end



function SWEP:DealDamage()



	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())



	self.Owner:LagCompensation( true )



	local tr = util.TraceLine( {

		start = self.Owner:GetShootPos(),

		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,

		filter = self.Owner,

		mask = MASK_SHOT_HULL

	} )



	if ( !IsValid( tr.Entity ) ) then

		tr = util.TraceHull( {

			start = self.Owner:GetShootPos(),

			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,

			filter = self.Owner,

			mins = Vector( -10, -10, -8 ),

			maxs = Vector( 10, 10, 8 ),

			mask = MASK_SHOT_HULL

		} )

	end



	-- We need the second part for single player because SWEP:Think is ran shared in SP

	if ( tr.Hit && !( game.SinglePlayer() && CLIENT ) ) then

		self:EmitSound( HitSound )

	end



	local hit = false



	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) ) then

		local dmginfo = DamageInfo()



		local attacker = self.Owner

		if ( !IsValid( attacker ) ) then attacker = self end

		dmginfo:SetAttacker( attacker )



		dmginfo:SetInflictor( self )

		dmginfo:SetDamage( math.random( 8, 12 ) )



		if ( anim == "fists_left" ) then

			dmginfo:SetDamageForce( self.Owner:GetRight() * 4912 + self.Owner:GetForward() * 9998 ) -- Yes we need those specific numbers

		elseif ( anim == "fists_right" ) then

			dmginfo:SetDamageForce( self.Owner:GetRight() * -4912 + self.Owner:GetForward() * 9989 )

		elseif ( anim == "fists_uppercut" ) then

			dmginfo:SetDamageForce( self.Owner:GetUp() * 5158 + self.Owner:GetForward() * 10012 )

			dmginfo:SetDamage( math.random( 12, 24 ) )

		end



		tr.Entity:TakeDamageInfo( dmginfo )

		hit = true



	end



	if ( SERVER && IsValid( tr.Entity ) ) then

		local phys = tr.Entity:GetPhysicsObject()

		if ( IsValid( phys ) ) then

			phys:ApplyForceOffset( self.Owner:GetAimVector() * 80 * phys:GetMass(), tr.HitPos )

		end

	end



	if ( SERVER ) then

		if ( hit && anim != "fists_uppercut" ) then

			self:SetCombo( self:GetCombo() + 1 )

		else

			self:SetCombo( 0 )

		end

	end



	self.Owner:LagCompensation( false )



end



function SWEP:OnDrop()



	self:Remove() -- You can't drop fists



end



function SWEP:Deploy()



	local speed = GetConVarNumber( "sv_defaultdeployspeed" )



	local vm = self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )

	vm:SetPlaybackRate( speed )



	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )

	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )

	self:UpdateNextIdle()



	if ( SERVER ) then

		self:SetCombo( 0 )

	end



	return true



end



function SWEP:Think()



	local vm = self.Owner:GetViewModel()

	local curtime = CurTime()

	local idletime = self:GetNextIdle()



	if ( idletime > 0 && CurTime() > idletime ) then



		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )



		self:UpdateNextIdle()



	end



	local meleetime = self:GetNextMeleeAttack()



	if ( meleetime > 0 && CurTime() > meleetime ) then



		self:DealDamage()



		self:SetNextMeleeAttack( 0 )



	end



	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then



		self:SetCombo( 0 )



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

	self:SetHoldType( "fist" )

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