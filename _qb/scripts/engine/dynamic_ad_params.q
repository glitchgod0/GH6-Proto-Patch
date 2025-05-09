massive_build = 0
massive_sku = 'atvi_guitar_hero_6_x360'
massive_log_level = none
0x9d6acbe9 = z_mainmenu
0xf583e6f5 = [
	{
		id = 0x2678b3de
		zone = z_mainmenu
		ie = 'ad_mainmenu_ad1_128x32'
		type = image
		width = 128
		height = 32
		texdict = `pak/menu_ad_tex/menu_ad_tex.tex`
		texturename = 'ad_mainmenu_ad1_logo_128x32'
		texturechecksum = 0xba903d86
	}
	{
		id = 0xe5884bd4
		zone = z_mainmenu
		ie = 'ad_mainmenu_ad1_512x256'
		type = image
		width = 512
		height = 256
		texdict = `pak/menu_ad_tex/menu_ad_tex.tex`
		texturename = 'ad_mainmenu_ad1_pic_512x256'
		texturechecksum = 0xcf117fb2
	}
	{
		id = 0xa0ecc170
		zone = z_mainmenu
		ie = 'ad_mainmenu_ad2_128x32'
		type = image
		width = 128
		height = 32
		texdict = `pak/menu_ad_tex/menu_ad_tex.tex`
		texturename = 'ad_mainmenu_ad2_logo_128x32'
		texturechecksum = 0xe90a6602
	}
	{
		id = 0xa2283104
		zone = z_mainmenu
		ie = 'ad_mainmenu_ad2_512x256'
		type = image
		width = 512
		height = 256
		texdict = `pak/menu_ad_tex/menu_ad_tex.tex`
		texturename = 'ad_mainmenu_ad2_pic_512x256'
		texturechecksum = 0x9c8b2436
	}
]
massive_zones = {
	z_mainmenu = {
		name = 'Sample Zone'
		texdict = 0x73a976e7
	}
	z_mexicocity = {
		name = 'z_mexicocity'
		texdict = `zones/z_mexicocity/z_mexicocity.tex`
	}
	z_vegas = {
		name = 'z_vegas'
		texdict = `zones/z_vegas/z_vegas.tex`
	}
	z_subway = {
		name = 'z_subway'
		texdict = `zones/z_subway/z_subway.tex`
	}
	z_dublin = {
		name = 'z_dublin'
		texdict = `zones/z_dublin/z_dublin.tex`
	}
}
massive_camera_names_exclude_list = [
	moment01
	moment02
	moment03
	moment04
	moment05
	moment06
	moment07
	moment08
	moment09
	moment10
	guitarist_mocap01
	guitarist_mocap02
	bassist_mocap01
	bassist_mocap02
	singer_mocap01
	singer_mocap02
	drummer_mocap01
	drummer_mocap02
]
g_dynamic_ad_started_called = 0
g_dynamic_ad_started = 0x00000000
g_dynamic_ad_ok_for_ad_override = 0
disable_ad_manager = 0
dynamicaddebugoverlay_container_pos = (50.0, 30.0)
dynamicaddebugoverlay_backgroundsize = (1180.0, 660.0)
dynamicaddebugoverlay_text_font = fontgrid_text_a1
dynamicaddebugoverlay_text_color1 = [
	255
	255
	255
	255
]
dynamicaddebugoverlay_text_color2 = [
	255
	255
	255
	255
]
dynamicaddebugoverlay_text_scale1 = (0.7, 0.7)
dynamicaddebugoverlay_text_scale2 = (0.5, 0.5)
dynamicaddebugoverlay_just = [
	left
	top
]

script 0x3501c707 
	if NOT gotparam \{id}
		return \{false}
	endif
	getarraysize \{$0xf583e6f5}
	if (<array_size> > 0)
		index = 0
		begin
		item = ($0xf583e6f5 [<index>])
		if ((<item>.id) = <id>)
			return true item = (<item>)
		endif
		index = (<index> + 1)
		repeat <array_size>
	endif
	return \{false}
endscript

script 0x1ac177ec 
	spawnscriptnow dynamic_ad_start params = {mode = menu zone = ($0x9d6acbe9)}
endscript

