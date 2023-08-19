if SERVER then
    util.AddNetworkString("SpawnProtectionStarted")
    util.AddNetworkString("SpawnProtectionStopped")
    resource.AddFile("materials/spawnprotection/shield-64.png")

    hook.Add("PlayerSpawn", "SpawnProtection", function(ply)
        if ply.NoProtect then
            return
        end

        timer.Simple(0.1, function()
            if IsValid(ply) then
                net.Start("SpawnProtectionStarted")
                net.Send(ply)

                ply:GodEnable()
                ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
                ply:SetColor(Color(255, 255, 255, 150))
                ply.SpawnProtect = true

                timer.Create("SpawnProtection" .. ply:SteamID64(), 5, 1, function()
                    if IsValid(ply) then
                        net.Start("SpawnProtectionStopped")
                        net.Send(ply)

                        ply:GodDisable()
                        ply:SetRenderMode(RENDERMODE_NORMAL)
                        ply.SpawnProtect = nil
                    end
                end)
            end
        end)
    end)

    hook.Add("EntityTakeDamage", "SpawnProtection", function(ent, dmg)
        local attacker = dmg:GetAttacker()
        if IsValid(attacker) and attacker:IsPlayer() and attacker.SpawnProtect then
            return true
        end
    end)

	hook.Add("PlayerInitialSpawn", "AntiSpawnKill", function(ply)	-- Prevents a spawn kill issue
		local player = ply

		timer.Simple(1, function() -- Requires 1 second worth of ticks to execute as intended
			MsgC(Color(255,0,0), "[Anti-Ghost Kill] ", Color(255,255,255), jlib.SteamIDName(player) .. " initially joined ; Setting off-map position\n") -- DEBUG
			player:SetPos(Vector(9999,9999,9999)) -- 9999 due to high likelyhood of non-existent map space
		end)
	end)
end

if CLIENT then
    local tex = Material("spawnprotection/shield-64.png")

    net.Receive("SpawnProtectionStarted", function()
        hook.Add("HUDPaint", "SpawnProtection", function()
            local hpBar = nut.fallout.gui.bars.hp
            local w, h = 64, 64

            surface.SetMaterial(tex)
            surface.SetDrawColor(nut.gui.palette.color_primary)
            if hpBar then
                surface.DrawTexturedRect(hpBar.x + hpBar.w + w, hpBar.y - (h / 2), w, h)
            else
                surface.DrawTexturedRect(ScrW() - 50 - w, ScrH() - 135 - h, w, h)
            end
        end)
    end)

    net.Receive("SpawnProtectionStopped", function()
        hook.Remove("HUDPaint", "SpawnProtection")
    end)
end
