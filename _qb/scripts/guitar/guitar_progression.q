
script reset_progression_atoms \{savegame = !i1768515945
		force_update = 1
		async = 0}
	conditional_async_wait async = <async> text = qs(0x8c29435c)
	lockglobaltags \{push_progression_writes_only}
	conditional_async_wait async = <async> text = qs(0xa704109f)
	completed_atoms_array = []
	create_quickplay_rewards_atoms_array {savegame = <savegame> , completed_atoms_array = <completed_atoms_array> , async = <async>}
	create_player_progression_atoms {savegame = <savegame> , completed_atoms_array = <completed_atoms_array> , async = <async>}
	conditional_async_wait async = <async> text = qs(0xbe1f21de)
	if NOT gotparam \{completed_atoms_array}
		printf \{'setup_progression_atoms Error: No atoms were loaded or created'}
		return
	endif
	conditional_async_wait async = <async> text = qs(0xf15eb719)
	registeratoms savegame = <savegame> <completed_atoms_array>
	conditional_async_wait async = <async> text = qs(0xe8458658)
	if (<force_update> = 1)
		updateatoms savegame = <savegame>
	endif
	conditional_async_wait async = <async> text = qs(0xc368d59b)
	lockglobaltags \{pop_progression_writes_only}
	conditional_async_wait async = <async> text = qs(0xda73e4da)
endscript

script update_active_players_atoms 
	getnumplayersingame \{local}
	if (<num_players> > 0)
		getfirstplayer \{local}
		begin
		get_savegame_from_player player = <player>
		updateatoms savegame = <savegame>
		getnextplayer local player = <player>
		repeat <num_players>
	endif
endscript

script create_player_progression_atoms \{savegame = !i1768515945
		completed_atoms_array = !a1768515945
		async = 0}
	conditional_async_wait async = <async> text = qs(0x1780bad2)
	quest_progression_create_chapter_atoms_array savegame = <savegame> async = <async>
	return completed_atoms_array = (<completed_atoms_array> + <chapter_atoms>)
endscript
career_rewards_just_unlocked = [
]

script 0xd6692308 
	requireparams \{[
			reward_struct
			savegame
		]
		all}
	reward_type = (<reward_struct>.reward_type)
	if get_progression_player_and_controller savegame = <savegame>
		broadcastevent type = unlock_item_type data = {player = <player> controller_index = <controller_index> item_type = <reward_type>}
	endif
	switch (<reward_type>)
		case cas
		car_pieces = (<reward_struct>.car_pieces)
		getarraysize <car_pieces>
		i = 0
		begin
		part = ((<car_pieces> [<i>]).part)
		desc_id = ((<car_pieces> [<i>]).desc_id)
		printf 'Unlocking CAS %a in %b through rewards system' a = <desc_id> b = <part> channel = progression_unlocks
		set_cas_item_unlocked_flag part = <part> desc_id = <desc_id> savegame = <savegame>
		i = (<i> + 1)
		repeat <array_size>
		case venue
		case venue_reward
		venue_checksum = (<reward_struct>.venue_checksum)
		formattext checksumname = formatted_checksum 'venue_%s' s = ($levelzones.<venue_checksum>.name) addtostringlookup = true
		if NOT gotparam \{formatted_checksum}
			scriptassert qs(0xac1635a7) a = <venue>
			return
		endif
		setglobaltags <formatted_checksum> params = {unlocked = 1} savegame = <savegame> progression = true
		case character
		if structurecontains \{structure = reward_struct
				profile_idx}
			profile_idx = (<reward_struct>.profile_idx)
			unlock_profile id = ($preset_musician_profiles_locked [<profile_idx>].name) savegame = <savegame>
		elseif structurecontains \{structure = reward_struct
				profile_name}
			profile_name = (<reward_struct>.profile_name)
			unlock_profile id = (<profile_name>) savegame = <savegame>
		endif
		case cheat
		cheat_name = (<reward_struct>.cheat_name)
		original_savegame = <savegame>
		getfirstplayer \{local
			out = search_player}
		getnumplayersingame \{local}
		begin
		get_savegame_from_player player = <search_player>
		if (<original_savegame> = <savegame>)
			player = <search_player>
			break
		endif
		getnextplayer player = <search_player> local out = search_player
		repeat <num_players>
		set_progression_cheat_unlocked cheat_name = <cheat_name> savegame = <savegame>
		savegame = <original_savegame>
		case cas_texture
		texture = (<reward_struct>.texture)
		set_cas_texture_unlocked_flag savegame = <savegame> texture = <texture>
	endswitch
	if structurecontains structure = (<reward_struct>) run_career_outro_and_credits
		if NOT innetgame
			change \{end_credits = 1}
		else
			unlock_career_finale_video_and_achievement
		endif
	endif
