
script ui_init_song_breakdown_shreddfest_match_complete 
	change \{song_breakdown_countdown_time_added = 0}
	change \{respond_to_signin_changed_func = ui_signin_changed_func}
	change \{song_breakdown_countdown_time = -1}
endscript

script ui_create_song_breakdown_shreddfest_match_complete 
	soundevent \{event = audio_ui_song_complete_menu_in}
	session_finished = 0
	playlist_getcurrentsongindex
	playlist_getsize
	song_num = <current_song_index>
	if ((gotparam continue_setlist_transition) || (gotparam add_setlist_continue_handlers))
		song_num = (<current_song_index> - 1)
	endif
	if (<song_num> != <playlist_size>)
		formattext \{textname = title_text
			qs(0xc4e0b900)}
		<session_finished> = 0
	else
		formattext \{textname = title_text
			qs(0xb2e8bd3f)}
		<session_finished> = 1
	endif
	formattext \{textname = title_text
		qs(0xb2e8bd3f)}
	formattext textname = game_tally_text qs(0xc39c5fc2) x = <song_num> y = <playlist_size>
	if NOT teammodeequals \{team_mode = two_teams}
		createscreenelement {
			parent = root_window
			id = song_complete_shreddfest_id
			type = descinterface
			desc = 'vs_summary'
			headline_text = <title_text>
			tally_text = <game_tally_text>
			song_summary_badge_winner_alpha = 0
			tags = {
				transition_param = none
			}
		}
		if song_complete_shreddfest_id :desc_resolvealias \{name = alias_highlight_sparkle
				param = highlight_sparkle_id}
			<highlight_sparkle_id> :obj_spawnscript ui_rotate
		else
			scriptassert \{'dschorn1'}
		endif
		if song_complete_shreddfest_id :desc_resolvealias \{name = alias_glow_anim
				param = glow_anim_id}
			<glow_anim_id> :obj_spawnscript ui_alphablink_02
		else
			scriptassert \{'dschorn1'}
		endif
	else
		createscreenelement {
			parent = root_window
			id = song_complete_shreddfest_id
			type = descinterface
			desc = 'vs_summary_team'
			headline_text = <title_text>
			tally_text = <game_tally_text>
			song_summary_badge_winner_alpha = 0
			tags = {
				transition_param = none
			}
		}
	endif
	song_breakdown_check_bot_play
	if (<bot_play> = 0)
		song_breakdown_get_exclusive_devices
		if screenelementexists \{id = song_complete_shreddfest_id}
			song_complete_shreddfest_id :se_setprops {
				exclusive_device = <exclusive_devices>
			}
		endif
	endif
	if screenelementexists \{id = song_complete_shreddfest_id}
		if NOT teammodeequals \{team_mode = two_teams}
			ui_song_breakdown_smc_populate_for_single
		else
			ui_song_breakdown_smc_populate_for_teams
		endif
		ui_song_breakdown_smc_setup_handler_scripts <...>
		launchevent \{type = focus
			target = song_complete_shreddfest_id}
	endif
endscript

