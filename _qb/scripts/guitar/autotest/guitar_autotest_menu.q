autotest_part_strings = {
	none = qs(0x3f1bbbb1)
	guitar = qs(0x826ca62c)
	bass = qs(0xec55f51b)
	vocals = qs(0x0cf770e2)
	drum = qs(0xf9468e57)
}
autotest_difficulty_strings = {
	beginner = qs(0x66a003c6)
	easy = qs(0x1c7f1488)
	medium = qs(0x79990567)
	hard = qs(0xc0aa0a20)
	expert = qs(0x242117ca)
}
autotest_game_mode_names = {
	career = qs(0xd1270c2d)
	quickplay = qs(0x4e077ebc)
	p8_pro_faceoff = qs(0xf33cebb5)
	practice = qs(0x3bee06d2)
}
autotest_hud_on = 0
autotest_restore_globals = 0
autotest_save_bot1 = 0
autotest_save_bot2 = 0
autotest_save_bot3 = 0
autotest_save_bot4 = 0
autotest_save_current_starttime = 0
autotest_save_current_level = 0
autotest_save_current_difficulty1 = 0
autotest_save_current_difficulty2 = 0
autotest_save_current_difficulty3 = 0
autotest_save_current_difficulty4 = 0
autotest_save_game_mode = 0
autotest_save_use_worst_band = 0
autotest_save_speedfactor = 0

script autotest_save_globals 
	getplayerinfo \{1
		bot_play
		out = bot_play1}
	getplayerinfo \{2
		bot_play
		out = bot_play2}
	getplayerinfo \{3
		bot_play
		out = bot_play3}
	getplayerinfo \{4
		bot_play
		out = bot_play4}
	getplayerinfo \{1
		difficulty
		out = difficulty1}
	getplayerinfo \{2
		difficulty
		out = difficulty2}
	getplayerinfo \{3
		difficulty
		out = difficulty3}
	getplayerinfo \{4
		difficulty
		out = difficulty4}
	change autotest_save_bot1 = <bot_play1>
	change autotest_save_bot2 = <bot_play2>
	change autotest_save_bot3 = <bot_play3>
	change autotest_save_bot4 = <bot_play4>
	change autotest_save_current_starttime = ($current_starttime)
	change autotest_save_current_level = ($current_level)
	change autotest_save_current_difficulty1 = <difficulty1>
	change autotest_save_current_difficulty2 = <difficulty2>
	change autotest_save_current_difficulty3 = <difficulty3>
	change autotest_save_current_difficulty4 = <difficulty4>
	change autotest_save_game_mode = ($game_mode)
	change autotest_save_use_worst_band = ($use_worst_band)
	change autotest_save_speedfactor = ($current_speedfactor)
	change \{autotest_restore_globals = 1}
endscript

script autotest_autotest_restore_globals 
	setplayerinfo 1 bot_play = ($autotest_save_bot1)
	setplayerinfo 2 bot_play = ($autotest_save_bot2)
	setplayerinfo 3 bot_play = ($autotest_save_bot3)
	setplayerinfo 4 bot_play = ($autotest_save_bot4)
	change current_starttime = ($autotest_save_current_starttime)
	change current_level = ($autotest_save_current_level)
	setplayerinfo 1 difficulty = ($autotest_save_current_difficulty1)
	setplayerinfo 2 difficulty = ($autotest_save_current_difficulty2)
	setplayerinfo 3 difficulty = ($autotest_save_current_difficulty3)
	setplayerinfo 4 difficulty = ($autotest_save_current_difficulty4)
	change game_mode = ($autotest_save_game_mode)
	change use_worst_band = ($autotest_save_use_worst_band)
	change current_speedfactor = ($autotest_save_speedfactor)
	change \{autotest_restore_globals = 0}
endscript

script autotest_menu_start 
	change \{autotest_on = 1}
	autotest_save_globals
	setplayerinfo \{1
		bot_play = 1}
	setplayerinfo \{2
		bot_play = 1}
	setplayerinfo \{3
		bot_play = 1}
	setplayerinfo \{4
		bot_play = 1}
	autotest_create_suite_list
	change \{autotest_test_index = 0}
