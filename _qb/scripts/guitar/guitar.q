show_gpu_time = 0
output_gpu_log = 0
gpu_log_start_logging = 0
show_cpu_time = 0
show_play_log = 0
play_log_lines = 10
show_guitar_tilt = 0
nxwatson_channels = 1
output_song_stats = 0
show_sensor_debug = 0
vocal_debug_hud = 0
roland_drumkit = 1
save_heap_created_at_boot = 0
ps2_venues = 0
current_level = load_z_cairo
current_time = 0.0
current_deltatime = 0.0167
current_starttime = 0
current_endtime = 0
current_looppoint = -1000000
current_speedfactor = 1.0
autolaunch_startnow = 0
autolaunch_showstorageselector = 1
current_song_qpak = none
current_song_qpak_performance = 0
freeplay_mem_dump_done = 0
last_song_failed = none
current_song_failed_num = 0
current_transition = none
debug_current_transition = none
in_band_lobby = 0
num_players_finished = 0
guitar_fretbar_divisions = 2
drum_fretbar_divisions = 2
always_corrupt_savegames = 0
disable_band = 0
disable_crowd = 0
disable_note_input = 0
is_network_game = 0
net_ready_to_start = 0
rich_presence_context = presence_menus
game_mode = quickplay
allow_controller_for_all_instruments = 0
autolaunch_cas = 0
autolaunch_jam = 0
autolaunch_lobby = 0
autolaunch_mainmenu = 0
skip_signin = 0
skip_career_forced_flow = 0
show_movies = 1
downloadcontent_enabled = 1
input_mode = record
replay_suspend = 1
songtime_paused = 0
drum_solo_songtime_paused = 0
drum_solo_length = 0.0
drum_solo_no_gems = 0
drum_rock_meter_weights = {
	beginner = [
		1.0
		1.0
	]
	easy = [
		1.0
		1.0
	]
	medium = [
		1.5
		1.5
	]
	hard = [
		2.0
		2.5
	]
	expert = [
		2.0
		2.5
	]
}
net_pattern = 0
net_strum = 0
display_debug_input = 0
output_log_file = 0
practice_start_time = 0
practice_end_time = 0
practice_loop_section = 1
startup_song = bloodlines
time_audio_offset = 0.0
time_gem_offset = 0.0
time_input_offset = 0.0
time_drum_midi_offset = 0.0
time_gem_offset_with_lag = 0.0
time_drum_midi_offset_with_lag = 0.0
cheat_airinstruments = -1
cheat_invisiblecharacters = -1
cheat_performancemode = -1
cheat_invincible = -1
cheat_focusmode = -1
cheat_hudfreemode = -1
challenge_fretbar_width = 1.5
challenge_fretbar_z = 3.9
crowd_model_array = none
failed_song_time = 0.0
current_section_array = none
current_section_array_entry = 0
primary_controller = 0
primary_controller_assigned = 0
invite_controller = -1
allow_missing_song_fsbs = 0
streamall_fsb_index = -1
sixchannelfiles_fsb_index = -1
enable_button_cheats = 1
enable_debug_menus = 1
winning_player_camera_percentage = 100
playerserver_frame_lag = 0
sysnotify_menus_position = topright
sysnotify_ingame_position = topright
instrument_checksums = [
	guitar
	bass
	vocals
	drum
]
instrument_text = [
	qs(0x09048d9e)
	qs(0xb6237ee8)
	qs(0x879f5b50)
	qs(0x04246759)
]
part_priority = [
	vocals
	drum
	guitar
	bass
]
random_songs_on_disc_only = 0
boot_movie_done = 0
cameracuts_enablevideovenuecams = 0
use_worst_band = 0
g_skinning_lod_dist = 6

script print_loading_time 
	gettrueelapsedtime starttime = <starttime>
	finalprintf qs(0xc84bff60) a = <elapsedtime> t = <text>
	gettruestarttime
	return starttime = <starttime>
endscript

