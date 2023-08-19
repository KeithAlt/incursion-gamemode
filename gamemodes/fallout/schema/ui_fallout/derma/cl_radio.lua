local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.radio)) then
			nut.gui.radio:Remove()
		end;

		nut.gui.radio = self

		self:SetSize(0, 0)

		radio = self:Add("DHTML")
		radio:SetHTML([[<video controls="" autoplay="" name="media" onloadstart="this.volume=0.2"><source src="http://fallout.fm:8000/falloutfm6.ogg" type="application/ogg"></video>]])
	end;

	function PANEL:setStation(station)
		radio:Remove()
		radio = self:Add("DHTML")
		radio:SetHTML([[<video controls="" autoplay="" name="media" onloadstart="this.volume=0.2"><source src="]]..station..[[" type="application/ogg"></video>]])
	end;

vgui.Register("nutMusicRadio", PANEL, "DPanel")

concommand.Add("dev_radio", function(player)
	if (player:IsSuperAdmin()) then
		if (IsValid(nut.gui.radio)) then
			nut.gui.radio:Remove()
		else
			vgui.Create("nutMusicRadio")
		end;
	end;
end)
