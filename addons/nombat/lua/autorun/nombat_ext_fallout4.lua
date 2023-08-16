/** if SERVER then

        resource.AddWorkshop(565016032) --place you workshop addon number here ( I told you to copy it remember ;) )

end **/

if CLIENT then

        function Nombat_Cl_Init(  )

                local pl = LocalPlayer() -- (DONT EDIT)
 
                if IsValid(pl) then

                        if pl then

                                pl.NOMBAT_Level = 1 -- (DONT EDIT)
                                pl.NOMBAT_PostLevel = 1 -- (DONT EDIT)

                                local Ambient_Time = {242,267,256,315,256,254} --song time (in seconds)
                                pl.NOMBAT_Amb_Delay = CurTime() -- (DONT EDIT)

                                local Combat_Time = {122,122,120,132,94,130} --song time (in seconds)
                                pl.NOMBAT_Com_Delay = CurTime() -- (DONT EDIT)
                                pl.NOMBAT_Com_Cool = CurTime() -- (DONT EDIT)

                                local packName = "fallout4"--MAKE SURE THIS IS THE SAME AS THE FOLDER NAME HOLDING THE SOUNDS

                                packName = packName.."/" -- (DONT EDIT)

                                local subTable = { packName, Ambient_Time, Combat_Time } -- (DONT EDIT)

                                if !pl.NOMBAT_PackTable then -- (DONT EDIT)
                                        pl.NOMBAT_PackTable = {subTable} -- (DONT EDIT)

                                else
                                        table.insert( pl.NOMBAT_PackTable, subTable ) -- (DONT EDIT)
                                end

                                pl.NOMBAT_SVol = 0 -- (DONT EDIT)

                        end
                end
        end
        hook.Add( "InitPostEntity", "Nombat_Cl_Init_fallout4", Nombat_Cl_Init ) -- change the "Nombat_Cl_Init_GAMENAME" to "Nombat_Cl_Init_" and your game name.

end





