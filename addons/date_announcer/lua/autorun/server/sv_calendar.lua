-- Announce date/time
function announceCalendar()
	local date_table = os.date("*t")
	local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
	local hour, minute, second = date_table.hour, date_table.min, date_table.sec
	local year, month, day = (date_table.year + 252), date_table.month, date_table.day
	local result = string.format("%d-%d-%d", month, day, year)

	DiscordEmbed("The current date is: **" .. result .. "**" ,"📅  Calendar Report  📅", Color(0,255,0), "IncursionChat")
	jlib.Announce(player.GetAll(), Color(0,255,0), "[CALENDAR] ", Color(155,255,155), "The current wasteland date is ", Color(0,255,0), result)
end

-- Initalize our timer
hook.Add("InitPostEntity", "CalendarAnnounce", function()
	timer.Create("CalendarAnnouncement", 7200, 0, announceCalendar)
	MsgC(Color(0,255,0), "[CALENDAR ANNOUNCER] ", Color(255,155,155), "Initalized calendar announcement")
end)
