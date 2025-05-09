notetracker_quickplay_active = 0

script 0x4ccdabaf 
	change \{notetracker_quickplay_active = 1}
	($default_loading_screen.create)
	change \{game_mode = quickplay}
	setplayerinfo \{1
		part = guitar}
	setplayerinfo \{1
		in_game = 1}
	getsonginfo
	stringremove text = <streamfile> remove = 'notetracker/' new_string = 0xb4bc59b9
	0xff58e205 string = <0xb4bc59b9>
	change memcard_jamsession_file_name = <utf16string>
	change jam_selected_song = <utf16string>
	killspawnedscript \{name = async_decompress}
	end_mp3_song
	ui_event_wait \{event = menu_replace
		data = {
			state = uistate_gameplay
		}}
endscript

script 0x1eb6f6da 
	wait \{60
		frames}
	jam_song_back_to_gameplay
endscript

script 0x1587bcfb 
endscript

script notetracker_quickplay_quit 
	spawnscriptnow \{0x492a69d2}
endscript

script 0x492a69d2 
	kill_gem_scroller
	wait \{4
		frame}
	disable_pause
	setup_bg_viewport
	change \{jam_current_recording_player = 1}
	setplayerinfo \{1
		jam_instrument = 0}
	process_sound_times \{negate}
	getsonginfo
	ui_event_block \{event = menu_back}
	ui_sfx \{menustate = generic
		uitype = select}
	generic_event_replace {
		state = uistate_musicstudio_notetracker
		data = {
			back_to_jam_band = 0
			editing = 1
			current_instrument = 0
			player = ($jam_current_recording_player)
			filename = <streamfile>
		}
	}
	unpausegame
	change \{notetracker_quickplay_active = 0}
endscript
