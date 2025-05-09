is_ampzilla_battle = 0

script setup_band_hud \{force_layout = 0}
	printf \{channel = zdebug
		qs(0x49729532)}
	if (<force_layout> = 0)
		update_hud_layout
	endif
	if structurecontains \{structure = $g_hud_2d_struct_used
			desc_interface}
		createscreenelement \{parent = root_window
			id = hud_misc_root
			type = containerelement
			pos = (0.0, 0.0)
			z_priority = 0
			alpha = 1}
		createscreenelement {
			parent = root_window
			id = hud_root
			type = descinterface
			desc = ($g_hud_2d_struct_used.desc_interface)
			pos = (0.0, 0.0)
			z_priority = 0
			alpha = 0
		}
		if NOT resolvescreenelementid \{id = {
					hud_root
					child = 0
				}
				param = hud_container}
			requireparams \{[
					hud_container
				]
				all}
			return
		endif
		gamemode_gettype
		hide_band_death_meter
		if (<type> = career || <type> = quickplay)
			init_upper_container
			hud_attach_star_meter
		else
			if hud_root :desc_resolvealias \{name = alias_upper_container
					param = upper_group}
				<upper_group> :die
			endif
		endif
		if ($calibrate_lag_enabled = 1 || $cheat_hudfreemode = 1)
			if hud_root :desc_resolvealias \{name = alias_upper_container
					param = upper_group}
				<upper_group> :se_setprops hide
			endif
		endif
		if (<type> = competitive && (teammodeequals team_mode = two_teams))
			if hud_root :desc_resolvealias \{name = alias_versus_meter
					param = versus_meter}
				hud_attach_widget_band_versus_meter parent_id = <versus_meter>
			endif
			count_all_players_by_part
			<num_highways> = (<num_guitar> + <num_bass> + <num_drum>)
			if (<num_vocals> > 2 && <num_highways> = 0)
				hud_root :se_setprops \{hud_standard_band_meter_pos = (165.0, 40.0)}
			endif
		elseif hud_root :desc_resolvealias \{name = alias_versus_meter
				param = versus_meter}
			<versus_meter> :die
		endif
		if (<type> = faceoff || <type> = pro_faceoff)
			if hud_root :desc_resolvealias \{name = alias_hud_scores_stack
					param = scores_stack}
				<scores_stack> :se_setprops unhide
				hud_attach_scores_stack_widget parent_id = <scores_stack>
			endif
		endif
		if hud_root :desc_resolvealias \{name = alias_final_power_meter
				param = zilla_meter}
			if (($is_ampzilla_battle) = 1)
				<zilla_meter> :se_setprops alpha = 1 fill_scale = (1.0, 0.01)
				<zilla_meter> :se_setprops
			else
				<zilla_meter> :se_setprops alpha = 0
				<zilla_meter> :die
			endif
		endif
		if ($cheat_performancemode = 1)
			if NOT (<type> = freeplay)
				hud_root :se_setprops \{hide}
			endif
		endif
	endif
	vocals_get_num_vocalists_onscreen
	if (<num_vocalists_shown> <= 0)
		change \{sysnotify_ingame_position = topright}
	elseif (<num_vocalists_shown> = 1)
		getnumplayersingame \{on_screen}
		if (<num_players_shown> = 1)
			change \{sysnotify_ingame_position = topright}
		else
			change \{sysnotify_ingame_position = centerright}
		endif
	else
		change \{sysnotify_ingame_position = centerright}
	endif
	setsystemnotificationposition pos = ($sysnotify_ingame_position)
	if ($cheat_focusmode = 1 || $calibrate_lag_enabled = 1)
		hud_create_focus_mode_curtain
	endif
	if ($g_debug_band_moment_starpower = 1)
		hud_root :obj_spawnscriptnow \{active_band_moment_starpower}
		change \{g_debug_band_moment_starpower = 0}
	endif
endscript

script destroy_band_hud 
	detachhudwidget \{all}
	if screenelementexists \{id = hud_root}
		destroyscreenelement \{id = hud_root}
	endif
	if screenelementexists \{id = hud_misc_root}
		destroyscreenelement \{id = hud_misc_root}
	endif
	change sysnotify_ingame_position = ($sysnotify_menus_position)
	setsystemnotificationposition pos = ($sysnotify_ingame_position)
endscript

