
script songlist_create \{locked = false
		exclusive_device = -1
		list_name = !q1768515945
		mode = !q1768515945}
	change g_songlist_sort_index = ($g_songlist_sort_indexes.<mode>)
	setmenuautorepeattimes ((0.3, 0.0) + (($g_songlist_scroll_speed) * (0.0, 1.0)))
	uistack_createboundscreenelement \{parent = root_window
		id = songlist
		type = descinterface
		desc = 'songlist'
		alpha = 0.0}
	songlist :obj_spawnscriptlater attempt_to_add_friend_feed params = {menu = songlist parent_id = songlist songlist_mode = <mode>}
	if (<mode> = music_store)
		if isps3
			getdisplaysettings
			if (<height> >= 720)
				songlist :se_setprops \{music_store_playstation_logo_texture = playstation_logo_hd720
					music_store_playstation_logo_scale = 1.0
					music_store_playstation_logo_dims = (180.0, 40.0)}
			else
				songlist :se_setprops \{music_store_playstation_logo_texture = playstation_logo_sd
					music_store_playstation_logo_scale = 1.5
					music_store_playstation_logo_dims = (136.0, 32.0)}
			endif
		endif
		songlist :se_setprops \{songlist_bg_illo_alpha = 0.0
			music_store_bg_illo_alpha = 1.0}
	endif
	if scriptexists \{audio_crowd_play_swells_during_stats_screen}
		killspawnedscript \{name = audio_crowd_play_swells_during_stats_screen}
	endif
	if issoundeventplaying \{surge_during_stats_screen}
		stopsoundevent \{surge_during_stats_screen
			fade_time = 1.5
			fade_type = linear}
	endif
	spawnscriptnow \{audio_crowd_silence_front_end}
	if songlist :desc_resolvealias \{name = alias_generic_scrollbar_wgt}
		assignalias id = <resolved_id> alias = songlist_scrollbar_wgt
		generic_scrollbar_wgt_initialize \{id = songlist_scrollbar_wgt}
	else
		scriptassert \{qs(0x7631f46d)}
	endif
	if songlist :desc_resolvealias \{name = alias_songlist_vmenu}
		printf \{qs(0xc1a5acd2)}
		assignalias id = <resolved_id> alias = current_menu
		controller = ($primary_controller)
		if (<mode> = practice || <mode> = leaderboard)
			controller = <device_num>
		endif
		if (<controller> = -1)
			if gotparam \{device_num}
				controller = <device_num>
			else
				controller = ($primary_controller)
			endif
		endif
		song_breakdown_check_bot_play
		if NOT (<bot_play> = 0)
			controller = ($primary_controller)
		endif
		if (<controller> = -1)
			scriptassert \{qs(0x6c9db444)}
		endif
		if (<exclusive_device> = -1 || <bot_play> > 0)
			exclusive_device = <controller>
		endif
		<resolved_id> :se_setprops exclusive_device = <exclusive_device>
		songlist_component :settags {
			savegame_device = <controller>
			exclusive_device = <exclusive_device>
		}
		get_savegame_from_controller controller = <controller>
		getglobaltags savegame = <savegame> songlist_options params = {show_more_info show_ghtunes 0x1d79954f}
		if demobuild
			<show_ghtunes> = 0
		endif
		change g_songlist_show_more_info = <show_more_info>
		change g_songlist_show_ghtunes = <show_ghtunes>
		if NOT gotparam \{0x1d79954f}
			0x1d79954f = 0
		endif
		change 0x42a06e7f = <0x1d79954f>
		if NOT (<mode> = music_store)
			if allow_show_ghtunes_toggle
				if (<show_ghtunes> = 0)
					filterspec = [
						{
							key = song_source
							union_list = [jam]
							comparator = not_equal
						}
					]
					songlist_change_filterspec filterspec = <filterspec>
				endif
			endif
		endif
	else
		scriptassert \{qs(0xd78eb9f9)}
	endif
	if songlist :desc_resolvealias \{name = alias_songlist_smenu}
		assignalias id = <resolved_id> alias = songlist_smenu
	else
		scriptassert \{qs(0xe0d6cecf)}
	endif
	if songlist :desc_resolvealias \{name = alias_songlist_detail_cont}
		assignalias id = <resolved_id> alias = songlist_detail_cont
	else
		scriptassert \{qs(0xf7d498a7)}
	endif
	if NOT (<mode> = music_store || <mode> = import)
		if (<mode> = practice || <mode> = leaderboard)
			player_num = 1
		else
			get_local_in_game_player_num_from_controller controller_index = <exclusive_device>
		endif
		if issingleplayergame
			getplayerinfo <player_num> part
			getplayerinfo <player_num> difficulty
		else
			<part> = band
			get_highest_difficulty
			<difficulty> = <highest_difficulty>
		endif
		get_difficulty_text_nl difficulty = <difficulty>
		formattext checksumname = difficulty_icon 'icon_difficulty_%i' i = <difficulty_text_nl>
		formattext checksumname = instrument_out 'icon_%i_out' i = ($instrument_list.<part>.text_nl)
		formattext checksumname = instrument_fill 'icon_%i_fill' i = ($instrument_list.<part>.text_nl)
		out_icon_alpha = 1
		band_icon_alpha = 0
		difficulty_alpha = 1
		if (<mode> = leaderboard)
			instrument_text_nl = ($current_leaderboard_instrument)
			if (<instrument_text_nl> = 'band' || <instrument_text_nl> = 'altband')
				out_icon_alpha = 0
				band_icon_alpha = 1
			else
				if (<instrument_text_nl> = 'backup')
					instrument_text_nl = 'bass'
				elseif (<instrument_text_nl> = 'drums')
					instrument_text_nl = 'drum'
				elseif (<instrument_text_nl> = 'mic')
					instrument_text_nl = 'vocals'
				endif
				formattext checksumname = instrument_out 'icon_%i_out' i = <instrument_text_nl>
				formattext checksumname = instrument_fill 'icon_%i_fill' i = <instrument_text_nl>
			endif
			difficulty_alpha = 0
		endif
	endif
	songlist_create_detail_desc mode = <mode>
	<event_handlers> = [
		{pad_back ui_sfx params = {mode = <mode> menustate = setlist uitype = back}}
		{pad_back generic_blocking_execute_script params = {pad_script = songlist_back}}
	]
	if (<mode> = music_store || <mode> = import)
		<content_source> = marketplace
		<list_name> = marketplace
		songlist_component :settags \{music_store_mode = hub
			music_store_seek_override = true
			visited_band_hub = 0
			tab_enabled = 0}
	else
		if NOT demobuild
			<sort_option> = {pad_l1 songlist_go_to_options params = {type = sort}}
			addarrayelement array = <event_handlers> element = <sort_option>
			<event_handlers> = <array>
		endif
		<tab_enabled> = 0
		if songlist_allow_music_store_toggling controller = <controller> mode = <mode>
			<tab_option> = {pad_btn_left songlist_go_to_music_store_tab}
			addarrayelement array = <event_handlers> element = <tab_option>
			<event_handlers> = <array>
			<tab_enabled> = 1
		endif
		songlist_component :settags {
			tab_enabled = <tab_enabled>
		}
		<content_source> = local_song_list
	endif
	current_menu :se_setprops {
		event_handlers = <event_handlers>
		replace_handlers
	}
	current_menu :se_setprops \{block_events}
	getterritory
	songlist_component :membfunc_songlist_uistack_initialize
	songlist_component :membfunc_songlist_uistack_setmode mode = <mode>
	songlist_component :membfunc_songlist_uistack_setlistname list_name = <list_name>
	songlist_component :settags {
		list_dirty = false
		initial_built = false
		locked = <locked>
		content_source = <content_source>
		territory = <territory>
		controller = <controller>
		jump_enabled = 1
	}
	songlist_init_music_store
	gamemode_gettype
	if NOT (<mode> = music_store || <mode> = import || <type> = freeplay)
		if (<mode> = leaderboard)
			songlist_determine_leaderboard_instrument_setup
		else
			songlist_determine_band_instrument_setup
		endif
		songlist_component :settags {
			band_instrument_setup = <band_instrument_setup>
		}
	endif
	songlist_update_ui
	songlist_scrollbar_wgt :se_setprops \{scroll_thumb_pos = (0.0, 0.0)}
	if ininternetmode
		net_songlist_leader_text
	endif
	if (<mode> = playlist)
		songlist_remove_unavailable_songs_from_playlist
	endif
endscript

script songlist_create_detail_desc \{mode = !q1768515945}
	if screenelementexists \{id = songlist_detail}
		destroyscreenelement \{id = songlist_detail}
	endif
	if (<mode> = music_store || <mode> = import)
		createscreenelement \{type = descinterface
			desc = 'songlist_detail_music_store'
			id = songlist_detail
			parent = songlist_detail_cont
			alpha = 0.0
			pos = (13.0, 15.0)}
		songlist_detail :se_setprops {
			patch_req_message_text = ($g_music_store_patch_req_message)
		}
		songlist_music_store_assign_text_aliases
	else
		if NOT issingleplayergame
			out_icon_alpha = 0
			band_icon_alpha = 1
		endif
		createscreenelement {
			type = descinterface
			desc = 'songlist_detail'
			id = songlist_detail
			parent = songlist_detail_cont
			alpha = 0.0
			songlist_detail_difficulty_icon_texture = <difficulty_icon>
			songlist_detail_difficulty_icon_alpha = <difficulty_alpha>
			songlist_detail_instrument_icon_out_texture = <instrument_out>
			songlist_detail_instrument_icon_fill_texture = <instrument_fill>
			songlist_detail_instrument_icon_out_alpha = <out_icon_alpha>
			songlist_detail_instrument_icon_fill_alpha = <out_icon_alpha>
			songlist_detail_instrument_icon_band_alpha = <band_icon_alpha>
		}
		if (<mode> = playlist)
			<id> :se_setprops alpha = 1.0
			<id> :se_setprops songlist_detail_mini_playlistt_text_alpha = 1.0
		endif
		if ($g_songlist_show_more_info = 1)
			songlist_detail :se_setprops \{songlist_detail_frame_1_cont_alpha = 0.0
				songlist_detail_frame_2_cont_alpha = 1.0}
		endif
		if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_stars_full_vmenu}
			assignalias id = <resolved_id> alias = songlist_detail_stars_full_vmenu
		else
			scriptassert \{qs(0x8030f42e)}
		endif
		if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_stars_empty_vmenu}
			assignalias id = <resolved_id> alias = songlist_detail_stars_empty_vmenu
		else
			scriptassert \{qs(0xc21dd60f)}
		endif
		if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_diff_inst_cont}
			assignalias id = <resolved_id> alias = songlist_detail_diff_inst_cont
		else
			scriptassert \{qs(0xa4036096)}
		endif
		if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_mini_playlist_vmenu}
			assignalias id = <resolved_id> alias = songlist_detail_mini_playlist_vmenu
		else
			scriptassert \{qs(0xbd105ffe)}
		endif
		if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_more_info_rows}
			assignalias id = <resolved_id> alias = songlist_detail_more_info_rows
		else
			scriptassert \{qs(0x17e03108)}
		endif
		if NOT screenelementexists \{id = songlist_detail_playlist}
			createscreenelement \{type = descinterface
				desc = 'songlist_detail_playlist'
				id = songlist_detail_playlist
				parent = songlist_detail_cont
				alpha = 0.0}
			if songlist_detail_playlist :desc_resolvealias \{name = alias_songlist_detail_playlist_vmenu}
				assignalias id = <resolved_id> alias = songlist_detail_playlist_vmenu
			else
				scriptassert \{qs(0x09d998d8)}
			endif
		endif
	endif
	if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_difficulty_guitar_vmenu}
		assignalias id = <resolved_id> alias = songlist_detail_difficulty_guitar_vmenu
	else
		scriptassert \{qs(0xd483e01c)}
	endif
	if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_difficulty_bass_vmenu}
		assignalias id = <resolved_id> alias = songlist_detail_difficulty_bass_vmenu
	else
		scriptassert \{qs(0xab2daa8c)}
	endif
	if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_difficulty_drums_vmenu}
		assignalias id = <resolved_id> alias = songlist_detail_difficulty_drums_vmenu
	else
		scriptassert \{qs(0x3bfbfa01)}
	endif
	if songlist_detail :desc_resolvealias \{name = alias_songlist_detail_difficulty_vocals_vmenu}
		assignalias id = <resolved_id> alias = songlist_detail_difficulty_vocals_vmenu
	else
		scriptassert \{qs(0xb86d4f96)}
	endif
	songlist_detail :settags \{prev_guitar_diff_rate = 0
		prev_bass_diff_rate = 0
		prev_drums_diff_rate = 0
		prev_vocals_diff_rate = 0
		prev_stars = 0}
endscript

script songlist_music_store_assign_text_aliases \{desc = songlist_detail}
	if screenelementexists id = <desc>
		if <desc> :desc_resolvealias name = alias_songlist_detail_album_text
			assignalias id = <resolved_id> alias = songlist_detail_album_text
		else
			scriptassert qs(0x9d4d64f5) d = <desc>
		endif
		if <desc> :desc_resolvealias name = alias_songlist_detail_genre_text
			assignalias id = <resolved_id> alias = songlist_detail_genre_text
		else
			scriptassert qs(0xae6b0c76) d = <desc>
		endif
		if <desc> :desc_resolvealias name = alias_songlist_detail_duration_text
			assignalias id = <resolved_id> alias = songlist_detail_duration_text
		else
			scriptassert qs(0x89329df5) d = <desc>
		endif
		if (<desc> = songlist_detail)
			if <desc> :desc_resolvealias name = alias_songlist_detail_songs_album_text
				assignalias id = <resolved_id> alias = songlist_detail_songs_album_text
			else
				scriptassert qs(0xe320c1cf) d = <desc>
			endif
			if <desc> :desc_resolvealias name = alias_songlist_detail_songs_genre_text
				assignalias id = <resolved_id> alias = songlist_detail_songs_genre_text
			else
				scriptassert qs(0x9f269a27) d = <desc>
			endif
			if <desc> :desc_resolvealias name = alias_songlist_detail_songs_duration_text
				assignalias id = <resolved_id> alias = songlist_detail_songs_duration_text
			else
				scriptassert qs(0x5c719b50) d = <desc>
			endif
		endif
	endif
endscript

script songlist_remove_unavailable_songs_from_playlist 
	songlist_options_check_relevance
	if (<list_relevant> = false)
		change current_playlist = <override_array>
		change \{g_songlist_warning_active = 1}
		if screenelementexists \{id = current_menu}
			launchevent \{type = unfocus
				target = current_menu}
			current_menu :se_setprops \{block_events}
		endif
		getnumplayersingame
		if (<num_players> > 1)
			formattext \{textname = body_text
				qs(0x44218325)}
		else
			formattext \{textname = body_text
				qs(0xfbc789d4)}
		endif
		songlist_component :getsingletag \{exclusive_device}
		create_dialog_box {
			heading_text = qs(0xaa163738)
			body_text = <body_text>
			player_device = <exclusive_device>
			options = [
				{
					func = songlist_destroy_dialog_box
					text = qs(0x0e41fe46)
				}
			]
		}
	endif
endscript

script songlist_destroy_dialog_box 
	destroy_dialog_box
	clean_up_user_control_helpers
	songlist_component :membfunc_songlist_uistack_getmode
	songlist_create_default_user_control_helpers mode = <mode>
	change \{g_songlist_warning_active = 0}
	if NOT is_current_playlist_empty
		if NOT ininternetmode
			songlist_allow_continue
		endif
	endif
	if screenelementexists \{id = current_menu}
		current_menu :se_setprops \{unblock_events}
		current_menu :getsingletag \{tag_selected_index}
		launchevent \{type = unfocus
			target = current_menu}
		launchevent type = focus target = current_menu data = {child_index = <tag_selected_index>}
	endif
endscript

script songlist_calculate_playlist_duration 
	getarraysize \{$current_playlist}
	if (<array_size> > 0)
		<i> = 0
		<total_seconds> = 0
		begin
		<song_not_found> = false
		get_ui_song_struct_items song = (($current_playlist) [<i>])
		if (<song_not_found> = false)
			<total_seconds> = (<total_seconds> + (<ui_struct>.song_duration))
		endif
		<i> = (<i> + 1)
		repeat <array_size>
		<time_array> = []
		addarrayelement array = <time_array> element = <total_seconds>
		rr_get_time_string data = <array>
		songlist_detail_playlist :se_setprops {
			songlist_detail_playlist_duration_text = <data_text>
		}
	else
		songlist_detail_playlist :se_setprops \{songlist_detail_playlist_duration_text = qs(0x369c70d7)}
	endif
endscript

