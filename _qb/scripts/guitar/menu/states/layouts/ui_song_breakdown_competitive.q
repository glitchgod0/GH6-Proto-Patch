ui_song_breakdown_competitive_already_updated_session_points = 0
ui_song_breakdown_competitive_order = [
]
ui_song_breakdown_competitive_order_is_tie = 0

script ui_init_song_breakdown_competitive 
	change \{songtime_paused = 1}
	change \{ui_song_breakdown_competitive_order_is_tie = 0}
	change \{ui_song_breakdown_competitive_order = [
		]}
	change \{song_breakdown_countdown_time_added = 0}
	change \{respond_to_signin_changed_func = ui_signin_changed_func}
	change \{ui_song_breakdown_competitive_already_updated_session_points = 0}
	change \{ui_song_breakdown_already_animated_stats = 0}
	change \{song_breakdown_countdown_time = -1}
	change \{song_breakdown_gem_scroller_restarted = 0}
	spawnscriptnow \{sfx_backgrounds_new_area
		params = {
			bg_sfx_area = $g_current_crowd_looping_bg_area_neutral
			fadeintime = 10
			fadeintype = linear
			fadeouttime = 10
			fadeouttype = linear
		}}
	spawnscriptnow \{audio_crowd_neutral_crowd_wait_to_lower_stats}
	spawnscriptnow \{audio_crowd_play_swells_during_stats_screen}
	change \{ui_song_breakdown_helper_params = {
		}}
	change \{playing_song = 0}
	disable_pause
	gamemode_gettype
	if ($is_network_game = 1)
		spawn_player_drop_listeners \{drop_player_script = song_breakdown_drop_player
			end_game_script = song_breakdown_end_game}
	endif
endscript

script ui_create_song_breakdown_competitive 
	if innetgame
		netsessionfunc \{obj = voice
			func = turnteamtalkoff}
	endif
	change \{ui_song_breakdown_helper_params = {
		}}
	if should_use_all_buttons
		change \{ui_song_breakdown_helper_params = {
				all_buttons
			}}
	endif
	if screenelementexists \{id = song_breakdown_competitive_id}
		destroyscreenelement \{id = song_breakdown_competitive_id}
	endif
	if ((gotparam continue_setlist_transition) || (gotparam add_setlist_continue_handlers))
		if (($song_breakdown_gem_scroller_restarted) = 0)
			spawnscriptlater restart_gem_scroller params = {
				starttime = <starttime>
				practice_intro = 0
				loading_transition = 1
				no_render = 0
			}
			change \{song_breakdown_gem_scroller_restarted = 1}
		endif
	endif
	playlist_getcurrentsong
	my_song = <current_song>
	if NOT ($last_song_played = none)
		my_song = ($last_song_played)
	endif
	get_song_title song = <my_song>
	gamemode_gettype
	if (<type> = pro_faceoff)
		ui_create_song_breakdown_faceoff song_title = <song_title>
	elseif (<type> = competitive)
		ui_create_song_breakdown_shreddfest song_title = <song_title>
	else
		scriptassert \{qs(0x7951d5fe)}
	endif
	ui_song_breakdown_competitive_setup_handler_scripts <...>
	if screenelementexists \{id = song_breakdown_competitive_id}
		if ($is_network_game = 1)
			if NOT ((gotparam continue_setlist_transition) || (gotparam add_setlist_continue_handlers))
				song_breakdown_competitive_id :obj_spawnscriptnow net_ui_song_breakdown_competitive_start_timer_spawned params = {<...>}
			endif
		endif
	endif
endscript

