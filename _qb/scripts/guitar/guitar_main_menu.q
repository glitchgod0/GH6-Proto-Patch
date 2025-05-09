g_mainmenu_freeplay_timer = 180

script mainmenu_populate_menu_options_global 
	mainmenu_text = {
		career = {
			menu_item_text = qs(0xab3fd99b)
			helper_text = qs(0x3a276c3f)
		}
		quickplay = {
			menu_item_text = qs(0xfabdce2b)
			helper_text = qs(0x274833eb)
		}
		training = {
			menu_item_text = qs(0xd093953b)
			helper_text = qs(0x0fb34f95)
		}
		competitive = {
			menu_item_text = qs(0x6e63fe63)
			helper_text = qs(0x822a435b)
		}
		music_store = {
			menu_item_text = qs(0xa8e9637f)
			helper_text = qs(0xb21014b9)
		}
		music_central = {
			menu_item_text = $guitar_main_menu_ghstudio_string
			helper_text = $music_central_helper_text
		}
		creator = {
			menu_item_text = qs(0x9f894c1e)
			helper_text = qs(0x351586ce)
		}
		options = {
			menu_item_text = qs(0x976cf9e7)
			helper_text = qs(0x55e419ba)
		}
		award_case = {
			menu_item_text = qs(0xd85e39f1)
			helper_text = qs(0xb1e36b7c)
		}
		hall_of_records = {
			menu_item_text = qs(0xd8332915)
			helper_text = qs(0x472752be)
		}
		debugmenu = {
			menu_item_text = qs(0xafdfad24)
			helper_text = qs(0x03ac90f0)
		}
		motd = {
			menu_item_text = qs(0x3e13521a)
			helper_text = qs(0x381eb98a)
		}
		xbox_party = {
			menu_item_text = qs(0x58e064fa)
			helper_text = qs(0xde181a9e)
		}
	}
	change g_mainmenu_text = <mainmenu_text>
endscript
force_mainmenu_signin = 0

script mainmenu_kill_song_and_characters 
	closesonglogfile
	playlist_clear
endscript

script fix_primary_controller_for_autolaunch 
	if (($primary_controller) = -1)
		change \{primary_controller = 0}
	endif
	change \{primary_controller_assigned = 1}
endscript

script create_main_menu 
	setmenuautorepeattimes \{(0.3, 0.1)}
	disable_pause
	unpausegame
	disable_pause
	spawnscriptnow \{audio_ui_menu_music_on}
	change \{end_credits = 0}
	setplayerinfo \{1
		device = 0}
	setplayerinfo \{2
		device = 1}
	setplayerinfo \{3
		device = 2}
	setplayerinfo \{4
		device = 3}
	if ($new_message_of_the_day = 1)
		runscriptonscreenelement \{id = current_menu
			pop_in_new_downloads_notifier}
	endif
	if NOT ($invite_controller = -1)
		change \{invite_controller = -1}
		main_menu_select_online
		fadetoblack \{off
			time = 0}
	else
	endif
	if ($autolaunch_cas = 1)
		change \{autolaunch_cas = 0}
		spawnscriptdelayed frames = 20 ui_event_wait params = {event = menu_change data = {state = uistate_character_selection device_num = ($primary_controller) from_main_menu}}
	endif
	if ($autolaunch_jam = 1)
		change \{autolaunch_jam = 0}
		spawnscriptdelayed frames = 20 music_central_select_music_studio params = {device_num = ($primary_controller)}
	endif
	if ($autolaunch_lobby = 1)
		change \{autolaunch_lobby = 0}
		spawnscriptdelayed frames = 20 main_menu_select_band_lobby params = {device_num = ($primary_controller) lobby_mode = ($g_lobby_state)}
	endif
	getarraysize ($0x7356e5ae)
	if (<array_size> > 0)
		spawnscriptdelayed \{frames = 20
			0xb3c74245}
	endif
	runscriptonscreenelement \{id = current_menu
		mainmenu_freeplay_timer}
	tod_proxim_update_lightfx_viewport \{fxparam = $default_tod_manager
		viewport = bg_viewport
		time = 0}
	venue_screenfx
endscript

