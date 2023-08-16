local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:DockMargin(ScrW() * 0.25, ScrH() * 0.25, ScrW() * 0.25, ScrH() * 0.25)

	self:SetTitle("Audit")
	self:MakePopup()

	self.listView = self:Add("DListView")
	self.listView:Dock(FILL)
end

function PANEL:populateRows(data)
	--PrintTable(data)
	--Let our data table decide what columns exist
	local columns = table.GetKeys(data[1])

	for _, column in ipairs(columns) do
		--Remove underscore of column name for aesthetic
		column = string.sub(column, 2)

		if column == "steamID" then
			column = "steamID64"
		end

		self.listView:AddColumn(column)
	end

	if table.HasValue(table.GetKeys(data[1]), "_steamID") then
		self.listView:AddColumn("steamID")
	end

	-- Populate list
	for _, row in ipairs(data) do
		-- Need to turn the row into a vararg

		-- Make sure our values are Steam ID 64
		if table.HasValue(table.GetKeys(row), "_steamID") then
			if string.StartWith(row["_steamID"], "STEAM") then
				row["_steamID"] = util.SteamIDTo64(row["_steamID"])
			end
		end

		-- Format our time
		if table.HasValue(table.GetKeys(row), "_lastJoinTime") then
			row["_lastJoinTime"] = string.FormattedTime(row["_lastJoinTime"], "%02i:%02i:%02i")
		end

		local row = table.ClearKeys(row)
		table.insert(row, table.GetLastKey(row) + 1, util.SteamIDFrom64(row[4]))

		PrintTable(row)
		
		self.listView:AddLine(unpack(row))
	end
end

vgui.Register("nutAuditPanel", PANEL, "DFrame")

net.Receive("nutAuditPanel", function()
	local data = net.ReadTable()

	local panel = vgui.Create("nutAuditPanel")
	panel:populateRows(data)
end)