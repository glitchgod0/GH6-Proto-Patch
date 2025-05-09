
script attempt_to_add_friend_feed \{parent_id = root_window
		menu = !q1768515945}
	printf \{channel = ff
		qs(0xd5461f01)}
	controller_index = -1
	switch <menu>
		case band_lobby
		begin
		if (-1 != $g_leader_player_num)
			getplayerinfo ($g_leader_player_num) controller out = controller_index
			break
		endif
		wait \{1
			second}
		repeat
		case songlist
		if gotparam \{songlist_mode}
			if (leaderboard = <songlist_mode>
					|| practice = <songlist_mode>
					|| music_store = <songlist_mode>
					|| play_song = <songlist_mode>
					|| playlist = <songlist_mode>
				)
				if ($primary_controller_assigned = 0)
					<controller_index> = ($primary_controller)
				else
					<controller_index> = -1
				endif
			else
				getplayerinfo ($g_leader_player_num) controller
				<controller_index> = <controller>
			endif
		else
			<controller_index> = -1
		endif
		case main
		controller_index = ($primary_controller)
		case freeplay
		if ($primary_controller_assigned = 0)
			controller_index = ($primary_controller)
		else
			max_controllers = 4
			controller_index = 0
			0x04936f26 = 0
			begin
			if checkforsignin controller_index = <controller_index>
				0x04936f26 = 1
				break
			endif
			controller_index = (<controller_index> + 1)
			repeat <max_controllers>
			if (0 = <0x04936f26>)
				controller_index = -1
			endif
		endif
	endswitch
	if (-1 != <controller_index>)
		printf \{channel = ff
			qs(0x2f529583)}
		if checkforsignin controller_index = <controller_index>
			printf \{channel = ff
				qs(0x29ac0fbb)}
			create_friend_feed parent_id = <parent_id> menu = <menu> controller_index = <controller_index> event_handler = <event_handler>
		endif
	endif
endscript

script create_friend_feed \{parent_id = !q1768515945
		menu = !q1768515945
		controller_index = !i1768515945}
	if screenelementexists id = <parent_id>
		if screenelementexists \{id = friends_feed_desc_id}
			destroyscreenelement \{id = friends_feed_desc_id}
		endif
		createscreenelement {
			parent = <parent_id>
			id = friends_feed_desc_id
			type = descinterface
			desc = 'friend_feed'
			autosizedims = true
			tags = {
				menu = <menu>
			}
		}
		friends_feed_desc_id :obj_spawnscriptnow \{ff_cleanup_spawned}
		pos = (0.0, 0.0)
		z_priority = 0.0
		pos = ($friend_feed_menu_data.<menu>.pos)
		z_priority = ($friend_feed_menu_data.<menu>.z_priority)
		friends_feed_desc_id :se_setprops pos = <pos> alpha = 0.0 z_priority = <z_priority>
		if friends_feed_desc_id :desc_resolvealias \{name = alias_friend_feed_vmenu
				param = friend_feed_vmenu_id}
			handlers = [{pad_back 0x9f80e0af}]
			<friend_feed_vmenu_id> :settags view_index = 0 state = idle 0x94a921b3 = 0
			<friend_feed_vmenu_id> :se_setprops pos = (0.0, -97.0) event_handlers = <handlers>
			<friend_feed_vmenu_id> :obj_spawnscriptlater ff_scroll_feed_items
			<friend_feed_vmenu_id> :obj_spawnscriptlater 0xbcdaa185
		endif
		0x1052c0ef controller_index = <controller_index>
		0x5fa741e4 controller_index = <controller_index>
		change \{0x621f73c3 = 1}
		if (1 = ($friend_feed_menu_data.<menu>.interactive))
			if gotparam \{event_handler}
				<friend_feed_vmenu_id> :settags return_menu = <event_handler>
				<event_handler> :se_setprops {
					event_handlers = [
						{($friend_feed_menu_data.<menu>.pad_handler) ff_attempt_to_expand_feed params = {}}
					]
				}
			endif
		endif
		friends_feed_desc_id :se_setprops \{alpha = 1.0}
	endif
endscript

script ff_cleanup_spawned 
	onexitrun \{ff_cleanup}
	block \{type = ff_cleanup}
endscript

script ff_cleanup 
	netfeeddebugoverlay_destroy
endscript

