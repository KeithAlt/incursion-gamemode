--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems
	
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

local precacheSounds = {
	"alydus/servo.wav",
	"alydus/controllerclick.wav"
}

for _, sound in pairs(precacheSounds) do
	util.PrecacheSound(sound)
end