script ui_create_song_breakdown_faceoff 
	soundevent \{event = audio_ui_song_complete_menu_in}
	getnumplayersingame
	if NOT teammodeequals \{team_mode = two_teams}
		createscreenelement {
			parent = root_window
			id = song_breakdown_competitive_id
			type = descinterface
			desc = 'song_complete_faceoff'
			title_text = <song_title>
			band_header_container_pos = {(0.0, -300.0) relative}
			tags = {
				player_id_array = []
				player_strips_id = []
				transition_param = none
				came_from_rock_record = 0
			}
		}
	else
		createscreenelement {
			parent = root_window
			id = song_breakdown_competitive_id
			type = descinterface
			desc = 'song_summary_team'
			song_name_text = <song_title>
			band_header_container_pos = {(0.0, -300.0) relative}
			tags = {
				player_id_array = []
				player_strips_id = []
				transition_param = none
				came_from_rock_record = 0
			}
		}
	endif
	song_breakdown_check_bot_play
	if (<bot_play> = 0)
		song_breakdown_get_exclusive_devices
		if screenelementexists \{id = song_breakdown_competitive_id}
			song_breakdown_competitive_id :se_setprops {
				exclusive_device = <exclusive_devices>
			}
		endif
	endif
	song_breakdown_competitive_determine_order_from_score
	getarraysize <order>
	order_size = <array_size>
	order_idx = 0
	player_idx = 1
	session_stats_update_scores order = <order> size = <order_size>
	if screenelementexists \{id = song_breakdown_competitive_id}
		if NOT teammodeequals \{team_mode = two_teams}
			if song_breakdown_competitive_id :desc_resolvealias \{name = alias_song_complete_faceoff_players_menu
					param = player_menu_id}
				getscreenelementchildren id = <player_menu_id>
				(<children> [0]) :se_setprops not_focusable
				begin
				if (<num_players> > 0)
					getfirstplayer
					strip_idx = 0
					begin
					getplayerinfo <player> band
					if (<band> = (<order> [<order_idx>].band_num))
						ui_song_breakdown_get_basic_player_data player_index = <player>
						createscreenelement {
							parent = <player_menu_id>
							type = descinterface
							desc = 'song_complete_faceoff_player_stats'
							player_name_text = <player_name_text>
							score_text = <score_text>
							autosizedims = true
						}
						song_breakdown_competitive_id :gettags
						addarrayelement array = <player_id_array> element = <player>
						<player_id_array> = <array>
						addarrayelement array = <player_strips_id> element = <id>
						<player_strips_id> = <array>
						song_breakdown_competitive_id :settags player_id_array = <player_id_array>
						song_breakdown_competitive_id :settags player_strips_id = <player_strips_id>
						<strip_idx> = (<strip_idx> + 1)
					endif
					getnextplayer player = <player>
					repeat <num_players>
				endif
				<order_idx> = (<order_idx> + 1)
				repeat <order_size>
			endif
			<player_menu_id> :se_setprops alpha = 1
		else
			if song_breakdown_competitive_id :desc_resolvealias \{name = alias_song_summary_team_stack
					param = team_menu_id}
				begin
				createscreenelement {
					parent = <team_menu_id>
					type = containerelement
					dims = (450.0, 130.0)
					pos_anchor = [left , top]
					just = [center , center]
					not_focusable
				}
				<score> = (<order> [<order_idx>].band_result)
				casttointeger \{score}
				formattext textname = score_text qs(0x73307931) s = <score> usecommas
				getbandinfo (<order> [<order_idx>].band_num) name
				<band_name_text> = ($<name>)
				createscreenelement {
					parent = <id>
					type = descinterface
					desc = 'song_summary_team_masthead'
					dims = (496.0, 157.0)
					pos_anchor = [left , top]
					just = [left , center]
					pos = (-39.0, 63.0)
					autosizedims = true
					score_main_text = <score_text>
					band_name_text = <band_name_text>
					tags = {
						team_strip_index = <order_idx>
						current_focused_strip_idx = -1
					}
				}
				if (<order_idx> = 0)
					masthead_bg_rgba = [65 55 0 255]
					masthead_text_rgba = gh5_gold_md
					song_summary_badge_winner_alpha = 0.9
					player_text_rgba = [50 30 25 255]
					song_summary_team_counter_bg_rgba = [233 202 100 255]
					song_summary_team_player_bg_rgba = [233 202 100 255]
					winning_player = 1
				else
					masthead_bg_rgba = [0 50 50 255]
					formattext checksumname = masthead_text_rgba 'p%i_md' i = (<order> [<order_idx>])
					formattext checksumname = masthead_score_bg_rgba 'p%i_lt' i = (<order> [<order_idx>])
					song_summary_badge_winner_alpha = 0
					formattext checksumname = player_text_rgba 'p%i_lt' i = (<order> [<order_idx>])
					formattext checksumname = highlight_film_dk_rgba 'p%i_xdk' i = (<order> [<order_idx>])
					winning_player = 0
					song_summary_team_player_bg_rgba = [105 160 175 255]
				endif
				<id> :se_setprops {
					masthead_bg_rgba = <masthead_bg_rgba>
					team_number_rgba = <masthead_score_bg_rgba>
					masthead_text_rgba = <masthead_text_rgba>
					masthead_score_bg_rgba = <masthead_score_bg_rgba>
					song_summary_badge_winner_alpha = <song_summary_badge_winner_alpha>
					song_summary_team_player_bg_rgba = <song_summary_team_player_bg_rgba>
				}
				if (<num_players> > 0)
					getfirstplayer
					strip_idx = 0
					begin
					getplayerinfo <player> band
					if (<band> = (<order> [<order_idx>].band_num))
						ui_song_breakdown_get_basic_player_data player_index = <player>
						createscreenelement {
							parent = <team_menu_id>
							type = containerelement
							dims = (441.0, 40.0)
							pos_anchor = [left , top]
							just = [center , center]
						}
						createscreenelement {
							parent = <id>
							type = descinterface
							desc = 'song_summary_team_player'
							dims = (475.0, 88.0)
							pos_anchor = [left , top]
							just = [left , top]
							pos = (0.0, 0.0)
							player_name_text = <player_name_text>
							player_name_rgba = <player_text_rgba>
							song_summary_team_player_bg_rgba = <song_summary_team_player_bg_rgba>
							icon_instrument_texture = <icon_texture>
							autosizedims = true
							tags = {
								player_num = <player>
								winning_player = <winning_player>
							}
						}
						song_breakdown_competitive_id :gettags
						addarrayelement array = <player_id_array> element = <player>
						<player_id_array> = <array>
						addarrayelement array = <player_strips_id> element = <id>
						<player_strips_id> = <array>
						song_breakdown_competitive_id :settags player_id_array = <player_id_array>
						song_breakdown_competitive_id :settags player_strips_id = <player_strips_id>
						<strip_idx> = (<strip_idx> + 1)
					endif
					getnextplayer player = <player>
					repeat <num_players>
				endif
				<order_idx> = (<order_idx> + 1)
				repeat <order_size>
			endif
		endif
	endif
endscript

