
script 0x747af45f 
endscript

script 0x17deface 
endscript

script 0x0213aa33 
	createscreenelement \{type = containerelement
		parent = root_window
		id = jam_song_select_container}
	make_generic_menu \{title = qs(0x43a4b9a6)
		pad_back_script = menu_jam_song_select_back
		vmenu_id = create_my_song_menu
		dims = (400.0, 600.0)
		tags = {
			debug_me
		}
		scrolling}
	startwildcardsearch \{wildcard = 'notetracker\\*.mp3'}
	index = 0
	begin
	if NOT getwildcardfile
		break
	endif
	setplayerinfo \{1
		jam_instrument = 0}
	add_generic_menu_icon_item {
		text = <filename>
		choose_state = uistate_musicstudio_notetracker
		choose_state_data = {back_to_jam_band = 0 current_instrument = 0 player = ($jam_current_recording_player) filename = <filename_nl>}
		additional_focus_script = menu_jam_create_song_focus
		additional_unfocus_script = menu_jam_create_song_unfocus
	}
	<index> = (<index> + 1)
	repeat
	endwildcardsearch
	change \{0x8dbcd060 = 1}
	if NOT scriptisrunning \{0x6e556f71}
		spawnscript \{0x6e556f71}
	endif
	change \{jam_current_recording_player = 1}
endscript

script 0x65f0726b 
	change \{0x8dbcd060 = 0}
	if screenelementexists \{id = jam_song_select_container}
		destroyscreenelement \{id = jam_song_select_container}
	endif
	destroy_generic_menu
	destroy_jam_song_select_popup
endscript
0x8dbcd060 = 0

script 0x6e556f71 
	add_generic_menu_text_item \{text = qs(0x695bf56c)
		additional_focus_script = menu_jam_create_song_focus
		additional_unfocus_script = menu_jam_create_song_unfocus}
	printf \{qs(0x2c7f49b5)}
	netsessionfunc \{func = cdn_init}
	wait \{1
		second}
	printf \{qs(0x07521a76)}
	authoringinit
	wait \{1
		second}
	0x4aa9658e
	first = 0
	begin
	0xcfd43754
	if (<failed> = 1)
		destroyscreenelement id = <item_container_id>
		if ($0x8dbcd060 = 1)
			add_generic_menu_text_item \{text = qs(0x359da6a5)
				additional_focus_script = menu_jam_create_song_focus
				additional_unfocus_script = menu_jam_create_song_unfocus}
		endif
		return
	endif
	if (<finished> = 1)
		return
	endif
	if ($0x8dbcd060 = 1 && <ready> = 1)
		if (<first> = 0)
			destroyscreenelement id = <item_container_id>
			add_generic_menu_text_item \{text = qs(0x23d3ba92)
				heading}
			first = 1
		endif
		filename_nl = <filename>
		0xff58e205 string = <filename>
		add_generic_menu_icon_item {
			text = <utf16string>
			choose_state = uistate_musicstudio_notetracker
			choose_state_data = {back_to_jam_band = 0 current_instrument = 0 player = ($jam_current_recording_player) filename = <filename_nl> usecdn = 1}
			additional_focus_script = menu_jam_create_song_focus
			additional_unfocus_script = menu_jam_create_song_unfocus
		}
	else
		wait \{1
			gameframe}
	endif
	repeat
	printf \{qs(0x57adc52f)}
endscript
