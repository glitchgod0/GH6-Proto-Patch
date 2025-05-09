g_songlist_options_item_unfocus_rgba = [
	205
	185
	123
	255
]
g_songlist_options_item_focus_rgba = [
	249
	243
	190
	255
]
g_songlist_options_item_invalid_rgba = [
	170
	149
	83
	80
]
main_songlist_options = [
	{
		text = qs(0xa68ba095)
		pad_choose_script = songlist_main_options_play_song
		option_boolean_script = is_current_playlist_empty
		force_add
	}
	{
		text = qs(0x6579b990)
		pad_choose_script = songlist_main_options_add_to_playlist
	}
	{
		text = qs(0x7ef467a3)
		pad_choose_script = songlist_main_options_remove_from_playlist
	}
	{
		text = qs(0x2842d903)
		option_boolean_script = allow_view_awards_option
		pad_choose_script = songlist_main_options_view_awards
	}
	{
		text = qs(0x69494c03)
		pad_choose_script = songlist_main_options_download_similar
		not_focusable
	}
	{
		text = qs(0x0c9cc77e)
		pad_choose_script = songlist_main_options_random_songs
	}
	{
		text = qs(0x54ba1bc5)
		pad_choose_script = songlist_options_clear_query
		option_boolean_script = is_a_playlist_loaded
	}
	{
		text = qs(0x63387d22)
		pad_choose_script = songlist_main_options_go_to_playlist_options
	}
	{
		text = qs(0x04c18b76)
		pad_choose_script = songlist_main_options_go_to_display_options
	}
]
playlist_songlist_options = [
	{
		text = qs(0xf481e489)
		pad_choose_script = songlist_options_load
	}
	{
		text = qs(0x1840c8c2)
		pad_choose_script = songlist_options_save
		option_boolean_script = allow_songlist_options_writes
	}
	{
		text = qs(0x612ddd8d)
		pad_choose_script = songlist_options_shuffle
		option_boolean_script = is_a_playlist_loaded
	}
	{
		text = qs(0xed733529)
		pad_choose_script = songlist_options_delete
		option_boolean_script = allow_songlist_options_writes
	}
]
display_songlist_options = [
	{
		text = qs(0x8704b183)
		textureon = options_controller_check
		textureoff = options_controller_x
		toggle_checksum = g_songlist_show_more_info
		pad_choose_script = songlist_options_show_more_info_toggle
	}
	{
		text = qs(0x3df210b8)
		textureon = options_controller_check
		textureoff = options_controller_x
		toggle_checksum = g_songlist_show_ghtunes
		pad_choose_script = songlist_options_show_ghtunes_toggle
		option_boolean_script = allow_show_ghtunes_toggle
	}
]
music_store_songlist_options = [
]
songlist_options_ready_to_proceed = 0
g_songlist_options_dirty = 0
g_songlist_refresh_menus = 0
g_songlist_options_back_requires_unblock = 0
g_first_empty_custom_playlist_slot = 0
g_current_loaded_custom_playlist_index = -1
g_songlist_show_more_info = 0
g_songlist_show_ghtunes = 1
0x42a06e7f = 0
g_gbm_exclusive_device = 0
g_gbm_savegame_device = 0

script ui_create_songlist_options 
	setmenuautorepeattimes \{(0.3, 0.1)}
	<passed_in_type> = <type>
	if (<passed_in_type> = main)
		get_savegame_from_controller controller = <savegame_device>
		getglobaltags savegame = <savegame> custom_playlists param = custom_playlists
		change custom_playlists = <custom_playlists>
	endif
	change \{g_songlist_options_dirty = 0}
	createscreenelement {
		type = descinterface
		desc = 'songlist_options'
		id = songlist_options
		parent = root_window
		z_priority = 107
		pos = (672.0, 140.0)
		songlist_options_main_cont_pos = <pos>
	}
	if songlist_options :desc_resolvealias \{name = alias_generic_scrollbar_wgt}
		assignalias id = <resolved_id> alias = songlist_options_scrollbar_wgt
		generic_scrollbar_wgt_initialize \{id = songlist_options_scrollbar_wgt}
	else
		scriptassert \{qs(0x7631f46d)}
	endif
	songlist_options :settags {
		show_more_info_on_enter = ($g_songlist_show_more_info)
		show_ghtunes_on_enter = ($g_songlist_show_ghtunes)
		0x5dd074a7 = ($0x42a06e7f)
	}
	if (<passed_in_type> = main)
		<song_options_bool_array> = [1]
		addarrayelement array = <song_options_bool_array> element = (<song_options_struct>.add_song)
		<song_options_bool_array> = <array>
		addarrayelement array = <song_options_bool_array> element = (<song_options_struct>.remove_song)
		<song_options_bool_array> = <array>
		<song_item_id> :se_getprops songlist_item_text_text
		songlist_options :settags {
			title_text = <songlist_item_text_text>
			song_item_id = <song_item_id>
			song_options_bool_array = <song_options_bool_array>
		}
		songlist_options_keep_focus id = <song_item_id>
	elseif (<passed_in_type> = music_store)
		change \{music_store_songlist_options = [
			]}
		songlist_options :settags {
			purchase_checksum = (<purchase_struct>.song_checksum)
		}
		if (<purchase_struct>.type = song)
			<element> = {
				text = qs(0xdfb2b37f)
				pad_choose_script = songlist_options_music_store_preview_song
				pad_choose_params = {song_preview_asset_name = (<purchase_struct>.song_preview_asset_name)}
			}
			addarrayelement array = ($music_store_songlist_options) element = <element>
			change music_store_songlist_options = <array>
		endif
		if (<purchase_struct>.purchased = 1)
			<element> = {
				text = qs(0xef99ba5a)
				pad_choose_script = songlist_options_music_store_purchase_accepted
				pad_choose_params = {purchase_struct = <purchase_struct>}
			}
			addarrayelement array = ($music_store_songlist_options) element = <element>
			change music_store_songlist_options = <array>
		else
			if (<purchase_struct>.type = song)
				if NOT structurecontains \{structure = purchase_struct
						album_pack_only}
					<element> = {
						text = qs(0xe6d6f69f)
						pad_choose_script = songlist_options_music_store_purchase_accepted
						pad_choose_params = {purchase_struct = <purchase_struct>}
					}
					addarrayelement array = ($music_store_songlist_options) element = <element>
					change music_store_songlist_options = <array>
				endif
				if structurecontains \{structure = purchase_struct
						pack_list}
					<pack_list> = (<purchase_struct>.pack_list)
					getarraysize <pack_list>
					if (<array_size> > 0)
						<filterspec> = [
							{
								key = song_checksum
								union_list = <pack_list>
								comparator = equal
							}
						]
						songlist_options_music_store_request_page_when_ready {
							filterspec = <filterspec>
						}
						begin
						if ($songlist_options_ready_to_proceed = 1)
							change \{songlist_options_ready_to_proceed = 0}
							break
						endif
						wait \{1
							gameframe}
						repeat
					endif
				endif
			else
				<element> = {
					text = qs(0xe6d6f69f)
					pad_choose_script = songlist_options_music_store_purchase_accepted
					pad_choose_params = {purchase_struct = <purchase_struct>}
				}
				addarrayelement array = ($music_store_songlist_options) element = <element>
				change music_store_songlist_options = <array>
				if structurecontains \{structure = purchase_struct
						pack_contents}
					<pack_contents> = (<purchase_struct>.pack_contents)
					getarraysize <pack_contents>
					if (<array_size> > 0)
						if NOT structurecontains \{structure = purchase_struct
								album_pack_only}
							<element> = {
								text = qs(0xc1621163)
								pad_choose_script = songlist_options_music_store_new_view_go_back
								pad_choose_params = {pack_struct = <purchase_struct>}
							}
							addarrayelement array = ($music_store_songlist_options) element = <element>
							change music_store_songlist_options = <array>
						endif
					endif
				endif
			endif
		endif
	endif
	if songlist_options :desc_resolvealias \{name = alias_songlist_options_vmenu}
		assignalias id = <resolved_id> alias = songlist_options_vmenu
		songlist_options_vmenu :se_setprops \{event_handlers = [
				{
					menu_selection_changed
					ui_sfx
					params = {
						menustate = generic
						uitype = scrollup
					}
				}
			]
			replace_handlers}
	else
		scriptassert \{qs(0x16858aa6)}
	endif
	if songlist_options :desc_resolvealias \{name = alias_songlist_options_smenu}
		assignalias id = <resolved_id> alias = songlist_options_smenu
		songlist_options_smenu :settags \{treat_not_focusable_as_header}
	else
		scriptassert \{qs(0x5d0c7d66)}
	endif
	songlist_options_setup_menu {
		exclusive_device = <exclusive_device>
		savegame_device = <savegame_device>
		type = <passed_in_type>
	}
	songlist_options_create_default_user_control_helpers
