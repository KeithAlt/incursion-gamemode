TOOL.Name = "NPC Relationship Modifier"
TOOL.Category = "Tools"
TOOL.Tab = "DrVrej"
TOOL.Command = nil
TOOL.ConfigName = ""

//TOOL.ClientConVar["playerinteract"] = 1
TOOL.ClientConVar["allytoplyallies"] = 1

local DefaultConVars = {}
for k,v in pairs(TOOL.ClientConVar) do
	DefaultConVars["vjstool_npcrelationship_"..k] = v
end
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	language.Add("tool.vjstool_npcrelationship.name", "NPC Relationship Modifier")
	language.Add("tool.vjstool_npcrelationship.desc", "Modify a NPC's relationship")
	language.Add("tool.vjstool_npcrelationship.0", "Left-Click to apply relationship, Right-Click to obtain the current classes, Press Reload to apply to yourself")
---------------------------------------------------------------------------------------------------------------------------------------------
	local function DoBuildCPanel_Relationship(Panel)
		local reset = vgui.Create("DButton")
		reset:SetFont("DermaDefaultBold")
		reset:SetText("Reset To Default")
		reset:SetSize(150,25)
		reset:SetColor(Color(0,0,0,255))
		reset.DoClick = function(reset)
			for k,v in pairs(DefaultConVars) do
				if v == "" then LocalPlayer():ConCommand(k.." ".."None") else
				LocalPlayer():ConCommand(k.." "..v) end
				table.Empty(VJ_NPCRELATION_TblCurrentValues)
				//LocalPlayer():ConCommand("vjstool_npcproperty_health 100")
				timer.Simple(0.05,function()
					GetPanel = controlpanel.Get("vjstool_npcrelationship")
					GetPanel:ClearControls()
					DoBuildCPanel_Relationship(GetPanel)
				end)
			end
		end
		Panel:AddPanel(reset)

		local tutorial = vgui.Create("DButton")
		tutorial:SetFont("DermaDefaultBold")
		tutorial:SetText("Tutorial Video")
		tutorial:SetSize(150, 20)
		tutorial:SetColor(Color(0,0,255,255))
		tutorial.DoClick = function(tutorial)
			gui.OpenURL("http://www.youtube.com/watch?v=SnuQU8Sc4cg")
		end
		Panel:AddPanel(tutorial)

		Panel:AddControl("Label", {Text = "It's recommended to use this tool only for VJ Base SNPCs."})
		Panel:ControlHelp("- Left click to apply relationship classes on an entity.")
		Panel:ControlHelp("- Right click to obtain the current classes an entity has.")
		Panel:ControlHelp("- Press reload to apply the relationship class to yourself.")
		
		VJ_NPCRELATION_TblCurrentValues = VJ_NPCRELATION_TblCurrentValues or {}
		local CheckList = vgui.Create("DListView")
			CheckList:SetTooltip(false)
			//CheckList:Center() -- No need since Size does it already
			CheckList:SetSize( 100, 300 ) -- Size
			CheckList:SetMultiSelect(false)
			//CheckList.Paint = function()
			//draw.RoundedBox( 8, 0, 0, CheckList:GetWide(), CheckList:GetTall(), Color( 0, 0, 100, 255 ) )
			//end
			CheckList:AddColumn("Class")
			CheckList.OnRowSelected = function(rowIndex,row) chat.AddText(Color(0,255,0),"Double click to ",Color(255,100,0),"remove ",Color(0,255,0),"a class") end
			function CheckList:DoDoubleClick(lineID,line)
				chat.AddText(Color(255,100,0)," "..line:GetValue(1).." ",Color(0,255,0),"removed!")
				CheckList:RemoveLine(lineID)
				table.Empty(VJ_NPCRELATION_TblCurrentValues)
				for kLine,vLine in pairs(CheckList:GetLines()) do
					table.insert(VJ_NPCRELATION_TblCurrentValues,vLine:GetValue(1))
				end
			end
		Panel:AddItem(CheckList)
		for k,v in pairs(VJ_NPCRELATION_TblCurrentValues) do
			CheckList:AddLine(v)
		end
		
		local function InsertToTable(val)
			if string.len(val) > 0 then
				local val = string.upper(val)
				if VJ_HasValue(VJ_NPCRELATION_TblCurrentValues,val) then
					chat.AddText(Color(220,20,60),"ERROR! ",Color(255,100,0),val.." ",Color(220,20,60),"already exists in the table!")
				else
					chat.AddText(Color(0,255,0),"Added",Color(255,100,0)," "..val.." ",Color(0,255,0),"to the class list!")
					table.insert(VJ_NPCRELATION_TblCurrentValues,val)
					timer.Simple(0.05,function()
						GetPanel = controlpanel.Get("vjstool_npcrelationship")
						GetPanel:ClearControls()
						DoBuildCPanel_Relationship(GetPanel)
					end)
				end
			end
		end
		local TextEntry = vgui.Create("DTextEntry")
		//TextEntry:SetText("Press enter to add class...")
		TextEntry.OnEnter = function()
			InsertToTable(TextEntry:GetValue())
		end
		Panel:AddItem(TextEntry)
		Panel:ControlHelp("Press ENTER to add the class")
		
		local button = vgui.Create("DButton")
		button:SetFont("DermaDefaultBold")
		button:SetText("Insert Combine Class")
		button:SetSize(50,20)
		button:SetColor(Color(0,0,0,255))
		button.DoClick = function(button)
			InsertToTable("CLASS_COMBINE")
		end
		Panel:AddPanel(button)
		
		local button = vgui.Create("DButton")
		button:SetFont("DermaDefaultBold")
		button:SetText("Insert Antlion Class")
		button:SetSize(50,20)
		button:SetColor(Color(0,0,0,255))
		button.DoClick = function(button)
			InsertToTable("CLASS_ANTLION")
		end
		Panel:AddPanel(button)
		
		local button = vgui.Create("DButton")
		button:SetFont("DermaDefaultBold")
		button:SetText("Insert Zombie Class")
		button:SetSize(50,20)
		button:SetColor(Color(0,0,0,255))
		button.DoClick = function(button)
			InsertToTable("CLASS_ZOMBIE")
		end
		Panel:AddPanel(button)
		
		local button = vgui.Create("DButton")
		button:SetFont("DermaDefaultBold")
		button:SetText("Insert Resistance Class")
		button:SetSize(50,20)
		button:SetColor(Color(0,0,0,255))
		button.DoClick = function(button)
			InsertToTable("CLASS_PLAYER_ALLY")
		end
		Panel:AddPanel(button)
		Panel:AddControl("Checkbox", {Label = "Allied with all player allies?", Command = "vjstool_npcrelationship_allytoplyallies"})
		Panel:ControlHelp("Only applies for VJ Base SNPCs and requires the SNPC to have CLASS_PLAYER_ALLY")
		
		//Panel:AddControl("Label", {Text = "For PLAYER entities Only:"})
		//Panel:AddControl("Checkbox", {Label = "Make NPCs interact with friendly player", Command = "vjstool_npcspawner_playerinteract"})
		//Panel:ControlHelp("Make NPCs be able to interact with friendly player, such follow when pressed E or get out of their way")
	end