endscript

script progression_create_rewards_atoms_array \{async = 0}
	getarraysize \{$reward_progression}
	createlocalarray name = atoms type = struct size = <array_size>
	index = 0
	begin
	formattext checksumname = name 'reward_%a_unlock' a = (<index> + 1) addtostringlookup = true
	depends_on = []
	addarrayelement array = <depends_on> element = {
		type = scr
		scr = progression_career_check_reward_unlock
		params = {($reward_progression [<index>]) savegame = <savegame>}
	}
	depends_on = <array>
	atom = {
		name = <name>
		type = scr
		atom_script = progression_career_do_reward_unlock
		atom_params = {reward_struct = ($reward_progression [<index>]) reward_progression_index = <index> name = <name> savegame = <savegame>}
		depends_on = <depends_on>
	}
	setarrayelement arrayname = atoms index = <index> newvalue = <atom>
	index = (<index> + 1)
	conditional_async_wait async = <async> text = qs(0x113a3caf)
	repeat <array_size>
	return reward_atoms = <atoms>
endscript

script progression_career_check_reward_unlock 
	criteria_passed = 0
	getglobaltags <requires_completed_gig> savegame = <savegame>
	if (<completed> = 1)
		if gotparam \{requires_completed_difficulty}
			switch <requires_completed_difficulty>
				case none
				criteria_passed = 1
				case gold
				if (<completed_gold> = 1)
					criteria_passed = 1
				endif
				case platinum
				if (<completed_platinum> = 1)
					criteria_passed = 1
				endif
				case diamond
				if (<completed_diamond> = 1)
					criteria_passed = 1
				endif
			endswitch
		else
			criteria_passed = 1
		endif
	endif
	if (<criteria_passed> = 1)
		return \{true}
	endif
	return \{false}
endscript

script progression_career_do_reward_unlock 
	requireparams \{[
			reward_struct
			reward_progression_index
			savegame
		]
		all}
	0xd6692308 reward_struct = <reward_struct> savegame = <savegame>
	reward_struct = (<reward_struct> + {reward_progression_index = <reward_progression_index>})
	progression_add_just_unlocked_item reward_struct = <reward_struct> player_savegame = <savegame>
endscript

script progression_add_just_unlocked_item 
	requireparams \{[
			reward_struct
			player_savegame
		]
		all}
	gamemode_gettype
	if (<type> != career)
		return
	endif
	getsavegamefromcontroller controller = ($primary_controller)
	if (<savegame> != <player_savegame>)
		return
	endif
	temp_array = ($career_rewards_just_unlocked)
	getarraysize <temp_array>
	if (<array_size> > 10)
		return
	endif
	reward_type = (<reward_struct>.reward_type)
	if (<array_size> > 0)
		i = 0
		begin
		check_struct = (<temp_array> [<i>])
		switch (<reward_type>)
			case cas
			if structurecontains \{structure = check_struct
					frontend_desc}
				frontend_desc = ((<temp_array> [<i>]).frontend_desc)
				if (<frontend_desc> = (<reward_struct>.frontend_desc))
					return
				endif
			endif
			case venue
			if structurecontains \{structure = check_struct
					venue_checksum}
				type = ((<temp_array> [<i>]).reward_type)
				venue_checksum = ((<temp_array> [<i>]).venue_checksum)
				if ((<type> = venue) && (<venue_checksum> = (<reward_struct>.venue_checksum)))
					return
				endif
			endif
			case gig
			if structurecontains \{structure = check_struct
					gig_checksum}
				type = ((<temp_array> [<i>]).reward_type)
				gig_checksum = ((<temp_array> [<i>]).gig_checksum)
				if ((<type> = gig) && (<gig_checksum> = (<reward_struct>.gig_checksum)))
					return
				endif
			endif
			case character
			if structurecontains \{structure = check_struct
					profile_idx}
				type = ((<temp_array> [<i>]).reward_type)
				index = ((<temp_array> [<i>]).profile_idx)
				if ((<type> = character) && (<index> = (<reward_struct>.profile_idx)))
					return
				endif
			endif
			case cheat
			if structurecontains \{structure = check_struct
					cheat_name}
				type = ((<temp_array> [<i>]).reward_type)
				name = ((<temp_array> [<i>]).cheat_name)
				if ((<type> = cheat) && (<name> = (<reward_struct>.cheat_name)))
					return
				endif
			endif
		endswitch
		i = (<i> + 1)
		repeat <array_size>
	endif
	addarrayelement array = <temp_array> element = <reward_struct>
	change career_rewards_just_unlocked = <array>
