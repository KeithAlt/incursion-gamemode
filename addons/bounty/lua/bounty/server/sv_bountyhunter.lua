local PLAYER = FindMetaTable("Player")

JOB_BOARD_LIST = JOB_BOARD_LIST or {}
POSTER_LIST = POSTER_LIST or {}
JOB_REQUEST_LIST = JOB_REQUEST_LIST or {}

local function JobRequest(prize, reason, contact, removeOnDC, icon) -- too lazy to use metatable.
	return {
        reason = reason or "An unknown reason.",
        contact = contact or "An unknown contact.",
        prize = prize or "An unknown reward.",
        removeOnDC = removeOnDC,
        icon = icon,
		timeLeft = POSTER_TIMEOUT
    }
end

util.AddNetworkString("RemoveBountyMenu")
util.AddNetworkString("NewBountySound")
util.AddNetworkString("UpdateBountyMenu")
util.AddNetworkString("AddNewBountyPoster")
util.AddNetworkString("open_place_bounty_menu")
util.AddNetworkString("create_job")

util.AddNetworkString("nutJobAdd")
util.AddNetworkString("nutJobRemove")
util.AddNetworkString("nutJobUpdate")
util.AddNetworkString("nutJobSync")

-- resource.AddWorkshop("752909534")
resource.AddFile("materials/bountyframe.png")
resource.AddSingleFile("materials/bountytarget.png")
resource.AddFile("materials/models/bountyboard.vtf")
resource.AddFile("materials/models/bountyboard.vmt")

local function distributePosters(charID)
    for entity, _ in pairs(JOB_BOARD_LIST) do
        entity:addPoster(charID)
    end
end

if (SERVER) then
    function PLAYER:redistPosters()
		local charID = tonumber(self:getChar():getID())

        local bountyInfo = JOB_REQUEST_LIST[charID]

        if (bountyInfo) then
            distributePosters(charID)
        end
    end

    function PLAYER:createJob(prize, reason, contact, removeOnDC, icon)
		local info = JobRequest(prize, reason, contact, removeOnDC, icon)
        info.name = self:Name()

		local charID = tonumber(self:getChar():getID())

        JOB_REQUEST_LIST[charID] = info

        net.Start("nutJobAdd")
            net.WriteString(charID) --for some reason WriteInt doesn't work here
            net.WriteTable(info)
        net.Broadcast()

        distributePosters(charID)

        hook.Run("OnPlayerBountyAdded", self, prize, reason, contact, icon, charID)

        self:notify("Successfully posted job.")
    end

    function PLAYER:removeJob()
		local charID = tonumber(self:getChar():getID())

		JOB_REQUEST_LIST[charID] = nil

		net.Start("nutJobRemove")
			net.WriteString(charID) --doesnt work here either
		net.Broadcast()

        self:notify("Successfully removed job.")
    end
end

net.Receive("create_job", function(len, client)
    local prize, reason, contact, removeOnDC, icon = net.ReadString(), net.ReadString(), net.ReadString(), net.ReadBool(), net.ReadString()

    local isNearBoard = false
    for entity, _ in pairs(JOB_BOARD_LIST) do
        if entity:GetPos():Distance(client:GetPos()) < 250 then
            isNearBoard = true
            break
        end
    end

    if !isNearBoard then
        client:notify("You are not near a bounty board to list this.")
        return
    end

    if (IsValid(client)) then
        if client:CanCreateJob() then
			client:createJob(prize, reason, contact, removeOnDC, icon)

			local bountyMsg = "A new job has been added to the job board."
			nut.chat.send(client, "bounty", bountyMsg)

			DiscordEmbed("**Reward:** " ..prize.. "| **Job:** " .. reason, "📜 Job Listing Added 📜", Color(255, 83, 0), "IncursionFeed")
        else
            client:notifyLocalized("notValid")
        end
    end
end)

function btQuack:PlayerInitialSpawn(client)
    timer.Simple(10, function()
        net.Start("nutJobSync")
            net.WriteString(util.TableToJSON(JOB_REQUEST_LIST))
        net.Send(client)
    end)
end
hook.Add("PlayerInitialSpawn", btQuack, btQuack.PlayerInitialSpawn)

