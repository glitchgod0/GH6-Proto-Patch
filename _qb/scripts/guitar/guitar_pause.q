
script setup_pause \{pad_start_script = gh3_start_pressed}
	setscreenelementprops {
		id = root_window
		event_handlers = [{pad_start <pad_start_script>}]
		replace_handlers
	}
	launchevent \{type = focus
		target = root_window}
endscript

script disable_pause 
	if NOT gotparam \{nospam}
	endif
	kill_start_key_binding <...>
endscript

script enable_pause 
	restore_start_key_binding
endscript

script pausegh3 \{for_practice = 0}
	printf \{qs(0xa96cae1c)}
	printf \{qs(0xf385348a)}
	printf \{qs(0xa96cae1c)}
	broadcastevent \{type = event_pause_game}
	do_gh3_pause
	if NOT (camanimfinished name = cutscene)
		moviemembfunc \{name = cutscene
			func = cut_gel_pause}
	endif
	if ($practice_enabled)
		for_practice = 1
	endif
	if gotparam \{pause_ui_state}
		ui_event_wait event = menu_change data = {state = <pause_ui_state> <pause_ui_state_params>}
	elseif gotparam \{from_handler}
		ui_event_wait event = menu_change data = {state = uistate_pausemenu for_practice = <for_practice>}
	endif
endscript
pause_grace_period = -1.0

script get_total_rewind_time 
	<rewind_time> = ($rewind_time + $rewind_scrollback_time + $rewind_hold_time)
	return rewind_time = <rewind_time>
endscript
allowed_rewind_unpause = 0

script allow_rewind_pause 
	if (($g_in_tutorial = 1) || ($calibrate_lag_enabled = 1) || ($game_mode = freeplay) || ($transition_playing = true) || ($is_network_game))
		change \{allowed_rewind_unpause = 0}
		return \{false}
	else
		if NOT cd
			if globalexists \{name = disable_unpause_countdown}
				if ($disable_unpause_countdown = 1)
					change \{allowed_rewind_unpause = 0}
					return \{false}
				endif
			endif
		endif
		getglobaltags \{user_options
			param = unpause_count}
		if (<unpause_count> = 0)
			change \{allowed_rewind_unpause = 0}
			return \{false}
		endif
		playlist_getcurrentsong
		getsongtime
		songfilemanager func = get_song_end_time song_name = <current_song>
		if ((<songtime> < $rewind_time) || ((<songtime> * 1000) >= <total_end_time>))
			change \{allowed_rewind_unpause = 0}
			return \{false}
		endif
	endif
	change \{allowed_rewind_unpause = 1}
	return \{true}
endscript

script reseek_rewind 
	getsongtimems
	casttointeger \{time}
	if sap_seek time = <time> nowait callback = songaudio_seekdone
		change \{songaudio_waitingforseek = 1}
	else
		change \{songaudio_waitingforseek = 0}
	endif
endscript

script switch_rewind_active \{active = 1}
	if NOT gameispaused
		scriptassert \{qs(0xc662e9d6)}
	endif
	if ((<active> = 0) && ($allowed_rewind_unpause = 1))
		waitforaudioseek
		change \{pause_grace_period = -1.0}
		change \{allowed_rewind_unpause = 0}
		reseek_rewind
	else
		if ((<active> = 1) && ($allowed_rewind_unpause = 0))
			waitforaudioseek
			get_total_rewind_time
			change pause_grace_period = <rewind_time>
			change \{allowed_rewind_unpause = 1}
			incrementsongtimer delta_time = (-1.0 * $rewind_time)
			reseek_rewind
			incrementsongtimer delta_time = (1.0 * $rewind_time)
		endif
	endif
endscript

