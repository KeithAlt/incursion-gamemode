ENT.Type = "anim"
ENT.PrintName = "Orbital Resource Drop Beacon"
ENT.Author = "Vex"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.RenderGroup = RENDERGROUP_BOTH

local radius = 640
local radiusSqrd = radius * radius
local dTime = 60 * 5
local renderDistance = 2500
local renderDistSqrd = renderDistance * renderDistance

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/grenadeAmmo.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Wake()
		end;

		self:setNetVar("DropTime", CurTime() + dTime)

		timer.Simple(dTime, function()
			if (IsValid(self)) then
				self:EmitSound("HL1/fvox/flatline.wav", 70, 150)
				self:EmitSound("fallout/orbit/drop_authorized.wav")

					timer.Simple(14, function()
						self:Remove()

						local tr = util.TraceLine({
							start = self:GetPos(),
							endpos = self:GetPos() + Vector(0, 0, 100000)
						})

						local spawnPosition = tr.HitPos - Vector(0, 0, 10)

						local drop = ents.Create("nut_orbit_drop")
							drop:SetPos(spawnPosition)
							drop:Spawn()
					end)
			end;
		end)

		self:EmitSound("fallout/orbit/standby.wav")
	end;

	function ENT:OnRemove()
		self:EmitSound("npc/manhack/gib.wav", 70, 150)
	end;
else
	local orbitalEnts = {}

	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	local color = Color(255, 50, 50)

	function ENT:Initialize()
		self.beep = 255
		self.DropTime = CurTime() + dTime
		table.insert(orbitalEnts, self)
	end

	function ENT:OnRemove()
		-- Best to just stick with RemoveByValue since the indicies will be jumbled around
		-- when entries are removed.
		table.RemoveByValue(orbitalEnts, self)
	end

	function ENT:Draw()
		self:DrawModel()
	end;

	function ENT:BeepLight()
		local firepos = self:GetPos() + (self:GetUp() * 5)
		local dlight = DynamicLight(self:EntIndex())

		dlight.Pos = firepos
		dlight.r = color.r
		dlight.g = color.g
		dlight.b = color.b
		dlight.Brightness = 5
		dlight.Size = 128
		dlight.Decay = 256
		dlight.DieTime = CurTime() + 0.5
	end;

	function ENT:Think()
		if (self.DropTime < CurTime()) then
			local firepos = self:GetPos() + (self:GetUp() * 5)
			dlight = DynamicLight(self:EntIndex())

			dlight.Pos = firepos
			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b
			dlight.Brightness = 5
			dlight.Size = 128
			dlight.Decay = 256
			dlight.DieTime = CurTime() + 60
		elseif (self.DropTime - CurTime() > 3) then
			self.beep = self.beep - FrameTime() * 500
		else
			self.beep = self.beep - FrameTime() * 2000
		end;

		if (self.beep <= 0) then
			self.beep = 255
			self:EmitSound("HL1/fvox/blip.wav", 70, 150)
			self:BeepLight()
		end;
	end;

	function ENT:DrawTranslucent()
		local firepos = self:GetPos() + (self:GetUp() * 5)
		render.SetMaterial(GLOW_MATERIAL)

		if (self.DropTime < CurTime()) then
			render.DrawSprite(firepos, 24, 24, color)
		else
			local size = self.beep / 5
			render.DrawSprite(firepos, size, size, color)
		end;
	end;

	hook.Add("HUDPaint", "HUDPaint_Orbit", function()
		for i, ent in ipairs(orbitalEnts) do
			if IsValid(ent) and ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < radiusSqrd then
				local dropTime = (ent:getNetVar("DropTime") or 0) - CurTime()

				if (dropTime > 0) then
					draw.SimpleText("Drop Countdown: "..string.FormattedTime(dropTime, "%02i:%02i:%02i"), "UI_Medium", 51, 51, Color(0, 0, 0), 0, 0)
					draw.SimpleText("Drop Countdown: "..string.FormattedTime(dropTime, "%02i:%02i:%02i"), "UI_Medium", 50, 50, nut.gui.palette.color_primary, 0, 0)

					draw.SimpleText("WARNING: PVP ZONE", "UI_Medium", (ScrW() / 2) + 1, 201, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText("WARNING: PVP ZONE", "UI_Medium", ScrW() / 2, 200, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				end

				break
			end
		end
	end)

	hook.Add("PostDrawOpaqueRenderables", "PostDrawOpaqueRenderables_Orbit", function()
		render.SetStencilWriteMask(0xFF)
		render.SetStencilTestMask(0xFF)
		render.SetStencilReferenceValue(0)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.ClearStencil()

		render.SetStencilEnable(true)

		for k, v in ipairs(orbitalEnts) do
			if !IsValid(v) or v:GetPos():DistToSqr(LocalPlayer():GetPos()) > renderDistSqrd then continue end

			render.SetStencilReferenceValue(1)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)

			render.SetColorMaterial()
			render.DrawBox(v:GetPos(), Angle(0,0,0), Vector(-radius, -radius, 0), Vector(radius, radius, 32), Color(255,0,0), true)

			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilFailOperation(STENCIL_KEEP)

			render.SetColorMaterial()
			cam.Start3D()
				render.DrawSphere(v:GetPos(), radius, 25, 25, Color(255, 0, 0, 100))
				render.DrawSphere(v:GetPos(), -radius, 25, 25, Color(255, 0, 0, 100))
			cam.End3D()
		end

		render.SetStencilEnable(false)
	end)
end;