endscript

script ui_return_songlist_options 
	songlist_options_create_default_user_control_helpers
endscript

script songlist_options_setup_menu \{type = main}
	if gotparam \{exclusive_device}
		change g_gbm_exclusive_device = <exclusive_device>
	endif
	if gotparam \{savegame_device}
		change g_gbm_savegame_device = <savegame_device>
	endif
	if ((<type> = main) || (<type> = sort) || (<type> = jump) || (<type> = music_store))
		songlist_options_vmenu :se_setprops {
			event_handlers = [
				{pad_back songlist_options_back}
			]
			exclusive_device = ($g_gbm_exclusive_device)
			replace_handlers
		}
	else
		songlist_options_vmenu :se_setprops {
			event_handlers = [
				{pad_back songlist_options_go_to_menu params = {type = main}}
			]
			exclusive_device = ($g_gbm_exclusive_device)
			replace_handlers
		}
	endif
	if NOT gotparam \{no_options}
		songlist_options_create_menu_options type = <type>
	endif
endscript

script songlist_options_create_default_user_control_helpers 
	clean_up_user_control_helpers
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green
		z = 100000}
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red
		z = 100000}
endscript

script songlist_options_accept_name 
	getarraysize \{$custom_playlists}
	<i> = 0
	begin
	if ((($custom_playlists) [<i>]).name = <text>)
		formattext textname = warning_text qs(0x52b92bd3) n = <text>
		create_dialog_box {
			heading_text = qs(0xaa163738)
			body_text = <warning_text>
			player_device = ($g_gbm_exclusive_device)
			options = [
				{
					func = songlist_options_refresh_edit_name
					text = qs(0x0e41fe46)
				}
			]
		}
		return
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	soundevent \{event = audio_ui_text_entry_finish}
	change g_current_loaded_custom_playlist_index = ($g_first_empty_custom_playlist_slot)
	<playlist_entry> = {
		name = <text>
		playlist = ($current_playlist)
	}
	setarrayelement arrayname = custom_playlists index = ($g_first_empty_custom_playlist_slot) newvalue = <playlist_entry> globalarray
	songlist_options_save_and_go_back exclusive_device = ($g_gbm_exclusive_device)
endscript

script songlist_options_refresh_edit_name 
	songlist_options_destroy_dialog \{no_focus = 1}
	ui_event \{event = menu_refresh}
endscript

script songlist_options_cancel_name 
	ui_sfx \{menustate = setlist
		uitype = back}
	ui_event event = menu_back data = {
		state = uistate_songlist_options
		exclusive_device = ($g_gbm_exclusive_device)
		savegame_device = ($g_gbm_savegame_device)
	}
	songlist_options_vmenu :se_setprops \{unblock_events}
endscript

script ui_destroy_songlist_options 
	destroyscreenelement \{id = songlist_options}
	clean_up_user_control_helpers
	songlist_create_default_user_control_helpers \{mode = playlist}
endscript

