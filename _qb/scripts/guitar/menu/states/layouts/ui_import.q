
script ui_create_import 
	audio_ui_menu_music_on
	if NOT import_check_signin_state
		import_setup_failed fail_text = <fail_text>
		return
	endif
	if NOT netsessionfunc obj = content_unlock func = get_content_list params = {controller_index = ($primary_controller)}
		scriptassert \{'ui_create_import was reached without download_content_list being completed!'}
	endif
	if NOT gotparam \{content_keys}
		scriptassert \{'get_content_list succeeded but did not return content_keys, something is very wrong.'}
	endif
	if NOT globalexists \{name = downloaded_offerings}
		scriptassert \{qs(0x7b5a8404)}
	endif
	getterritory
	if (<territory> != territory_us)
		<esrb_notice_alpha> = 0.0
	else
		<esrb_notice_alpha> = 1.0
	endif
	createscreenelement {
		type = descinterface
		desc = 'music_store'
		id = songlist
		parent = root_window
		songlist_subheader_cont_alpha = 0.0
		music_store_title_alpha = 0.0
		songlist_title_text_alpha = 1.0
		songlist_title_text_text = qs(0x637c4479)
		songlist_sticky_header_alpha = 1.0
		exclusive_device = $primary_controller
		0x5bd0df53 = (925.0, 64.0)
		songlist_window_dims = (925.0, 380.0)
		esrb_notice_alpha = <esrb_notice_alpha>
	}
	if songlist :desc_resolvealias \{name = alias_songlist_vmenu}
		assignalias id = <resolved_id> alias = current_menu
		current_menu :se_setprops \{event_handlers = [
				{
					pad_back
					import_exit_check
				}
				{
					pad_up
					import_up
				}
				{
					pad_down
					import_down
				}
			]}
	endif
	added_elements = 0
	getarraysize \{$downloaded_offerings}
	if (<array_size> > 0)
		i = 0
		begin
		if structurecontains structure = ($downloaded_offerings [<i>]) offer
			if import_get_product_code offer = (($downloaded_offerings [<i>]).offer)
				if ((($downloaded_offerings [<i>]).type) = import)
					import_add_item {
						text = (($downloaded_offerings [<i>]).display_name)
						pad_choose_script = import_choose
						pad_choose_params = {code = <code> content_keys = <content_keys> offeringid = (($downloaded_offerings [<i>]).offeringid) display_name = (($downloaded_offerings [<i>]).display_name) title_name = (($downloaded_offerings [<i>]).title_name)}
						pad_square_script = import_choose_details
						pad_square_params = {index = <i>}
						($downloaded_offerings [<i>])
					}
					added_elements = (<added_elements> + 1)
				elseif ((($downloaded_offerings [<i>]).type) = patch)
					if isps3
						<choose_script> = import_go_to_terms
					else
						<choose_script> = import_purchase_content
					endif
					import_add_item {
						text = (($downloaded_offerings [<i>]).display_name)
						pad_choose_script = <choose_script>
						pad_choose_params = {code = <code>}
						($downloaded_offerings [<i>])
					}
					added_elements = (<added_elements> + 1)
				endif
			else
				printf 'unable to get code for %s' s = (($downloaded_offerings [<i>]).display_name)
			endif
		else
			printf 'no offer structure in %s' s = (($downloaded_offerings [<i>]).display_name)
		endif
		i = (<i> + 1)
		repeat <array_size>
	endif
	if ($g_include_debug_songs = 1)
		<0x21c30766> = 20
		<i> = 0
		begin
		formattext textname = 0x5363519e qs(0x6ef913a6) i = <i>
		import_add_item {
			text = <0x5363519e>
			pad_choose_script = nullscript
			pad_choose_params = {}
		}
		<i> = (<i> + 1)
		repeat <0x21c30766>
		<array_size> = (<array_size> + <0x21c30766>)
		<added_elements> = <array_size>
	endif
	if (<added_elements> = 0)
		import_setup_failed \{fail_text = qs(0x9d2e328d)
			heading_text = qs(0x03ac90f0)}
		return
	endif
	songlist_component :settags {
		list_count = <added_elements>
		slider_nub_res = (350.0 / (<array_size> - 1))
	}
	getscreenelementchildren \{id = current_menu}
	if (<array_size> > 0)
		if gotparam \{selected_index}
			if (<selected_index> > 0)
				begin
				import_down \{no_sound}
				repeat <selected_index>
			endif
			(<children> [<selected_index>]) :se_setprops item_rgba = ($g_music_store_item_focus_rgba)
		else
			(<children> [0]) :se_setprops item_rgba = ($g_music_store_item_focus_rgba)
		endif
	endif
	add_gamertag_helper exclusive_device = ($primary_controller)
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green
		z = 100000}
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red
		z = 100000}