script guitar_startup 
	if globalexists \{name = scriptstocompile}
		getarraysize \{$scriptstocompile}
		if (<array_size> > 0)
			index = 0
			begin
			enablecompiledscript scriptname = ($scriptstocompile [<index>].scriptname) checksum = ($scriptstocompile [<index>].checksum)
			index = (<index> + 1)
			repeat <array_size>
		endif
	endif
	if scriptexists \{pre_startup}
		pre_startup
	endif
	if demobuild
		if ($kiosk_demo = 1)
			change gh6_songlist = ($gh6_demo_kiosk_songlist)
		else
			change gh6_songlist = ($gh6_demo_xbla_songlist)
		endif
	endif
	gettruestarttime
	guitar_startup_initialize
	guitar_startup_memory
	guitar_startup_systems
	print_loading_time starttime = <starttime> text = qs(0xc0c883fd)
	if scriptexists \{console_debug_create_personal}
		console_debug_create_personal
	else
		console_debug_create
	endif
	spawnscriptnow \{guitar_startup_spawned}
endscript

script debug_timing_test 
	togglemetrics \{mode = 2}
	wait \{100
		gameframes}
	moveprofilecursor cpu = ($current_cpu) freeze
endscript

script guitar_startup_spawned 
	audio_ui_menu_music_off
	memory_create_song_heap
	guitar_startup_critical_loads
	spawnscriptnow \{guitar_startup_async_init}
	output_status_begin \{prefix = 'movie'}
	output_status \{prefix = 'movie'
		text = 'Loading intro movie to memory.'}
	create_loading_screen \{is_bink
		bink = 'Intro_FINALanimatic_0209'
		heap = heap_cas_cache
		heap_vram = heap_cas_cache_vram
		pause_script = guitar_startup_async_init}
	output_status \{prefix = 'movie'
		text = 'cleanup'}
	startrendering
	hideloadingscreen
	fadetoblack \{off
		no_wait}
	output_status_end \{prefix = 'movie'}
	output_status_begin \{prefix = 'mload'}
	output_status \{prefix = 'mload'
		text = 'pak/anims/perm_anims/perm_anims.pak & pak/ui_shared/ui_shared.pak'}
	loadpakasync \{pak_name = 'pak/anims/perm_anims/perm_anims.pak'
		heap = heap_musician_anim
		no_vram}
	loadpakasync \{pak_name = 'pak/ui_shared/ui_shared.pak'
		heap = heap_ui_shared}
	output_status \{prefix = 'mload'
		text = 'Font setup'}
	interlock \{lock_name = lock_uishared}
	output_status \{prefix = 'mgame'
		text = 'Load in-game textures'}
	pushmemprofile \{'z_in_game'}
	loadpakasync \{pak_name = 'zones/z_ingame/z_in_game.pak'
		heap = heap_in_game}
	popmemprofile
	output_status \{prefix = 'mload'
		text = 'Initializing Anim Cache'}
	loadpakasync \{pak_name = 'pak/animq.pak'
		heap = topdownheap
		no_vram}
	registerallanimevents
	unloadpak \{'pak/animq.pak'}
	output_status \{prefix = 'mload'
		text = 'Loading global_model_tex'}
	pushmemprofile \{'global_model_tex'}
	loadpakasync \{pak_name = 'pak/global_model_tex/global_model_tex.pak'
		heap = heap_global_pak}
	popmemprofile
	output_status \{prefix = 'mload'
		text = 'Loading cas_captextures'}
	pushmemprofile \{'Game Heaps'}
	loadpakasync \{pak_name = 'pak/cas_captextures.pak'
		heap = heap_cas_global}
	memory_create_zone_maps
	popmemprofile
	output_status \{prefix = 'mload'
		text = 'Pak for global venue ad textures'}
	loadpakasync \{pak_name = 'pak/global_ad_tex/global_ad_tex.pak'
		heap = heap_massive_ads}
	registertexdictforui \{`pak/global_ad_tex/global_ad_tex.tex`}
	output_status \{prefix = 'mload'
		text = 'Pak for menu ad textures'}
	dynamicadmanagercommand \{func = loadingpak}
	loadpakasync \{pak_name = 'pak/menu_ad_tex/menu_ad_tex.pak'
		heap = heap_massive_ads}
	registertexdictforui \{`pak/menu_ad_tex/menu_ad_tex.tex`}
	output_status \{prefix = 'mload'
		text = 'Load up global ragdoll/skeleton pak. As a rawpak, we\'re instancing out assets from it'}
	loadpakasync \{pak_name = 'pak/global_skeletons/global_skeletons.pak'
		heap = heap_global_pak
		is_raw = 1}
	output_status \{prefix = 'mload'
		text = 'Load up song stats'}
	loadpakasync \{pak_name = 'pak/songstat.pak'
		heap = heap_songstat_pak
		no_vram}
	output_status \{prefix = 'mload'
		text = 'Loading global.pak'}
	loadpakasync \{pak_name = 'zones/global/global.pak'
		heap = heap_global_pak}
	output_status \{prefix = 'mload'
		text = 'Loading global.pak nodearray'}
	parsenodearray \{queue
		zone_name = global
		array_name = global_nodearray
		heap = heap_global_pak}
	output_status \{prefix = 'mload'
		text = 'AvatarBoneRemapTable'}
	pushmemprofile \{'InitializeAvatarBoneRemapTable'}
	initializeavatarboneremaptable
	popmemprofile
	interlock \{lock_name = lock_materials}
	output_status \{prefix = 'mload'
		text = 'Changelist display settings'}
	if ($show_build_version = 1)
		debug_toggle_changelist \{show}
	endif
	output_status \{prefix = 'mload'
		text = 'FMod Streams + SFX'}
	pausespawnedscript \{guitar_startup_async_init}
	pushmemprofile \{'FMod Streams + SFX'}
	if isfmodenabled
		loadfsb \{filename = 'streams/streamall'
			numstreams = 3}
		change streamall_fsb_index = <fsb_index>
		loadfsb \{filename = 'streams/sixchannelfiles'
			numstreams = 1}
		change sixchannelfiles_fsb_index = <fsb_index>
		loadpakasync \{pak_name = 'zones/global/global_sfx.pak'
			heap = heap_global_sfx}
	endif
	popmemprofile
	unpausespawnedscript \{guitar_startup_async_init}
	output_status \{prefix = 'mload'
		text = 'global_gfx setup'}
	setscenepermanent \{scene = 'zones/global/global_gfx.scn'
		permanent}
	output_status \{prefix = 'iinit'
		text = 'Set SkinLookupTexture'}
	engineconfig \{skinlookuptexture = `tex/sfx/skinlookup64x64_dnc.dds`}
	output_status \{prefix = 'mload'
		text = 'setup_models'}
	pushmemprofile \{'setup_models'}
	setup_models
	popmemprofile
	output_status \{prefix = 'mload'
		text = 'Loading Zone'}
	printf \{qs(0x7ef8c198)
		s = $current_level}
	setpakmancurrentblock \{map = zones
		pak = none
		block_scripts = 1}
	output_status \{prefix = 'mload'
		text = 'Creating Reverb'}
	audio_effects_create_settings_by_venue
	audio_jam_effects_create_jam_mode_effects
	change \{g_not_start_of_game = 0}
	output_status \{prefix = 'mload'
		text = 'AddEditableList ped_editable_list'}
	addeditablelist \{ped_editable_list}
	output_status \{prefix = 'mload'
		text = 'StartKeyboardHandler'}
	startkeyboardhandler \{max_length = 128}
	output_status_end \{prefix = 'mload'}
	printf \{qs(0xb698d219)}
	output_status_begin \{prefix = 'mgame'}
	output_status \{prefix = 'mgame'
		text = 'Load in-game anims'}
	pushmemprofile \{'z_in_game'}
	popmemprofile
	output_status \{prefix = 'mgame'
		text = 'Band logo'}
	pushmemprofile \{'band_logo'}
	cas_band_logo_create_object
	popmemprofile
	registertexdictforui ($cas_band_logo_details.texdict)
	output_status \{prefix = 'mgame'
		text = 'Create MusicStudio Object'}
	pushmemprofile \{'MusicStudio'}
	createcompositeobject \{$musicstudio_mainobj_desc}
	popmemprofile
	output_status \{prefix = 'mgame'
		text = 'Vocals setup'}
	vocals_start_mic
	if ($autolaunch_startnow != 0)
		vocals_distribute_mics
	endif
	output_status \{prefix = 'mgame'
		text = 'Jam Session'}
	songfilemanager \{func = add_song_file
		song_name = jamsession}
	output_status \{prefix = 'mgame'
		text = 'ArchiveInvalidateSizes'}
	if NOT cd
		archiveinvalidatesizes
	endif
	interlock \{wait
		prefix = 'mgame'
		lock_name = lock_savegame}
	output_status \{prefix = 'mgame'
		text = 'Load venue'}
	interlock \{wait
		prefix = 'mgame'
		lock_name = lock_globaltags}
	quickplay_choose_random_venue
	load_venue
	output_status \{prefix = 'mgame'
		text = 'Load song'}
	playlist_clear
	freeplay_next_song \{initial_song_list = true}
	output_status \{prefix = 'mgame'
		text = 'Load persistent band.'}
	persistent_band_create_band \{startup = 1
		async = 1}
	waitunloadgroup \{cas
		async = 1}
	playlist_getcurrentsong
	load_songqpak song_name = <current_song> async = 1 resetzone = 1
	loaddrumkitall async = 1 percussion = 0 song = <current_song>
	anim_paks_set_state \{state = ingame}
	persistent_band_prepare_for_song \{async = 1}
	output_status \{prefix = 'mgame'
		text = 'Preload band_lobbyUI Pak'}
	setpakmancurrent \{map = ui_paks
		pakname = 'band_lobby'}
	output_status \{prefix = 'mgame'
		text = 'Make sure all async scripts are done.'}
	interlock \{wait
		prefix = 'mgame'}
	interlock \{wait
		prefix = 'mgame'
		lock_name = lock_freeplay}
	memory_destroy_save_heap_at_boot
	output_status_end \{prefix = 'mgame'}
	output_status_begin \{prefix = 'movie'}
	output_status \{prefix = 'movie'
		text = 'Waiting for movie to finish.'}
	destroy_loading_screen \{wait_for_unload
		wait_for_end}
	output_status_end \{prefix = 'movie'}
	change \{boot_movie_done = 1}
	create_song_and_musicstudio_heaps
	autolaunch_run
	printf \{qs(0x160a1d8c)}
	guitar_initialize_profilers
	getmaxlocalplayers
	player = 1
	begin
	if ($autolaunch_startnow = 1)
		spawnscriptnow create_guitar_events params = {<...>}
	else
		spawnscriptlater create_guitar_events params = {<...>}
	endif
	player = (<player> + 1)
	repeat <max_players>
	spawnscriptlater \{create_news_feed_events}
	fadetoblack \{on
		alpha = 1.0
		time = 0.0
		z_priority = 100
		no_wait}
	if ($autolaunch_startnow = 0)
		if globalexists \{name = autolaunch_state
				type = checksum}
			fadetoblack \{off
				no_wait}
			change \{primary_controller_assigned = 1}
			change \{g_boot_sysnotify_wait = false}
			ui_event \{event = menu_change
				data = {
					state = $autolaunch_state
				}}
		else
			ui_event_wait \{event = menu_replace
				data = {
					state = uistate_freeplay
					boot
				}}
			addparams \{donthide}
			fadetoblack \{off
				no_wait}
		endif
	else
		fadetoblack \{off
			no_wait}
		getplayerinfo \{1
			controller}
		ui_event_wait_for_safe
		ui_event event = menu_change data = {state = uistate_gameplay device_num = <controller> uselaststarttime = 1}
	endif
	if ($debug_unlockall_on_boot)
		if (($primary_controller_assigned = 0) || ($primary_controller = -1))
			change \{primary_controller_assigned = 1}
			change \{primary_controller = 0}
			unset_primary_controller = 1
		endif
		debug_menu_unlockall
		if gotparam \{unset_primary_controller}
			change \{primary_controller_assigned = 0}
		endif
	endif
	spawnscriptnow \{song_preview_monitor}
	create_ui_visualizer
	if isps3
		sys_mem_limit = (142 * 1024)
	else
		sys_mem_limit = 0
	endif
	setsystemmemorylimit limit = <sys_mem_limit>
	if ($autolaunch_startnow = 1)
		stoprendering
		spawnscriptnow start_game params = {starttime = ($current_starttime)}
	endif
