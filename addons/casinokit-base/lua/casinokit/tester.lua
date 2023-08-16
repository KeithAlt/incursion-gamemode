local assert_lib = {}
do
	-- better assert function; delegates error to testing file
	local function assert(cond, desc)
		if not cond then
			error(desc or "assertion failed!", 3)
		end
	end

	function assert_lib.equal(x, y, desc)
		assert(x == y, desc or ("'" .. tostring(x) .. "' is not equal to '" .. tostring(y) .. "'"))
	end

	local function isShallowEqual(x, y)
		local eq = true
		for k,v in pairs(x) do
			if y[k] ~= v then eq = false break end
		end
		for k,v in pairs(y) do
			if x[k] ~= v then eq = false break end
		end
		return eq
	end
	function assert_lib.shallow_equal(x, y, desc)
		assert(isShallowEqual(x, y), desc)
	end
	function assert_lib.not_shallow_equal(x, y, desc)
		assert(not isShallowEqual(x, y), desc)
	end
	function assert_lib.truthy(x, desc)
		assert(not not x, desc or ("'" .. tostring(x) .. "' is not truthy"))
	end
	function assert_lib.falsy(x, desc)
		assert(not x, desc or ("'" .. tostring(x) .. "' is not falsy"))
	end
	function assert_lib.no_errors(fn, desc)
		assert(type(fn) == "function", "parameter 'fn' must be a function")

		local stat, err = pcall(fn)
		assert(stat, desc or ("got error: " .. tostring(err)))
	end
	function assert_lib.errors(fn, desc)
		assert(type(fn) == "function", "parameter 'fn' must be a function")

		local stat, err = pcall(fn)
		assert(not stat, desc or "did not get errors")
	end
end

local util_lib = {}
do
	function util_lib.mockPlayer(tbl)
		if type(tbl) == "boolean" then
			tbl = {fakeValidity = tbl}
		end
		tbl = tbl or {}

		local p = CasinoKit.classes.Player()
		if tbl.fakeValidity then
			p.isValid = function() return true end
		end

		return p
	end
	function util_lib.mockTable(tbl)
		if type(tbl) == "number" then
			tbl = {slots = tbl}
		end
		tbl = tbl or {slots = 3}

		return CasinoKit.classes.Table(tbl.slots)
	end
end

function CasinoKit.test()
	print(" == CasinoKit: Starting testing == ")

	local tests = {}
	local test_env = setmetatable({}, {__index = _G})

	test_env.assert = assert_lib
	test_env.testutil = util_lib

	-- shorthand
	test_env.cls = CasinoKit.classes

	function test_env.describe(smth, fn)
		local tbl = {desc = smth, its = {}}
		table.insert(tests, tbl)

		local descEnv = setmetatable({
			it = function(smth, fn)
				table.insert(tbl.its, {desc = smth, fn = fn})
			end
		}, {__index = test_env})
		setfenv(fn, descEnv)
		fn()
	end

	print(" == CasinoKit: Loading tests == ")

	local paths  = {"addons/casinokit/tests/", "addons/gmod-casinokit/tests/"}
	for _,path in pairs(paths) do
		for _,fil in pairs(file.Find(path .. "*.lua", "GAME")) do
			local contents = file.Read(path .. fil, "GAME")
			local fn = CompileString(contents, "casinokit test " .. fil)
			setfenv(fn, test_env)
			fn()
		end
	end

	print(" == CasinoKit: Running tests == ")

	local complCount, failCount = 0, 0
	local function runTests(tbl)
		for k,v in pairs(tbl) do
			print(v.desc)
			for _,it in pairs(v.its) do
				Msg("\t" .. it.desc .. ": ")
				local stat, err = pcall(it.fn)
				if stat then
					MsgC(Color(0, 255, 0), "yup")
				else
					local file, line, err = err:match("(.-):(%d+):(.*)")
					MsgC(Color(255, 0, 0), "nope (line #" .. line .. " in " .. file .. ": " .. err .. ")")
					failCount = failCount + 1
				end
				complCount = complCount + 1
				MsgN("")
			end
		end
	end

	runTests(tests)

	Msg(" == CasinoKit: Tests complete (") MsgC(Color(200, 200, 200), complCount) Msg(" completed - ") MsgC(failCount > 0 and Color(255, 0, 0) or Color(200, 200, 200), failCount) MsgN(" failed) == ")
end

concommand.Add("casinokit_test", CasinoKit.test)
