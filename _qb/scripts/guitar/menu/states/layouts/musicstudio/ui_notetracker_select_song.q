
script 0xcb082cee 
endscript

script 0xa8ac227f 
endscript

script 0xbd617282 \{show_popup = 0}
	createscreenelement \{type = containerelement
		parent = root_window
		id = jam_song_select_container}
	make_generic_menu \{title = qs(0xa38d930d)
		pad_back_script = menu_jam_song_select_back
		vmenu_id = create_my_song_menu
		dims = (400.0, 600.0)
		tags = {
			debug_me
		}
		scrolling
		no_up_down_sound_handlers
		pad_back_sound = nullscript
		pad_back_params = {
			nosound
		}}
	change \{jam_current_recording_player = 1}
	setplayerinfo \{1
		jam_instrument = 0}
	add_generic_menu_icon_item \{text = qs(0x1bca1511)
		choose_state = 0x95831ed7
		additional_focus_script = menu_jam_create_song_focus
		additional_unfocus_script = menu_jam_create_song_unfocus}
	directorylisting = $jam_curr_directory_listing
	getarraysize <directorylisting>
	has_download_songs = 0
	first_local_song = 0
	if (<array_size> > 0)
		if globalexists \{name = jam_download_songs
				type = array}
			printf \{channel = jam_mode
				qs(0xa047b8ba)}
			destroyscriptarray \{name = jam_download_songs}
		endif
		createscriptarray name = jam_download_songs size = <array_size> heap = heap_song
		index = 0
		begin
		show_local_song = 1
		if structurecontains structure = (<directorylisting> [<index>]) downloaded
			if ((<directorylisting> [<index>].downloaded) = 1)
				<show_local_song> = 0
				<has_download_songs> = 1
				setarrayelement arrayname = jam_download_songs globalarray index = <index> newvalue = 1
			endif
		endif
		if (<show_local_song> = 1)
			if (<first_local_song> = 0)
				add_generic_menu_text_item \{text = qs(0x322ff13f)
					heading}
				<first_local_song> = 1
			endif
			setarrayelement arrayname = jam_download_songs globalarray index = <index> newvalue = 0
			add_generic_menu_text_item {
				text = (<directorylisting> [<index>].filename)
				pad_choose_script = 0x2dd0fde3
				pad_choose_params = {index = <index> filename = (<directorylisting> [<index>].filename) advanced_record = <advanced_record>}
				pad_start_script = delete_jam_song_confirm
				pad_start_params = {filename = (<directorylisting> [<index>].filename) advanced_record = <advanced_record>}
			}
		endif
		<index> = (<index> + 1)
		repeat <array_size>
	endif
	startwildcardsearch \{wildcard = 'notetracker\\*.jam'}
	index = 0
	first_local_song = 0
	begin
	if NOT getwildcardfile
		break
	endif
	0x0efe6ecd = [
		'_rhythm.jam'
		'_lead.jam'
		'_bass.jam'
		'_drums.jam'
		'_keyboard.jam'
		'_vocals.jam']
	getarraysize <0x0efe6ecd>
	file = 0
	0x8eda0113 = 1
	begin
	if stringcontains text = <filename_nl> substring = (<0x0efe6ecd> [<file>])
		0x8eda0113 = 0
	endif
	file = (<file> + 1)
	repeat <array_size>
	if (<0x8eda0113> = 1)
		if (<first_local_song> = 0)
			add_generic_menu_text_item \{text = qs(0xe1e3d46e)
				heading}
			<first_local_song> = 1
		endif
		add_generic_menu_icon_item {
			text = <filename>
			pad_choose_script = 0x2dd0fde3
			pad_choose_params = {index = <index> filename = <filename> filename_nl = <filename_nl> advanced_record = <advanced_record> 0x06f6140c = 1}
			additional_focus_script = menu_jam_create_song_focus
			additional_unfocus_script = menu_jam_create_song_unfocus
		}
		<index> = (<index> + 1)
	endif
	repeat
	endwildcardsearch
	if (<show_popup> = 1)
		0x88ec947e \{advanced_record = 0
			example_song = 0}
	endif
endscript

script 0x2dd0fde3 \{0x06f6140c = 0}
	printf \{channel = jam_mode
		qs(0x84934677)}
	clearcustomsong
	jam_recording_create_editable_arrays
	directorylisting = ($jam_curr_directory_listing)
	<year> = 2008
	change_jamsession_songlist_props_struct year = <year>
	if (<0x06f6140c> = 0)
		change memcard_jamsession_file_name = <filename>
		change jam_selected_song = <filename>
		ui_memcard_load_jam event = menu_back data = {show_popup = 1 example_song = <example_song>}
	else
		stringremove text = <filename_nl> remove = 'notetracker/' new_string = 0xb4bc59b9
		0xff58e205 string = <0xb4bc59b9>
		change memcard_jamsession_file_name = <utf16string>
		change jam_selected_song = <utf16string>
		0xaa919f3d jamname = <filename_nl>
		ui_sfx \{menustate = generic
			uitype = select}
		generic_event_choose \{state = 0x2af1c666
			data = {
				show_popup = 1
			}}
	endif
	jam_publish_update_playback_track \{guitar_num = 1}
	jam_publish_update_playback_track \{guitar_num = 2}
	jam_publish_update_playback_drumvocal_track
