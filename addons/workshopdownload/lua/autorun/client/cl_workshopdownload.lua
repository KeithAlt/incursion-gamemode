WorkshopDL = WorkshopDL or {}
WorkshopDL.Author = "jonjo"

include("workshopdl_config.lua")

--General data
WorkshopDL.LoadscreenImages = WorkshopDL.LoadscreenImages or {}
WorkshopDL.LoadscreenImagesKeys = WorkshopDL.LoadscreenImagesKeys or table.GetKeys(WorkshopDL.LoadscreenImages)
WorkshopDL.AddonNameCache = WorkshopDL.AddonNameCache or {}
WorkshopDL.LoadscreenModels = table.GetKeys(WorkshopDL.LoadscreenSequences)

--Function aliases
WorkshopDL.Download = steamworks.DownloadUGC
WorkshopDL.IsSubscribed = steamworks.IsSubscribed

function WorkshopDL.Print(...)
	local msg = ""
	for i, arg in ipairs({...}) do
		msg = msg .. tostring(arg)
		if i != #{...} then
			msg = msg .. " "
		end
	end

	MsgC(Color(102, 192, 244, 255), "[WorkshopDL] ", Color(255, 255, 255, 255), msg, "\n")
end

function WorkshopDL.Mount(path)
	local result = game.MountGMA(path)
	if !result then
		WorkshopDL.Print("ERROR: Addon with path " .. path .. " failed to mount.")
	end
end

function WorkshopDL.Init()
	for i, dir in ipairs({"workshopdl", "workshopdl/img", "workshopdl/updated"}) do
		if !file.IsDir(dir, "DATA") then
			file.CreateDir(dir)
		end
	end

	WorkshopDL.GetLoadscreenImages(WorkshopDL.ImgurAlbumID, function(imgs)
		if #WorkshopDL.Queue <= 0 then
			WorkshopDL.GetWorkshopIDs(WorkshopDL.Collections, function(workshopIDs)
				WorkshopDL.GetItemsToMount(workshopIDs, function(itemsToMount)
					for i, id in ipairs(itemsToMount) do
						WorkshopDL.Print("Mounting addon with ID '" .. id .. "'.")
						WorkshopDL.Mount(WorkshopDL.GetGMAPath(id))
					end

					WorkshopDL.DoneMounting = true

					if WorkshopDL.DoneDownloading then
						hook.Run("WorkshopDLPostInit")
					end
				end)

				WorkshopDL.GetItemsToDownload(workshopIDs, function(itemsToDownload)
					if #itemsToDownload > 0 then
						WorkshopDL.DownloadWorkshopItems(itemsToDownload, function(gmaPaths)
							WorkshopDL.Print("Finished downloading collection(s)")
							WorkshopDL.EndLoadScreen()

							WorkshopDL.DoneDownloading = true

							if WorkshopDL.DoneMounting then
								hook.Run("WorkshopDLPostInit")
							end
						end)

						WorkshopDL.StartLoadScreen()
					else
						WorkshopDL.DoneDownloading = true

						if WorkshopDL.DoneMounting then
							hook.Run("WorkshopDLPostInit")
						end
					end
				end)
			end)
		end
	end)
end
hook.Add("InitPostEntity", "WorkshopDLInit", function() timer.Simple(0, WorkshopDL.Init) end)

--Queue functions
WorkshopDL.Queue = WorkshopDL.Queue or {}
WorkshopDL.Downloading = false
WorkshopDL.CurrentlyDownloading = nil

function WorkshopDL.AddToQueue(workshopID, callback)
	table.insert(WorkshopDL.Queue, {workshopID = workshopID, callback = callback})
end

function WorkshopDL.ProgressQueue()
	WorkshopDL.CurrentlyDownloading = nil

	if !WorkshopDL.Downloading and WorkshopDL.Queue[1] then
		WorkshopDL.DownloadWorkshopItem(WorkshopDL.Queue[1].workshopID, WorkshopDL.Queue[1].callback)
		table.remove(WorkshopDL.Queue, 1)
	end
end

--Addon checking functions
function WorkshopDL.IsEnabled(id)
	return WorkshopDL.IsSubscribed(id) and steamworks.ShouldMountAddon(id)
end

WorkshopDL.InfoCache = WorkshopDL.InfoCache or {}
function WorkshopDL.GetInfo(id, callback)
	if WorkshopDL.InfoCache[id] then
		callback(WorkshopDL.InfoCache[id])
	else
		steamworks.FileInfo(id, function(dat)
			WorkshopDL.InfoCache = dat
			callback(dat)
		end)
	end
end