script ui_song_breakdown_smc_populate_for_single 
	ui_song_breakdown_determine_order_from_session_points
	getarraysize <order>
	order_idx = 0
	if screenelementexists \{id = song_complete_shreddfest_id}
		if song_complete_shreddfest_id :desc_resolvealias \{name = alias_player_stack
				param = player_menu_id}
			winning_strip_pos = (0.0, 0.0)
			song_breakdown_smc_single_check_for_tie_winner order = <order>
			begin
			getnumplayersingame
			if (<num_players> > 0)
				getfirstplayer
				begin
				getplayerinfo <player> band
				if (<band> = (<order> [<order_idx>].band_num))
					ui_song_breakdown_get_basic_player_data player_index = <player>
					if ((<order_idx> = 0) && (<is_tie> = 0))
						player_text_rgba = gh5_gold_md
						player_bg_rgba = gh5_gold_md
						player_position_rgba = gh5_gold_md
						player_points_rgba = <player_position_rgba>
						player_units_rgba = <player_position_rgba>
						icon_instrument_alpha = 0.3
						icon_instrument_dims = (112.0, 112.0)
						icon_instrument_rgba = <player_position_rgba>
						winning_player = 1
					else
						formattext checksumname = player_text_rgba 'p%i_lt' i = (<order> [<order_idx>].band_num)
						formattext checksumname = player_position_rgba 'p%i_lt' i = (<order> [<order_idx>].band_num)
						player_points_rgba = <player_position_rgba>
						player_units_rgba = <player_position_rgba>
						formattext checksumname = player_bg_rgba 'p%i_dk' i = (<order> [<order_idx>].band_num)
						icon_instrument_alpha = 0.3
						icon_instrument_dims = (112.0, 112.0)
						icon_instrument_rgba = <player_position_rgba>
						winning_player = 0
					endif
					createscreenelement {
						parent = <player_menu_id>
						type = containerelement
						dims = (100.0, 75.0)
						pos_anchor = [left , top]
						just = [center , center]
					}
					if (<order_idx> = 0)
						if (<is_tie> = 0)
							formattext textname = winner_text qs(0x8113e038) p = <player_name_text>
							position_text = qs(0x03ac90f0)
						else
							formattext \{textname = winner_text
								qs(0x238e0b78)}
							formattext textname = position_text qs(0x66680619) p = (<order_idx> + 1)
						endif
						song_complete_shreddfest_id :se_setprops {
							message_text = <winner_text>
						}
					else
						formattext textname = position_text qs(0x66680619) p = (<order_idx> + 1)
					endif
					formattext textname = points_text qs(0x66680619) p = (<order> [<order_idx>].session_points) usecommas
					createscreenelement {
						parent = <id>
						type = descinterface
						desc = 'vs_summary_player_x8'
						dims = (508.0, 140.0)
						pos_anchor = [center , center]
						just = [center , center]
						pos = (70.0, 0.0)
						scale = (1.0, 1.0)
						player_name_text = <player_name_text>
						player_name_rgba = <player_text_rgba>
						player_position_text = <position_text>
						player_position_rgba = <player_position_rgba>
						player_points_text = <points_text>
						player_points_rgba = <player_points_rgba>
						player_units_rgba = <player_units_rgba>
						song_summary_playerheading_bg_rgba = <player_bg_rgba>
						player_name_bg_rgba = <player_bg_rgba>
						player_position_fill_rgba = <player_bg_rgba>
						icon_instrument_texture = <icon_texture>
						icon_instrument_rgba = <icon_instrument_rgba>
						icon_instrument_alpha = <icon_instrument_alpha>
						icon_instrument_dims = <icon_instrument_dims>
						autosizedims = true
						tags = {
							player_num = <player>
							winning_player = <winning_player>
						}
					}
				endif
				getnextplayer player = <player>
				repeat <num_players>
			endif
			<order_idx> = (<order_idx> + 1)
			repeat <array_size>
			<player_menu_id> :se_setprops alpha = 1
			if (<is_tie> = 0)
				if song_complete_shreddfest_id :desc_resolvealias \{name = alias_song_summary_badge_winner
						param = song_summary_badge_winner_id}
					<song_summary_badge_winner_id> :obj_spawnscript ui_pulse
				else
					scriptassert \{'dschorn1'}
				endif
			else
				song_complete_shreddfest_id :se_setprops \{song_summary_badge_winner_alpha = 0}
			endif
		endif
	endif
endscript