endscript

script progression_get_rewards_just_unlocked 
	return rewards_just_unlocked = ($career_rewards_just_unlocked)
endscript

script progression_clear_rewards_just_unlocked 
	change \{career_rewards_just_unlocked = [
		]}
endscript

script get_rewards_for_gig 
	requireparams \{[
			gig_name
		]
		all}
	getarraysize \{$reward_progression}
	i = 0
	begin
	if structurecontains structure = (($reward_progression) [<i>]) requires_completed_gig
		required_gig = ($reward_progression [<i>].requires_completed_gig)
		if (<required_gig> = <gig_name>)
			frontend_desc = qs(0x587f8983)
			unlock_icon = 0x00000000
			required_difficulty = 0x00000000
			if structurecontains structure = (($reward_progression) [<i>]) frontend_desc
				frontend_desc = ($reward_progression [<i>].frontend_desc)
			endif
			if structurecontains structure = (($reward_progression) [<i>]) vague_frontend_desc
				vague_frontend_desc = ($reward_progression [<i>].vague_frontend_desc)
			endif
			if structurecontains structure = (($reward_progression) [<i>]) unlock_icon
				unlock_icon = ($reward_progression [<i>].unlock_icon)
			endif
			if structurecontains structure = (($reward_progression) [<i>]) requires_completed_difficulty
				required_difficulty = ($reward_progression [<i>].requires_completed_difficulty)
			endif
			if gotparam \{vague_frontend_desc}
				return gig_rewards = {
					frontend_desc = <frontend_desc>
					vague_frontend_desc = ($<vague_frontend_desc>)
					unlock_icon = <unlock_icon>
					required_difficulty = <required_difficulty>
				}
			else
				return gig_rewards = {
					frontend_desc = <frontend_desc>
					unlock_icon = <unlock_icon>
					required_difficulty = <required_difficulty>
				}
			endif
		endif
	endif
	i = (<i> + 1)
	repeat <array_size>
	return \{gig_rewards = {
		}
		no_rewards = 1}
endscript

script progression_reward_song_stars 
	requireparams \{[
			song_checksum
		]
		all}
	getfirstplayer \{on_screen}
	begin
	getplayerinfo <player> is_local_client
	if (<is_local_client> = 1)
		getplayerinfo <player> controller
		getsavegamefromcontroller controller = <controller>
		getglobaltags <song_checksum> savegame = <savegame> param = stars
		old_stars = <stars>
		getglobaltags <song_checksum> savegame = <savegame> param = score
		old_score = <score>
		if (<new_stars> > <old_stars>)
			setglobaltags <song_checksum> savegame = <savegame> params = {stars = <new_stars>}
		endif
		if (<new_score> > <old_score>)
			casttointeger \{new_score}
			setglobaltags <song_checksum> savegame = <savegame> params = {score = <new_score>}
		endif
	endif
	getnextplayer on_screen player = <player>
	repeat <num_players_shown>
endscript

script progression_calculate_star_penalty 
	penalty = 0
	if (($cheat_invincible) = 1)
		penalty = (<penalty> + 1)
	endif
	return penalty = <penalty>
endscript