script ff_clear_mini_feed_items 
	if screenelementexists \{id = friends_feed_desc_id}
		if friends_feed_desc_id :desc_resolvealias \{name = alias_friend_feed_vmenu
				param = friend_feed_vmenu_id}
			destroyscreenelement id = <friend_feed_vmenu_id> preserve_parent
			<friend_feed_vmenu_id> :obj_killspawnedscript name = ff_scroll_feed_items
			handlers = [{pad_back 0x9f80e0af}]
			<friend_feed_vmenu_id> :settags view_index = 0 state = idle 0x94a921b3 = 0
			<friend_feed_vmenu_id> :se_setprops pos = (0.0, -97.0) event_handlers = <handlers>
			<friend_feed_vmenu_id> :obj_spawnscriptnow ff_scroll_feed_items
		endif
	endif
endscript

script ff_attempt_to_expand_feed \{device_num = !i1768515945}
	if (-1 != <device_num>)
		if checkforsignin controller_index = <device_num>
			ff_expand_feed controller_index = <device_num>
		else
			printf \{qs(0x5bc2d488)}
		endif
	endif
endscript

script ff_expand_feed \{controller_index = !i1768515945}
	if screenelementexists \{id = friends_feed_desc_id}
		if friends_feed_desc_id :desc_resolvealias \{name = alias_friend_feed_vmenu
				param = friend_feed_vmenu_id}
			obj_getid
			launchevent type = unfocus target = <objid>
			ff_setup_expanded_view controller_index = <controller_index>
			<friend_feed_vmenu_id> :obj_killspawnedscript name = 0xbcdaa185
			<friend_feed_vmenu_id> :obj_spawnscriptnow 0xb76ad2f7
			friends_feed_desc_id :getsingletag \{menu}
			<anim> = ($friend_feed_menu_data.<menu>.expand_anim)
			getarraysize ($g_friend_feed_anims.<anim>) param = anim_steps
			if (<anim_steps> > 0)
				<anim_index> = 0
				begin
				friends_feed_desc_id :se_getprops
				friends_feed_desc_id :se_setprops {
					pos = ((($g_friend_feed_anims.<anim> [<anim_index>]).pos) + <pos>)
					time = (($g_friend_feed_anims.<anim> [<anim_index>]).time)
					motion = (($g_friend_feed_anims.<anim> [<anim_index>]).motion)
				}
				friends_feed_desc_id :se_waitprops
				<anim_index> = (1 + <anim_index>)
				repeat <anim_steps>
			endif
			clean_up_user_control_helpers
			friends_feed_desc_id :se_getprops
			friends_feed_desc_id :se_setprops {
				gamertag_cont_pos = ((0.0, -32.0) + <gamertag_cont_pos>)
				0x247e1e74 = ((0.0, 45.0) + <0x247e1e74>)
				0x9bae8ebe = (-1.0, -45.0)
				0xb77c9c58 = (625.0, 0.0)
				motion = ease_in
				time = 0.1
			}
			friends_feed_desc_id :se_waitprops
			friends_feed_desc_id :se_getprops
			friends_feed_desc_id :se_setprops {
				0x0113c131 = (1.0, 4.9)
				gamertag_cont_pos = ((0.0, -392.0) + <gamertag_cont_pos>)
				0x2799bb6b = ((0.0, -392.0) + <0x2799bb6b>)
				0x247e1e74 = ((0.0, 5.0) + <0x247e1e74>)
				0x9bae8ebe = (-1.0, -363.0)
				0xb77c9c58 = (625.0, 420.0)
				motion = ease_in
				time = 0.2
			}
			friends_feed_desc_id :se_waitprops
			friends_feed_desc_id :se_getprops
			friends_feed_desc_id :se_setprops {
				0x0113c131 = (1.0, 4.75)
				gamertag_cont_pos = ((0.0, 10.0) + <gamertag_cont_pos>)
				0x2799bb6b = ((0.0, 10.0) + <0x2799bb6b>)
				0x247e1e74 = ((0.0, -5.0) + <0x247e1e74>)
				0x1cfc8248 = (475.0, 475.0)
				scroll_bar_alpha = 1
				time = 0.2
			}
			friends_feed_desc_id :se_waitprops
		endif
	endif
endscript

