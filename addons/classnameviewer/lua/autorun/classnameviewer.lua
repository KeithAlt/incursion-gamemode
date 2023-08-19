Classnameviewer = {}

if SERVER then
	util.AddNetworkString("classnameviewer")
end

function Classnameviewer.Open(ply)
	if SERVER then
		if ply:IsAdmin() then
			net.Start("classnameviewer")
			net.Send(ply)
		end
	else
		local frame = vgui.Create("DFrame")
		frame:SetTitle("Classname viewer")
		frame:SetSize(600, 600)
		frame:Center()
		frame:MakePopup()

		local sheet = frame:Add("DPropertySheet")
		sheet:Dock(FILL)

		local factionsPanel = sheet:Add("DPanel")
		sheet:AddSheet("Factions", factionsPanel)

		local factionsList = factionsPanel:Add("DListView")
		factionsList:AddColumn("Print Name")
		factionsList:AddColumn("Class Name")
		for uniqueID, faction in pairs(nut.faction.teams) do
			factionsList:AddLine(faction.name, uniqueID)
		end
		factionsList:Dock(FILL)

		local classesPanel = sheet:Add("DPanel")
		sheet:AddSheet("Classes", classesPanel)

		local classesList = classesPanel:Add("DListView")
		classesList:AddColumn("Print Name")
		classesList:AddColumn("Class Name")
		for i, class in ipairs(nut.class.list) do
			classesList:AddLine(class.name, class.uniqueID)
		end
		classesList:Dock(FILL)

		local itemsPanel = sheet:Add("DPanel")
		sheet:AddSheet("Items", itemsPanel)

		local itemsList = itemsPanel:Add("DListView")
		itemsList:AddColumn("Print Name")
		itemsList:AddColumn("Class Name")
		for k, item in pairs(nut.item.list) do
			itemsList:AddLine(item.name, item.uniqueID)
		end
		itemsList:Dock(FILL)
	end
end

if CLIENT then
	net.Receive("classnameviewer", Classnameviewer.Open)
end

function Classnameviewer.SetupCommand()
	nut.command.add("classnameviewer", {
        adminOnly = true,
        onRun = function(ply)
            Classnameviewer.Open(ply)
        end
    })
end

hook.Add("InitPostEntity", "Classnameviewer", Classnameviewer.SetupCommand)

if nut and nut.command and nut.command.add then
	Classnameviewer.SetupCommand()
end
