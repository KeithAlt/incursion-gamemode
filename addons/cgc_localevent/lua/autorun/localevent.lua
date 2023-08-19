// Renders the affected area when /localevent is in the chatbox.
hook.Add("PostDrawOpaqueRenderables", "LOCALEVENT_DrawDistance", function(depth, skybox)
    if depth or skybox then return end
    if !LocalPlayer():IsAdmin() then return end

    if IsValid(nut.gui.chat) and IsValid(nut.gui.chat.text) and (string.find(nut.gui.chat.text:GetText(), "/localevent") or string.find(nut.gui.chat.text:GetText(), "/localsound")) then
        local args = nut.command.extractArgs(nut.gui.chat.text:GetText():sub(2))
        if args[2] == nil then return end
        local radius = tonumber(args[2])
        if !radius then return end

        render.SetColorMaterial()
        render.DrawSphere(LocalPlayer():GetPos(), -radius , 30, 30, Color(255, 150, 0, 100))
    end
end)

hook.Add("InitPostEntity", "LOCALEVENT_Registry", function()
    nut.command.add( "localevent", {
        adminOnly = true,
        syntax = "<int radius> <string message>",
        onRun = function( client, arguments )
            local targets = ents.FindInSphere(client:GetPos(), tonumber(arguments[1]))
            jlib.Announce(targets, Color(0, 234, 255), arguments[2])
        end
    } )

    nut.command.add( "localsound", {
        adminOnly = true,
        syntax = "<int radius> <string path>",
        onRun = function( client, arguments )
            local targets = ents.FindInSphere(client:GetPos(), tonumber(arguments[1]))

            jlib.SendSound(arguments[2], targets)
        end
    } )
end)