script ui_create_song_breakdown_shreddfest 
	soundevent \{event = audio_ui_song_complete_menu_in}
	getnumplayersingame
	getuppercasestring <goal_results_column_title>
	<goal_results_column_title> = <uppercasestring>
	if NOT teammodeequals \{team_mode = two_teams}
		createscreenelement {
			parent = root_window
			id = song_breakdown_competitive_id
			type = descinterface
			desc = 'vs_summary'
			tally_text = <song_title>
			shreddfest_winning_criteria_label_text = <goal_results_column_title>
			tags = {
				player_id_array = []
				player_strips_id = []
				transition_param = none
				came_from_rock_record = 0
			}
		}
	else
		ruleset = ($competitive_rules)
		createscreenelement {
			parent = root_window
			id = song_breakdown_competitive_id
			type = descinterface
			desc = 'song_summary_team'
			song_name_text = <song_title>
			game_rules_text = ($<ruleset>.text)
			band_header_container_pos = {(0.0, -300.0) relative}
			tags = {
				player_id_array = []
				player_strips_id = []
				transition_param = none
				came_from_rock_record = 0
			}
		}
	endif
	song_breakdown_check_bot_play
	if (<bot_play> = 0)
		song_breakdown_get_exclusive_devices
		if screenelementexists \{id = song_breakdown_competitive_id}
			song_breakdown_competitive_id :se_setprops {
				exclusive_device = <exclusive_devices>
			}
		endif
	endif
	getarraysize ($ui_song_breakdown_competitive_order)
	if (<array_size> <= 0)
		song_breakdown_shreddfest_determine_order
		change ui_song_breakdown_competitive_order = <order>
		change ui_song_breakdown_competitive_order_is_tie = <is_tie>
	else
		order = ($ui_song_breakdown_competitive_order)
		is_tie = ($ui_song_breakdown_competitive_order_is_tie)
	endif
	getarraysize <order>
	order_size = <array_size>
	order_idx = 0
	if ($ui_song_breakdown_competitive_already_updated_session_points = 0)
		session_stats_update_scores order = <order> size = <order_size>
		change \{ui_song_breakdown_competitive_already_updated_session_points = 1}
	endif
	if screenelementexists \{id = song_breakdown_competitive_id}
		formattext textname = song_title_text qs(0xf3f44f34) s = <song_title>
		<ruleset> = ($competitive_rules)
		formattext textname = shreddfest_type_text qs(0xdb2c2a33) m = ($<ruleset>.text)
		if NOT teammodeequals \{team_mode = two_teams}
			if song_breakdown_competitive_id :desc_resolvealias \{name = alias_player_stack
					param = player_menu_id}
				song_breakdown_competitive_id :se_setprops {
					headline_text = ($<ruleset>.text)
				}
				winning_strip_pos = (0.0, 0.0)
				strip_idx = 0
				begin
				getnumplayersingame
				if (<num_players> > 0)
					getfirstplayer
					begin
					getplayerinfo <player> band
					if (<band> = (<order> [<order_idx>].band_num))
						ui_song_breakdown_get_basic_player_data player_index = <player>
						if ((<order_idx> = 0) && (<is_tie> = 0))
							getplayerinfo <player> part
							switch <part>
								case guitar
								<icon_texture> = mixer_icon_guitar
								case bass
								<icon_texture> = mixer_icon_bass
								case drum
								<icon_texture> = 0xd35def3f
								case vocals
								<icon_texture> = mixer_icon_vox
								default
								<icon_texture> = mixer_icon_guitar
							endswitch
							player_text_rgba = gh5_gold_md
							player_bg_rgba = gh5_gold_md
							player_position_rgba = gh5_gold_md
							player_points_rgba = <player_position_rgba>
							player_units_rgba = <player_position_rgba>
							icon_instrument_alpha = 0.8
							icon_instrument_dims = (112.0, 112.0)
							icon_instrument_rgba = <player_position_rgba>
							winning_player = 1
						else
							formattext checksumname = player_text_rgba 'p%i_lt' i = (<order> [<order_idx>].band_num)
							formattext checksumname = player_position_rgba 'p%i_lt' i = (<order> [<order_idx>].band_num)
							player_points_rgba = <player_position_rgba>
							player_units_rgba = <player_position_rgba>
							formattext checksumname = player_bg_rgba 'p%i_dk' i = (<order> [<order_idx>].band_num)
							icon_instrument_alpha = 0.8
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
							song_breakdown_competitive_id :se_setprops {
								message_text = <winner_text>
							}
						else
							formattext textname = position_text qs(0x66680619) p = (<order_idx> + 1)
						endif
						order_score = (<order> [<order_idx>].band_result)
						casttointeger \{order_score}
						formattext textname = points_text qs(0x66680619) p = <order_score> usecommas
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
						song_breakdown_competitive_id :gettags
						addarrayelement array = <player_id_array> element = <player>
						<player_id_array> = <array>
						addarrayelement array = <player_strips_id> element = <id>
						<player_strips_id> = <array>
						song_breakdown_competitive_id :settags {
							player_id_array = <player_id_array>
							player_strips_id = <player_strips_id>
						}
						<strip_idx> = (<strip_idx> + 1)
					endif
					getnextplayer player = <player>
					repeat <num_players>
				endif
				<order_idx> = (<order_idx> + 1)
				repeat <array_size>
				<player_menu_id> :se_setprops alpha = 1
				if (<is_tie> = 0)
					if song_breakdown_competitive_id :desc_resolvealias \{name = alias_song_summary_badge_winner
							param = song_summary_badge_winner_id}
						<song_summary_badge_winner_id> :obj_spawnscript ui_pulse
					else
						scriptassert \{'dschorn1'}
					endif
					if song_breakdown_competitive_id :desc_resolvealias \{name = alias_highlight_sparkle
							param = highlight_sparkle_id}
						<highlight_sparkle_id> :obj_spawnscript ui_rotate
					else
						scriptassert \{'dschorn1'}
					endif
					if song_breakdown_competitive_id :desc_resolvealias \{name = alias_glow_anim
							param = glow_anim_id}
						<glow_anim_id> :obj_spawnscript ui_alphablink_02
					else
						scriptassert \{'dschorn1'}
					endif
				else
					song_breakdown_competitive_id :se_setprops \{song_summary_badge_winner_alpha = 0}
				endif
			endif
		else
			if song_breakdown_competitive_id :desc_resolvealias \{name = alias_song_summary_team_stack
					param = team_menu_id}
				begin
				createscreenelement {
					parent = <team_menu_id>
					type = containerelement
					dims = (450.0, 200.0)
					pos_anchor = [left , top]
					just = [center , center]
					not_focusable
				}
				<score> = ((<order> [<order_idx>]).band_result)
				casttointeger \{score}
				formattext textname = score_text qs(0x73307931) s = <score> usecommas
				getbandinfo (<order> [<order_idx>].band_num) name
				<band_name_text> = ($<name>)
				createscreenelement {
					parent = <id>
					type = descinterface
					desc = 'song_summary_team_masthead'
					dims = (496.0, 157.0)
					pos_anchor = [left , top]
					just = [left , center]
					pos = (0.0, 150.0)
					autosizedims = true
					score_main_text = <score_text>
					band_name_text = <band_name_text>
					tags = {
						team_strip_index = <order_idx>
						current_focused_strip_idx = -1
					}
				}
				if ((<order_idx> = 0) && (<is_tie> = 0))
					masthead_bg_rgba = [65 55 0 255]
					masthead_text_rgba = gh5_gold_md
					masthead_score_bg_rgba = [255 180 50 255]
					song_summary_badge_winner_alpha = 0.9
					player_text_rgba = yellow_lt
					highlight_film_dk_rgba = <masthead_bg_rgba>
					team_number_text = qs(0x03ac90f0)
					winning_player = 1
					icon_instrument_rgba = <player_text_rgba>
					song_summary_team_winner_fx_alpha = 1
					song_summary_team_counter_bg_rgba = [233 202 100 255]
					song_summary_team_player_bg_rgba = [233 202 100 255]
				else
					masthead_bg_rgba = [0 50 50 255]
					formattext checksumname = masthead_text_rgba 'p%i_md' i = ((<order> [<order_idx>]).band_num)
					formattext checksumname = masthead_score_bg_rgba 'p%i_lt' i = ((<order> [<order_idx>]).band_num)
					song_summary_badge_winner_alpha = 0
					formattext checksumname = player_text_rgba 'p%i_lt' i = ((<order> [<order_idx>]).band_num)
					formattext checksumname = highlight_film_dk_rgba 'p%i_xdk' i = ((<order> [<order_idx>]).band_num)
					formattext textname = team_number_text qs(0x66680619) p = (<order_idx> + 1)
					winning_player = 0
					icon_instrument_rgba = <player_text_rgba>
					song_summary_team_counter_bg_rgba = <masthead_score_bg_rgba>
					song_summary_team_winner_fx_alpha = 0
					song_summary_team_player_bg_rgba = <highlight_film_dk_rgba>
				endif
				<id> :se_setprops {
					masthead_bg_rgba = <masthead_bg_rgba>
					team_number_rgba = <masthead_score_bg_rgba>
					masthead_text_rgba = <masthead_text_rgba>
					masthead_score_bg_rgba = <masthead_score_bg_rgba>
					song_summary_badge_winner_alpha = <song_summary_badge_winner_alpha>
					team_number_text = <team_number_text>
					song_summary_team_counter_bg_rgba = <song_summary_team_counter_bg_rgba>
					song_summary_team_winner_fx_alpha = <song_summary_team_winner_fx_alpha>
					song_summary_team_player_bg_rgba = <song_summary_team_player_bg_rgba>
				}
				if (<song_summary_badge_winner_alpha> > 0)
					if <id> :desc_resolvealias name = alias_song_summary_badge_winner param = song_summary_badge_winner_id
						<song_summary_badge_winner_id> :obj_spawnscript ui_pulse
					else
						scriptassert \{'dschorn1'}
					endif
					if <id> :desc_resolvealias name = alias_highlight_sparkle param = highlight_sparkle_id
						<highlight_sparkle_id> :obj_spawnscript ui_rotate
					else
						scriptassert \{'dschorn1'}
					endif
					if <id> :desc_resolvealias name = alias_glow_anim param = glow_anim_id
						<glow_anim_id> :obj_spawnscript ui_alphablink_02
					else
						scriptassert \{'dschorn1'}
					endif
				endif
				if (<num_players> > 0)
					getfirstplayer
					strip_idx = 0
					begin
					getplayerinfo <player> band
					if (<band> = ((<order> [<order_idx>]).band_num))
						ui_song_breakdown_get_basic_player_data player_index = <player>
						createscreenelement {
							parent = <team_menu_id>
							type = containerelement
							dims = (441.0, 40.0)
							pos_anchor = [left , top]
							just = [center , center]
						}
						createscreenelement {
							parent = <id>
							type = descinterface
							desc = 'song_summary_team_player'
							dims = (475.0, 88.0)
							pos_anchor = [left , top]
							just = [left , top]
							pos = (20.0, -120.0)
							player_name_text = <player_name_text>
							player_name_rgba = <player_text_rgba>
							song_summary_team_player_bg_rgba = <song_summary_team_player_bg_rgba>
							icon_instrument_texture = <icon_texture>
							icon_instrument_rgba = <icon_instrument_rgba>
							autosizedims = true
							tags = {
								player_num = <player>
								winning_player = <winning_player>
							}
						}
						song_breakdown_competitive_id :gettags
						addarrayelement array = <player_id_array> element = <player>
						<player_id_array> = <array>
						addarrayelement array = <player_strips_id> element = <id>
						<player_strips_id> = <array>
						song_breakdown_competitive_id :settags player_id_array = <player_id_array>
						song_breakdown_competitive_id :settags player_strips_id = <player_strips_id>
						<strip_idx> = (<strip_idx> + 1)
					endif
					getnextplayer player = <player>
					repeat <num_players>
				endif
				<order_idx> = (<order_idx> + 1)
				repeat <order_size>
			endif
		endif
	endif
