
script ui_create_song_unpause 
	hide_glitch \{num_frames = 4}
	createscreenelement \{parent = root_window
		id = song_unpause
		type = descinterface
		desc = 'song_unpause'
		z_priority = 10000
		alpha = 0.0}
	song_unpause :obj_spawnscript \{ui_song_unpause}
	launchevent \{type = focus
		target = song_unpause}
endscript

script ui_destroy_song_unpause 
	destroyscreenelement \{id = song_unpause}
	spawnscriptnow \{ui_destroy_song_spawned}
endscript

script ui_destroy_song_spawned 
	ui_event_wait_for_safe
	gamemode_gettype
	if NOT (<type> = freeplay)
		if NOT ui_event_exists_in_stack \{above = 'gameplay'
				name = 'song_breakdown'}
			enable_pause
		endif
	endif
	if ($calibrate_lag_enabled = 1)
		setup_pause \{pad_start_script = calibrate_hit_pause}
	endif
endscript

script ui_song_unpause 
	setscriptcannotpause
	ui_event_wait_for_safe
	if ($allowed_rewind_unpause = 0)
		ui_song_unpause_done
		change \{pause_grace_period = -1.0}
		return
	endif
	ui_song_unpause_done \{unpause_audio = 0}
	spawnscriptnow \{wait_and_set_songtime}
	<rew_time> = 0.0
	<play_time> = 0.0
	soundevent \{event = ui_sfx_rewind_highway}
	getsongtime
	<rewind_target_songtime> = (<songtime> - $rewind_time)
	killdeadgems
	<elapsed_time> = 0.0
	<audio_unpaused> = 0
	begin
	wait \{1
		gameframe}
	getdeltatime \{ignore_slomo}
	<elapsed_time> = (<elapsed_time> + <delta_time>)
	<rewind_wait_time> = ($rewind_scrollback_time + $rewind_hold_time)
	<elapsed_time_delta> = (<elapsed_time> - <rewind_wait_time>)
	if (<elapsed_time_delta> > 0.008)
		if (<audio_unpaused> = 0)
			unpauseaudio <...>
			<audio_unpaused> = 1
		endif
		if ($pause_grace_period < 0.0)
			break
		endif
		<play_time> = (<play_time> + <delta_time>)
	else
		<rewind_speed> = (1.0 + ($rewind_time / $rewind_scrollback_time))
		incrementsongtimer delta_time = ((0.0 - <rewind_speed>) * <delta_time>)
		<rew_time> = (<rew_time> + <delta_time>)
		getsongtime
		if (<songtime> < <rewind_target_songtime>)
			setsongtime songtime = <rewind_target_songtime>
		endif
	endif
	change pause_grace_period = ($pause_grace_period - <delta_time>)
	repeat
	finalprintf qs(0x5c38fb65) a = <rew_time> b = <play_time> c = (<rew_time> + <play_time>)
endscript

script wait_and_set_songtime 
	pausecompositeobjects
	if getskatercamanimparams \{name = cameracutcam}
		if gotparam \{cam_object_id}
			<cam_object_id> :ccam_pause
		endif
	endif
	getsongtime
	<original_songtime> = <songtime>
	<wait_time> = $pause_grace_period
	<elapsed_time> = 0.0
	begin
	wait \{1
		gameframe}
	getdeltatime \{ignore_slomo}
	<elapsed_time> = (<elapsed_time> + <delta_time>)
	<elapsed_time_delta> = (<elapsed_time> - <wait_time>)
	if (<elapsed_time_delta> > -0.008)
		break
	endif
	repeat
	change \{pause_grace_period = -1.0}
	unpausecompositeobjects
	if getskatercamanimparams \{name = cameracutcam}
		if gotparam \{cam_object_id}
			<cam_object_id> :ccam_unpause
		endif
	endif
endscript

script fireoff_countdown_by_user_lag 
	wait_time = (<video_offset> - <audio_offset>)
	if (<wait_time> < 0)
		wait_time = 0
	endif
	wait (<wait_time> / 1000.0) seconds
	formattext textname = number_text qs(0xc31d83ea) i = <i>
	se_setprops number_text = <number_text>
endscript

script ui_song_unpause_done \{unpause_audio = 1}
	setscriptcannotpause
	ui_event_wait_for_safe
	do_gh3_unpause unpause_audio = <unpause_audio>
	ui_event \{event = menu_back
		data = {
			state = uistate_gameplay
			repausing = false
		}}
	if isobjectscript
		die
	endif
endscript

script ui_song_unpause_repause 
	setscriptcannotpause
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	killspawnedscript \{name = ui_song_unpause}
	ui_event_wait_for_safe
	if gotparam \{from_system}
		if ui_event_exists_in_stack \{name = 'gameplay'}
			ui_event \{event = menu_back
				data = {
					state = uistate_gameplay
					repausing = true
				}}
		else
			ui_event \{event = menu_back}
		endif
	else
		printf \{qs(0x20ab9428)
			channel = here}
		ui_sfx \{menustate = generic
			uitype = select}
		ui_event event = menu_replace state = uistate_pausemenu data = {device_num = <device_num>}
	endif
endscript