script songlist_options_create_menu_options \{type = main}
	if ((<type> = main) || (<type> = playlist) || (<type> = display) || (<type> = music_store))
		if (<type> = main)
			songlist_options :getsingletag \{title_text}
		elseif (<type> = playlist)
			<title_text> = qs(0xa83e4d6f)
		elseif (<type> = display)
			<title_text> = qs(0x1b24235a)
		endif
		songlist_options :se_setprops {
			songlist_options_text_text = <title_text>
		}
		extendcrc <type> '_songlist_options' out = options_array
		getarraysize $<options_array>
		<options_array_size> = <array_size>
		if (<options_array_size> > 0)
			<num_menu_items> = 0
			<i> = 0
			begin
			<item_struct> = ($<options_array> [<i>])
			<continue> = 1
			if structurecontains structure = <item_struct> pad_choose_params
				<pad_choose_params> = (<item_struct>.pad_choose_params)
			else
				<pad_choose_params> = {}
			endif
			<option_boolean_params> = {}
			if (<type> = main)
				songlist_options :getsingletag \{song_options_bool_array}
				songlist_options :getsingletag \{song_item_id}
				<pad_choose_params> = {
					<pad_choose_params>
					song_item_id = <song_item_id>
				}
				<option_boolean_params> = {song_item_id = <song_item_id>}
				getarraysize <song_options_bool_array>
				if (<i> < <array_size>)
					if (<song_options_bool_array> [<i>] = 0)
						<continue> = 0
					endif
				endif
			endif
			if structurecontains structure = <item_struct> option_boolean_script
				if NOT (<item_struct>.option_boolean_script) <option_boolean_params>
					<continue> = 0
				endif
			endif
			<common_params> = {
				text_unfocus_color = ($g_songlist_options_item_unfocus_rgba)
			}
			if (<continue> = 0)
				if structurecontains structure = <item_struct> force_add
					<continue> = 1
					<common_params> = {
						text_unfocus_color = ($g_songlist_options_item_invalid_rgba)
						not_focusable
					}
				endif
			endif
			if (<continue> = 1)
				<num_menu_items> = (<num_menu_items> + 1)
				<common_params> = {
					<common_params>
					text = (<item_struct>.text)
					text_focus_color = ($g_songlist_options_item_focus_rgba)
					pad_choose_script = (<item_struct>.pad_choose_script)
					pad_choose_params = <pad_choose_params>
				}
				if structurecontains structure = <item_struct> not_focusable
					<common_params> = {
						<common_params>
						not_focusable
						text_unfocus_color = ($g_songlist_options_item_invalid_rgba)
					}
				endif
				if structurecontains structure = <item_struct> toggle_checksum
					<toggle_checksum> = (<item_struct>.toggle_checksum)
					if (($<toggle_checksum>) = 0)
						<texture> = (<item_struct>.textureoff)
					else
						<texture> = (<item_struct>.textureon)
					endif
					songlist_options_add_item {
						<common_params>
						icon = <texture>
						icon_first = 0
						dont_force_quit = 1
					}
				else
					songlist_options_add_item {
						<common_params>
					}
				endif
			endif
			<i> = (<i> + 1)
			repeat <options_array_size>
			generic_scrollbar_wgt_set_resolution id = songlist_options_scrollbar_wgt num_elements = <num_menu_items>
		endif
	elseif (<type> = sort)
		songlist_options :se_setprops \{songlist_options_text_text = qs(0x00a93373)}
		getarraysize \{$g_songlist_sort_array}
		if (<array_size> > 0)
			<i> = 0
			begin
			<visibility> = (($g_songlist_sort_array) [<i>].visibility)
			if (<visibility> = always)
				<item_is_valid> = 1
			elseif (<visibility> = never)
				<item_is_valid> = 0
			else
				songlist_component :membfunc_songlist_uistack_getmode
				if (<mode> != music_store && <visibility> = songlist_only)
					<item_is_valid> = 1
				elseif (<mode> = music_store && <visibility> = store_only)
					<item_is_valid> = 1
				else
					<item_is_valid> = 0
				endif
			endif
			if (<item_is_valid> = 1)
				songlist_options_add_item {
					text = (($g_songlist_sort_array) [<i>].text)
					text_focus_color = ($g_songlist_options_item_focus_rgba)
					text_unfocus_color = ($g_songlist_options_item_unfocus_rgba)
					pad_choose_script = songlist_options_sort
					pad_choose_params = {index = <i>}
					dont_force_quit = 1
				}
			endif
			<i> = (<i> + 1)
			repeat <array_size>
			generic_scrollbar_wgt_set_resolution id = songlist_options_scrollbar_wgt num_elements = <array_size>
		endif
	elseif (<type> = jump)
		formattext textname = jump_title qs(0xf1a849d1) s = (($g_songlist_sort_array [($g_songlist_sort_index)]).text)
		songlist_options :se_setprops {
			songlist_options_text_text = <jump_title>
		}
		<header_type> = (($g_songlist_sort_array [($g_songlist_sort_index)]).header_type)
		<header_array> = (($g_songlist_headers).<header_type>)
		getarraysize <header_array>
		if (<array_size> > 0)
			<i> = 0
			begin
			<header_struct> = (<header_array> [<i>])
			if NOT structurecontains structure = <header_struct> header_text_override
				<text> = (<header_struct>.header_text)
			else
				<text> = (<header_struct>.header_text_override)
			endif
			<params> = {
				text = <text>
				text_focus_color = ($g_songlist_options_item_focus_rgba)
				text_unfocus_color = ($g_songlist_options_item_unfocus_rgba)
				pad_choose_script = songlist_options_jump_to_header
				pad_choose_params = {header_type = <header_type> header_struct = <header_struct> index = <i>}
				dont_force_quit = 1
			}
			if structurecontains structure = <header_struct> valid
				if (<header_struct>.valid = 0)
					<params> = {
						<params>
						not_focusable
						text_unfocus_color = ($g_songlist_options_item_invalid_rgba)
					}
				endif
			endif
			songlist_options_add_item {
				<params>
			}
			<i> = (<i> + 1)
			repeat <array_size>
			generic_scrollbar_wgt_set_resolution id = songlist_options_scrollbar_wgt num_elements = <array_size>
		endif
	endif
endscript

script songlist_options_add_item {
		text_unfocus_color = ($menu_unfocus_color)
		text_focus_color = ($menu_focus_color)
		just = [left center]
	}
	<params> = {
		type = descinterface
		parent = songlist_options_vmenu
		autosizedims = true
		menurow_txt_item_text = <text>
		menurow_txt_item_font = fontgrid_text_a1
		menurow_txt_item_rgba = <text_unfocus_color>
		menurow_txt_item_dims = (448.0, 40.0)
		menurow_just = <just>
		menurow_internal_just = <just>
		tags = {
			text_unfocus_color = <text_unfocus_color>
			text_focus_color = <text_focus_color>
		}
	}
	if NOT gotparam \{icon}
		<params> = {
			<params>
			desc = 'menurow_txt_desc'
			event_handlers = [
				{focus songlist_options_focus params = {id = <id>}}
				{unfocus songlist_options_unfocus params = {id = <id>}}
				{pad_choose generic_blocking_execute_script params = {pad_script = <pad_choose_script> pad_params = {container_id = <id> <pad_choose_params>}}}
			]
		}
	else
		formattext \{checksumname = menurow_ico_item
			'menurow_ico_item_%i'
			i = $g_num_menu_items_with_icon}
		change g_num_menu_items_with_icon = ($g_num_menu_items_with_icon + 1)
		<params> = {
			<params>
			menurow_ico_item_texture = <icon>
			event_handlers = [
				{focus songlist_options_focus params = {id = <id>}}
				{unfocus songlist_options_unfocus params = {id = <id>}}
				{pad_choose generic_blocking_execute_script params = {pad_script = <pad_choose_script> pad_params = {container_id = <id> <pad_choose_params> icon_id = <menurow_ico_item>}}}
			]
		}
		if (<icon_first> = 1)
			<params> = {
				<params>
				desc = 'menurow_ico_txt_desc'
			}
		else
			<params> = {
				<params>
				desc = 'menurow_txt_ico_desc'
			}
		endif
	endif
	createscreenelement {
		<params>
	}
	if <id> :desc_resolvealias name = alias_menurow_ico_item
		assignalias id = <resolved_id> alias = <menurow_ico_item>
	endif
	if gotparam \{not_focusable}
		<id> :se_setprops not_focusable
	endif
endscript

script songlist_options_focus \{time = 0.05}
	text_focus_color = ($menu_focus_color)
	if NOT gotparam \{id}
		obj_getid
		<id> = <objid>
	endif
	<id> :getsingletag text_focus_color
	<id> :se_setprops {
		menurow_txt_item_font = fontgrid_text_a1
		menurow_txt_item_rgba = <text_focus_color>
		menurow_highlight_bar_alpha = 1.0
		motion = ease_in
		time = <time>
	}
	songlist_options_vmenu :getsingletag \{tag_selected_index}
	generic_scrollbar_wgt_update_thumb_pos id = songlist_options_scrollbar_wgt index = <tag_selected_index>
endscript