endscript

script ui_song_breakdown_competitive_anim_in_script 
	setscriptcannotpause
	gamemode_gettype
	popdisablerendering \{context = menu_transition
		type = unchecked}
endscript

script ui_song_breakdown_competitive_anim_out_script 
	setscriptcannotpause
	popdisablerendering \{context = menu_transition
		type = unchecked}
	clean_up_user_control_helpers
endscript

script ui_song_breakdown_competitive_setup_handler_scripts 
	continue_script = nullscript
	back_script = nullscript
	option_script = nullscript
	option2_script = nullscript
	continue_text = qs(0x182f0173)
	back_text = qs(0x03ac90f0)
	option_text = qs(0x3f11367e)
	option2_text = qs(0x03ac90f0)
	continue_params = {}
	back_params = {}
	option2_params = {}
	transition_param = none
	gamemode_gettype
	if gotparam \{end_of_setlist_transition}
		continue_params = {end_of_setlist_transition}
		transition_param = end_of_setlist_transition
		if (<type> = pro_faceoff)
			if ($is_network_game = 1)
				option2_script = net_ui_song_breakdown_show_players_list
				option2_text = qs(0xd16792bf)
				option2_params = {
					screen_id = song_breakdown_competitive_id
					destroy_players_list_script = net_ui_song_breakdown_competitive_destroy_players_list
				}
				if NOT (gotparam no_timer)
					song_breakdown_competitive_id :obj_spawnscriptnow net_ui_song_breakdown_competitive_start_timer_spawned params = {<...>}
				endif
			else
				continue_script = song_breakdown_shreddfest_continue_to_next_screen
			endif
		else
			if ($is_network_game = 1)
				option2_script = net_ui_song_breakdown_show_players_list
				option2_text = qs(0xd16792bf)
				option2_params = {
					screen_id = song_breakdown_competitive_id
					destroy_players_list_script = net_ui_song_breakdown_competitive_destroy_players_list
				}
				if NOT (gotparam no_timer)
					song_breakdown_competitive_id :obj_spawnscriptnow net_ui_song_breakdown_competitive_start_timer_spawned params = {<...>}
				endif
			else
				continue_script = song_breakdown_shreddfest_continue_to_next_screen
			endif
		endif
		option_script = song_breakdown_go_to_stats_from_transition
		option_params = {transition_param = <transition_param>}
	elseif ((gotparam continue_setlist_transition) || (gotparam add_setlist_continue_handlers))
		if gotparam \{continue_setlist_transition}
			transition_param = continue_setlist_transition
		else
			transition_param = add_setlist_continue_handlers
		endif
		if (gotparam add_setlist_continue_handlers)
			option_script = song_breakdown_go_to_stats_from_transition
			option_params = {transition_param = <transition_param>}
			transition_param = add_setlist_continue_handlers
			if NOT innetgame
				continue_params = {continue_setlist_transition}
				continue_script = song_breakdown_shreddfest_continue_to_next_screen
			else
				option2_script = net_ui_song_breakdown_show_players_list
				option2_text = qs(0xd16792bf)
				option2_params = {
					screen_id = song_breakdown_competitive_id
					destroy_players_list_script = net_ui_song_breakdown_competitive_destroy_players_list
				}
				if NOT (gotparam no_timer)
					song_breakdown_competitive_id :obj_spawnscriptnow net_ui_song_breakdown_competitive_start_timer_spawned params = {<...>}
				endif
			endif
		endif
	elseif (gotparam net_transition)
		transition_param = net_transition
		back_script = postgame_lobby_quit
		back_params = {id = song_breakdown_competitive_id}
		back_text = qs(0x67d9c56d)
		option_script = song_breakdown_go_to_stats_from_transition
		option_text = qs(0x3f11367e)
		option_params = {transition_param = <transition_param>}
		option2_script = net_ui_song_breakdown_show_players_list
		option2_text = qs(0xd16792bf)
		option2_params = {
			screen_id = song_breakdown_competitive_id
			destroy_players_list_script = net_ui_song_breakdown_competitive_destroy_players_list
		}
	else
		scriptassert \{'Invalid transition from song breakdown'}
	endif
	if (gotparam no_wait)
		spawnscriptnow ui_song_breakdown_add_handlers_for_next_transition_spawned params = {
			screen_element_id = song_breakdown_competitive_id
			continue_script = <continue_script>
			back_script = <back_script>
			option_script = <option_script>
			option2_script = <option2_script>
			continue_text = <continue_text>
			back_text = <back_text>
			option_text = <option_text>
			option2_text = <option2_text>
			continue_params = <continue_params>
			back_params = <back_params>
			option_params = <option_params>
			option2_params = <option2_params>
			transition_param = <transition_param>
			can_scroll_stats = 0
			no_wait
		}
	else
		spawnscriptnow ui_song_breakdown_add_handlers_for_next_transition_spawned params = {
			screen_element_id = song_breakdown_competitive_id
			continue_script = <continue_script>
			back_script = <back_script>
			option_script = <option_script>
			option2_script = <option2_script>
			continue_text = <continue_text>
			back_text = <back_text>
			option_text = <option_text>
			option2_text = <option2_text>
			continue_params = <continue_params>
			back_params = <back_params>
			option_params = <option_params>
			option2_params = <option2_params>
			transition_param = <transition_param>
			can_scroll_stats = 0
		}
	endif
