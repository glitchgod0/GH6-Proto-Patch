
script ui_init_quest_map_giglist 
endscript

script ui_create_quest_map_giglist \{chapter_name = !q1768515945}
	audio_ui_menu_music_off
	<hero_info> = ($<chapter_name>.hero_info)
	<character_name_text> = ($<hero_info>.character_name)
	<power_description_text> = ($<hero_info>.character_power)
	<power_type_text> = ($<hero_info>.power_desc1)
	<character_description_text> = ($<hero_info>.0x1a77f5fc)
	createscreenelement {
		parent = root_window
		id = questmapgiglistid
		type = descinterface
		desc = 'career_gig_select'
		character_name_text = <character_name_text>
		power_description_text = <power_type_text>
		power_type_text = <power_description_text>
		character_description_text = <character_description_text>
	}
	questmapgiglistid :desc_resolvealias \{name = alias_songlist_menu
		param = songlist_menu}
	<songlist_menu> :se_setprops {
		event_handlers = [
			{pad_back generic_event_back}
			{pad_back ui_sfx params = {menustate = career_map uitype = back}}
			{pad_up ui_quest_map_pad_up}
			{pad_down ui_quest_map_pad_down}
		]
	}
	if questmapgiglistid :desc_resolvealias \{name = alias_challenge_led_container
			param = 0xbe20b6f7}
		<0xbe20b6f7> :obj_spawnscript ui_pulse3
	else
		scriptassert \{'dschorn1'}
	endif
	getarraysize ($<chapter_name>.songs)
	<song_index> = 0
	<num_songs_added> = 0
	<stars_earned> = 0
	begin
	<song_name> = ($<chapter_name>.songs [<song_index>])
	get_song_title song = <song_name>
	get_song_prefix song = <song_name>
	get_song_artist song = <song_name>
	format_career_song_gigtag chapter_name = ($<chapter_name>.name) song_name = <song_prefix>
	getglobaltags savegame = ($primary_controller) <song_gigtag> param = stars
	<add_song> = 1
	<encore_icon_alpha> = 0
	if (<song_name> = $<chapter_name>.encore)
		quest_progression_get_chapter_tag savegame = ($primary_controller) chapter_global = <chapter_name> param = encore_unlocked
		if (<encore_unlocked> = 0)
			<add_song> = 0
		endif
		<encore_icon_alpha> = 1
	endif
	if (<add_song> = 1)
		formattext textname = star_number_text qs(0x0bc409e2) a = <stars>
		createscreenelement {
			parent = <songlist_menu>
			type = descinterface
			desc = 'career_gig_select_item'
			song_text = <song_title>
			artist_text = <song_artist>
			star_number_text = <star_number_text>
			highlight_bar_alpha = 0
			encore_icon_alpha = <encore_icon_alpha>
			dims = (600.0, 86.0)
			event_handlers = [
				{focus ui_quest_map_giglist_focus params = {song = <song_name> song_num = (<song_index> + 1) total_songs = <array_size>}}
				{unfocus ui_quest_map_giglist_unfocus}
				{pad_choose ui_quest_map_giglist_choose params = {song_name = <song_name> chapter_name = <chapter_name>}}
			]
		}
		<num_songs_added> = (<num_songs_added> + 1)
		<stars_earned> = (<stars_earned> + <stars>)
	endif
	if NOT cd
		<id> :se_setprops event_handlers = [{pad_option ui_quest_map_giglist_debug_beat params = {song_name = <song_name> chapter_global = <chapter_name> refresh_menu = 1}}]
	endif
	<song_index> = (<song_index> + 1)
	repeat <array_size>
	<stars_needed> = ($<chapter_name>.stars_for_encore)
	<star_diff> = (<stars_needed> - <stars_earned>)
	if (<star_diff> < 0)
		<star_diff> = 0
	endif
	formattext textname = star_amount_needed_text qs(0x76b3fda7) d = <star_diff>
	questmapgiglistid :se_setprops tags = {stars_earned = <stars_earned> stars_needed = <stars_needed>} star_amount_needed_text = <star_amount_needed_text>
	<songlist_menu> :se_setprops tags = {max_items = <num_songs_added>}
	questmapgiglistid :desc_resolvealias \{name = alias_generic_scrollbar_wgt}
	generic_scrollbar_wgt_initialize id = <resolved_id>
	generic_scrollbar_wgt_set_resolution id = <resolved_id> num_elements = <num_songs_added>
	questmapgiglistid :desc_resolvealias \{name = alias_challenge_led_container}
	<percent_done> = (<stars_earned> / (<stars_needed> * 1.0))
	if (<percent_done> >= 1.0)
		<percent_done> = 1.0
		questmapgiglistid :se_setprops \{fx_special_alpha = 1}
	endif
	if (<percent_done> > 0)
		<rot_angle> = 0
		begin
		if (<rot_angle> > (360 * <percent_done>))
			break
		endif
		createscreenelement {
			type = spriteelement
			parent = <resolved_id>
			texture = medalion_meter
			rgba = [255 255 255 255]
			rot_angle = <rot_angle>
			just = [center center]
			pos_anchor = [center center]
			pos = (0.0, 0.0)
			z_priority = 101
		}
		<rot_angle> = (<rot_angle> + 1)
		repeat
	endif
	questmapgiglistid :desc_resolvealias \{name = alias_description_window
		param = window_parent}
	questmapgiglistid :desc_resolvealias \{name = alias_character_description}
	<resolved_id> :obj_spawnscriptnow ui_quest_map_giglist_scroll_text params = {parent = <window_parent> id = <resolved_id>}
	assignalias id = <songlist_menu> alias = current_menu
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green}
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red}
	if NOT cd
		add_user_control_helper \{text = qs(0x65949184)
			button = blue}
	endif