script progression_reward_stars 
	if ($end_credits > 0)
		return
	endif
	gman_getgrade goal = <current_challenge>
	gman_venuefunc \{goal = career
		tool = venue_handler
		func = get_current_venue}
	formattext checksumname = venue_checksum 'venue_%s' s = ($levelzones.<current_venue>.name)
	getnumplayersingame \{local}
	if (<num_players> > 0)
		getfirstplayer \{local}
		begin
		getplayerinfo <player> controller
		get_savegame_from_controller controller = <controller>
		getglobaltags <current_challenge> savegame = <savegame>
		star_reward = 0
		getsongstatshistory
		getarraysize <song_stats_history>
		getfirstplayer \{local
			out = first_player}
		getplayerinfo <first_player> band
		<star_penalty> = 0
		band = (<band> - 1)
		all_gold = 1
		new_stars = 0
		if (<array_size> >= 1)
			song_index = 0
			earned = ((<song_stats_history> [<song_index>] [<band>].band_stars) - <star_penalty>)
			if (<earned> < 0)
				earned = 0
			endif
			if (<earned> > <song1_stars_earned>)
				setglobaltags <current_challenge> params = {song1_stars_earned = <earned>} savegame = <savegame> progression = true
				new_stars = (<new_stars> + (<earned> - <song1_stars_earned>))
			endif
			if ((<song_stats_history> [<song_index>] [<band>].is_gold_stars) = 0)
				all_gold = 0
			endif
		endif
		if (<all_gold> = 1)
			setglobaltags <current_challenge> params = {earned_gold_stars = 1} savegame = <savegame> progression = true
		endif
		if ((<completed> = 0) && (<pending_grade> >= 1))
			setglobaltags <current_challenge> params = {completed = 1} savegame = <savegame> progression = true
		endif
		if ((<completed_gold> = 0) && (<pending_grade> >= 2))
			setglobaltags <current_challenge> params = {completed_gold = 1} savegame = <savegame> progression = true
			new_stars = (<new_stars> + ($star_reward_gold))
		endif
		if ((<completed_platinum> = 0) && (<pending_grade> >= 3))
			setglobaltags <current_challenge> params = {completed_platinum = 1} savegame = <savegame> progression = true
			new_stars = (<new_stars> + ($star_reward_platinum))
		endif
		if ((<completed_diamond> = 0) && (<pending_grade> >= 4))
			setglobaltags <current_challenge> params = {completed_diamond = 1} savegame = <savegame> progression = true
			new_stars = (<new_stars> + ($star_reward_diamond))
		endif
		get_current_progression_stars savegame = <savegame>
		total_stars = (<total_stars> + <new_stars>)
		set_progression_stars new_total_stars = <total_stars> savegame = <savegame>
		getglobaltags <venue_checksum> param = venue_stars savegame = <savegame>
		setglobaltags <venue_checksum> params = {venue_stars = (<venue_stars> + <new_stars>)} savegame = <savegame> progression = true
		getnextplayer local player = <player>
		repeat <num_players>
	endif
	update_active_players_atoms
	gman_setgrade goal = <current_challenge>
endscript

script get_current_progression_stars 
	if NOT gotparam \{savegame}
		get_savegame_from_controller controller = ($primary_controller)
	endif
	if NOT getglobaltags career_progression_tags param = total_stars savegame = <savegame> noassert = 1
		return \{total_stars = 0}
	endif
	return total_stars = <total_stars>
endscript

script set_progression_stars \{new_total_stars = !i1768515945}
	if NOT gotparam \{savegame}
		get_savegame_from_controller controller = ($primary_controller)
	endif
	setglobaltags savegame = <savegame> career_progression_tags params = {total_stars = <new_total_stars>} progression = true
	if savegamegetprogression savegame = <savegame>
		formattext checksumname = field 'progression_header%d' d = <progression> addtostringlookup = true
		setglobaltags savegame = <savegame> <field> params = {stars = <new_total_stars>}
	endif
endscript

script get_current_progression_award_points 
	if NOT gotparam \{savegame}
		get_savegame_from_controller controller = ($primary_controller)
	endif
	if NOT getglobaltags career_progression_tags param = total_award_points savegame = <savegame> noassert = 1
		return \{total_award_points = 0}
	endif
	return total_award_points = <total_award_points>