script create_main_menu_elements 
	if NOT ($invite_controller = -1)
		return
	endif
	createscreenelement \{parent = root_window
		id = mainmenu_id
		type = descinterface
		desc = 'mainmenu'
		tags = {
			motd_id = none
		}}
	mainmenu_setup_physics_elements \{screen_id = mainmenu_id}
	mainmenu_id :obj_spawnscriptnow \{fg_objects_1
		params = {
			desc_id = mainmenu_id
		}}
	mainmenu_id :obj_spawnscriptnow \{ampzilla_anim
		params = {
			desc_id = mainmenu_id
		}}
	mainmenu_id :obj_spawnscriptnow \{anim_clouds
		params = {
			desc_id = mainmenu_id
		}}
	mainmenu_setup_option \{choose_script = main_menu_select_band_lobby
		choose_params = {
			lobby_mode = quickplay
		}
		menu_item = quickplay}
	mainmenu_setup_option \{choose_script = main_menu_select_career
		choose_params = {
			lobby_mode = career
		}
		menu_item = career}
	mainmenu_setup_option \{choose_script = main_menu_select_music_store
		menu_item = music_store}
	mainmenu_setup_option \{choose_script = music_central_select_music_studio
		menu_item = music_central}
	mainmenu_setup_option \{choose_script = main_menu_select_options
		menu_item = options}
	if isxenonorwindx
		mainmenu_setup_option \{choose_script = main_menu_select_xbox_party
			menu_item = xbox_party}
	endif
	mainmenu_setup_option \{choose_script = main_menu_select_award_case
		menu_item = award_case}
	mainmenu_setup_option \{choose_script = main_menu_select_hall_of_records
		menu_item = hall_of_records}
	mainmenu_setup_option \{choose_script = main_menu_select_cas
		menu_item = creator}
	mainmenu_setup_option \{choose_script = main_menu_select_training
		menu_item = training}
	mainmenu_setup_option \{choose_script = main_menu_select_band_lobby
		choose_params = {
			lobby_mode = vs
		}
		menu_item = competitive}
	show_debug_menus = 0
	if ($enable_button_cheats = 1)
		<show_debug_menus> = 1
		if ($enable_debug_menus = 0)
			<show_debug_menus> = 0
		endif
	endif
	if (<show_debug_menus>)
		mainmenu_setup_option \{choose_script = main_menu_select_debug
			menu_item = debugmenu}
	endif
	current_menu :se_setprops \{event_handlers = [
			{
				pad_option2
				main_menu_select_freeplay
			}
		]}
	if NOT demobuild
		attempt_to_add_friend_feed \{menu = main
			parent_id = mainmenu_id
			event_handler = current_menu}
	endif
	set_focus_color
	set_unfocus_color
endscript

script main_menu_select_xbox_party 
	printf \{qs(0x7743abb8)}
	ui_sfx \{menustate = generic
		uitype = select}
	if checkforsignin controller_index = <device_num> network_platform_only
		netsessionfunc {
			obj = plat_party
			func = show_party_sessions_ui
			params = {
				controller_index = <device_num>
			}
		}
	else
		if checkforsignin controller_index = <device_num> local
			<body_text> = qs(0x113c41ea)
			<options> = [
				{
					func = main_menu_xbox_party_dialog_box_exit
					text = qs(0x0e41fe46)
				}
			]
		else
			<body_text> = qs(0x3facf63d)
			<options> = [
				{
					func = mainmenu_do_xbox_party_signin
					text = qs(0x17df5913)
				}
				{
					func = main_menu_xbox_party_dialog_box_exit
					text = qs(0xf7723015)
				}
			]
		endif
		if screenelementexists \{id = current_menu}
			launchevent \{type = unfocus
				target = current_menu}
			current_menu :se_setprops \{block_events}
		endif
		if screenelementexists \{id = motdinterface}
			launchevent \{type = unfocus
				target = motdinterface}
		endif
		create_dialog_box {
			dlg_z_priority = 1000
			heading_text = qs(0xaa163738)
			body_text = <body_text>
			parent = root_window
			no_background
			options = <options>
			player_device = <device_num>
		}
		assignalias id = <menu_id> alias = main_menu_select_xbox_party_warning
		launchevent \{type = focus
			target = main_menu_select_xbox_party_warning}
	endif
endscript

script main_menu_xbox_party_dialog_box_exit 
	printf \{qs(0x7fc8b8a0)}
	if screenelementexists \{id = main_menu_select_xbox_party_warning}
		destroy_dialog_box
	endif
	if screenelementexists \{id = motdinterface}
		launchevent \{type = focus
			target = motdinterface}
	endif
	if screenelementexists \{id = current_menu}
		current_menu :se_setprops \{unblock_events}
		launchevent \{type = focus
			target = current_menu}
	endif
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green
		z = 100
		all_buttons}
	add_user_control_helper \{text = qs(0x8a778398)
		button = yellow
		z = 100
		all_buttons}
	<helper_pill_id> :obj_spawnscriptnow sheen_highlight
	<helper_pill_id> :obj_spawnscriptnow sheen_highlight_bottom
	if screenelementexists \{id = motdinterface}
		add_user_control_helper \{text = qs(0x3e13521a)
			button = orange
			z = 100
			all_buttons}
	endif