script ui_song_breakdown_smc_populate_for_teams 
	song_breakdown_smc_get_band_num_order
	getarraysize <order>
	order_idx = 0
	if screenelementexists \{id = song_complete_shreddfest_id}
		if (<array_size> > 0)
			begin
			song_breakdown_smc_check_if_team_is_winner bands = <order> band_to_check = <order_idx>
			if (<order_idx> = 0)
				alias_to_resolve = alias_vs_summary_team_info_left
			else
				alias_to_resolve = alias_vs_summary_team_info_right
			endif
			if (<is_winner> = 1)
				masthead_bg_rgba = gh5_gold_md
				band_name_rgba = [50 50 0 255]
				wins_circle_rgba = yellow_md
				wins_text_rgba = [50 30 25 255]
				song_number_rgba = yellow_lt
				badge_alpha = 1
				vs_summary_session_fx_alpha = 1
				song_summary_team_player_bg_rgba = [233 202 100 255]
				vs_summary_session_bandname_bg_rgba = <song_summary_team_player_bg_rgba>
			else
				formattext checksumname = masthead_bg_rgba 'p%b_xdk' b = (<order> [<order_idx>])
				formattext checksumname = band_name_rgba 'p%b_md' b = (<order> [<order_idx>])
				formattext checksumname = wins_circle_rgba 'p%b_md' b = (<order> [<order_idx>])
				formattext checksumname = wins_text_rgba 'p%b_lt' b = (<order> [<order_idx>])
				song_number_rgba = <wins_text_rgba>
				badge_alpha = 0
				vs_summary_session_fx_alpha = 0
				song_summary_team_player_bg_rgba = <masthead_bg_rgba>
				vs_summary_session_bandname_bg_rgba = <masthead_bg_rgba>
			endif
			getbandinfo (<order> [<order_idx>]) name
			<band_name> = ($<name>)
			if (<is_winner> = 1)
				position_text = qs(0x03ac90f0)
			else
				formattext textname = position_text qs(0x1e9c76ca) b = (<order_idx> + 1)
			endif
			if song_complete_shreddfest_id :desc_resolvealias name = <alias_to_resolve> param = team_panel_id
				if <team_panel_id> :desc_resolvealias name = alias_team_info_stack param = player_menu_id
					<team_panel_id> :se_setprops {
						band_name_text = <band_name>
						band_name_rgba = <band_name_rgba>
						song_number_rgba = <song_number_rgba>
						song_summary_badge_winner_alpha = <badge_alpha>
						team_position_text = <position_text>
						team_position_rgba = <wins_text_rgba>
						vs_summary_session_fx_alpha = <vs_summary_session_fx_alpha>
						vs_summary_session_bandname_bg_rgba = <vs_summary_session_bandname_bg_rgba>
					}
					if (<is_winner> = 1)
						if <team_panel_id> :desc_resolvealias name = alias_highlight_sparkle param = highlight_id
							<highlight_id> :obj_spawnscript ui_rotate
						else
							scriptassert \{'dschorn1'}
						endif
						if <team_panel_id> :desc_resolvealias name = alias_glow_anim param = glow_anim_id
							<glow_anim_id> :obj_spawnscript ui_alphablink_02
						else
							scriptassert \{'dschorn1'}
						endif
						if <team_panel_id> :desc_resolvealias name = alias_song_summary_badge_winner param = song_summary_badge_winner_id
							<song_summary_badge_winner_id> :obj_spawnscript ui_pulse
						else
							scriptassert \{'dschorn1'}
						endif
					endif
					getbandinfo (<order> [<order_idx>]) session_points
					formattext textname = wins_text qs(0x292990de) w = <session_points>
					<team_panel_id> :se_setprops {
						song_number_text = <wins_text>
					}
					getnumplayersingame
					if (<num_players> > 0)
						getfirstplayer
						begin
						getplayerinfo <player> band
						if (<band> = (<order> [<order_idx>]))
							ui_song_breakdown_get_basic_player_data player_index = <player>
							createscreenelement {
								parent = <player_menu_id>
								type = containerelement
								pos_anchor = [left , top]
								just = [left , center]
								dims = (395.0, 40.0)
							}
							createscreenelement {
								parent = <id>
								type = descinterface
								desc = 'vs_summary_team_info_player'
								dims = (508.0, 120.0)
								pos_anchor = [left , center]
								just = [left , center]
								pos = (8.0, -210.0)
								scale = (1.0, 1.0)
								player_bar_rgba = <masthead_bg_rgba>
								player_name_text = <player_name_text>
								player_name_rgba = <wins_text_rgba>
								icon_instrument_texture = <icon_texture>
								icon_instrument_rgba = <player_text_rgba>
								song_summary_team_player_bg_rgba = <song_summary_team_player_bg_rgba>
								autosizedims = true
								tags = {
									player_num = <player>
								}
							}
						endif
						getnextplayer player = <player>
						repeat <num_players>
					endif
				endif
				<order_idx> = (<order_idx> + 1)
				repeat <array_size>
				if (<array_size> = 1)
					if song_complete_shreddfest_id :desc_resolvealias \{name = alias_vs_summary_team_info_right
							param = team_panel_id}
						if <team_panel_id> :desc_resolvealias name = alias_team_info_stack param = player_menu_id
							<team_panel_id> :se_setprops {
								band_name_text = qs(0x03ac90f0)
								song_number_text = qs(0x3bf547a6)
								song_summary_badge_winner_alpha = 0
							}
						endif
					endif
				endif
			endif
		endif
	endif