endscript

script set_progression_award_points \{new_total_award_points = !i1768515945}
	if NOT gotparam \{savegame}
		get_savegame_from_controller controller = ($primary_controller)
	endif
	setglobaltags savegame = <savegame> career_progression_tags params = {total_award_points = <new_total_award_points>} progression = true
	if savegamegetprogression savegame = <savegame>
		formattext checksumname = field 'progression_header%d' d = <progression> addtostringlookup = true
		setglobaltags savegame = <savegame> <field> params = {award_points = <new_total_award_points>}
	endif
endscript

script get_progression_globals 
	return \{progression_global = gh5_career_guitar_progression}
endscript

script progression_songwon 
	update_song_star_rating
	if issingleplayergame
		getfirstplayer \{out = player_one}
		getplayerinfo <player_one> part
	else
		part = band
	endif
	get_highest_difficulty
	get_difficulty_text_nl difficulty = <highest_difficulty>
	playlist_getcurrentsong
	get_song_prefix song = <current_song>
	progression_updatedetailedstatsforgig
	if ($autotest_on = 1)
		return
	endif
	if NOT ($is_in_debug)
		if (<current_song> != jamsession)
			gamemode_gettype
			if NOT isbandcheating
				<score> = 0
				<stars> = 0
				songlist_get_data_for_songlist_stats
				if (<type> = career)
					get_savegame_from_controller controller = ($primary_controller)
					getglobaltags savegame = <savegame> career_progression_tags param = current_chapter
					<chapter_name> = ($<current_chapter>.name)
					format_career_song_gigtag chapter_name = <chapter_name> song_name = <song_prefix>
					songlist_get_data_for_songlist_stats
					<setup_encore> = 0
					if (<stars> > 0)
						<new_stars> = <stars>
						getglobaltags savegame = <savegame> <song_gigtag> param = stars
						if (<new_stars> > <stars>)
							setglobaltags savegame = <savegame> <song_gigtag> params = {stars = <new_stars>} progression = true
							if quest_progression_check_for_chapter_complete savegame = <savegame> chapter_global = <current_chapter>
								broadcastevent type = encore_complete data = {player = ($g_net_leader_player_num) controller_index = ($primary_controller)}
								quest_progression_set_chapter_tags savegame = <savegame> chapter_global = <current_chapter> params = {completed = 1}
							endif
							quest_progression_get_chapter_tag savegame = <savegame> chapter_global = <current_chapter> param = encore_unlocked
							if (<encore_unlocked> = 0)
								quest_progression_get_encore_stars_required chapter_global = <current_chapter>
								if (<total_stars> >= <encore_stars_required>)
									quest_progression_set_chapter_tags savegame = <savegame> chapter_global = <current_chapter> params = {encore_unlocked = 1}
									setglobaltags savegame = <savegame> career_progression_tags params = {encore_ready = 1} progression = true
									quest_progression_add_transformation_songs chapter_global = <current_chapter>
									<setup_encore> = 1
								endif
							endif
						endif
					endif
					if ($debug_career_transformations = 1)
						change \{debug_career_transformations = 0}
						if (<setup_encore> = 0)
							quest_progression_set_chapter_tags savegame = <savegame> chapter_global = <current_chapter> params = {encore_unlocked = 1}
							setglobaltags savegame = <savegame> career_progression_tags params = {encore_ready = 1} progression = true
							quest_progression_add_transformation_songs chapter_global = <current_chapter>
						endif
					endif
				elseif (<type> = quickplay)
					if (<score> > 0)
						consider_setlist_score {
							player_score = <score>
							player_stars = <stars>
							player_percentage = <percent_notes_hit>
							song_prefix = (<song_prefix>) difficulty_text_nl = <difficulty_text_nl> part = ($instrument_list.<part>.text_nl)
						}
					endif
				endif
			endif
			if ((<type> = career) || (<type> = quickplay) || (<type> = competitive))
				increment_num_times_played {
					song_id = ($last_song_played)
				}
			endif
		endif
		if isxenonorwindx
			if NOT (<current_song> = jamsession)
				writesongdatatofile
			endif
		endif
	endif
