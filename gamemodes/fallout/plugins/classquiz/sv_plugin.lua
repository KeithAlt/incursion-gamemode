local PLUGIN = PLUGIN
PLUGIN.banTime = 30
PLUGIN.maxWrong = 1

PLUGIN.Quizzes = {}
PLUGIN.Quizzes[1] = {
	"Freeside Resident Registry", -- Title that will show up on the prop
	"models/maxib123/deskterminal.mdl", -- The model for the entity

	{ -- Table that contains all the questions
		{
			"Would you like to become a Resident of Freeside?", -- Question title
			{ -- Possible answers
				"Yes",
				"No"
			}
		},

	},
	{{[1] = true}}, -- We precise the first anwser (Yes) is a correct one
	CLASS_BLYTHE, -- It will set this class if all the answers are correct
	banOnFail = false, -- It will ban the char from the quizz for PLUGIN.banTime
	failMessage = false, -- Will show "You failed the quizz" if the char failed it
	FACTION_WASTELANDER, -- The needed faction to pass the quizz
}

PLUGIN.Quizzes[2] = {
	"Scrapton Resident Registry", -- Title that will show up on the prop
	"models/maxib123/deskterminal.mdl", -- The model for the entity

	{ -- Table that contains all the questions
		{
			"Would you like to become a Resident of Scrapton?", -- Question title
			{ -- Possible answers
				"Yes",
				"No"
			}
		},

	},
	{{[1] = true}}, -- We precise the first anwser (Yes) is a correct one
	CLASS_CRATER, -- It will set this class if all the answers are correct
	banOnFail = false, -- It will ban the char from the quizz for PLUGIN.banTime
	failMessage = false, -- Will show "You failed the quizz" if the char failed it
	FACTION_WASTELANDER, -- The needed faction to pass the quizz
}

PLUGIN.Quizzes[3] = {
	"Robotics Station - Eyebot", -- Title that will show up on the prop
	"models/mosi/fallout4/furniture/workstations/robotworkbench.mdl", -- The model for the entity

	{ -- Table that contains all the questions
		{
			"Would you like to convert into an Eyebot? (Warning: This will remove you from a faction if done)", -- Question title
			{ -- Possible answers
				"Yes",
				"No"
			}
		},

	},
	{{[1] = true}}, -- We precise the first anwser (Yes) is a correct one
	CLASS_EYEBOT_DEFAULT, -- It will set this class if all the answers are correct
	banOnFail = false, -- It will ban the char from the quizz for PLUGIN.banTime
	failMessage = false, -- Will show "You failed the quizz" if the char failed it
	FACTION_ROBOT, -- The needed faction to pass the quizz
}

PLUGIN.Quizzes[4] = {
	"Robotics Station - Gutsy", -- Title that will show up on the prop
	"models/mosi/fallout4/furniture/workstations/robotworkbench.mdl", -- The model for the entity

	{ -- Table that contains all the questions
		{
			"Would you like to convert into a Mister Gutsy? (Warning: This will remove you from a faction if done)", -- Question title
			{ -- Possible answers
				"Yes",
				"No"
			}
		},

	},
	{{[1] = true}}, -- We precise the first anwser (Yes) is a correct one
	CLASS_GUTSY_DEFAULT, -- It will set this class if all the answers are correct
	banOnFail = false, -- It will ban the char from the quizz for PLUGIN.banTime
	failMessage = false, -- Will show "You failed the quizz" if the char failed it
	FACTION_ROBOT, -- The needed faction to pass the quizz
}