endscript

script net_ui_song_breakdown_competitive_start_timer_spawned 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	obj_getid
	screen_id = <objid>
	net_ui_song_breakdown_wait_for_timer screen_id = <screen_id> timer_text = qs(0xc0de1c84)
	gamemode_gettype
	if ($is_network_game = 1)
		song_breakdown_shreddfest_continue_to_next_screen timer_expired <...>
	endif
endscript

script ui_return_song_breakdown_competitive 
	if screenelementexists \{id = song_breakdown_competitive_id}
		if NOT screenelementexists \{id = band_lobby_popup_menu}
			song_breakdown_competitive_id :getsingletag \{transition_param}
			ui_song_breakdown_competitive_setup_handler_scripts <transition_param> no_wait
		else
			band_lobby_update_button_helpers controller = ($primary_controller) menu = playerslist
		endif
	endif
endscript

script song_breakdown_shreddfest_continue_to_next_screen 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	if gotparam \{timer_expired}
		removeparameter \{base_name}
		removeparameter \{timer_expired}
		removeparameter \{anim_in_script}
		removeparameter \{anim_out_script}
		if screenelementexists \{id = song_breakdown_competitive_id}
			launchevent \{type = unfocus
				target = song_breakdown_competitive_id}
		elseif screenelementexists \{id = stats_summary_id}
			launchevent \{type = unfocus
				target = stats_summary_id}
		endif
		if ui_event_is_top_popup
			ui_sfx \{menustate = generic
				uitype = select}
			ui_event_wait_for_safe
			generic_event_replace state = uistate_song_breakdown_shreddfest_match_complete data = <...>
		else
			ui_sfx \{menustate = generic
				uitype = select}
			ui_event_wait_for_safe
			generic_event_choose state = uistate_song_breakdown_shreddfest_match_complete data = <...>
		endif
	else
		getplayerinfo ($g_net_leader_player_num) bot_play
		if (<bot_play> = 1)
			getplayerinfo ($g_net_leader_player_num) bot_original_controller
			controller = <bot_original_controller>
		else
			getplayerinfo ($g_net_leader_player_num) controller
		endif
		if (<device_num> = <controller>)
			if screenelementexists \{id = song_breakdown_competitive_id}
				launchevent \{type = unfocus
					target = song_breakdown_competitive_id}
			endif
			if ui_event_is_top_popup
				ui_sfx \{menustate = generic
					uitype = select}
				ui_event_wait_for_safe
				generic_event_replace state = uistate_song_breakdown_shreddfest_match_complete data = <...>
			else
				ui_sfx \{menustate = generic
					uitype = select}
				ui_event_wait_for_safe
				generic_event_choose state = uistate_song_breakdown_shreddfest_match_complete data = <...>
			endif
		endif
	endif