script 0xa090dd3d 
	dynamicadmanagercommand \{func = trace
		msg = 'dynamic_ad_mainmenu_watchdog_callback : Called'}
	dynamicadmanagercommand \{func = destroyallwatchdogs}
	pos = (700.0, 16.0)
	getarraysize <ids>
	if (<array_size> > 0)
		index = 0
		begin
		item_id = (<ids> [<index>])
		if 0x3501c707 id = (<item_id>)
			scale = 1.0
			if ((<item>.width) <= 128.0)
				scale = 0.5
			endif
			tempwidth = ((<item>.width) / <scale>)
			tempheight = ((<item>.height) / <scale>)
			tempid = (<item>.id)
			dims = (((<tempwidth>) * (1.0, 0.0)) + ((<tempheight>) * (0.0, 1.0)))
			createscreenelement {
				type = dynamicadspriteelement
				parent = root_window
				id = <tempid>
				texture = (<item>.texturechecksum)
				dims = <dims>
				pos = <pos>
				scale = (1.0, 1.0)
				just = [left , top]
				rgba = [255 255 255 255]
				alpha = 1.0
				z_priority = 10005
				dynamicadmenuobjectid = (<item>.id)
				destroyelementifmenuobjectdestroyed
			}
			dims = (((0) * (1.0, 0.0)) + ((<tempheight>) * (0.0, 1.0)))
			pos = (<pos> + <dims>)
			dims = (((0) * (1.0, 0.0)) + ((16) * (0.0, 1.0)))
			pos = (<pos> + <dims>)
		endif
		index = (<index> + 1)
		repeat <array_size>
	endif
endscript

script dynamic_ad_enter_menu 
	dynamicadmanagercommand \{func = trace
		msg = 'dynamic_ad_enter_menu : Called'}
	dynamicadmanagercommand \{func = destroyallmenuobjects}
	if NOT gotparam \{zone}
		return
	endif
	idlist = []
	getarraysize \{$0xf583e6f5}
	if (<array_size> > 0)
		index = 0
		begin
		item = ($0xf583e6f5 [<index>])
		if ((<item>.zone) = <zone>)
			dynamicadmanagercommand func = createmenuobject id = (<item>.id) zone = (<item>.zone) ie = (<item>.ie) type = (<item>.type) width = (<item>.width) height = (<item>.height) texdict = (<item>.texdict) texturename = (<item>.texturename) texturechecksum = (<item>.texturechecksum)
			addarrayelement array = <idlist> element = (<item>.id)
			<idlist> = <array>
		endif
		index = (<index> + 1)
		repeat <array_size>
	endif
	dynamicadmanagercommand func = createwatchdog id = 0x22dd413b qscriptcallback = 0xa090dd3d ids = <idlist>
	dynamicadmanagercommand \{func = debugmarkallassetsdownloadedforwatchdog
		id = 0x22dd413b
		value = 1}
	dynamicadmanagercommand \{func = pumpallwatchdogs}
	dynamicadmanagercommand \{func = trace
		msg = 'dynamic_ad_enter_menu : Done'}
endscript

script 0x61ada606 
	dynamicadmanagercommand \{func = trace
		msg = 'dynamic_ad_leave_mainmenu : Called'}
	dynamicadmanagercommand \{func = destroyallmenuobjects}
	dynamicadmanagercommand \{func = trace
		msg = 'dynamic_ad_leave_mainmenu : Done'}
endscript

script dynamic_ad_get_current_camera_name_checksum 
	current_camera_name_checksum = nullchecksum
	if NOT ($cameracuts_init = true)
	else
		if getarraysize ($cameracuts_lastarray) noassert = 1
			index = ($cameracuts_lastindex)
			if (<index> < 0)
			elseif (<index> >= <array_size>)
			else
				if structurecontains structure = (($cameracuts_lastarray) [<index>]) name
					current_camera_name_checksum = ($cameracuts_lastarray [<index>].name)
				else
					if structurecontains structure = (($cameracuts_lastarray) [<index>]) params
						if structurecontains structure = (($cameracuts_lastarray) [<index>].params) name
							current_camera_name_checksum = ($cameracuts_lastarray [<index>].params.name)
						endif
					endif
				endif
			endif
		endif
	endif
	if (current_camera_name_checksum = nullchecksum)
		return \{false
			current_camera_name_checksum = nullchecksum}
	endif
	return true current_camera_name_checksum = <current_camera_name_checksum>
