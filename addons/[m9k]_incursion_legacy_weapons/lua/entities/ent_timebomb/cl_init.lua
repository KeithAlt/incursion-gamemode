include("shared.lua")
language.Add(ClassName,"Time Bomb")
surface.CreateFont("timebomb_font",{
	font="Trebuchet24",
	size=36,
	weight=700
})
net.Receive("timebomb_set",function()
	local Ent=net.ReadEntity()
	local cTime=tonumber(net.ReadString())
	local timebomb=vgui.Create("DFrame")
	timebomb:SetSize(430,120)
	timebomb:Center()
	timebomb:SetTitle("Time Bomb")
	timebomb:SetVisible(true)
	timebomb:SetDraggable(true)
	timebomb:ShowCloseButton(false)
	timebomb:SetBackgroundBlur(true)
	local currtime=vgui.Create("DLabel",timebomb)
	currtime:SetFont("timebomb_font")
	currtime:SetColor(Color(255,255,255,255))
	currtime:SetText("00:00")
	currtime:SizeToContents()
	currtime:SetPos(0,25)
	currtime:CenterHorizontal()
	local slider=vgui.Create("DNumSlider",timebomb)
	slider:SetSize(320,20)
	slider:SetPos(0,60)
	slider:CenterHorizontal()
	slider:SetText("Time")
	slider:SetMin(30)
	slider:SetMax(600)
	slider:SetDecimals(0)
	slider.ValueChanged=function(cont,v)
		currtime:SetText(string.FormattedTime(v,"%02i:%02i"))
	end
	slider:SetValue(cTime)
	local cancel=vgui.Create("DButton",timebomb)
	cancel:SetText("Cancel")
	cancel:SetSize(160,25)
	cancel:SetPos(10,90)
	cancel.DoClick=function()
		timebomb:Close()
	end
	local set=vgui.Create("DButton",timebomb)
	set:SetText("Set")
	set:SetSize(160,25)
	set:SetPos(260,90)
	set.DoClick=function()
		timebomb:Close()
		RunConsoleCommand("timebomb_settime",Ent:EntIndex(),slider:GetValue())
	end
	timebomb:MakePopup()
end)
function ENT:Draw()
	self:DrawModel()
    local Pos = self:GetPos() + self:GetUp()*9 + self:GetForward()*4.05 + self:GetRight()*4.40
    local Ang = self:GetAngles()
    Ang:RotateAroundAxis(Ang:Up(), -90)
	local starttime=self:GetStartTime()
	local toexplode=starttime+self:GetTimeToExplode()
	local TimeRemaining=math.floor(math.abs(CurTime()-toexplode))
	if TimeRemaining<0 or TimeRemaining>600 then
		TimeRemaining=0
	end
    cam.Start3D2D(Pos, Ang, 0.15 )
        if(self:GetStarted()) then

            draw.DrawText(string.FormattedTime( TimeRemaining, "%2i:%02i" ), "Default", 0, 0, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER )

        else

            draw.DrawText( string.FormattedTime( self:GetTimeToExplode(), "%2i:%02i" ), "Default", 0, 0, Color(0, 255, 0, 255), TEXT_ALIGN_CENTER )

        end
    cam.End3D2D()
end