endscript

script song_breakdown_shreddfest_change_game_type 
	requireparams \{[
			device_num
			transition_param
		]
		all}
	if ininternetmode
		getplayerinfo ($g_net_leader_player_num) controller
	else
		controller = ($primary_controller)
	endif
	if (<device_num> = <controller>)
		ui_sfx \{menustate = generic
			uitype = select}
		launchevent \{type = unfocus
			target = song_complete_shreddfest_id}
		start_timer = 0
		if ininternetmode
			if ((<transition_param> = continue_setlist_transition) || (<transition_param> = add_setlist_continue_handlers))
				start_timer = 1
			endif
		endif
		generic_event_choose state = uistate_game_rules data = {start_timer = <start_timer>}
	endif
endscript

script song_breakdown_faceoff_continue_to_next_screen \{device_num = !i1768515945}
	if (<device_num> = ($primary_controller))
		ui_sfx \{menustate = generic
			uitype = select}
		getpakmancurrent \{map = zones}
		if (<pak> != z_studio)
			spawnscriptnow \{sfx_backgrounds_new_area
				params = {
					bg_sfx_area = frontend_menu_music
				}}
			if scriptexists \{audio_crowd_play_swells_during_stats_screen}
				killspawnedscript \{name = audio_crowd_play_swells_during_stats_screen}
			endif
			if issoundeventplaying \{surge_during_stats_screen}
				stopsoundevent \{surge_during_stats_screen
					fade_time = 1.5
					fade_type = linear}
			endif
		endif
		if screenelementexists \{id = song_breakdown_competitive_id}
			launchevent \{type = unfocus
				target = song_breakdown_competitive_id}
		elseif screenelementexists \{id = song_complete_shreddfest_id}
			launchevent \{type = unfocus
				target = song_complete_shreddfest_id}
		endif
		printf \{qs(0x2bd3b055)}
		change \{songtime_paused = 0}
		generic_event_choose \{state = 0x0604ee76
			data = {
				0x28f2d5b2 = menu_back
				0x3002594a = {
					no_jamsession
				}
			}}
	endif
endscript

script song_breakdown_competitive_continue_to_next_song 
	requireparams \{[
			device_num
		]
		all}
	if (<device_num> = ($primary_controller))
		launchevent \{type = unfocus
			target = song_complete_shreddfest_id}
		if ($game_mode = fest_mode || $game_mode = fest_mode_team)
			display_competitive_rules_voting \{voting_callback = song_breakdown_back_to_gameplay
				back_params = {
					data = {
						continue_setlist_transition
					}
				}}
		else
			audio_ui_menu_music_off
			song_breakdown_back_to_gameplay
		endif
	endif
endscript