script 0x9f80e0af 
	if screenelementexists \{id = friends_feed_desc_id}
		obj_getid
		<objid> :getsingletag return_menu
		if screenelementexists id = <return_menu>
			launchevent type = unfocus target = <objid>
			friends_feed_desc_id :se_getprops
			friends_feed_desc_id :se_setprops \{0x9bae8ebe = (-1.0, -45.0)
				0xb77c9c58 = (625.0, 0.0)}
			friends_feed_desc_id :se_waitprops
			friends_feed_desc_id :se_getprops
			friends_feed_desc_id :se_setprops {
				0x0113c131 = (1.0, 4.9)
				gamertag_cont_pos = ((0.0, -15.0) + <gamertag_cont_pos>)
				0x247e1e74 = ((0.0, 5.0) + <0x247e1e74>)
				0x2799bb6b = ((0.0, -15.0) + <0x2799bb6b>)
				0x1cfc8248 = (475.0, 60.0)
				scroll_bar_alpha = 0.0
			}
			friends_feed_desc_id :se_waitprops
			friends_feed_desc_id :se_getprops
			friends_feed_desc_id :se_setprops {
				0x0113c131 = (1.0, 1.0)
				gamertag_cont_pos = ((0.0, 392.0) + <gamertag_cont_pos>)
				0x247e1e74 = ((0.0, -5.0) + <0x247e1e74>)
				0x2799bb6b = ((0.0, 392.0) + <0x2799bb6b>)
				motion = ease_in
				time = 0.2
			}
			friends_feed_desc_id :se_waitprops
			friends_feed_desc_id :se_getprops
			friends_feed_desc_id :se_setprops {
				gamertag_cont_pos = ((0.0, 32.0) + <gamertag_cont_pos>)
				0x247e1e74 = ((0.0, -45.0) + <0x247e1e74>)
				motion = ease_in
				time = 0.1
			}
			friends_feed_desc_id :se_waitprops
			friends_feed_desc_id :getsingletag \{menu}
			<anim> = ($friend_feed_menu_data.<menu>.expand_anim)
			getarraysize ($g_friend_feed_anims.<anim>) param = anim_steps
			if (<anim_steps> > 0)
				<anim_index> = 0
				begin
				friends_feed_desc_id :se_getprops
				friends_feed_desc_id :se_setprops {
					pos = ((-1) * (($g_friend_feed_anims.<anim> [<anim_index>]).pos) + <pos>)
					time = (($g_friend_feed_anims.<anim> [<anim_index>]).time)
					motion = (($g_friend_feed_anims.<anim> [<anim_index>]).motion)
				}
				friends_feed_desc_id :se_waitprops
				<anim_index> = (1 + <anim_index>)
				repeat <anim_steps>
			endif
			if friends_feed_desc_id :desc_resolvealias \{name = alias_friend_feed_vmenu
					param = friend_feed_vmenu_id}
				<friend_feed_vmenu_id> :obj_spawnscriptlater ff_scroll_feed_items
				<friend_feed_vmenu_id> :obj_spawnscriptlater 0xbcdaa185
			endif
			add_user_control_helper \{text = qs(0xc18d5e76)
				button = green
				z = 100
				all_buttons}
			add_user_control_helper \{text = qs(0x8a778398)
				button = yellow
				z = 100
				all_buttons}
			add_user_control_helper \{text = qs(0xcc6e981d)
				button = blue
				z = 100
				all_buttons}
			launchevent type = focus target = <return_menu>
		endif
	endif
endscript

script 0xb540620a \{feed_data = 0x69696969}
	printf \{channel = friend_feed
		qs(0x10433f5b)}
	addarrayelement array = ($0x968bb042) element = <feed_data>
	change 0x968bb042 = <array>
endscript

script 0xbcdaa185 
	onexitrun \{0x127a2c8e}
	obj_getid
	begin
	gettags
	if (idle = <state> && -1 < <view_index>)
		getarraysize ($0x968bb042)
		if (<array_size> > 0)
			0x36976d73 ($0x968bb042 [0])
			if (0 = <fail>)
				removearrayelement array = ($0x968bb042) index = 0
				change 0x968bb042 = <array>
				settags 0x94a921b3 = (<0x94a921b3> + 1)
			endif
		endif
	endif
	gettags
	if ($friend_feed_menu_data.0x89b65daf <= <0x94a921b3>)
		change \{0x621f73c3 = 0}
		settags \{0x94a921b3 = 0}
	endif
	wait \{1
		gameframe}
	repeat
endscript

