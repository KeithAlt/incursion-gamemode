local dlqueue = {}

local loading = false
local function CheckWSQueue(delayTime)
	if loading then return end

	local o = dlqueue[1]
	if o then
		if o.fileid then
			MsgN("[CasinoKit-DL] Initiating download of fileid " .. o.fileid)
			o.loading = true
			loading = true
			steamworks.Download(o.fileid, true, function(name)
				if not name then
					print("[CasinoKit-DL] Failed to get name of fileid " .. o.fileid)
					return
				end

				o.loading = false
				loading = false

				MsgN("[CasinoKit-DL] Fileid " .. o.fileid .. " downloaded to " .. name .. ". Mounting.")
				game.MountGMA(name)

				if o.cb then o.cb() end

				table.remove(dlqueue, 1)
				CheckWSQueue()
			end)
		else
			timer.Simple(0.5, CheckWSQueue)
		end
	end
end

local fetchHistory = {}
function CasinoKit.fetchFromWorkshop(id, cb, noHistory)
	MsgN("[CasinoKit-DL] Queueing download of " .. id)

	if not noHistory then
		table.insert(fetchHistory, id)
	end

	local t = {id = id, cb = cb}
	table.insert(dlqueue, t)
	steamworks.FileInfo(id, function(result)
		t.name = result.title
		t.fileid = result.fileid
		t.size = result.size
	end)

	CheckWSQueue()
end

concommand.Add("casinokit_reloadworkshop", function()
	for _,id in pairs(fetchHistory) do
		CasinoKit.fetchFromWorkshop(id, function()end, true)
	end
end)

local loadingIcon = Material("icon16/monkey.png")
hook.Add("HUDPaint", "CasinoKit_WSDLProgress", function()
	for i,o in pairs(dlqueue) do
		local x, y, w, h = ScrW() - 200, 200 +(i-1)*28, 200, 28
		surface.SetDrawColor(50, 50, 50)
		surface.DrawRect(x, y, w, h)

		surface.SetDrawColor(127, 127, 127)
		surface.DrawOutlinedRect(x, y, w, h)

		draw.SimpleText(o.name or "unknown", "DermaDefaultBold", x + 28, y + 7)

		if o.loading then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(loadingIcon)
			surface.DrawTexturedRectRotated(x + 13, y + 13, 16, 16, CurTime() * 180)
		end
	end
end)