endscript

script ok_for_ad_on 
	change \{g_dynamic_ad_ok_for_ad_override = 1}
endscript

script ok_for_ad_off 
	change \{g_dynamic_ad_ok_for_ad_override = 0}
endscript

script dynamic_ad_find_out_if_camera_ok_for_ad_flag 
	requireparams \{[
			camera_name_checksum
		]
		all}
	if ($g_dynamic_ad_ok_for_ad_override != 0)
		return \{true}
	endif
	if (<camera_name_checksum> = nullchecksum)
		return \{true}
	endif
	getarraysize \{$massive_camera_names_exclude_list}
	num_camera_names = <array_size>
	if (<num_camera_names> <= 0)
		return \{true}
	endif
	index = 0
	begin
	camera_name_checksum2 = ($massive_camera_names_exclude_list [<index>])
	if (<camera_name_checksum> = <camera_name_checksum2>)
		return \{false}
	endif
	index = (<index> + 1)
	repeat <num_camera_names>
	return \{true}
endscript

script dynamic_ad_update_camera_ok_for_ad_flag 
	dynamic_ad_get_current_camera_name_checksum
	if dynamic_ad_find_out_if_camera_ok_for_ad_flag camera_name_checksum = <current_camera_name_checksum>
		setcurrentviewportcameraokforad \{ok_for_ad = 1}
	else
		setcurrentviewportcameraokforad \{ok_for_ad = 0}
	endif
endscript

script should_we_record_dynamic_ads_for_this_song 
	if (disable_ad_manager != 0)
		return \{false}
	endif
	printf \{qs(0x30ee78f4)}
	gamemode_gettype
	if (<type> = freeplay)
		printf \{qs(0x4f04688e)}
		return \{false}
	endif
	printf \{qs(0x5a72e97d)
		s = $current_level}
	if NOT structurecontains \{structure = $levelzones
			$current_level}
		printf \{qs(0x2535433a)}
		return \{false}
	endif
	getnumplayersingame \{on_screen
		out = num_players}
	if (<num_players> <= 0)
		printf \{qs(0x8d9a9fcb)}
		return \{false}
	endif
	getnumplayersingame \{remote
		out = num_remote_players}
	if (<num_remote_players> > 0)
		printf \{qs(0x8103ad48)}
		return \{false}
	endif
	numhighways = 0
	numvocalists = 0
	getfirstplayer \{on_screen
		out = player}
	begin
	getplayerinfo <player> part
	if ((<part> = drum) || (<part> = guitar) || (<part> = bass))
		numhighways = (<numhighways> + 1)
	elseif (<part> = vocals)
		numvocalists = (<numvocalists> + 1)
	endif
	getnextplayer player = <player> on_screen out = player
	repeat <num_players>
	printstruct <...>
	if (<numhighways> > 1)
		printf \{qs(0x6fe667a9)}
		return \{false}
	elseif (<numhighways> = 1)
	else
		if (<numvocalists> > 1)
			printf \{qs(0x69853d0f)}
			return \{false}
		endif
	endif
	printf \{qs(0xc7cddf56)}
	return \{true}
endscript

script dynamic_ad_get_current_venue_zone_checksum 
	zonechecksum = (($levelzones.$current_level).zone)
	return zone = <zonechecksum>
endscript

script dynamic_ad_start 
	if NOT gotparam \{mode}
		<mode> = venue
	endif
	if NOT gotparam \{zone}
		dynamic_ad_get_current_venue_zone_checksum
	endif
	formattext textname = msgtext 'dynamic_ad_start : Called.  mode=%a zone=%b' a = <mode> b = <zone> dontassertforchecksums
	dynamicadmanagercommand func = trace msg = <msgtext>
	if (<mode> = venue)
		dynamic_ad_stop
		if should_we_record_dynamic_ads_for_this_song
			printf qs(0xf65920b1) s = <zone>
			dynamicadmanagercommand \{func = issuecue
				cue = connect}
			wait \{2
				frames}
			dynamicadmanagercommand func = enterzone zone = <zone>
			change \{g_dynamic_ad_started = venue}
		else
			dynamicadmanagercommand \{func = leavezone}
		endif
		change \{g_dynamic_ad_started_called = 1}
	elseif (<mode> = menu)
		dynamic_ad_stop
		dynamicadmanagercommand \{func = issuecue
			cue = connect}
		wait \{2
			frames}
		dynamic_ad_enter_menu zone = <zone>
		dynamicadmanagercommand func = enterzone zone = ($0x9d6acbe9)
		change \{g_dynamic_ad_started = menu}
		change \{g_dynamic_ad_started_called = 1}
	else
	endif