endscript

script guitar_initialize_profilers 
	<profile_gpu> = 0
	if ($show_gpu_time = 1)
		<profile_gpu> = 1
	endif
	if ($output_gpu_log = 1)
		<profile_gpu> = 1
		if isxenon
			enableprofileinmanager \{processor = 0
				enabled = 0}
			enableprofileinmanager \{processor = 1
				enabled = 1}
			enableprofileinmanager \{processor = 2
				enabled = 0}
			enableprofileinmanager \{processor = 3
				enabled = 0}
			enableprofileinmanager \{processor = 4
				enabled = 0}
			enableprofileinmanager \{processor = 5
				enabled = 0}
			enableprofileinmanager \{processor = 6
				enabled = 0}
		else
			enableprofileinmanager \{processor = 0
				enabled = 0}
			enableprofileinmanager \{processor = 1
				enabled = 1}
			enableprofileinmanager \{processor = 2
				enabled = 0}
		endif
	endif
	if (<profile_gpu> = 1)
		togglemetrics \{mode = 5}
		change \{current_cpu = 6}
	else
		if ($show_cpu_time = 1)
			change \{current_cpu = 0}
			togglemetrics \{mode = 5}
		endif
	endif
endscript

script start_game \{starttime = 0}
	load_venue
	transition_selecttransition
	spawnscriptlater start_gem_scroller params = {starttime = <starttime>}
	unpausegh3