endscript

script mainmenu_setup_physics_elements 
	requireparams \{[
			screen_id
		]
		all}
	if <screen_id> :desc_resolvealias name = alias_mainmenu_up_arrow
		arrow_up_id = <resolved_id>
	else
		scriptassert \{qs(0xfdafa36d)}
	endif
	if <screen_id> :desc_resolvealias name = alias_mainmenu_down_arrow
		arrow_down_id = <resolved_id>
	else
		scriptassert \{qs(0xfdafa36d)}
	endif
	if <screen_id> :desc_resolvealias name = alias_mainmenu_vmenu
		assignalias id = <resolved_id> alias = current_menu
		current_menu :settags \{smooth_morph_time = 0.1}
		<event_handlers> = [
			{pad_up mainmenu_pad_up params = {arrow_id = <arrow_up_id>}}
			{pad_up smoothmenuscroll params = {dir = -1 isvertical = true}}
			{pad_down smoothmenuscroll params = {dir = 1 isvertical = true}}
			{pad_down mainmenu_pad_down params = {arrow_id = <arrow_down_id>}}
			{menu_selection_changed ui_sfx params = {menustate = generic uitype = scrollup}}
		]
		current_menu :se_setprops event_handlers = <event_handlers>
	else
		scriptassert \{qs(0xfdafa36d)}
	endif
endscript

script mainmenu_setup_option 
	if screenelementexists \{id = mainmenu_id}
		requireparams \{[
				menu_item
			]
			all}
		menu_item_text = ($g_mainmenu_text.<menu_item>.menu_item_text)
	else
		requireparams \{[
				menu_item_text
			]
			all}
	endif
	if gotparam \{icon}
		if NOT gotparam \{icon_side}
			<icon_side> = left
		endif
		if (<icon_side> = right)
			<menurow_desc> = 'menurow_txt_ico_desc'
		else
			<menurow_desc> = 'menurow_ico_txt_desc'
		endif
		createscreenelement {
			type = descinterface
			parent = current_menu
			desc = <menurow_desc>
			just = [center center]
			autosizedims = true
			menurow_just = [center center]
			menurow_internal_just = [center center]
			menurow_txt_item_internal_just = [center center]
			menurow_txt_item_text = <menu_item_text>
			menurow_txt_item_font = fontgrid_text_a1
			menurow_txt_item_rgba = [216 181 117 255]
			menurow_ico_item_texture = <icon>
		}
	else
		createscreenelement {
			type = descinterface
			parent = current_menu
			desc = 'menurow_txt_desc'
			just = [center center]
			autosizedims = true
			menurow_just = [center center]
			menurow_internal_just = [center center]
			menurow_txt_item_internal_just = [center center]
			menurow_txt_item_text = <menu_item_text>
			menurow_txt_item_font = fontgrid_text_a1
			menurow_txt_item_rgba = [216 181 117 255]
		}
	endif
	if gotparam \{blank_entry}
		<id> :se_setprops {
			not_focusable
		}
	elseif gotparam \{not_focusable}
		<id> :se_setprops {
			not_focusable
			menurow_txt_item_rgba = [64 64 64 255]
		}
	else
		if screenelementexists \{id = mainmenu_id}
			<id> :settags {
				menu_item = <menu_item>
			}
		elseif gotparam \{helper_text}
			requireparams \{[
					screen_id
				]
				all}
			<id> :settags {
				helper_text = <helper_text>
				screen_id = <screen_id>
			}
		endif
		sound = true
		if gotparam \{no_sound}
			<sound> = false
		endif
		array = [
			{focus mainmenu_item_focus params = {sound = <sound>}}
			{unfocus mainmenu_item_unfocus params = {sound = <sound>}}
		]
		if gotparam \{choose_state}
			addarrayelement array = <array> element = {pad_choose generic_blocking_execute_script params = {pad_script = generic_event_choose pad_params = {state = <choose_state> data = {<choose_params>}}}}
			addarrayelement array = <array> element = {pad_choose ui_sfx params = {menustate = generic uitype = select}}
		elseif gotparam \{choose_script}
			addarrayelement array = <array> element = {pad_choose generic_blocking_execute_script params = {pad_script = <choose_script> pad_params = {<choose_params>}}}
			addarrayelement array = <array> element = {pad_choose ui_sfx params = {menustate = generic uitype = select}}
		endif
		if gotparam \{back_state}
			addarrayelement array = <array> element = {
				pad_back generic_event_back params = {state = <back_state>}
				pad_back ui_sfx params = {menustate = generic uitype = back}
			}
		elseif gotparam \{back_script}
			addarrayelement array = <array> element = {pad_back <back_script>}
		endif
		if gotparam \{additional_focus_script}
			addarrayelement array = <array> element = {focus <additional_focus_script> params = {<additional_focus_params>}}
		endif
		<id> :se_setprops event_handlers = <array>
	endif
	return mainmenu_item_id = <id>
