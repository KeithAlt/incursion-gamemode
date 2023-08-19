local hitboxCurrentlyRendering = CreateClientConVar("hitbox_togglerender", 0)
local renderAll = CreateClientConVar("hitbox_renderall", 0)
local renderRagDolls = CreateClientConVar("hitbox_renderragdolls", 0)
local renderNPCs = CreateClientConVar("hitbox_rendernpcs", 0)
local renderLocalPlayer = CreateClientConVar("hitbox_renderlocalplayer", 0)
local cullDistance = CreateClientConVar("hitbox_culldistance", 100, true, false, "Any entity closer than this will not have it's hitboxes/bounding box rendered")
local drawAllClasses = CreateClientConVar("hitbox_drawallclassnames", 1)
local printOriginDetails = CreateClientConVar("hitbox_printorigindetails", 1)

local function ShouldRender(...)
	for i, v in ipairs({...}) do
		if v == false then
			return false
		end
	end

	return LocalPlayer():IsAdmin() and hitboxCurrentlyRendering:GetBool()
end

local function ShouldRenderEnt(ent)
	return ent:GetPos():Distance(LocalPlayer():GetPos()) > cullDistance:GetInt()
end

local function HitboxRender3D(depth, skybox)
	if !ShouldRender(!depth, !skybox) then return end

	for _, ent in ipairs(ents.GetAll()) do
		if !ShouldRenderEnt(ent) then continue end
		if !renderLocalPlayer:GetBool() and (ent == LocalPlayer() or ent:GetParent() == LocalPlayer()) then continue end

		if !renderAll:GetBool() then
			if !ent:IsPlayer() and !ent:IsRagdoll() and !ent:IsNPC() then continue end
			if !renderNPCs:GetBool() and ent:IsNPC() then continue end
			if !renderRagDolls:GetBool() and ent:IsRagdoll() then continue end
		end

		if ent:GetHitBoxGroupCount() == nil then continue end

		for group = 0, ent:GetHitBoxGroupCount() - 1 do
		 	for hitbox = 0, ent:GetHitBoxCount(group) - 1 do
		 		local pos, ang =  ent:GetBonePosition(ent:GetHitBoxBone(hitbox, group))
		 		local mins, maxs = ent:GetHitBoxBounds(hitbox, group)

				render.DrawWireframeBox(pos, ang, mins, maxs, Color(51, 204, 255, 255), true)
			end
		end

		render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs(), Color(255, 204, 51, 255), true)
	end
end

local function HitboxRender2D()
	if !ShouldRender() then return end

	local tr = LocalPlayer():GetEyeTrace()
	local hitEnt = tr.Entity
	if tr.Hit and IsValid(hitEnt) then
		local pos = tr.HitPos:ToScreen()
		draw.SimpleText(hitEnt:GetClass(), nil, pos.x, pos.y)
	end

	for _, ent in ipairs(ents.GetAll()) do
		if !ShouldRenderEnt(ent) then continue end

		local pos = ent:GetPos()

		if printOriginDetails:GetBool() and pos.x == 0 and pos.y == 0 and pos.z == 0 then
			print("Entity at origin:", ent:GetClass(), ent:GetModel(), IsValid(ent:GetParent()) and ent:GetParent():GetClass() or "No parent")
		end

		if drawAllClasses:GetBool() then
			local screenPos = pos:ToScreen()
			draw.SimpleText(ent:GetClass(), nil, screenPos.x, screenPos.y)
		end
	end
end

cvars.AddChangeCallback("hitbox_togglerender", function(name, old, new)
	if new == "1" and ShouldRender() then
		hook.Add("PostDrawOpaqueRenderables", "HitboxRender", HitboxRender3D)
		hook.Add("HUDPaint", "HitboxRender", HitboxRender2D)
	else
		hook.Remove("PostDrawOpaqueRenderables", "HitboxRender")
		hook.Remove("HUDPaint", "HitboxRender")
	end
end)

hook.Add("InitPostEntity", "HitboxRender", function()
	if ShouldRender() then
		hook.Add("PostDrawOpaqueRenderables", "HitboxRender", HitboxRender3D)
		hook.Add("HUDPaint", "HitboxRender", HitboxRender2D)
	end
end)