endscript

script 0xda82aada 
	if screenelementexists \{id = jam_song_select_container}
		destroyscreenelement \{id = jam_song_select_container}
	endif
	destroy_generic_menu
	destroy_jam_song_select_popup
endscript

script 0x88ec947e \{advanced_record = 0
		example_song = 0}
	stoprendering
	if screenelementexists \{id = current_menu}
		current_menu :se_setprops \{block_events}
	endif
	getsonginfo
	change jam_current_bpm = <bpm>
	change jam_current_tuning = <tuning>
	if NOT (<downloaded> = 1 || <example_song> = 1)
		destroy_dialog_box
		create_dialog_box {
			heading_text = qs(0xbc9429b6)
			body_text = qs(0x00000000)
			player_device = <player_device>
			options = [
				{
					func = 0xe2fdf2d5
					func_params = {advanced_record = <advanced_record>}
					text = qs(0x56fbf662)
				}
				{
					func = 0x583eb3e7
					func_params = {advanced_record = <advanced_record>}
					text = qs(0x42474b0a)
				}
				{
					func = 0xc0a1b9a7
					func_params = {filename = ($jam_selected_song)}
					text = qs(0x44f29f0d)
				}
			]
			back_button_script = jam_song_options_select_back
			back_button_params = {advanced_record = <advanced_record>}
		}
	else
		destroy_dialog_box
		create_dialog_box {
			heading_text = qs(0xbc9429b6)
			body_text = qs(0x00000000)
			player_device = <player_device>
			options = [
				{
					func = 0xe2fdf2d5
					func_params = {<...>}
					text = qs(0x56fbf662)
				}
			]
			back_button_script = jam_song_options_select_back
			back_button_params = {advanced_record = <advanced_record>}
		}
	endif
	if screenelementexists \{id = dialog_box_vmenu}
		dialog_box_vmenu :se_setprops \{block_events}
	endif
	musicstudio_init_volumes
	musicstudio_init_pan
	change \{jam_current_instrument_effects = [
			0
			0
			0
			0
			0
		]}
	change \{jam_current_active_effects = [
			0
			0
			0
			0
			0
		]}
	jam_load_scale
	jam_load_effect
	player_device = ($primary_controller)
	cas_band_logo_update \{album_art}
	pushassetcontext context = ($cas_band_logo_details.assetcontext)
	createscreenelement {
		type = spriteelement
		parent = dialog_box_container
		texture = ($cas_band_logo_details.textureasset)
		just = [left center]
		rgba = [255 255 255 250]
		pos = (350.0, 305.0)
		dims = (170.0, 170.0)
		z_priority = 1000
	}
	popassetcontext
	0x83318abb parent = dialog_box_container pos = (540.0, 288.0) rgba = [180 180 180 250] filename = ($jam_selected_song)
	if screenelementexists \{id = dialog_box_vmenu}
		dialog_box_vmenu :se_setprops \{unblock_events}
		dialog_box_vmenu :menu_changeselection
		dialog_box_vmenu :menu_changeselection \{up}
	endif
	startrendering
	clean_up_user_control_helpers
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green
		z = 10000}
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red
		z = 10000}
endscript