script song_breakdown_back_to_gameplay 
	printf \{qs(0xc895d2b5)}
	if gotparam \{result}
		change competitive_rules = <result>
		if ishost
			sendstructure callback = net_set_competitive_rules data_to_send = {competitive_rules = <result> loading_screen = 0}
		endif
	endif
	ui_sfx \{menustate = generic
		uitype = select}
	soundevent \{event = audio_ui_song_complete_menu_out}
	gman_shutdowngamemodegoal
	gman_startgamemodegoal
	if ininternetmode
		generic_net_sync \{callback = unpause_songtime_back_to_gameplay}
	else
		unpause_songtime_back_to_gameplay
	endif
endscript

script unpause_songtime_back_to_gameplay 
	ui_sfx \{menustate = generic
		uitype = select}
	soundevent \{event = audio_ui_song_complete_menu_out}
	change \{songtime_paused = 0}
	generic_event_back \{nosound
		state = uistate_gameplay}
endscript

script ui_destroy_song_breakdown_competitive 
	clean_up_user_control_helpers
	if screenelementexists \{id = song_breakdown_competitive_id}
		if song_breakdown_competitive_id :getsingletag \{players_list_id}
			if screenelementexists id = <players_list_id>
				destroyscreenelement id = <players_list_id>
			endif
		endif
		destroyscreenelement \{id = song_breakdown_competitive_id}
	endif
	killspawnedscript \{name = net_ui_song_breakdown_competitive_start_timer_spawned}
endscript

script ui_deinit_song_breakdown_competitive 
	change \{ui_song_breakdown_competitive_order_is_tie = 0}
	change \{ui_song_breakdown_competitive_order = [
		]}
	change \{song_breakdown_countdown_time = -1}
	change \{song_breakdown_countdown_time_added = 0}
	change \{ui_song_breakdown_competitive_already_updated_session_points = 0}
	change \{ui_song_breakdown_already_animated_stats = 0}
	change \{song_breakdown_gem_scroller_restarted = 0}
	ui_song_breakdown_clean_up_highest_multipliers
endscript

script net_ui_song_breakdown_competitive_destroy_players_list 
	requireparams \{[
			players_list_id
		]
		all}
	destroyscreenelement id = <players_list_id>
	launchevent \{type = focus
		target = song_breakdown_competitive_id}
	clean_up_user_control_helpers
	if screenelementexists \{id = song_breakdown_competitive_id}
		if song_breakdown_competitive_id :getsingletag \{transition_param}
			ui_song_breakdown_competitive_setup_handler_scripts <transition_param> no_wait no_timer
		endif
	endif
endscript