script songlist_options_unfocus \{time = 0.0}
	text_unfocus_color = ($menu_unfocus_color)
	if NOT gotparam \{id}
		obj_getid
		<id> = <objid>
	endif
	<id> :getsingletag text_unfocus_color
	<id> :se_setprops {
		menurow_txt_item_font = fontgrid_text_a1
		menurow_txt_item_rgba = <text_unfocus_color>
		menurow_highlight_bar_alpha = 0.0
		motion = ease_in
		time = <time>
	}
endscript

script songlist_options_jump_to_header \{header_type = !q1768515945
		header_struct = 0x69696969
		index = !i1768515945}
	switch <header_type>
		case alphabetical
		case genre
		case source
		if NOT structurecontains structure = <header_struct> seek_first
			<text> = (<header_struct>.header_text)
		else
			<text> = (<header_struct>.seek_first)
		endif
		change g_songlist_seek_first = <text>
		case year
		case duration
		case intensity
		change g_songlist_seek_first = (<header_struct>.lower)
		case popularity
		songlist_component :membfunc_songlist_uistack_getpopularitysortseekfirstdata index = <index>
		change g_songlist_seek_first = <seek_first_data>
	endswitch
	change \{g_songlist_refresh_menus = 1}
	change \{g_songlist_options_back_requires_unblock = 1}
	generic_event_back \{data = {
			no_pivot
		}}
endscript

script songlist_options_sort \{index = !i1768515945}
	songlist_sort index = <index>
	generic_event_back
endscript

script songlist_options_save 
	ui_sfx \{menustate = setlist
		uitype = select}
	if NOT is_a_playlist_loaded
		launchevent \{type = unfocus
			target = songlist_options_vmenu}
		songlist_options_vmenu :se_setprops \{block_events}
		create_dialog_box {
			heading_text = qs(0xaa163738)
			body_text = qs(0x7d6a4901)
			player_device = ($g_gbm_exclusive_device)
			options = [
				{
					func = songlist_options_destroy_dialog
					text = qs(0x0e41fe46)
				}
			]
		}
	else
		if ($g_current_loaded_custom_playlist_index = -1)
			if get_first_empty_custom_playlist_slot
				songlist_options_create_new_confirm index = <slot> exclusive_device = ($g_gbm_exclusive_device)
			else
				launchevent \{type = unfocus
					target = songlist_options_vmenu}
				songlist_options_vmenu :se_setprops \{block_events}
				create_dialog_box {
					heading_text = qs(0xaa163738)
					body_text = qs(0x7764e154)
					player_device = ($g_gbm_exclusive_device)
					options = [
						{
							func = songlist_options_destroy_dialog
							text = qs(0x0e41fe46)
						}
					]
				}
			endif
		else
			launchevent \{type = unfocus
				target = songlist_options_vmenu}
			songlist_options_vmenu :se_setprops \{block_events}
			create_dialog_box {
				heading_text = qs(0xaa163738)
				body_text = qs(0xfdbc4b34)
				player_device = ($g_gbm_exclusive_device)
				back_button_script = songlist_options_destroy_dialog
				options = [
					{
						func = songlist_options_destroy_dialog
						text = qs(0xf7723015)
					}
					{
						func = songlist_options_overwrite_confirm
						func_params = {exclusive_device = ($g_gbm_exclusive_device)}
						text = qs(0xf77909ae)
					}
					{
						func = songlist_options_create_new_confirm
						func_params = {exclusive_device = ($g_gbm_exclusive_device)}
						text = qs(0xa1ea347f)
					}
				]
			}
		endif
	endif
endscript

script songlist_options_overwrite_confirm 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	destroy_dialog_box
	<index> = ($g_current_loaded_custom_playlist_index)
	<playlist_entry> = {
		name = (($custom_playlists) [<index>].name)
		playlist = ($current_playlist)
	}
	setarrayelement arrayname = custom_playlists index = <index> newvalue = <playlist_entry> globalarray
	songlist_options_save_and_go_back exclusive_device = ($g_gbm_exclusive_device)
endscript

script songlist_options_create_new_confirm 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	songlist_options_destroy_dialog
	if get_first_empty_custom_playlist_slot
		change g_first_empty_custom_playlist_slot = <slot>
		formattext textname = playlist_name qs(0xc0114aa1) i = (<slot> + 1)
		gamemode_gettype
		if ((<type> != freeplay) && ($g_songlist_options_dirty = 1))
			get_savegame_from_controller controller = ($g_gbm_savegame_device)
			setglobaltags savegame = <savegame> custom_playlists params = {custom_playlists = ($custom_playlists)}
			setglobaltags savegame = <savegame> songlist_options params = {show_more_info = ($g_songlist_show_more_info) show_ghtunes = ($g_songlist_show_ghtunes)}
			songlist_deinit_music_store
			<event_func> = ui_memcard_autosave_replace
		else
			<event_func> = ui_event
		endif
		<event_func> event = menu_change is_popup data = {
			is_popup
			state = uistate_edit_name
			default_name = <playlist_name>
			char_limit = 18
			title = qs(0x3703427b)
			accept_script = songlist_options_accept_name
			cancel_script = songlist_options_cancel_name
			device_num = ($g_gbm_exclusive_device)
		}
	else
		launchevent \{type = unfocus
			target = songlist_options_vmenu}
		songlist_options_vmenu :se_setprops \{block_events}
		create_dialog_box {
			heading_text = qs(0xaa163738)
			body_text = qs(0xaaf1b4f3)
			player_device = ($g_gbm_exclusive_device)
			options = [
				{
					func = songlist_options_destroy_dialog
					text = qs(0xf7723015)
				}
				{
					func = songlist_options_overwrite_confirm
					func_params = {exclusive_device = ($g_gbm_exclusive_device)}
					text = qs(0xf77909ae)
				}
			]
		}
	endif
endscript

script songlist_options_select_create 
	launchevent \{type = unfocus
		target = songlist_options_vmenu}
	songlist_options_vmenu :se_setprops \{block_events}
	songlist :obj_spawnscriptnow \{songlist_create_playlist
		params = {
			no_focus = 1
			no_refresh = 1
			no_detail_transition = 1
		}}
	change \{g_songlist_refresh_menus = 1}
	songlist_options_back \{no_sound}
endscript

