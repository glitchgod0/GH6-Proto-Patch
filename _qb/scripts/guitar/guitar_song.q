song_is_waiting_to_start = 0

script songaudioplay 
	if NOT ($current_song_qpak = jamsession)
		sap_play
	else
		if notetracker_is_using_stream
			begin_mp3_song
		endif
	endif
	if ($0x9260476c = 1)
		spawnscript \{0x981544bd}
	endif
	0xb3af2e63
	change \{song_is_waiting_to_start = 0}
endscript

script songaudiostop \{song_failed_pitch_streams = 0}
	if NOT (<song_failed_pitch_streams> = 1)
		killspawnedscript \{name = failed_song_pitch_down}
		if ($waiting_for_pitching = 1)
			change \{waiting_for_pitching = 0}
		endif
		sap_stop
		sap_unload \{nowait}
		end_mp3_song
	else
		printf \{channel = sfx
			qs(0xc2b5a42d)}
		spawnscriptnow \{failed_song_pitch_down}
	endif
	change \{song_is_waiting_to_start = 0}
endscript
waiting_for_pitching = 0

script failed_song_pitch_down 
	sap_setpitch \{pitch = -8
		time = 3}
	sap_setmastervolume \{vol = -20
		time = 3}
	change \{waiting_for_pitching = 1}
	wait \{3
		seconds}
	spawnscriptnow \{songaudiostop}
endscript

script songaudioseek \{position = 0
		callback = none}
	sap_seek time = <position> callback = <callback>
endscript

script songaudiosetwhammy 
	sap_setplayerwhammy player = <player> whammy_value = (1 - (<control> * 0.057))
endscript

script pauseaudio 
	pausesoundsbybuss \{master}
	sap_pause
	muteeffectsend slot = ($venue_sendeffect_slot)
	vocaldspsetparams \{mute_all}
	if ($drum_solo_songtime_paused = 1)
		return
	endif
	if NOT gotparam \{no_seek}
		getsongtimems
		casttointeger \{time}
		if (<time> > $current_starttime)
			if NOT gotparam \{seek_on_unpause}
				if sap_seek time = <time> nowait callback = songaudio_seekdone
					change \{songaudio_waitingforseek = 1}
				else
					change \{songaudio_waitingforseek = 0}
				endif
			endif
		endif
	endif
endscript
songaudio_waitingforseek = 0

script songaudio_seekdone 
	change \{songaudio_waitingforseek = 0}
endscript

script waitforaudioseek 
	begin
	if ($songaudio_waitingforseek = 0)
		break
	endif
	wait \{1
		gameframe}
	repeat
endscript

script unpauseaudio 
	if ($drum_solo_songtime_paused = 1)
		return
	endif
	can_unpause = 1
	if ($song_is_waiting_to_start = 1)
		can_unpause = 0
	endif
	gamemode_gettype
	if (<type> = practice)
		getsongtimems
		casttointeger \{time}
		if (<time> < $practice_start_time || <time> > $practice_end_time)
			removeparameter \{seek_on_unpause}
			can_unpause = 0
		endif
	endif
	unmuteeffectsend slot = ($venue_sendeffect_slot)
	vocaldspsetparams \{unmute_all}
	if gotparam \{seek_on_unpause}
		getsongtimems
		casttointeger \{time}
		if (<time> >= $current_starttime)
			sap_seek time = <time> nowait
		endif
	endif
	waitforaudioseek
	if (<can_unpause> = 1)
		sap_unpause
	endif
	getsongtimems
	casttointeger \{time}
	if (<time> >= 0)
		setsoundseekposition mp3stream position = <time>
		setsoundseekposition fsbstream position = <time>
	endif
	unpausesoundsbybuss \{master}
endscript

script songaudioinit \{callback = none}
	mode = $game_mode
	speed = ($current_speedfactor)
	sap_init <...> callback = <callback> nowait
endscript

script songaudiodeinit \{callback = none}
	sap_unload \{nowait}
	sap_deinit nowait callback = <callback>
	setsoundbussparams {crowd_one_shots = {vol = (($default_bussset.crowd_one_shots.vol))} time = 0.02}
endscript

