
script ui_create_bonus_videos 
	change \{rich_presence_context = presence_videos}
	locked_option_flags = {
		not_focusable
		text_focus_color = [220 30 30 255]
		text_unfocus_color = [216 181 117 255]
	}
	uistack_createboundscreenelement \{parent = root_window
		id = options_videos_menu_id
		type = descinterface
		desc = 'mainmenu'
		tags = {
		}
		event_handlers = [
			{
				pad_back
				generic_event_back
			}
		]}
	mainmenu_setup_physics_elements \{screen_id = options_videos_menu_id}
	uistack_spawnboundscriptnow \{fg_objects_1
		params = {
			desc_id = options_videos_menu_id
		}}
	uistack_spawnboundscriptnow \{ampzilla_anim
		params = {
			desc_id = options_videos_menu_id
		}}
	uistack_spawnboundscriptnow \{anim_clouds
		params = {
			desc_id = options_videos_menu_id
		}}
	mainmenu_setup_option {
		choose_state = uistate_bonus_videos_credits
		back_script = generic_event_back
		menu_item_text = ($bonus_videos [0].text)
		screen_id = options_videos_menu_id
		helper_text = qs(0x03ac90f0)
	}
	getarraysize ($bonus_videos)
	i = 1
	begin
	if NOT ui_bonus_videos_is_locked id = ($bonus_videos [<i>].id)
		movie = ($bonus_videos [<i>].movie)
		getterritory
		if gotparam \{territory}
			if NOT (<territory> = territory_us)
				if structurecontains structure = ($bonus_videos [<i>]) movienoesrb
					movie = ($bonus_videos [<i>].movienoesrb)
				endif
			else
			endif
		endif
		mainmenu_setup_option {
			choose_script = ui_bonus_videos_play_video_if_not_playing
			choose_params = {movie = <movie>}
			back_script = generic_event_back
			menu_item_text = ($bonus_videos [<i>].text)
			screen_id = options_videos_menu_id
			helper_text = qs(0x03ac90f0)
		}
	else
		mainmenu_setup_option {
			choose_script = ui_bonus_videos_negative_sfx
			back_script = generic_event_back
			menu_item_text = qs(0x24a08263)
			screen_id = options_videos_menu_id
			helper_text = qs(0x03ac90f0)
			<locked_option_flags>
		}
	endif
	<i> = (<i> + 1)
	repeat (<array_size> - 1)
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green
		z = 100000}
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red
		z = 100000}
	launchevent type = focus target = current_menu data = {child_index = <selected_index>}
endscript

script ui_destroy_bonus_videos 
	clean_up_user_control_helpers
	if screenelementexists \{id = options_videos_menu_id}
		destroyscreenelement \{id = options_videos_menu_id}
	endif
endscript

script ui_bonus_videos_play_video_if_not_playing \{movie = 'atvi'}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	if NOT scriptisrunning \{ui_bonus_videos_play_video}
		ui_bonus_videos_play_video movie = <movie>
	endif
endscript

script ui_bonus_videos_play_video \{movie = 'atvi'}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	launchevent \{type = unfocus
		target = current_menu}
	current_menu :se_setprops \{block_events}
	if ui_bonus_videos_is_locked id = <id>
	else
		audio_ui_menu_music_off
		spawnscriptnow \{audio_crowd_silence_front_end
			params = {
				immediate = 1
			}}
		fadetoblack \{on
			alpha = 1.0
			time = 0
			z_priority = 200}
		clean_up_user_control_helpers
		netsessionfunc \{func = removeallcontrollers}
		destroy_song_and_musicstudio_heaps \{do_unloads}
		setbinkheap \{heap_cas_cache}
		playmovieandwait noblack movie = <movie>
		setbinkheap \{heap_bink}
		create_song_and_musicstudio_heaps
		if ($invite_controller = -1)
			netsessionfunc func = addcontrollers params = {controller = ($primary_controller)}
		else
			netsessionfunc func = addcontrollers params = {controller = ($invite_controller)}
		endif
		menu_finish
		fadetoblack \{off
			time = 0}
		spawnscriptnow \{sfx_backgrounds_new_area
			params = {
				bg_sfx_area = frontend_menu_music
			}}
		audio_ui_menu_music_on
		add_user_control_helper \{text = qs(0xc18d5e76)
			button = green
			z = 100000}
		add_user_control_helper \{text = qs(0xaf4d5dd2)
			button = red
			z = 100000}
	endif
	current_menu :se_setprops \{unblock_events}
	launchevent \{type = focus
		target = current_menu}
endscript

script ui_bonus_videos_is_locked 
	getarraysize ($bonus_videos)
	i = 0
	begin
	if gotparam \{id}
		if (<id> = ($bonus_videos [<i>].id))
			getglobaltags ($bonus_videos [<i>].id)
			if (<unlocked> = 0)
				return \{true}
			else
				return \{false}
			endif
		endif
	elseif gotparam \{movie}
		if (<movie> = ($bonus_videos [<i>].movie))
			getglobaltags ($bonus_videos [<i>].id)
			if (<unlocked> = 0)
				return \{true}
			else
				return \{false}
			endif
		endif
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	return \{false}
endscript

script get_movie_id_by_name 
	getarraysize ($bonus_videos)
	i = 0
	begin
	if (($bonus_videos [<i>].movie) = <movie>)
		return id = ($bonus_videos [<i>].id)
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	scriptassert \{qs(0xbb136b8e)}
endscript

script ui_bonus_videos_negative_sfx 
	ui_sfx \{menustate = generic
		uitype = negativeselect}
endscript