---------------------------------------------------------------------------------------------------------------------------------------------
	function TOOL.BuildCPanel(Panel)
		DoBuildCPanel_Relationship(Panel)
	end
	
---------------------------------------------------------------------------------------------------------------------------------------------
	net.Receive("vj_npcrelationship_cl_select",function(len,pl)
		ent = net.ReadEntity()
		entname = net.ReadString()
		hasclasstbl = net.ReadBool()
		classtbl = net.ReadTable()
		chat.AddText(Color(0,255,0),"Obtained",Color(255,100,0)," "..entname.."'s ",Color(0,255,0),"relationship class list!")
		//print(ent)
		//print(hasclasstbl)
		//PrintTable(classtbl)
		//print(#classtbl)
		VJ_NPCRELATION_TblCurrentValues = classtbl
		timer.Simple(0.05,function()
			GetPanel = controlpanel.Get("vjstool_npcrelationship")
			GetPanel:ClearControls()
			DoBuildCPanel_Relationship(GetPanel)
		end)
	end)
---------------------------------------------------------------------------------------------------------------------------------------------
	net.Receive("vj_npcrelationship_cl_leftclick",function(len,pl)
		ent = net.ReadEntity()
		entname = net.ReadString()
		clicktype = net.ReadString()
		allynum = net.ReadFloat()
		if clicktype == "ReloadClick" then entname = "Yourself" end
		chat.AddText(Color(0,255,0),"Applied the relationship class table on",Color(255,100,0)," "..entname)
		net.Start("vj_npcrelationship_sr_leftclick")
		net.WriteEntity(ent)
		//net.WriteTable(self)
		net.WriteString(clicktype)
		net.WriteTable(VJ_NPCRELATION_TblCurrentValues)
		net.WriteFloat(allynum)
		net.SendToServer()
	end)