script do_gh3_pause 
	if ($is_network_game && $playing_song)
		return
	endif
	if allow_rewind_pause
		get_total_rewind_time
		change pause_grace_period = <rewind_time>
		incrementsongtimer delta_time = (-1.0 * $rewind_time)
		pauseaudio <...>
		incrementsongtimer delta_time = (1.0 * $rewind_time)
	else
		change \{pause_grace_period = -1.0}
		pauseaudio <...>
	endif
	pausefullscreenmovie
	pausegame
	if ismovieplaying \{textureslot = 0}
		pausemovie \{textureslot = 0}
	endif
	if ismovieplaying \{textureslot = 1}
		pausemovie \{textureslot = 1}
	endif
	freeplay_prepare_for_pause \{hide_hud = false}
endscript

script unpausegh3 
	printf \{qs(0xf6b8aa2b)}
	printf \{qs(0x293a99c4)}
	printf \{qs(0xf6b8aa2b)}
	wait \{1
		gameframe}
	if NOT (camanimfinished name = cutscene)
		moviemembfunc \{name = cutscene
			func = cut_gel_pause
			params = {
				off
			}}
	endif
	resumecontrollerchecking
	clear_paused_controllers
	change \{unknown_drum_type = 0}
	change \{toggleviewmode_enabled = true}
	change \{paused_for_hardware = 0}
	ui_event_get_top
	if (<base_name> = 'gameplay')
		do_gh3_unpause
		change \{pause_grace_period = -1.0}
		return
	endif
	if gotparam \{from_handler}
		if is_ui_event_running
			return
		endif
		if ui_event_exists_in_stack \{above = 'gameplay'
				name = 'song_unpause'}
			if NOT ui_event_exists_in_stack \{above = 'song_unpause'
					name = 'pausemenu'}
				ui_event \{event = menu_replace
					data = {
						state = uistate_pausemenu
					}}
				return
			endif
		endif
		gamemode_gettype
		if (<type> = tutorial)
			if ui_event_exists_in_stack \{name = 'gameplay'}
				ui_event \{event = menu_back
					data = {
						state = uistate_gameplay
					}}
			else
				generic_event_back \{data = {
						return_from_pause = 1
					}}
			endif
			do_gh3_unpause
			change \{pause_grace_period = -1.0}
		else
			get_savegame_from_controller controller = ($last_start_pressed_device)
			ui_event \{event = menu_replace
				data = {
					state = uistate_song_unpause
				}}
		endif
	else
		do_gh3_unpause
		change \{pause_grace_period = -1.0}
	endif
endscript

script do_gh3_unpause \{unpause_audio = 1}
	printscriptinfo \{'do_gh3_unpause'}
	if (<unpause_audio> = 1)
		unpauseaudio <...>
	endif
	unpausefullscreenmovie
	unpausegame
	if ismovieplaying \{textureslot = 0}
		resumemovie \{textureslot = 0}
	endif
	if ismovieplaying \{textureslot = 1}
		resumemovie \{textureslot = 1}
	endif
	freeplay_prepare_for_unpause
endscript
last_start_pressed_device = 0

script gh3_start_pressed \{device_num = -1}
	printscriptinfo \{qs(0x245e7cc1)}
	if ($pause_grace_period >= 0.0)
		if NOT gameispaused
			return
		endif
	endif
	if NOT cd
		if playerinfoequals \{1
				bot_play = 1}
			if (<device_num> = ($primary_controller))
				device_num = -1
			else
				if gotparam \{from_handler}
					if globalexists \{name = debug_pause_control}
						ui_event_wait_for_safe
						if gameispaused
							ui_event_block \{event = menu_back
								data = {
									state = uistate_gameplay
								}}
							do_gh3_unpause
							change \{pause_grace_period = -1.0}
						else
							ui_event_block \{event = menu_change
								data = {
									state = uistate_debug
								}}
							do_gh3_pause
						endif
						return
					endif
				endif
				device_num = -1
			endif
		endif
	endif
	if (<device_num> = -1)
		if playerinfoequals \{1
				bot_play = 1}
			start_pressed_device = ($primary_controller)
		else
			getfirstplayer
			getplayerinfo <player> controller
			start_pressed_device = <controller>
		endif
	else
		found_device = 0
		getnumplayersingame
		if (<num_players> > 0)
			getfirstplayer
			begin
			getplayerinfo <player> controller
			if (<device_num> = <controller>)
				<found_device> = 1
				start_pressed_device = <device_num>
				break
			endif
			getnextplayer player = <player>
			repeat <num_players>
		endif
		if (<found_device> = 0)
			if NOT cd
				if gotparam \{from_handler}
					if globalexists \{name = debug_pause_control}
						ui_event_wait_for_safe
						if gameispaused
							ui_event_block \{event = menu_back
								data = {
									state = uistate_gameplay
								}}
							do_gh3_unpause
							change \{pause_grace_period = -1.0}
						else
							ui_event_block \{event = menu_change
								data = {
									state = uistate_debug
								}}
							do_gh3_pause
						endif
					endif
				endif
			endif
			return
		endif
	endif
	if gameispaused
		if NOT (<device_num> = -1)
			if NOT (<start_pressed_device> = $last_start_pressed_device)
				return
			endif
			setinput controller = <device_num> pattern = 0 strum = 0
		endif
	else
		change last_start_pressed_device = <start_pressed_device>
	endif
	printstruct <...>
	spawnscriptnow gh3_start_pressed_spawned params = {<...>}