script getsongaudioinfo 
	requireparams \{[
			song_name
		]
		all}
	get_song_prefix song = <song_name>
	get_song_struct song = <song_name>
	stream_name = <song_prefix>
	if structurecontains structure = <song_struct> streamname
		stream_name = (<song_struct>.streamname)
	endif
	return song_stream_name = <stream_name> song_volume = (<song_struct>.overall_song_volume)
endscript

script songaudioload \{starttime = 0
		callback = none}
	setscriptcannotpause
	getsongaudioinfo song_name = <song_name>
	get_song_encryption_type song_name = <song_name>
	change \{song_is_waiting_to_start = 1}
	sap_load filename = <song_stream_name> vol = <song_volume> encryption_type = <encryption_type>
	if (<song_command_success> = 0)
		if NOT cd
			scriptassert 'Failed to load song: %s' s = <song_name>
		endif
		begin
		if ($start_gem_scroller_running = 0)
			break
		endif
		wait \{1
			gameframe}
		repeat
		destroy_loading_screen
		downloadcontentlost
		return \{false}
	endif
	if (<starttime> > 0)
		sap_seek time = <starttime>
	endif
	return \{true}
endscript

script songaudiosetupdsp 
	playlist_getcurrentsong
	song_name = <current_song>
	get_song_prefix song = <song_name>
	get_song_struct song = <song_name>
	getnumplayersingame
	getnumplayersingame \{on_screen}
	if (<num_players_shown> < <num_players>)
		<num_players> = <num_players_shown>
	endif
	mono_drums = 0
	if structurecontains structure = <song_struct> mono_drums
		mono_drums = (<song_struct>.mono_drums)
	endif
	if structurecontains structure = <song_struct> fake_bass_mode
		fake_bass_mode = (<song_struct>.fake_bass_mode)
	endif
	sap_setupplayerdsp <...>
	sap_settracksurroundpan track = crowd pan1x = ($g_crowd_singalong_pan1x) pan1y = ($g_crowd_singalong_pan1y) pan2x = ($g_crowd_singalong_pan2x) pan2y = ($g_crowd_singalong_pan2y)
	playlist_getcurrentsong
	song = <current_song>
	gamemode_gettype
	if NOT ($game_mode = practice)
		if NOT (<song> = jamsession)
			audio_effects_reset_to_current_snapshot
		else
			setsoundbussparams {crowd = {vol = (($game_bussset.crowd.vol))} time = 0.02}
		endif
		setsoundbussparams {crowd_one_shots = {vol = (($default_bussset.crowd_one_shots.vol))} time = 0.02}
	else
		change \{g_current_music_dsp_snapshot_setting = 'game'}
		audio_effects_reset_to_current_snapshot
	endif
	if NOT (<song> = jamsession)
		if (<type> != freeplay)
			audio_freeplay_music_and_crowd_transitions \{params = {
					transition = 'Setlist_To_Game'
				}}
		endif
	endif
	if localgameincludesabassist
		if NOT (<song> = jamsession)
			setsoundbusseffects \{effects = [
					{
						name = bass_eq
						effect = parameq
						center = 100
						bandwidth = 1
						gain = 1.0
					}
				]
				time = 0.2}
			change \{g_current_eq_bass_gain = 1.0}
		endif
		printdspsettingsonscreen
	else
	endif
endscript
dspsettings_printtoscreen = 0

