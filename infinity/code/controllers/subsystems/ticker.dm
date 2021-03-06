/datum/controller/subsystem/ticker
	var/server_update_client = null
	var/server_update = FALSE
	var/respawn_cooldown = 0

/datum/controller/subsystem/ticker/proc/UpdateServer()
	end_game_state = END_GAME_AWAITING_UPDATE
	to_world(SPAN_NOTICE(FONT_LARGE("<b><br>Сервер уходит на обновление!<br>Запуск через одну минуту (или меньше).<br></b>")))
	ForceUpdate()

/datum/controller/subsystem/ticker/proc/ForceUpdate()
	var/a = server_update_client ? " Инициировано [server_update_client]." : ""

	send2mainirc("Производится обновление сервера.")
	send2admindiscord("Происходит обновление.[a]")
	SSwebhooks.send(WEBHOOK_SERVER_UPDATE)

	game_log("SERVER", "Начато обновление сервера.")

	if(world.system_type == UNIX)
		return shell("sh update_start.sh")
	else if(world.system_type == MS_WINDOWS)
		return shell("update.bat")
	else
		end_game_state = END_GAME_ENDING
		log_admin("## ERROR: What? What system your host using? What [world.system_type] is? Message it to your devs, this feature is not supported for this OS.")
		CRASH("Error, trying to update server using unknown OS([world.system_type]).")

/datum/controller/subsystem/ticker/proc/update_map(New_Map)
	if(shell("update_map.bat") == 0)
		send2mainirc("Следующей картой будет - [New_Map]!")
		log_and_message_admins("Компилирование карты завершено. Следующей картой будет - [New_Map].")
	else
		scheduled_map_change = 1
		log_and_message_admins("Ошибка в компилировании карты! Возпроизведение резервного обновлениЯ в конце раунда! Доложить об ошибке разработчикам!")

	if(GAME_STATE == RUNLEVEL_POSTGAME)
		end_game_state = END_GAME_READY_TO_END