endscript

script mainmenu_item_focus \{time = 0.05
		grow_scale = 1.3499999
		sound = true}
	if (<sound> = true)
	endif
	if NOT gotparam \{id}
		obj_getid
		<id> = <objid>
	endif
	if screenelementexists \{id = mainmenu_id}
		if <id> :getsingletag menu_item
			mainmenu_id :se_setprops {
				mainmenu_helper_text_text = ($g_mainmenu_text.<menu_item>.helper_text)
				motion = ease_in
				time = <time>
			}
		endif
	else
		<id> :gettags
		if gotparam \{helper_text}
			<screen_id> :se_setprops mainmenu_helper_text_text = <helper_text>
		endif
	endif
	<id> :se_setprops {
		menurow_scale = <grow_scale>
		menurow_txt_item_font = fontgrid_title_a1
		menurow_txt_item_rgba = [250 250 250 255]
		motion = ease_in
		time = <time>
	}
endscript

script mainmenu_item_unfocus \{time = 0.05}
	if NOT gotparam \{id}
		obj_getid
		<id> = <objid>
	endif
	<id> :se_setprops {
		menurow_scale = 1.0
		menurow_txt_item_font = fontgrid_text_a1
		menurow_txt_item_rgba = [216 181 117 255]
		motion = ease_in
		scale = <scale>
		time = <time>
	}
endscript

script mainmenu_pad_up 
	requireparams \{[
			arrow_id
		]
		all}
	<arrow_id> :obj_spawnscript mainmenu_do_scroll_glow
	<arrow_id> :obj_spawnscript mainmenu_do_arrow_pulse
	runscriptonscreenelement \{id = current_menu
		mainmenu_freeplay_timer}
endscript

script mainmenu_pad_down 
	requireparams \{[
			arrow_id
		]
		all}
	<arrow_id> :obj_spawnscript mainmenu_do_scroll_glow
	<arrow_id> :obj_spawnscript mainmenu_do_arrow_pulse params = {down}
	runscriptonscreenelement \{id = current_menu
		mainmenu_freeplay_timer}
endscript

script mainmenu_do_arrow_pulse 
	obj_getid
	createscreenelement {
		type = spriteelement
		parent = <objid>
		texture = mainmenu_wgt_barrel_arrow
		dims = (32.0, 32.0)
		pos = (16.0, 16.0)
		just = [center center]
		z_priority = 20
		rgba = [166 30 45 255]
	}
	<id> :se_setprops
	if gotparam \{down}
		<id> :se_setprops flip_h
	endif
	<id> :se_setprops scale = 1.3 time = 0.01 relative_scale
	<id> :se_waitprops
	<id> :se_setprops scale = 1.0 time = 0.1 relative_scale
	wait \{0.1
		seconds}
	destroyscreenelement id = <id>
endscript

script mainmenu_do_scroll_glow 
	obj_getid
	createscreenelement {
		type = spriteelement
		parent = <objid>
		texture = circle_gradient_64
		dims = (64.0, 64.0)
		pos = (16.0, 16.0)
		rgba = [255 215 0 255]
		just = [center center]
		z_priority = 20
		alpha = 0.2
		blend = add
	}
	<id> :se_setprops scale = 1.2 relative_scale
	<id> :se_setprops scale = (Random (@ 2.0 @ 2.5 @ 3.0 )) alpha = 0.0 time = 0.2 relative_scale motion = ease_out
	wait \{0.2
		seconds}
	destroyscreenelement id = <id>
endscript

script destroy_main_menu 
	generic_ui_destroy
	killspawnedscript \{name = anim_clouds}
	killspawnedscript \{name = fg_objects_1}
	killspawnedscript \{name = ampzilla_anim}
	destroyscreenelement \{id = mainmenu_id}
endscript