endscript

script ui_destroy_quest_map_giglist 
	clean_up_user_control_helpers
	if screenelementexists \{id = questmapgiglistid}
		destroyscreenelement \{id = questmapgiglistid}
	endif
	songlist_update_song_preview \{song = none}
endscript

script ui_deinit_quest_map_giglist 
	audio_ui_menu_music_on
endscript

script ui_quest_map_giglist_scroll_text \{parent = !q1768515945
		id = !q1768515945}
	<initial_wait> = 5.0
	wait <initial_wait> seconds
	getscreenelementdims id = <parent>
	<parent_y> = <height>
	getscreenelementdims id = <id>
	<id_y> = <height>
	if (<id_y> <= <parent_y>)
		return
	endif
	<diff> = (<parent_y> - <id_y>)
	getscreenelementposition id = <id>
	<original_pos> = <screenelementpos>
	<scroll_time> = (<diff> * -0.05)
	begin
	<id> :se_setprops pos = (<screenelementpos> + (<diff> * (0.0, 1.0))) time = <scroll_time>
	wait <scroll_time> seconds
	wait <initial_wait> seconds
	<fade_time> = 1.0
	<id> :se_setprops alpha = 0 time = <fade_time>
	wait <fade_time> seconds
	<id> :se_setprops pos = <original_pos>
	<id> :se_setprops alpha = 1 time = <fade_time>
	wait <fade_time> seconds
	wait <initial_wait> seconds
	repeat
endscript

script ui_quest_map_giglist_choose \{song_name = !q1768515945
		chapter_name = !q1768515945}
	questmapgiglistid :gettags
	if (<stars_earned> >= <stars_needed>)
		quest_progression_set_player_score_attribute \{level = 2}
	endif
	playlist_setcurrentsong song = <song_name>
	<venue> = ($<chapter_name>.venue)
	if structurecontains structure = ($levelzones.<venue>) name = loading_movie
		create_venue_loading_screen movie_params = ($levelzones.<venue>)
	endif
	generic_event_choose \{state = uistate_play_song}
endscript

script ui_quest_map_giglist_focus \{song_num = !i1768515945
		total_songs = !i1768515945
		song = !q1768515945}
	obj_getid
	<objid> :se_setprops {
		highlight_bar_alpha = 1
		song_rgba = [249 243 190 255]
		artist_rgba = [249 243 190 255]
	}
	songlist_update_song_preview song = <song>
endscript

script ui_quest_map_giglist_unfocus 
	obj_getid
	<objid> :se_setprops {
		highlight_bar_alpha = 0
		song_rgba = [206 196 124 255]
		artist_rgba = [174 148 87 255]
	}
endscript

script ui_quest_map_pad_up 
	gettags
	menu_getselectedindex
	if (<selected_index> > 0)
		ui_sfx \{menustate = career_map
			uitype = scrollup}
		questmapgiglistid :desc_resolvealias \{name = alias_generic_scrollbar_wgt}
		generic_scrollbar_wgt_update_thumb_pos id = <resolved_id> dir = up
	endif
endscript

script ui_quest_map_pad_down 
	gettags
	menu_getselectedindex
	if (<selected_index> + 1 < <max_items>)
		ui_sfx \{menustate = career_map
			uitype = scrolldown}
		questmapgiglistid :desc_resolvealias \{name = alias_generic_scrollbar_wgt}
		generic_scrollbar_wgt_update_thumb_pos id = <resolved_id> dir = down
	endif
endscript

script ui_quest_map_giglist_debug_beat \{song_name = !q1768515945
		chapter_global = !q1768515945
		refresh_menu = !i1768515945}
	<chapter_name> = ($<chapter_global>.name)
	get_song_name song = <song_name>
	format_career_song_gigtag chapter_name = <chapter_name> song_name = <song_name>
	setglobaltags savegame = ($primary_controller) <song_gigtag> params = {stars = 5} progression = true
	<stars_needed> = ($<chapter_global>.stars_for_encore)
	<total_stars> = 0
	getarraysize ($<chapter_global>.songs)
	<song_index> = 0
	begin
	<song_name> = ($<chapter_global>.songs [<song_index>])
	get_song_name song = <song_name>
	format_career_song_gigtag chapter_name = <chapter_name> song_name = <song_name>
	getglobaltags savegame = ($primary_controller) <song_gigtag> param = stars
	<total_stars> = (<total_stars> + <stars>)
	<song_index> = (<song_index> + 1)
	repeat <array_size>
	if (<total_stars> >= <stars_needed>)
		quest_progression_set_chapter_tags savegame = ($primary_controller) chapter_global = <chapter_global> params = {encore_unlocked = 1}
		quest_progression_set_chapter_tags savegame = ($primary_controller) chapter_global = <chapter_global> params = {completed = 1}
		updateatoms savegame = ($primary_controller)
	endif
	if (<refresh_menu> = 1)
		ui_event \{event = menu_refresh}
	endif
endscript