script songlist_update_ui 
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = music_store)
		<title> = ($g_music_store_title)
	elseif (<mode> = import)
		offering = ($downloaded_offerings [($downloaded_offerings_index)])
		<title> = (<offering>.display_name)
		import_esrb_label_alpha = 0.0
		if NOT ((<offering>.rating) = none)
			import_esrb_label_alpha = 1.0
		endif
		songlist :se_setprops {
			music_store_title_alpha = 0.0
			songlist_sticky_header_alpha = 1.0
			songlist_title_text_alpha = 1.0
			import_esrb_label_alpha = <import_esrb_label_alpha>
		}
	else
		<title> = ($g_songlist_modes.<mode>.title)
	endif
	songlist :se_setprops {
		songlist_title_text_text = <title>
		songlist_sort_property_dims = (10.0, 32.0)
		songlist_sort_property_text = (($g_songlist_sort_array [($g_songlist_sort_index)]).text)
	}
	<event_handlers> = [
		{pad_up songlist_scroll_up}
		{pad_down songlist_scroll_down}
	]
	if NOT (<mode> = music_store || <mode> = import)
		if NOT ininternetmode
			if NOT demobuild
				gamemode_gettype
				if ((<type> = career) || (<mode> = leaderboard) || (<mode> = practice))
					<mp_option> = {pad_btn_left songlist_toggle_more_info}
					addarrayelement array = <event_handlers> element = <mp_option>
					<event_handlers> = <array>
				endif
			endif
		endif
	endif
	current_menu :se_setprops {
		event_handlers = <event_handlers>
		replace_handlers
	}
	if (<mode> = music_store)
		songlist_component :getsingletag \{visited_band_hub}
		if (<visited_band_hub> = 1)
			clean_up_user_control_helpers
			songlist_create_default_user_control_helpers mode = <mode>
			songlist :se_setprops \{songlist_sticky_header_alpha = 1.0
				songlist_title_text_alpha = 1.0}
			if isps3
				songlist :se_setprops \{music_store_playstation_logo_alpha = 1.0}
			endif
		endif
	endif
endscript

script songlist_toggle_more_info 
	if ($g_songlist_show_more_info = 0)
		change \{g_songlist_show_more_info = 1}
		user_control_helper_change_text \{button = blue
			text = qs(0x0d424947)}
	else
		change \{g_songlist_show_more_info = 0}
		user_control_helper_change_text \{button = blue
			text = qs(0x6644ffc7)}
	endif
	songlist_detail :obj_spawnscriptnow \{songlist_detail_transition
		params = {
			desc = songlist_detail
			force_transition
			fade_time = 0
		}}
endscript

script songlist_create_playlist 
	current_menu :se_setprops \{block_events}
	audio_ui_play_songlist_playlist_switch_sfx
	songlist_component :membfunc_songlist_uistack_setmode \{mode = playlist}
	if NOT gotparam \{no_detail_transition}
		songlist_detail_transition \{desc = songlist_detail}
	endif
	audio_ui_menu_music_off
	if NOT gotparam \{no_refresh}
		if gotparam \{no_focus}
			songlist_refresh_menus \{no_focus = 1}
		else
			songlist_refresh_menus
		endif
	endif
	current_menu :se_setprops \{unblock_events}
endscript

script songlist_create_play_song 
	current_menu :se_setprops \{block_events}
	audio_ui_play_songlist_playlist_switch_sfx
	songlist_component :membfunc_songlist_uistack_setmode \{mode = play_song}
	if NOT gotparam \{no_detail_transition}
		songlist_detail_transition \{desc = songlist_detail}
	endif
	if NOT gotparam \{no_refresh}
		if gotparam \{no_focus}
			songlist_refresh_menus \{no_focus = 1}
		else
			songlist_refresh_menus
		endif
	endif
	current_menu :se_setprops \{unblock_events}
endscript

script songlist_go_to_options \{type = !q1768515945}
	current_menu :se_setprops \{block_events}
	if screenelementexists \{id = songlist_options}
		return
	endif
	if scriptisrunning \{songlist_continue}
		return
	endif
	wait \{1
		gameframe}
	songlist_component :getsingletag \{exclusive_device}
	songlist_component :getsingletag \{savegame_device}
	if gotparam \{exclusive_device}
		ui_sfx \{menustate = setlist
			uitype = select}
		if (<type> = main)
			generic_event_choose {
				state = uistate_songlist_options
				data = {
					is_popup
					type = <type>
					exclusive_device = <exclusive_device>
					savegame_device = <savegame_device>
					song_item_id = <song_item_id>
					song_options_struct = <song_options_struct>
				}
			}
		elseif (<type> = music_store)
			generic_event_choose {
				state = uistate_songlist_options
				data = {
					is_popup
					type = <type>
					exclusive_device = <exclusive_device>
					savegame_device = <savegame_device>
					purchase_struct = <purchase_struct>
				}
			}
		else
			generic_event_choose {
				state = uistate_songlist_options
				data = {
					is_popup
					type = <type>
					exclusive_device = <exclusive_device>
					savegame_device = <savegame_device>
				}
			}
		endif
	else
		scriptassert \{qs(0x098ea72c)}
	endif
endscript

script songlist_music_store_go_to_hub 
	current_menu :se_setprops \{alpha = 0.0}
	songlist_component :getsingletag \{territory}
	if (<territory> != territory_us)
		<esrb_notice_alpha> = 0.0
	else
		<esrb_notice_alpha> = 1.0
	endif
	songlist :se_setprops {
		songlist_sticky_header_alpha = 0.0
		songlist_subheader_cont_alpha = 0.0
		songlist_sort_cont_alpha = 0.0
		songlist_title_text_alpha = 0.0
		music_store_playstation_logo_alpha = 0.0
		pa_esrb_label_alpha = 0.0
		esrb_notice_alpha = <esrb_notice_alpha>
	}
	songlist_component :membfunc_songlist_uistack_setstickyheaderupdate \{update = 0}
	songlist_component :membfunc_songlist_uistack_initialize
	songlist_component :getsingletag \{exclusive_device}
	generic_event_choose no_sound state = uistate_music_store_hub data = {is_popup exclusive_device = <exclusive_device>}
endscript

script songlist_pre_build 
	songlist_component :getsingletag \{content_source}
	songlist_component :membfunc_songlist_uistack_getmode
	songlist_component :membfunc_songlist_uistack_getlistname
	songlist_component :membfunc_songlist_uistack_getlistregistered
	if (<list_registered> = 0)
		if (<mode> = import)
			if NOT import_create_details_content_source list_name = <list_name>
				return
			endif
		else
			contentmanfunc func = register_content_source name = <list_name> type = <content_source>
		endif
		songlist_component :membfunc_songlist_uistack_setlistregistered \{list_registered = 1}
	endif
	songlist_component :settags \{list_dirty = true}
	<sortspec> = {
		key = (($g_songlist_sort_array [($g_songlist_sort_index)]).key)
		alt_key = (($g_songlist_sort_array [($g_songlist_sort_index)]).alt_key)
		(($g_songlist_sort_array [($g_songlist_sort_index)]).progression)
	}
	songlist :obj_spawnscriptnow songlist_request_initial_page_when_ready params = {sortspec = <sortspec>}
endscript

script songlist_request_initial_page_when_ready 
	setspawninstancelimits \{max = 1
		management = kill_oldest}
	songlist_component :membfunc_songlist_uistack_getmode
	songlist_component :membfunc_songlist_uistack_getlistname
	begin
	if contentmanfunc func = is_ready name = <list_name>
		if (<mode> = music_store || <mode> = import)
			destroy_dialog_box
			songlist_component :getsingletag \{music_store_mode}
			if gotparam \{music_store_mode}
				if (<music_store_mode> = songs)
					songlist_music_store_allow_sorting
				endif
			endif
		endif
		songlist_component :membfunc_songlist_uistack_getfilterspec
		<content_man_params> = {
			func = request_page
			name = <list_name>
			current_page
			callback = songlist_callback_have_page_find_data_range
			sortspec = <sortspec>
			filterspec = <filterspec>
			invert_filterspec = <invert_filterspec>
		}
		if NOT (($g_songlist_current_pivot) = null)
			<content_man_params> = {
				<content_man_params>
				seek = ($g_songlist_current_pivot)
			}
		elseif NOT (($g_songlist_seek_first) = null)
			<content_man_params> = {
				<content_man_params>
				seek_first = ($g_songlist_seek_first)
			}
		endif
		if ($g_songlist_debug_output = 1)
			printf \{channel = songlist
				qs(0x128a6a04)}
			printf \{channel = songlist
				qs(0xe76beaa4)}
			printstruct channel = songlist <...>
			printf \{channel = songlist
				qs(0xe76beaa4)}
		endif
		contentmanfunc {
			<content_man_params>
		}
		return
	endif
	wait \{0.1
		seconds}
	repeat 200
	if (<mode> = music_store || <mode> = import)
		destroy_dialog_box
	endif
	if (<mode> != music_store)
		scriptassert \{qs(0x1bbd378e)}
	endif
	create_dialog_box \{no_background
		heading_text = qs(0xaa163738)
		body_text = qs(0xa47088ec)
		options = [
			{
				func = songlist_marketplace_timed_out_go_back
				text = qs(0x0e41fe46)
			}
		]}
endscript

script songlist_marketplace_timed_out_go_back 
	destroy_dialog_box
	change \{g_marketplace_responding_to_error = 0}
	if ui_event_exists_in_stack \{name = 'band_lobby'}
		<back_state> = uistate_band_lobby
	else
		<back_state> = uistate_mainmenu
	endif
	ui_event event = menu_back data = {state = <back_state>}
endscript

script songlist_callback_have_page_find_data_range 
	if NOT screenelementexists \{id = songlist}
		return
	endif
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = music_store)
		songlist_component :getsingletag \{music_store_seek_override}
		if (<music_store_seek_override> = true)
			<seek_index> = 0
			<seek_checksum> = null
			songlist_component :settags \{music_store_seek_override = false}
		endif
	endif
	generic_scrollbar_wgt_set_resolution id = songlist_scrollbar_wgt num_elements = <content_size>
	songlist_component :membfunc_songlist_uistack_setlistindex list_index = <seek_index> seek_checksum = <seek_checksum>
	songlist_component :membfunc_songlist_uistack_setlistpagesize list_page_size = <page_size>
	songlist_component :settags \{list_dirty = false}
	generic_scrollbar_wgt_update_thumb_pos id = songlist_scrollbar_wgt dir = down count = <seek_index>
	songlist_scrollbar_wgt :se_setprops \{alpha = 1.0}
	change \{g_songlist_current_pivot = null}
	change \{g_songlist_seek_first = null}
	formattext textname = num_songs qs(0xc31d83ea) i = <content_size>
	songlist :se_setprops songlist_songs_available_num_text = <num_songs>
	if (<content_size> = 1)
		if (<mode> = music_store)
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0xd20d2af6)}
		else
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0x7b899ac6)}
		endif
	else
		if (<mode> = music_store)
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0x08cb5377)}
		else
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0x1cec7f8c)}
		endif
	endif
	if demobuild
		formattext textname = demo_songs qs(0x862202b8) a = <content_size> b = 85
		songlist :se_setprops songlist_songs_available_num_text = <demo_songs>
	endif
	<start_index> = <seek_index>
	songlist_component :membfunc_songlist_uistack_getmaxcontentsize
	if (<page_size> = 0)
		songlist_detail :se_setprops \{alpha = 0.0}
		songlist_disallow_continue
		if ($g_songlist_warning_active = 0)
			current_menu :se_setprops \{unblock_events}
			launchevent \{type = unfocus
				target = current_menu}
			launchevent \{type = focus
				target = current_menu}
		endif
		songlist_component :membfunc_songlist_uistack_setrangearray \{range_array = [
			]
			offset = 0}
		songlist_create_default_user_control_helpers mode = <mode> no_options = 1
		return
	elseif (<page_size> <= <max_content_size>)
		<start_index> = 0
		<end_index> = (<page_size> - 1)
	else
		<end_index> = ((<max_content_size> - 1) + <seek_index>)
		if (<end_index> >= <page_size>)
			<end_index> = (<page_size> - 1)
			<start_index> = ((<end_index> - <max_content_size>) + 1)
		endif
	endif
	songlist_component :membfunc_songlist_uistack_setlisttop list_top = <start_index>
	songlist_component :membfunc_songlist_uistack_setlistbottom list_bottom = <end_index>
	songlist_component :membfunc_songlist_uistack_updateheaderarray
	songlist_component :membfunc_songlist_uistack_getlistname
	if ($g_songlist_debug_output = 1)
		printf \{channel = songlist
			qs(0xf2859875)}
		printf \{channel = songlist
			qs(0xe76beaa4)}
		printstruct channel = songlist <...>
		printf \{channel = songlist
			qs(0xe76beaa4)}
	endif
	contentmanfunc {
		func = request_data
		name = <list_name>
		start_index = <start_index>
		end_index = <end_index>
		callback = songlist_callback_data_range
	}
endscript

script songlist_callback_data_range 
	if NOT screenelementexists \{id = songlist}
		return
	endif
	songlist_component :getsingletag \{initial_built}
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = music_store)
		previewassetcache \{func = cancel_all_requests}
		music_store_preload_album_covers list = <range>
		music_store_preload_preview_music list = <range>
	endif
	if ($g_songlist_debug_output = 1)
		printf \{channel = songlist
			qs(0x70375fa7)}
		printf \{channel = songlist
			qs(0xe76beaa4)}
		printstruct channel = songlist <...>
		printf \{channel = songlist
			qs(0xe76beaa4)}
	endif
	if (<initial_built> = false)
		songlist_component :membfunc_songlist_uistack_setrangearray range_array = <range> offset = 0
		if NOT (<mode> = play_song)
			audio_ui_menu_music_off
		endif
		songlist_build
		songlist_component :settags \{initial_built = true}
		if NOT (<mode> = music_store)
			songlist_component :membfunc_songlist_uistack_setstickyheaderupdate \{update = 1}
		endif
	else
		songlist_component :membfunc_songlist_uistack_getscrollresult
		if (<scroll_result> = request_data_range_down)
			songlist_component :membfunc_songlist_uistack_setrangearray range_array = <range> update_sticky_header = 0 offset = 1
			if songlist_component :membfunc_songlist_uistack_isitemanheader
				songlist_component :membfunc_songlist_uistack_decrementlistindex
				songlist_insert_item_bottom \{focus = 0}
				onexitrun \{songlist_scroll_down
					params = {
						dont_update_slider = 1
					}}
			else
				songlist_insert_item_bottom
			endif
		elseif (<scroll_result> = request_data_range_up)
			songlist_component :membfunc_songlist_uistack_setrangearray range_array = <range> update_sticky_header = 0 offset = -1
			if songlist_component :membfunc_songlist_uistack_isitemanheader
				songlist_component :membfunc_songlist_uistack_incrementlistindex
				songlist_insert_item_top \{focus = 0}
				onexitrun \{songlist_scroll_up
					params = {
						dont_update_slider = 1
					}}
			else
				songlist_insert_item_top
			endif
		else
			songlist_component :membfunc_songlist_uistack_setrangearray range_array = <range>
		endif
	endif
	if songlist_component :getsingletag \{need_unavailable_dialog}
		if (<need_unavailable_dialog> = 1)
			songlist_component :settags \{need_unavailable_dialog = 0}
			generic_event_choose \{state = uistate_songlist_popup
				data = {
					is_popup
					exclusive_device = 0
				}}
		endif
	endif
endscript

script songlist_insert_item_top \{focus = 1}
	<index> = 0
	songlist_component :membfunc_songlist_uistack_getrangestruct
	getscreenelementchildren \{id = current_menu}
	if gotparam \{children}
		getarraysize <children>
		<index> = (<array_size> - 1)
		songlist_component :membfunc_songlist_uistack_getmaxmenuelements
		if (<array_size> >= <max_menu_elements>)
			destroyscreenelement id = (<children> [<index>])
		endif
	endif
	if structurecontains structure = <range_struct> header
		songlist_add_header {
			header_struct = <range_struct>
		}
	else
		songlist_add_item {
			ui_struct = <range_struct>
		}
	endif
	current_menu :menu_setitemindex index = <index> newindex = 0
	if (<focus> = 1)
		if ($g_songlist_options_back_requires_unblock = 1)
			change \{g_songlist_options_back_requires_unblock = 0}
			current_menu :se_setprops \{unblock_events}
		endif
		launchevent \{type = unfocus
			target = current_menu}
		launchevent \{type = focus
			target = current_menu
			data = {
				child_index = 0
			}}
	endif
endscript

script songlist_insert_item_bottom \{focus = 1}
	songlist_component :membfunc_songlist_uistack_getrangestruct
	getscreenelementchildren \{id = current_menu}
	destroyscreenelement id = (<children> [0])
	if structurecontains structure = <range_struct> header
		songlist_add_header {
			header_struct = <range_struct>
		}
	else
		songlist_add_item {
			ui_struct = <range_struct>
		}
	endif
	if (<focus> = 1)
		if ($g_songlist_options_back_requires_unblock = 1)
			change \{g_songlist_options_back_requires_unblock = 0}
			current_menu :se_setprops \{unblock_events}
		endif
		songlist_component :membfunc_songlist_uistack_getmaxmenuelements
		launchevent \{type = unfocus
			target = current_menu}
		launchevent type = focus target = current_menu data = {child_index = (<max_menu_elements> - 1)}
	endif
