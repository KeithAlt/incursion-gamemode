TFA.INS2 = TFA.INS2 or {}
local defaultScopes = { "ins2_si_mx4", "ins2_si_mosin" } --default scope if it has it
local ForceAttachment = { --overwrites above
	["tfa_ins2_svu"] = "ins2_si_mosin",
	["tfa_ins2_svd"] = "ins2_si_mosin"
}
local attachmentCorrectionsPre = {}
local attachmentCorrections = {
	["ins2_si_eotech"] = {
		["VElements"] = {
			["sight_eotech"] = {
				["active"] = true
			}
		}
	},
	["ins2_si_kobra"] = {
		["VElements"] = {
			["sight_kobra"] = {
				["active"] = true
			}
		}
	},
	["ins2_si_rds"] = {
		["VElements"] = {
			["sight_rds"] = {
				["active"] = true
			}
		}
	},
	["ins2_si_2xrds"] = {
		["VElements"] = {
			["scope_2xrds"] = {
				["active"] = true
			}
		}
	},
	["ins2_si_c79"] = {
		["VElements"] = {
			["scope_c79"] = {
				["active"] = true
			}
		}
	},
	["ins2_si_po4x"] = {
		["VElements"] = {
			["scope_po4x"] = {
				["active"] = true
			}
		}
	},
	["ins2_si_mx4"] = {
		["VElements"] = {
			["scope_mx4"] = {
				["active"] = true
			}
		}
	},
	["ins2_si_mosin"] = {
		["VElements"] = {
			["scope_mosin"] = {
				["active"] = true
			}
		}
	}
}
local defaultValue = {
	["IronFOV"] = 70,
	["IronSightMoveSpeed"] = 0.9,
	["RTScopeFOV"] = 6
}
--don't modify below here unless you're confident you know what you're doing
function TFA.INS2.AnimateSight() end
function ApplyWeaponTableRecursive(source,target,wepom)
	if not source then return end
	if not target then return end
	for k,v in pairs(source) do
		if istable(v) then
			target[k] = target[k] or {}
			ApplyWeaponTableRecursive(v,target[k],wepom)
			--[[
		elseif isfunction(v) then
			local ent = wepom or target
			local succ, val = pcall( v,ent, target[k] or defaultValue[k] )
			if succ and type(val) ~= "function" then
				target[k] = val
			end
			]]--
		elseif target[k] == nil then
			target[k] = v
		elseif type(target[k]) == type(v) then
			target[k] = v
		end
	end
	for k,v in pairs(source) do
		if isfunction(v) then
			local ent = wepom or target
			local succ, val = pcall( v,ent, target[k] or defaultValue[k] )
			if succ and type(val) ~= "function" then
				target[k] = val
			end
		end
	end
end
function TFAApplyAttachment(attName,wep)
	local attachment = TFA.Attachments.Atts[attName]
	if not attachment then return end
	if not wep then return end
	ApplyWeaponTableRecursive(attachmentCorrectionsPre[attName],wep,wep)
	if attachment.Attach then
		attachment.Attach(table.Copy(attachment),wep)
	end
	ApplyWeaponTableRecursive(attachment.WeaponTable,wep,wep)
	ApplyWeaponTableRecursive(attachmentCorrections[attName],wep,wep)
end
function TFASelectAttachment(wep,attachments)
	for k,v in ipairs(defaultScopes) do
		local found
		for l, b in pairs(attachments.atts) do
			if b == v then
				found = true
				attachments.sel = l
				break
			end
		end
		if found then
			break
		end
	end
	for k,v in pairs(attachments.atts) do
		if ForceAttachment[wep] == v then
			attachments.sel = k
		end
	end
end
function TFAApplyAttachmentOuter(wep)
	if wep.Attachments and weapons.IsBasedOn(wep.ClassName or "", "tfa_gun_base") then
		for k,v in pairs(wep.Attachments) do
			TFASelectAttachment(wep,v)
			if v.sel and v.atts and v.sel >= 0 then
				TFAApplyAttachment(v.atts[v.sel],wep)
			end
		end
	end
end