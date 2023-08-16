jlib.logs = jlib.logs or {}

--[[
	ReceiveLogs
	Purpose: Receive and show logs sent to us by the server
]]
function jlib.logs.ReceiveLogs(logs, table, amtPerPage, cond)
	if !IsValid(jlib.logs.Panel) then
		local logsPanel = vgui.Create("jLogsPanel")
		logsPanel:SetUpLogs(unpack(logs.logTypes))
		logsPanel:SetLogs(logs)
		logsPanel:SetSize(800, 600)
		logsPanel:Center()
		logsPanel:MakePopup()
		logsPanel.tbl = table
		logsPanel.amtPerPage = amtPerPage
	else
		jlib.logs.UpdateLogs(logs)
	end
end

--[[
	UpdateLogs
	Purpose: Receive additional logs and add them to an existing logs panel
]]
function jlib.logs.UpdateLogs(logs)
	if IsValid(jlib.logs.Panel) then
		jlib.logs.Panel:AddLogs(logs)
		jlib.logs.Panel.loadmore:SetDisabled(false)
	end
end

net.Receive("jSendLogs", function()
	local logs = jlib.ReadCompressedTable()
	local table = net.ReadString()
	local amtPerPage = net.ReadInt(32)

	jlib.logs.ReceiveLogs(logs, table, amtPerPage)
end)