endscript

script songlist_build 
	songlist_component :membfunc_songlist_uistack_getmode
	songlist_component :getsingletag \{visited_band_hub}
	if (<mode> = music_store)
		if (<visited_band_hub> = 0)
			songlist_component :settags \{visited_band_hub = 1}
			songlist :se_setprops \{alpha = 1.0}
			songlist_music_store_go_to_hub
			return
		endif
	endif
	songlist_component :membfunc_songlist_uistack_getmastervectorsize
	if (<master_vector_size> > 0)
		songlist_component :membfunc_songlist_uistack_getmaxmenuelements
		if (<master_vector_size> < <max_menu_elements>)
			<repeat_amt> = <master_vector_size>
		else
			<repeat_amt> = <max_menu_elements>
		endif
		<i> = 0
		begin
		songlist_component :membfunc_songlist_uistack_getrangestruct index = <i>
		if structurecontains structure = <range_struct> header
			songlist_add_header {
				header_struct = <range_struct>
			}
		else
			songlist_add_item {
				ui_struct = (<range_struct>)
			}
		endif
		<i> = (<i> + 1)
		repeat <repeat_amt>
	endif
	songlist_component :membfunc_songlist_uistack_postrefresh
	clean_up_user_control_helpers
	songlist_create_default_user_control_helpers mode = <mode>
	songlist :se_setprops \{alpha = 1.0}
	if (<focus> = true)
		if ($g_songlist_warning_active = 0)
			current_menu :se_setprops \{unblock_events}
			launchevent \{type = unfocus
				target = current_menu}
			launchevent type = focus target = current_menu data = {child_index = <focus_index>}
		endif
	endif
	if (<mode> = music_store || <mode> = import)
		songlist_component :settags \{list_dirty = false}
		return
	endif
	formattext textname = songs_required qs(0xc31d83ea) i = ($g_songlist_force_num_songs_to_choose)
	songlist_detail_playlist :se_setprops {
		songlist_detail_playlist_num_songs_required_text = <songs_required>
	}
	if ($g_songlist_force_num_songs_to_choose > 0)
		songlist_detail_playlist :se_setprops \{songlist_detail_playlist_songs_added_alpha = 1.0
			songlist_detail_playlist_duration_alpha = 0.0}
	endif
	getarraysize ($current_playlist)
	if (<array_size> > 0)
		<i> = 0
		<iters> = <array_size>
		if (<array_size> > ($g_songlist_playlist_detail_items))
			<i> = (<array_size> - ($g_songlist_playlist_detail_items))
			<iters> = ($g_songlist_playlist_detail_items)
		endif
		begin
		get_ui_song_struct_items song = ($current_playlist [<i>])
		formattext textname = pos_text qs(0xc31d83ea) i = (<i> + 1)
		createscreenelement {
			type = descinterface
			desc = 'songlist_detail_playlist_item'
			parent = songlist_detail_playlist_vmenu
			songlist_item_text_text = (<ui_struct>.song_title)
			autosizedims = true
			in_playlist_pos_alpha = 1.0
			in_playlist_pos_text = <pos_text>
		}
		<id> :settags playlist_index = <i>
		<i> = (<i> + 1)
		repeat <iters>
		<i> = 0
		<iters> = <array_size>
		if (<array_size> > ($g_songlist_mini_playlist_detail_items))
			<i> = (<array_size> - ($g_songlist_mini_playlist_detail_items))
			<iters> = ($g_songlist_mini_playlist_detail_items)
		endif
		begin
		get_ui_song_struct_items song = ($current_playlist [<i>])
		formattext textname = pos_text qs(0xc31d83ea) i = (<i> + 1)
		createscreenelement {
			type = descinterface
			desc = 'songlist_detail_playlist_item'
			parent = songlist_detail_mini_playlist_vmenu
			songlist_item_text_text = (<ui_struct>.song_title)
			autosizedims = true
			in_playlist_pos_alpha = 1.0
			in_playlist_pos_text = <pos_text>
		}
		<id> :settags playlist_index = <i>
		<i> = (<i> + 1)
		repeat <iters>
		if ($g_songlist_force_num_songs_to_choose > 0)
			formattext textname = songs_added qs(0xc31d83ea) i = <array_size>
			songlist_detail_playlist :se_setprops {
				songlist_detail_playlist_num_songs_added_text = <songs_added>
			}
			if (<array_size> = $g_songlist_force_num_songs_to_choose)
				songlist_allow_continue
			endif
		elseif NOT ininternetmode
			songlist_allow_continue
		endif
	else
		songlist_disallow_continue
	endif
	songlist :settags \{list_dirty = false}
endscript

script songlist_add_header \{header_struct = 0x69696969}
	createscreenelement {
		type = descinterface
		desc = 'songlist_header_desc'
		parent = current_menu
		autosizedims = true
		songlist_header_text_text = (<header_struct>.header_text)
		not_focusable
	}
	<id> :settags {
		header = 1
	}
endscript

script songlist_update_sticky_header \{header_struct = {
		}
		alpha = 1}
	if (<alpha> = 1)
		<header_text> = (<header_struct>.header_text)
		if structurecontains \{structure = header_struct
				header_text_override}
			<header_text> = (<header_struct>.header_text_override)
		endif
		formattext textname = header_text qs(0x46bef454) h = <header_text> s = (($g_songlist_sort_array [($g_songlist_sort_index)]).text)
		songlist :se_setprops {
			songlist_sticky_header_alpha = 1.0
			songlist_sticky_header_text = <header_text>
		}
	else
		songlist :se_setprops \{songlist_sticky_header_alpha = 0.0}
	endif
endscript

script songlist_disallow_jump 
	current_menu :se_setprops \{event_handlers = [
			{
				pad_option2
				nullscript
			}
		]
		replace_handlers}
	songlist_component :settags \{jump_enabled = 0}
endscript

script songlist_allow_jump 
	current_menu :se_setprops \{event_handlers = [
			{
				pad_option2
				songlist_go_to_options
				params = {
					type = jump
				}
			}
		]
		replace_handlers}
	songlist_component :settags \{jump_enabled = 1}
endscript

script songlist_add_item \{ui_struct = 0x69696969}
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = import)
		formattext checksumname = song '%a' a = (<ui_struct>.song_title)
	elseif song_is_jamsession song = (<ui_struct>.song_checksum)
		formattext textname = text '%a' a = (<ui_struct>.filename)
		formattext checksumname = song '%i' i = <text>
	else
		song = (<ui_struct>.song_checksum)
	endif
	if (<mode> = music_store || <mode> = import)
		<desc> = 'music_store_item'
	else
		<desc> = 'songlist_item'
	endif
	extendcrc <song> '_sl_item' out = item_id
	if NOT structurecontains structure = <ui_struct> song_original_artist
		<sub_text> = (<ui_struct>.song_artist)
	else
		if (<ui_struct>.song_original_artist = 1)
			<sub_text> = (<ui_struct>.song_artist)
		else
			<sub_text> = $cover_artist_text
		endif
	endif
	createscreenelement {
		type = descinterface
		id = <item_id>
		desc = <desc>
		parent = current_menu
		songlist_item_text_text = (<ui_struct>.song_title)
		songlist_item_sub_text_text = <sub_text>
		autosizedims = true
	}
	<id> :settags {
		header = 0
		song_checksum = <song>
	}
	if NOT ((<mode> = import) || (<mode> = music_store))
		if NOT issongselectable song = (<ui_struct>.song_checksum)
			<id> :se_setprops {
				songlist_item_text_rgba = $g_songlist_invalid_item_unfocus_rgba
				songlist_item_sub_text_rgba = $g_songlist_invalid_sub_item_unfocus_rgba
			}
		endif
	endif
	if (<mode> = import)
		<id> :se_setprops {
			music_store_song_price_rgba = [0 0 0 0]
			music_store_money_icon_rgba = [0 0 0 0]
			music_store_money_text_rgba = [0 0 0 0]
		}
	endif
	if (<mode> = music_store)
		if structurecontains \{structure = ui_struct
				album_pack_only}
			songlist_music_store_add_item {
				id = <item_id>
				purchased = (<ui_struct>.purchased)
				price = (<ui_struct>.price)
				album_pack_only
			}
		else
			songlist_music_store_add_item {
				id = <item_id>
				purchased = (<ui_struct>.purchased)
				price = (<ui_struct>.price)
			}
		endif
	endif
	if songlist_is_song_in_playlist song = <song>
		songlist_component :getsingletag \{locked}
		if (<locked> = false)
			if innetgame
				gamemode_gettype
				if (<type> = career)
					<pad_choose_script> = songlist_item_remove_from_playlist
					<pad_choose_params> = {ui_struct = <ui_struct>}
				else
					<pad_choose_script> = songlist_item_add_to_playlist
					<pad_choose_params> = {ui_struct = <ui_struct>}
				endif
			else
				<song_options_struct> = {
					add_song = 0
					remove_song = 1
				}
				<pad_choose_script> = songlist_go_to_options
				<pad_choose_params> = {type = main song_item_id = <id> song_options_struct = <song_options_struct>}
			endif
		else
			<pad_choose_script> = nullscript
			<pad_choose_params> = {}
		endif
		<show_playlist_number> = 0
		if innetgame
			gamemode_gettype
			if (<type> = career || ($net_song_countdown = 1))
				<show_playlist_number> = 1
			endif
		else
			<show_playlist_number> = 1
		endif
		if (<show_playlist_number> = 1)
			formattext textname = pos_text qs(0xc31d83ea) i = (<playlist_index> + 1)
			<id> :se_setprops {
				in_playlist_pos_alpha = 1.0
				in_playlist_pos_text = <pos_text>
			}
		endif
		<id> :settags playlist_index = <playlist_index>
	else
		if (<mode> = import)
			<pad_choose_script> = nullscript
		elseif (<mode> = music_store)
			<pad_choose_script> = songlist_go_to_options
			<pad_choose_params> = {type = music_store purchase_struct = <ui_struct>}
		elseif ((<mode> = leaderboard) || (<mode> = practice) || (ininternetmode))
			<pad_choose_script> = songlist_item_add_to_playlist
			<pad_choose_params> = {ui_struct = <ui_struct>}
		else
			<song_options_struct> = {
				add_song = 1
				remove_song = 0
			}
			<pad_choose_script> = songlist_go_to_options
			<pad_choose_params> = {type = main song_item_id = <id> song_options_struct = <song_options_struct>}
		endif
	endif
	event_handlers = [
		{focus songlist_item_focus params = {ui_struct = <ui_struct>}}
		{unfocus songlist_item_unfocus params = {ui_struct = <ui_struct>}}
		{pad_choose <pad_choose_script> params = <pad_choose_params>}
	]
	<id> :se_setprops event_handlers = <event_handlers>
	return id = <id>
endscript

script songlist_go_to_song_library_tab 
	current_menu :se_setprops \{block_events}
	change \{rich_presence_context = presence_gigboard_and_setlist}
	songlist_component :membfunc_songlist_uistack_getmode
	songlist_set_mode_sort_index mode = <mode>
	songlist_component :getsingletag \{return_mode}
	change g_songlist_sort_index = ($g_songlist_sort_indexes.<return_mode>)
	songlist_component :membfunc_songlist_uistack_setmode mode = <return_mode>
	songlist_component :membfunc_songlist_uistack_setlistname \{list_name = gh_songlist}
	songlist_component :settags \{content_source = local_song_list}
	if ui_event_exists_in_stack \{name = 'music_store_hub'}
		generic_event_back
	endif
	songlist_create_detail_desc \{mode = play_song}
	songlist :se_setprops \{songlist_bg_illo_alpha = 1.0
		music_store_bg_illo_alpha = 0.0
		time = 0.25}
	current_menu :se_setprops \{event_handlers = [
			{
				pad_btn_left
				songlist_go_to_music_store_tab
			}
			{
				pad_l1
				songlist_go_to_options
				params = {
					type = sort
				}
			}
		]
		replace_handlers}
	songlist_refresh_menus \{no_pivot = 1}
endscript

script songlist_go_to_music_store_tab 
	current_menu :se_setprops \{block_events}
	songlist_update_song_preview \{song = none}
	if isps3
		getdisplaysettings
		if (<height> >= 720)
			songlist :se_setprops \{music_store_playstation_logo_texture = playstation_logo_hd720
				music_store_playstation_logo_scale = 1.0
				music_store_playstation_logo_dims = (180.0, 40.0)}
		else
			songlist :se_setprops \{music_store_playstation_logo_texture = playstation_logo_sd
				music_store_playstation_logo_scale = 1.5
				music_store_playstation_logo_dims = (136.0, 32.0)}
		endif
	endif
	change \{rich_presence_context = presence_music_store}
	create_dialog_box \{heading_text = qs(0x131b4d0f)
		body_text = qs(0xf29f90c7)}
	dialog_box_container :obj_spawnscript \{jam_recording_animate_spinning_record}
	songlist_component :membfunc_songlist_uistack_getmode
	songlist_component :settags {
		music_store_mode = hub
		music_store_seek_override = true
		visited_band_hub = 0
		return_mode = <mode>
	}
	songlist_set_mode_sort_index mode = <mode>
	<mode> = music_store
	change g_songlist_sort_index = ($g_songlist_sort_indexes.<mode>)
	songlist_component :membfunc_songlist_uistack_setmode mode = <mode>
	songlist_component :membfunc_songlist_uistack_setlistname \{list_name = marketplace}
	songlist_clear_filterspec
	songlist_component :settags \{content_source = marketplace}
	songlist_create_detail_desc mode = <mode>
	songlist :se_setprops \{songlist_bg_illo_alpha = 0.0
		music_store_bg_illo_alpha = 1.0
		time = 0.25}
	current_menu :se_setprops \{event_handlers = [
			{
				pad_btn_left
				songlist_go_to_song_library_tab
			}
		]
		replace_handlers}
	songlist_refresh_menus \{no_pivot = 1}
endscript

script songlist_music_store_add_item \{id = !q1768515945
		purchased = !i1768515945
		price = !i1768515945}
	if isps3
		<money_icon_alpha> = 0.0
		<money_text_alpha> = 1.0
		music_store_determine_currency
	endif
	if gotparam \{price}
		musicstore_format_price_text price = <price> currency_decimals = <currency_decimals>
	endif
	if (<purchased> = 1)
		<money_icon_alpha> = 1.0
		<money_text_alpha> = 0.0
		<money_texture> = checkmark
		<price_text> = qs(0x03ac90f0)
		<money_rgba> = (($g_menu_colors).pure_white)
	elseif gotparam \{album_pack_only}
		<money_icon_alpha> = 0.0
		<money_text_alpha> = 0.0
		<price_text> = qs(0x03ac90f0)
	endif
	<id> :se_setprops {
		music_store_song_price_text = <price_text>
		music_store_money_icon_texture = <money_texture>
		music_store_money_icon_alpha = <money_icon_alpha>
		music_store_money_icon_rgba = <money_rgba>
		music_store_money_text_alpha = <money_text_alpha>
		music_store_money_text_text = <currency>
		music_store_money_text_rgba = <money_rgba>
	}
endscript

script songlist_music_store_view_pack_songs \{ui_struct = 0x69696969}
	if gotparam \{play_sfx}
		music_store_select_sfx
	endif
	songlist_component :membfunc_songlist_uistack_getfilterspec
	if gotparam \{purchase_checksum}
		<pivot_checksum> = <purchase_checksum>
	else
		<pivot_checksum> = (<ui_struct>.song_checksum)
	endif
	current_menu :se_setprops {
		event_handlers = [
			{pad_back songlist_music_store_back_to_previous_filterspec params = {filterspec = <filterspec> sort_index = ($g_songlist_sort_index) pivot_checksum = <pivot_checksum>}}
		]
		replace_handlers
	}
	<pack_contents> = (<ui_struct>.pack_contents)
	addarrayelement array = <pack_contents> element = (<ui_struct>.song_checksum)
	filterspec = [
		{
			key = song_checksum
			union_list = <array>
			comparator = equal
		}
	]
	songlist_change_filterspec filterspec = <filterspec>
	songlist_change_sort_by_key \{key = type_string}
	if ((<ui_struct>.type) = pack)
		formattext textname = title qs(0xf987cdb7) t = (<ui_struct>.song_title)
	else
		formattext textname = title qs(0x690533a1) t = (<ui_struct>.song_title)
	endif
	change g_music_store_title = <title>
	if gotparam \{no_pivot}
		songlist_refresh_menus \{no_pivot = 1}
	else
		songlist_refresh_menus
	endif
endscript

script songlist_music_store_back_to_previous_filterspec \{filterspec = !a1768515945
		sort_index = !i1768515945
		pivot_checksum = !q1768515945}
	current_menu :se_setprops \{event_handlers = [
			{
				pad_back
				songlist_back
			}
		]
		replace_handlers}
	songlist_change_filterspec filterspec = <filterspec>
	songlist_change_sort_index index = <sort_index>
	songlist_refresh_menus pivot_checksum = <pivot_checksum>