endscript

script import_go_to_terms 
	requireparams \{[
			code
		]
		all}
	ui_sfx \{menustate = generic
		uitype = select}
	generic_event_choose state = uistate_import_terms data = {code = <code>}
endscript

script ui_destroy_import 
	clean_up_user_control_helpers
	destroyscreenelement \{id = songlist}
	destroy_dialog_box
endscript

script import_add_item 
	createscreenelement {
		type = descinterface
		desc = 'import_item'
		parent = current_menu
		item_text = <text>
		item_rgba = ($g_music_store_item_unfocus_rgba)
		autosizedims = true
		event_handlers = [
			{focus import_focus params = <...>}
			{unfocus import_unfocus}
			{pad_choose <pad_choose_script> params = <pad_choose_params>}
		]
	}
	if gotparam \{pad_square_script}
		<id> :se_setprops {
			event_handlers = [
				{pad_square <pad_square_script> params = <pad_square_params>}
			]
		}
	endif
endscript

script import_focus 
	se_setprops {
		item_rgba = ($g_music_store_item_focus_rgba)
	}
	import_esrb_label_alpha = 0.0
	if gotparam \{rating}
		if NOT (<rating> = none)
			import_esrb_label_alpha = 1.0
		endif
	endif
	songlist :se_setprops import_esrb_label_alpha = <import_esrb_label_alpha>
	clean_up_user_control_helpers
	add_gamertag_helper exclusive_device = ($primary_controller)
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green
		z = 100000}
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red
		z = 100000}
	if gotparam \{pad_square_script}
		add_user_control_helper \{text = qs(0x96561bac)
			button = blue
			z = 100000}
	endif
endscript

script import_unfocus 
	se_setprops {
		item_rgba = ($g_music_store_item_unfocus_rgba)
	}
endscript

script import_up 
	songlist_component :membfunc_songlist_uistack_getlistindex
	songlist_component :membfunc_songlist_uistack_getlisttop
	songlist_component :membfunc_songlist_uistack_getlistbottom
	if (<list_index> >= 0)
		list_index = (<list_index> - 1)
		if (<list_index> < 0)
			return
		else
			if NOT gotparam \{no_sound}
				audio_ui_play_songlist_scroll_sfx
			endif
			generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
				dir = up}
			if (<list_index> < <list_top>)
				if (<list_top> > 0)
					list_top = (<list_top> - 1)
					list_bottom = (<list_bottom> - 1)
					<resolved_id> :se_setprops pos = ((0.0, -74.0) * <list_top>)
				endif
			endif
			songlist_component :membfunc_songlist_uistack_setlistindex list_index = <seek_index> seek_checksum = <seek_checksum>
			songlist_component :membfunc_songlist_uistack_setlisttop list_top = <list_top>
			songlist_component :membfunc_songlist_uistack_setlistbottom list_bottom = <list_bottom>
		endif
	endif
endscript

script import_down 
	songlist_component :membfunc_songlist_uistack_getlistindex
	songlist_component :membfunc_songlist_uistack_getlisttop
	songlist_component :membfunc_songlist_uistack_getlistbottom
	songlist_component :getsingletag \{list_count}
	if (<list_index> < <list_count>)
		list_index = (<list_index> + 1)
		if (<list_index> >= <list_count>)
			return
		else
			if NOT gotparam \{no_sound}
				audio_ui_play_songlist_scroll_sfx
			endif
			generic_scrollbar_wgt_update_thumb_pos \{id = songlist_scrollbar_wgt
				dir = down}
			if (<list_index> > <list_bottom>)
				if (<list_top> >= 0)
					list_top = (<list_top> + 1)
					list_bottom = (<list_bottom> + 1)
					<resolved_id> :se_setprops pos = ((0.0, -74.0) * <list_top>)
				endif
			endif
			songlist_component :membfunc_songlist_uistack_setlistindex list_index = <seek_index> seek_checksum = <seek_checksum>
			songlist_component :membfunc_songlist_uistack_setlisttop list_top = <list_top>
			songlist_component :membfunc_songlist_uistack_setlistbottom list_bottom = <list_bottom>
		endif
	endif
endscript

script import_choose 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	requireparams \{[
			content_keys
			offeringid
		]
		all}
	if NOT import_check_signin_state
		import_setup_failed fail_text = <fail_text>
		return
	endif
	se_getparentid
	if screenelementexists id = <parent_id>
		launchevent type = unfocus target = <parent_id>
	endif
	if import_match_content_key content_keys = <content_keys> offeringid = <offeringid>
		import_purchase_content code = <code>
	else
		ui_sfx \{menustate = generic
			uitype = select}
		ui_event_wait event = menu_change data = {state = uistate_import_pre_legal code = <code> offeringid = <offeringid> display_name = <display_name> title_name = <title_name>}
	endif