script ui_bonus_videos_anim_in 
	printf \{channel = blah
		qs(0x0d1a424d)}
	if screenelementexists \{id = options_videos_menu_id}
		begin
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-309.0, 210.0)
			gor_anim_pos = (-269.0, -20.0)
			gor_anim_scale = (1.0, 1.0)
			bgrock_anim_pos = (-130.0, -186.0)
			axestone_anim_pos = (317.0, 82.0)
			ampzilla_anim_pos = (18.0, -176.0)
			mainmenu_anim_calcium_fulltop_pos = (86.0, 100.0)}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-315.0, 233.0)
			gor_anim_pos = (-272.0, -20.0)
			gor_anim_scale = (1.03, 1.03)
			bgrock_anim_pos = (-155.0, -178.0)
			axestone_anim_pos = (330.0, 72.0)
			ampzilla_anim_pos = (10.0, -169.0)
			mainmenu_anim_calcium_fulltop_pos = (79.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-305.0, 233.0)
			gor_anim_pos = (-260.0, -20.0)
			bgrock_anim_pos = (-130.0, -195.0)
			axestone_anim_pos = (310.0, 82.0)
			ampzilla_anim_pos = (25.0, -180.0)
			mainmenu_anim_calcium_fulltop_pos = (90.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-315.0, 240.0)
			gor_anim_pos = (-272.0, -20.0)
			gor_anim_scale = (1.06, 1.06)
			bgrock_anim_pos = (-130.0, -180.0)
			axestone_anim_pos = (310.0, 92.0)
			ampzilla_anim_pos = (12.0, -170.0)
			mainmenu_anim_calcium_fulltop_pos = (78.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-309.0, 233.0)
			gor_anim_pos = (-255.0, -20.0)
			gor_anim_scale = (1.05, 1.05)
			bgrock_anim_pos = (-130.0, -195.0)
			axestone_anim_pos = (330.0, 75.0)
			ampzilla_anim_pos = (22.0, -160.0)
			mainmenu_anim_calcium_fulltop_pos = (85.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-313.0, 233.0)
			gor_anim_pos = (-271.0, -20.0)
			gor_anim_scale = (1.01, 1.01)
			bgrock_anim_pos = (-150.0, -178.0)
			axestone_anim_pos = (310.0, 90.0)
			ampzilla_anim_pos = (18.0, -179.0)
			mainmenu_anim_calcium_fulltop_pos = (93.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops {
			chain_anim_pos = (-309.0, 210.0)
			gor_anim_pos = (-269.0, -20.0)
			gor_anim_scale = (1.0, 1.0)
			bgrock_anim_pos = (-130.0, -186.0)
			axestone_anim_pos = (317.0, 82.0)
			ampzilla_anim_pos = <pos>
			mainmenu_anim_calcium_fulltop_pos = (86.0, 100.0)
			time = 0.01
		}
		options_videos_menu_id :se_waitprops
		repeat 1
	endif
endscript

script ui_bonus_videos_anim_out 
	printf \{channel = blah
		qs(0x0d1a424d)}
	if screenelementexists \{id = options_videos_menu_id}
		begin
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-309.0, 210.0)
			gor_anim_pos = (-269.0, -20.0)
			gor_anim_scale = (1.0, 1.0)
			bgrock_anim_pos = (-130.0, -186.0)
			axestone_anim_pos = (317.0, 82.0)
			ampzilla_anim_pos = (18.0, -176.0)
			mainmenu_anim_calcium_fulltop_pos = (86.0, 100.0)}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-315.0, 233.0)
			gor_anim_pos = (-272.0, -20.0)
			gor_anim_scale = (1.03, 1.03)
			bgrock_anim_pos = (-155.0, -178.0)
			axestone_anim_pos = (330.0, 72.0)
			ampzilla_anim_pos = (10.0, -169.0)
			mainmenu_anim_calcium_fulltop_pos = (79.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-305.0, 233.0)
			gor_anim_pos = (-260.0, -20.0)
			bgrock_anim_pos = (-130.0, -195.0)
			axestone_anim_pos = (310.0, 82.0)
			ampzilla_anim_pos = (25.0, -180.0)
			mainmenu_anim_calcium_fulltop_pos = (90.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-315.0, 240.0)
			gor_anim_pos = (-272.0, -20.0)
			gor_anim_scale = (1.06, 1.06)
			bgrock_anim_pos = (-130.0, -180.0)
			axestone_anim_pos = (310.0, 92.0)
			ampzilla_anim_pos = (12.0, -170.0)
			mainmenu_anim_calcium_fulltop_pos = (78.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-309.0, 233.0)
			gor_anim_pos = (-255.0, -20.0)
			gor_anim_scale = (1.05, 1.05)
			bgrock_anim_pos = (-130.0, -195.0)
			axestone_anim_pos = (330.0, 75.0)
			ampzilla_anim_pos = (22.0, -160.0)
			mainmenu_anim_calcium_fulltop_pos = (85.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-313.0, 233.0)
			gor_anim_pos = (-271.0, -20.0)
			gor_anim_scale = (1.01, 1.01)
			bgrock_anim_pos = (-150.0, -178.0)
			axestone_anim_pos = (310.0, 90.0)
			ampzilla_anim_pos = (18.0, -179.0)
			mainmenu_anim_calcium_fulltop_pos = (93.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		options_videos_menu_id :se_setprops \{chain_anim_pos = (-309.0, 210.0)
			gor_anim_pos = (-269.0, -20.0)
			gor_anim_scale = (1.0, 1.0)
			bgrock_anim_pos = (-130.0, -186.0)
			axestone_anim_pos = (317.0, 82.0)
			ampzilla_anim_pos = (18.0, -176.0)
			mainmenu_anim_calcium_fulltop_pos = (86.0, 100.0)
			time = 0.01}
		options_videos_menu_id :se_waitprops
		repeat 1
	endif
endscript