endscript

script songlist_music_store_disallow_sorting 
	if user_control_helper_exists \{button = orange}
		user_control_destroy_helper \{button = orange}
	endif
	current_menu :se_setprops \{event_handlers = [
			{
				pad_l1
				nullscript
			}
		]
		replace_handlers}
endscript

script songlist_music_store_allow_sorting 
	if NOT user_control_helper_exists \{button = orange}
		add_user_control_helper \{text = qs(0x00a93373)
			button = orange
			z = 100000}
	else
		user_control_helper_change_text \{button = orange
			text = qs(0x00a93373)}
	endif
	current_menu :se_setprops \{event_handlers = [
			{
				pad_l1
				songlist_go_to_options
				params = {
					type = sort
				}
			}
		]
		replace_handlers}
endscript

script songlist_is_song_in_playlist \{song = !q1768515945}
	getarraysize ($current_playlist)
	if (<array_size> > 0)
		<i> = 0
		begin
		if (<song> = ($current_playlist [<i>]))
			return true playlist_index = <i>
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	endif
	return \{false}
endscript

script songlist_is_song_in_menu \{song = !q1768515945}
	getscreenelementchildren \{id = current_menu}
	getarraysize <children>
	if (<array_size> > 0)
		<i> = 0
		begin
		(<children> [<i>]) :getsingletag header
		if (<header> = 0)
			(<children> [<i>]) :getsingletag song_checksum
			if (<song> = <song_checksum>)
				return true menu_index = <i>
			endif
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	endif
	return \{false}
endscript

script songlist_get_song_playlist_detail_index \{playlist_index = !i1768515945
		vmenu_id = !q1768515945}
	<my_playlist_index> = <playlist_index>
	if getscreenelementchildren id = <vmenu_id>
		getarraysize <children>
		<i> = 0
		begin
		(<children> [<i>]) :getsingletag playlist_index
		if (<playlist_index> = <my_playlist_index>)
			return true playlist_detail_index = <i>
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	endif
	return \{false}
endscript

script songlist_do_maintenance_on_list \{playlist_index = !i1768515945
		list = !q1768515945}
	if getscreenelementchildren id = <list>
		getarraysize <children>
		<my_playlist_index> = <playlist_index>
		removeparameter \{playlist_index}
		<i> = 0
		begin
		(<children> [<i>]) :getsingletag playlist_index
		if gotparam \{playlist_index}
			if (<my_playlist_index> < <playlist_index>)
				<new_index> = <playlist_index>
				formattext textname = pos_text qs(0xc31d83ea) i = <new_index>
				(<children> [<i>]) :se_setprops {
					in_playlist_pos_text = <pos_text>
				}
				(<children> [<i>]) :settags playlist_index = (<new_index> - 1)
			endif
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	endif
endscript

script songlist_update_instrument_difficulty_rating \{time = 0.025
		prev_diff_rate = !i1768515945}
	if NOT gotparam \{diff_rate}
		diff_rate = 0
	endif
	if (<diff_rate> = 11)
		<diff_rate> = 0
	endif
	songlist_component :membfunc_songlist_uistack_getmode
	<on_rgba> = [45 100 110 0]
	<off_rgba> = [255 255 255 255]
	<off_alpha> = 1.0
	<difference> = (<diff_rate> - <prev_diff_rate>)
	formattext checksumname = songlist_detail_difficulty_vmenu 'songlist_detail_difficulty_%i_vmenu' i = <instrument>
	getscreenelementchildren id = <songlist_detail_difficulty_vmenu>
	resolvescreenelementid id = [
		{id = <songlist_detail_difficulty_vmenu>}
		{local_id = songlist_detail_difficulty_sprite}
		{local_id = songlist_detail_difficulty_invalid}
	]
	if gotparam \{resolved_id}
		if (<diff_rate> = 0)
			<resolved_id> :se_setprops alpha = 1 time = 0.2
		else
			<resolved_id> :se_setprops alpha = 0 time = 0.2
		endif
	endif
	if (<difference> > 0)
		<i> = (9 - <prev_diff_rate>)
		formattext checksumname = prev_diff_rate 'prev_%i_diff_rate' i = <instrument>
		begin
		(<children> [<i>]) :se_setprops rgba = <on_rgba> alpha = 1.0
		addparam structure_name = my_diff_rate_struct name = <prev_diff_rate> value = (10 - <i>)
		songlist_detail :settags {
			<my_diff_rate_struct>
		}
		wait <time> seconds
		<i> = (<i> - 1)
		repeat <difference>
	else
		<difference> = (<difference> * -1)
		<i> = (10 - <prev_diff_rate>)
		if (<difference> > 0)
			formattext checksumname = prev_diff_rate 'prev_%i_diff_rate' i = <instrument>
			begin
			(<children> [<i>]) :se_setprops rgba = <off_rgba> alpha = <off_alpha>
			addparam structure_name = my_diff_rate_struct name = <prev_diff_rate> value = (9 - <i>)
			songlist_detail :settags {
				<my_diff_rate_struct>
			}
			wait <time> seconds
			<i> = (<i> + 1)
			repeat <difference>
		endif
	endif
endscript

script songlist_update_stars \{time = 0.05
		prev_stars = !i1768515945
		gold_stars = !i1768515945}
	if NOT gotparam \{stars}
		stars = 0
	endif
	<difference> = (<stars> - <prev_stars>)
	getscreenelementchildren \{id = songlist_detail_stars_empty_vmenu}
	getarraysize <children>
	if (<stars> = 6)
		<max_stars> = 6
		if (<array_size> = 5)
			createscreenelement \{type = spriteelement
				parent = songlist_detail_stars_empty_vmenu
				texture = songlist_star_empty
				dims = (64.0, 64.0)
				just = [
					center
					center
				]
				alpha = 0.15
				z_priority = 21}
			songlist_detail_stars_empty_vmenu :menu_setitemindex \{index = 5
				newindex = 0}
			createscreenelement \{type = spriteelement
				parent = songlist_detail_stars_full_vmenu
				texture = songlist_star_full
				dims = (64.0, 64.0)
				just = [
					center
					center
				]
				alpha = 0
				z_priority = 22}
			songlist_detail_stars_full_vmenu :menu_setitemindex \{index = 5
				newindex = 0}
			getscreenelementposition \{id = songlist_detail_diff_inst_cont}
			songlist_detail_diff_inst_cont :se_setprops pos = (<screenelementpos> + (0.0, 14.0))
		endif
	else
		<max_stars> = 5
		if (<array_size> = 6)
			destroyscreenelement id = (<children> [0])
			removeparameter \{children}
			getscreenelementchildren \{id = songlist_detail_stars_full_vmenu}
			destroyscreenelement id = (<children> [0])
			getscreenelementposition \{id = songlist_detail_diff_inst_cont}
			songlist_detail_diff_inst_cont :se_setprops pos = (<screenelementpos> + (0.0, -14.0))
		endif
	endif
	getscreenelementchildren \{id = songlist_detail_stars_full_vmenu}
	if (<difference> > 0)
		<i> = ((<max_stars> - 1) - <prev_stars>)
		begin
		(<children> [<i>]) :se_setprops alpha = 1.0
		songlist_detail :settags {
			prev_stars = (<max_stars> - <i>)
		}
		wait <time> seconds
		<i> = (<i> - 1)
		repeat <difference>
	else
		<difference> = (<difference> * -1)
		if (<difference> > 0)
			if (<prev_stars> = 6)
				<prev_stars> = 5
				songlist_detail :settags \{prev_stars = 5}
				<difference> = (<difference> - 1)
			endif
			if (<difference> > 0)
				<i> = (<max_stars> - <prev_stars>)
				begin
				(<children> [<i>]) :se_setprops alpha = 0.0
				songlist_detail :settags {
					prev_stars = ((<max_stars> - 1) - <i>)
				}
				wait <time> seconds
				<i> = (<i> + 1)
				repeat <difference>
			endif
		endif
	endif
	if (<gold_stars> = 0)
		<rgba> = (($g_menu_colors).pure_white)
	else
		<rgba> = (($g_menu_colors).gh5_gold_md)
	endif
	<star> = 0
	begin
	(<children> [<star>]) :se_setprops rgba = <rgba> time = 0.5
	<star> = (<star> + 1)
	repeat <max_stars>
endscript

script songlist_item_focus \{time = 0.0
		ui_struct = 0x69696969}
	if NOT gotparam \{id}
		obj_getid
		<id> = <objid>
	endif
	<rgba> = (($g_menu_colors).black)
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = import)
		<id> :se_setprops {
			songlist_item_text_rgba = ($g_music_store_item_focus_rgba)
			songlist_item_sub_text_rgba = ($g_music_store_sub_item_focus_rgba)
			music_store_song_price_rgba = [0 0 0 0]
			music_store_money_icon_rgba = [0 0 0 0]
			music_store_money_text_rgba = [0 0 0 0]
			time = <time>
		}
		return
	endif
	if song_is_jamsession song = (<ui_struct>.song_checksum)
		formattext textname = text '%a' a = (<ui_struct>.filename)
		formattext checksumname = song_checksum '%i' i = <text>
	else
		song_checksum = (<ui_struct>.song_checksum)
	endif
	songlist_component :getsingletag \{exclusive_device}
	if (<mode> = music_store)
		if (<ui_struct>.type = song)
			songlist_detail :se_setprops \{songlist_detail_songs_alpha = 1.0
				songlist_detail_albums_alpha = 0.0}
		else
			songlist_detail :se_setprops \{songlist_detail_songs_alpha = 0.0
				songlist_detail_albums_alpha = 1.0}
		endif
		if NOT (<ui_struct>.song_rating = none)
			<pa_alpha> = 1.0
			<esrb_notice_alpha> = 0.0
		else
			<pa_alpha> = 0.0
			songlist_component :getsingletag \{territory}
			if (<territory> != territory_us)
				<esrb_notice_alpha> = 0.0
			else
				<esrb_notice_alpha> = 1.0
			endif
		endif
		songlist :se_setprops {
			pa_esrb_label_alpha = <pa_alpha>
			esrb_notice_alpha = <esrb_notice_alpha>
		}
	endif
	if songlist_is_song_in_playlist song = <song_checksum>
		<rgba> = (($g_menu_colors).songlist_focus_orangeish)
		gamemode_gettype
		if NOT ininternetmode
		elseif (<type> = career)
			if ($g_net_leader_player_num != -1)
				if playerinfoequals ($g_net_leader_player_num) is_local_client = 1
					user_control_helper_change_text \{button = green
						text = qs(0x34ff4910)}
				endif
			endif
		endif
	endif
	if NOT (<mode> = music_store)
		if issongselectable song = (<ui_struct>.song_checksum)
			<item_focus_rgba> = ($g_songlist_item_focus_rgba)
			<sub_item_focus_rgba> = ($g_songlist_sub_item_focus_rgba)
		else
			<item_focus_rgba> = ($g_songlist_invalid_item_focus_rgba)
			<sub_item_focus_rgba> = ($g_songlist_invalid_sub_item_focus_rgba)
		endif
	else
		<item_focus_rgba> = ($g_music_store_item_focus_rgba)
		<sub_item_focus_rgba> = ($g_music_store_sub_item_focus_rgba)
	endif
	<id> :se_setprops {
		songlist_item_text_rgba = <item_focus_rgba>
		songlist_item_sub_text_rgba = <sub_item_focus_rgba>
		songlist_item_highlight_bar_alpha = 0.8
		time = <time>
	}
	if (<mode> = music_store)
		if (<ui_struct>.purchased = 1)
			<money_icon_rgba> = (($g_menu_colors).pure_white)
		else
			<money_icon_rgba> = <sub_item_focus_rgba>
		endif
		<id> :se_setprops {
			music_store_song_price_rgba = <sub_item_focus_rgba>
			music_store_money_icon_rgba = <money_icon_rgba>
			music_store_money_text_rgba = <money_icon_rgba>
			songlist_item_highlight_bar_alpha = 0.5
		}
	endif
	if NOT (<mode> = music_store)
		if NOT song_is_jamsession song = (<ui_struct>.song_checksum)
			get_genre_text genre = (<ui_struct>.song_genre) song = <song_checksum>
			formattext textname = genre_year_text qs(0xf7e765ed) g = <genre> y = (<ui_struct>.song_year)
		else
			curr_musicstudio_genre = (<ui_struct>.musicstudio_genre)
			getarraysize ($jam_genre_list) param = genre_list_size
			if ((<curr_musicstudio_genre> >= 0) && (<curr_musicstudio_genre> < <genre_list_size>))
				musicstudio_genre_text = ($jam_genre_list [<curr_musicstudio_genre>].name_text)
			else
				musicstudio_genre_text = qs(0xd0ef7f05)
			endif
			formattext textname = genre_year_text qs(0xf7e765ed) g = <musicstudio_genre_text> y = (<ui_struct>.song_year)
		endif
		<total_seconds> = 0
		if structurecontains structure = <ui_struct> song_duration
			<total_seconds> = (<ui_struct>.song_duration)
		endif
		if (<total_seconds> > 0)
			seconds = 0
			minutes = 0
			mod a = <total_seconds> b = 60
			<seconds> = <mod>
			<total_seconds> = (<total_seconds> - <seconds>)
			if (<total_seconds> > 0)
				mod a = <total_seconds> b = (60 * 60)
				<minutes> = (<mod> / 60)
			endif
		else
			<seconds> = 0
			<minutes> = 0
		endif
		formattext textname = duration_text qs(0x81ca0519) m = <minutes> s = <seconds>
		songlist_detail_transition \{desc = songlist_detail
			fade_time = 0}
		if NOT song_is_jamsession song = (<ui_struct>.song_checksum)
			if (<mode> = practice || <mode> = leaderboard)
				player_num = 1
			else
				get_local_in_game_player_num_from_controller {controller_index = <exclusive_device> allow_dropped_player = 1}
			endif
			if (<player_num> = -1)
				scriptassert \{'player_num = -1'}
			endif
			if issingleplayergame
				getplayerinfo <player_num> part
				getplayerinfo <player_num> difficulty
			else
				<part> = band
				get_highest_difficulty
				<difficulty> = <highest_difficulty>
			endif
			get_difficulty_text_nl difficulty = <difficulty>
			get_song_prefix song = <song_checksum>
			if (<mode> = leaderboard)
				switch ($current_leaderboard_instrument)
					case 'guitar'
					part = guitar
					case 'backup'
					part = bass
					case 'drums'
					part = drum
					case 'mic'
					part = vocals
					case 'band'
					case 'altband'
					part = band
				endswitch
			endif
			if (<mode> = leaderboard)
				difficulty = beginner
				get_difficulty_text_nl difficulty = <difficulty>
				getarraysize ($difficulty_list) param = diff_list_size
				diff_idx = (<diff_list_size> - 1)
				begin
				diff = ($difficulty_list [<diff_idx>])
				get_difficulty_text_nl difficulty = <diff>
				if ($g_include_debug_songs = 0)
					0x4cb6620f {
						song_prefix = <song_prefix>
						difficulty_text_nl = <difficulty_text_nl>
						part = ($instrument_list.<part>.text_nl)
					}
				else
					<setlist_beststars> = 0
					<setlist_bestpercentage> = 0
				endif
				if (<setlist_beststars> > 0)
					difficulty = <diff>
					break
				endif
				diff_idx = (<diff_idx> - 1)
				repeat <diff_list_size>
			else
				if ($g_include_debug_songs = 0)
					0x4cb6620f {
						song_prefix = <song_prefix>
						difficulty_text_nl = <difficulty_text_nl>
						part = ($instrument_list.<part>.text_nl)
					}
				else
					<setlist_beststars> = 0
					<setlist_bestpercentage> = 0
				endif
			endif
			songlist_update_more_info {
				part = <part>
				song_checksum = <song_checksum>
			}
			formattext checksumname = difficulty_icon 'icon_difficulty_%i' i = <difficulty_text_nl>
			songlist_detail :se_setprops {
				songlist_detail_difficulty_icon_texture = <difficulty_icon>
				songlist_detail_difficulty_icon_alpha = 1
				songlist_detail_intensity_cont_alpha = 1.0
				songlist_detail_jam_instruments_cont_alpha = 0.0
				intensity_text = qs(0x1e6a3a72)
			}
		else
			songlist_clear_more_info
			if (<ui_struct>.playback_track1 = -1)
				<guitar_alpha> = 0.2
			else
				<guitar_alpha> = 1.0
			endif
			if (<ui_struct>.playback_track2 = -1)
				<bass_alpha> = 0.2
			else
				<bass_alpha> = 1.0
			endif
			if (<ui_struct>.playback_track_drums = 0)
				<drum_alpha> = 0.2
			else
				<drum_alpha> = 1.0
			endif
			if (<ui_struct>.playback_track_vocals = 0)
				<vocal_alpha> = 0.2
			else
				<vocal_alpha> = 1.0
			endif
			songlist_detail :se_setprops {
				songlist_detail_jam_guitar_square_alpha = <guitar_alpha>
				songlist_detail_jam_bass_square_alpha = <bass_alpha>
				songlist_detail_jam_drum_square_alpha = <drum_alpha>
				songlist_detail_jam_vocal_square_alpha = <vocal_alpha>
				songlist_detail_intensity_cont_alpha = 0.0
				songlist_detail_jam_instruments_cont_alpha = 1.0
				intensity_text = qs(0xb7ce658c)
			}
		endif
		<line0> = (<ui_struct>.song_album_title)
		<line1> = <genre_year_text>
		<line2> = <duration_text>
		<text_dims> = (360.0, 40.0)
		songlist_detail :se_setprops {
			songlist_detail_album_text_dims = <text_dims>
			songlist_detail_genre_text_dims = <text_dims>
			songlist_detail_duration_text_dims = <text_dims>
			songlist_detail_artist_text_text = (<ui_struct>.song_artist)
			songlist_detail_song_text_text = (<ui_struct>.song_title)
			songlist_detail_genre_text_text = <line1>
			songlist_detail_album_text_text = <line0>
			songlist_detail_duration_text_text = <line2>
			songlist_detail_source_text_text = (<ui_struct>.song_source_txt)
		}
	else
		0x92fefb19 {
			id = <id>
			ui_struct = <ui_struct>
		}
	endif
	<do_intensity> = 1
	if song_is_jamsession song = (<ui_struct>.song_checksum)
		<do_intensity> = 0
	endif
	if (<mode> = music_store)
		if NOT (<ui_struct>.type = song)
			<do_intensity> = 0
		endif
	endif
	songlist_detail :gettags
	if (<do_intensity> = 1)
		songlist_detail :obj_killspawnedscript \{name = songlist_update_instrument_difficulty_rating}
		songlist_detail :obj_spawnscriptnow songlist_update_instrument_difficulty_rating params = {
			instrument = 'guitar'
			diff_rate = (<ui_struct>.song_guitar_difficulty_rating)
			prev_diff_rate = <prev_guitar_diff_rate>
		}
		songlist_detail :obj_spawnscriptnow songlist_update_instrument_difficulty_rating params = {
			instrument = 'bass'
			diff_rate = (<ui_struct>.song_bass_difficulty_rating)
			prev_diff_rate = <prev_bass_diff_rate>
		}
		songlist_detail :obj_spawnscriptnow songlist_update_instrument_difficulty_rating params = {
			instrument = 'drums'
			diff_rate = (<ui_struct>.song_drums_difficulty_rating)
			prev_diff_rate = <prev_drums_diff_rate>
		}
		songlist_detail :obj_spawnscriptnow songlist_update_instrument_difficulty_rating params = {
			instrument = 'vocals'
			diff_rate = (<ui_struct>.song_vocals_difficulty_rating)
			prev_diff_rate = <prev_vocals_diff_rate>
		}
	endif
	if NOT (<mode> = music_store)
		if song_is_jamsession song = (<ui_struct>.song_checksum)
			<setlist_beststars> = 0
		endif
		<gold_stars> = 0
		if gotparam \{setlist_bestpercentage}
			if (<setlist_bestpercentage> = 100)
				<gold_stars> = 1
			endif
		endif
		songlist_detail :obj_killspawnedscript \{name = songlist_update_stars}
		songlist_detail :obj_spawnscriptnow songlist_update_stars params = {
			stars = <setlist_beststars>
			prev_stars = <prev_stars>
			gold_stars = <gold_stars>
		}
		if NOT 0x3697c2c5 song = <song_checksum>
			audio_ui_menu_music_off
			songlist_update_song_preview song = <song_checksum>
		else
			spawnscriptnow \{audio_ui_menu_music_on}
			songlist_update_song_preview \{song = none}
		endif
		if (<ui_struct>.song_double_kick = 1)
			songlist_detail :se_setprops \{icon_difficulty_expert_plus_alpha = 1.0}
		else
			songlist_detail :se_setprops \{icon_difficulty_expert_plus_alpha = 0.0}
		endif
	else
		if (<ui_struct>.patched = 0)
			songlist_detail :se_setprops \{music_store_patch_popup_alpha = 1.0}
		else
			songlist_detail :se_setprops \{music_store_patch_popup_alpha = 0.0}
		endif
		if structurecontains structure = <ui_struct> song_double_kick
			if (<ui_struct>.song_double_kick = 1)
				songlist_detail :se_setprops \{icon_difficulty_expert_plus_alpha = 1.0}
			else
				songlist_detail :se_setprops \{icon_difficulty_expert_plus_alpha = 0.0}
			endif
		else
			songlist_detail :se_setprops \{icon_difficulty_expert_plus_alpha = 0.0}
		endif
	endif
	if (<mode> != playlist)
		songlist_detail :se_setprops \{songlist_detail_mini_playlist_text = qs(0x03ac90f0)}
	else
		songlist_detail :se_setprops \{songlist_detail_mini_playlist_text = qs(0x0f9cf815)}
	endif
	if ((<mode> != playlist) && (<mode> != music_store) && (<mode> != import))
		songlist_detail :se_setprops \{songlist_detail_mini_info_alpha = 0.0}
		if structurecontains structure = $gh_songlist_props (<ui_struct>.song_checksum)
			if structurecontains structure = ($gh_songlist_props.(<ui_struct>.song_checksum)) name
				formattext checksumname = challenge_global 'c_%s' s = (($gh_songlist_props.(<ui_struct>.song_checksum)).name)
				if globalexists name = <challenge_global>
					if structurecontains structure = ($<challenge_global>) descrip
						songlist_detail :se_setprops \{songlist_detail_mini_playlist_text = qs(0x9adda19b)}
						songlist_detail :se_setprops songlist_detail_mini_info_text = (($<challenge_global>).descrip)
						songlist_detail :se_setprops \{songlist_detail_mini_info_alpha = 1.0}
					endif
				endif
			endif
		endif
	else
		songlist_detail :se_setprops \{songlist_detail_mini_info_alpha = 0.0
			time = 0.1}
		songlist_detail :se_waitprops
		songlist_detail :se_setprops \{songlist_detail_mini_info_text = qs(0x03ac90f0)}
	endif
	if (<mode> = play_song || <mode> = playlist)
		quickplay_songlist_update_awards song_checksum = (<ui_struct>.song_checksum)
	endif
