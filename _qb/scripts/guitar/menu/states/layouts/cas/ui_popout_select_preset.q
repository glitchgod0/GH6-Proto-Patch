
script ui_create_popout_select_preset 
	spawnscriptnow ui_create_popout_select_preset_spawned params = {<...>}
endscript

script ui_create_popout_select_preset_spawned \{is_customizable = true
		create_bg_menu = 0}
	make_list_menu {
		vmenu_id = create_popout_select_preset_vmenu
		title = <text>
		pad_back_script = generic_exit_restore
		pad_back_sound = audio_null_sound
		text_case = <text_case>
		icon = <hist_tex>
		icon_offset = <icon_offset>
		list_offset = <list_offset>
		exclusive_device = <state_device>
	}
	create_popout_select_preset_vmenu :settags create_bg_menu = <create_bg_menu>
	if NOT gotparam \{disable_rotation_zoom}
		setup_cas_menu_handlers vmenu_id = create_popout_select_preset_vmenu camera_list = <camera_list> zoom_camera = <zoom_camera> no_rotate = <no_rotate> no_zoom = <no_zoom> pull_back_distance = <pull_back_distance> controller = <state_device>
	endif
	clean_up_user_control_helpers
	<preset_list> = ($<preset_list_name>.male)
	cas_get_is_female player = ($cas_current_player)
	if (<is_female> = 1)
		<preset_list> = ($<preset_list_name>.female)
	endif
	if (<is_customizable> = true)
		add_list_item {
			text = qs(0xd2cd3957)
			pad_choose_script = popout_select_preset_customize
			pad_choose_params = {preset_type = <preset_list_name> customize_state = <customize_state>}
			additional_focus_script = select_preset_focus_change
			additional_focus_params = {
				preset_type = <preset_list_name>
				preset_index = -1
				show_customizable = 0
				restore_car = 1
				play_current_anim = <play_current_anim>
			}
		}
	endif
	current_part = 0
	swatch_editable_icon = style_icon
	getarraysize <preset_list>
	num_parts_added = 0
	if (<array_size> > 0)
		i = 0
		begin
		if structurecontains structure = (<preset_list> [<i>]) locked
			price = 100
		else
			removeparameter \{price}
		endif
		add_list_item {
			text = ((<preset_list> [<i>]).frontend_desc)
			pad_choose_script = popout_select_preset_choose
			pad_choose_params = {preset_type = <preset_list_name> preset_index = <i> instrument = <instrument> nosound}
			camera_list = <camera_list>
			zoom_camera = <zoom_camera>
			additional_focus_script = select_preset_focus_change
			additional_focus_params = {
				state_device = <state_device>
				preset_type = <preset_list_name>
				preset_index = <i>
				play_current_anim = <play_current_anim>
				disable_rotation_zoom = <disable_rotation_zoom>
				show_customizable = <is_customizable>
				customize_state = <customize_state>
			}
		}
		num_parts_added = (<num_parts_added> + 1)
		removeparameter \{price}
		removeparameter \{pad_choose_dialogue}
		removeparameter \{pad_back_dialogue}
		removeparameter \{show_purchasable}
		removeparameter \{show_editable}
		removeparameter \{show_swatches}
		removeparameter \{pad_option2_script}
		removeparameter \{editable}
		i = (<i> + 1)
		repeat <array_size>
	endif
	<focus_index> = 0
	if is_preset_type_in_appearance preset_type = <preset_list_name>
		if (<is_customizable> = true)
			<focus_index> = (<preset_index> + 1)
		else
			<focus_index> = <preset_index>
		endif
	endif
	launchevent type = focus target = create_popout_select_preset_vmenu data = {child_index = <focus_index>}
	if gotparam \{stance}
		if getcurrentcasobject
			bandmanager_changestance name = <cas_object> stance = <stance> no_wait
		endif
	endif
	if gotparam \{face_anim}
		if getcurrentcasobject
			band_changefacialanims name = <cas_object> fa_type = <face_anim>
		endif
	endif
	if gotparam \{cam_name}
		change \{generic_menu_block_input = 1}
		task_menu_default_anim_in base_name = <cam_name>
		change \{generic_menu_block_input = 0}
	endif
endscript

script ui_destroy_popout_select_preset 
	if screenelementexists \{id = sponsor_logo}
		destroyscreenelement \{id = sponsor_logo}
	endif
	if screenelementexists \{id = create_popout_select_preset_vmenu}
		create_popout_select_preset_vmenu :getsingletag \{create_bg_menu}
		if (<create_bg_menu> = 1)
			destroy_generic_menu
		endif
	endif
	generic_list_destroy
	destroy_dialog_box
endscript

script ui_init_popout_select_preset 
	requireparams \{[
			preset_list_name
		]
		all}
	pushtemporarycasappearance
	if gotparam \{remove_parts}
		getarraysize <remove_parts>
		i = 0
		begin
		part = (<remove_parts> [<i>])
		editcasappearance {
			target = clearpart
			targetparams = {part = <part>}
		}
		i = (<i> + 1)
		repeat <array_size>
		rebuildcurrentcasmodel
	endif
endscript