function WorkshopDL.GetItemsToDownload(workshopIDs, callback)
	local itemsToDownload = {}
	local itemsChecked = 0

	for i, id in ipairs(workshopIDs) do
		WorkshopDL.GetInfo(id, function(dat)
			if !WorkshopDL.IsEnabled(id) and !WorkshopDL.IsUpToDate(id, dat.updated) then
				table.insert(itemsToDownload, id)
			end

			itemsChecked = itemsChecked + 1
			if itemsChecked == #workshopIDs and isfunction(callback) then
				callback(itemsToDownload)
			end
		end)
	end
end

function WorkshopDL.GetItemsToMount(workshopIDs, callback)
	local itemsToMount = {}
	local itemsChecked = 0

	for i, id in ipairs(workshopIDs) do
		WorkshopDL.GetInfo(id, function(dat)
			if WorkshopDL.IsUpToDate(id, dat.updated) and !WorkshopDL.IsEnabled(id) then
				table.insert(itemsToMount, id)
			end

			itemsChecked = itemsChecked + 1
			if itemsChecked == #workshopIDs and isfunction(callback) then
				callback(itemsToMount)
			end
		end)
	end
end

function WorkshopDL.IsUpToDate(workshopID, updated)
	local gmaPath = WorkshopDL.GetGMAPath(workshopID)
	local updatedPath = "workshopdl/updated/" .. workshopID .. ".txt"
	return file.Exists(gmaPath, "GAME") and file.Exists(updatedPath, "DATA") and updated <= tonumber(file.Read(updatedPath, "DATA"))
end

--Utility function
function WorkshopDL.GetGMAPath(workshopID)
	return "cache/workshop/" .. workshopID .. ".gma"
end

--Download functions
function WorkshopDL.DownloadWorkshopItem(workshopID, callback)
	if WorkshopDL.Downloading then
		WorkshopDL.AddToQueue(workshopID, callback)
		return
	end

	WorkshopDL.Downloading = true
	WorkshopDL.CurrentlyDownloading = workshopID

	WorkshopDL.GetInfo(workshopID, function(dat)
		if dat then
			local gmaPath = "cache/workshop/" .. workshopID .. ".gma"
			local updatedPath = "workshopdl/updated/" .. workshopID .. ".txt"

			if WorkshopDL.IsUpToDate(workshopID, dat.updated) then
				WorkshopDL.Print("Skipping addon '" .. dat.title .. "' as it is already up to date.")

				WorkshopDL.Print("Mounting addon '" .. dat.title .. "'.")
				WorkshopDL.Mount(gmaPath)

				if isfunction(callback) then callback(false) end

				WorkshopDL.Downloading = false
				WorkshopDL.ProgressQueue()

				return
			end

			WorkshopDL.Print("Downloading addon '" .. dat.title .. "' with ID", workshopID)

			WorkshopDL.Download(workshopID, function(path, f)
				if path then
					WorkshopDL.Print("Finished downloading '" .. dat.title .. "' file path:", path)
					WorkshopDL.Print("Mounting addon '" .. dat.title .. "'.")
					WorkshopDL.Mount(path)
				else
					WorkshopDL.Print("Failed to download addon '" .. dat.title .. "'.")
				end

				file.Write(updatedPath, dat.updated)

				if isfunction(callback) then callback(path or false, f) end

				WorkshopDL.Downloading = false
				WorkshopDL.ProgressQueue()
			end)
		else
			WorkshopDL.Print("Error fetching info for workshop item with ID", workshopID)
			WorkshopDL.Downloading = false
			WorkshopDL.ProgressQueue()
		end
	end)
end

function WorkshopDL.DownloadWorkshopItems(workshopItems, callback)
	WorkshopDL.TotalDownloads = #workshopItems

	local gmaPaths = {}

	for i, workshopID in ipairs(workshopItems) do
		WorkshopDL.DownloadWorkshopItem(workshopID, function(path, f)
			table.insert(gmaPaths, path)

			if #gmaPaths == #workshopItems and isfunction(callback) then
				callback(gmaPaths)
			end
		end)
	end
end