endscript

script autotest_create_suite_list 
	if NOT screenelementexists \{id = test_suite_list}
		createscreenelement {
			type = vmenu
			parent = root_window
			id = test_suite_list
			just = [left top]
			dims = (400.0, 550.0)
			pos = ($menu_pos - (500.0, 0.0))
			rgba = [128 128 128 250]
		}
		autotest_populate_test_suite_list
	endif
endscript

script destroy_test_suite_select_menu 
	if screenelementexists \{id = test_suite_scrolling_menu}
		destroyscreenelement \{id = test_suite_scrolling_menu}
	endif
	if screenelementexists \{id = test_suite_list}
		destroyscreenelement \{id = test_suite_list}
	endif
	clean_up_user_control_helpers
	destroy_menu_backdrop
endscript

script autotest_suite_transition_set_props 
	gettrueelapsedtime \{starttime = $autotest_initial_time}
	change autotest_total_time = <elapsedtime>
	autotest_format_time \{time = $autotest_total_time
		mode = hours_minutes_seconds}
	autotest_suite_transition :se_setprops test_suite_text = (<suite_struct>.name)
	autotest_suite_transition :se_setprops total_time_text = <formatted_time>
	if ($autotest_total_frames > 0)
		change autotest_average_fps = ($autotest_average_fps / $autotest_total_frames)
	endif
	formattext \{textname = average_fps_text
		qs(0x44859f25)
		f = $autotest_average_fps}
	autotest_format_time \{time = $autotest_highest_fps_time
		mode = minutes_seconds_ms}
	formattext \{textname = highest_fps_text
		qs(0x44859f25)
		f = $autotest_highest_fps}
	formattext textname = highest_fps_info qs(0xb17c4417) s = $autotest_highest_fps_test t = <formatted_time>
	autotest_format_time \{time = $autotest_lowest_fps_time
		mode = minutes_seconds_ms}
	formattext \{textname = lowest_fps_text
		qs(0x44859f25)
		f = $autotest_lowest_fps}
	formattext textname = lowest_fps_info qs(0xb17c4417) s = $autotest_lowest_fps_test t = <formatted_time>
	autotest_suite_transition :se_setprops average_fps_text = <average_fps_text>
	autotest_suite_transition :se_setprops highest_fps_text = <highest_fps_text>
	autotest_suite_transition :se_setprops highest_fps_info_text = <highest_fps_info>
	autotest_suite_transition :se_setprops lowest_fps_text = <lowest_fps_text>
	autotest_suite_transition :se_setprops lowest_fps_info_text = <lowest_fps_info>
endscript