endscript

script progression_songfailed 
	printf \{qs(0xb3ef858d)}
	if ($game_mode = career)
		update_active_players_atoms
	endif
	if ($current_song != $last_song_failed)
		change last_song_failed = ($current_song)
		change \{current_song_failed_num = 1}
	else
		change current_song_failed_num = ($current_song_failed_num + 1)
	endif
	if ($current_song_failed_num < 3)
		if isxenonorwindx
			if NOT is_current_song_a_jam_session
				writesongdatatofile \{failed = 1}
			endif
		endif
	endif
endscript

script update_song_star_rating 
	getnumplayersingame \{local}
	getfirstplayer \{local}
	if (<num_players> > 0)
		begin
		getplayerinfo <player> projected_song_stars
		getplayerinfo <player> band
		<stars> = <projected_song_stars>
		casttointeger \{stars}
		setplayerinfo <player> stars = <stars>
		getbandinfo <band> projected_song_stars out = band_projected_song_stars
		band_stars = <band_projected_song_stars>
		casttointeger \{band_stars}
		setbandinfo <band> stars = <band_stars>
		getnextplayer player = <player> local
		repeat <num_players>
	endif
endscript

script get_player_percent_accuracy 
	requireparams \{[
			player_index
		]
		all}
	if NOT playerinfoequals <player_index> part = vocals
		getplayerinfo <player_index> notes_hit
		getplayerinfo <player_index> max_notes
		if (<max_notes> > 0)
			<percent_notes_hit> = (((<notes_hit> * 1.0) / <max_notes>) * 100.0)
		else
			<percent_notes_hit> = 0
		endif
	else
		getplayerinfo <player_index> vocal_phrase_quality
		getplayerinfo <player_index> vocal_phrase_max_qual
		if (<vocal_phrase_max_qual> > 0)
			<percent_notes_hit> = (((<vocal_phrase_quality> * 1.0) / <vocal_phrase_max_qual>) * 100.0)
		else
			<percent_notes_hit> = 0
		endif
	endif
	mathfloor <percent_notes_hit>
	<percent_notes_hit> = <floor>
	return percent_notes_hit = <percent_notes_hit>
endscript
end_credits = 0

script unlock_career_finale_video_and_achievement 
	getarraysize \{$bonus_videos}
	i = 0
	begin
	video_id = ((($bonus_videos) [<i>]).id)
	if (<video_id> = career_ending)
		getnumplayersingame \{local}
		getfirstplayer \{local}
		begin
		getplayerinfo <player> controller
		getsavegamefromcontroller controller = <controller>
		setglobaltags savegame = <savegame> <video_id> params = {unlocked = 1} packtype = unlockedtags
		fire_achievement name = achievement_thetraditional controller = <controller>
		getnextplayer player = <player> local
		repeat <num_players>
	endif
	i = (<i> + 1)
	repeat <array_size>
endscript

script unlock_and_goto_credits 
	unlock_career_finale_video_and_achievement
	ui_memcard_autosave_all_players \{event = menu_change
		state = uistate_end_credits}
endscript

script progression_endcredits 
	progression_getcreditssong
	playlist_setcurrentsong song = <credits_song>
	sfx_backgrounds_new_area \{bg_sfx_area = frontend
		fadeouttime = 2
		fadeouttype = linear}
	if memheapexists \{name = heap_song}
		destroy_song_and_musicstudio_heaps \{do_unloads}
	endif
	setbinkheap \{heap_cas_cache}
	playmovieandwait \{noblack
		movie = 'career_ending'
		no_script_wait
		noskip}
	progression_getcreditsvenue
	change current_level = <credits_venue>
	setbinkheap \{heap_bink}
	waitformovie_endcredits
	create_loading_screen
	load_venue
	audio_crowd_setup_based_on_zone
	create_song_and_musicstudio_heaps
	if NOT ui_event_exists_in_stack \{name = 'gameplay'}
		if ($is_in_debug = 0)
			return
		else
			playlist_setcurrentsong song = <credits_song>
			generic_event_choose \{state = uistate_play_song}
		endif
	else
		change \{gameplay_restart_song = 1}
		generic_event_back \{nosound
			state = uistate_gameplay}
	endif
	spawnscriptnow \{scrolling_list_begin_credits}
