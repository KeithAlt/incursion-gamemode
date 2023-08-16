--[[
	Logs Panel
	Purpose: Allows you to fill a DListView with searchable logs
]]

local PANEL = {}

function PANEL:Init()
	jlib.logs.Panel = self

	self:SetTitle("Logs")

	self.page = 1

	self.listview = self:Add("DListView")
	self.listview:Dock(FILL)
	self.listview.OnRowRightClick = function(s, lineID, line)
		local menu = DermaMenu()
		menu:SetPos(input.GetCursorPos())
		menu:MakePopup()

		for i, column in ipairs(s.Columns) do
			local name = column.Header:GetText()
			local value = line:GetColumnText(i)

			menu:AddOption("Copy " .. name, function()
				SetClipboardText(value)
			end):SetIcon("icon16/paste_plain.png")
		end
	end

	self.loadmore = self:Add("DButton")
	self.loadmore:SetText("Load more")
	self.loadmore:Dock(BOTTOM)
	self.loadmore.DoClick = function(s)
		self.page = self.page + 1

		s:SetDisabled(true)

		net.Start("jRequestPage")
			net.WriteString(self.tbl)
			net.WriteInt(self.page, 32)
			net.WriteInt(self.amtPerPage, 32)
		net.SendToServer()
	end
	self.loadmore:SetSkin("Default")

	self.searchbox = self:Add("DTextEntry")
	self.searchbox:SetPlaceholderText("Search...")
	self.searchbox:Dock(BOTTOM)
	self.searchbox.OnEnter = function(s)
		self:SearchLogs(s:GetText())
	end
end

function PANEL:SetUpLogs(...)
	local logTypes = {...}

	for _, logType in ipairs(logTypes) do
		self.listview:AddColumn(logType)
	end
end

function PANEL:FillLogs(logs)
	for i = 1, #logs do
		local log = logs[i]

		log[#log] = os.date("%d/%m/%Y - %H:%M:%S", tonumber(log[#log]) or 0)

		self.listview:AddLine(unpack(log))
	end
end

function PANEL:SetLogs(logs)
	self:FillLogs(logs)
	self.logs = logs
end

function PANEL:AddLogs(logs)
	self:FillLogs(logs)
	self.logs = table.Add(self.logs, logs)
end

function PANEL:SearchLogs(searchTerm)
	self.listview:Clear()

	if !searchTerm or searchTerm == "" and self.logs then
		self:FillLogs(self.logs)
		return
	end

	local results = {}
	for i = 1, #self.logs do
		local log = self.logs[i]

		for _, entry in pairs(log) do
			if tostring(entry):lower():find(searchTerm:lower(), nil, false) then
				table.insert(results, log)
				break
			end
		end
	end

	self:FillLogs(results)
end

vgui.Register("jLogsPanel", PANEL, "DFrame")
