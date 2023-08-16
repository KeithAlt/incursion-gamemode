if SERVER then
    hook.Add("PlayerSpawn", "mrgatlingondeath", function(ply)
        if !(IsValid(ply)) then
            return
        end
        ply:ConCommand( "-speed" )
        ply:ConCommand( "-walk" )
    end)
end