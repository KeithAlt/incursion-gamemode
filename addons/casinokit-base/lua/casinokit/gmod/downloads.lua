local Download = CasinoKit.class("AssetDownload")

function Download:initialize()
	Download.super.initialize(self)

	self._loading = false
	self._loaded = false

	self._wsDownloads = {}
end

function Download:withWorkshop(id)
	assert(not self._loaded and not self._loading)

	table.insert(self._wsDownloads, id)

	return self
end

function Download:load()
	-- Set flags and modify load() to return loaded status in the future
	self._loading = true
	self.load = self.isLoaded

	assert(#self._wsDownloads <= 1) -- TODO support more
	for _,id in pairs(self._wsDownloads) do
		CasinoKit.fetchFromWorkshop(id, function()
			-- lol ??
			self._loaded = true
		end)
	end

	return false
end

function Download:isLoaded()
	return self._loaded
end

function CasinoKit.newDownload()
	return Download()
end