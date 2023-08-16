util.AddNetworkString("AreasAddSong")
util.AddNetworkString("AreasRemoveSong")

function Areas.Meta:AddSong(str)
	local music = self:GetMusic()
	if !table.HasValue(music, str) then
		table.insert(music, str)
	end
	self:SetMusic(music)
end

function Areas.Meta:RemoveSong(str)
	local music = self:GetMusic()
	table.RemoveByValue(music, str)
	self:SetMusic(music)
end

net.Receive("AreasAddSong", function(len, ply)
	if ply:IsSuperAdmin() then
		local areaID = net.ReadInt(32)
		local song = net.ReadString()
		local area = Areas.Instances[areaID]
		area:AddSong(song)
	end
end)

net.Receive("AreasRemoveSong", function(len, ply)
	if ply:IsSuperAdmin() then
		local areaID = net.ReadInt(32)
		local song = net.ReadString()
		local area = Areas.Instances[areaID]
		area:RemoveSong(song)
	end
end)