script ui_deinit_popout_select_preset 
	flushallcompositetexturesfromui
	poptemporarycasappearance
	if NOT gotparam \{skip_deinit_script}
		if gotparam \{additional_deinit_script}
			<additional_deinit_script>
		endif
		if getcurrentcasobject
			if gotparam \{return_stance}
				bandmanager_changestance name = <cas_object> stance = <return_stance> no_wait
			else
				bandmanager_changestance name = <cas_object> stance = stance_frontend no_wait
			endif
			if gotparam \{return_face_anim}
				band_changefacialanims name = <cas_object> fa_type = <return_face_anim>
			else
				band_changefacialanims name = <cas_object> fa_type = '_rocker'
			endif
		endif
	else
		ui_event_remove_params \{param = skip_deinit_script}
	endif
	cleanup_cas_menu_handlers
	if gotparam \{bonemenu_popup}
		cas_bonemenu_begin part = <bonemenu_popup>
	endif
endscript

script cas_get_gender {
		0x52 player = ($cas_current_player)
	}
	cas_get_is_female player = <player>
	if (<is_female> = 1)
		return \{gender = female}
	else
		return \{gender = male}
	endif
endscript

script select_preset_focus_change 
	requireparams \{[
			preset_type
			preset_index
		]
		all}
	killallcompositetextures
	cas_get_gender
	<preset_list> = ($<preset_type>.<gender>)
	<parts_list> = ($body_parts)
	if (<preset_index> >= 0)
		<new_preset> = (<preset_list> [<preset_index>])
		getarraysize <parts_list>
		<i> = 0
		begin
		<cur_part> = (<parts_list> [<i>])
		if structurecontains structure = <new_preset> <cur_part>
			<part_struct> = (<new_preset>.<cur_part>)
			if (<cur_part> = cas_body)
				change cas_current_appearance = {($cas_current_appearance) cas_body = <part_struct>}
			else
				cas_add_item_to_appearance {
					part = <cur_part>
					desc_id = (<part_struct>.desc_id)
					no_rebuild
				}
			endif
			getcasappearancepartinstance part = <cur_part>
			if gotparam \{part_instance}
				if structurecontains structure = <part_instance> bones
					setcasappearancebones part = <cur_part> bones = (<part_instance>.bones)
				endif
			endif
		endif
		<i> = (<i> + 1)
		repeat <array_size>
		if structurecontains structure = <new_preset> post_layer
			if structurecontains structure = <new_preset> base_tex
				<base_tex> = (<new_preset>.base_tex)
				<post_layer> = (<new_preset>.post_layer)
				if structurecontains structure = <new_preset> layers
					setcasappearancecapmakeup base_tex = <base_tex> post_layer = <post_layer> layers = (<new_preset>.layers)
				else
					setcasappearancecapmakeup base_tex = <base_tex> post_layer = <post_layer>
				endif
			endif
		endif
		if structurecontains structure = <new_preset> tattoos
			setcasappearancecaptattoo tattoos = (<new_preset>.tattoos)
		endif
		rebuildcurrentcasmodel
	endif
	if gotparam \{restore_car}
		restoretoptemporarycasappearance
	endif
	if gotparam \{play_current_anim}
		if gotparam \{frontend_anim_name}
			if getcurrentcasobject
				band_playsimpleanim name = <cas_object> anim = <frontend_anim_name>
			endif
		endif
	endif
	clean_up_user_control_helpers
	if gotparam \{disable_rotation_zoom}
		no_rotate_zoom_text = {no_rotate_zoom_text}
	endif
	if gotparam \{show_purchasable}
		car_helper_text = {car_helper_text_purchase}
	elseif gotparam \{show_swatches}
		car_helper_text = {car_helper_text_swatches}
	else
		car_helper_text = {car_helper_text_cancel}
	endif
	if (<show_customizable> = true)
		car_helper_text = {car_helper_text_customize}
		setscreenelementprops {
			id = create_popout_select_preset_vmenu
			event_handlers = [
				{pad_option2 popout_select_preset_customize params = {preset_type = <preset_type> customize_state = <customize_state>}}
			]
			replace_handlers
		}
	endif
	menu_finish <car_helper_text> <no_rotate_zoom_text> controller = <state_device>
endscript

script popout_select_preset_choose 
	if gotparam \{instrument}
		switch (<instrument>)
			case drum
			state = uistate_cadrm_main
			case vocals
			state = uistate_customize_character_mic_main
			default
			scriptassert 'Invalid Instrument - %s' s = <instrument>
		endswitch
		if ui_event_exists_in_stack \{name = 'cadrm_main'}
			ui_sfx \{menustate = car
				uitype = select}
			generic_event_back state = <state>
		elseif ui_event_exists_in_stack \{name = 'customize_character_mic_main'}
			ui_sfx \{menustate = car
				uitype = select}
			generic_event_back state = <state>
		else
			ui_event_wait event = menu_replace data = {
				state = <state>
				instrument_info = ($cag_instruments [$cag_instrument_idxs.<instrument>])
				instrument = <instrument>
			}
		endif
	else
		generic_event_back
	endif
	add_preset_to_appearance preset_type = <preset_type> preset_index = <preset_index>
endscript

script popout_select_preset_customize 
	remove_preset_from_appearance preset_type = <preset_type>
	ui_event_wait event = menu_replace data = {state = <customize_state>}
endscript
