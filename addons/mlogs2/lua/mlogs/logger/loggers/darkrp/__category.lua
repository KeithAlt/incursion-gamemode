--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"DarkRP", -- Name
	"darkrp", 
	Color(240,52,52), -- Color
	function() -- Check
		return DarkRP != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("darkrp", {
	adverts = function(data) return mLogs.doLogReplace({"^player1",":","^msg"},data) end,
    agenda = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
        data.msg and "agenda_update" or "agenda_remove"   
    ),data) end,
	arrests = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.a and "arrest" or "unarrest"
	),data) end,
	batteringram = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.s and 
			(data.owner and (data.vehicle and "ram_success_vehicle" or "ram_success") or
				(data.vehicle and "ram_success_unowned_vehicle" or "ram_success_unowned")
			) or

			(data.owner and (data.vehicle and "ram_fail_vehicle" or "ram_fail") or
				(data.vehicle and "ram_fail_unowned_vehicle" or "ram_fail_unowned")
			)
	),data) end,
	cheques = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.d and "cheque_drop" or data.p and "cheque_pickup" or data.t and "cheque_tore"
	),data) end,
	demotes = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.afk and "demote_afk" or "demote"
	),data) end,
	doors = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.s and "door_sold" or "door_buy"
	),data) end,
	money = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.d and "money_drop" or data.p and (data.owner and "money_pickup" or "money_pickup_unowned")
	),data) end,
	hits = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.a and "hit_accept" or data.c and "hit_complete" or data.f and "hit_fail" or data.r and "hit_request"
	),data) end,
	jobs = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("job"),data) end,
	lockpick = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.t and
			(data.owner and (data.vehicle and "lockpick_started_vehicle" or "lockpick_started") or
				(data.vehicle and "lockpick_started_unowned_vehicle" or "lockpick_started_unowned")
			)
		or
		data.c and (
			(data.s and 
				(data.owner and (data.vehicle and "lockpick_success_vehicle" or "lockpick_success") or
					(data.vehicle and "lockpick_success_unowned_vehicle" or "lockpick_success_unowned")
				) or

				(data.owner and (data.vehicle and "lockpick_fail_vehicle" or "lockpick_fail") or
					(data.vehicle and "lockpick_fail_unowned_vehicle" or "lockpick_fail_unowned")
				)
			) 
		) or "lockpick_fail"
	),data) end,
	name = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("name"),data) end,
	pocket = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.d and "pocket_drop" or "pocket"
	),data) end,
	purchases = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.s and "purchase_shipment" or "purchase"
	),data) end,
	hunger = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("hunger"),data) end,
	wanted = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.w and "wanted" or "unwanted"
	),data) end,
	warrant = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.w and "warrant" or "unwarrant"
	),data) end,
	weaponcheck = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.s and "wep_check" or data.c and "wep_confiscate" or "wep_return"
	),data) end,
})