script main_menu_select_freeplay 
	play_cameracut \{prefix = 'cameras_no_band'}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	spawnscriptnow \{audio_ui_kill_menu_music_slowly}
	spawnscriptnow \{audio_crowd_play_surge_from_main_menu_to_freeplay}
	if NOT gotparam \{do_not_play_sfx}
		ui_sfx \{menustate = generic
			uitype = select}
	endif
	if gotparam \{device_num}
		set_primary_controller {
			device_num = <device_num>
			require_signin = 0
			state = uistate_freeplay
			data = {
				no_sound = 1
				clear_previous_stack
				freeplay_auto_join_device = <device_num>
			}
		}
	else
		ui_event \{event = menu_replace
			data = {
				state = uistate_freeplay
				clear_previous_stack
			}}
	endif
endscript

script main_menu_select_career 
	universal_help_display_help_check help_context = career_lobby device_num = <device_num>
	if (<show_help_page> = 1)
		generic_event_choose {
			state = uistate_universal_help
			data = {
				next_state_script = main_menu_enter_career
				next_state_params = {
					device_num = <device_num>
				}
				help_global_index = <help_index>
				device_num = <device_num>
			}
		}
	else
		main_menu_enter_career device_num = <device_num>
	endif
endscript

script main_menu_enter_career 
	stoprendering
	main_menu_select_band_lobby lobby_mode = career device_num = <device_num>
endscript

script main_menu_select_band_lobby \{state = uistate_band_lobby
		data = {
		}}
	stoprendering
	requireparams \{[
			lobby_mode
		]
		all}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	setplayerinfo \{1
		controller = 0}
	setplayerinfo \{2
		controller = 1}
	setplayerinfo \{3
		controller = 2}
	setplayerinfo \{4
		controller = 3}
	change g_lobby_state = <lobby_mode>
	if checksumequals a = <lobby_mode> b = career
		if has_completed_forced_career_flow device_num = <device_num>
			change \{g_lobby_enter_from_main_menu = 1}
		endif
	else
		change \{g_lobby_enter_from_main_menu = 1}
	endif
	<data> = {<data> device_num = <device_num>}
	ui_sfx \{menustate = generic
		uitype = select}
	set_primary_controller device_num = <device_num> state = <state> data = <data> optional_signin = 1
endscript

script main_menu_select_online 
	hide_glitch \{num_frames = 40}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_sfx \{menustate = generic
		uitype = select}
	set_primary_controller device_num = <device_num> state = uistate_net_setup require_live = 1
endscript

script main_menu_select_music_central 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_sfx \{menustate = generic
		uitype = select}
	set_primary_controller device_num = <device_num> state = uistate_music_central
endscript

script main_menu_select_cas 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	hide_glitch \{num_frames = 10}
	lightshow_notingameplay_setmood \{mood = band_lobby}
	play_cameracut \{prefix = 'cameras_no_band'}
	killspawnedscript \{name = persistent_band_cancel_lobby}
	ui_sfx \{menustate = generic
		uitype = select}
	universal_help_display_help_check help_context = rock_star_creator device_num = <device_num>
	if (<show_help_page> = 1)
		set_primary_controller {
			device_num = <device_num>
			state = uistate_universal_help
			optional_signin = 1
			data = {
				next_state_name = uistate_character_selection
				next_state_params = {
					device_num = <device_num>
					from_main_menu
				}
				help_global_index = <help_index>
				device_num = <device_num>
			}
		}
	else
		set_primary_controller device_num = <device_num> state = uistate_character_selection optional_signin = 1 data = {device_num = <device_num> from_main_menu}
	endif
endscript

script main_menu_select_training 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	hide_glitch \{num_frames = 15}
	universal_help_display_help_check help_context = training_menu device_num = <device_num>
	ui_sfx \{menustate = generic
		uitype = select}
	if (<show_help_page> = 1)
		set_primary_controller {
			device_num = <device_num>
			state = uistate_universal_help
			require_signin = 0
			data = {
				next_state_name = uistate_select_training
				next_state_params = {
					from_main_menu = 1
					no_sound = 1
				}
				help_global_index = <help_index>
				device_num = <device_num>
			}
		}
	else
		set_primary_controller device_num = <device_num> state = uistate_select_training require_signin = 0 data = {from_main_menu = 1 no_sound = 1}
	endif
endscript

script main_menu_select_options 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	hide_glitch \{num_frames = 5}
	universal_help_display_help_check help_context = training_menu device_num = <device_num>
	ui_sfx \{menustate = generic
		uitype = select}
	if (<show_help_page> = 1)
		set_primary_controller {
			device_num = <device_num>
			optional_signin = 1
			state = uistate_universal_help
			data = {
				next_state_name = uistate_options
				next_state_params = {
					no_sound = 1
				}
				help_global_index = <help_index>
				device_num = <device_num>
			}
		}
	else
		set_primary_controller device_num = <device_num> optional_signin = 1 state = uistate_options data = {no_sound = 1}
	endif