script 0x127a2c8e 
	change \{0x968bb042 = [
		]}
endscript

script ff_scroll_feed_items 
	obj_getid
	begin
	settags \{state = idle}
	wait ($friend_feed_menu_data.scroll_time) seconds
	if getscreenelementchildren id = <objid>
		getarraysize <children> param = num_ff_items
		num_ff_items = (<num_ff_items> - 1)
		if (($friend_feed_menu_data.0x89b65daf) = <num_ff_items>)
			ff_index = 0
			num_items_displayed = 0
			begin
			(<children> [<ff_index>]) :gettags
			if (0 < <mini_feed_display_count>)
				num_items_displayed = (1 + <num_items_displayed>)
			endif
			<ff_index> = (1 + <ff_index>)
			repeat <num_ff_items>
			if (<num_items_displayed> = <num_ff_items>)
				change \{0x621f73c3 = 1}
			endif
		endif
		if ($friend_feed_menu_data.mini_feed_num_items_to_scroll <= <num_ff_items>)
			getsingletag \{view_index}
			settags \{state = animating}
			if (<num_ff_items> > <view_index>)
				getarraysize ($g_friend_feed_anims.scroll_anim) param = anim_steps
				if (<anim_steps> > 0)
					<anim_index> = 0
					begin
					se_getprops
					se_setprops {
						pos = ((($g_friend_feed_anims.scroll_anim [<anim_index>]).pos) + <pos>)
						time = (($g_friend_feed_anims.scroll_anim [<anim_index>]).time)
						motion = (($g_friend_feed_anims.scroll_anim [<anim_index>]).motion)
					}
					se_waitprops
					<anim_index> = (1 + <anim_index>)
					repeat <anim_steps>
				endif
				if (-1 < <view_index>)
					(<children> [<view_index>]) :getsingletag mini_feed_display_count
					(<children> [<view_index>]) :settags mini_feed_display_count = (<mini_feed_display_count> + 1)
				endif
				settags view_index = (<view_index> + 1)
			endif
			getsingletag \{view_index}
			if (<num_ff_items> = (<view_index> + 1))
				se_setprops \{pos = (0.0, 0.0)}
				(<children> [<view_index>]) :getsingletag mini_feed_display_count
				(<children> [<view_index>]) :settags mini_feed_display_count = (<mini_feed_display_count> + 1)
				settags \{view_index = -1}
			endif
		endif
	endif
	repeat
endscript

script 0x36976d73 \{feed_string = qs(0xaf3e73b9)}
	printf \{channel = friend_feed
		qs(0x2998bf79)}
	fail = 0
	if screenelementexists \{id = friends_feed_desc_id}
		if friends_feed_desc_id :desc_resolvealias \{name = alias_friend_feed_vmenu
				param = friend_feed_vmenu_id}
			<0xbf3bbba4> = 0
			if getscreenelementchildren id = <friend_feed_vmenu_id>
				getarraysize <children> param = num_ff_items
				num_ff_items = (<num_ff_items> - 1)
				if (($friend_feed_menu_data.0x89b65daf) = <num_ff_items>)
					ff_index = 1
					0xd1562846 = -1
					0xd4fc0b25 = 0
					begin
					(<children> [<ff_index>]) :getsingletag mini_feed_display_count
					if (<0xd1562846> < <mini_feed_display_count>)
						<0xd1562846> = <mini_feed_display_count>
						<0xd4fc0b25> = <ff_index>
					endif
					<ff_index> = (1 + <ff_index>)
					repeat <num_ff_items>
					<friend_feed_vmenu_id> :getsingletag view_index
					if ((<view_index> != <0xd4fc0b25> || 0 != <0xd4fc0b25>)
							&& 0 != <0xd4fc0b25>)
						if (($friend_feed_menu_data.0x89b65daf) != <0xd4fc0b25>)
							<0xbf3bbba4> = 0
						else
							destroyscreenelement id = (<children> [($friend_feed_menu_data.0x89b65daf)])
							<0xbf3bbba4> = 1
						endif
					else
						fail = 1
					endif
				else
					<0xbf3bbba4> = 1
				endif
			else
				<0xbf3bbba4> = 1
			endif
			if (0 = <0xbf3bbba4>)
				destroyscreenelement id = (<children> [<0xd4fc0b25>])
			else
				if gotparam \{children}
					destroyscreenelement id = (<children> [0])
				endif
			endif
			createscreenelement {
				type = descinterface
				desc = 'friend_feed_item'
				parent = <friend_feed_vmenu_id>
				autosizedims = true
				message_text = <feed_string>
				event_handlers = [
					{focus ff_change_item_focus params = {focus_type = focus}}
					{unfocus ff_change_item_focus params = {focus_type = unfocus}}
				]
				tags = {
					msg_type = <msg_type>
					mini_feed_display_count = 0
				}
			}
			if (0 = <0xbf3bbba4>)
				<friend_feed_vmenu_id> :menu_setitemindex id = <id> newindex = <0xd4fc0b25>
			else
				createscreenelement {
					type = descinterface
					desc = 'friend_feed_item'
					parent = <friend_feed_vmenu_id>
					autosizedims = true
					message_text = <feed_string>
					not_focusable
					tags = {
						mini_feed_display_count = 1
					}
				}
				<friend_feed_vmenu_id> :menu_setitemindex id = <id> newindex = 0
			endif
		else
			fail = 1
		endif
	else
		fail = 1
	endif
	return fail = <fail>