script debug_refresh_hud 
	destroy_band_hud
	setup_band_hud \{force_layout = 1}
	hud_root :se_setprops \{alpha = 1}
endscript

script count_players_by_part 
	requireparams \{[
			part
		]
		all}
	<player> = 1
	<players_by_part> = 0
	getnumplayersingame \{on_screen}
	if (<num_players_shown> > 0)
		getfirstplayer \{on_screen}
		begin
		if playerinfoequals <player> part = <part>
			<players_by_part> = (<players_by_part> + 1)
		endif
		getnextplayer player = <player> on_screen
		repeat <num_players_shown>
	endif
	return players_by_part = <players_by_part>
endscript

script hud_create_focus_mode_curtain 
	createscreenelement \{type = spriteelement
		parent = hud_misc_root
		texture = white
		rgba = [
			0
			0
			0
			255
		]
		dims = (1280.0, 720.0)
		pos = (640.0, 360.0)
		z_priority = -9999}
	playigccam \{id = cs_view_cam_id
		name = ch_view_cam
		viewport = bg_viewport
		lockto = world
		pos = (100000000.0, 100000000.0, 100000000.0)
		quat = (0.0, 0.0, 0.0)
		fov = 72.0
		play_hold = 1
		interrupt_current}
endscript

script count_all_players_by_part 
	count_players_by_part \{part = guitar}
	<num_guitar> = <players_by_part>
	count_players_by_part \{part = drum}
	<num_drum> = <players_by_part>
	count_players_by_part \{part = vocals}
	<num_vocals> = <players_by_part>
	count_players_by_part \{part = bass}
	<num_bass> = <players_by_part>
	return num_guitar = <num_guitar> num_drum = <num_drum> num_vocals = <num_vocals> num_bass = <num_bass>
endscript

script update_hud_layout 
	count_all_players_by_part
	<num_highways> = (<num_guitar> + <num_bass> + <num_drum>)
	getnumplayersingame \{on_screen}
	<solo_highway_mode> = 0
	getnumplayersingame \{local}
	if (<num_players> > 0)
		getfirstplayer \{local}
		begin
		if playerinfoequals <player> solo_highway_mode = 1
			<solo_highway_mode> = 1
			break
		endif
		getnextplayer player = <player> local
		repeat <num_players>
	endif
	<desired_layout> = hud_standard
	if (<num_players_shown> = 1 && <num_highways> = 1)
		if (<solo_highway_mode> = 1)
			<desired_layout> = hud_standard_1p
		else
			<desired_layout> = hud_standard_1p
		endif
	elseif (<num_vocals> > 0 && <num_highways> = 1)
		<desired_layout> = hud_standard_1g1v
	elseif (<num_vocals> = 1 && <num_highways> = 0)
		if (<solo_highway_mode> = 1)
			<desired_layout> = hud_standard
		else
			<desired_layout> = hud_standard_1v
		endif
	else
		<desired_layout> = hud_standard
	endif
	if globalexists name = <desired_layout>
		change g_hud_2d_struct_used = $<desired_layout>
	else
		printstruct <...>
		softassert 'Unknown hud layout %s' s = <desired_layout>
		change \{g_hud_2d_struct_used = $hud_3g1v}
	endif
endscript

script show_hud 
	if screenelementexists \{id = hud_root}
		setscreenelementprops \{id = hud_root
			alpha = 1}
	endif
endscript

script hide_hud 
	if NOT retailbuild
		if ($alternate_viewer_hud_behavior = 1)
			return
		endif
	endif
	if screenelementexists \{id = hud_root}
		setscreenelementprops \{id = hud_root
			alpha = 0}
	endif
endscript