endscript

script main_menu_select_leaderboards 
	change \{rich_presence_context = presence_leaderboards}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	hide_glitch \{num_frames = 5}
	universal_help_display_help_check help_context = options_menu device_num = <device_num>
	ui_sfx \{menustate = generic
		uitype = select}
	if (<show_help_page> = 1)
		set_primary_controller {
			device_num = <device_num>
			state = uistate_universal_help
			require_signin = 0
			data = {
				next_state_name = uistate_leaderboard_instrument
				next_state_params = {
					no_sound = 1
				}
				help_global_index = <help_index>
				device_num = <device_num>
			}
		}
	else
		set_primary_controller device_num = <device_num> require_signin = 0 state = uistate_leaderboard_instrument data = {no_sound = 1}
	endif
endscript

script main_menu_select_award_case 
	change \{rich_presence_context = presence_leaderboards}
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	hide_glitch \{num_frames = 5}
	ui_sfx \{menustate = generic
		uitype = select}
	set_primary_controller device_num = <device_num> state = uistate_songlist leaderboards = 1 data = {mode = leaderboard device_num = <device_num>}
endscript

script main_menu_select_hall_of_records 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_sfx \{menustate = generic
		uitype = select}
	set_primary_controller device_num = <device_num> state = uistate_hall_of_records
endscript

script main_menu_select_debug 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_sfx \{menustate = generic
		uitype = select}
	generic_event_choose \{state = uistate_debug}
endscript

script main_menu_select_music_store 
	universal_help_display_help_check help_context = music_store device_num = <device_num>
	ui_sfx \{menustate = generic
		uitype = select}
	if (<show_help_page> = 1)
		generic_event_choose {
			state = uistate_universal_help
			data = {
				next_state_script = set_primary_controller
				next_state_params = {
					device_num = <device_num>
					event = menu_replace
					require_live = 1
					musicstore = 1
					state = uistate_songlist
					data = {
						mode = music_store
						no_sound = 1
					}
				}
				help_global_index = <help_index>
				device_num = <device_num>
			}
		}
	else
		set_primary_controller device_num = <device_num> require_live = 1 musicstore = 1 state = uistate_songlist data = {mode = music_store no_sound = 1}
	endif
endscript

script main_menu_select_motd 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_sfx \{menustate = generic
		uitype = select}
	generic_event_choose \{state = uistate_motd}
endscript

script main_menu_select_vip 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_sfx \{menustate = generic
		uitype = select}
	generic_event_choose \{state = uistate_vip_invite}
endscript

script pop_in_new_downloads_notifier \{time = 0.5}
	wait \{0.5
		second}
	if NOT screenelementexists \{id = main_menu_text_container}
		return
	endif
	pos = (100.0, 390.0)
	text = qs(0x40fdb3fc)
	createscreenelement {
		type = textelement
		parent = main_menu_text_container
		text = <text>
		scale = 0.5
		rgba = [255 255 205 255]
		just = [center center]
		font_spacing = 5
		font = fontgrid_text_a3
		pos = <pos>
		z_priority = 5
		alpha = 0
	}
	getscreenelementdims id = <id>
	if (<width> >= 500)
		setscreenelementprops id = <id> scale = 1
		fit_text_in_rectangle id = <id> only_if_larger_x = 1 dims = ((500.0, 0.0) + <height> * (0.0, 1.0)) keep_ar = 1
	endif
	legacydoscreenelementmorph id = <id> alpha = 1 time = <time>
	createscreenelement {
		type = textelement
		parent = main_menu_text_container
		id = new_downloads_text_glow
		text = <text>
		scale = 0.5
		rgba = [255 255 255 255]
		font = fontgrid_text_a3
		just = [center center]
		font_spacing = 5
		pos = <pos>
		z_priority = 6
		alpha = 0
	}
	getscreenelementdims id = <id>
	if (<width> >= 500)
		setscreenelementprops id = <id> scale = 1
		fit_text_in_rectangle id = <id> only_if_larger_x = 1 dims = ((500.0, 0.0) + <height> * (0.0, 1.0)) keep_ar = 1
	endif
	legacydoscreenelementmorph id = <id> alpha = 1 time = <time>
	createscreenelement {
		type = spriteelement
		parent = main_menu_text_container
		tex = white
		pos = (<pos>)
		just = [center center]
		rgba = [170 90 35 255]
		z = 4
		dims = ((<width> + 20) * (1.0, 0.0) + (0.0, 1.0) * (<height> + 10))
		alpha = 0
	}
	legacydoscreenelementmorph id = <id> alpha = 1 time = <time>
	createscreenelement {
		type = spriteelement
		parent = main_menu_text_container
		tex = character_hub_hilite_bookend
		just = [right center]
		rgba = [170 90 35 255]
		z = 4
		pos = ((<pos>) - <width> * (0.5, 0.0) - (6.0, 1.0))
		dims = (<height> * (1.0, 1.0))
		flip_v
		alpha = 0
	}
	legacydoscreenelementmorph id = <id> alpha = 1 time = <time>
	createscreenelement {
		type = spriteelement
		parent = main_menu_text_container
		tex = character_hub_hilite_bookend
		just = [left center]
		rgba = [170 90 35 255]
		z = 4
		pos = ((<pos>) + <width> * (0.5, 0.0) + (6.0, 1.0))
		dims = (<height> * (1.0, 1.0))
		alpha = 0
	}
	legacydoscreenelementmorph id = <id> alpha = 1 time = <time>
	spawnscriptnow \{glow_new_downloads_text
		params = {
			time = 0.75
		}}
