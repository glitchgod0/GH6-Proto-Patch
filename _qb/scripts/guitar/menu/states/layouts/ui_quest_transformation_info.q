
script ui_init_quest_transformation_info 
	change \{song_breakdown_gem_scroller_restarted = 0}
	change \{song_breakdown_countdown_time_added = 0}
	change \{ui_song_breakdown_already_animated_stats = 0}
	change \{respond_to_signin_changed_func = ui_signin_changed_func}
	change \{song_breakdown_countdown_time = -1}
	change \{sb_jam_song_end_time = 0}
	change \{net_breakdown_continue_msg_sent = 0}
	change \{songtime_paused = 1}
	change \{playing_song = 0}
	disable_pause
endscript

script ui_create_quest_transformation_info \{starttime = !i1768515945}
	createscreenelement \{type = descinterface
		desc = 'career_transformation_info'
		parent = root_window
		id = questtransformationinfo
		event_handlers = [
			{
				pad_choose
				ui_quest_transformation_continue
			}
		]}
	quest_progression_transform_character
	begin
	if scriptisrunning \{persistent_band_prepare_for_song}
		blockforscript \{persistent_band_prepare_for_song}
		break
	endif
	wait \{1
		gameframe}
	repeat
	spawnscriptlater restart_gem_scroller params = {starttime = <starttime> practice_intro = 0 loading_transition = 1 no_render = 0}
endscript

script ui_quest_transformation_add_handlers 
	if NOT screenelementexists \{id = questtransformationinfo}
		return
	endif
	if screenelementexists \{id = song_breakdown_noncompetitive_id}
		launchevent \{type = unfocus
			target = song_breakdown_noncompetitive_id}
	endif
	assignalias \{id = questtransformationinfo
		alias = current_menu}
	launchevent \{type = focus
		target = current_menu}
	add_user_control_helper \{controller = $primary_controller
		text = qs(0x494b4d7f)
		button = green
		z = 100000}
endscript

script ui_destroy_quest_transformation_info 
	if screenelementexists \{id = questtransformationinfo}
		destroyscreenelement \{id = questtransformationinfo}
	endif
	clean_up_user_control_helpers
endscript

script ui_deinit_quest_transformation_info 
endscript

script ui_quest_transformation_continue 
	change \{songtime_paused = 0}
	generic_event_back \{nosound
		state = uistate_gameplay}
	ui_destroy_quest_transformation_info
endscript