endscript

script ff_setup_expanded_view 
	if screenelementexists \{id = friends_feed_desc_id}
		name = qs(0xb2359d6b)
		netsessionfunc obj = match func = get_gamertag params = {controller = <controller_index>}
		friends_feed_desc_id :se_setprops gamertag_text = <name>
		if friends_feed_desc_id :desc_resolvealias \{name = 0xd29dbe72
				param = 0xb2f1f7fa}
			getnetid controller_index = <controller_index>
			array = []
			addarrayelement array = <array> element = <net_id_first>
			addarrayelement array = <array> element = <net_id_second>
			0xe77c941b name = <0xb2f1f7fa> get_small = 1 user_id = <array>
		endif
		if friends_feed_desc_id :desc_resolvealias \{name = 0x0af46c4d
				param = 0xa0f7cd36}
			destroyscreenelement id = <0xa0f7cd36> preserve_parent
			createscreenelement {
				type = textelement
				parent = <0xa0f7cd36>
				dims = (50.0, 50.0)
				internal_scale = (0.8, 0.8)
				internal_just = [center , center]
				text = qs(0x3a60bebc)
				font = fontgrid_text_a1
				autosizedims = false
			}
			createscreenelement {
				type = textelement
				parent = <0xa0f7cd36>
				dims = (50.0, 25.0)
				internal_just = [center , center]
				text = qs(0xaf4d5dd2)
				internal_scale = (0.5, 0.5)
				font = fontgrid_text_a1
				fit_width = `scale each line if larger`
				fit_height = `scale down if larger`
				autosizedims = false
			}
			createscreenelement {
				type = textelement
				parent = <0xa0f7cd36>
				dims = (50.0, 50.0)
				internal_scale = (0.8, 0.8)
				internal_just = [center , center]
				text = qs(0x114ded7f)
				font = fontgrid_text_a1
			}
			createscreenelement {
				type = textelement
				parent = <0xa0f7cd36>
				dims = (25.0, 20.0)
				internal_just = [center , center]
				text = qs(0x7acb342a)
				internal_scale = (0.5, 0.5)
				font = fontgrid_text_a1
				fit_width = `scale each line if larger`
				fit_height = `scale down if larger`
			}
		endif
	endif
endscript

script 0xb76ad2f7 
	begin
	getsingletag \{state}
	if (idle = <state>)
		obj_killspawnedscript \{name = ff_scroll_feed_items}
		break
	endif
	wait \{1
		gameframe}
	repeat
	begin
	if NOT scriptisrunning \{ff_expand_feed}
		break
	endif
	wait \{1
		gameframe}
	repeat
	obj_getid
	getsingletag \{view_index}
	if screenelementexists id = <objid>
		launchevent type = focus target = <objid> data = {child_index = (1 + <view_index>)}
	endif
endscript