endscript

script autolaunch_spawned 
	if ($net_autolaunch_role = none)
		($default_loading_screen.create)
		mc_setactiveplayer \{querydefault}
		if ($autolaunch_showstorageselector = 1)
			showstorageselector
		endif
		ui_event_block \{event = menu_add
			state = uistate_mainmenu
			data = {
				base_name = 'mainmenu'
			}}
		ui_event_block \{event = menu_add
			state = uistate_songlist
			data = {
				base_name = 'songlist'
			}}
		getplayerinfo \{1
			controller}
		ui_event event = menu_change data = {state = uistate_play_song device_num = <controller> uselaststarttime = 1}
	else
		printf \{qs(0xe17688e1)}
		mc_setactiveplayer \{querydefault}
		if ($autolaunch_showstorageselector = 1)
			showstorageselector
		endif
		ui_event_block \{event = menu_add
			state = uistate_mainmenu
			data = {
				base_name = 'mainmenu'
			}}
		assign_new_primary_controller \{device_num = 0}
		net_autolaunch_spawned
	endif
endscript

script kill_dummy_bg_camera 
	killcamanim \{name = dummy_cam_bg}
endscript

script restore_dummy_bg_camera 
	kill_dummy_bg_camera
	playigccam \{name = dummy_cam_bg
		viewport = bg_viewport
		pos = (-2800000.2, 100000.48, 700000.2)
		quat = (-0.00071999995, -0.99706, -0.07604)
		fov = 72.0
		play_hold}