endscript

script progression_endcredits_done 
	destroy_credits_menu
endscript

script progression_getcreditssong 
	credits_gig_checksum = ($gig_credits)
	if NOT structurecontains structure = ($<credits_gig_checksum>) predefined_playlist
		scriptassert \{'Progression_GetCreditsSong: Couldnt find a predefined_playlist in the $credits_gig struct'}
	endif
	getarraysize (($<credits_gig_checksum>).predefined_playlist)
	if (<array_size> != 1)
		scriptassert 'Progression_GetCreditsSong: %a songs in $gig_credits playlist, when there should be 1' a = <array_size>
	endif
	credits_song_checksum = (($<credits_gig_checksum>).predefined_playlist [0])
	return credits_song = <credits_song_checksum>
endscript

script progression_getcreditsvenue 
	credits_gig_checksum = ($gig_credits)
	if NOT structurecontains structure = ($<credits_gig_checksum>) venue
		scriptassert \{'Progression_GetCreditsVenue: Couldnt find a venue in the $credits_gig struct, this is odd'}
	endif
	credits_venue_checksum = (($<credits_gig_checksum>).venue)
	return credits_venue = <credits_venue_checksum>
endscript

script progression_isencoresong 
	return \{false}
endscript

script progression_setprogressionnodeflags 
	changenodeflag \{ls_always
		1}
	ls_encore = 0
	ls_3_5 = 0
	if ($debug_encore)
		<ls_encore> = 1
	endif
	if ($encore_transitioned_played = true)
		ls_encore = 1
	else
		gamemode_gettype
		if (<type> = career)
			getpakmancurrent \{map = zones}
			if is_encore_song
				ls_encore = 1
			endif
		endif
	endif
	if (<ls_encore> = 1)
		changenodeflag \{ls_3_5_pre
			0}
		changenodeflag \{ls_3_5_post
			1}
		changenodeflag \{ls_encore_pre
			0}
		changenodeflag \{ls_encore_post
			1}
	elseif (<ls_3_5> = 1)
		changenodeflag \{ls_3_5_pre
			0}
		changenodeflag \{ls_3_5_post
			1}
		changenodeflag \{ls_encore_pre
			1}
		changenodeflag \{ls_encore_post
			0}
	else
		changenodeflag \{ls_3_5_pre
			1}
		changenodeflag \{ls_3_5_post
			0}
		changenodeflag \{ls_encore_pre
			1}
		changenodeflag \{ls_encore_post
			0}
	endif
	getpakmancurrentname \{map = zones}
	if gotparam \{pakname}
		formattext checksumname = zone_setup '%s_SetupNodeflags' s = <pakname>
		if scriptexists <zone_setup>
			spawnscriptnow <zone_setup>
		endif
	endif
endscript

script progression_cleardetailedstatsforgig 
	change \{song_stats_backup = [
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
		]}
	change \{song_stats_backup_band = [
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
			{
			}
		]}
endscript

