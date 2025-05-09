max_song_stars = 5
career_info = {
	name = 'career'
	goal_type = game_mode
	data = {
		results_text = qs(0x00000000)
	}
	constants = {
	}
	checkpoints = [
		{
			name = 'main'
			tools = [
				{
					name = 'venue_handler'
					type = venue
				}
				{
					name = 'pause'
					type = pause
					dont_start_on_enter
					settings = {
						default_options = {
							resume
							restart
							options
							difficulty
							gig_info
							quit
						}
						custom_options = [
							{
								text = qs(0x64e825e2)
								func = ui_event
								func_params = {
									event = menu_change
									data = {
										state = uistate_pausemenu_quit_warning
										option2_func_params = {
											newgig
										}
									}
								}
								local_only = 1
							}
						]
					}
				}
			]
		}
	]
}

script career_main_enter 
	printf \{'Career::Main_Enter'}
	change \{end_credits = 0}
endscript

script career_begin_main_gameplay 
endscript

script 0xe1d4c4ff 
endscript

script career_song_started 
	printf \{'Career::Song_Started'
		channel = career_challenge}
	change \{autolaunch_startnow = 0}
	get_savegame_from_controller controller = ($primary_controller)
	getglobaltags savegame = <savegame> career_progression_tags param = current_chapter
	quest_progression_set_chapter_tags savegame = <savegame> chapter_global = <current_chapter> params = {has_been_played = 1}
	spawnscriptnow \{guitarevent_gigstarted}
endscript

script career_song_complete 
	printf 'Career::Song_Complete event = %a' a = <event> channel = career_challenge
	if (<event> = song_won)
		gameevent_songwon
		gameevent_gigwon
	elseif (<event> = song_retry)
		gameevent_songretry
		gameevent_gigretry
	elseif (<event> = song_failed)
		gameevent_songfailed
		gameevent_gigfailed
	elseif (<event> = song_quit)
		gameevent_songaborted
		gameevent_gigaborted
	endif
endscript

script career_continue_next_song 
	printf \{'Career::Continue_Next_Song'
		channel = career_challenge}
	playlist_switchtonextsong
	change \{gameplay_restart_song = 1}
	generic_event_back \{nosound
		state = uistate_gameplay}
endscript

script career_complete_challenge 
	if NOT gman_goalisactive \{goal = career}
		return
	endif
	playlist_clear
	progression_clear_rewards_just_unlocked
	update_active_players_atoms
endscript

script career_pause_quit 
	audio_gameplay_crowd_stop_all_paused_sounds
	career_end_challenge
	killspawnedscript \{name = scrolling_list_begin_credits}
	destroy_credits_menu
	quest_progression_reset_career_progression_tags
	if gotparam \{newgig}
		generic_event_back \{nosound
			state = uistate_quest_map}
	else
		generic_event_back \{nosound
			state = uistate_mainmenu}
	endif
endscript

script career_end_challenge 
	gman_sendcallbacktoallgoals \{suffix = 'song_complete'
		callback_data = {
			event = song_quit
		}}
	career_complete_challenge
endscript

script get_goal_results_data 
	gman_getdata goal = <goal> name = <results_screen_goal_data>
	if NOT gotparam \{results_screen_goal_data}
		scriptassert qs(0x8b1b399f) a = <goal>
		return
	endif
	column_title = (<results_screen_goal_data>.column_title)
	goal_var_source = (<results_screen_goal_data>.data_source)
	goal_var_name = (<results_screen_goal_data>.var_name)
	is_band_data = 0
	column_data = []
	if (<goal_var_source> = player_goal_data)
		getnumplayersingame
		if (<num_players> > 0)
			getfirstplayer
			begin
			gman_getdata goal = <goal> player = <player> name = <goal_var_name> return_name = recieved_data
			if NOT gotparam \{recieved_data}
				scriptassert qs(0xaa773e13) v = <goal_var_name> s = <goal_var_source>
				return
			endif
			<column_data> = (<column_data> + (<recieved_data>))
			getnextplayer player = <player>
			repeat <num_players>
		endif
	elseif (<goal_var_source> = player_info_data)
		getnumplayersingame
		if (<num_players> > 0)
			getfirstplayer
			begin
			getplayerinfo <player> (<goal_var_name>) out = recieved_data
			<column_data> = (<column_data> + (<recieved_data>))
			getnextplayer player = <player>
			repeat <num_players>
		endif
	elseif (<goal_var_source> = player_goal_data_array)
		gman_getdata goal = <goal> name = <goal_var_name> return_name = column_data
	elseif (<goal_var_source> = band_info_data)
		is_band_data = 1
		getbandsstatus
		getarraysize <bands>
		i = 0
		begin
		if (<bands> [<i>].in_game)
			getbandinfo (<i> + 1) score out = recieved_data
			<column_data> = (<column_data> + (<recieved_data>))
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	endif
	return goal_results_column_title = <column_title> goal_results_column_data = <column_data> is_band_data = <is_band_data>
endscript

script career_get_progress_for_venue 
	requireparams \{[
			venue_list
			index
		]
		all}
endscript

script career_win_challenge \{grade = 4}
endscript