script songlist_options_load 
	destroyscreenelement \{id = songlist_options_vmenu
		preserve_parent}
	setscreenelementlock \{id = songlist_options_vmenu
		off}
	setscreenelementlock \{id = songlist_options_vmenu
		on}
	ui_sfx \{menustate = setlist
		uitype = select}
	getarraysize \{$locked_playlists}
	<locked_size> = <array_size>
	getarraysize \{$custom_playlists}
	<custom_size> = <array_size>
	<total_size> = (<locked_size> + <custom_size>)
	if (<total_size> > 0)
		songlist_options :se_setprops \{songlist_options_text_text = qs(0xf481e489)}
		event_handlers = [
			{pad_back songlist_options_go_to_menu params = {type = playlist}}
		]
		songlist_options_vmenu :se_setprops {
			event_handlers = <event_handlers>
			replace_handlers
		}
		songlist_options_vmenu :se_setprops \{unblock_events}
		launchevent \{type = focus
			target = songlist_options_vmenu}
		<num_menu_items> = 0
		if (<locked_size> > 0)
			<i> = 0
			begin
			if NOT is_playlist_slot_empty playlists = locked slot = <i>
				<num_menu_items> = (<num_menu_items> + 1)
				<item_struct> = (($locked_playlists) [<i>])
				songlist_options_add_item {
					text = (<item_struct>.name)
					text_focus_color = ($g_songlist_options_item_focus_rgba)
					text_unfocus_color = ($g_songlist_options_item_unfocus_rgba)
					pad_choose_script = songlist_options_load_query
					pad_choose_params = {index = <i> text = (<item_struct>.name) playlists = locked}
				}
			endif
			<i> = (<i> + 1)
			repeat <locked_size>
			generic_scrollbar_wgt_set_resolution id = songlist_options_scrollbar_wgt num_elements = <num_menu_items>
		endif
		<i> = 0
		begin
		if NOT is_playlist_slot_empty playlists = custom slot = <i>
			<num_menu_items> = (<num_menu_items> + 1)
			<item_struct> = (($custom_playlists) [<i>])
			songlist_options_add_item {
				text = (<item_struct>.name)
				text_focus_color = ($g_songlist_options_item_focus_rgba)
				text_unfocus_color = ($g_songlist_options_item_unfocus_rgba)
				pad_choose_script = songlist_options_load_query
				pad_choose_params = {index = <i> text = (<item_struct>.name) playlists = custom}
			}
		endif
		<i> = (<i> + 1)
		repeat <custom_size>
		generic_scrollbar_wgt_set_resolution id = songlist_options_scrollbar_wgt num_elements = <num_menu_items>
	endif
	songlist_options_create_default_user_control_helpers
endscript

script songlist_options_delete 
	ui_sfx \{menustate = setlist
		uitype = select}
	if NOT does_custom_playlist_exist
		launchevent \{type = unfocus
			target = songlist_options_vmenu}
		songlist_options_vmenu :se_setprops \{block_events}
		create_dialog_box {
			heading_text = qs(0xaa163738)
			body_text = qs(0xb5d36d74)
			player_device = ($g_gbm_exclusive_device)
			options = [
				{
					func = songlist_options_destroy_dialog
					text = qs(0x0e41fe46)
				}
			]
		}
		return
	endif
	destroyscreenelement \{id = songlist_options_vmenu
		preserve_parent}
	setscreenelementlock \{id = songlist_options_vmenu
		off}
	setscreenelementlock \{id = songlist_options_vmenu
		on}
	getarraysize \{$custom_playlists}
	if (<array_size> > 0)
		songlist_options :se_setprops \{songlist_options_text_text = qs(0xed733529)}
		event_handlers = [
			{pad_back songlist_options_go_to_menu params = {type = playlist}}
		]
		songlist_options_vmenu :se_setprops {
			event_handlers = <event_handlers>
			replace_handlers
		}
		songlist_options_vmenu :se_setprops \{unblock_events}
		launchevent \{type = focus
			target = songlist_options_vmenu}
		<i> = 0
		<num_menu_items> = 0
		begin
		if NOT is_playlist_slot_empty playlists = custom slot = <i>
			<num_menu_items> = (<num_menu_items> + 1)
			<item_struct> = (($custom_playlists) [<i>])
			songlist_options_add_item {
				text = (<item_struct>.name)
				text_focus_color = ($g_songlist_options_item_focus_rgba)
				text_unfocus_color = ($g_songlist_options_item_unfocus_rgba)
				pad_choose_script = songlist_options_deletion_query
				pad_choose_params = {index = <i>}
			}
		endif
		<i> = (<i> + 1)
		repeat <array_size>
		generic_scrollbar_wgt_set_resolution id = songlist_options_scrollbar_wgt num_elements = <num_menu_items>
	endif
	songlist_options_create_default_user_control_helpers
endscript

script songlist_options_clear_query 
	ui_sfx \{menustate = setlist
		uitype = select}
	launchevent \{type = unfocus
		target = songlist_options_vmenu}
	songlist_options_vmenu :se_setprops \{block_events}
	formattext \{textname = clear_text
		qs(0xdde7cc6a)}
	create_dialog_box {
		heading_text = qs(0xaa163738)
		body_text = <clear_text>
		player_device = ($g_gbm_exclusive_device)
		options = [
			{
				func = songlist_options_destroy_dialog
				text = qs(0xf7723015)
			}
			{
				func = songlist_options_clear_all
				text = qs(0xe6bedbca)
			}
		]
	}
endscript

script songlist_options_clear_all 
	songlist_options_destroy_dialog \{no_focus}
	songlist_clear
	ui_sfx \{menustate = setlist
		uitype = select}
	songlist_create_play_song \{no_focus = 1
		no_refresh = 1
		no_detail_transition = 1}
	change \{g_songlist_refresh_menus = 1}
	songlist_options_back \{no_sound}
endscript

script songlist_options_shuffle 
	getarraysize \{$current_playlist}
	ui_sfx \{menustate = setlist
		uitype = select}
	if (<array_size> > 1)
		<i> = 0
		begin
		getrandomvalue a = 0 b = (<array_size> - <i> - 1) name = remaining_range integer
		<random_pos> = (<i> + <remaining_range>)
		<temp> = ($current_playlist [<i>])
		setarrayelement arrayname = current_playlist globalarray index = <i> newvalue = ($current_playlist [<random_pos>])
		setarrayelement arrayname = current_playlist globalarray index = <random_pos> newvalue = <temp>
		<i> = (<i> + 1)
		repeat (<array_size> - 1)
		change \{g_songlist_refresh_menus = 1}
		change \{g_songlist_options_back_requires_unblock = 1}
	endif
	songlist_options_back \{no_sound}
endscript

script songlist_options_destroy_dialog 
	destroy_dialog_box
	if NOT gotparam \{no_focus}
		if screenelementexists \{id = songlist_options_vmenu}
			songlist_options_vmenu :se_setprops \{unblock_events}
			launchevent \{type = focus
				target = songlist_options_vmenu}
		else
			songlist_options_setup_menu exclusive_device = <exclusive_device> savegame_device = <savegame_device>
		endif
	else
		if screenelementexists \{id = songlist_options_vmenu}
			launchevent \{type = unfocus
				target = songlist_options_vmenu}
			songlist_options_vmenu :se_setprops \{block_events}
		endif
	endif
	songlist_options_create_default_user_control_helpers
endscript

script songlist_options_deletion_query 
	launchevent \{type = unfocus
		target = songlist_options_vmenu}
	songlist_options_vmenu :se_setprops \{block_events}
	formattext textname = deletion_text qs(0x9c3cfb6b) c = ((($custom_playlists) [<index>]).name)
	create_dialog_box {
		heading_text = qs(0xaa163738)
		body_text = <deletion_text>
		player_device = ($g_gbm_exclusive_device)
		options = [
			{
				func = songlist_options_destroy_dialog
				text = qs(0xf7723015)
			}
			{
				func = songlist_options_deletion_confirm
				func_params = {index = <index>}
				text = qs(0x271a1633)
			}
		]
	}