script progression_updatedetailedstatsforgig 
	playlist_getcurrentsong
	progression_cleardetailedstatsforgig
	<default_song_stats> = {
		song = <current_song>
	}
	getnumplayersingame
	if (<num_players> > 0)
		getfirstplayer
		begin
		getplayerinfo <player> score
		casttointeger \{score}
		getplayerinfo <player> stars
		getplayerinfo <player> notes_hit
		getplayerinfo <player> total_notes
		getplayerinfo <player> notes_created
		getplayerinfo <player> sp_phrases_hit
		getplayerinfo <player> sp_phrases_total
		getplayerinfo <player> best_run
		getplayerinfo <player> max_notes
		getplayerinfo <player> vocal_streak_phrases
		getplayerinfo <player> vocal_phrase_quality
		getplayerinfo <player> vocal_phrase_max_qual
		get_average_multiplier player = <player>
		<avg_multiplier> = <average_multiplier>
		get_song_section_arrays_for_player player = <player>
		<curr_song_stats> = {
			<default_song_stats>
			score = <score>
			stars = <stars>
			notes_hit = <notes_hit>
			best_run = <best_run>
			max_notes = <max_notes>
			total_notes = <total_notes>
			notes_created = <notes_created>
			sp_phrases_hit = <sp_phrases_hit>
			sp_phrases_total = <sp_phrases_total>
			avg_multiplier = <avg_multiplier>
			vocal_streak_phrases = <vocal_streak_phrases>
			vocal_phrase_quality = <vocal_phrase_quality>
			vocal_phrase_max_qual = <vocal_phrase_max_qual>
			detailed_stats = <detailed_stats>
			detailed_stats_max = <detailed_stats_max>
			section_names = <section_names>
		}
		<stats_all> = ($song_stats_backup)
		setarrayelement arrayname = stats_all index = (<player> - 1) newvalue = <curr_song_stats>
		change globalname = song_stats_backup newvalue = <stats_all>
		getnextplayer player = <player>
		repeat <num_players>
	endif
	getbandsstatus
	if gotparam \{bands}
		getarraysize <bands>
		bands_size = <array_size>
		if (<bands_size> > 0)
			band_idx = 0
			begin
			band = (<band_idx> + 1)
			getbandinfo <band> stars
			getbandinfo <band> score
			getbandinfo <band> high_mult
			getbandinfo <band> high_1p_streak
			getbandinfo <band> high_2p_streak
			getbandinfo <band> high_3p_streak
			getbandinfo <band> high_4p_streak
			getbandinfo <band> band_moments_hit
			getbandinfo <band> band_moments_possible
			current_band_stats = {
				stars = <stars>
				score = <score>
				high_mult = <high_mult>
				high_1p_streak = <high_1p_streak>
				high_2p_streak = <high_2p_streak>
				high_3p_streak = <high_3p_streak>
				high_4p_streak = <high_4p_streak>
				band_moments_hit = <band_moments_hit>
				band_moments_possible = <band_moments_possible>
			}
			<band_stats_all> = ($song_stats_backup_band)
			setarrayelement arrayname = band_stats_all index = <band_idx> newvalue = <current_band_stats>
			change globalname = song_stats_backup_band newvalue = <band_stats_all>
			band_idx = (<band_idx> + 1)
			repeat <bands_size>
		endif
	endif
	if NOT gotparam \{failed_or_practice}
		addhistoryforcurrentsong
	endif
endscript

script get_song_section_arrays_for_player 
	requireparams \{[
			player
		]
		all}
	<detailed_stats> = []
	<detailed_stats_max> = []
	<section_names> = []
	formattext checksumname = last_song_stats 'p%p_last_song_detailed_stats' p = <player> addtostringlookup = true
	formattext checksumname = last_song_stats_max 'p%p_last_song_detailed_stats_max' p = <player> addtostringlookup = true
	get_song_section_array player = <player>
	getarraysize <song_section_array>
	if (<array_size> > 0)
		<detailed_stats> = ($<last_song_stats>)
		<detailed_stats_max> = ($<last_song_stats_max>)
		i = 0
		begin
		formattext textname = marker_text qs(0x73307931) s = ((<song_section_array> [<i>]).marker)
		addarrayelement array = <section_names> element = <marker_text>
		<section_names> = <array>
		i = (<i> + 1)
		repeat <array_size>
	endif
	return detailed_stats = <detailed_stats> detailed_stats_max = <detailed_stats_max> section_names = <section_names>
endscript

script get_progression_player_and_controller \{savegame = !i1768515945}
	<target_savegame> = <savegame>
	<num_matches> = 0
	<last_matching_player> = 0
	<ret> = true
	getnumplayersingame \{local}
	getfirstplayer \{local}
	begin
	getplayerinfo <player> controller
	getsavegamefromcontroller controller = <controller>
	if (<target_savegame> = <savegame>)
		<num_matches> = (1 + <num_matches>)
		<last_matching_player> = <player>
	endif
	getnextplayer player = <player> local
	repeat <num_players>
	if (1 = <num_matches>)
		getplayerinfo <last_matching_player> controller
		addparam structure_name = return_struct name = player value = <last_matching_player>
		addparam structure_name = return_struct name = controller_index value = <controller>
	else
		<ret> = false
	endif
	return <ret> <return_struct>
endscript
