TFA.Attachments = TFA.Attachments or {}
TFA.Attachments.Atts = {}

TFA.Attachments.Colors = {
	["active"] = Color(252, 151, 50, 255),
	["error"] = Color(225, 0, 0, 255),
	["background"] = Color(15, 15, 15, 64),
	["primary"] = Color(245, 245, 245, 255),
	["secondary"] = Color(153, 253, 220, 255),
	["+"] = Color(128, 255, 128, 255),
	["-"] = Color(255, 128, 128, 255),
	["="] = Color(192, 192, 192, 255)
}

TFA.Attachments.UIPadding = 2
TFA.Attachments.Path = "tfa/att/"
TFA_ATTACHMENT_ISUPDATING = false

local function basefunc(t, k)
	if k == "Base" then return end
	if t.Base then
		local bt = TFA.Attachments.Atts[t.Base]
		if bt then return bt[k] end
	end
end

local inheritanceCached = {}

local function patchInheritance(t, basetbl)
	if not basetbl and t.Base then
		basetbl = TFA.Attachments.Atts[t.Base]

		if basetbl and istable(basetbl) and basetbl.ID and not inheritanceCached[basetbl.ID] then
			inheritanceCached[basetbl.ID] = true
			patchInheritance(basetbl)
		end
	end

	if not (basetbl and istable(basetbl)) then return end

	for k, v in pairs(t) do
		local baseT = basetbl[k]

		if istable(v) and baseT then
			patchInheritance(v, baseT)
		end
	end

	for k, v in pairs(basetbl) do
		if rawget(t, k) == nil then
			t[k] = v
		end
	end
end

function TFARegisterAttachment(att)
	if att.ID and att.ID ~= "base" then
		att.Base = att.Base or "base"
	end

	TFA.Attachments.Atts[att.ID or att.Name] = att
end

function TFAUpdateAttachments()
	TFA.AttachmentColors = TFA.Attachments.Colors --for compatibility
	TFA.Attachments.Atts = {}
	TFA_ATTACHMENT_ISUPDATING = true
	local tbl = file.Find(TFA.Attachments.Path .. "*base*", "LUA", "namedesc")
	local addtbl = file.Find(TFA.Attachments.Path .. "*", "LUA", "namedesc")

	for _, v in ipairs(addtbl) do
		if not string.find(v, "base") then
			table.insert(tbl, #tbl + 1, v)
		end
	end

	for _, v in ipairs(tbl) do
		local id = v
		v = TFA.Attachments.Path .. v
		ATTACHMENT = {}
		ATTACHMENT.ID = string.Replace(id, ".lua", "")

		if SERVER then
			AddCSLuaFile(v)
			include(v)
		else
			include(v)
		end

		setmetatable(ATTACHMENT, {
			__index = basefunc
		})

		TFARegisterAttachment(ATTACHMENT)
		ATTACHMENT = nil
	end

	for k, v in pairs(TFA.Attachments.Atts) do
		patchInheritance(v)
	end

	ProtectedCall(function()
		hook.Run("TFAAttachmentsLoaded")
	end)

	TFA_ATTACHMENT_ISUPDATING = false
end

hook.Add("InitPostEntity", "TFAUpdateAttachmentsIPE", TFAUpdateAttachments)

if TFAUpdateAttachments then
	TFAUpdateAttachments()
end