endscript

script songlist_music_store_item_focus 
endscript

script 0x92fefb19 \{hub_item_cycle = 0
		morph_time = 0.0
		ui_struct = 0x69696969}
	song_checksum = (<ui_struct>.song_checksum)
	get_genre_text genre = (<ui_struct>.song_genre) song = <song_checksum>
	formattext textname = genre_year_text qs(0xf7e765ed) g = <genre> y = (<ui_struct>.song_year)
	<total_seconds> = 0
	if structurecontains structure = <ui_struct> song_duration
		<total_seconds> = (<ui_struct>.song_duration)
	endif
	if (<total_seconds> > 0)
		seconds = 0
		minutes = 0
		mod a = <total_seconds> b = 60
		<seconds> = <mod>
		<total_seconds> = (<total_seconds> - <seconds>)
		if (<total_seconds> > 0)
			mod a = <total_seconds> b = (60 * 60)
			<minutes> = (<mod> / 60)
		endif
	else
		<seconds> = 0
		<minutes> = 0
	endif
	formattext textname = duration_text qs(0x81ca0519) m = <minutes> s = <seconds>
	<line0> = (<ui_struct>.album)
	<line1> = <genre_year_text>
	<line2> = <duration_text>
	if (<ui_struct>.type = song)
		if (<hub_item_cycle> = 1)
			<line0> = (<ui_struct>.song_title)
			<line1> = (<ui_struct>.song_artist)
			formattext textname = album_year_text qs(0xfaf915aa) a = (<ui_struct>.album) y = (<ui_struct>.song_year)
			<line2> = <album_year_text>
		endif
	elseif (<ui_struct>.type = pack)
		<array> = (<ui_struct>.contents_strings)
		getarraysize <array>
		<iters> = <array_size>
		<more_than_3> = 0
		if (<array_size> > 3)
			<iters> = 2
			<more_than_3> = (<array_size> - 2)
		endif
		if (<iters> > 0)
			<i> = 0
			begin
			formattext checksumname = line 'line%i' i = <i>
			addparam name = <line> value = (<array> [<i>])
			<i> = (<i> + 1)
			repeat <iters>
		endif
		if (<more_than_3> > 1)
			formattext textname = more_songs qs(0x560b5eda) n = <more_than_3>
			addparam name = line2 value = <more_songs>
		endif
		<empty_iters> = (3 - <array_size>)
		if (<empty_iters> > 0)
			<i> = <iters>
			begin
			formattext checksumname = line 'line%i' i = <i>
			addparam name = <line> value = qs(0x03ac90f0)
			<i> = (<i> + 1)
			repeat <empty_iters>
		endif
	else
		<line0> = (<ui_struct>.song_title)
		<line1> = (<ui_struct>.song_artist)
		<line2> = qs(0x73ab05d2)
	endif
	<text_dims> = (330.0, 40.0)
	<desc> = songlist_detail
	if (<hub_item_cycle> = 1)
		<desc> = music_store_hub
		<text_dims> = (530.0, 40.0)
		music_store_hub :se_setprops songlist_detail_cont_alpha = 0.0 time = <morph_time>
		wait <morph_time> seconds
	endif
	<desc> :se_setprops {
		songlist_detail_album_text_dims = <text_dims>
		songlist_detail_genre_text_dims = <text_dims>
		songlist_detail_duration_text_dims = <text_dims>
		songlist_detail_artist_text_text = (<ui_struct>.song_artist)
		songlist_detail_song_text_text = (<ui_struct>.song_title)
		songlist_detail_genre_text_text = <line1>
		songlist_detail_album_text_text = <line0>
		songlist_detail_duration_text_text = <line2>
		songlist_detail_source_text_text = (<ui_struct>.song_source_txt)
	}
	songlist_music_store_check_scroll_text {
		desc = <desc>
		item_type = (<ui_struct>.type)
		hub_item_cycle = <hub_item_cycle>
		text_dims = <text_dims>
		line0 = <line0>
		line1 = <line1>
		line2 = <line2>
	}
	if ((<ui_struct>.patched = 1) || (<hub_item_cycle> = 1))
		if structurecontains structure = <ui_struct> song_preview_asset_name
			music_store_change_album_cover {
				texture_name = (<ui_struct>.song_preview_asset_name)
				desc = <desc>
			}
		endif
	endif
	if (<hub_item_cycle> = 1)
		music_store_hub :se_setprops songlist_detail_cont_alpha = 1.0 time = <morph_time>
	endif
endscript

script songlist_music_store_check_scroll_text \{desc = songlist_detail
		item_type = !q1768515945
		hub_item_cycle = !i1768515945
		text_dims = 0x69696969}
	<desc> :se_getprops
	<max_x> = (<text_dims>.(1.0, 0.0))
	<i> = 0
	begin
	if (<i> = 0)
		<param> = 'album'
	elseif (<i> = 1)
		<param> = 'genre'
	else
		<param> = 'duration'
	endif
	formattext checksumname = songlist_detail_text_dims 'songlist_detail_%c_text_dims' c = <param>
	formattext checksumname = songlist_detail_text_text 'songlist_detail_%c_text_text' c = <param>
	formattext checksumname = songlist_detail_cont 'songlist_detail_%c_cont' c = <param>
	formattext checksumname = songlist_detail_text_rgba 'songlist_detail_%c_text_rgba' c = <param>
	if ((<hub_item_cycle> = 1) || (<item_type> != song))
		formattext checksumname = songlist_detail_text 'songlist_detail_%c_text' c = <param>
	else
		formattext checksumname = songlist_detail_text 'songlist_detail_songs_%c_text' c = <param>
	endif
	formattext checksumname = line_text 'line%i' i = <i>
	if (((<...>.<songlist_detail_text_dims>).(1.0, 0.0)) > <max_x>)
		addparam structure_name = my_blank_text name = <songlist_detail_text_text> value = qs(0x03ac90f0)
		<desc> :se_setprops {
			<my_blank_text>
		}
		if screenelementexists id = <songlist_detail_cont>
			<songlist_detail_text> :obj_killspawnedscript name = scroll_ticker_text
			destroyscreenelement id = <songlist_detail_cont>
		endif
		createscreenelement {
			type = containerelement
			id = <songlist_detail_cont>
			parent = <songlist_detail_text>
		}
		<songlist_detail_text> :obj_spawnscriptlater scroll_ticker_text params = {
			ticker_text = (<...>.<line_text>)
			ticker_space = qs(0x8b73fd0e)
			ticker_pos = (0.0, 0.0)
			ticker_just = [left top]
			ticker_parent = <songlist_detail_cont>
			ticker_font = fontgrid_text_a1
			ticker_x_scale = 0.5
			ticker_y_scale = 0.5
			ticker_rgba1 = (<...>.<songlist_detail_text_rgba>)
			ticker_rgba2 = (<...>.<songlist_detail_text_rgba>)
			ticker_alpha = 1.0
			ticker_z_priority = 53
			time = 16
			use_shadow = 0
		}
	else
		if screenelementexists id = <songlist_detail_cont>
			<songlist_detail_text> :obj_killspawnedscript name = scroll_ticker_text
			destroyscreenelement id = <songlist_detail_cont>
		endif
	endif
	<i> = (<i> + 1)
	repeat 3
endscript

script songlist_clear_more_info 
	getscreenelementchildren \{id = songlist_detail_more_info_rows}
	<rows> = <children>
	removeparameter \{children}
	<i> = 0
	begin
	getscreenelementchildren id = (<rows> [<i>])
	<stats> = <children>
	removeparameter \{children}
	getscreenelementchildren id = (<stats> [1])
	<id> = (<children> [0])
	<id> :se_setprops text = qs(0x03ac90f0)
	removeparameter \{children}
	getscreenelementchildren id = (<stats> [2])
	<id> = (<children> [0])
	<id> :se_setprops text = qs(0x03ac90f0)
	removeparameter \{children}
	getscreenelementchildren id = (<stats> [3])
	<id> = (<children> [0])
	<id> :se_setprops text = qs(0x03ac90f0)
	removeparameter \{children}
	<i> = (<i> + 1)
	repeat 5
endscript

script songlist_update_more_info \{part = !q1768515945
		song_checksum = !q1768515945}
	songlist_component :membfunc_songlist_uistack_getmode
	getscreenelementchildren \{id = songlist_detail_more_info_rows}
	<rows> = <children>
	removeparameter \{children}
	<i> = 0
	begin
	if (<mode> = leaderboard)
		switch ($current_leaderboard_instrument)
			case 'guitar'
			part = guitar
			case 'backup'
			part = bass
			case 'drums'
			part = drum
			case 'mic'
			part = vocals
			case 'band'
			case 'altband'
			part = band
		endswitch
	endif
	get_difficulty_text_nl index = (4 - <i>)
	get_song_prefix song = <song_checksum>
	if ($g_include_debug_songs = 0)
		0x4cb6620f {
			song_prefix = <song_prefix>
			difficulty_text_nl = <difficulty_text_nl>
			part = ($instrument_list.<part>.text_nl)
		}
	else
		<setlist_beststars> = 0
		<setlist_bestscore> = 0
		<setlist_bestpercentage> = 0
	endif
	getscreenelementchildren id = (<rows> [<i>])
	<stats> = <children>
	removeparameter \{children}
	getscreenelementchildren id = (<stats> [1])
	<id> = (<children> [0])
	if (<setlist_beststars> = 0)
		formattext \{textname = stars_text
			qs(0x03ac90f0)}
	else
		formattext textname = stars_text qs(0x73307931) s = <setlist_beststars>
	endif
	<id> :se_setprops text = <stars_text>
	removeparameter \{children}
	getscreenelementchildren id = (<stats> [2])
	<id> = (<children> [0])
	if (<setlist_bestscore> = 0)
		formattext \{textname = score_text
			qs(0x03ac90f0)}
	else
		formattext textname = score_text qs(0x73307931) s = <setlist_bestscore> usecommas
	endif
	<id> :se_setprops text = <score_text>
	removeparameter \{children}
	getscreenelementchildren id = (<stats> [3])
	<id> = (<children> [0])
	if (<setlist_bestpercentage> = 0)
		formattext \{textname = notes_text
			qs(0x03ac90f0)}
	else
		formattext textname = notes_text qs(0x6cd5ba93) s = <setlist_bestpercentage>
	endif
	<id> :se_setprops text = <notes_text>
	removeparameter \{children}
	<i> = (<i> + 1)
	repeat 5
endscript