script ff_change_item_focus \{focus_type = !q1768515945}
	obj_getid
	if (focus = <focus_type>)
		se_setprops \{bkgd_rgba = gh6_red_dk}
		if screenelementexists \{id = friends_feed_desc_id}
			if friends_feed_desc_id :desc_resolvealias \{name = 0x0af46c4d
					param = 0xa0f7cd36}
				destroyscreenelement id = <0xa0f7cd36> preserve_parent
				gettags
				0xd11067ad msg_type = <msg_type>
				printf \{qs(0x19c820b3)}
				printstruct <...>
				if (1 = <0xb5ea39bf>)
					createscreenelement {
						type = textelement
						parent = <0xa0f7cd36>
						dims = (50.0, 50.0)
						internal_scale = (0.8, 0.8)
						internal_just = [center , center]
						text = qs(0x237b8ffd)
						font = fontgrid_text_a1
						autosizedims = false
					}
					createscreenelement {
						type = textelement
						parent = <0xa0f7cd36>
						dims = (50.0, 25.0)
						internal_just = [center , center]
						text = <button_text>
						internal_scale = (0.5, 0.5)
						font = fontgrid_text_a1
						fit_width = `scale each line if larger`
						fit_height = `scale down if larger`
						autosizedims = false
					}
				endif
				createscreenelement {
					type = textelement
					parent = <0xa0f7cd36>
					dims = (50.0, 50.0)
					internal_scale = (0.8, 0.8)
					internal_just = [center , center]
					text = qs(0x3a60bebc)
					font = fontgrid_text_a1
					autosizedims = false
				}
				createscreenelement {
					type = textelement
					parent = <0xa0f7cd36>
					dims = (50.0, 25.0)
					internal_just = [center , center]
					text = qs(0xaf4d5dd2)
					internal_scale = (0.5, 0.5)
					font = fontgrid_text_a1
					fit_width = `scale each line if larger`
					fit_height = `scale down if larger`
					autosizedims = false
				}
				createscreenelement {
					type = textelement
					parent = <0xa0f7cd36>
					dims = (50.0, 50.0)
					internal_scale = (0.8, 0.8)
					internal_just = [center , center]
					text = qs(0x114ded7f)
					font = fontgrid_text_a1
				}
				createscreenelement {
					type = textelement
					parent = <0xa0f7cd36>
					dims = (25.0, 20.0)
					internal_just = [center , center]
					text = qs(0x7acb342a)
					internal_scale = (0.5, 0.5)
					font = fontgrid_text_a1
					fit_width = `scale each line if larger`
					fit_height = `scale down if larger`
				}
			endif
		endif
	else
		<objid> :se_setprops bkgd_rgba = [30 30 30 255]
	endif
endscript

script 0xd11067ad \{msg_type = !q1768515945}
	<0xb5ea39bf> = 1
	switch <msg_type>
		case beat_score
		case 0x59c99385
		case 0x245dec11
		case 0xf5bcb036
		case 0xf6026930
		case 0x65958817
		case 0x74753ec4
		case 0xb8aa5603
		case 0x84944e6c
		<location> = band_lobby
		<lobby_state> = quickplay
		<button_text> = qs(0xffb0c002)
		case 0x5636f414
		<location> = band_lobby
		<lobby_state> = vs
		<button_text> = qs(0xffb0c002)
		case 0x45bc8371
		case 0xc0e5376b
		case 0x9a05102e
		<location> = band_lobby
		<lobby_state> = career
		<button_text> = qs(0xffb0c002)
		case cash_milestone
		case 0x0da1d556
		case 0xcbe15a60
		case 0x2791abe0
		<location> = rock_record
		<button_text> = qs(0x78f3e2ef)
		case 0x6b4e0ec8
		case 0x12257924
		case highest_score
		<location> = leaderboards
		<button_text> = qs(0x78f3e2ef)
		case created_rocker
		case 0xf03ff1f4
		case 0x1c069af8
		<location> = car
		<button_text> = qs(0xaf9913ad)
		case 0xc9aa4357
		case 0x5884f28a
		<location> = music_store
		<button_text> = qs(0xaf9913ad)
		case 0x57dfa81d
		case 0xa798a837
		<location> = ghtunes
		<button_text> = qs(0xaf9913ad)
		case 0x20449ad2
		case 0xdc473df7
		<location> = 0x329bde07
		<button_text> = qs(0xaf9913ad)
		case 0x3ae1cd59
		<location> = vip_invite
		<button_text> = qs(0x78f3e2ef)
		default
		<location> = none
		<button_text> = qs(0x00000000)
		<0xb5ea39bf> = 0
	endswitch
	return location = <location> 0xb5ea39bf = <0xb5ea39bf> button_text = <button_text>
endscript