PLUGIN.Quizzes[5] = {
	"Robotics Station - Protectron", -- Title that will show up on the prop
	"models/mosi/fallout4/furniture/workstations/robotworkbench.mdl", -- The model for the entity

	{ -- Table that contains all the questions
		{
			"Would you like to convert into a Protectron? (Warning: This will remove you from a faction if done)", -- Question title
			{ -- Possible answers
				"Yes",
				"No"
			}
		},

	},
	{{[1] = true}}, -- We precise the first anwser (Yes) is a correct one
	CLASS_PROTECTRON_DEFAULT, -- It will set this class if all the answers are correct
	banOnFail = false, -- It will ban the char from the quizz for PLUGIN.banTime
	failMessage = false, -- Will show "You failed the quizz" if the char failed it
	FACTION_ROBOT, -- The needed faction to pass the quizz
}

PLUGIN.Quizzes[6] = {
	"NCR Citizenship Registry", -- Title that will show up on the prop
	"models/maxib123/deskterminal.mdl", -- The model for the entity

	{ -- Table that contains all the questions
		{
			"Who was the most popular president of the New California Republic?", -- Question title
			{ -- Possible answers
				"President Kimball",
				"President Tandi",
				"President Mammoth",
			}
		},
		{
			"What was the original name of the New California Republic capital?", -- Question title
			{ -- Possible answers
				"Provo City",
				"Shady Sands",
				"Navarro"
			}
		},
		{
			"What is the animal on the flag of the NCR?", -- Question title
			{ -- Possible answers
				"A two-headed bear",
				"A bull",
				"A radroach"
			}
		},

	},
	{{[2] = true}, {[2] = true}, {[1] = true}}, -- We precise the first anwser (Yes) is a correct one
	CLASS_WASTELANDER_NCR, -- It will set this class if all the answers are correct
	banOnFail = false, -- It will ban the char from the quizz for PLUGIN.banTime
	failMessage = true, -- Will show "You failed the quizz" if the char failed it
	FACTION_WASTELANDER, -- The needed faction to pass the quizz
}

netstream.Hook("fo_classquizz", function( ply, ent, answers )
	local char = ply:getChar()
	if not char then return end
	if not ent.foQuizz then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > 20000 then return end
	if char:getFaction() != PLUGIN.Quizzes[ent.foQuizz][6] then return end
	if char:getClass() == PLUGIN.Quizzes[ent.foQuizz][5] then return end
	if not PLUGIN:CanTakeQuizz(char, ent.foQuizz) then return end

	for k, v in pairs(PLUGIN.Quizzes[ent.foQuizz][4]) do
		if not v[answers[k]] then
			if ( PLUGIN.Quizzes[ent.foQuizz].banOnFail ) then
				local newData = char:getData("quizzes", {})
				newData[ent.foQuizz] = os.time() + PLUGIN.banTime
				char:setData("quizzes", newData)

				if ( PLUGIN.Quizzes[ent.foQuizz].failMessage ) then
					ply:notify("You failed the quizz, you may take it again on "..os.date("%c", os.time() + PLUGIN.banTime))
				end
			elseif ( PLUGIN.Quizzes[ent.foQuizz].failMessage ) then
				ply:notify("You failed the quizz")
			end

			return
		end
	end

	local classID = PLUGIN.Quizzes[ent.foQuizz][5]
	local class = nut.class.list[classID]
	char:setData("class", class.uniqueID)
	char:joinClass(classID)
	ply:notify("You joined the class.")
end)

function PLUGIN:LoadData()
	local savedTable = self:getData() or {}

	for k, v in ipairs(savedTable) do
		local ent = ents.Create("fo_classquizz")
		local quizz = PLUGIN.Quizzes[v.id]
		ent.foQuizz = v.id
		ent:setNetVar("title", quizz[1])
		ent:SetModel(quizz[2])
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		ent:Activate()
		ent:SetMoveType(MOVETYPE_NONE)

		--[[local physicsObject = stash:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion()
		end--]]
	end
end

function PLUGIN:SaveData()
	local savedTable = {}

	for k, v in ipairs(ents.GetAll()) do
		if (v:GetClass() == "fo_classquizz") then
			table.insert(savedTable, {pos = v:GetPos(), ang = v:GetAngles(), id = v.foQuizz})
		end
	end

	self:setData(savedTable)
end