script split_text_into_array_elements \{text = qs(0x6df5a0fe)
		text_pos = (0.0, 0.0)
		space_between = (0.0, 0.0)
		flags = {
		}}
	stringtochararray string = <text>
	getarraysize <char_array>
	if NOT gotparam \{parent}
		parent = root_window
	endif
	if gotparam \{id}
		createscreenelement {
			type = containerelement
			parent = <parent>
			pos = (0.0, 0.0)
			id = <id>
		}
	else
		createscreenelement {
			type = containerelement
			parent = <parent>
			pos = (0.0, 0.0)
		}
	endif
	parent_container = <id>
	fit_scale = 1.0
	if gotparam \{fit_dims}
		createscreenelement {
			type = textelement
			parent = <parent_container>
			text = <text>
			font = fontgrid_text_a3
			scale = (<flags>.scale)
		}
		getscreenelementdims id = <id>
		stringlength string = <text>
		avg_width = (<width> / <str_len>)
		fit_scale = (<fit_dims>.(1.0, 0.0) / (<str_len> * <avg_width>))
		<space_between> = (<space_between> * <fit_scale>)
		destroy_menu menu_id = <id>
	endif
	if gotparam \{centered}
		half_width = ((<array_size> - 1) * (<space_between>.(1.0, 0.0)) * 0.5)
		<text_pos> = (<text_pos> - <half_width> * (1.0, 0.0))
	endif
	i = 0
	begin
	createscreenelement {
		type = textelement
		parent = <parent_container>
		pos = <text_pos>
		text = (<char_array> [<i>])
		<flags>
		scale = (<flags>.scale * <fit_scale>)
		alpha = (<flags>.alpha)
	}
	createscreenelement {
		type = textelement
		parent = <parent_container>
		text = (<char_array> [<i>])
		<flags>
		z_priority = (<flags>.z_priority - 1)
		rgba = [0 0 0 255]
		just = [center center]
		pos = <text_pos>
		alpha = (<flags>.alpha)
		scale = (<flags>.scale * (1.3, 1.2) * <fit_scale>)
	}
	<text_pos> = (<text_pos> + <space_between>)
	<i> = (<i> + 1)
	repeat <array_size>
	return container_id = <parent_container>
endscript

script jiggle_text_array_elements \{explode = 0}
	saved_id = <id>
	if NOT screenelementexists id = <id>
		return
	endif
	getscreenelementchildren id = <id>
	getarraysize \{children}
	i = 0
	begin
	if screenelementexists id = (<children> [<i>])
		getscreenelementprops id = (<children> [<i>])
		(<children> [<i>]) :settags pos = <pos> scale = <scale>
	endif
	<i> = (<i> + 1)
	repeat <array_size>
	getstarttime
	last_time = <starttime>
	begin
	getstarttime
	if ((<starttime> - <last_time>) >= <wait_time>)
		break
	else
		i = 0
		begin
		if screenelementexists id = (<children> [<i>])
			(<children> [<i>]) :gettags
			getrandomvalue \{a = -10
				b = 10
				name = rand_x}
			getrandomvalue \{a = -10
				b = -10
				name = rand_y}
			getrandomvalue \{a = 0
				b = 3
				name = rand_rot}
			getrandomvalue \{a = 0.7
				b = 1.3
				name = rand_scale}
			rand_pos = (<rand_x> * (1.0, 0.0) + <rand_y> * (0.0, 1.0))
			setscreenelementprops id = (<children> [<i>]) pos = (<pos> + <rand_pos>) rot_angle = <rand_rot> scale = <rand_scale> relative_scale
		endif
		<i> = (<i> + 1)
		repeat <array_size>
		wait \{0.075
			seconds}
		<i> = 0
		begin
		if screenelementexists id = (<children> [<i>])
			(<children> [<i>]) :gettags
			setscreenelementprops id = (<children> [<i>]) pos = <pos> rot_angle = <rand_rot> scale = <scale>
		endif
		<i> = (<i> + 1)
		repeat <array_size>
	endif
	wait \{1
		gameframe}
	repeat
	if (<explode> = 1)
		<id> = <saved_id>
		explode_text_array_elements <...>
	endif
endscript