script 0x1052c0ef \{controller_index = !i1768515945}
	netfeed func = createsender controller_index = <controller_index>
	netfeed func = createlocalinbox controller_index = <controller_index>
endscript

script ff_wait_for_feed_ready \{controller_index = !i1768515945}
	begin
	if netfeed func = isready controller_index = <controller_index>
		netfeed \{func = logmessage
			msg = 'ff_wait_for_feed_ready: net feed is now ready.'}
		break
	endif
	wait \{1
		second}
	repeat
endscript

script ff_wait_for_inbox_ready \{controller_index = !i1768515945}
	begin
	if NOT netfeed func = islocalinboxbusy controller_index = <controller_index>
		netfeed \{func = logmessage
			msg = 'ff_wait_for_inbox_ready: local inbox no longer busy.'}
		break
	endif
	wait \{1
		gameframe}
	repeat
endscript

script 0x5fa741e4 \{controller_index = !i1768515945}
	<messagecount> = 0
	<array> = []
	ff_wait_for_feed_ready controller_index = <controller_index>
	ff_wait_for_inbox_ready controller_index = <controller_index>
	netfeed func = updatelocalinbox controller_index = <controller_index> qeventhandler = netfeedqeventhandler index = 0 numitems = 10
	ff_wait_for_inbox_ready controller_index = <controller_index>
	netfeed func = getmessagecount controller_index = <controller_index> out = messagecount
	if (0 < <messagecount>)
		if netfeed func = getmsgidfront controller_index = <controller_index> out = msgid out_first = msgid_first out_second = msgid_second
			begin
			addarrayelement array = <array> element = <msgid>
			if NOT netfeed func = getmsgidnext controller_index = <controller_index> msgid = (<msgid>) out = msgid out_first = msgid_first out_second = msgid_second
				break
			endif
			repeat
		endif
		getarraysize <array> param = num_headers
		if (0 < <num_headers>)
			<0xec28e319> = 0
			begin
			if netfeed func = fetchmessage msgid = (<array> [<0xec28e319>]) controller_index = <controller_index> qeventhandler = netfeedqeventhandler
				printf \{qs(0x063c1956)}
			endif
			<0xec28e319> = (1 + <0xec28e319>)
			repeat <num_headers>
		endif
	endif
endscript

script ff_get_source_value \{type = !q1768515945}
	<ret> = true
	switch <type>
		case encore_complete
		get_savegame_from_controller controller = <controller_index>
		getglobaltags savegame = <savegame> career_progression_tags param = current_chapter
		<value> = <current_chapter>
		case item_type
		printf \{qs(0xdff00147)}
		case instrument_type
		getplayerinfo <player> part out = value
		case song_name
		playlist_getcurrentsong
		<value> = <current_song>
		case stars_count
		quickplay_get_overall_awards_progress player = <player>
		<value> = <current_award_points_total>
		default
		<ret> = false
	endswitch
	printstruct <...>
	return <ret> value = <value>
endscript

script ff_get_song_string 
	ret = false
	if get_song_name_no_assert song = <param>
		ret = true
		addparam structure_name = return_struct name = result value = <song_name>
	else
		ret = true
		addparam \{structure_name = return_struct
			name = result
			value = qs(0xb2359d6b)}
	endif
	return <ret> <return_struct>
endscript

script 0xf8f66ed7 
	ret = false
	if get_song_name_no_assert song = <param>
		ret = true
		addparam structure_name = return_struct name = result value = <song_name>
	else
		ret = true
		addparam \{structure_name = return_struct
			name = result
			value = qs(0xb2359d6b)}
	endif
	return <ret> <return_struct>
endscript

script create_news_feed_events 
	getarraysize \{$news_feed_events
		param = num_feed_events}
	array_entry = 0
	if (0 < <num_feed_events>)
		begin
		<event> = ($news_feed_events [<array_entry>].event)
		<scr> = ($news_feed_events [<array_entry>].scr)
		seteventhandler response = call_script event = <event> scr = <scr> params = {}
		array_entry = (<array_entry> + 1)
		repeat <num_feed_events>
	endif
	block
endscript

