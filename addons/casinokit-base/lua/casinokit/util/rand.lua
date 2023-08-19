local NICE_COLOR = Color(38, 166, 91)
local SCARY_COLOR = Color(242, 38, 19)
local function ScaryTextBlock(tbl)
	MsgC(SCARY_COLOR, "######################\n")
	for _,t in pairs(tbl) do
		MsgC(SCARY_COLOR, "# " .. t .. "\n")
	end
	MsgC(SCARY_COLOR, "######################\n")
end

CasinoKit.rand = {}

-- Use math.random in the beginning.
-- AttemptInstallCSPRNG will try to change this to use a cryptographically secure
-- number generation function or print a huge warning message if it does not succeed.
CasinoKit.rand.random = math.random
CasinoKit.rand.isCrypto = false

local cvar_disablecryptorng = CreateConVar("casinokit_disablecryptorng", "0", FCVAR_ARCHIVE)

local function AttemptInstallCSPRNG()
	if cvar_disablecryptorng:GetBool() then
		MsgC(SCARY_COLOR, "[CasinoKit] Warning: Cryptrand is disabled which is a security risk! Use 'casinokit_disablecryptorng 0' to re-enable.\n")
		return
	end

	local ret = pcall(require, "cryptrandom")
	if not ret or not CryptRandom then
		ScaryTextBlock {
			"WARNING",
			"Currently using insecure method of random number generation.",
			"This makes it trivial for a malicious actor to cheat the system",
			"(for example accurately guess the contents of a shuffled deck)",
			"This allows said person to cheat the system without trace!",
			"",
			"Games will continue working normally, but it is VERY highly advised",
			"to install the secure random number generation module.",
			"",
			"Type 'casinokit_cryptohelp' in RCON (the console you're reading right",
			"now) for installation instructions."
		}

		-- Try again in a bit
		timer.Create("CasinoKit_CSPRNG_AttemptInstall", 60 * 60, 1, AttemptInstallCSPRNG)
	else
		local testnumber, m = CryptRandom()
		if type(testnumber) == "number" and testnumber >= 0 and testnumber <= 1 then
			MsgC(NICE_COLOR, "[CasinoKit] Secure cryptographic number generator is installed and working properly.\n")
		else
			MsgC(SCARY_COLOR, "[CasinoKit] Warning! Invalid cryptrand output: " .. tostring(testnumber) .. "/" .. tostring(m) .. ". Contact developer.\n")
		end

		CasinoKit.rand.random = CryptRandom
		CasinoKit.rand.isCrypto = true
	end
end

AttemptInstallCSPRNG()

concommand.Add("casinokit_cryptohelp", function(ply)
	if IsValid(ply) then return end

	if CasinoKit.rand.isCrypto then
		MsgC(NICE_COLOR, "Note: crypto library is already correctly installed! Here's the instructions for reference:\n")
	end

	local suffix = system.IsWindows() and "win32" or "linux"
	MsgN("1. Move gmsv_cryptorandom_" .. suffix .. ".dll from garrysmod/addon/casinokit/lua/bin/ to garrysmod/lua/bin/ (create the folder if it does not exist)")
	MsgN("2. Restart/change map")
	MsgN("3. You should no longer see an error message in the console")
end)