script autotest_transition_set_props 
	autotest_get_suite \{suite_num = $autotest_suite_index
		fromsuitelist}
	autotest_get_test \{suite_num = $autotest_suite_index
		test_num = $autotest_test_index}
	formattext textname = suite_and_test_text qs(0x2a2c7f76) s = (<suite_struct>.name) t = $autotest_test_index
	autotest_transition :se_setprops test_suite_text = <suite_and_test_text>
	props_struct = ($on_disc_props)
	<song_name> = (<test_struct>.song)
	<song_struct> = (($<props_struct>).<song_name>)
	<song_text> = (<song_struct>.title)
	autotest_transition :se_setprops song_text = <song_text>
	<venue_name> = (<test_struct>.level)
	<venue_struct> = ($levelzones.<venue_name>)
	<venue_text> = (<venue_struct>.title)
	autotest_transition :se_setprops venue_text = <venue_text>
	<game_mode> = (<test_struct>.game_mode)
	autotest_transition :se_setprops game_mode_text = ($autotest_game_mode_names.<game_mode>)
	<starttime_text> = qs(0x431892ee)
	<endtime_text> = qs(0x449293a1)
	if ($autotest_has_starttime = 1)
		autotest_format_time \{mode = minutes_seconds_ms
			time = $current_starttime}
		formattext textname = starttime_text qs(0x73307931) s = <formatted_time>
	endif
	if ($autotest_has_endtime = 1)
		autotest_format_time \{mode = minutes_seconds_ms
			time = $autotest_endtime}
		formattext textname = endtime_text qs(0x6fa8cce6) e = <formatted_time>
	endif
	formattext textname = time_span_text qs(0xcdace2e0) s = <starttime_text> e = <endtime_text>
	autotest_transition :se_setprops time_span_text = <time_span_text>
	formattext textname = speed_text qs(0x73307931) s = <speed>
	autotest_transition :se_setprops speed_text = <speed_text>
	if (<test_struct>.p1_part != none)
		autotest_transition :se_setprops p1_part_text = ($autotest_part_strings.(<test_struct>.p1_part))
		autotest_transition :se_setprops p1_difficulty_text = ($autotest_difficulty_strings.(<test_struct>.p1_difficulty))
	else
		autotest_transition :se_setprops \{p1_part_text = qs(0x549620e7)}
		autotest_transition :se_setprops \{p1_difficulty_text = qs(0x03ac90f0)}
	endif
	if (<test_struct>.p2_part != none)
		autotest_transition :se_setprops p2_part_text = ($autotest_part_strings.(<test_struct>.p2_part))
		autotest_transition :se_setprops p2_difficulty_text = ($autotest_difficulty_strings.(<test_struct>.p2_difficulty))
	else
		autotest_transition :se_setprops \{p2_part_text = qs(0x549620e7)}
		autotest_transition :se_setprops \{p2_difficulty_text = qs(0x03ac90f0)}
	endif
	if (<test_struct>.p3_part != none)
		autotest_transition :se_setprops p3_part_text = ($autotest_part_strings.(<test_struct>.p3_part))
		autotest_transition :se_setprops p3_difficulty_text = ($autotest_difficulty_strings.(<test_struct>.p3_difficulty))
	else
		autotest_transition :se_setprops \{p3_part_text = qs(0x549620e7)}
		autotest_transition :se_setprops \{p3_difficulty_text = qs(0x03ac90f0)}
	endif
	if (<test_struct>.p4_part != none)
		autotest_transition :se_setprops p4_part_text = ($autotest_part_strings.(<test_struct>.p4_part))
		autotest_transition :se_setprops p4_difficulty_text = ($autotest_difficulty_strings.(<test_struct>.p4_difficulty))
	else
		autotest_transition :se_setprops \{p4_part_text = qs(0x549620e7)}
		autotest_transition :se_setprops \{p4_difficulty_text = qs(0x03ac90f0)}
	endif
endscript

script destroy_autotest_menu \{still_testing = 0}
	if screenelementexists \{id = autotest_vmenu}
		destroyscreenelement \{id = autotest_vmenu}
	endif
	if screenelementexists \{id = test_suite_list}
		destroyscreenelement \{id = test_suite_list}
	endif
	destroy_menu_backdrop
	killspawnedscript \{name = autotest_check_end_time}
	killspawnedscript \{name = autotest_update_gpu_info}
	if (<still_testing> = 0)
		change \{autotest_on = 0}
		change \{autotest_suite_index = 0}
		change \{autotest_test_index = 0}
		if ($autotest_restore_globals = 1)
			autotest_autotest_restore_globals
		endif
	endif
endscript

script back_to_autotest_menu 
	destroy_test_suite_select_menu
	destroy_autotest_complete
	create_autotest_menu
endscript

script destroy_autotest_complete 
	if screenelementexists \{id = autotest_complete}
		destroyscreenelement \{id = autotest_complete}
	endif
endscript

script autotest_create_hud 
	if ($autotest_hud_on)
		if NOT screenelementexists \{id = autotest_hud}
			begin
			if screenelementexists \{id = hud_root}
				break
			endif
			wait \{1
				gameframe}
			repeat
			createscreenelement \{parent = root_window
				id = autotest_hud
				type = descinterface
				desc = 'autotest_hud'}
			spawnscriptnow \{autotest_update_in_game_hud}
		endif
	endif
endscript

script autotest_destroy_hud 
	killspawnedscript \{name = autotest_update_in_game_hud}
	if screenelementexists \{id = autotest_hud}
		destroyscreenelement \{id = autotest_hud}
	endif
endscript