script feed_event_cheated 
	printf \{qs(0xe003e856)}
	printstruct <...>
	netfeed func = createsender controller_index = ($primary_controller)
	if netfeed \{func = gettitleid
			out = title_id}
		if friend_feed_get_message_structure titleid = <title_id> event = cheated msg_type = `default` controller_index = <controller_index> player = <player> out_param = msg_pak
			if netfeed func = isoktosend controller_index = ($primary_controller)
				msg = {event = cheated <msg_pak>}
				if NOT netfeed func = sendmessage controller_index = ($primary_controller) qeventhandler = netfeedqeventhandler sendto = myfriends msg = <msg>
					printf \{qs(0x90b0776a)}
				endif
			else
				printf \{qs(0x87bee461)}
			endif
		else
			printf \{qs(0x1dcf5125)}
		endif
	else
		printf \{qs(0xa034a921)}
	endif
endscript

script feed_event_created_rocker 
	printf \{qs(0x760fc908)}
	printstruct <...>
	netfeed func = createsender controller_index = ($primary_controller)
	if netfeed \{func = gettitleid
			out = title_id}
		if friend_feed_get_message_structure titleid = <title_id> event = created_rocker msg_type = `default` controller_index = <controller_index> player = <player> out_param = msg_pak
			if netfeed func = isoktosend controller_index = ($primary_controller)
				msg = {event = created_rocker <msg_pak>}
				if NOT netfeed func = sendmessage controller_index = ($primary_controller) qeventhandler = netfeedqeventhandler sendto = myfriends msg = <msg>
					printf \{qs(0x90b0776a)}
				endif
			else
				printf \{qs(0x87bee461)}
			endif
		else
			printf \{qs(0x1dcf5125)}
		endif
	else
		printf \{qs(0xa034a921)}
	endif
endscript

script feed_event_completed_encore 
	printf \{qs(0xf8d92c6c)}
	printstruct <...>
	netfeed func = createsender controller_index = ($primary_controller)
	if netfeed \{func = gettitleid
			out = title_id}
		if friend_feed_get_message_structure titleid = <title_id> event = encore_complete msg_type = `default` controller_index = <controller_index> player = <player> out_param = msg_pak
			if netfeed func = isoktosend controller_index = ($primary_controller)
				msg = {event = encore_complete <msg_pak>}
				if NOT netfeed func = sendmessage controller_index = ($primary_controller) qeventhandler = netfeedqeventhandler sendto = myfriends msg = <msg>
					printf \{qs(0x90b0776a)}
				endif
			else
				printf \{qs(0x87bee461)}
			endif
		else
			printf \{qs(0x1dcf5125)}
		endif
	else
		printf \{qs(0xa034a921)}
	endif
endscript

script feed_event_unlock_item_type 
	printf \{qs(0x69ca2032)}
	printstruct <...>
	if gotparam \{item_type}
		netfeed func = createsender controller_index = ($primary_controller)
		if netfeed \{func = gettitleid
				out = title_id}
			if friend_feed_get_message_structure titleid = <title_id> event = unlock_item_type msg_type = `default` controller_index = <controller_index> player = <player> out_param = msg_pak item_type = <item_type>
				if netfeed func = isoktosend controller_index = ($primary_controller)
					msg = {event = unlock_item_type <msg_pak>}
					if NOT netfeed func = sendmessage controller_index = ($primary_controller) qeventhandler = netfeedqeventhandler sendto = myfriends msg = <msg>
						printf \{qs(0x90b0776a)}
					endif
				else
					printf \{qs(0x87bee461)}
				endif
			else
				printf \{qs(0x1dcf5125)}
			endif
		else
			printf \{qs(0xa034a921)}
		endif
	endif
endscript

script 0xa4356b07 \{controller_index = !i1768515945}
	getarraysize ($0x24f2a572) param = 0xdcf59f63
	getrandomvalue name = message_index integer a = 0 b = (<0xdcf59f63> - 1)
	msg = {msg_type = ($0x24f2a572 [<message_index>])}
	if netfeed func = isoktosend controller_index = <controller_index>
		if NOT netfeed func = sendmessage controller_index = <controller_index> qeventhandler = netfeedqeventhandler sendto = myself msg = <msg>
			printf \{qs(0x90b0776a)}
		endif
	endif
endscript

script 0xecb03b87 
	getarraysize ($0x24f2a572) param = 0xdcf59f63
	begin
	if (1 = $0x621f73c3)
		getrandomvalue name = message_index integer a = 0 b = (<0xdcf59f63> - 1)
		0xb540620a msg_type = ($0x24f2a572 [<message_index>])
	endif
	wait \{1
		second}
	repeat
endscript
