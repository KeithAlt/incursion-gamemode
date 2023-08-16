if SERVER then
	RunConsoleCommand("mp_show_voice_icons", "0")
end

if CLIENT then
	local voiceMat = Material("voice/icntlk_pl")

	hook.Add("PrePlayerDraw", "VoiceIcons", function(ply)
		if ply != LocalPlayer() and ply:Alive() and ply:IsSpeaking() and hook.Run("PreRenderVoiceIcon", ply) != true and halo.RenderedEntity() != ply then
			local attachment = ply:GetAttachment(ply:LookupAttachment('eyes'))
			local eyePos = attachment and attachment.Pos or ply:EyePos()
			local pos = eyePos + (ply:GetUp() * 15)

			render.SetMaterial(voiceMat)
			render.DrawSprite(pos, 16, 16, Color(255, 255, 255, 255))
		end
	end)
end