function btQuack:PlayerDisconnected(client)
	local char = client:getChar()
	if(char) then
		local charID = char:getID()

		if(!JOB_REQUEST_LIST[charID]) then return end --save us some calculations

		for keyID, poster in pairs(JOB_REQUEST_LIST) do
			if(keyID == charID and poster.removeOnDC) then
				JOB_REQUEST_LIST[charID] = nil --erase it

				for k, board in ipairs(ents.FindByClass("bountyboard")) do
					board:removeJobOf(charID)
				end
			end
		end

		--networks removal of job
		for k, player in pairs(player.GetAll()) do
			net.Start("nutJobRemove")
				net.WriteString(charID)
			net.Send(player)
		end
	end
end
hook.Add("PlayerDisconnected", btQuack, btQuack.PlayerDisconnected)

function btQuack:PlayerLoadedChar(client, char, oldChar)
	if(!oldChar) then return end

	local charID = oldChar:getID()

	if(!JOB_REQUEST_LIST[charID]) then return end --save us some calculations

    for keyID, poster in pairs(JOB_REQUEST_LIST) do
		if(keyID == charID and poster.removeOnDC) then
			JOB_REQUEST_LIST[charID] = nil --erase it

			for k, board in ipairs(ents.FindByClass("bountyboard")) do
				board:removeJobOf(charID)
			end

			--networks removal of job
			for k, player in pairs(player.GetAll()) do
				net.Start("nutJobRemove")
					net.WriteString(charID)
				net.Send(player)
			end
		end
	end
end
hook.Add("PlayerLoadedChar", btQuack, btQuack.PlayerLoadedChar)

function btQuack:Think()
	if((self.nextPosterT or 0) < CurTime()) then
		self.nextPosterT = CurTime() + 1

		for charID, poster in pairs(JOB_REQUEST_LIST) do
			local timeLeft = poster.timeLeft or 0 --how many minutes are left in the poster's life

			if(timeLeft < 1) then --life over
				JOB_REQUEST_LIST[charID] = nil --erase it

				for k, board in ipairs(ents.FindByClass("bountyboard")) do
					board:removeJobOf(charID)
				end

				--networks the removal to everybody, kind of sucks
				for k, client in pairs(player.GetAll()) do
					net.Start("nutJobRemove")
						net.WriteString(charID)
					net.Send(player)
				end
			else
				JOB_REQUEST_LIST[charID].timeLeft = timeLeft - 1
			end
		end
	end
end
hook.Add("Think", btQuack, btQuack.Think)

local blacklist = {bountyboard = true, bountyposter = true}
function btQuack:CanTool(client, trace, tool)
    local entity = trace.Entity

    if (IsValid(entity)) then
        local class = entity:GetClass()

        if (blacklist[class]) then
            if (not client:IsSuperAdmin()) then
                return false
            end

            return true
        end
    end
end
hook.Add("CanTool", btQuack, btQuack.CanTool)

function btQuack:CanProperty(client, stringproperty, entity)
    if (IsValid(entity)) then
        local class = entity:GetClass()

        if (blacklist[class] and not client:IsSuperAdmin()) then
            return false
        end
    end
end
hook.Add("CanProperty", btQuack, btQuack.CanProperty)

local map = game.GetMap():lower()

function btQuack:SaveData()
    local listOfBoards = {}

    for k, v in ipairs(ents.FindByClass('bountyboard')) do
        table.insert(listOfBoards, {
            pos = v:GetPos(),
            ang = v:GetAngles()
        })
    end

	--probably not the best way to save this
    util.SetPData(map.."1", "superQuack", util.TableToJSON(listOfBoards))
    util.SetPData(map.."2", "superQuack", util.TableToJSON(JOB_REQUEST_LIST))
end
hook.Add("SaveData", btQuack, btQuack.SaveData)

function btQuack:LoadData()
    for k, v in ipairs(ents.FindByClass('bountyboard')) do
        v:Remove()
    end

    local loadedData = util.GetPData(map.."1", "superQuack")
    local jobReq = util.GetPData(map.."2", "superQuack")

	if(jobReq) then
		JOB_REQUEST_LIST = util.JSONToTable(jobReq)

		for charID, job in pairs(JOB_REQUEST_LIST) do
			timer.Simple(0, function() --makes sure they don't get yeeted
				distributePosters(tonumber(charID))
			end)
		end
	end

    if (loadedData) then
        local listOfBoards = util.JSONToTable(loadedData)

        for _, data in pairs(listOfBoards) do
            local ent = ents.Create('bountyboard')
            ent:SetPos(data.pos)
            ent:SetAngles(data.ang)
            ent:Spawn()
            ent:Activate()

            local phys = ent:GetPhysicsObject()
            if (IsValid(phys)) then
                phys:EnableMotion(false)
            end
        end
    end
end

hook.Add("LoadData", btQuack, btQuack.LoadData)