script printdspsettingsonscreen 
	if ($dspsettings_printtoscreen = 1)
		formattext textname = my_text qs(0xb61e1d96) n = ($g_current_eq_kick_gain) dontassertforchecksums
		create_panel_message {text = <my_text>
			pos = (950.0, 300.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_1
		}
		formattext textname = my_text2 qs(0x81388595) n = ($g_current_delay_kick_wetmix) dontassertforchecksums
		create_panel_message {text = <my_text2>
			pos = (950.0, 320.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_2
		}
		formattext textname = my_text3 qs(0x90f84428) n = ($g_current_eq_snare_gain) dontassertforchecksums
		create_panel_message {text = <my_text3>
			pos = (950.0, 340.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_3
		}
		formattext textname = my_text4 qs(0x7a95cf5f) n = ($g_current_delay_snare_wetmix) dontassertforchecksums
		create_panel_message {text = <my_text4>
			pos = (950.0, 360.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_4
		}
		formattext textname = my_text5 qs(0x98242f04) n = ($g_current_eq_cymbal_gain) dontassertforchecksums
		create_panel_message {text = <my_text5>
			pos = (950.0, 380.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_5
		}
		formattext textname = my_text6 qs(0x91825885) n = ($g_current_comp_guitar_threshold) dontassertforchecksums
		create_panel_message {text = <my_text6>
			pos = (950.0, 400.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_6
		}
		formattext textname = my_text7 qs(0x859f7bd7) n = ($g_current_eq_guitar_gain) dontassertforchecksums
		create_panel_message {text = <my_text7>
			pos = (950.0, 420.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_7
		}
		formattext textname = my_text8 qs(0xf67cfb22) n = ($g_current_comp_bass_threshold) dontassertforchecksums
		create_panel_message {text = <my_text8>
			pos = (950.0, 440.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_8
		}
		formattext textname = my_text9 qs(0x7882957d) n = ($g_current_eq_bass_gain) dontassertforchecksums
		create_panel_message {text = <my_text9>
			pos = (950.0, 460.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_9
		}
		formattext textname = my_text10 qs(0xe971d45d) n = ($g_current_eq_vocals_gain) dontassertforchecksums
		create_panel_message {text = <my_text10>
			pos = (950.0, 480.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_10
		}
		formattext textname = my_text11 qs(0xbc90e139) n = ($g_current_delay_vocals_wetmix) dontassertforchecksums
		create_panel_message {text = <my_text11>
			pos = (950.0, 500.0)
			rgba = [255 255 255 255]
			font_face = fontgrid_text_a3
			time = 180000
			just = [left left]
			scale = 0.33
			id = sfx_dsp_panel_message_11
		}
	endif
endscript

script waitthendumpsounds 
	wait \{1.5
		seconds}
	if ($debugsoundfx = 1)
		dumpsounds
	endif
	printdspsettingsonscreen
endscript

script localgameincludesabassist 
	gamemode_gettype
	getnumplayersingame \{local}
	getfirstplayer \{local}
	if (<num_players> > 0)
		begin
		if playerinfoequals <player> part = bass
			if (<type> != freeplay)
				return \{true}
			else
				getplayerinfo <player> freeplay_state
				if (<freeplay_state> != dropped && <freeplay_state> != joining)
					return \{true}
				endif
			endif
		endif
		getnextplayer player = <player> local
		repeat <num_players>
	endif
	return \{false}
endscript

script begin_jam_song \{pause = 0}
	getsongtimems
	casttointeger \{time}
	printf \{channel = jam_mode
		qs(0xca536e9e)}
	if NOT notetracker_is_using_stream
		playback_custom_song start_time = <time> in_game = 1
	endif
	musicstudio_init_volumes
	jam_init_reverb
	musicstudio_init_pan
	musicstudio_init_all_line6_effects
	musicstudio_eq_settings_mastering
	change \{song_is_waiting_to_start = 0}
endscript

script net_stream_mp3 
	printf \{qs(0x2c7f49b5)}
	netsessionfunc \{func = cdn_init}
	wait \{1
		second}
	printf \{qs(0x07521a76)}
	authoringinit
	wait \{1
		second}
	printf \{qs(0x4acd4ff1)}
	if NOT gotparam \{filename}
		filename = 'ClickClickBoom.mp3'
	endif
	authoringgetfile <filename> heap = bottomupheap
	begin
	if authoringisloaded <filename>
		printf \{qs(0x0d3b51e8)}
		break
	else
		printf qs(0x167dad2a) i = <progress>
		if (<progress> > 500000)
			break
		endif
	endif
	wait \{1
		gameframe}
	repeat
	printf \{qs(0x57adc52f)}
	stopallsounds
	printf qs(0x50a5d267) s = <filename>
	loadmp3 <filename> usecdn = true
	buffer_pos = (1024 * 1024)
	printf \{qs(0x32de9625)}
	decompressmp3 name = <filename> reset
	decompressmp3 name = <filename> pos = <buffer_pos>
	printf \{qs(0x53bf4f66)}
	addpcmstream mp3stream name = <filename> sample_freq = 44100 floatformat = false
	wait \{2
		gameframe}
	playsound \{mp3stream
		buss = master}
	getstarttime
	song_starttime = <starttime>
	getpcmstreamseekpos \{mp3stream}
	printf qs(0x35461467) i = <pos>
	begin
	getpcmstreamseekpos \{mp3stream}
	new_buffer_pos = (<buffer_pos> + 16 * 1024)
	if (<pos> + 1024 * 1024 > <buffer_pos>)
		if NOT decompressmp3 name = <filename> pos = <new_buffer_pos>
			break
		endif
		<buffer_pos> = <new_buffer_pos>
	endif
	wait \{1
		gameframe}
	repeat
	song_lengthms = ((1000.0 * <totalsize>) / (44100 * 2 * 2))
	printstruct <...>
	begin
	getstarttime
	song_time = (<starttime> - <song_starttime>)
	if (<song_time> >= <song_lengthms>)
		printstruct <...>
		printf \{qs(0x3111b13e)}
		break
	endif
	wait \{1
		gameframe}
	repeat
	stopsound \{mp3stream}
	stopsound \{fsbstream}
	wait \{4
		gameframes}
	decompressmp3 name = <filename> reset
	unloadmp3 name = ($jam_notetracker_mp3)
	removepcmstream \{mp3stream}
	removefsbstream \{fsbstream}
endscript

script preload_mp3_song 
	musicstudio_instrument_unloadall
	getsonginfo
	change jam_notetracker_mp3 = <streamfile>
	change jam_notetracker_usecdn = <usecdn>
	spawnscript \{mp3_decoder}
endscript

script mp3_decoder 
	usecdn = ($jam_notetracker_usecdn)
	if stringcontains text = ($jam_notetracker_mp3) substring = '.fsb'
		usefsb = 1
		progress_required = (32 * 1024)
	else
		usefsb = 0
		progress_required = (100 * 1024)
	endif
	if (<usecdn>)
		createscreenelement \{type = textelement
			parent = root_window
			id = cdn_progress
			just = [
				center
				top
			]
			font = debug
			text = qs(0xc66308a5)
			scale = 0.5
			pos = (640.0, 200.0)
			rgba = [
				250
				245
				145
				255
			]}
	endif
	filename = ($jam_notetracker_mp3)
	if (<usecdn>)
		printf \{qs(0x2c7f49b5)}
		netsessionfunc \{func = cdn_init}
		begin
		if netsessionfunc \{obj = raf
				func = is_ready}
			printf \{qs(0x03c8ecd6)}
			break
		endif
		if netsessionfunc \{obj = raf
				func = check_for_manifest_error}
			printf 'Manifest download error %e' e = <error>
			formattext textname = mp3_text qs(0xcd97b6e0) s = <percent>
			setscreenelementprops id = cdn_progress text = <mp3_text>
			return
			break
		endif
		wait \{1
			gameframe}
		repeat
		printf \{qs(0x07521a76)}
		authoringinit
		printf \{qs(0x1e492b37)}
		authoringgetfile ($jam_notetracker_mp3) heap = heap_musicstudio_guitar
		frames = 0
		last_progress = -1
		begin
		if authoringisloaded <filename>
			printf \{qs(0x80bb28ad)}
			break
		else
			if (<progress> != <last_progress>)
				printf qs(0x79981298) i = <progress>
				last_progress = <progress>
			endif
			if (<current> = false)
				frames = (<frames> + 1)
				if (<frames> = 120)
					printf \{qs(0x67534dab)}
					frames = 0
				endif
			endif
			if (<progress> > <progress_required>)
				break
			endif
		endif
		wait \{1
			gameframe}
		repeat
	endif
	if (<usefsb> = 0)
		printf \{qs(0xf3676e6b)}
		loadmp3 ($jam_notetracker_mp3) usecdn = ($jam_notetracker_usecdn) heap = heap_musicstudio_guitar
		addmp3stream mp3stream name = ($jam_notetracker_mp3) usecdn = <usecdn>
		if (<usecdn>)
			begin
			getpcmstreamseekpos \{fsbstream}
			if authoringisloaded <filename>
				formattext \{textname = mp3_text
					qs(0xcfd55336)
					s = 100}
				setscreenelementprops id = cdn_progress text = <mp3_text>
				break
			else
				percent = ((<progress> - <pos>) * 100)
				percent = (<percent> / (128 * 1024))
				if (<percent> > 100)
					percent = 100
				endif
				if (<percent> < 0)
					percent = 0
				endif
				formattext textname = mp3_text qs(0xcfd55336) s = <percent>
				setscreenelementprops id = cdn_progress text = <mp3_text>
			endif
			wait \{1
				gameframe}
			repeat
		endif
	else
		addfsbstream fsbstream ($jam_notetracker_mp3) usecdn = <usecdn>
		if (<usecdn>)
			begin
			getpcmstreamseekpos \{fsbstream}
			if authoringisloaded <filename>
				formattext \{textname = mp3_text
					qs(0xcfd55336)
					s = 100}
				setscreenelementprops id = cdn_progress text = <mp3_text>
				break
			else
				percent = ((<progress> - <pos>) * 100)
				percent = (<percent> / (128 * 1024))
				if (<percent> > 100)
					percent = 100
				endif
				if (<percent> < 0)
					percent = 0
				endif
				formattext textname = mp3_text qs(0xcfd55336) s = <percent>
				setscreenelementprops id = cdn_progress text = <mp3_text>
			endif
			wait \{1
				gameframe}
			repeat
		endif
	endif
endscript

script begin_mp3_song 
	printf \{qs(0x99bf2c18)}
	change \{single_stream_enabled = 1}
	single_stream_reset
	if stringcontains text = ($jam_notetracker_mp3) substring = '.fsb'
		spawnscript \{fsb_streamer}
	else
		spawnscript \{mp3_streamer}
	endif
endscript

script end_mp3_song 
	if ($current_song_qpak = jamsession)
		if notetracker_is_using_stream
			killspawnedscript \{name = mp3_decoder}
			killspawnedscript \{name = mp3_streamer}
			destroyscreenelement \{id = cdn_progress}
			stopsound \{mp3stream}
			stopsound \{fsbstream}
			wait \{4
				gameframes}
			decompressmp3 name = ($jam_notetracker_mp3) reset
			unloadmp3 name = ($jam_notetracker_mp3)
			removepcmstream \{mp3stream}
			removefsbstream \{fsbstream}
			musicstudio_mainobj :0x691dd744
			musicstudio_mainobj :0x13bdcf18
		endif
	endif
	killspawnedscript \{name = 0x981544bd}
	0x70de2b6e
	single_stream_reset
endscript

script mp3_streamer 
	playing = 0
	song_starttime = 0
	begin
	if NOT gameispaused
		if (<playing> = 0)
			if 0x4831889b \{mp3stream}
				playsound mp3stream buss = notetracker_stream vol_percent = ($single_stream_max_vol) pan1x = 0.25 pan1y = 1 pan2x = -0.25 pan2y = 1
				playing = 1
				if ($jam_notetracker_usecdn = 0)
					return
				endif
			else
				printf \{qs(0xf894a92d)}
				printstruct <...>
				gh3_start_pressed \{from_handler}
				unpausespawnedscript \{mp3_decoder}
				unpausespawnedscript \{rafoverlay_thread}
			endif
		else
			0x07f85e65 \{mp3stream}
			if authoringisloaded ($jam_notetracker_mp3)
				break
			endif
			if (<progress> < <pos> + 16 * 1024)
				printf \{qs(0xe50baad2)}
				printstruct <...>
				gh3_start_pressed \{from_handler}
				unpausespawnedscript \{mp3_decoder}
				unpausespawnedscript \{rafoverlay_thread}
			endif
		endif
	endif
	wait \{1
		gameframe}
	repeat
	song_lengthms = ((1000.0 * <totalsize>) / (44100 * 2 * 2))
	printstruct <...>
	begin
	getsongtimems
	song_time = <time>
	if (<song_time> >= <song_lengthms>)
		printstruct <...>
		printf \{qs(0x3111b13e)}
		break
	endif
	wait \{1
		gameframe}
	repeat
	stopsound \{mp3stream}
	wait \{4
		gameframes}
	decompressmp3 name = ($jam_notetracker_mp3) reset
	unloadmp3 name = ($jam_notetracker_mp3)
	removepcmstream \{mp3stream}
endscript

script 0x5b40738d 
	playing = 0
	song_starttime = 0
	begin
	if NOT gameispaused
		if (<playing> = 0)
			if ispcmstreamadded \{mp3stream}
				playsound mp3stream buss = notetracker_stream vol_percent = ($single_stream_max_vol) pan1x = 0.25 pan1y = 1 pan2x = -0.25 pan2y = 1
				playing = 1
				getstarttime
				song_starttime = <starttime>
			else
				printf \{qs(0xf894a92d)}
				printstruct <...>
				gh3_start_pressed \{from_handler}
				unpausespawnedscript \{mp3_decoder}
				unpausespawnedscript \{rafoverlay_thread}
			endif
		else
			getpcmstreamseekpos \{mp3stream}
			if NOT decompressmp3 name = ($jam_notetracker_mp3) pos = 0
				break
			endif
			if (<totalsize> < <pos> + 768 * 1024)
				printf \{qs(0xe50baad2)}
				printstruct <...>
				gh3_start_pressed \{from_handler}
				unpausespawnedscript \{mp3_decoder}
				unpausespawnedscript \{rafoverlay_thread}
			endif
		endif
	endif
	wait \{1
		gameframe}
	repeat
	song_lengthms = ((1000.0 * <totalsize>) / (44100 * 2 * 2))
	printstruct <...>
	begin
	getstarttime
	song_time = (<starttime> - <song_starttime>)
	if (<song_time> >= <song_lengthms>)
		printstruct <...>
		printf \{qs(0x3111b13e)}
		break
	endif
	wait \{1
		gameframe}
	repeat
	stopsound \{mp3stream}
	wait \{4
		gameframes}
	decompressmp3 name = ($jam_notetracker_mp3) reset
	unloadmp3 name = ($jam_notetracker_mp3)
	removepcmstream \{mp3stream}
endscript

script fsb_streamer 
	playing = 0
	song_starttime = 0
	begin
	if NOT gameispaused
		if (<playing> = 0)
			if isfsbstreamadded \{fsbstream}
				playsound fsbstream buss = notetracker_stream vol_percent = ($single_stream_max_vol) pan1x = 0.25 pan1y = 1 pan2x = -0.25 pan2y = 1
				playing = 1
				if ($jam_notetracker_usecdn = 0)
					return
				endif
			else
				printf \{qs(0xd5bbdba1)}
				printstruct <...>
				gh3_start_pressed \{from_handler}
				unpausespawnedscript \{mp3_decoder}
				unpausespawnedscript \{rafoverlay_thread}
			endif
		else
			getfsbstreamseekpos \{fsbstream}
			if authoringisloaded ($jam_notetracker_mp3)
				break
			endif
			if (<progress> < <pos> + 16 * 1024)
				printf \{qs(0xcadb2ba0)}
				printstruct <...>
				gh3_start_pressed \{from_handler}
				unpausespawnedscript \{mp3_decoder}
				unpausespawnedscript \{rafoverlay_thread}
			endif
		endif
	endif
	wait \{1
		gameframe}
	repeat
endscript

script 0xb3af2e63 
	if ($single_stream_enabled = 1)
		if ($single_stream_effects_created = 0)
			effect = [
				{effect = highpass name = mp3_highpass cutoff = 10 resonance = 1.0}
				{effect = lowpass name = mp3_lowpass cutoff = 22000 resonance = 1.0}
			]
			createsoundbusseffects buss = notetracker_stream effect = <effect>
			change \{single_stream_effects_created = 1}
		endif
	endif
endscript

script 0x70de2b6e 
	destroysoundbusseffects \{buss = notetracker_stream
		buss_array = [
			mp3_highpass
			mp3_lowpass
		]}
	change \{single_stream_effects_created = 0}
	change single_stream_enabled = ($0xd33a99df)
endscript
last_performance_time = 0.0

script getperformancetime 
	if ($pause_grace_period < 0.0)
		getsongtime
		change last_performance_time = <songtime>
		return songtime = <songtime>
	else
		return songtime = ($last_performance_time)
	endif
endscript
last_performance_time_ms = 0.0

script getperformancetimems 
	if ($pause_grace_period < 0.0)
		getsongtimems time_offset = <time_offset>
		change last_performance_time_ms = <time>
		return time = <time>
	else
		return time = ($last_performance_time_ms)
	endif
endscript