endscript

script songlist_options_deletion_confirm 
	requireparams \{[
			index
		]
		all}
	delete_custom_playlist_slot slot = <index>
	if (<index> = $g_current_loaded_custom_playlist_index)
		change \{g_current_loaded_custom_playlist_index = -1}
	endif
	songlist_options_destroy_dialog
	change \{g_songlist_options_dirty = 1}
	songlist_options_go_to_menu \{type = playlist}
endscript

script songlist_options_load_query 
	launchevent \{type = unfocus
		target = songlist_options_vmenu}
	songlist_options_vmenu :se_setprops \{block_events}
	if is_a_playlist_loaded
		formattext textname = load_text qs(0x167cfdb3) c = <text>
		create_dialog_box {
			heading_text = qs(0xaa163738)
			body_text = <load_text>
			player_device = ($g_gbm_exclusive_device)
			options = [
				{
					func = songlist_options_destroy_dialog
					text = qs(0xf7723015)
				}
				{
					func = songlist_options_load_confirm
					func_params = {index = <index> playlists = <playlists>}
					text = qs(0xad5cfad4)
				}
			]
		}
	else
		songlist_options_load_confirm index = <index> playlists = <playlists>
	endif
endscript

script songlist_options_load_confirm 
	requireparams \{[
			index
		]
		all}
	songlist_options_destroy_dialog \{no_focus}
	songlist_clear
	extendcrc <playlists> '_playlists' out = my_playlists
	songlist_options_check_relevance {
		playlist = ((($<my_playlists>) [<index>]).playlist)
	}
	if (<list_relevant> = false)
		launchevent \{type = unfocus
			target = songlist_options_vmenu}
		songlist_options_vmenu :se_setprops \{block_events}
		getnumplayersingame
		if (<num_players> > 1)
			formattext \{textname = body_text
				qs(0x44218325)}
		else
			formattext \{textname = body_text
				qs(0xfbc789d4)}
		endif
		create_dialog_box {
			heading_text = qs(0xaa163738)
			body_text = <body_text>
			player_device = ($g_gbm_exclusive_device)
			options = [
				{
					func = songlist_options_load_confirm_finish
					func_params = {<...>}
					text = qs(0x0e41fe46)
				}
			]
		}
	else
		songlist_options_load_confirm_finish <...>
	endif
endscript

script songlist_options_check_relevance playlist = ($current_playlist)
	<list_relevant> = true
	getarraysize <playlist>
	if (<array_size> > 0)
		<song_available_list> = []
		<i> = 0
		<available_count> = 0
		begin
		<song> = (<playlist> [<i>])
		<song_allowed> = false
		get_ui_song_struct_items song = <song>
		if NOT gotparam \{song_not_found}
			if song_is_jamsession song = (<ui_struct>.song_checksum)
				gamemode_gettype
				if (<type> = quickplay)
					<song_allowed> = true
				else
					<song_allowed> = false
				endif
			elseif issongavailable song = <song>
				if issongselectable song = <song>
					<song_allowed> = true
				endif
			endif
		else
			removeparameter \{song_not_found}
		endif
		if (<song_allowed> = true)
			addarrayelement array = <song_available_list> element = true
			<song_available_list> = <array>
			<available_count> = (<available_count> + 1)
		else
			<list_relevant> = false
			addarrayelement array = <song_available_list> element = false
			<song_available_list> = <array>
		endif
		<i> = (<i> + 1)
		repeat <array_size>
		if (<list_relevant> = false)
			<override_array> = []
			<i> = 0
			<override_i> = 0
			begin
			if (<song_available_list> [<i>] = true)
				addarrayelement array = <override_array> element = (<playlist> [<i>])
				<override_array> = <array>
				<override_i> = (<override_i> + 1)
			endif
			<i> = (<i> + 1)
			repeat <array_size>
		endif
	endif
	if (<list_relevant> = true)
		return list_relevant = <list_relevant>
	else
		return list_relevant = <list_relevant> override_array = <override_array>
	endif
endscript

script songlist_options_load_confirm_finish 
	songlist_options_destroy_dialog \{no_focus}
	if NOT gotparam \{override_array}
		change current_playlist = ((($<my_playlists>) [<index>]).playlist)
	else
		change current_playlist = <override_array>
	endif
	if screenelementexists \{id = songlist_detail_playlist}
		songlist_detail_playlist :obj_spawnscriptnow \{songlist_calculate_playlist_duration}
	endif
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = play_song)
		songlist_options_select_create
	else
		change \{g_songlist_refresh_menus = 1}
		change \{g_songlist_options_back_requires_unblock = 1}
		songlist_options_back \{no_sound}
	endif
	if (<playlists> = custom)
		change g_current_loaded_custom_playlist_index = <index>
	endif
endscript

script songlist_options_go_to_menu \{type = !q1768515945}
	destroyscreenelement \{id = songlist_options_vmenu
		preserve_parent}
	setscreenelementlock \{id = songlist_options_vmenu
		off}
	setscreenelementlock \{id = songlist_options_vmenu
		on}
	songlist_options_setup_menu type = <type>
	ui_sfx \{menustate = setlist
		uitype = back}
	songlist_options_create_default_user_control_helpers
	launchevent \{type = focus
		target = songlist_options_vmenu}
endscript

script songlist_options_back \{data = {
		}}
	songlist_options :gettags
	if NOT (<show_more_info_on_enter> = ($g_songlist_show_more_info))
		change \{g_songlist_options_dirty = 1}
	endif
	if NOT (<show_ghtunes_on_enter> = ($g_songlist_show_ghtunes))
		change \{g_songlist_options_dirty = 1}
		<data> = {
			<data>
			no_pivot = 1
		}
	endif
	if NOT (<0x5dd074a7> = ($0x42a06e7f))
		change \{g_songlist_options_dirty = 1}
	endif
	if ($g_songlist_options_dirty = 1)
		songlist_options_save_and_go_back data = <data>
	else
		if NOT gotparam \{no_sound}
			ui_sfx \{menustate = setlist
				uitype = back}
		endif
		generic_event_back data = <data>
	endif
endscript

script songlist_options_save_and_go_back \{data = {
		}}
	gamemode_gettype
	if (<type> = freeplay)
		ui_event \{event = menu_back
			data = {
				state = uistate_songlist
			}}
	else
		get_savegame_from_controller controller = ($g_gbm_savegame_device)
		setglobaltags savegame = <savegame> custom_playlists params = {custom_playlists = ($custom_playlists)}
		setglobaltags savegame = <savegame> songlist_options params = {show_more_info = ($g_songlist_show_more_info) show_ghtunes = ($g_songlist_show_ghtunes)}
		songlist_deinit_music_store
		ui_memcard_autosave_replace event = menu_back state = uistate_songlist is_popup data = <data>
	endif
endscript

