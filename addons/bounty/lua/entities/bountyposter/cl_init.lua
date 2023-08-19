include('shared.lua')

surface.CreateFont( "BB_WantedPosterTextName", {
	font = "Courier New",
	size = 15,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "BB_WantedPosterTextBounty", {
	font = "Courier New",
	size = 25,
	weight = 500,
	antialias = true,
} )

function ENT:materialCreate(icon)
	if(!self.mat) then
		self.mat = Material(icon)
	end

	return self.mat
end

local ha = os.time()
local Frame = Material("bountyframe.png")
local gradient = nut.util.getMaterial("vgui/gradient-d")
local shitColor = ColorAlpha(color_white, 155)

function ENT:drawBounty(Pos, Ang)
	local bountyID = self:GetNW2String("posterCharID")

	if (bountyID and bountyID != "") then
		local bountyInfo = JOB_REQUEST_LIST[tonumber(bountyID)]

		if (bountyInfo) then
			pcall(function()
				surface.SetMaterial(Frame)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(0, 0, 180, 300)

				local mat = self:materialCreate(bountyInfo.icon)

				surface.SetMaterial(mat)
				surface.SetDrawColor(50, 50, 50, 255)
				surface.DrawTexturedRect(10, 74, 160, 163)
			end, function(error)
				print(error)
			end)
		else
			draw.SimpleText("Loading...", "BB_WantedPosterTextName",90,200,shitColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	else
		draw.SimpleText("Loading...", "BB_WantedPosterTextName",90,200,shitColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end

function ENT:Draw()	
	local Pos, Ang = self:GetPos()+self:GetRight()*5+self:GetUp()*9, self:GetAngles()
	Ang:RotateAroundAxis( Ang:Forward(), 90 )
	Ang:RotateAroundAxis( Ang:Right(), -90 )

	cam.Start3D2D( Pos, Ang, .06)
        self:drawBounty(Pos, Ang)
	cam.End3D2D()
end

function ENT:onShouldDrawEntityInfo()
	return true
end

function ENT:onDrawEntityInfo(alpha)
	local bountyID = self:GetNW2String("posterCharID")

	if (bountyID and bountyID != "") then
		local bountyInfo = JOB_REQUEST_LIST[tonumber(bountyID)]

		if (bountyInfo) then
			local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*15):ToScreen()
			local x, y = position.x, position.y

			nut.util.drawText("Job Poster", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
			--nut.util.drawText("Employer: " ..bountyInfo.employ, x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			nut.util.drawText("Description: " ..bountyInfo.reason, x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			nut.util.drawText("Contact: " ..bountyInfo.contact, x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			nut.util.drawText("Reward: " ..bountyInfo.prize, x, y + 48, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			--nut.util.drawText(L("bountyTakeHelp"), x, y + 48, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		end
	end
end