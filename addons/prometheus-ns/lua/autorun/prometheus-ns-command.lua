hook.Add("InitPostEntity", "PrometheusNSCommands", function()
    nut.command.add("getpackages", {
        adminOnly = true,
    	onRun = function(ply, args)
    		local targetName = table.concat(args, " ")
            local target = nut.util.findPlayer(targetName)

            if IsValid(target) then
                Prometheus.DB.FetchPlayerBought(function(response)
                    if istable(response) then
                        local str = "Packages for " .. target:Nick() .. ": "

                        for _, package in pairs(response) do
                            str = str .. "'" .. package.title .. "' "
                        end
                        ply:ChatPrint(str)
                    else
                        ply:ChatPrint("No packages found for " .. target:Nick() .. ".")
                    end
                end, target)
            end
    	end
    })
end)