script song_breakdown_competitive_determine_order_from_score 
	getbandsstatus
	getarraysize <bands>
	order = []
	i = 0
	begin
	if (<bands> [<i>].in_game)
		getbandscorefromdetailedstats band = (<i> + 1)
		addarrayelement {
			array = <order>
			element = {
				band_num = (<i> + 1)
				band_result = <score>
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
		left_score = (<order> [<i>].band_result)
		right_score = (<order> [(<i> + 1)].band_result)
		if (<right_score> > <left_score>)
			left_score_band_idx = (<order> [<i>])
			setarrayelement arrayname = order index = <i> newvalue = (<order> [(<i> + 1)])
			setarrayelement arrayname = order index = (<i> + 1) newvalue = <left_score_band_idx>
		endif
		<i> = (<i> + 1)
		repeat (<array_size> - 1)
		repeat <array_size>
	endif
	return order = <order>
endscript

script song_breakdown_shreddfest_determine_order 
	get_goal_results_data \{goal = competitive}
	ruleset = ($competitive_rules)
	if NOT structurecontains structure = ($<ruleset>) ranking_criteria
		scriptassert \{'competitive ruleset does not have a ranking criteria'}
	endif
	switch (($<ruleset>).ranking_criteria)
		case performance_value
		song_breakdown_shreddfest_determine_order_combined_player_scores {
			goal_results_column_data = <goal_results_column_data>
		}
		case elimination_order
		song_breakdown_shreddfest_determine_order_highest_player_score {
			goal_results_column_data = <goal_results_column_data>
		}
		case score
		song_breakdown_shreddfest_determine_order_band_score {
			goal_results_column_data = <goal_results_column_data>
			is_band_data = <is_band_data>
		}
	endswitch
	return {
		order = <order>
		is_tie = <is_tie>
	}
endscript

script song_breakdown_shreddfest_determine_order_band_score 
	requireparams \{[
			goal_results_column_data
			is_band_data
		]
		all}
	getbandsstatus
	getarraysize <bands>
	order = []
	i = 0
	j = 0
	if (<is_band_data> = 1)
		begin
		if (<bands> [<i>].in_game)
			addarrayelement {
				array = <order>
				element = {
					band_num = (<i> + 1)
					band_result = (<goal_results_column_data> [<j>])
				}
			}
			order = <array>
			<j> = (<j> + 1)
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	else
		getnumplayersingame
		if (<num_players> > 0)
			getfirstplayer
			begin
			getplayerinfo <player> band
			addarrayelement {
				array = <order>
				element = {
					band_num = <band>
					band_result = (<goal_results_column_data> [<j>])
				}
			}
			order = <array>
			<j> = (<j> + 1)
			getnextplayer player = <player>
			repeat <num_players>
		endif
	endif
	is_tie = 0
	getarraysize <order>
	if (<array_size> > 1)
		begin
		<i> = 0
		<index_to_access> = -1
		begin
		left_score = ((<order> [<i>]).band_result)
		right_score = ((<order> [(<i> + 1)]).band_result)
		if (<right_score> > <left_score>)
			left_score_band_info_idx = (<order> [<i>])
			setarrayelement arrayname = order index = <i> newvalue = (<order> [(<i> + 1)])
			setarrayelement arrayname = order index = (<i> + 1) newvalue = <left_score_band_info_idx>
		endif
		<i> = (<i> + 1)
		repeat (<array_size> - 1)
		repeat <array_size>
		if ((<order> [0].band_result) = (<order> [1].band_result))
			is_tie = 1
		endif
	endif
	return {
		order = <order>
		is_tie = <is_tie>
	}
endscript

script song_breakdown_shreddfest_determine_order_combined_player_scores 
	requireparams \{[
			goal_results_column_data
		]
		all}
	getnumplayersingame
	getbandsstatus
	getarraysize <bands>
	order = []
	i = 0
	begin
	if (<bands> [<i>].in_game)
		if (<num_players> > 0)
			getfirstplayer
			combined_score = 0
			individual_scores = []
			j = 0
			begin
			getplayerinfo <player> band
			if (<band> = (<i> + 1))
				<combined_score> = (<combined_score> + (<goal_results_column_data> [<j>]))
				if teammodeequals \{team_mode = two_teams}
					addarrayelement {
						array = <individual_scores>
						element = {
							player_num = <player>
							player_result = (<goal_results_column_data> [<j>])
						}
					}
					<individual_scores> = <array>
				endif
			endif
			getnextplayer player = <player>
			<j> = (<j> + 1)
			repeat <num_players>
			addarrayelement {
				array = <order>
				element = {
					band_num = (<i> + 1)
					band_result = <combined_score>
					individual_results = <individual_scores>
				}
			}
			<order> = <array>
		endif
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	is_tie = 0
	getarraysize <order>
	if (<array_size> > 1)
		begin
		<i> = 0
		begin
		left_score = ((<order> [<i>]).band_result)
		right_score = ((<order> [(<i> + 1)]).band_result)
		if (<right_score> > <left_score>)
			left_score_band_info_idx = (<order> [<i>])
			setarrayelement arrayname = order index = <i> newvalue = (<order> [(<i> + 1)])
			setarrayelement arrayname = order index = (<i> + 1) newvalue = <left_score_band_info_idx>
		endif
		<i> = (<i> + 1)
		repeat (<array_size> - 1)
		repeat <array_size>
		if ((<order> [0].band_result) = (<order> [1].band_result))
			is_tie = 1
		endif
	endif
	return {
		order = <order>
		is_tie = <is_tie>
	}
endscript

script song_breakdown_shreddfest_determine_order_highest_player_score 
	requireparams \{[
			goal_results_column_data
		]
		all}
	getnumplayersingame
	getbandsstatus
	getarraysize <bands>
	order = []
	i = 0
	begin
	if (<bands> [<i>].in_game)
		if (<num_players> > 0)
			getfirstplayer
			highest_score = -1
			individual_scores = []
			j = 0
			begin
			getplayerinfo <player> band
			if (<band> = (<i> + 1))
				if ((<goal_results_column_data> [<j>]) > <highest_score>)
					<highest_score> = (<goal_results_column_data> [<j>])
				endif
				if teammodeequals \{team_mode = two_teams}
					addarrayelement {
						array = <individual_scores>
						element = {
							player_num = <player>
							player_result = (<goal_results_column_data> [<j>])
						}
					}
					<individual_scores> = <array>
				endif
			endif
			getnextplayer player = <player>
			<j> = (<j> + 1)
			repeat <num_players>
			addarrayelement {
				array = <order>
				element = {
					band_num = (<i> + 1)
					band_result = <highest_score>
					individual_results = <individual_scores>
				}
			}
			<order> = <array>
		endif
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	is_tie = 0
	getarraysize <order>
	if (<array_size> > 1)
		begin
		<i> = 0
		<index_to_access> = -1
		begin
		left_score = ((<order> [<i>]).band_result)
		right_score = ((<order> [(<i> + 1)]).band_result)
		if (<right_score> > <left_score>)
			left_score_band_info_idx = (<order> [<i>])
			setarrayelement arrayname = order index = <i> newvalue = (<order> [(<i> + 1)])
			setarrayelement arrayname = order index = (<i> + 1) newvalue = <left_score_band_info_idx>
		endif
		<i> = (<i> + 1)
		repeat (<array_size> - 1)
		repeat <array_size>
		if ((<order> [0].band_result) = (<order> [1].band_result))
			is_tie = 1
		endif
	endif
	return {
		order = <order>
		is_tie = <is_tie>
	}
endscript

script getbandscorefromdetailedstats \{band = 1}
	score = ($song_stats_backup_band [(<band> - 1)].score)
	return score = <score>
endscript

script getbandstreakfromdetailedstats \{band = 1}
	high_1p_streak = ($song_stats_backup_band [(<band> - 1)].high_1p_streak)
	high_2p_streak = ($song_stats_backup_band [(<band> - 1)].high_2p_streak)
	high_3p_streak = ($song_stats_backup_band [(<band> - 1)].high_3p_streak)
	high_4p_streak = ($song_stats_backup_band [(<band> - 1)].high_4p_streak)
	high_streak = <high_1p_streak>
	if (<high_2p_streak> > <high_streak>)
		high_streak = <high_2p_streak>
	endif
	if (<high_3p_streak> > <high_streak>)
		high_streak = <high_3p_streak>
	endif
	if (<high_4p_streak> > <high_streak>)
		high_streak = <high_4p_streak>
	endif
	return high_streak = <high_streak>
endscript

script getbandmultiplierfromdetailedstats \{band = 1}
	high_mult = ($song_stats_backup_band [(<band> - 1)].high_mult)
	return high_mult = <high_mult>
endscript