endscript

script dynamic_ad_stop 
	if ($g_dynamic_ad_started = venue)
		dynamicadmanagercommand \{func = issuecue
			cue = disconnect}
		wait \{2
			frames}
		change \{g_dynamic_ad_started_called = 0}
		change \{g_dynamic_ad_started = 0x00000000}
	elseif ($g_dynamic_ad_started = menu)
		0x61ada606
		dynamicadmanagercommand \{func = issuecue
			cue = disconnect}
		wait \{2
			frames}
		change \{g_dynamic_ad_started_called = 0}
		change \{g_dynamic_ad_started = 0x00000000}
	endif
endscript

script dynamic_ad_reset 
	if ($g_dynamic_ad_started != 0x00000000)
		tempmode = $g_dynamic_ad_started
		tempzone = $g_dynamic_ad_zone
		dynamic_ad_stop
		dynamic_ad_start mode = (<tempmode>) zone = (<tempzone>)
	endif
endscript

script dynamicaddebugoverlay 
	spawnscript \{dynamicaddebugoverlay_create}
endscript

script flushalldebugimpressioncounters 
	dynamicadmanagercommand \{func = flushalldebugimpressioncounters}
endscript

script dynamicaddebugoverlay_create 
	dynamicaddebugoverlay_destroy
	createscreenelement \{type = containerelement
		parent = root_window
		pos = $dynamicaddebugoverlay_container_pos
		just = $dynamicaddebugoverlay_just
		id = dynamicaddebugoverlay_root_id}
	createscreenelement \{type = spriteelement
		parent = dynamicaddebugoverlay_root_id
		texture = white
		dims = (1180.0, 660.0)
		rgba = [
			0
			0
			0
			0
		]
		pos = (590.0, 30.0)
		z_priority = 10000
		id = dynamicaddebugoverlay_background_id}
	createscreenelement \{type = textelement
		parent = dynamicaddebugoverlay_root_id
		font = $dynamicaddebugoverlay_text_font
		text = qs(0x00000000)
		scale = $dynamicaddebugoverlay_text_scale2
		just = $dynamicaddebugoverlay_just
		pos = (0.0, 10.0)
		dims = (1180.0, 660.0)
		z_priority = 10001
		rgba = $dynamicaddebugoverlay_text_color2
		id = dynamicaddebugoverlay_text1_id
		single_line = false}
	runscriptonscreenelement \{id = dynamicaddebugoverlay_root_id
		dynamicaddebugoverlay_task}
endscript

script dynamicaddebugoverlay_destroy 
	if screenelementexists \{id = dynamicaddebugoverlay_root_id}
		destroyscreenelement \{id = dynamicaddebugoverlay_root_id}
	endif
endscript

script dynamicaddebugoverlay_loop 
	begin
	if screenelementexists \{id = dynamicaddebugoverlay_root_id}
		dynamicaddebugoverlay_root_id :se_setprops \{alpha = 1.0
			time = 0.5}
		dynamic_ad_get_current_camera_name_checksum
		if dynamicadmanagercommand func = getdebugoverlayinfo camera_name_checksum = <current_camera_name_checksum>
		else
			<text> = qs(0x00000000)
		endif
		if NOT gotparam \{text}
			<text> = qs(0x00000000)
		endif
		if screenelementexists \{id = dynamicaddebugoverlay_text1_id}
			dynamicaddebugoverlay_text1_id :se_setprops text = <text>
		endif
	endif
	wait \{0.05
		seconds}
	repeat
endscript

script dynamicaddebugoverlay_task 
	dynamicaddebugoverlay_loop
	dynamicaddebugoverlay_destroy
endscript
