
script ui_create_finish_song_loading 
	spawnscriptnow finish_song_loading_spawned params = {<...>}
endscript

script ui_destroy_finish_song_loading 
endscript

script finish_song_loading_spawned \{loading_transition = 1
		from_memcard = 0
		is_jam = 0}
	starttime = ($current_starttime)
	if (<is_jam> = 1)
		finish_jam_song_setup loading_transition = <loading_transition>
		if gotparam \{end_time}
			change sb_jam_song_end_time = <end_time>
		endif
		if (<loading_transition> = 0)
			jam_song_back_to_gameplay
		endif
		starttime = 0
		create_cameracuts \{in_game = 1}
	else
		if (<loading_transition> = 0)
			quickplay_start_song starttime = <starttime> uselaststarttime = 0
			if ($is_network_game = 0)
				ui_event_wait \{event = menu_replace
					data = {
						state = uistate_gameplay
					}}
			endif
		endif
	endif
	if (<loading_transition> = 1)
		finish_song_loading_and_transition_to_song_breakdown starttime = <starttime>
	endif
endscript

script finish_jam_song_setup 
	if (<loading_transition> = 0)
		($default_loading_screen.create)
	endif
	getsonginfo
	change jam_current_bpm = <bpm>
	change jam_current_tuning = <tuning>
	change \{jam_current_instrument_effects = [
			0
			0
			0
			0
			0
		]}
	change \{jam_current_active_effects = [
			0
			0
			0
			0
			0
		]}
	jam_load_effect
	jam_recording_create_jamsession_arrays
	song_prefix = 'editable'
	formattext checksumname = arraylist '%s_arraylist' s = <song_prefix> addtostringlookup = true
	song_prefix = 'jamsession'
	formattext checksumname = arraylist2 '%s_arraylist' s = <song_prefix> addtostringlookup = true
	jamsession_copymarkerarrays \{song = editable}
	jamsession_copyfinalscriptarrays arraylist = <arraylist> arraylist2 = <arraylist2>
	getplayerinfo \{1
		part}
	getnumplayersingame
	<players> = <num_players>
	end_time = 0
	musicstudio_setup_custom_song
	getsonginfo
	change_jamsession_songlist_props_struct title = ($jam_selected_song_name) artist = <artist>
	spawnscriptnow start_song params = {
		song_name = jamsession
		endtime = <end_time>
		do_not_restart_gem_scroller = <loading_transition>
	}
	return end_time = <end_time>
endscript

script jam_song_back_to_gameplay 
	if ($notetracker_quickplay_active = 0)
		event = menu_replace
		if ui_event_exists_in_stack \{name = 'gameplay'}
			printf \{channel = bkutcher
				qs(0xcd6ba95e)}
			event = menu_back
		endif
		ui_event_wait event = <event> data = {state = uistate_gameplay}
	endif
	change \{songtime_paused = 0}
endscript

script finish_song_loading_and_transition_to_song_breakdown 
	requireparams \{[
			starttime
		]
		all}
	<state> = uistate_song_breakdown <data> = {continue_setlist_transition starttime = <starttime>}
	gamemode_gettype
	if ($is_network_game = 1 && ((<type> = career) || (<type> = quickplay)))
		if (<type> = career)
			getglobaltags savegame = <savegame> career_progression_tags param = encore_ready
			if (<encore_ready> = 1)
				if is_encore_song
					<state> = uistate_quest_transformation_info <data> = {starttime = <starttime>}
				endif
			endif
		endif
	elseif ($is_network_game = 0)
		if ((<type> = pro_faceoff) || (<type> = competitive))
			<state> = uistate_song_breakdown_competitive <data> = {continue_setlist_transition starttime = <starttime>}
		else
			if (<type> = freeplay)
				return
			else
				if (<type> = career)
					if is_encore_song
						getglobaltags savegame = ($primary_controller) career_progression_tags param = encore_ready
						if (<encore_ready> = 1)
							<state> = uistate_quest_transformation_info <data> = {starttime = <starttime>}
						endif
					endif
				endif
			endif
		endif
	else
		<state> = uistate_song_breakdown_competitive data = {continue_setlist_transition starttime = <starttime>}
	endif
	ui_event_wait event = menu_replace data = {state = <state> <data>}
endscript