script songlist_item_unfocus \{time = 0.0}
	if NOT gotparam \{id}
		obj_getid
		<id> = <objid>
	endif
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = import)
		<id> :se_setprops {
			songlist_item_text_rgba = ($g_music_store_item_unfocus_rgba)
			songlist_item_sub_text_rgba = ($g_music_store_sub_item_unfocus_rgba)
			music_store_song_price_rgba = [0 0 0 0]
			music_store_money_icon_rgba = [0 0 0 0]
			music_store_money_text_rgba = [0 0 0 0]
			time = <time>
		}
		return
	endif
	if song_is_jamsession song = (<ui_struct>.song_checksum)
		formattext textname = text '%a' a = (<ui_struct>.filename)
		formattext checksumname = song_checksum '%i' i = <text>
	else
		song_checksum = (<ui_struct>.song_checksum)
	endif
	if NOT (<mode> = music_store)
		if issongselectable song = (<ui_struct>.song_checksum)
			<item_unfocus_rgba> = ($g_songlist_item_unfocus_rgba)
			<sub_item_unfocus_rgba> = ($g_songlist_sub_item_unfocus_rgba)
		else
			<item_unfocus_rgba> = ($g_songlist_invalid_item_unfocus_rgba)
			<sub_item_unfocus_rgba> = ($g_songlist_invalid_sub_item_unfocus_rgba)
		endif
	else
		music_store_kill_preview_music
		<item_unfocus_rgba> = ($g_music_store_item_unfocus_rgba)
		<sub_item_unfocus_rgba> = ($g_music_store_sub_item_unfocus_rgba)
	endif
	<id> :se_setprops {
		songlist_item_text_rgba = <item_unfocus_rgba>
		songlist_item_sub_text_rgba = <sub_item_unfocus_rgba>
		songlist_item_highlight_bar_alpha = 0.0
		time = <time>
	}
	if (<mode> = music_store)
		if (<ui_struct>.purchased = 1)
			<money_icon_rgba> = (($g_menu_colors).pure_white)
		else
			<money_icon_rgba> = <sub_item_unfocus_rgba>
		endif
		<id> :se_setprops {
			music_store_song_price_rgba = <sub_item_unfocus_rgba>
			music_store_money_icon_rgba = <money_icon_rgba>
			music_store_money_text_rgba = <money_icon_rgba>
			songlist_item_highlight_bar_alpha = 0.0
		}
	endif
endscript

script songlist_clear_playlist 
	songlist_clear
	playlist_clear
endscript

script songlist_clear 
	change \{current_playlist = [
		]}
	if screenelementexists \{id = songlist_detail_playlist}
		songlist_detail_playlist :obj_spawnscriptnow \{songlist_calculate_playlist_duration}
	endif
	change \{g_current_loaded_custom_playlist_index = -1}
endscript

script songlist_remove_first_song_in_playlist 
	if is_a_playlist_loaded
		removearrayelement array = ($current_playlist) index = 0
		change current_playlist = <array>
		if screenelementexists \{id = songlist_detail_playlist}
			songlist_detail_playlist :obj_spawnscriptnow \{songlist_calculate_playlist_duration}
		endif
	endif
endscript

script songlist_display_non_patched_dialog 
	change \{g_songlist_warning_active = 1}
	if screenelementexists \{id = current_menu}
		launchevent \{type = unfocus
			target = current_menu}
		current_menu :se_setprops \{block_events}
	endif
	songlist_component :getsingletag \{exclusive_device}
	create_dialog_box {
		heading_text = qs(0x24c5d3a9)
		body_text = qs(0x11eb8dc1)
		player_device = <exclusive_device>
		options = [
			{
				func = songlist_destroy_dialog_box
				text = qs(0x0e41fe46)
			}
		]
	}
endscript

script songlist_item_add_to_playlist 
	if NOT gotparam \{ui_struct}
		songlist_component :membfunc_songlist_uistack_getrangestruct
		<ui_struct> = <range_struct>
	endif
	if scriptisrunning \{songlist_item_focus}
		return
	endif
	current_menu :se_setprops \{block_events}
	if NOT issongselectable song = (<ui_struct>.song_checksum)
		current_menu :se_setprops \{unblock_events}
		ui_sfx \{menustate = setlist
			uitype = negativeselect}
		if gotparam \{song_not_patched}
			songlist_display_non_patched_dialog
		endif
		return
	endif
	if ($is_network_game = 1)
		net_songlist_add_song song = (<ui_struct>.song_checksum)
		current_menu :se_setprops \{unblock_events}
		return
	endif
	getarraysize ($current_playlist)
	if (<array_size> >= $g_max_playlist_size)
		current_menu :se_setprops \{unblock_events}
		return
	endif
	if ($g_songlist_force_num_songs_to_choose > 0)
		if (<array_size> >= $g_songlist_force_num_songs_to_choose)
			current_menu :se_setprops \{unblock_events}
			return
		endif
	endif
	if song_is_jamsession song = (<ui_struct>.song_checksum)
		formattext textname = text '%a' a = (<ui_struct>.filename)
		formattext checksumname = song_checksum '%i' i = <text>
	else
		song_checksum = (<ui_struct>.song_checksum)
	endif
	addarrayelement array = ($current_playlist) element = <song_checksum>
	change current_playlist = <array>
	if screenelementexists \{id = songlist_detail_playlist}
		songlist_detail_playlist :obj_spawnscriptnow \{songlist_calculate_playlist_duration}
	endif
	printf \{channel = playlist
		qs(0xbe2ec1c9)}
	debug_songlist_print_playlist
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = play_song || <mode> = leaderboard || <mode> = practice)
		songlist_continue device_num = <device_num>
		current_menu :se_setprops \{unblock_events}
		return
	endif
	soundevent \{event = audio_ui_setlist_select}
	songlist_is_song_in_playlist song = <song_checksum>
	if songlist_is_song_in_menu song = <song_checksum>
		if NOT gotparam \{id}
			obj_getid
			<id> = <objid>
		endif
		<song_options_struct> = {
			add_song = 0
			remove_song = 1
		}
		<pad_choose_script> = songlist_go_to_options
		<pad_choose_params> = {type = main song_item_id = <id> song_options_struct = <song_options_struct>}
		<id> :se_setprops {
			event_handlers = [
				{pad_choose <pad_choose_script> params = <pad_choose_params>}
			]
			replace_handlers
		}
		formattext textname = pos_text qs(0xc31d83ea) i = (<playlist_index> + 1)
		<id> :se_setprops {
			in_playlist_pos_alpha = 1.0
			in_playlist_pos_text = <pos_text>
		}
		<id> :settags playlist_index = <playlist_index>
		gamemode_gettype
		if NOT ininternetmode
		elseif (<type> = career)
			if ($g_net_leader_player_num != -1)
				if playerinfoequals ($g_net_leader_player_num) is_local_client = 1
					user_control_helper_change_text \{button = green
						text = qs(0x34ff4910)}
				endif
			endif
		endif
	endif
	getarraysize \{$current_playlist}
	formattext textname = pos_text qs(0xc31d83ea) i = (<array_size>)
	if (<array_size> > ($g_songlist_playlist_detail_items))
		getscreenelementchildren \{id = songlist_detail_playlist_vmenu}
		destroyscreenelement id = (<children> [0])
	endif
	if (<array_size> > ($g_songlist_mini_playlist_detail_items))
		getscreenelementchildren \{id = songlist_detail_mini_playlist_vmenu}
		destroyscreenelement id = (<children> [0])
	endif
	createscreenelement {
		type = descinterface
		desc = 'songlist_detail_playlist_item'
		parent = songlist_detail_playlist_vmenu
		songlist_item_text_text = (<ui_struct>.song_title)
		autosizedims = true
		in_playlist_pos_alpha = 1.0
		in_playlist_pos_text = <pos_text>
	}
	<id> :settags playlist_index = <playlist_index>
	createscreenelement {
		type = descinterface
		desc = 'songlist_detail_playlist_item'
		parent = songlist_detail_mini_playlist_vmenu
		songlist_item_text_text = (<ui_struct>.song_title)
		autosizedims = true
		in_playlist_pos_alpha = 1.0
		in_playlist_pos_text = <pos_text>
	}
	<id> :settags playlist_index = <playlist_index>
	songlist_detail :obj_spawnscriptnow \{songlist_detail_transition
		params = {
			desc = songlist_detail_playlist
			fade_time = 0
		}}
	if ($g_songlist_force_num_songs_to_choose > 0)
		getarraysize ($current_playlist)
		formattext textname = songs_added qs(0xc31d83ea) i = <array_size>
		songlist_detail_playlist :se_setprops {
			songlist_detail_playlist_num_songs_added_text = <songs_added>
		}
		getarraysize ($current_playlist)
		if (<array_size> = $g_songlist_force_num_songs_to_choose)
			songlist_allow_continue
		endif
	else
		songlist_allow_continue
	endif
	current_menu :se_setprops \{unblock_events}
endscript

script songlist_allow_continue 
	if ($g_songlist_warning_active = 1)
		return
	endif
	current_menu :se_setprops \{event_handlers = [
			{
				pad_start
				songlist_continue
			}
		]
		replace_handlers}
	current_menu :settags \{allow_continue = 1}
	if NOT user_control_helper_exists \{button = start}
		add_user_control_helper \{text = qs(0x25cd4a61)
			button = start
			z = 100000}
	endif
endscript

script songlist_disallow_continue 
	current_menu :se_setprops \{event_handlers = [
			{
				pad_start
				nullscript
			}
			{
				pad_option
				nullscript
			}
		]
		replace_handlers}
	current_menu :settags \{allow_continue = 0}
	user_control_destroy_helper \{button = start}
endscript

script songlist_item_remove_from_playlist 
	if NOT gotparam \{ui_struct}
		songlist_component :membfunc_songlist_uistack_getrangestruct
		<ui_struct> = <range_struct>
	endif
	if scriptisrunning \{songlist_item_focus}
		return
	endif
	if scriptisrunning \{songlist_continue}
		return
	endif
	if ($is_network_game = 1)
		gamemode_gettype
		if (<type> = career)
			if ($g_net_leader_player_num != -1)
				if playerinfoequals ($g_net_leader_player_num) is_local_client = 1
					net_songlist_remove_song song = (<ui_struct>.song_checksum)
				endif
			endif
		endif
		return
	endif
	songlist_item_remove_from_playlist_guts <...>
endscript

script songlist_item_remove_from_playlist_guts 
	soundevent \{event = audio_ui_setlist_remove}
	if NOT gotparam \{id}
		obj_getid
		<my_id> = <objid>
	else
		<my_id> = <id>
	endif
	if screenelementexists id = <my_id>
		<song_options_struct> = {
			add_song = 1
			remove_song = 0
		}
		<pad_choose_script> = songlist_go_to_options
		<pad_choose_params> = {type = main song_item_id = <my_id> song_options_struct = <song_options_struct>}
		<my_id> :se_setprops {
			songlist_item_text_rgba = ($g_songlist_item_focus_rgba)
			in_playlist_pos_alpha = 0.0
			event_handlers = [
				{pad_choose <pad_choose_script> params = <pad_choose_params>}
			]
			replace_handlers
		}
		<my_id> :getsingletag playlist_index
	endif
	songlist_get_song_playlist_detail_index playlist_index = <playlist_index> vmenu_id = songlist_detail_playlist_vmenu
	if gotparam \{playlist_detail_index}
		getscreenelementchildren \{id = songlist_detail_playlist_vmenu}
		getarraysize \{$current_playlist}
		if (<array_size> > ($g_songlist_playlist_detail_items))
			formattext textname = pos_text qs(0xc31d83ea) i = (<array_size> - ($g_songlist_playlist_detail_items))
			<passed_in_ui_struct> = <ui_struct>
			get_ui_song_struct_items song = ($current_playlist [((<array_size> - ($g_songlist_playlist_detail_items)) - 1)])
			createscreenelement {
				type = descinterface
				desc = 'songlist_detail_playlist_item'
				parent = songlist_detail_playlist_vmenu
				songlist_item_text_text = (<ui_struct>.song_title)
				autosizedims = true
				in_playlist_pos_alpha = 1.0
				in_playlist_pos_text = <pos_text>
			}
			songlist_detail_playlist_vmenu :menu_setitemindex index = ($g_songlist_playlist_detail_items) newindex = 0
			<id> :settags playlist_index = ((<array_size> - ($g_songlist_playlist_detail_items)) - 1)
			<ui_struct> = <passed_in_ui_struct>
			removeparameter \{passed_in_ui_struct}
		endif
		destroyscreenelement id = (<children> [<playlist_detail_index>])
	endif
	removeparameter \{playlist_detail_index}
	songlist_get_song_playlist_detail_index playlist_index = <playlist_index> vmenu_id = songlist_detail_mini_playlist_vmenu
	if gotparam \{playlist_detail_index}
		getscreenelementchildren \{id = songlist_detail_mini_playlist_vmenu}
		getarraysize \{$current_playlist}
		if (<array_size> > ($g_songlist_mini_playlist_detail_items))
			formattext textname = pos_text qs(0xc31d83ea) i = (<array_size> - ($g_songlist_mini_playlist_detail_items))
			<passed_in_ui_struct> = <ui_struct>
			get_ui_song_struct_items song = ($current_playlist [((<array_size> - ($g_songlist_mini_playlist_detail_items)) - 1)])
			createscreenelement {
				type = descinterface
				desc = 'songlist_detail_playlist_item'
				parent = songlist_detail_mini_playlist_vmenu
				songlist_item_text_text = (<ui_struct>.song_title)
				autosizedims = true
				in_playlist_pos_alpha = 1.0
				in_playlist_pos_text = <pos_text>
			}
			songlist_detail_mini_playlist_vmenu :menu_setitemindex index = ($g_songlist_mini_playlist_detail_items) newindex = 0
			<id> :settags playlist_index = ((<array_size> - ($g_songlist_mini_playlist_detail_items)) - 1)
			<ui_struct> = <passed_in_ui_struct>
			removeparameter \{passed_in_ui_struct}
		endif
		destroyscreenelement id = (<children> [<playlist_detail_index>])
	endif
	if screenelementexists id = <my_id>
		<my_id> :removetags playlist_index
	endif
	songlist_do_maintenance_on_list playlist_index = <playlist_index> list = songlist_detail_playlist_vmenu
	songlist_do_maintenance_on_list playlist_index = <playlist_index> list = songlist_detail_mini_playlist_vmenu
	songlist_do_maintenance_on_list playlist_index = <playlist_index> list = current_menu
	songlist_detail :obj_spawnscriptnow \{songlist_detail_transition
		params = {
			desc = songlist_detail_playlist
		}}
	if song_is_jamsession song = (<ui_struct>.song_checksum)
		formattext textname = text '%a' a = (<ui_struct>.filename)
		formattext checksumname = song_checksum '%i' i = <text>
	else
		song_checksum = (<ui_struct>.song_checksum)
	endif
	removearrayelement array = ($current_playlist) element = <song_checksum>
	change current_playlist = <array>
	if screenelementexists \{id = songlist_detail_playlist}
		songlist_detail_playlist :obj_spawnscriptnow \{songlist_calculate_playlist_duration}
	endif
	printf \{channel = playlist
		qs(0x6cdde419)}
	debug_songlist_print_playlist
	if screenelementexists id = <my_id>
		if NOT isscreenelementinfocus id = <my_id>
			<my_id> :obj_spawnscriptnow songlist_item_unfocus params = {ui_struct = <ui_struct>}
		endif
	endif
	getarraysize ($current_playlist)
	if NOT (<array_size> > 0)
		songlist_disallow_continue
	endif
	if ($g_songlist_force_num_songs_to_choose > 0)
		getarraysize ($current_playlist)
		formattext textname = songs_added qs(0xc31d83ea) i = <array_size>
		songlist_detail_playlist :se_setprops {
			songlist_detail_playlist_num_songs_added_text = <songs_added>
		}
		if NOT (<array_size> = $g_songlist_force_num_songs_to_choose)
			songlist_disallow_continue
		else
			songlist_allow_continue
		endif
	endif
endscript

