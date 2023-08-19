local tmpmat
local fname

function TFA.PrecacheDirectory(dir, typev)
	if not typev then
		typev = ""

		if string.find(dir, "material") then
			typev = "mat"
		elseif string.find(dir, "model") then
			typev = "mdl"
		elseif string.find(dir, "sound") then
			typev = "snd"
		end
	end

	local files, directories = file.Find(dir .. "*", "GAME")

	for _, fdir in pairs(directories) do
		if fdir ~= ".svn" and fdir ~= ".git" then
			TFA.PrecacheDirectory(dir .. fdir .. "/", typev)
		end
	end

	for k, v in pairs(files) do
		fname = string.lower(dir .. v)

		if (string.find(v, ".vmt") or string.find(v, ".vtf") or string.find(v, ".png")) and (typev == "" or typev == "mat") then
			tmpmat = Material(string.Replace(fname, ".vmt", ""))
			tmpmat:GetKeyValues()
		elseif string.find(v, ".mdl") and (typev == "" or typev == "mdl") then
			util.PrecacheModel(fname)
		elseif (string.find(v, ".wav") or string.find(v, ".mp3")) and (typev == "" or typev == "snd") then
			util.PrecacheSound(fname)
		end
	end
end

--[[
local cv_icon
local cv_mdl
local cv_mat
local cv_snd

cv_icon = GetConVar("mp_tfa_precache_icons")
if cv_icon == nil then
	cv_icon = CreateConVar("mp_tfa_precache_icons", "1", { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_UNREGISTERED }, "Precache spawn/hud icons?")
end

cv_mdl = GetConVar("mp_tfa_precache_models")
if cv_mdl == nil then
	cv_mdl = CreateConVar("mp_tfa_precache_models", "0",{ FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_UNREGISTERED }, "Precache weapon models?")
end

cv_mat = GetConVar("mp_tfa_precache_materials")
if cv_mat == nil then
	cv_mat = CreateConVar("mp_tfa_precache_materials", "0", { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_UNREGISTERED }, "Precache weapon materials?")
end

cv_snd = GetConVar("mp_tfa_precache_sounds")
if cv_snd == nil then
	cv_snd = CreateConVar("mp_tfa_precache_sounds", "0", { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_UNREGISTERED }, "Precache weapon sounds?")
end

hook.Add("InitPostEntity","TFAPrecache",function()
	if not cv_icon or cv_icon:GetBool() then
		PrecacheDirectory("materials/vgui/entities/")
		PrecacheDirectory("materials/vgui/hud/")
	end
	if cv_mdl and cv_mdl:GetBool() then
		PrecacheDirectory("models/weapons/")
	end
	if cv_mat and cv_mat:GetBool() then
		PrecacheDirectory("materials/models/weapons/")
		PrecacheDirectory("materials/models/tfa_csgo/")
		PrecacheDirectory("materials/models/tfa_l4d2/")
	end
	if cv_snd and cv_snd:GetBool() then
		PrecacheDirectory("sound/impacts/")
		PrecacheDirectory("sound/weapons/")
	end
end)
]]--