endscript

script main_menu_select_generic 
	if screenelementexists \{id = current_menu}
		launchevent \{type = unfocus
			target = current_menu}
	endif
	if gotparam \{dont_clear_stack}
		ui_sfx \{menustate = generic
			uitype = select}
		generic_event_choose state = <state> data = {<data>}
	else
		ui_sfx \{menustate = generic
			uitype = select}
		generic_event_choose state = <state> data = {<data>}
	endif
endscript

script set_primary_controller \{event = menu_change
		require_signin = 1}
	if screenelementexists \{id = current_menu}
		launchevent \{type = unfocus
			target = current_menu}
	endif
	if ((gotparam force) || ($force_mainmenu_signin = 1))
		change \{primary_controller_assigned = 0}
		change \{primary_controller = -1}
		change \{force_mainmenu_signin = 0}
	endif
	change \{signin_jam_mode = 0}
	if ($game_mode = freeplay)
		change \{game_mode = quickplay}
	endif
	if gotparam \{jam}
		if ($jam_view_cam_created = 1)
			scriptassert \{'logic error, this value should be zero here'}
		endif
		change \{signin_jam_mode = 1}
		generic_event_choose event = <event> state = uistate_signin data = {device_num = <device_num> allow_back = 1 new_state = <state> new_data = {<data> jam = 1} jam = 1 require_signin = <require_signin> require_live = <require_live>}
	else
		if ($skip_signin = 1)
			ui_event event = menu_change data = <...>
		else
			generic_event_choose event = <event> no_sound state = uistate_signin data = {device_num = <device_num> allow_back = 1 new_state = <state> new_data = <data> require_signin = <require_signin> require_live = <require_live> downloads = <downloads> leaderboards = <leaderboards> musicstore = <musicstore> optional_signin = <optional_signin>}
		endif
	endif
endscript

script mainmenu_freeplay_timer 
	setscriptcannotpause
	setspawninstancelimits \{max = 1
		management = kill_oldest}
	wait ($g_mainmenu_freeplay_timer) seconds
	main_menu_select_freeplay \{do_not_play_sfx}
endscript

script mainmenu_freeplay_timer_pause 
	begin
	spawnscriptnow \{mainmenu_freeplay_timer}
	wait \{1
		gameframe}
	repeat
endscript

script mainmenu_do_xbox_party_signin \{device_num = !i1768515945}
	ui_sfx \{menustate = generic
		uitype = select}
	main_menu_xbox_party_dialog_box_exit
	netsessionfunc \{func = showsigninui
		params = {
			online_only
		}
		breakpoint = 0}
	wait_for_blade_complete
	if checkforsignin controller_index = <device_num> network_platform_only
		netsessionfunc {
			obj = plat_party
			func = show_party_sessions_ui
			params = {
				controller_index = <device_num>
			}
		}
	endif
endscript