script songlist_continue \{autosave_playlist = 1}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_event_wait_for_safe
	songlist_update_song_preview \{song = none}
	current_menu :se_setprops \{block_events}
	ui_sfx \{menustate = setlist
		uitype = select}
	if ininternetmode
		host_start_songlist_countdown
		return
	endif
	songlist_generate_song_array playlist = ($current_playlist)
	playlist_clear
	playlist_addsongarray song_array = <song_array> additional_props_array = <additional_props_array>
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = leaderboard)
		song = ($current_playlist [0])
		songlist_clear
		generic_event_choose state = uistate_award_case data = {is_popup no_targeting song = <song> device_num = <device_num>}
		return
	elseif (<mode> = practice)
		songlist_clear
		practice_setup_part_and_continue device_num = <device_num>
		return
	endif
	songlist_component :getsingletag \{tab_enabled}
	if (<tab_enabled> = 1)
		songlist_deinit_music_store
	endif
	<show_help_page> = 0
	gamemode_gettype
	switch (<type>)
		case career
		gman_challengemanagerfunc goal = <type> tool = challenges func = get_current_challenge
		gig_struct = ($<current_challenge>)
		venue = (<gig_struct>.venue)
		if structurecontains structure = ($levelzones.<venue>) name = loading_movie
			create_venue_loading_screen movie_params = ($levelzones.<venue>)
		else
			printstruct <gig_struct>
			scriptassert \{qs(0x2f9dfa76)}
		endif
		case quickplay
		universal_help_display_help_check help_context = quickplay_to_gameplay device_num = ($primary_controller)
		if (<show_help_page> = 1)
			generic_event_choose {
				state = uistate_universal_help
				data = {
					next_state_script = songlist_continue_for_quickplay
					next_state_params = {
						autosave_playlist = <autosave_playlist>
					}
					device_num = ($primary_controller)
					help_global_index = <help_index>
				}
			}
		else
			songlist_continue_for_quickplay autosave_playlist = <autosave_playlist>
		endif
		case freeplay
		ui_event \{event = menu_back}
		return
		case competitive
		if ($game_mode = fest_mode || $game_mode = fest_mode_team)
			display_competitive_rules_voting \{next_state = uistate_play_song
				voting_callback = songlist_voting_callback_continue}
			return
		else
			gman_startgamemodegoal
		endif
		change current_level = ($g_band_lobby_current_level)
		venue = ($g_band_lobby_current_level)
		if structurecontains structure = ($levelzones.<venue>) name = loading_movie
			create_venue_loading_screen movie_params = ($levelzones.<venue>)
		else
			create_loading_screen
		endif
		case practice
		practice_setup_part_and_continue device_num = <device_num>
		return
	endswitch
	if (<show_help_page> = 0)
		ui_event \{event = menu_change
			state = uistate_play_song}
	endif
endscript

script songlist_continue_for_quickplay \{autosave_playlist = !i1768515945}
	venue = ($g_band_lobby_current_level)
	gman_venuefunc {goal = quickplay tool = venue_handler func = set_venue params = {venue_name = <venue>}}
	if (<autosave_playlist> = 1)
		fill_auto_save_playlist
	endif
	if structurecontains structure = ($levelzones.<venue>) name = loading_movie
		create_venue_loading_screen movie_params = ($levelzones.<venue>)
	else
		create_loading_screen
	endif
	ui_event \{event = menu_change
		state = uistate_play_song}
endscript

script songlist_voting_callback_continue \{result = !q1768515945}
	printf \{qs(0x7d7081f8)}
	change competitive_rules = <result>
	gman_shutdowngamemodegoal
	gman_startgamemodegoal
endscript

script songlist_generate_song_array 
	additional_props_array = []
	index = 0
	getarraysize ($current_playlist)
	if (<array_size> > 0)
		begin
		get_ui_song_struct_items song = (<playlist> [<index>])
		additional_props = {}
		if structurecontains structure = <ui_struct> additional_props
			additional_props = (<ui_struct>.additional_props)
		endif
		if structurecontains structure = <additional_props> jam_index
			setarrayelement arrayname = playlist index = <index> newvalue = jamsession
		endif
		addarrayelement array = <additional_props_array> element = <additional_props>
		additional_props_array = <array>
		index = (<index> + 1)
		repeat <array_size>
	endif
	return additional_props_array = <array> song_array = <playlist>
endscript

script songlist_destroy 
	if screenelementexists \{id = songlist_component}
		songlist_component :membfunc_songlist_uistack_unregisterallcontentsources
		songlist_component :membfunc_songlist_uistack_getmode
		songlist_set_mode_sort_index mode = <mode>
	endif
	if scriptisrunning \{songlist_request_initial_page_when_ready}
		killspawnedscript \{name = songlist_request_initial_page_when_ready}
	endif
	setmenuautorepeattimes \{(0.3, 0.1)}
endscript

script songlist_unregister_content_source \{list_name = !q1768515945}
	contentmanfunc func = unregister_content_source name = <list_name>
endscript

script songlist_get_first_visible_item_info 
	songlist_smenu :scrollingmenu_getfirstvisibleindex
	getscreenelementchildren \{id = current_menu}
	if gotparam \{children}
		getarraysize <children>
		if (<array_size> > 0)
			<first_visible_id> = (<children> [<first_visible_index>])
			<first_visible_id> :getsingletag header
			<first_visible_id> :getsingletag song_checksum
			if (<header> = 0)
				return first_visible_song_checksum = <song_checksum> header = <header>
			else
				return header = <header>
			endif
		endif
	endif
endscript

script songlist_scroll_down 
	if screenelementexists \{id = songlist}
		songlist_component :getsingletag \{list_dirty}
		songlist_component :membfunc_songlist_uistack_getlistname
		songlist_component :membfunc_songlist_uistack_getlistbottom
		songlist_component :membfunc_songlist_uistack_getlistpagesize
		songlist_component :membfunc_songlist_uistack_getmaxmenuelements
		setmenuautorepeattimes ((0.3, 0.0) + (($g_songlist_scroll_speed) * (0.0, 1.0)))
		if (<list_dirty> = true)
			return
		endif
		songlist_component :membfunc_songlist_uistack_scrolldown
		if (<scroll_result> = proceed_as_normal)
			current_menu :getsingletag \{tag_selected_index}
			songlist_component :membfunc_songlist_uistack_getmaxmenuelements
			if (<tag_selected_index> = (<max_menu_elements> - 1))
				if songlist_component :membfunc_songlist_uistack_isitemanheader
					songlist_component :membfunc_songlist_uistack_decrementlistindex
					songlist_insert_item_bottom \{focus = 0}
					onexitrun \{songlist_scroll_down}
					return
				endif
				songlist_insert_item_bottom
			elseif (<tag_selected_index> = (<max_menu_elements> - 2))
				if songlist_component :membfunc_songlist_uistack_isitemanheader
					songlist_component :membfunc_songlist_uistack_decrementlistindex
					onexitrun \{songlist_scroll_down
						params = {
							force_insert = 1
						}}
					return
				endif
				if gotparam \{force_insert}
					songlist_insert_item_bottom
				endif
			endif
			if songlist_component :membfunc_songlist_uistack_isitemanheader
				songlist_component :membfunc_songlist_uistack_incrementmastervectorindex
			endif
			if NOT gotparam \{dont_update_slider}
				generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
					dir = down}
				songlist_scroll_sound
			endif
		elseif (<scroll_result> = request_data_range_down)
			songlist_component :membfunc_songlist_uistack_getlisttop
			songlist_component :membfunc_songlist_uistack_getlistbottom
			contentmanfunc {
				func = request_data
				name = <list_name>
				start_index = <list_top>
				end_index = <list_bottom>
				callback = songlist_callback_data_range
			}
			generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
				dir = down}
			songlist_scroll_sound
		elseif (<scroll_result> = request_page_down)
			contentmanfunc {
				func = more_data
				name = <list_name>
				page_down
				callback = songlist_callback_more_data_down
			}
		endif
	endif
endscript

script songlist_scroll_up 
	if screenelementexists \{id = songlist}
		songlist_component :getsingletag \{list_dirty}
		songlist_component :membfunc_songlist_uistack_getlistname
		songlist_component :membfunc_songlist_uistack_getlisttop
		songlist_component :membfunc_songlist_uistack_getlistpagesize
		songlist_component :membfunc_songlist_uistack_getmaxmenuelements
		if (<list_dirty> = true)
			return
		endif
		songlist_component :membfunc_songlist_uistack_scrollup
		if (<scroll_result> = proceed_as_normal)
			current_menu :getsingletag \{tag_selected_index}
			if (<tag_selected_index> = 0)
				if songlist_component :membfunc_songlist_uistack_isitemanheader
					songlist_component :membfunc_songlist_uistack_incrementlistindex
					songlist_insert_item_top \{focus = 0}
					onexitrun \{songlist_scroll_up}
					return
				endif
				songlist_insert_item_top
			elseif (<tag_selected_index> = 1)
				if songlist_component :membfunc_songlist_uistack_isitemanheader
					songlist_component :membfunc_songlist_uistack_incrementlistindex
					onexitrun \{songlist_scroll_up
						params = {
							force_insert = 1
						}}
					return
				endif
				if gotparam \{force_insert}
					songlist_insert_item_top
				endif
			endif
			if songlist_component :membfunc_songlist_uistack_isitemanheader
				songlist_component :membfunc_songlist_uistack_decrementmastervectorindex
			endif
			if NOT gotparam \{dont_update_slider}
				generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
					dir = up}
				songlist_scroll_sound
			endif
		elseif (<scroll_result> = request_data_range_up)
			songlist_component :membfunc_songlist_uistack_getlisttop
			songlist_component :membfunc_songlist_uistack_getlistbottom
			contentmanfunc {
				func = request_data
				name = <list_name>
				start_index = <list_top>
				end_index = <list_bottom>
				callback = songlist_callback_data_range
			}
			generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
				dir = up}
			songlist_scroll_sound
		elseif (<scroll_result> = request_page_up)
			contentmanfunc {
				func = more_data
				name = <list_name>
				page_up
				callback = songlist_callback_more_data_up
			}
		endif
	endif
endscript

script songlist_scroll_sound 
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = play_song)
		audio_ui_play_songlist_scroll_sfx
	elseif (<mode> = playlist)
		audio_ui_play_playlist_scroll_sfx
	elseif (<mode> = music_store)
		music_store_scroll_sfx
	else
		audio_ui_play_songlist_scroll_sfx
	endif
endscript

script songlist_callback_more_data_down 
	if NOT screenelementexists \{id = songlist}
		return
	endif
	songlist_component :membfunc_songlist_uistack_getlistname
	<sortspec> = {
		key = (($g_songlist_sort_array [($g_songlist_sort_index)]).key)
		alt_key = (($g_songlist_sort_array [($g_songlist_sort_index)]).alt_key)
		(($g_songlist_sort_array [($g_songlist_sort_index)]).progression)
	}
	songlist_component :membfunc_songlist_uistack_getlistindex
	songlist_component :membfunc_songlist_uistack_getfilterspec
	if (<more_data> = true)
		contentmanfunc {
			func = request_page
			name = <list_name>
			page_down
			seek = <list_index>
			sortspec = <sortspec>
			filterspec = <filterspec>
			invert_filterspec = <invert_filterspec>
			callback = songlist_callback_have_page_down
		}
		songlist_component :settags \{list_dirty = true}
	endif
endscript

script songlist_callback_more_data_up 
	if NOT screenelementexists \{id = songlist}
		return
	endif
	songlist_component :membfunc_songlist_uistack_getlistname
	<sortspec> = {
		key = (($g_songlist_sort_array [($g_songlist_sort_index)]).key)
		alt_key = (($g_songlist_sort_array [($g_songlist_sort_index)]).alt_key)
		(($g_songlist_sort_array [($g_songlist_sort_index)]).progression)
	}
	songlist_component :membfunc_songlist_uistack_getlistindex
	songlist_component :membfunc_songlist_uistack_getfilterspec
	if (<more_data> = true)
		contentmanfunc {
			func = request_page
			name = <list_name>
			page_up
			seek = <list_index>
			sortspec = <sortspec>
			filterspec = <filterspec>
			invert_filterspec = <invert_filterspec>
			callback = songlist_callback_have_page_up
		}
		songlist_component :settags \{list_dirty = true}
	endif
endscript

script songlist_callback_have_page_up 
	if NOT screenelementexists \{id = songlist}
		return
	endif
	songlist_request_new_data_range <...> dir = up
	generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
		dir = up}
endscript

script songlist_callback_have_page_down 
	if NOT screenelementexists \{id = songlist}
		return
	endif
	songlist_request_new_data_range <...> dir = down
	generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
		dir = down}
endscript

script songlist_request_new_data_range \{dir = !q1768515945}
	songlist_component :membfunc_songlist_uistack_getmode
	songlist_component :membfunc_songlist_uistack_getlistindex
	songlist_component :membfunc_songlist_uistack_getlisttop
	generic_scrollbar_wgt_set_resolution id = songlist_scrollbar_wgt num_elements = <content_size>
	formattext textname = num_songs qs(0xc31d83ea) i = <content_size>
	songlist :se_setprops songlist_songs_available_num_text = <num_songs>
	if (<content_size> = 1)
		if (<mode> = music_store)
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0xd20d2af6)}
		else
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0x7b899ac6)}
		endif
	else
		if (<mode> = music_store)
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0x08cb5377)}
		else
			songlist :se_setprops \{songlist_songs_available_text_text = qs(0x1cec7f8c)}
		endif
	endif
	if (<dir> = up)
		seek_index = (<seek_index> - 1)
	else
		seek_index = (<seek_index> + 1)
	endif
	seek_distance = (<list_index> - <list_top>)
	list_top = (<seek_index> - <seek_distance>)
	if (<list_top> < 0)
		list_top = 0
	endif
	list_bottom = (<list_top> + ($g_songlist_last_visible_index))
	if (<list_bottom> < <page_size>)
		songlist_component :membfunc_songlist_uistack_setlistindex list_index = <seek_index> seek_checksum = <seek_checksum>
		songlist_component :membfunc_songlist_uistack_setlisttop list_top = <list_top>
		songlist_component :membfunc_songlist_uistack_setlistbottom list_bottom = <list_bottom>
		songlist_component :membfunc_songlist_uistack_setlistpagesize list_page_size = <page_size>
		songlist_component :settags \{list_dirty = false}
		songlist_component :membfunc_songlist_uistack_updateheaderarray
		contentmanfunc {
			func = request_data
			name = <list_name>
			start_index = <list_top>
			end_index = <list_bottom>
			callback = songlist_callback_data_range
		}
	else
		scriptassert \{qs(0x869440a1)}
	endif
endscript

script songlist_slide_scroll 
	getlogicframe
	last_change = <logicframe>
	last_button = 0
	createscreenelement \{parent = root_window
		type = spriteelement
		texture = white
		pos = (550.0, 500.0)
		dims = (20.0, 50.0)
		just = [
			left
			center
		]}
	rate = 0.0
	damper = 0.8
	rate_scale = 100.0
	begin
	if guitargettouchpattern \{player = 1}
		getlogicframe
		if (<touch_pattern> < <last_button>)
			last_button = <touch_pattern>
			if (<rate> >= 0)
				if NOT (<logicframe> = <last_change>)
					rate = ((<rate> + (<rate_scale> / (<logicframe> - <last_change>))) / 2)
				endif
			else
				rate = 0
			endif
			last_change = <logicframe>
			rot_angle = 0
		elseif (<touch_pattern> > <last_button>)
			last_button = <touch_pattern>
			if (<rate> <= 0)
				if NOT (<logicframe> = <last_change>)
					rate = ((<rate> + (<rate_scale> / (<last_change> - <logicframe>))) / 2)
				endif
			else
				rate = 0
			endif
			last_change = <logicframe>
			rot_angle = 180
		endif
	endif
	if ((<rate> > 0.1) || (<rate> < -0.1))
		rate = (<damper> * <rate>)
	else
		rate = 0
	endif
	mathfloor <rate>
	casttointeger \{floor}
	setscreenelementprops id = <id> scale = ((0.0, 1.0) + ((1.0, 0.0) * <floor>)) rot_angle = <rot_angle>
	wait \{5
		gameframes}
	repeat
endscript