script 0x83318abb \{column_offset = (220.0, 0.0)
		z_priority = 1000
		rgba = [
			210
			130
			0
			250
		]
		num_ratings = 0}
	note_count_text = [qs(0x00000000) qs(0x00000000) qs(0x00000000) qs(0x00000000) qs(0x00000000) qs(0x00000000)]
	tracks_recorded_text = qs(0x00000000)
	track_count = 0
	last_end_time = 0
	all_tracks = 1
	begin
	gettracksize track = ($jam_tracks [<track_count>].id)
	if (<track_size> > 0)
		getcustomnote track = ($jam_tracks [<track_count>].id) index = (<track_size> - 1)
		if (<note_time> > <last_end_time>)
			<last_end_time> = <note_time>
		endif
		formattext textname = note_count qs(0xd7ee902f) a = ($jam_tracks [<track_count>].name_text) b = <track_size> s = qs(0x42c9738e)
		formattext textname = tracks_recorded_text qs(0xdc07585f) s = <tracks_recorded_text> a = ($jam_tracks [<track_count>].name_text)
		setarrayelement arrayname = note_count_text index = <track_count> newvalue = <note_count>
	else
		formattext textname = note_count qs(0x5e97b9d2) a = ($jam_tracks [<track_count>].name_text) s = qs(0x71d71562)
		setarrayelement arrayname = note_count_text index = <track_count> newvalue = <note_count>
		all_tracks = 0
	endif
	<track_count> = (<track_count> + 1)
	repeat 6
	if (<tracks_recorded_text> = qs(0x00000000))
		formattext \{textname = tracks_recorded_text
			qs(0xf36d10c8)}
	endif
	if (<all_tracks> = 1)
		formattext \{textname = tracks_recorded_text
			qs(0x711df7be)}
	endif
	mod a = <last_end_time> b = 60000
	<seconds> = (<mod> / 1000)
	<minutes> = (<last_end_time> / 60000)
	<sec_check> = (<seconds> / 10)
	if (<sec_check> < 1)
		formattext textname = length_text qs(0x6b8769fa) a = <minutes> b = <seconds>
	else
		formattext textname = length_text qs(0x830308cc) a = <minutes> b = <seconds>
	endif
	gettrackinfo \{track = rhythm}
	formattext textname = bpm_text qs(0x21072c11) a = <bpm>
	getsonginfo
	getarraysize \{$jam_genre_list}
	if (<genre> < 0 || <genre> >= <array_size>)
		formattext textname = genre_text qs(0xd0ef7f05) a = <genre>
	else
		formattext textname = genre_text qs(0x4d3a8435) a = ($jam_genre_list [<genre>].name_text)
	endif
	if (<artist> = qs(0x00000000))
		<artist> = qs(0x2dc91c7c)
	endif
	if screenelementexists \{id = song_preview_element}
		platform_prefix = qs(0x03ac90f0)
		if isxenon
			<platform_prefix> = qs(0x035582ab)
		elseif isps3
			<platform_prefix> = qs(0xcb8c08a3)
		else
			<platform_prefix> = qs(0x84cd9e64)
		endif
		if ((<file_id>.file_id [0]) = 0)
			formattext textname = file_id_text qs(0xd6df1a7a) a = (<file_id>.file_id [1]) p = <platform_prefix>
		else
			formattext textname = file_id_text qs(0xb05112d6) a = (<file_id>.file_id [1]) b = (<file_id>.file_id [0]) p = <platform_prefix>
		endif
		if ((<file_id>.file_id [0]) = 0 && (<file_id>.file_id [1]) = 0)
			file_id_text = qs(0x03ac90f0)
		endif
		if NOT (<num_ratings> = 0)
			formattext textname = ratings_text qs(0x90047b5d) a = <num_ratings>
		else
			ratings_text = qs(0x03ac90f0)
		endif
		song_preview_element :se_setprops {
			song_name_text = <filename>
			artist_name_text = <artist>
			note_count01_text = (<note_count_text> [0])
			note_count02_text = (<note_count_text> [1])
			note_count03_text = (<note_count_text> [2])
			note_count04_text = (<note_count_text> [3])
			note_count05_text = (<note_count_text> [4])
			length_text = <length_text>
			bpm_text = <bpm_text>
			genre_text = <genre_text>
			file_id_text = <file_id_text>
			num_ratings_text = <ratings_text>
		}
	else
		if (<genre> < 0 || <genre> >= <array_size>)
			formattext textname = length_text qs(0xe3cd7faf) s = <length_text> b = qs(0xd0ef7f05)
		else
			formattext textname = length_text qs(0xe3cd7faf) s = <length_text> b = ($jam_genre_list [<genre>].name_text)
		endif
		createscreenelement {
			parent = <parent>
			type = descinterface
			desc = 'jam_song_info_text'
			pos = (190.0, 115.0)
			scale = 0.75
			song_name_text = <filename>
			artist_name_text = <artist>
			tracks_recorded_text = <tracks_recorded_text>
			song_length_text = <length_text>
			bpm_text = <bpm_text>
			genre_text = <genre_text>
			z_priority = 1000
		}
	endif
	return song_length = <last_end_time>
endscript

script 0xe2fdf2d5 
	if screenelementexists \{id = current_menu}
		launchevent \{type = unfocus
			target = current_menu}
	endif
	jam_recording_create_jamsession_arrays
	song_prefix = 'editable'
	formattext checksumname = arraylist '%s_arraylist' s = <song_prefix> addtostringlookup = true
	song_prefix = 'jamsession'
	formattext checksumname = arraylist2 '%s_arraylist' s = <song_prefix> addtostringlookup = true
	jamsession_copymarkerarrays \{song = editable}
	jamsession_copyfinalscriptarrays arraylist = <arraylist> arraylist2 = <arraylist2>
	create_jam_play_select_menu <...> advanced_record = <advanced_record>
endscript

script 0x583eb3e7 
	ui_sfx \{menustate = generic
		uitype = select}
	generic_event_choose state = uistate_musicstudio_notetracker data = {back_to_jam_band = 0 editing = 1 current_instrument = 0 player = ($jam_current_recording_player) filename = ''}
endscript

script 0xc0a1b9a7 
endscript