script explode_text_array_elements 
	if NOT screenelementexists id = <id>
		return
	endif
	if NOT getscreenelementchildren id = <id>
		return
	endif
	getarraysize \{children}
	i = 0
	explode_dir = 1
	if (<array_size> < 2)
		return
	endif
	begin
	if screenelementexists id = (<children> [<i>])
		switch (<explode_dir>)
			case 1
			getrandomvalue \{a = -2000
				b = 0
				name = rand_x}
			getrandomvalue \{a = -2000
				b = -200
				name = rand_y}
			case 2
			getrandomvalue \{a = 1280
				b = 3280
				name = rand_x}
			getrandomvalue \{a = -2000
				b = -200
				name = rand_y}
			case 3
			getrandomvalue \{a = 1280
				b = 3280
				name = rand_x}
			getrandomvalue \{a = 920
				b = 2720
				name = rand_y}
			case 4
			getrandomvalue \{a = -2000
				b = 0
				name = rand_x}
			getrandomvalue \{a = 920
				b = 2720
				name = rand_y}
		endswitch
		<explode_dir> = (<explode_dir> + 1)
		if (<explode_dir> > 4)
			<explode_dir> = 1
		endif
		getrandomvalue \{a = 0
			b = 180
			name = rand_rot}
		rand_pos = (<rand_x> * (1.0, 0.0) + <rand_y> * (0.0, 1.0))
		setscreenelementprops id = (<children> [<i>]) pos = <rand_pos> rot_angle = <rand_rot> time = <time> motion = ease_out
	endif
	<i> = (<i> + 1)
	if screenelementexists id = (<children> [<i>])
		setscreenelementprops id = (<children> [<i>]) pos = <rand_pos> rot_angle = <rand_rot> time = <time>
	endif
	<i> = (<i> + 1)
	repeat (<array_size> / 2)
endscript

script init_upper_container 
	<cnt> = 0
	getnumplayersingame
	if (<num_players> > 0)
		getfirstplayer
		begin
		getplayerinfo <player> part
		if (<part> = vocals)
			cnt = (<cnt> + 1)
		endif
		getnextplayer player = <player>
		repeat <num_players>
	endif
	if (<cnt> >= 1)
		shift_upper_hud
	else
		shift_upper_hud \{dx = 40}
	endif
endscript

script shift_upper_hud \{dx = 120}
	if NOT screenelementexists \{id = hud_root}
		printf \{qs(0xc0fc7d99)
			channel = zdebug}
		return
	endif
	if NOT hud_root :desc_resolvealias \{name = alias_upper_container
			param = upper_group}
		printf \{qs(0x20f5a935)
			channel = zdebug}
		return
	endif
	rel_pos = ((0.0, 1.0) * <dx>)
	<upper_group> :se_setprops pos = {relative <rel_pos>}
endscript
force_fail_vignette_on = 0

script create_band_failing_vignette 
	if NOT screenelementexists \{id = vignette_of_failure}
		createscreenelement \{id = vignette_of_failure
			parent = root_window
			type = descinterface
			desc = 'band_fail_vignette'
			z_priority = 25
			pos = (0.0, 0.0)
			root_alpha = 0}
		vignette_of_failure :obj_spawnscriptnow \{band_failing_vignette_pulse}
	endif
endscript

script band_failing_vignette_on 
	if ($current_num_players = 1)
		return
	endif
	if ($game_mode = p2_faceoff)
		return
	endif
	if ($game_mode = freeplay)
		return
	endif
	gamemode_gettype
	if (<type> = competitive)
		return
	endif
	create_band_failing_vignette
	vignette_of_failure :se_setprops \{root_alpha = 1.0
		time = 0.5}
endscript

script band_failing_vignette_pulse 
	begin
	se_setprops \{outline_rgba = [
			128
			0
			0
			255
		]
		time = 0.5}
	se_waitprops
	se_setprops \{outline_rgba = [
			0
			0
			0
			255
		]
		time = 0.5}
	se_waitprops
	repeat
endscript

script band_failing_vignette_off 
	if ($force_fail_vignette_on = 1)
		return
	endif
	create_band_failing_vignette
	vignette_of_failure :se_setprops \{root_alpha = 0.0
		time = 0.5}
endscript

script destroy_band_failing_vignette 
	destroyscreenelement \{id = vignette_of_failure}
endscript

script 0xf11bb8e9 
	<max_zilla_stars> = 9.0
	if (($is_ampzilla_battle) != 1)
		return
	endif
	if NOT hud_root :desc_resolvealias \{name = alias_hud_meter_star
			param = star_meter}
		printf \{channel = zdebug
			qs(0xccccee13)}
		return
	endif
	if NOT hud_root :desc_resolvealias \{name = alias_final_power_meter
			param = zilla_meter}
		printf \{channel = zdebug
			qs(0x06e05b66)}
		return
	endif
	<zilla_percent> = (<stars> / <max_zilla_stars>)
	<zilla_percent> = (<zilla_percent> * 128.0)
	<dims> = (((1.0, 0.0) * <zilla_percent>) + (0.0, 64.0))
	<zilla_meter> :se_setprops fill_dims = <dims>
endscript