endscript

script ui_song_breakdown_shreddfest_match_complete_continue_to_next_screen 
	ui_sfx \{menustate = generic
		uitype = select}
	getpakmancurrent \{map = zones}
	if (<pak> != z_studio)
		spawnscriptnow \{sfx_backgrounds_new_area
			params = {
				bg_sfx_area = frontend_menu_music
			}}
	endif
	printf \{qs(0x2bd3b055)}
	change \{songtime_paused = 0}
	if ($is_network_game = 1)
		generic_event_back \{state = uistate_songlist}
	else
		generic_event_choose \{state = 0x0604ee76
			data = {
				0x28f2d5b2 = menu_back
				0x3002594a = {
					no_jamsession
				}
			}}
	endif
endscript

script ui_destroy_song_breakdown_shreddfest_match_complete 
	clean_up_user_control_helpers
	if screenelementexists \{id = song_complete_shreddfest_id}
		if song_complete_shreddfest_id :getsingletag \{players_list_id}
			if screenelementexists id = <players_list_id>
				destroyscreenelement id = <players_list_id>
			endif
		endif
		destroyscreenelement \{id = song_complete_shreddfest_id}
	endif
endscript

script ui_deinit_song_breakdown_shreddfest_match_complete 
	change \{song_breakdown_countdown_time_added = 0}
	ui_song_breakdown_clean_up_highest_multipliers
endscript

script ui_song_breakdown_determine_order_from_session_points 
	getbandsstatus
	getarraysize <bands>
	order = []
	i = 0
	begin
	if (<bands> [<i>].in_game)
		getbandinfo (<i> + 1) session_points
		addarrayelement {
			array = <order>
			element = {
				band_num = (<i> + 1)
				session_points = <session_points>
			}
		}
		order = <array>
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	getarraysize <order>
	if (<array_size> > 1)
		begin
		<i> = 0
		begin
		left_score = (<order> [<i>].session_points)
		right_score = (<order> [(<i> + 1)].session_points)
		if (<right_score> > <left_score>)
			left_element = (<order> [<i>])
			setarrayelement arrayname = order index = <i> newvalue = (<order> [(<i> + 1)])
			setarrayelement arrayname = order index = (<i> + 1) newvalue = <left_element>
		endif
		<i> = (<i> + 1)
		repeat (<array_size> - 1)
		repeat <array_size>
	endif
	return order = <order>
endscript

