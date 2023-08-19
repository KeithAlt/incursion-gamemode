--This is a untility to convert lists of sounds into tables usable by the vox system.
--TODO run the output through a spellcheck library and see if we can get it to seperate the words.
AddCSLuaFile()
local input_raw = [[

vo/npc/female01/abouttime01.wav
vo/npc/female01/abouttime02.wav
vo/npc/female01/ahgordon01.wav
vo/npc/female01/ahgordon02.wav
vo/npc/female01/ammo01.wav
vo/npc/female01/ammo02.wav
vo/npc/female01/ammo03.wav
vo/npc/female01/ammo04.wav
vo/npc/female01/ammo05.wav
vo/npc/female01/answer01.wav
vo/npc/female01/answer02.wav
vo/npc/female01/answer03.wav
vo/npc/female01/answer04.wav
vo/npc/female01/answer05.wav
vo/npc/female01/answer07.wav
vo/npc/female01/answer08.wav
vo/npc/female01/answer09.wav
vo/npc/female01/answer10.wav
vo/npc/female01/answer11.wav
vo/npc/female01/answer12.wav
vo/npc/female01/answer13.wav
vo/npc/female01/answer14.wav
vo/npc/female01/answer15.wav
vo/npc/female01/answer16.wav
vo/npc/female01/answer17.wav
vo/npc/female01/answer18.wav
vo/npc/female01/answer19.wav
vo/npc/female01/answer20.wav
vo/npc/female01/answer21.wav
vo/npc/female01/answer22.wav
vo/npc/female01/answer23.wav
vo/npc/female01/answer24.wav
vo/npc/female01/answer25.wav
vo/npc/female01/answer26.wav
vo/npc/female01/answer27.wav
vo/npc/female01/answer28.wav
vo/npc/female01/answer29.wav
vo/npc/female01/answer30.wav
vo/npc/female01/answer31.wav
vo/npc/female01/answer32.wav
vo/npc/female01/answer33.wav
vo/npc/female01/answer34.wav
vo/npc/female01/answer35.wav
vo/npc/female01/answer36.wav
vo/npc/female01/answer37.wav
vo/npc/female01/answer38.wav
vo/npc/female01/answer39.wav
vo/npc/female01/answer40.wav
vo/npc/female01/behindyou01.wav
vo/npc/female01/behindyou02.wav
vo/npc/female01/busy02.wav
vo/npc/female01/cit_dropper01.wav
vo/npc/female01/cit_dropper04.wav
vo/npc/female01/civilprotection01.wav
vo/npc/female01/civilprotection02.wav
vo/npc/female01/combine01.wav
vo/npc/female01/combine02.wav
vo/npc/female01/coverwhilereload01.wav
vo/npc/female01/coverwhilereload02.wav
vo/npc/female01/cps01.wav
vo/npc/female01/cps02.wav
vo/npc/female01/docfreeman01.wav
vo/npc/female01/docfreeman02.wav
vo/npc/female01/doingsomething.wav
vo/npc/female01/dontforgetreload01.wav
vo/npc/female01/excuseme01.wav
vo/npc/female01/excuseme02.wav
vo/npc/female01/fantastic01.wav
vo/npc/female01/fantastic02.wav
vo/npc/female01/finally.wav
vo/npc/female01/freeman.wav
vo/npc/female01/getdown02.wav
vo/npc/female01/getgoingsoon.wav
vo/npc/female01/gethellout.wav
vo/npc/female01/goodgod.wav
vo/npc/female01/gordead_ans01.wav
vo/npc/female01/gordead_ans02.wav
vo/npc/female01/gordead_ans03.wav
vo/npc/female01/gordead_ans04.wav
vo/npc/female01/gordead_ans05.wav
vo/npc/female01/gordead_ans06.wav
vo/npc/female01/gordead_ans07.wav
vo/npc/female01/gordead_ans08.wav
vo/npc/female01/gordead_ans09.wav
vo/npc/female01/gordead_ans10.wav
vo/npc/female01/gordead_ans11.wav
vo/npc/female01/gordead_ans12.wav
vo/npc/female01/gordead_ans13.wav
vo/npc/female01/gordead_ans14.wav
vo/npc/female01/gordead_ans15.wav
vo/npc/female01/gordead_ans16.wav
vo/npc/female01/gordead_ans17.wav
vo/npc/female01/gordead_ans18.wav
vo/npc/female01/gordead_ans19.wav
vo/npc/female01/gordead_ans20.wav
vo/npc/female01/gordead_ques01.wav
vo/npc/female01/gordead_ques02.wav
vo/npc/female01/gordead_ques04.wav
vo/npc/female01/gordead_ques05.wav
vo/npc/female01/gordead_ques06.wav
vo/npc/female01/gordead_ques07.wav
vo/npc/female01/gordead_ques08.wav
vo/npc/female01/gordead_ques10.wav
vo/npc/female01/gordead_ques11.wav
vo/npc/female01/gordead_ques12.wav
vo/npc/female01/gordead_ques13.wav
vo/npc/female01/gordead_ques14.wav
vo/npc/female01/gordead_ques15.wav
vo/npc/female01/gordead_ques16.wav
vo/npc/female01/gordead_ques17.wav
vo/npc/female01/gotone01.wav
vo/npc/female01/gotone02.wav
vo/npc/female01/gottareload01.wav
vo/npc/female01/gunship02.wav
vo/npc/female01/hacks01.wav
vo/npc/female01/hacks02.wav
vo/npc/female01/headcrabs01.wav
vo/npc/female01/headcrabs02.wav
vo/npc/female01/headsup01.wav
vo/npc/female01/headsup02.wav
vo/npc/female01/health01.wav
vo/npc/female01/health02.wav
vo/npc/female01/health03.wav
vo/npc/female01/health04.wav
vo/npc/female01/health05.wav
vo/npc/female01/hellodrfm01.wav
vo/npc/female01/hellodrfm02.wav
vo/npc/female01/help01.wav
vo/npc/female01/herecomehacks01.wav
vo/npc/female01/herecomehacks02.wav
vo/npc/female01/heretheycome01.wav
vo/npc/female01/heretohelp01.wav
vo/npc/female01/heretohelp02.wav
vo/npc/female01/heydoc01.wav
vo/npc/female01/heydoc02.wav
vo/npc/female01/hi01.wav
vo/npc/female01/hi02.wav
vo/npc/female01/hitingut01.wav
vo/npc/female01/hitingut02.wav
vo/npc/female01/holddownspot01.wav
vo/npc/female01/holddownspot02.wav
vo/npc/female01/illstayhere01.wav
vo/npc/female01/imhurt01.wav
vo/npc/female01/imhurt02.wav
vo/npc/female01/imstickinghere01.wav
vo/npc/female01/incoming02.wav
vo/npc/female01/itsamanhack01.wav
vo/npc/female01/itsamanhack02.wav
vo/npc/female01/leadon01.wav
vo/npc/female01/leadon02.wav
vo/npc/female01/leadtheway01.wav
vo/npc/female01/leadtheway02.wav
vo/npc/female01/letsgo01.wav
vo/npc/female01/letsgo02.wav
vo/npc/female01/likethat.wav
vo/npc/female01/littlecorner01.wav
vo/npc/female01/lookoutfm01.wav
vo/npc/female01/lookoutfm02.wav
vo/npc/female01/moan01.wav
vo/npc/female01/moan02.wav
vo/npc/female01/moan03.wav
vo/npc/female01/moan04.wav
vo/npc/female01/moan05.wav
vo/npc/female01/myarm01.wav
vo/npc/female01/myarm02.wav
vo/npc/female01/mygut02.wav
vo/npc/female01/myleg01.wav
vo/npc/female01/myleg02.wav
vo/npc/female01/nice01.wav
vo/npc/female01/nice02.wav
vo/npc/female01/no01.wav
vo/npc/female01/no02.wav
vo/npc/female01/notthemanithought01.wav
vo/npc/female01/notthemanithought02.wav
vo/npc/female01/ohno.wav
vo/npc/female01/ok01.wav
vo/npc/female01/ok02.wav
vo/npc/female01/okimready01.wav
vo/npc/female01/okimready02.wav
vo/npc/female01/okimready03.wav
vo/npc/female01/onyourside.wav
vo/npc/female01/outofyourway02.wav
vo/npc/female01/overhere01.wav
vo/npc/female01/overthere01.wav
vo/npc/female01/overthere02.wav
vo/npc/female01/ow01.wav
vo/npc/female01/ow02.wav
vo/npc/female01/pain01.wav
vo/npc/female01/pain02.wav
vo/npc/female01/pain03.wav
vo/npc/female01/pain04.wav
vo/npc/female01/pain05.wav
vo/npc/female01/pain06.wav
vo/npc/female01/pain07.wav
vo/npc/female01/pain08.wav
vo/npc/female01/pain09.wav
vo/npc/female01/pardonme01.wav
vo/npc/female01/pardonme02.wav
vo/npc/female01/question01.wav
vo/npc/female01/question02.wav
vo/npc/female01/question03.wav
vo/npc/female01/question04.wav
vo/npc/female01/question05.wav
vo/npc/female01/question06.wav
vo/npc/female01/question07.wav
vo/npc/female01/question08.wav
vo/npc/female01/question09.wav
vo/npc/female01/question10.wav
vo/npc/female01/question11.wav
vo/npc/female01/question12.wav
vo/npc/female01/question13.wav
vo/npc/female01/question14.wav
vo/npc/female01/question15.wav
vo/npc/female01/question16.wav
vo/npc/female01/question17.wav
vo/npc/female01/question18.wav
vo/npc/female01/question19.wav
vo/npc/female01/question20.wav
vo/npc/female01/question21.wav
vo/npc/female01/question22.wav
vo/npc/female01/question23.wav
vo/npc/female01/question25.wav
vo/npc/female01/question26.wav
vo/npc/female01/question27.wav
vo/npc/female01/question28.wav
vo/npc/female01/question29.wav
vo/npc/female01/question30.wav
vo/npc/female01/question31.wav
vo/npc/female01/readywhenyouare01.wav
vo/npc/female01/readywhenyouare02.wav
vo/npc/female01/reloadfm01.wav
vo/npc/female01/reloadfm02.wav
vo/npc/female01/runforyourlife01.wav
vo/npc/female01/runforyourlife02.wav
vo/npc/female01/scanners01.wav
vo/npc/female01/scanners02.wav
vo/npc/female01/sorry01.wav
vo/npc/female01/sorry02.wav
vo/npc/female01/sorry03.wav
vo/npc/female01/sorrydoc01.wav
vo/npc/female01/sorrydoc02.wav
vo/npc/female01/sorrydoc04.wav
vo/npc/female01/sorryfm01.wav
vo/npc/female01/sorryfm02.wav
vo/npc/female01/squad_affirm01.wav
vo/npc/female01/squad_affirm02.wav
vo/npc/female01/squad_affirm03.wav
vo/npc/female01/squad_affirm04.wav
vo/npc/female01/squad_affirm05.wav
vo/npc/female01/squad_affirm06.wav
vo/npc/female01/squad_affirm07.wav
vo/npc/female01/squad_affirm08.wav
vo/npc/female01/squad_affirm09.wav
vo/npc/female01/squad_approach01.wav
vo/npc/female01/squad_approach02.wav
vo/npc/female01/squad_approach03.wav
vo/npc/female01/squad_approach04.wav
vo/npc/female01/squad_away01.wav
vo/npc/female01/squad_away02.wav
vo/npc/female01/squad_away03.wav
vo/npc/female01/squad_follow01.wav
vo/npc/female01/squad_follow02.wav
vo/npc/female01/squad_follow03.wav
vo/npc/female01/squad_follow04.wav
vo/npc/female01/squad_greet01.wav
vo/npc/female01/squad_greet02.wav
vo/npc/female01/squad_greet04.wav
vo/npc/female01/squad_reinforce_group01.wav
vo/npc/female01/squad_reinforce_group02.wav
vo/npc/female01/squad_reinforce_group03.wav
vo/npc/female01/squad_reinforce_group04.wav
vo/npc/female01/squad_reinforce_single01.wav
vo/npc/female01/squad_reinforce_single02.wav
vo/npc/female01/squad_reinforce_single03.wav
vo/npc/female01/squad_reinforce_single04.wav
vo/npc/female01/squad_train01.wav
vo/npc/female01/squad_train02.wav
vo/npc/female01/squad_train03.wav
vo/npc/female01/squad_train04.wav
vo/npc/female01/startle01.wav
vo/npc/female01/startle02.wav
vo/npc/female01/stopitfm.wav
vo/npc/female01/strider.wav
vo/npc/female01/strider_run.wav
vo/npc/female01/takecover02.wav
vo/npc/female01/thehacks01.wav
vo/npc/female01/thehacks02.wav
vo/npc/female01/thislldonicely01.wav
vo/npc/female01/uhoh.wav
vo/npc/female01/upthere01.wav
vo/npc/female01/upthere02.wav
vo/npc/female01/vanswer01.wav
vo/npc/female01/vanswer02.wav
vo/npc/female01/vanswer03.wav
vo/npc/female01/vanswer04.wav
vo/npc/female01/vanswer05.wav
vo/npc/female01/vanswer06.wav
vo/npc/female01/vanswer07.wav
vo/npc/female01/vanswer08.wav
vo/npc/female01/vanswer09.wav
vo/npc/female01/vanswer10.wav
vo/npc/female01/vanswer11.wav
vo/npc/female01/vanswer12.wav
vo/npc/female01/vanswer13.wav
vo/npc/female01/vanswer14.wav
vo/npc/female01/vquestion01.wav
vo/npc/female01/vquestion02.wav
vo/npc/female01/vquestion03.wav
vo/npc/female01/vquestion04.wav
vo/npc/female01/vquestion05.wav
vo/npc/female01/vquestion06.wav
vo/npc/female01/vquestion07.wav
vo/npc/female01/waitingsomebody.wav
vo/npc/female01/watchout.wav
vo/npc/female01/watchwhat.wav
vo/npc/female01/wetrustedyou01.wav
vo/npc/female01/wetrustedyou02.wav
vo/npc/female01/whoops01.wav
vo/npc/female01/yeah02.wav
vo/npc/female01/youdbetterreload01.wav
vo/npc/female01/yougotit02.wav
vo/npc/female01/zombies01.wav
vo/npc/female01/zombies02.wav



]]

if CLIENT then
    concommand.Add("pk_dev_voxgen", function(ply, cmd, args)
        local n = args[1]
        local output = {'local ' .. n .. '={}'}

        for _, v in pairs(("\n"):Explode(input_raw)) do
            if v:len() == 0 then continue end
            local r = string.match(v, "/([^/]*)%.")
            output[r] = v
            table.insert(output, n .. '[  "' .. r .. '"  ]="' .. v .. '"')
        end

        SetClipboardText(("\n"):Implode(output))
    end)
end