endscript

script import_match_content_key 
	requireparams \{[
			content_keys
			offeringid
		]
		all}
	getarraysize <content_keys>
	if (<array_size> > 0)
		i = 0
		begin
		if import_match_single_key content_key = ((<content_keys> [<i>]).content_key) offeringid = <offeringid>
			return \{true}
		endif
		i = (<i> + 1)
		repeat <array_size>
	endif
	return \{false}
endscript

script import_match_single_key 
	if (<content_key> = <offeringid>)
		return \{true}
	endif
endscript
downloaded_offerings_index = -1

script import_create_details_content_source 
	requireparams \{[
			list_name
		]
		all}
	if NOT import_check_signin_state
		if scriptisrunning \{songlist_request_page_when_ready}
			killspawnedscript \{name = songlist_request_page_when_ready}
		endif
		if scriptisrunning \{songlist_pre_build}
			killspawnedscript \{name = songlist_pre_build}
		endif
		import_setup_failed fail_text = <fail_text>
		return \{false}
	endif
	if (($downloaded_offerings_index) = -1)
		scriptassert \{qs(0xfd92c0ad)}
		return \{false}
	endif
	contentmanfunc func = register_content_source name = <list_name> type = playlist
	offering = ($downloaded_offerings [($downloaded_offerings_index)])
	if structurecontains structure = <offering> contents
		getarraysize (<offering>.contents)
		if (<array_size> > 0)
			i = 0
			begin
			formattext checksumname = item_name 'item_%s' s = <i> addtostringlookup = true
			contentmanfunc func = add_data name = <list_name> item_name = <item_name> item_data = ((<offering>.contents) [<i>])
			i = (<i> + 1)
			repeat <array_size>
		endif
	endif
	change \{downloaded_offerings_index = -1}
	return \{true}
endscript

script import_choose_details 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	requireparams \{[
			index
		]
		all}
	if NOT import_check_signin_state
		import_setup_failed fail_text = <fail_text>
		return
	endif
	change downloaded_offerings_index = <index>
	ui_sfx \{menustate = generic
		uitype = select}
	ui_event_wait event = menu_change data = {state = uistate_songlist mode = import exclusive_device = ($primary_controller)}
endscript

script import_exit_check 
	setspawninstancelimits \{max = 1
		management = ignore_spawn_request}
	ui_sfx \{menustate = generic
		uitype = back}
	if NOT import_check_signin_state
		import_setup_failed fail_text = <fail_text>
		return
	endif
	if screenelementexists \{id = current_menu}
		current_menu :se_setprops \{block_events}
	endif
	if ($music_store_attempted_purchase = 1)
		create_dialog_box {
			no_background
			heading_text = qs(0x3ed675b6)
			body_text = qs(0x9d6e82da)
			player_device = ($primary_controller)
			options = [
				{
					text = qs(0x4b4accd7)
					func = import_exit_check_warning_exit
				}
				{
					text = qs(0xf07aa486)
					func = import_exit_check_warning_cancel
				}
			]
		}
		return
	endif
	generic_event_back_block \{state = uistate_options
		nosound}
endscript

script import_exit_check_warning 
	if screenelementexists \{id = generic_barrel_vmenu}
		launchevent \{type = unfocus
			target = generic_barrel_vmenu}
	endif
	destroy_dialog_box
	create_dialog_box {
		no_background
		heading_text = <title>
		body_text = <body_text>
		options = <options>
		player_device = ($primary_controller)
	}
endscript

script import_exit_check_warning_cancel 
	destroy_dialog_box
	if screenelementexists \{id = current_menu}
		current_menu :se_setprops \{unblock_events}
	endif
	current_menu :menu_getselectedindex
	add_gamertag_helper exclusive_device = ($primary_controller)
	add_user_control_helper \{text = qs(0xc18d5e76)
		button = green
		z = 100000}
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red
		z = 100000}
	getarraysize \{$downloaded_offerings}
	if (<selected_index> < <array_size>)
		if ((($downloaded_offerings [<selected_index>]).type) = import)
			add_user_control_helper \{text = qs(0x96561bac)
				button = blue
				z = 100000}
		endif
	endif
endscript

script import_exit_check_warning_exit 
	destroy_dialog_box
	if screenelementexists \{id = current_menu}
		launchevent \{type = focus
			target = current_menu}
	endif
	generic_event_back_block \{state = uistate_options
		nosound}
endscript