--Web API functions
function WorkshopDL.GetWorkshopIDs(collectionIDs, callback) --Get's all the workshop IDs from given collections
	WorkshopDL.Print("Fetching workshop data from workshop collection(s):", unpack(collectionIDs))

	local data = {["collectioncount"] = tostring(#collectionIDs)}

	for i, collectionID in ipairs(WorkshopDL.Collections) do
		data["publishedfileids[" .. tostring(i - 1) .. "]"] = collectionID
	end
    http.Post("https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/", data, function(response)
        local parsedResponse = util.JSONToTable(response)
		local workshopIDs = {}

		for _, collection in pairs(parsedResponse.response.collectiondetails) do
			WorkshopDL.Print("Processing data for collection", collection.publishedfileid)

			for _, workshopItem in pairs(collection.children) do
				table.insert(workshopIDs, workshopItem.publishedfileid)

				WorkshopDL.GetInfo(workshopItem.publishedfileid, function(dat)
					WorkshopDL.AddonNameCache[workshopItem.publishedfileid] = dat.title
				end)
			end
		end

		if isfunction(callback) then callback(workshopIDs) end
    end, function(err)
        WorkshopDL.Print("ERROR:", err)
    end)
end

function WorkshopDL.GetLoadscreenImages(imgurAlbum, callback)
	WorkshopDL.Print("Fetching loading screen images from Imgur album with ID", imgurAlbum)

	http.Fetch("https://api.imgur.com/3/album/" .. imgurAlbum .. "/images", function(response)
		local parsedResponse = util.JSONToTable(response)
		local folderPath = "workshopdl/img/" .. imgurAlbum

		if !file.IsDir(folderPath, "DATA") then
			file.CreateDir(folderPath)
		end

		if table.Count(WorkshopDL.LoadscreenImages) >= #parsedResponse.data then
			WorkshopDL.Print("Image table already full, skipping Imgur download.")

			if isfunction(callback) then
				callback(WorkshopDL.LoadscreenImages)
			end

			return
		end

		for i, imgData in ipairs(parsedResponse.data) do
			local imgPath = folderPath .. "/" .. imgData.id .. ".png"
			local matPath = "data/" .. imgPath

			if file.Exists(imgPath, "DATA") then
				WorkshopDL.Print("Image " .. imgData.id .. ".png already exists. Skipping download.")
				WorkshopDL.LoadscreenImages[imgData.id] = Material(matPath)

				if table.Count(WorkshopDL.LoadscreenImages) >= #parsedResponse.data and isfunction(callback) then
					WorkshopDL.LoadscreenImagesKeys = table.GetKeys(WorkshopDL.LoadscreenImages)
					callback(WorkshopDL.LoadscreenImages)

					return
				end

				continue
			end

			http.Fetch(imgData.link, function(img)
				WorkshopDL.Print("Downloaded image", imgData.link)
				file.Write(imgPath, img)
				WorkshopDL.LoadscreenImages[imgData.id] = Material(matPath)

				if table.Count(WorkshopDL.LoadscreenImages) >= #parsedResponse.data and isfunction(callback) then
					WorkshopDL.LoadscreenImagesKeys = table.GetKeys(WorkshopDL.LoadscreenImages)
					callback(WorkshopDL.LoadscreenImages)
				end
			end)
		end
	end, function(err)
		WorkshopDL.Print("ERROR:", err)
	end, {["Authorization"] = "Client-ID " .. WorkshopDL.ImgurClientID})
end

--Load screen data
surface.CreateFont("WorkshopDL", {font = "Roboto", size = 24, weight = 400})

WorkshopDL.TotalDownloads = WorkshopDL.TotalDownloads or 0

--Loading screen functions
function WorkshopDL.StartLoadScreen()
	if IsValid(WorkshopDL.LoadScreen) then
		WorkshopDL.LoadScreen:Remove()
	end

	WorkshopDL.LoadScreen = vgui.Create("DFrame")
	WorkshopDL.LoadScreen:SetMouseInputEnabled(true)
	WorkshopDL.LoadScreen:ShowCloseButton(false)
	WorkshopDL.LoadScreen:SetTitle("")
	WorkshopDL.LoadScreen:SetDraggable(false)
	WorkshopDL.LoadScreen:SetSize(ScrW(), ScrH())
	WorkshopDL.LoadScreen:MakePopup()
	WorkshopDL.LoadScreen.Paint = function(s)
		local currentDownloads = WorkshopDL.TotalDownloads - #WorkshopDL.Queue
		local progress = math.Clamp(currentDownloads / WorkshopDL.TotalDownloads, 0, 1)

		local materialKey = WorkshopDL.LoadscreenImagesKeys[math.Clamp(math.ceil(#WorkshopDL.LoadscreenImagesKeys * progress), 1, #WorkshopDL.LoadscreenImagesKeys)]

		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(WorkshopDL.LoadscreenImages[materialKey])
		surface.DrawTexturedRect(0, 0, s:GetWide(), s:GetTall())

		local w, h, pad = 400, 20, 6
		local pW, pH = w - pad, h - pad

		surface.SetDrawColor(Color(50, 50, 50, 200))
		surface.DrawRect((s:GetWide() / 2) - (w / 2), s:GetTall() - h - 10, w, h)
		surface.SetDrawColor(Color(45, 206, 137, 255))
		surface.DrawRect((s:GetWide() / 2) - (pW / 2), s:GetTall() - (h / 2) - (pH / 2) - 10, pW * progress, pH)

		surface.SetFont("WorkshopDL")

		local text
		if WorkshopDL.CurrentlyDownloading then
			text = "Downloading " .. (WorkshopDL.AddonNameCache[WorkshopDL.CurrentlyDownloading] or "unknown") .. "\n" .. currentDownloads .. "/" .. WorkshopDL.TotalDownloads
		else
			text = "Downloading " .. currentDownloads .. "/" .. WorkshopDL.TotalDownloads
		end
		local _, tH = surface.GetTextSize(text)
		jlib.ShadowText(text, "WorkshopDL", s:GetWide() / 2,  s:GetTall() - (h * 2) - tH, Color(255, 255, 255, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		s.HintTime = (s.HintTime or WorkshopDL.LoadScreenHintsInterval) + RealFrameTime()

		if s.HintTime >= WorkshopDL.LoadScreenHintsInterval then
			WorkshopDL.Print("Updating loading screen hint.")
			s.CurrentHint = WorkshopDL.Hints[math.random(#WorkshopDL.Hints)]
			s.HintTime = 0
		end

		_, tH = surface.GetTextSize("Hint:")

		local lineW, lineL = 2, 15
		w = 600

		local wrappedHint = jlib.WrapText(w - lineW - 7, s.CurrentHint, "WorkshopDL")
		local _, hintHeight = surface.GetTextSize(wrappedHint)
		h = hintHeight + 10

		local x, y = ScrW() - w - 100, ScrH() - h - 100

		s.Color = s.Color or table.Copy(nut.gui.palette.color_primary)

		surface.SetDrawColor(nut.gui.palette.color_background)
		surface.DrawRect(x, y, w, h)

		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawRect(x + lineW, y, lineL + 1, lineW + 1) --Top left shadow
		surface.DrawRect(x, y, lineW + 1, h + 1) --Left side shadow
		surface.DrawRect(x + lineW, y + h - lineW, lineL + 1, lineW + 1) --Bottom left shadow


		surface.SetDrawColor(s.Color)
		surface.DrawRect(x + lineW, y, lineL, lineW) --Top left
		surface.DrawRect(x, y, lineW, h) --Left side
		surface.DrawRect(x + lineW, y + h - lineW, lineL, lineW) --Bottom left

		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawRect(w + x - lineL - lineW, y, lineL + 1, lineW + 1) --Top right shadow
		surface.DrawRect(x + w - lineW, y, lineW + 1, h + 1) --Right side shadow
		surface.DrawRect(x + w - lineL - lineW, y + h - lineW, lineL + 1, lineW + 1) --Bottom right shadow

		surface.SetDrawColor(s.Color)
		surface.DrawRect(w + x - lineL - lineW, y, lineL, lineW) --Top right
		surface.DrawRect(x + w - lineW, y, lineW, h) --Right side
		surface.DrawRect(x + w - lineL - lineW, y + h - lineW, lineL, lineW) --Bottom right

		jlib.ShadowText("Hint:", "WorkshopDL", x, y - tH, nut.gui.palette.text_primary, Color(0, 0, 0, 255), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		jlib.ShadowText(wrappedHint, "WorkshopDL", x + lineW + 7, y + lineW + 3, nut.gui.palette.text_primary, Color(0, 0, 0, 255), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	local modelPnl = WorkshopDL.LoadScreen:Add("DModelPanel")
	modelPnl:SetSize(ScrW() / 2, ScrH())
	modelPnl:SetAnimated(true)
	function modelPnl:UpdateModel()
		WorkshopDL.Print("Updating loading screen model.")

		local mdls = WorkshopDL.LoadscreenModels
		local mdl = mdls[math.random(#mdls)]

		self:SetModel(mdl)

		local sequences = WorkshopDL.LoadscreenSequences[mdl]
		local sequence = sequences[math.random(#sequences)]

		local csEnt = self:GetEntity()
		csEnt:ResetSequence(sequence)
		csEnt:SetSkin(math.random(0, csEnt:SkinCount() - 1))

		if !WorkshopDL.LoadscreenNoBodygroups[mdl] then
			for i = 0, csEnt:GetNumBodyGroups() - 1 do
				csEnt:SetBodygroup(i, math.random(0, csEnt:GetBodygroupCount(i) - 1))
			end
		end

		local mins, maxs = csEnt:GetRenderBounds()
		local renderSize = maxs - mins
		local camPos = self:GetCamPos()
		camPos.x = renderSize.z
		self:SetCamPos(camPos)
	end

	function modelPnl:Think()
		self.ModelTime = (self.ModelTime or WorkshopDL.LoadScreenModelInterval) + RealFrameTime()

		if self.ModelTime >= WorkshopDL.LoadScreenModelInterval then
			self:UpdateModel()
			self.ModelTime = 0
		end
	end
end

function WorkshopDL.EndLoadScreen()
	WorkshopDL.TotalDownloads = 0
	if IsValid(WorkshopDL.LoadScreen) then
		WorkshopDL.LoadScreen:Remove()
	end
	WorkshopDL.LoadScreen = nil
end
