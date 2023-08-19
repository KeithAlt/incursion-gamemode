local PLUGIN = PLUGIN

local function InDistance(pos01, pos02, dist)
	local inDistance = pos01:DistToSqr(pos02) < (dist * dist)
	return  inDistance
end

AddCSLuaFile()
TOOL.Category = "Fallout Mining"
TOOL.Name = "#RockSpawner"
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar["type"] = "Random"
TOOL.ClientConVar["amount"] = 10
TOOL.ClientConVar["rate"] = 300
TOOL.ClientConVar["refreshamount"] = 5

if (CLIENT) then
	language.Add("tool.fo_rockspawner.name", "Fallout Mining")
	language.Add("tool.fo_rockspawner.desc", "Creates a rock")
	language.Add("tool.fo_rockspawner.0", "LeftClick: Creates a rock.")
end


function TOOL:LeftClick(trace)
	if !self:GetOwner():IsSuperAdmin() then return end

	local trEnt = trace.Entity
	if (trEnt:IsPlayer()) then return false end
	if (CLIENT) then return end
	local tool_rType = self:GetClientInfo("type", 0)
	local tool_rAmount = self:GetClientNumber("amount", 10)
	local refreshRate = self:GetClientNumber("rate", 300)
	local refreshAmount = self:GetClientNumber("refreshamount", 5)

	if ( tool_rType == "Random") then
		tool_rType = 0
	elseif ( tool_rType == "Iron" ) then
		tool_rType = 1
	elseif ( tool_rType == "Bronze" ) then
		tool_rType = 2
	elseif ( tool_rType == "Silver" ) then
		tool_rType = 3
	elseif ( tool_rType == "Gold" ) then
		tool_rType = 4
	elseif ( tool_rType == "Coal" ) then
		tool_rType = 5
	end

	if (trEnt:GetClass() == "worldspawn") then
		--This prevents the creation of Spawner that are too close to others
		local ahzdistance
		local pos = trace.HitPos

		for a, b in pairs(ents.FindByClass("fo_mine_rock")) do
			if not b:IsValid() then return end


			if InDistance(pos, b:GetPos(), 100) then
				ahzdistance = true

				if (SERVER) then
					self:GetOwner():ChatPrint("Too Close to other Spawn!")
				end

				break
			end
		end

		if ahzdistance then return false end
		local ent = ents.Create("fo_mine_rock")
		if (not ent:IsValid()) then return end
		ent:SetPos(pos + Vector(0, 0, 1))
		local ang = Angle(0, 0, 0)
		ang:RotateAroundAxis(Vector(0, 0, 1), math.random(0, 360))
		ent:SetAngles(ang)
		ent:setNetVar("mineType", tool_rType)
		ent:setNetVar("mineHp", tool_rAmount)
		ent.RefreshRate = refreshRate
		ent.RefreshAmount = refreshAmount
		ent:Spawn()
		ent:Activate()
		ent:setNetVar("mineMaxHp", tool_rAmount)
		undo.Create("fo_mine_rock")
		undo.AddEntity(ent)
		undo.SetPlayer(self:GetOwner())
		undo.Finish()

		if (SERVER) then
			self:GetOwner():ChatPrint("New Resource Spawn created!")
		end

		return true
	else
		if (trEnt:GetClass() == "fo_mine_rock") then
			trEnt:setNetVar("mineType", tool_rType)
			trEnt:setNetVar("mineHp", tool_rAmount)
			trEnt:setNetVar("mineMaxHp", tool_rAmount)
			trEnt.RefreshRate = refreshRate
			trEnt.RefreshAmount = refreshAmount

			if (SERVER) then
				self:GetOwner():ChatPrint("Resource Spawn Updated!")
			end

			return true
		else
			return false
		end
	end
end

function TOOL:RightClick(trace)
	if !self:GetOwner():IsSuperAdmin() then return end

	if (trace.Entity:IsPlayer()) then return false end
end

function TOOL:Deploy()
end

function TOOL:Holster()
end


function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.fo_rockspawner.name",
		Description = "#tool.fo_rockspawner.desc"
	})

	CPanel:AddControl("label", {
		Text = "-------------------------------------------------------------------"
	})

	local combobox = CPanel:ComboBox("Resource Type", "fo_rockspawner_type")
	combobox:AddChoice("Random")
	combobox:AddChoice("Coal")
	combobox:AddChoice("Iron")
	combobox:AddChoice("Bronze")
	combobox:AddChoice("Silver")
	combobox:AddChoice("Gold")
	CPanel:NumSlider("Resource Amount", "fo_rockspawner_amount", 1, 200, 0)
	CPanel:NumSlider("Refresh Rate", "fo_rockspawner_rate", 10, 3600, 0)
	CPanel:NumSlider("Refresh Amount", "fo_rockspawner_refreshamount", 1, 200, 0)

	CPanel:AddControl("label", {
		Text = "Tip: When creating Bronze, Silver or Gold Ore´s make sure do not set the Amount too High."
		})

		CPanel:AddControl("label", {
			Text = "Recommended: 5-20"
		})
	end


if CLIENT then
	-- The ClientModel
	if fomine_tool_item == nil then
		fomine_tool_item = nil
	end

	local function SpawnClientModel(weapon)
		local ent = ents.CreateClientProp("models/zerochain/props_mining/zrms_resource_point.mdl")
		ent:SetPos(weapon:GetPos() + weapon:GetUp() * 25 + weapon:GetForward() * 10)
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()
		ent:Activate()
		ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
		ent:SetColor(Color(0, 255, 0, 200))
		fomine_tool_item = ent
	end

	hook.Add("Think", "fomine_Think_ToolGun_RockSpawner", function()
		local ply = LocalPlayer()
		local weapon = ply:GetActiveWeapon()

		if IsValid(weapon) and weapon:GetClass() == "gmod_tool" then
			local tool = ply:GetTool()

			if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "fo_rockspawner" and tool.Name == "#RockSpawner" then
				if IsValid(fomine_tool_item) then
					local tr = ply:GetEyeTrace()

					if tr.Hit and tr.HitPos then
						fomine_tool_item:SetPos(tr.HitPos)
					end
				else
					SpawnClientModel(weapon)
				end
			else
				if IsValid(fomine_tool_item) then
					fomine_tool_item:Remove()
				end
			end
		else

			if IsValid(fomine_tool_item) then
				fomine_tool_item:Remove()
			end
		end
	end)
end