else
	util.AddNetworkString("vj_npcrelationship_cl_select")
	util.AddNetworkString("vj_npcrelationship_cl_leftclick")
	util.AddNetworkString("vj_npcrelationship_sr_leftclick")
---------------------------------------------------------------------------------------------------------------------------------------------
	net.Receive("vj_npcrelationship_sr_leftclick",function(len,pl)
		ent = net.ReadEntity()
		clicktype = net.ReadString()
		classtbl = net.ReadTable()
		allynum = net.ReadFloat()
		if #classtbl > 0 then
			ent.VJ_NPC_Class = classtbl
			if (ent.IsVJBaseSNPC) && allynum == 1 && table.HasValue(classtbl,"CLASS_PLAYER_ALLY") then
				ent.FriendsWithAllPlayerAllies = true
			end
		else
			ent.VJ_NPC_Class = {nil}
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:LeftClick(tr)
	if (CLIENT) then return true end
	local ent = tr.Entity
	if IsValid(ent) then
		if ent:IsPlayer() or ent:IsNPC() then
			local entname = ent:GetName()
			if entname == "" then entname = ent:GetClass() end
			net.Start("vj_npcrelationship_cl_leftclick")
			net.WriteEntity(ent)
			net.WriteString(entname)
			net.WriteString("LeftClick")
			net.WriteFloat(self:GetClientNumber("allytoplyallies"))
			net.Send(self:GetOwner())
			return true
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:RightClick(tr)
	if (CLIENT) then return true end
	local ent = tr.Entity
	if IsValid(ent) then
		if ent:IsPlayer() or ent:IsNPC() then
			local hasclasstbl = false
			local classtbl = {nil}
			local entname = ent:GetName()
			if entname == "" then entname = ent:GetClass() end
			if (ent.VJ_NPC_Class) then
				hasclasstbl = true
				//classtbl = ent.VJ_NPC_Class
				for k,v in ipairs(ent.VJ_NPC_Class) do
					table.insert(classtbl,v)
				end
				//if (classtbl.BaseClass) then table.remove(classtbl,BaseClass) end
			end
			//PrintTable(ent.VJ_NPC_Class)
			net.Start("vj_npcrelationship_cl_select")
			net.WriteEntity(ent)
			net.WriteString(entname)
			net.WriteBool(hasclasstbl)
			net.WriteTable(classtbl)
			net.Send(self:GetOwner())
			return true
		end
	end
	/*	local trent = tr.Entity
		trent:SetHealth(self:GetClientNumber("health"))
		if tr.Entity:IsNPC() then
			if self:GetClientNumber("godmode") == 1 then trent.GodMode = true else trent.GodMode = false end
		end
		return true
	end*/
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:Reload(tr)
	if (CLIENT) then return true end
	net.Start("vj_npcrelationship_cl_leftclick")
	net.WriteEntity(self:GetOwner())
	net.WriteString("Me")
	net.WriteString("ReloadClick")
	net.Send(self:GetOwner())
	return true
end