endscript

script gh3_start_pressed_spawned 
	printf \{qs(0x2c46a642)}
	if NOT ($view_mode = 0)
		if gameispaused
			unpauseaudio <...>
			unpausegame
		else
			pauseaudio <...>
			pausegame
			unpausespawnedscript \{update_crowd_model_cam}
		endif
		return
	endif
	if gameispaused
		unpausegh3 <...>
		broadcastevent \{type = event_unpause_game}
	else
		if ($net_pause = 1)
			net_unpausegh
			return
		elseif ($is_network_game && $playing_song)
			net_pausegh
			return
		endif
		pausegh3 <...>
		spawnscriptnow \{block_input}
	endif
endscript

script block_input 
	if NOT sys_fade_showing
		setbuttoneventmappings \{block_menu_input}
		wait \{0.25
			seconds}
		setbuttoneventmappings \{unblock_menu_input}
	endif
endscript

script create_generic_backdrop 
	if NOT screenelementexists \{id = generic_backdrop_container}
		createscreenelement \{type = containerelement
			parent = root_window
			id = generic_backdrop_container
			pos = (0.0, 0.0)
			just = [
				left
				top
			]}
		createscreenelement \{type = spriteelement
			id = pause_backdrop
			parent = generic_backdrop_container
			texture = menu_venue_bg
			rgba = [
				255
				255
				255
				255
			]
			pos = (640.0, 360.0)
			dims = (1280.0, 720.0)
			just = [
				center
				center
			]
			z_priority = 0
			alpha = 1}
	endif
endscript

script destroy_generic_backdrop 
	if screenelementexists \{id = generic_backdrop_container}
		destroyscreenelement \{id = generic_backdrop_container}
	endif
endscript

script handle_pause_event 
	if is_ui_event_running
		return
	endif
	gamemode_gettype
	if NOT (<type> = freeplay && $in_sing_a_long = false)
		if ($transition_playing = true)
			if NOT is_pausable_transition \{transition = $current_playing_transition}
				return
			endif
		endif
	endif
	if ($in_sing_a_long = true && $view_mode != 1)
		return
	endif
	printf \{qs(0xf173f764)}
	if gameispaused
		printf \{'KeepControllersAlive - unpause'}
		keepingamecontrollersalive
	endif
	if NOT scriptisrunning \{gh3_start_pressed}
		if NOT scriptisrunning \{gh3_start_pressed_spawned}
			spawnscriptnow gh3_start_pressed params = {<...> from_handler}
		endif
	endif
endscript

script is_pausable_transition 
	switch <transition>
		case songwon
		case songwonfreeplay
		case songdoneattract
		case songoutro
		case songlost
		return \{false}
		case intro
		case fastintro
		case fastintrotutorial
		case practice
		case preencore
		case encore
		case restartencore
		case loading
		case onlineloading
		case loadingintro
		case finalbandintro
		case finalbandoutro
		case celebintro
		default
		return \{true}
	endswitch
endscript