script songlist_back 
	songlist_component :membfunc_songlist_uistack_getmode
	gamemode_gettype
	if (<mode> = music_store)
		songlist_component :getsingletag \{visited_band_hub}
		if (<visited_band_hub> = 1)
			songlist_component :settags \{music_store_seek_override = true}
			songlist_music_store_disallow_sorting
			songlist_music_store_go_to_hub
		else
			ui_sfx \{menustate = generic
				uitype = back}
			destroy_dialog_box
			if ui_event_exists_in_stack \{name = 'band_lobby'}
				<back_state> = uistate_band_lobby
			else
				<back_state> = uistate_mainmenu
			endif
			generic_event_back state = <back_state>
		endif
	elseif (<mode> = import)
		ui_event \{event = menu_back}
	elseif (<mode> = leaderboard)
		songlist_leaderboard_back
	elseif (<type> = practice)
		ui_event \{event = menu_back
			data = {
				songlist_change_canceled = true
			}}
	elseif (<type> = freeplay)
		if (<mode> = playlist)
			if screenelementexists \{id = current_menu}
				launchevent \{type = unfocus
					target = current_menu}
				current_menu :se_setprops \{block_events}
			endif
			songlist_component :getsingletag \{exclusive_device}
			create_dialog_box {
				heading_text = qs(0xaa163738)
				body_text = qs(0xbdfb6886)
				player_device = <exclusive_device>
				options = [
					{
						func = songlist_destroy_dialog_box
						text = qs(0xdba6e8b9)
					}
					{
						func = songlist_freeplay_revert_playlist
						text = qs(0x9894be22)
					}
				]
			}
		else
			songlist_freeplay_revert_playlist
		endif
	elseif (<type> = career)
		if innetgame
			if ($net_song_countdown = 0)
				if playerinfoequals ($g_net_leader_player_num) is_local_client = 1
					net_career_songlist_back
				elseif ($primary_controller = <device_num>)
					if screenelementexists \{id = current_menu}
						launchevent \{type = unfocus
							target = current_menu}
						current_menu :se_setprops \{block_events}
					endif
					ui_sfx \{menustate = generic
						uitype = back}
					generic_event_choose \{state = uistate_online_quit_warning
						data = {
							is_popup
						}}
				endif
			endif
		else
			ui_event \{event = menu_back
				data = {
					use_selected_index
				}}
		endif
	elseif playerinfoequals ($g_net_leader_player_num) controller = <device_num>
		if ((($g_lobby_net_state = local) || ($g_lobby_net_state = net_private)) && ($net_song_countdown = 0))
			if ui_event_exists_in_stack \{name = 'team_select'}
				state = uistate_team_select
			else
				if ininternetmode
					if ishost
						quit_online_now
						return
					endif
				else
					state = uistate_band_lobby
				endif
			endif
			if ininternetmode
				sendstructure callback = ui_event data_to_send = {event = menu_back data = {state = <state>}}
			endif
			ui_event event = menu_back data = {state = <state>}
		elseif ($g_lobby_net_state = net_public && ($net_song_countdown = 0))
			if screenelementexists \{id = current_menu}
				launchevent \{type = unfocus
					target = current_menu}
				current_menu :se_setprops \{block_events}
			endif
			ui_sfx \{menustate = generic
				uitype = back}
			generic_event_choose \{state = uistate_online_quit_warning
				data = {
					is_popup
				}}
		endif
		hide_glitch \{num_frames = 10}
	elseif ($primary_controller = <device_num>)
		if innetgame
			if ($net_song_countdown = 0)
				if screenelementexists \{id = current_menu}
					launchevent \{type = unfocus
						target = current_menu}
					current_menu :se_setprops \{block_events}
				endif
				generic_event_choose \{state = uistate_online_quit_warning
					data = {
						is_popup
					}}
			endif
		else
			ui_event \{event = menu_back
				data = {
					state = uistate_band_lobby
				}}
		endif
	endif
endscript

script songlist_freeplay_revert_playlist 
	destroy_dialog_box
	ui_event \{event = menu_back
		data = {
			songlist_change_canceled = true
		}}
endscript

script songlist_detail_transition \{fade_time = $g_songlist_detail_fade_time
		desc = !q1768515945}
	setspawninstancelimits \{max = 1
		management = kill_oldest}
	if (<desc> = songlist_detail)
		songlist_detail :se_getprops
		<do_transition> = 0
		if gotparam \{force_transition}
			<do_transition> = 1
		endif
		if NOT (<alpha> = 1.0)
			<do_transition> = 1
		endif
		if (<do_transition> = 1)
			songlist_component :membfunc_songlist_uistack_getmode
			if NOT (<mode> = music_store)
				songlist_detail_playlist :se_setprops \{alpha = 0.0}
				if ($g_songlist_show_more_info = 1)
					songlist_detail :se_setprops \{songlist_detail_frame_1_cont_alpha = 0.0
						songlist_detail_frame_2_cont_alpha = 1.0}
				else
					songlist_detail :se_setprops \{songlist_detail_frame_1_cont_alpha = 1.0
						songlist_detail_frame_2_cont_alpha = 0.0}
				endif
			endif
			songlist_detail :se_setprops alpha = 1.0 time = <fade_time>
			songlist_detail :se_waitprops
		endif
	else
		songlist_detail_playlist :se_getprops
		<do_transition> = 0
		if gotparam \{force_transition}
			<do_transition> = 1
		endif
		if NOT (<alpha> = 1.0)
			<do_transition> = 1
		endif
		if (<do_transition> = 1)
			songlist_detail :se_setprops \{alpha = 0.0}
			songlist_detail_playlist :se_setprops alpha = 1.0 time = <fade_time>
			songlist_detail_playlist :se_waitprops
		endif
	endif
endscript

script songlist_sort \{index = !i1768515945}
	songlist_component :membfunc_songlist_uistack_setstickyheaderupdate \{update = 0}
	songlist_component :membfunc_songlist_uistack_getmode
	current_menu :getsingletag \{tag_selected_index}
	if NOT gotparam \{tag_selected_index}
		return
	endif
	if (<mode> = music_store)
		songlist_component :getsingletag \{visited_band_hub}
		if (<visited_band_hub> = 0)
			return
		endif
	endif
	current_menu :se_setprops \{block_events}
	songlist_change_sort_index index = <index>
	audio_ui_play_sort_songlist_sfx
	songlist_update_song_preview \{song = none}
	songlist_scrollbar_wgt :se_setprops \{alpha = 0.0}
	songlist_refresh_menus
	current_menu :se_setprops \{unblock_events}
endscript

script songlist_refresh_menus 
	songlist_component :membfunc_songlist_uistack_setstickyheaderupdate \{update = 0}
	songlist_clear_menus
	songlist_component :membfunc_songlist_uistack_getmode
	if NOT gotparam \{no_pivot}
		if NOT gotparam \{pivot_checksum}
			songlist_component :membfunc_songlist_uistack_getcurrentchecksum
			change g_songlist_current_pivot = <current_checksum>
		else
			change g_songlist_current_pivot = <pivot_checksum>
		endif
		songlist_component :membfunc_songlist_uistack_setlistindex \{list_index = 0}
		songlist_component :membfunc_songlist_uistack_setlisttop \{list_top = 0}
		songlist_component :membfunc_songlist_uistack_setlistbottom \{list_bottom = 0}
		songlist_component :membfunc_songlist_uistack_setlistpagesize \{list_page_size = 0}
		songlist_component :membfunc_songlist_uistack_zeromastervectorindex
	else
		change \{g_songlist_current_pivot = null}
		songlist_component :membfunc_songlist_uistack_initialize
	endif
	songlist_component :settags \{list_dirty = false
		initial_built = false}
	if (<mode> = playlist)
		songlist_detail :se_setprops \{songlist_detail_mini_playlistt_text_alpha = 1.0}
	else
	endif
	songlist_scrollbar_wgt :se_setprops \{scroll_thumb_pos = (0.0, 0.0)}
	songlist_update_ui
	songlist_pre_build
	if NOT gotparam \{no_focus}
		launchevent \{type = focus
			target = current_menu}
	endif
endscript

script songlist_clear_menus 
	songlist_component :membfunc_songlist_uistack_getmode
	destroyscreenelement \{id = current_menu
		preserve_parent}
	if NOT (<mode> = music_store)
		destroyscreenelement \{id = songlist_detail_playlist_vmenu
			preserve_parent}
		destroyscreenelement \{id = songlist_detail_mini_playlist_vmenu
			preserve_parent}
	endif
	setscreenelementlock \{id = current_menu
		off}
	setscreenelementlock \{id = current_menu
		on}
	if NOT (<mode> = music_store || <mode> = import)
		setscreenelementlock \{id = songlist_detail_playlist_vmenu
			off}
		setscreenelementlock \{id = songlist_detail_playlist_vmenu
			on}
		setscreenelementlock \{id = songlist_detail_mini_playlist_vmenu
			off}
		setscreenelementlock \{id = songlist_detail_mini_playlist_vmenu
			on}
	endif
endscript

script songlist_leaderboard_back 
	ui_sfx \{menustate = generic
		uitype = back}
	audio_ui_menu_music_on
	generic_event_back
endscript

script songlist_determine_leaderboard_instrument_setup 
	band_contains_guitar = false
	band_is_only_guitar = false
	band_contains_bass = false
	band_is_only_bass = false
	band_contains_vocals = false
	band_is_only_vocals = false
	band_contains_drum = false
	band_is_only_drum = false
	switch ($current_leaderboard_instrument)
		case 'guitar'
		band_contains_guitar = true
		band_is_only_guitar = true
		case 'backup'
		band_contains_bass = true
		band_is_only_bass = true
		case 'drums'
		band_contains_drum = true
		band_is_only_drum = true
		case 'mic'
		band_contains_vocals = true
		band_is_only_vocals = true
		case 'band'
		case 'altband'
		band_contains_guitar = true
		band_contains_bass = true
		band_contains_drum = true
		band_contains_vocals = true
		band_is_only_guitar = false
		band_is_only_bass = false
		band_is_only_drum = false
		band_is_only_vocals = false
	endswitch
	return band_instrument_setup = {
		guitar = {
			contains = <band_contains_guitar>
			only = <band_is_only_guitar>
		}
		bass = {
			contains = <band_contains_bass>
			only = <band_is_only_bass>
		}
		drum = {
			contains = <band_contains_drum>
			only = <band_is_only_drum>
		}
		vocals = {
			contains = <band_contains_vocals>
			only = <band_is_only_vocals>
		}
	}
endscript

script songlist_determine_band_instrument_setup 
	band_contains_guitar = false
	band_is_only_guitar = true
	band_contains_bass = false
	band_is_only_bass = true
	band_contains_vocals = false
	band_is_only_vocals = true
	band_contains_drum = false
	band_is_only_drum = true
	getnumplayersingame
	if (<num_players> > 0)
		getfirstplayer
		begin
		getplayerinfo <player> part
		switch <part>
			case guitar
			band_contains_guitar = true
			band_is_only_bass = false
			band_is_only_vocals = false
			band_is_only_drum = false
			case bass
			band_contains_bass = true
			band_is_only_guitar = false
			band_is_only_vocals = false
			band_is_only_drum = false
			case vocals
			band_contains_vocals = true
			band_is_only_guitar = false
			band_is_only_bass = false
			band_is_only_drum = false
			case drum
			band_contains_drum = true
			band_is_only_guitar = false
			band_is_only_bass = false
			band_is_only_vocals = false
		endswitch
		getnextplayer player = <player>
		repeat <num_players>
	endif
	return band_instrument_setup = {
		guitar = {
			contains = <band_contains_guitar>
			only = <band_is_only_guitar>
		}
		bass = {
			contains = <band_contains_bass>
			only = <band_is_only_bass>
		}
		drum = {
			contains = <band_contains_drum>
			only = <band_is_only_drum>
		}
		vocals = {
			contains = <band_contains_vocals>
			only = <band_is_only_vocals>
		}
	}
endscript

script get_highest_difficulty 
	highest_difficulty = beginner
	getnumplayersingame
	if (<num_players> > 0)
		getfirstplayer
		begin
		getplayerinfo <player> difficulty
		if difficulty_is_higher compare = <difficulty> against = <highest_difficulty>
			highest_difficulty = <difficulty>
		endif
		getnextplayer player = <player>
		repeat <num_players>
	endif
	return highest_difficulty = <highest_difficulty>
endscript

script difficulty_is_higher \{compare = !q1768515945
		against = !q1768515945}
	if (<against> = expert)
		return \{false}
	endif
	if (<compare> = expert)
		return \{true}
	endif
	if (<against> = hard)
		return \{false}
	endif
	if (<compare> = hard)
		return \{true}
	endif
	if (<against> = medium)
		return \{false}
	endif
	if (<compare> = medium)
		return \{true}
	endif
	if (<against> = easy)
		return \{false}
	endif
	if (<compare> = easy)
		return \{true}
	endif
	if (<against> != <compare>)
		scriptassert 'Improper compare %a vs %b' a = <against> b = <compare>
	endif
	if (<against> != beginner)
		scriptassert 'Unknown difficulty %a' a = <against>
	endif
	return \{false}
endscript

script songlist_get_data_for_songlist_stats {
		toprockerssong = ($last_song_played)
	}
	get_player_num_from_controller controller_index = ($primary_controller)
	if (<player_num> = -1)
		getfirstplayer \{in_game
			local}
		<player_num> = <player>
	endif
	get_highest_difficulty
	get_difficulty_text_nl difficulty = <highest_difficulty>
	get_song_prefix song = <toprockerssong>
	get_song_title song = <toprockerssong>
	getnumplayersingame
	if (<num_players> = 1)
		getplayerinfo <player_num> part
	else
		<part> = band
	endif
	if structurecontains structure = ($debug_songlist_props) <toprockerssong>
		return
	endif
	0x4cb6620f {
		song_prefix = <song_prefix>
		difficulty_text_nl = <difficulty_text_nl>
		part = ($part_list_props.<part>.text_nl)
	}
	get_difficulty_text difficulty = <highest_difficulty>
	getuppercasestring <song_title>
	song_title = <uppercasestring>
	getuppercasestring <difficulty_text>
	difficulty_text = <uppercasestring>
	if (<num_players> = 1)
		getscorefromdetailedstats player = <player_num>
		getstarsfromdetailedstats player = <player_num>
		get_percent_notes_hit player_index = <player_num> use_player_info = 0
	else
		getplayerinfo <player_num> band
		score = ($song_stats_backup_band [(<band> - 1)].score)
		stars = ($song_stats_backup_band [(<band> - 1)].stars)
		get_percent_notes_hit_for_band band = <band>
	endif
	casttointeger \{percent_notes_hit}
	if (<percent_notes_hit> < 0)
		percent_notes_hit = 0
	endif
	if (<percent_notes_hit> > 100)
		percent_notes_hit = 100
	endif
	casttointeger \{score}
	return songname = <songname> score = <score> stars = <stars> percent_notes_hit = <percent_notes_hit>
endscript

script increment_num_times_played \{song_id = !q1768515945}
	savegame_added_song = []
	getnumplayersingame \{local}
	if (<num_players> > 0)
		getfirstplayer \{local}
		begin
		get_actual_controller player = <player>
		get_savegame_from_controller controller = <controller>
		if NOT arraycontains array = <savegame_added_song> contains = <savegame>
			addarrayelement array = <savegame_added_song> element = <savegame>
			<savegame_added_song> = <array>
			getglobaltags <song_id> param = num_times_played savegame = <savegame>
			if (<num_times_played> < ($g_max_song_globaltag_plays))
				setglobaltags <song_id> params = {num_times_played = (<num_times_played> + 1)} savegame = <savegame>
			endif
		endif
		getnextplayer local player = <player>
		repeat <num_players>
	endif
endscript

script consider_setlist_score 
	requireparams \{[
			player_score
			player_stars
			player_percentage
		]
		all}
	getnumplayersingame \{local}
	if (<num_players> > 0)
		getfirstplayer \{local}
		begin
		get_actual_controller player = <player>
		get_savegame_from_controller controller = <controller>
		if 0x4cb6620f savegame = <savegame> noassert = 1 song_prefix = <song_prefix> difficulty_text_nl = <difficulty_text_nl> part = <part>
			if (<setlist_bestscore> < <player_score>)
				set_globaltag_song_info {savegame = <savegame> noassert = 1 song_prefix = <song_prefix> difficulty_text_nl = <difficulty_text_nl> part = <part>
					setlist_bestscore = <player_score> setlist_beststars = <player_stars> setlist_bestpercentage = <player_percentage>}
				new_hi = 1
			endif
		endif
		getnextplayer local player = <player>
		repeat <num_players>
	endif
	if gotparam \{new_hi}
		return \{true}
	endif
	return \{false}
endscript

script get_percent_notes_hit_for_band 
	<cumulative_percent_hit> = 0
	<num_members> = 0
	getnumplayersingame \{on_screen}
	if (<num_players_shown> > 0)
		getfirstplayer \{on_screen}
		begin
		getplayerinfo <player> band out = this_band
		if (<band> = <this_band>)
			get_percent_notes_hit player_index = <player>
			<cumulative_percent_hit> = (<cumulative_percent_hit> + <percent_notes_hit>)
			<num_members> = (<num_members> + 1)
		endif
		getnextplayer on_screen player = <player>
		repeat <num_players_shown>
	endif
	<percent_notes_hit> = 0
	if (<num_members> > 0)
		<percent_notes_hit> = (<cumulative_percent_hit> / <num_members>)
	endif
	return percent_notes_hit = <percent_notes_hit>
endscript

script debug_songlist_print_playlist 
	printstruct channel = playlist ($current_playlist)
	printf \{channel = playlist
		qs(0xcb943ab3)}
endscript

script debug_songlist_print_tags 
	songlist_component :gettags
	printstruct <...>
	printf \{qs(0xcb943ab3)}
endscript

script musicstore_format_price_text 
	if isxenonorwindx
		formattext textname = price_text qs(0x581d2af2) p = <price>
	else
		formatdecimals integer = <price> fractional = <price_fraction> num_decimals = <currency_decimals>
	endif
	return price_text = <price_text>
endscript

script music_store_scroll_sfx 
	soundevent \{event = audio_ui_jam_scroll}
endscript

script music_store_select_sfx 
	soundevent \{event = audio_ui_jam_select}
endscript

script music_store_back_sfx 
	soundevent \{event = audio_ui_jam_back}
endscript

script music_store_determine_currency 
	if isps3
		if marketplacefunc \{func = get_currency_info}
			return true currency = <currency_code> currency_decimals = <currency_decimals>
		else
			scriptassert \{'Currency info fetch failed'}
		endif
	endif
	return \{false}
endscript