script ampzilla_anim \{desc_id = !q1768515945}
	if <desc_id> :desc_resolvealias name = alias_ampzilla_phys1
		assignalias id = <resolved_id> alias = ampzilla_phys1_id
	else
		scriptassert \{qs(0xf8dc3bb9)}
	endif
	if <desc_id> :desc_resolvealias name = alias_mainmenu_dude
		assignalias id = <resolved_id> alias = mainmenu_dude_id
	else
		scriptassert \{qs(0x32f98d30)}
	endif
	if <desc_id> :desc_resolvealias name = alias_mainmenu_fg_chain
		assignalias id = <resolved_id> alias = mainmenu_fg_chain_id
	else
		scriptassert \{qs(0x32f98d30)}
	endif
	if <desc_id> :desc_resolvealias name = alias_mainmenu_menubg1
		assignalias id = <resolved_id> alias = mainmenu_menubg1_id
	else
		scriptassert \{qs(0x32f98d30)}
	endif
	if <desc_id> :desc_resolvealias name = alias_mainmenu_axestone
		assignalias id = <resolved_id> alias = mainmenu_axestone_id
	else
		scriptassert \{qs(0x32f98d30)}
	endif
	if <desc_id> :desc_resolvealias name = alias_mainmenu_bgoutrock
		assignalias id = <resolved_id> alias = mainmenu_bgoutrock_id
	else
		scriptassert \{qs(0x32f98d30)}
	endif
	<desc_id> :obj_spawnscriptnow create_2d_spring_system params = {desc_id = ampzilla_phys1_id num_springs = 1 objid1 = anchor_spring_1 objid2 = physics_spring_1 stiffness = 0.01 rest_length = 1}
	<desc_id> :obj_spawnscriptnow create_2d_spring_system params = {desc_id = mainmenu_fg_chain_id num_springs = 1 objid1 = anchor_spring_1 objid2 = physics_spring_1 stiffness = 0.005 rest_length = 1}
	<desc_id> :obj_spawnscriptnow create_2d_spring_system params = {desc_id = mainmenu_axestone_id num_springs = 1 objid1 = anchor_spring_1 objid2 = physics_spring_1 stiffness = 0.005 rest_length = 1}
endscript

script fg_objects_1 
endscript

script anim_clouds \{desc_id = !q1768515945}
	<desc_id> :desc_resolvealias name = alias_mainmenu_anim_cloud_1 param = mainmenu_anim_cloud_1_id
	<mainmenu_anim_cloud_1_id> :obj_spawnscript cloud_drift_leftoright
	<desc_id> :desc_resolvealias name = alias_mainmenu_anim_cloud_2 param = mainmenu_anim_cloud_2_id
	<mainmenu_anim_cloud_2_id> :obj_spawnscript cloud_drift_righttoleft
endscript

script cloud_drift_leftoright 
	begin
	r = RandomInteger (1.0, 4.0)
	time = Random (@ 30 @ 25 @ 15 @ 35 )
	switch <r>
		case 1
		<start_pos> = (-800.0, -107.0)
		<end_pos> = (800.0, -107.0)
		<z_priority> = 10
		<scale> = (2.2, 2.2)
		case 2
		<start_pos> = (-800.0, 200.0)
		<end_pos> = (800.0, 200.0)
		<z_priority> = 15
		<scale> = (2.5, 2.5)
		case 3
		<start_pos> = (-800.0, 145.0)
		<end_pos> = (800.0, 145.0)
		<z_priority> = 3
		<scale> = (3.01, 3.01)
		default
		<start_pos> = (-800.0, -200.0)
		<end_pos> = (800.0, -200.0)
		<z_priority> = 20
		<scale> = (2.6, 2.6)
	endswitch
	se_setprops pos = <start_pos>
	se_setprops scale = <scale>
	se_setprops z_priority = <z_priority> time = 0
	se_waitprops
	se_setprops pos = <end_pos> time = <time>
	se_waitprops
	repeat
endscript

script cloud_drift_righttoleft 
	begin
	time = Random (@ 30 @ 25 @ 15 @ 35 )
	r = RandomInteger (1.0, 4.0)
	switch <r>
		case 1
		<start_pos> = (700.0, -10.0)
		<end_pos> = (-800.0, -10.0)
		<z_priority> = 11
		<scale> = (2.2, 2.2)
		case 2
		<start_pos> = (700.0, 201.0)
		<end_pos> = (-800.0, 201.0)
		<z_priority> = 5
		<scale> = (2.5, 2.5)
		case 3
		<start_pos> = (700.0, -145.0)
		<end_pos> = (-800.0, -145.0)
		<z_priority> = 3
		<scale> = (2.01, 2.01)
		default
		<start_pos> = (700.0, -20.0)
		<end_pos> = (-800.0, -20.0)
		<z_priority> = 20
		<scale> = (2.6, 2.6)
	endswitch
	se_setprops pos = <start_pos>
	se_setprops scale = <scale>
	se_setprops z_priority = <z_priority> time = 0
	se_waitprops
	se_setprops pos = <end_pos> time = <time>
	se_waitprops
	wait \{1
		second}
	repeat
endscript