script songlist_options_show_more_info_toggle 
	if ($g_songlist_show_more_info = 0)
		change \{g_songlist_show_more_info = 1}
		<new_texture> = options_controller_check
		ui_sfx \{menustate = setlist
			uitype = toggleon}
	else
		change \{g_songlist_show_more_info = 0}
		<new_texture> = options_controller_x
		ui_sfx \{menustate = setlist
			uitype = toggleoff}
	endif
	<icon_id> :setprops texture = <new_texture>
	songlist_detail :obj_spawnscriptnow \{songlist_detail_transition
		params = {
			desc = songlist_detail
			force_transition
		}}
endscript

script songlist_options_show_ghtunes_toggle 
	if ($g_songlist_show_ghtunes = 0)
		change \{g_songlist_show_ghtunes = 1}
		<new_texture> = options_controller_check
		ui_sfx \{menustate = setlist
			uitype = toggleon}
		songlist_clear_filterspec
	else
		change \{g_songlist_show_ghtunes = 0}
		<new_texture> = options_controller_x
		ui_sfx \{menustate = setlist
			uitype = toggleoff}
		filterspec = [
			{
				key = song_source
				union_list = [jam]
				comparator = not_equal
			}
		]
		songlist_change_filterspec filterspec = <filterspec>
	endif
	<icon_id> :setprops texture = <new_texture>
	change \{g_songlist_refresh_menus = 1}
	change \{g_songlist_options_back_requires_unblock = 1}
endscript

script 0xf69734ba 
	if ($0x42a06e7f = 0)
		change \{0x42a06e7f = 1}
		<new_texture> = options_controller_check
		ui_sfx \{menustate = setlist
			uitype = toggleon}
		songlist_clear_filterspec
	else
		change \{0x42a06e7f = 0}
		<new_texture> = options_controller_x
		ui_sfx \{menustate = setlist
			uitype = toggleoff}
		filterspec = [
			{
				key = song_source
				union_list = [notetracker]
				comparator = not_equal
			}
		]
		songlist_change_filterspec filterspec = <filterspec>
	endif
	<icon_id> :setprops texture = <new_texture>
	change \{g_songlist_refresh_menus = 1}
	change \{g_songlist_options_back_requires_unblock = 1}
endscript

script allow_show_ghtunes_toggle 
	gamemode_gettype
	if (<type> = quickplay)
		return \{true}
	else
		return \{false}
	endif
endscript

script 0x5e7cb996 
	gamemode_gettype
	if (<type> = quickplay)
		return \{true}
	else
		return \{false}
	endif
endscript

script songlist_main_options_play_song \{song_item_id = !q1768515945}
	songlist_options_back data = {bypass_return_script = songlist_item_add_to_playlist bypass_return_params = {id = <song_item_id>}}
endscript

script songlist_main_options_add_to_playlist \{song_item_id = !q1768515945}
	songlist_component :membfunc_songlist_uistack_getmode
	if (<mode> = playlist)
		onexitrun songlist_item_add_to_playlist params = {id = <song_item_id>}
		songlist_options_back \{no_sound}
	elseif (<mode> = play_song)
		onexitrun songlist_item_add_to_playlist params = {id = <song_item_id>}
		songlist_component :membfunc_songlist_uistack_getrangestruct
		if issongselectable song = (<range_struct>.song_checksum)
			songlist_options_select_create
		else
			songlist_options_back \{no_sound}
		endif
	endif
endscript

script songlist_main_options_remove_from_playlist \{song_item_id = !q1768515945}
	if is_a_playlist_loaded
		if (<size> = 1)
			songlist_create_play_song \{no_focus = 1
				no_refresh = 1
				no_detail_transition = 1}
		endif
	endif
	songlist_options_back data = {additional_return_script = songlist_item_remove_from_playlist additional_return_params = {id = <song_item_id>}}
endscript

script allow_view_awards_option \{song_item_id = !q1768515945}
	<song_item_id> :getsingletag song_checksum
	get_ui_song_struct_items song = <song_checksum>
	if song_is_jamsession song = (<ui_struct>.song_checksum)
		return \{false}
	endif
	return \{true}
endscript

script songlist_main_options_view_awards \{song_item_id = !q1768515945}
	ui_sfx \{menustate = generic
		uitype = select}
	<song_item_id> :getsingletag song_checksum
	gamemode_gettype
	if (<type> = freeplay)
		generic_event_choose state = uistate_award_case data = {is_popup song = <song_checksum> device_num = <device_num> no_targeting = 1}
	else
		generic_event_choose state = uistate_award_case data = {is_popup song = <song_checksum> device_num = <device_num>}
	endif
endscript

script songlist_song_options_smart_playlist \{song_item_id = !q1768515945}
	printf \{qs(0xdb3d37d4)}
endscript

script songlist_main_options_download_similar \{song_item_id = !q1768515945}
	printf \{qs(0xe8752168)}
endscript

script songlist_main_options_random_songs 
	destroyscreenelement \{id = songlist_options_vmenu
		preserve_parent}
	setscreenelementlock \{id = songlist_options_vmenu
		off}
	setscreenelementlock \{id = songlist_options_vmenu
		on}
	ui_sfx \{menustate = setlist
		uitype = select}
	<num_random_songs_array> = [1 3 5 10]
	getarraysize <num_random_songs_array>
	if (<array_size> > 0)
		songlist_options :se_setprops \{songlist_options_text_text = qs(0x0c9cc77e)}
		event_handlers = [
			{pad_back songlist_options_go_to_menu params = {type = main}}
		]
		songlist_options_vmenu :se_setprops {
			event_handlers = <event_handlers>
			replace_handlers
		}
		songlist_options_vmenu :se_setprops \{unblock_events}
		launchevent \{type = focus
			target = songlist_options_vmenu}
		<i> = 0
		begin
		formattext textname = random_text qs(0xfd68af01) i = (<num_random_songs_array> [<i>])
		songlist_options_add_item {
			text = <random_text>
			text_focus_color = ($g_songlist_options_item_focus_rgba)
			text_unfocus_color = ($g_songlist_options_item_unfocus_rgba)
			pad_choose_script = songlist_main_options_random_processing
			pad_choose_params = {num_songs = (<num_random_songs_array> [<i>])}
		}
		<i> = (<i> + 1)
		repeat <array_size>
	endif
	songlist_options_add_item {
		text = qs(0x5bd73447)
		text_focus_color = ($g_songlist_options_item_focus_rgba)
		text_unfocus_color = ($g_songlist_options_item_invalid_rgba)
		pad_choose_script = songlist_main_options_random_processing
		pad_choose_params = {num_songs = -1}
		not_focusable
	}
	generic_scrollbar_wgt_set_resolution id = songlist_options_scrollbar_wgt num_elements = (<array_size> + 1)
endscript