script ui_song_breakdown_smc_setup_handler_scripts 
	continue_script = nullscript
	back_script = nullscript
	option_script = nullscript
	option2_script = nullscript
	continue_text = qs(0x182f0173)
	back_text = qs(0x3f11367e)
	option_text = qs(0x03ac90f0)
	option2_text = qs(0x03ac90f0)
	back_params = {}
	option_params = {}
	option2_params = {}
	transition_param = none
	gamemode_gettype
	if gotparam \{end_of_setlist_transition}
		transition_param = end_of_setlist_transition
		if ($is_network_game = 1)
			continue_script = net_ui_song_breakdown_continue_to_next_screen_gig_complete
		else
			continue_script = song_breakdown_faceoff_continue_to_next_screen
		endif
		if (($is_network_game = 0) || ($g_lobby_net_state = net_private))
			getplayerinfo ($g_net_leader_player_num) is_local_client
			if (<is_local_client> = 1)
				option_script = song_breakdown_shreddfest_change_game_type
				option_params = {transition_param = <transition_param>}
				option_text = qs(0x2ba5d7e6)
			endif
		endif
		if ininternetmode
			option2_script = net_ui_song_breakdown_show_players_list
			option2_text = qs(0xd16792bf)
			option2_params = {
				screen_id = song_complete_shreddfest_id
				destroy_players_list_script = net_ui_song_breakdown_smc_destroy_players_list
			}
		endif
	elseif ((gotparam continue_setlist_transition) || (gotparam add_setlist_continue_handlers))
		transition_param = continue_setlist_transition
		if ($is_network_game = 1)
			<team_game_can_continue> = 1
			getnumplayers
			get_local_players_in_game
			if (<num_local_players> >= <num_players> || <team_game_can_continue> = 0)
				back_script = postgame_lobby_quit
				back_params = {id = song_complete_shreddfest_id}
				back_text = qs(0x67d9c56d)
			else
				if NOT (gotparam no_timer)
					if ($song_breakdown_countdown_time_added = 0)
						change \{song_breakdown_countdown_time = 5}
					endif
					song_complete_shreddfest_id :obj_spawnscriptnow \{net_ui_song_breakdown_start_timer_spawned
						params = {
							continue_to_next_song
						}}
				endif
			endif
			option2_script = net_ui_song_breakdown_show_players_list
			option2_text = qs(0xd16792bf)
			option2_params = {
				screen_id = song_complete_shreddfest_id
				destroy_players_list_script = net_ui_song_breakdown_smc_destroy_players_list
			}
		else
			continue_script = song_breakdown_competitive_continue_to_next_song
		endif
		if (($is_network_game = 0) || ($g_lobby_net_state = net_private))
			getplayerinfo ($g_net_leader_player_num) is_local_client
			if (<is_local_client> = 1)
				allow_change_game_mode = 1
				if ($g_lobby_net_state = net_private)
					getnumplayers
					get_local_players_in_game
					if (<num_local_players> >= <num_players>)
						<allow_change_game_mode> = 0
					endif
				endif
				if (<allow_change_game_mode> = 1)
					option_script = song_breakdown_shreddfest_change_game_type
					option_params = {transition_param = <transition_param>}
					option_text = qs(0x2ba5d7e6)
				endif
			endif
		endif
	elseif (gotparam net_transition)
		transition_param = net_transition
		<team_game_can_continue> = 1
		getnumplayers
		get_local_players_in_game
		if (<num_local_players> < <num_players> && <team_game_can_continue> = 1)
			continue_script = net_ui_song_breakdown_go_to_setlist
			continue_text = qs(0xd31dcde6)
		endif
		back_script = postgame_lobby_quit
		back_params = {id = song_complete_shreddfest_id}
		back_text = qs(0x67d9c56d)
		if ($g_lobby_net_state = net_private)
			getplayerinfo ($g_net_leader_player_num) is_local_client
			if (<is_local_client> = 1)
				if (<num_local_players> < <num_players> && <team_game_can_continue> = 1)
					option_script = song_breakdown_shreddfest_change_game_type
					option_params = {transition_param = <transition_param>}
					option_text = qs(0x2ba5d7e6)
				endif
			endif
		endif
		option2_script = net_ui_song_breakdown_show_players_list
		option2_text = qs(0xd16792bf)
		option2_params = {
			screen_id = song_complete_shreddfest_id
			destroy_players_list_script = net_ui_song_breakdown_smc_destroy_players_list
		}
	else
		scriptassert \{'Invalid transition from song breakdown'}
	endif
	if (gotparam no_wait)
		spawnscriptnow ui_song_breakdown_add_handlers_for_next_transition_spawned params = {
			screen_element_id = song_complete_shreddfest_id
			continue_script = <continue_script>
			back_script = <back_script>
			option_script = <option_script>
			option2_script = <option2_script>
			continue_text = <continue_text>
			back_text = <back_text>
			option_text = <option_text>
			option2_text = <option2_text>
			back_params = <back_params>
			option_params = <option_params>
			option2_params = <option2_params>
			transition_param = <transition_param>
			can_scroll_stats = 0
			no_wait
		}
	else
		spawnscriptnow ui_song_breakdown_add_handlers_for_next_transition_spawned params = {
			screen_element_id = song_complete_shreddfest_id
			continue_script = <continue_script>
			back_script = <back_script>
			option_script = <option_script>
			option2_script = <option2_script>
			continue_text = <continue_text>
			back_text = <back_text>
			option_text = <option_text>
			option2_text = <option2_text>
			back_params = <back_params>
			option_params = <option_params>
			option2_params = <option2_params>
			transition_param = <transition_param>
			can_scroll_stats = 0
		}
	endif