endscript

script get_levelzonearray_size 
	getarraysize \{$levelzonearray}
	size = (<array_size>)
	return array_size = <size>
endscript

script get_levelzonearray_checksum 
	getarraysize \{$levelzonearray}
	if (<index> < <array_size>)
		return level_checksum = ($levelzonearray [<index>])
	endif
endscript
debug_checksum_names = [
	largest_desc_id
	budget_report_main
	budget_report_vram
	budget_report_geo
	main
	vram
	underbudget
	overbudget
	totalsize
	slack
	heap_cas_vram
	assetsizes
	budgetsizes
	largestpieces
	worst_parts
	specific_parts
	size_kb
	custom_character_0
	custom_character_1
	custom_character_2
	custom_character_3
	custom_character_4
	`script cache small`
	`script cache big`
	script
	playerinfoheap
	heap_global_scripts
	heap_script_pools
	heap_hashitem_pool
	heap_network
	asyncrenderer
	heap_frontend
	heap_render_data
	heap_lightortho
	loadingscreen
	heap_massive_ads
]

script getcurrentlevel 
	return level = ($current_level)
endscript

script get_level_prefix 
	if structurecontains \{structure = $levelzones
			$current_level}
		return prefix = ($levelzones.($current_level).name) prefix_crc = ($levelzones.($current_level).zone)
	endif
	printf \{qs(0xfd035b9c)}
	printf \{qs(0xfd035b9c)}
	printf \{qs(0xc350451a)}
	printf \{qs(0xfd035b9c)}
	printf \{qs(0xfd035b9c)}
	return \{prefix = 'z_unknown'
		prefix_crc = z_unknown}