script songlist_main_options_random_processing \{num_songs = !i1768515945}
	if NOT (<num_songs> = -1)
		if NOT is_current_playlist_empty
			launchevent \{type = unfocus
				target = songlist_options_vmenu}
			songlist_options_vmenu :se_setprops \{block_events}
			create_dialog_box {
				heading_text = qs(0xcf5deb58)
				body_text = qs(0x3fb79e11)
				player_device = ($g_gbm_exclusive_device)
				options = [
					{
						func = songlist_main_options_generate_random_playlist
						func_params = {num_songs = <num_songs>}
						text = qs(0x0e41fe46)
					}
				]
			}
			fill_auto_save_playlist
			songlist_clear_playlist
		else
			songlist_main_options_generate_random_playlist num_songs = <num_songs>
		endif
	else
	endif
endscript

script songlist_main_options_generate_random_playlist \{num_songs = !i1768515945}
	songlist_options_destroy_dialog
	<random_playlist> = []
	songlist_component :membfunc_songlist_uistack_setupapplicablerandomindeces
	<i> = 0
	begin
	if songlist_component :membfunc_songlist_uistack_getrandomsongstruct
		if song_is_jamsession song = (<random_song_struct>.song_checksum)
			formattext textname = text '%a' a = (<random_song_struct>.filename)
			formattext checksumname = song_checksum '%i' i = <text>
		else
			song_checksum = (<random_song_struct>.song_checksum)
		endif
		addarrayelement array = <random_playlist> element = <song_checksum>
		<random_playlist> = <array>
	else
		printf \{qs(0x30fc5905)}
	endif
	repeat <num_songs>
	change current_playlist = <random_playlist>
	songlist_options_back data = {bypass_return_script = songlist_continue bypass_return_params = {device_num = <device_num> autosave_playlist = 0}}
endscript

script songlist_main_options_go_to_playlist_options 
	songlist_options_go_to_menu \{type = playlist}
endscript

script songlist_main_options_go_to_display_options 
	songlist_options_go_to_menu \{type = display}
endscript

script songlist_options_keep_focus \{id = !q1768515945}
	<item_focus_rgba> = ($g_songlist_item_focus_rgba)
	<sub_item_focus_rgba> = ($g_songlist_sub_item_focus_rgba)
	<id> :se_setprops {
		songlist_item_text_rgba = <item_focus_rgba>
		songlist_item_sub_text_rgba = <sub_item_focus_rgba>
		songlist_item_highlight_bar_alpha = 0.3
	}
endscript

script songlist_options_music_store_request_page_when_ready \{filterspec = !a1768515945}
	songlist_component :membfunc_songlist_uistack_getlistname
	begin
	if contentmanfunc func = is_ready name = <list_name>
		contentmanfunc {
			func = request_page
			current_page
			name = <list_name>
			filterspec = <filterspec>
			callback = songlist_options_music_store_pack_callback_request_page
		}
		change \{g_songlist_refresh_menus = 1}
		change \{g_songlist_options_back_requires_unblock = 1}
		return
	endif
	wait \{3
		gameframes}
	repeat 1000
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

script songlist_options_music_store_pack_callback_request_page 
	if (<content_size> > 0)
		songlist_component :membfunc_songlist_uistack_getlistname
		begin
		if contentmanfunc func = is_ready name = <list_name>
			contentmanfunc {
				func = request_data
				name = <list_name>
				start_index = 0
				end_index = (<content_size> - 1)
				callback = songlist_options_music_store_pack_callback_request_data
			}
			return
		endif
		wait \{3
			gameframes}
		repeat 1000
		create_dialog_box \{no_background
			heading_text = qs(0xaa163738)
			body_text = qs(0xa47088ec)
			options = [
				{
					func = songlist_marketplace_timed_out_go_back
					text = qs(0x0e41fe46)
				}
			]}
	else
		change \{songlist_options_ready_to_proceed = 1}
	endif
endscript

script songlist_options_music_store_pack_callback_request_data 
	<pack_index> = -1
	<album_index> = -1
	getarraysize <range>
	if (<array_size> > 0)
		<i> = 0
		begin
		if ((<range> [<i>]).type = pack)
			if (<pack_index> = -1)
				<pack_index> = <i>
			endif
		elseif ((<range> [<i>]).type = album)
			if (<album_index> = -1)
				<album_index> = <i>
			endif
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	endif
	if (<pack_index> >= 0)
		<pack_struct> = (<range> [<pack_index>])
		songlist_options :getsingletag \{purchase_checksum}
		<element> = {
			text = qs(0xce5d2e92)
			pad_choose_script = songlist_options_music_store_new_view_go_back
			pad_choose_params = {pack_struct = <pack_struct> purchase_checksum = <purchase_checksum>}
		}
		addarrayelement array = ($music_store_songlist_options) element = <element>
		change music_store_songlist_options = <array>
	endif
	if (<album_index> >= 0)
		<album_struct> = (<range> [<album_index>])
		songlist_options :getsingletag \{purchase_checksum}
		<element> = {
			text = qs(0x55c682ba)
			pad_choose_script = songlist_options_music_store_new_view_go_back
			pad_choose_params = {pack_struct = <album_struct> purchase_checksum = <purchase_checksum>}
		}
		addarrayelement array = ($music_store_songlist_options) element = <element>
		change music_store_songlist_options = <array>
	endif
	change \{songlist_options_ready_to_proceed = 1}
endscript

script songlist_options_music_store_purchase_accepted \{purchase_struct = 0x69696969}
	music_store_purchase_content purchase_struct = <purchase_struct>
	if isxenon
		if ($shutdown_game_for_signin_change_flag = 0)
			ui_event event = menu_replace data = {is_popup state = uistate_music_store_scan_marketplace data = {purchase_struct = <purchase_struct>}}
		endif
	else
		songlist_options_music_store_go_to_terms purchase_struct = <purchase_struct>
	endif
endscript

script songlist_options_music_store_go_to_terms \{purchase_struct = 0x69696969}
	current_menu :se_setprops \{alpha = 0.0}
	songlist :se_setprops \{songlist_sticky_header_alpha = 0.0
		songlist_subheader_cont_alpha = 0.0
		songlist_sort_cont_alpha = 0.0}
	songlist_component :getsingletag \{exclusive_device}
	songlist_scrollbar_wgt :se_getprops \{scroll_thumb_pos}
	ui_event_wait event = menu_change data = {
		no_sound
		state = uistate_music_store_terms
		is_popup
		exclusive_device = <exclusive_device>
		purchase_struct = <purchase_struct>
		slider_pos = <scroll_thumb_pos>
	}
endscript

script songlist_options_music_store_preview_song \{song_preview_asset_name = 0x69696969}
	music_store_request_preview_music music_name = <song_preview_asset_name>
endscript

script songlist_options_music_store_new_view_go_back \{pack_struct = 0x69696969}
	ui_sfx \{menustate = musicstore
		uitype = back}
	destroy_dialog_box
	songlist_component :settags \{music_store_seek_override = true}
	songlist_options_back data = {
		no_pivot = 1
		bypass_return_script = songlist_music_store_view_pack_songs
		bypass_return_params = {
			ui_struct = <pack_struct>
			purchase_checksum = <purchase_checksum>
		}
	}
endscript