endscript

script song_breakdown_smc_get_band_num_order 
	getbandsstatus
	getarraysize <bands>
	order = []
	i = 0
	begin
	if (<bands> [<i>].in_game)
		addarrayelement {
			array = <order>
			element = (<i> + 1)
		}
		order = <array>
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	return order = <order>
endscript

script song_breakdown_smc_check_if_team_is_winner 
	requireparams \{[
			bands
			band_to_check
		]
		all}
	getarraysize <bands>
	if (<array_size> != 2)
		return \{is_winner = 1
			is_tie = 0}
	endif
	getbandinfo (<bands> [0]) session_points
	band1_points = <session_points>
	getbandinfo (<bands> [1]) session_points
	band2_points = <session_points>
	winner_order_idx = -1
	if (<band1_points> != <band2_points>)
		if (<band1_points> > <band2_points>)
			winner_order_idx = 0
		else
			winner_order_idx = 1
		endif
	else
		return \{is_winner = 0
			is_tie = 1}
	endif
	if (<band_to_check> = <winner_order_idx>)
		return \{is_winner = 1
			is_tie = 0}
	else
		return \{is_winner = 0
			is_tie = 0}
	endif
endscript

script song_breakdown_smc_single_check_for_tie_winner 
	requireparams \{[
			order
		]
		all}
	is_tie_winner = 0
	getarraysize <order>
	if (<array_size> > 1)
		if ((<order> [0].session_points) = (<order> [1].session_points))
			is_tie_winner = 1
		endif
	endif
	return is_tie = <is_tie_winner>
endscript

script ui_return_song_breakdown_shreddfest_match_complete 
	if screenelementexists \{id = song_complete_shreddfest_id}
		if NOT screenelementexists \{id = band_lobby_popup_menu}
			song_complete_shreddfest_id :getsingletag \{transition_param}
			ui_song_breakdown_smc_setup_handler_scripts <transition_param> no_wait
		else
			band_lobby_update_button_helpers controller = ($primary_controller) menu = playerslist
		endif
	endif
endscript

script net_ui_song_breakdown_smc_destroy_players_list 
	requireparams \{[
			players_list_id
		]
		all}
	destroyscreenelement id = <players_list_id>
	launchevent \{type = focus
		target = song_complete_shreddfest_id}
	clean_up_user_control_helpers
	if screenelementexists \{id = song_complete_shreddfest_id}
		if song_complete_shreddfest_id :getsingletag \{transition_param}
			ui_song_breakdown_smc_setup_handler_scripts <transition_param> no_wait no_timer
		endif
	endif
endscript