endscript

script preqbromid 
	pausegh3
endscript

script postqbromid 
	getplayerinfo \{1
		controller
		out = device_num}
	restart_gem_scroller {
		starttime = ($current_starttime)
		device_num = <device_num>
	}
endscript

script are_replays_enabled 
	return \{false}
endscript

script startrendering 
	popdisablerendering \{context = legacy_stop_rendering_script
		type = unchecked}
endscript

script stoprendering 
	pushdisablerendering \{context = legacy_stop_rendering_script
		type = unchecked}
endscript

script hide_glitch \{num_frames = !i1768515945}
	spawnscriptnow hide_glitch_spawned params = {num_frames = <num_frames>}
endscript

script hide_glitch_spawned \{num_frames = !i1768515945}
	onexitrun \{hide_glitch_spawned_exit}
	setscriptcannotpause
	pushdisablerendering \{context = hide_glitch
		type = stack}
	wait <num_frames> gameframes
endscript

script hide_glitch_spawned_exit 
	popdisablerendering \{context = hide_glitch
		type = stack}
endscript

script spawnscriptdelayed 
	getunnamedchecksum
	spawnscriptlater spawnscriptdelayedworker params = {scriptname = <checksum> params = <params> frames = <frames> seconds = <seconds>}
endscript

script spawnscriptdelayedworker 
	if gotparam \{frames}
		wait <frames> gameframes
	endif
	if gotparam \{seconds}
		wait <seconds> seconds
	endif
	spawnscriptnow <scriptname> params = <params>
endscript

script console_debug_create 
	debugconsole_display_params = {
		m_back_color = [190 , 190 , 190 , 100]
		m_text_color = [10 , 255 , 10 , 255]
		m_scroll_btn_color = [250 , 250 , 250 , 255]
		m_corner = [100.0 , 100.0]
		m_width = 800.0
		m_height = 310.0
		m_text_scale = 0.5
		m_num_rows = 12
		m_char_per_row = 80
		m_animate = 1
	}
	memory_get_heap_sizes
	dbg_console_heap = heap_debug
	if (<heap_size_stash> > 10240)
		dbg_console_heap = heap_stash
	endif
	debugconsole_create_params = {
		m_num_command_history = 5
		m_history = 100
		m_toggle_char = '`'
		m_enable = 1
		m_display = 0
		m_heap = <dbg_console_heap>
		m_use_thread_safe = 1
		m_name = debug
	}
	debugconsolecreate display_params = <debugconsole_display_params> create_params = <debugconsole_create_params>
endscript

script console_debug_destroy 
	debugconsoledestroy \{name = debug}
endscript
