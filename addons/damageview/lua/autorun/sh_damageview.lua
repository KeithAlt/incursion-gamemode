AddCSLuaFile()

hook.Add("meleeInit", "isMeleeInit", function()
    local WEAPON = FindMetaTable("Weapon")

    local meleeWeps = {
    	["weapon_rebarclub_len_m2"] = true,
    	["weapon_bowieknife_len_m2"] = true,
    	["weapon_boxinggloves_len_m2"] = true,
		["weapon_brassknuckles_len_m2"] = true,
		["weapon_bumpersword_len_m2"] = true,
		["weapon_cleaver_len_m2"] = true,
		["weapon_commiewacker_len_m2"] = true,
		["weapon_deathclawgauntlet_len_m2"] = true,
		["weapon_fireaxe_len_m2"] = true,
		["weapon_hook_len_m2"] = true,
		["weapon_kitchenknife_len_m2"] = true,
		["weapon_laserkatana_len_m2"] = true,
		["weapon_leadpipe_len_m2"] = true,
		["weapon_legionblade_len_m2"] = true,
		["weapon_machete_len_m2"] = true,
		["weapon_machetegladius_len_m2"] = true,
		["weapon_policebaton_len_m2"] = true,
		["weapon_powerfist_len_m2"] = true,
		["weapon_protonaxe_len_m2"] = true,
		["weapon_rebarclub_len_m2"] = true,
		["weapon_shishkebab_len_m2"] = true,
		["weapon_shovel_len_m2"] = true,
		["meleearts_axe_fireaxe"] = true,
		["meleearts_blade_throwingknife"] = true,
		["meleearts_axe_trenchaxe"] = true,
		["meleearts_bludgeon_sledgehammer"] = true,
		["meleearts_spear_shovel"] = true,
		["meleearts_blade_sword"] = true,
		["meleearts_bludgeon_crowbar"] = true,
		["meleearts_staff_bamboo"] = true,
    	["nut_hands"] = true
    }

    for k,v in pairs(nut.fallout.registry.melee) do
    	meleeWeps[k] = true
    end

    function WEAPON:isMelee()
    	return meleeWeps[self:GetClass()] or false
    end
end)

if CLIENT then
    local energyWeapons = 
    {
        ["MicrofusionCell"] = true,
        ["EnergyCell"] = true,
        ["ElectronChargePack"] = true,
    }

    local function start()

    local prim = nut.gui.palette.color_primary
    local col = Color(prim.r, prim.g, prim.b, prim.a)

    local shouldDrawDmg = false
    hook.Add("PlayerSwitchWeapon", "damageviewStart", function(ply, button)
        shouldDrawDmg = true
        col.a = 255
        hook.Add("Think", "damageviewFade", function()
            col.a = math.max(col.a - (FrameTime() * 100), 0)
            if col.a <= 0 then
                shouldDrawDmg = false
                col.a = 255
                hook.Remove("Think", "damageviewFade")
            end
        end)
    end)

    local w, h = ScrW(), ScrH()
    hook.Add("HUDPaint", "damageviewHUD", function()
        if !shouldDrawDmg then return end
        local wep = LocalPlayer():GetActiveWeapon()
        if !IsValid(wep) then return end

        local dmg
        local p = wep.Primary
        if !p then return end
        dmg = p.Damage or p.DmgMin
        if !dmg then
            dmg = wep.DmgMin
            if !dmg then return end
        end

        --Add rarity bonus
        local rarity = wep:GetNWInt("rarity", 1)
        dmg = dmg * (1 + (wRarity.Config.Rarities[rarity].buff / 100))

        --Calculate bonus based on their special stats
        local bonus = ""

        local char = LocalPlayer():getChar()
        local strength
        local intelligence
        local perception

        if char then
            strength  = LocalPlayer():getSpecial("S")
            perception = LocalPlayer():getSpecial("P")
            intelligence = LocalPlayer():getSpecial("I")


            if wep:isMelee() or wep.Base == "dangumeleebase" then
                local modifier = ((strength/25) / 1.6)
                bonus = "(+" .. dmg * modifier .. ")"
            else

                // Energy weapons gain buff from intelligence and ballistic from perception
                if energyWeapons[wep.Primary.Ammo] then
                    local modifier = (0.010 * intelligence)
                    bonus = "(+" .. dmg * modifier .. ")"
                else
                    local modifier = (0.010 * perception)
                    bonus = "(+" .. dmg * modifier .. ")"
                end

            end
        end

        surface.SetFont("Trebuchet24")
        surface.SetTextColor(col)
        surface.SetTextPos(w/2, h/2)
        surface.DrawText("Weapon Damage: " .. dmg .. bonus)
    end)

    end

    hook.Add("InitPostEntity", "damageViewStart", start)
end