
script getcurrentcasobject 
	if cas_player_has_character_object player = ($cas_current_player)
		return true cas_object = <character_object>
	endif
	return \{false}
endscript

script getcasappearance 
	return true appearance = ($cas_current_appearance)
endscript

script getcasappearancepartinstance \{part = !q1768515945}
	resolvebodyspecificpartinappearance part = <part>
	if structurecontains structure = ($cas_current_appearance) <part>
		app_struct = (($cas_current_appearance).<part>)
		if structurecontains structure = <app_struct> desc_id
			return true part_instance = (<app_struct>)
		endif
	endif
	return \{false}
endscript

script setcasappearancepartinstance \{part = !q1768515945
		part_instance = 0x69696969}
	resolvebodyspecificpartinappearance part = <part>
	addparam name = <part> structure_name = part_struct value = <part_instance>
	change cas_current_appearance = {
		($cas_current_appearance)
		<part_struct>
	}
endscript

script editcasappearance \{target = !q1768515945
		targetparams = 0x69696969}
	modelbuilder_check_lock
	part = (<targetparams>.part)
	resolvebodyspecificpartinappearance part = <part>
	switch (<target>)
		case setpart
		newstruct = {desc_id = (<targetparams>.desc_id)}
		add_default_cap_array_to_newstruct part = <part> newstruct = <newstruct>
		add_default_chosen_materials_to_newstruct part = <part> newstruct = <newstruct>
		updatestructelement struct = $cas_current_appearance element = <part> value = <newstruct>
		change cas_current_appearance = <newstruct>
		case clearpart
		newstruct = ($cas_current_appearance)
		removecomponent structure_name = newstruct name = <part>
		change cas_current_appearance = <newstruct>
		case hidegeom
		hide_geom = (<targetparams>.hide_geom)
		if structurecontains structure = ($cas_current_appearance) <part>
			newstruct = {
				(($cas_current_appearance).<part>)
				hide_geom = <hide_geom>
			}
			updatestructelement struct = $cas_current_appearance element = <part> value = <newstruct>
			change cas_current_appearance = <newstruct>
		endif
		default
		scriptassert 'EditCASAppearance - %s not supported' s = <target>
	endswitch
endscript

script add_default_chosen_materials_to_newstruct \{part = !q1768515945
		newstruct = 0x69696969}
	if NOT getactualcasoptionstruct part = <part> desc_id = (<newstruct>.desc_id)
		scriptassert '%s %t not found' s = <part> t = (<newstruct>.desc_id)
	endif
	if gotparam \{chosen_materials}
		return newstruct = {
			<newstruct>
			chosen_materials = <chosen_materials>
		}
	endif
endscript

script rebuildcurrentcasmodel {
		0x54 instrument = ($cas_current_instrument)
	}
	cas_queue_add_request {
		appearance = ($cas_current_appearance)
		player = ($cas_current_player)
		instrument = <instrument>
		force_update = <force_update>
		in_cas
	}
endscript

script updatecurrentcasmodel {
		0x54 buildscript
		0x59 buildscriptparams = {}
		0x54 instrument = ($cas_current_instrument)
		0x52 flush_assets = 1
		0x52 cache = 1
	}
	requireparams \{[
			buildscript
		]
		all}
	if cas_queue_is_busy \{in_queue_too}
		printf \{'UpdateCurrentCASModel: Doing full refresh, CAS queue is already working'}
		rebuildcurrentcasmodel instrument = <instrument>
		return
	endif
	killspawnedscript \{name = updatecurrentcasmodelspawned}
	spawnscriptnow updatecurrentcasmodelspawned params = {
		buildscript = <buildscript>
		buildscriptparams = <buildscriptparams>
		instrument = <instrument>
		flush_assets = <flush_assets>
		cache = <cache>
	}
endscript

script updatecurrentcasmodelspawned \{instrument = !q1768515945
		flush_assets = !i1768515945
		cache = !i1768515945}
	printscriptinfo \{'UpdateCurrentCASModelSpawned'}
	archivewaitloading \{cas
		async = 0}
	caswaitforcomposite
	if NOT ($cas_override_object = none)
		<cache> = 0
		cas_object = ($cas_override_object)
	else
		getcurrentcasobject
	endif
	if gotparam \{cas_object}
		if compositeobjectexists name = <cas_object>
			change \{safe_to_free_cas_temporaries = 0}
			onexitrun updatecurrentcasmodelspawned_cleanup params = {flush_assets = <flush_assets>}
			<cas_object> :getsingletag lightgroup
			<cas_object> :getsingletag asset_heap
			appearance = ($cas_current_appearance)
			get_appearance_checksum {appearance = <appearance> instrument = <instrument> mic = 0}
			gethathairchoice
			filterappearance appearance_name = appearance part_set = $instrument_part_sets chosen_set = <instrument>
			filterappearance appearance_name = appearance part_set = $hair_part_sets chosen_set = <hat_hair_choice>
			if (<instrument> = drum)
				use_body_skeleton2 = true
			endif
			buildscriptparams = {
				<buildscriptparams>
				temporary_heap = heap_cas_build
				instrument = <instrument>
				lightgroup = <lightgroup>
				hat_hair_choice = <hat_hair_choice>
				use_body_skeleton2 = <use_body_skeleton2>
				no_parts_added_or_removed
			}
			if (<cache> = 1)
				cascachemodel {
					async = 0
					appearance = <appearance>
					global_storage = <asset_heap>
					buildscript = <buildscript>
					buildscriptparams = <buildscriptparams>
				}
			endif
			<cas_object> :settags appearance_checksum = <new_appearance_checksum>
			<cas_object> :modelbuilder_preload {
				async = 0
				appearance = <appearance>
				buildscript = <buildscript>
				buildscriptparams = <buildscriptparams>
			}
			<cas_object> :modelbuilder_loadassets {
				async = 0
			}
			<cas_object> :modelbuilder_processassets
			<cas_object> :modelbuilder_build {
				appearance = <appearance>
				buildscript = <buildscript>
				buildscriptparams = <buildscriptparams>
			}
			forceinstanceupdate
		endif
	endif
endscript

script updatecurrentcasmodelspawned_cleanup \{flush_assets = !i1768515945}
	change \{safe_to_free_cas_temporaries = 1}
	if (<flush_assets> = 1)
		castemporariesflush
	endif
endscript

script printcurrentappearance 
	reorderstructforcas struct = ($cas_current_appearance)
	printcompactstruct <out>
endscript

script getcasmaterialvalue \{part = !q1768515945
		material = !q1768515945}
	if structurecontains structure = ($cas_current_appearance) <part>
		str = (($cas_current_appearance).<part>)
		if structurecontains structure = <str> chosen_materials
			if structurecontains structure = (<str>.chosen_materials) <material>
				return true value = ((<str>.chosen_materials).<material>)
			endif
		endif
	endif
	return \{false}
endscript

script setcasappearancematerial \{part = !q1768515945
		material = !q1768515945}
	requireparams \{[
			value
		]
		all}
	modelbuilder_check_lock
	if structurecontains structure = ($cas_current_appearance) <part>
		str = (($cas_current_appearance).<part>)
		if structurecontains structure = <str> chosen_materials
			chosen_materials = (<str>.chosen_materials)
		else
			chosen_materials = {}
		endif
		updatestructelement struct = <chosen_materials> element = <material> value = <value>
		chosen_materials = {
			<chosen_materials> <newstruct>
		}
		appendstruct struct = cas_current_appearance field = <part> params = {<str> chosen_materials = <chosen_materials>} globalstruct
	endif
endscript

script getcaspartmaterials \{part = !q1768515945}
	if NOT getcasappearancepartdescid part = <part>
		return \{false}
	endif
	if NOT getactualcasoptionstruct part = <part> desc_id = <desc_id>
		return \{false}
	endif
	if gotparam \{materials}
		getarraysize <materials>
		if (<array_size> > 0)
			array = []
			i = 0
			begin
			title = qs(0x1a32079f)
			if (<array_size> = 1)
				name = qs(0xaa2546c1)
			else
				formattext textname = name qs(0xdfd513db) d = (<i> + 1)
			endif
			if gotparam \{material_names}
				name = (<material_names> [<i>])
				title = (<material_names> [<i>])
			endif
			formattext checksumname = desc_id 'material%d' d = (<i> + 1)
			addarrayelement array = <array> element = {desc_id = <desc_id> name = <name> title = <title>}
			i = (<i> + 1)
			repeat <array_size>
			return true part_materials = <array>
		endif
	else
		if gotparam \{material_groups}
			getarraysize <material_groups>
			if (<array_size> > 0)
				array = []
				i = 0
				begin
				title = qs(0x1a32079f)
				if (<array_size> = 1)
					name = qs(0xaa2546c1)
				else
					formattext textname = name qs(0xdfd513db) d = (<i> + 1)
				endif
				if structurecontains structure = (<material_groups> [<i>]) name
					name = ((<material_groups> [<i>]).name)
					title = ((<material_groups> [<i>]).name)
				endif
				if structurecontains structure = (<material_groups> [<i>]) desc_id
					desc_id = ((<material_groups> [<i>]).desc_id)
				else
					formattext checksumname = desc_id 'material%d' d = (<i> + 1)
				endif
				addarrayelement array = <array> element = {desc_id = <desc_id> name = <name> title = <title>}
				i = (<i> + 1)
				repeat <array_size>
				return true part_materials = <array>
			endif
		else
			if gotparam \{modify_all_materials}
				name = qs(0xaa2546c1)
				title = qs(0x1a32079f)
				if gotparam \{material_names}
					name = (<material_names> [0])
					title = (<material_names> [0])
				endif
				return true part_materials = [{desc_id = material1 name = <name> title = <title>}]
			endif
		endif
		return \{false}
	endif
endscript

script getcaspartswatches \{part = !q1768515945}
	if NOT getcasappearancepartdescid part = <part>
		return \{false}
	endif
	if NOT getactualcasoptionstruct part = <part> desc_id = <desc_id>
		return \{false}
	endif
	current_swatch_desc_id = <desc_id>
	if gotparam \{swatch_for}
		if NOT getactualcasoptionstruct part = <part> desc_id = <swatch_for>
			return \{false}
		endif
	endif
	if gotparam \{swatch_list}
		getarraysize <swatch_list>
		if (<array_size> > 0)
			array = []
			addarrayelement array = <array> element = {desc_id = <desc_id>}
			i = 0
			begin
			addarrayelement array = <array> element = {desc_id = (<swatch_list> [<i>])}
			i = (<i> + 1)
			repeat <array_size>
			return true part_swatches = <array> frontend_desc = <frontend_desc> current_swatch_desc_id = <current_swatch_desc_id>
		endif
	endif
	return \{false}
endscript

script setcasappearancebones \{part = !q1768515945
		bones = 0x69696969}
	printscriptinfo \{'SetCASAppearanceBones'}
	modelbuilder_check_lock
	if structurecontains structure = ($cas_current_appearance) <part>
		str = (($cas_current_appearance).<part>)
		appendstruct struct = cas_current_appearance field = <part> params = {<str> bones = <bones>} globalstruct
	endif
endscript

script setcasappearancecap \{part = !q1768515945}
	modelbuilder_check_lock
	if structurecontains structure = ($cas_current_appearance) <part>
		str = (($cas_current_appearance).<part>)
		if gotparam \{cap}
			appendstruct struct = cas_current_appearance field = <part> params = {<str> cap = <cap>} globalstruct
		else
			removecomponent \{name = cap
				structure_name = str}
			appendstruct struct = cas_current_appearance field = <part> params = {<str>} globalstruct
		endif
	endif
endscript

script getcasappearancecap \{part = !q1768515945}
	if NOT structurecontains structure = ($cas_current_appearance) <part>
		scriptassert qs(0x1136de11) p = <part>
	endif
	<part_struct> = ($cas_current_appearance.<part>)
	if structurecontains structure = <part_struct> cap
		return true cap = (<part_struct>.cap)
	else
		return \{false
			cap = [
			]}
	endif
endscript

script setcasappearancecapmakeup \{base_tex = !q1768515945
		post_layer = !a1768515945
		layers = [
		]}
	getcasappearancecap \{part = cas_body}
	getarraysize <cap>
	if (<array_size> = 0)
		setcasappearancecap part = cas_body cap = [{base_tex = <base_tex> post_layer = <post_layer> layers = <layers>}]
		return
	endif
	<i> = 0
	begin
	<cap_entry> = (<cap> [<i>])
	if structurecontains structure = <cap_entry> post_layer
		setarrayelement arrayname = cap index = <i> newvalue = {base_tex = <base_tex> post_layer = <post_layer> layers = <layers>}
		setcasappearancecap part = cas_body cap = <cap>
		break
	endif
	<i> = (<i> + 1)
	repeat <array_size>
endscript

script setcasappearancecaptattoo \{tattoos = !a1768515945}
	cap_new_design_worker \{part = cas_body
		div_id = body}
	cap_new_design_worker \{part = cas_body
		div_id = `right arm`}
	cap_new_design_worker \{part = cas_body
		div_id = `left arm`}
	getcasappearancecap \{part = cas_body}
	getarraysize <tattoos>
	if (<array_size> = 0)
		return
	endif
	<i> = 0
	begin
	<0x87347ac1> = (<tattoos> [<i>])
	addarrayelement array = <cap> element = <0x87347ac1>
	<cap> = <array>
	<i> = (<i> + 1)
	repeat <array_size>
	setcasappearancecap part = cas_body cap = <cap>
endscript

script setcasappearancepresets \{presets = !a1768515945}
	modelbuilder_check_lock
	change cas_current_appearance = {
		($cas_current_appearance)
		presets = <presets>
	}
endscript

script getcasappearancepresets \{presets = !a1768515945}
	if structurecontains structure = ($cas_current_appearance) presets
		return true presets = ($cas_current_appearance.presets)
	else
		return \{false
			presets = [
			]}
	endif
endscript

script setcasappearance \{appearance = 0x69696969}
	modelbuilder_check_lock
	verifycapprofile profile = {appearance = <appearance>} allowlocked
	change cas_current_appearance = {<appearance>}
endscript

script hideinstrument 
	foreachin (($instrument_part_sets).guitar) do = hideinstrument_foreach
	foreachin (($instrument_part_sets).bass) do = hideinstrument_foreach
	foreachin (($instrument_part_sets).drum) do = hideinstrument_foreach
	foreachin (($instrument_part_sets).vocals) do = hideinstrument_foreach
endscript

script hideinstrument_foreach 
	switchoffatomic <checksum>
endscript

script unhideinstrument 
	foreachin (($instrument_part_sets).guitar) do = unhideinstrument_foreach
	foreachin (($instrument_part_sets).bass) do = unhideinstrument_foreach
	foreachin (($instrument_part_sets).drum) do = unhideinstrument_foreach
	foreachin (($instrument_part_sets).vocals) do = unhideinstrument_foreach
endscript

script unhideinstrument_foreach 
	switchonatomic <checksum>
endscript

script hidemusician 
	foreachin \{$body_parts
		do = hidemusician_foreach}
endscript

script hidemusician_foreach 
	switchoffatomic <checksum>
endscript

script unhidemusician 
	foreachin \{$body_parts
		do = unhidemusician_foreach}
endscript

script unhidemusician_foreach 
	switchonatomic <checksum>
endscript

script caswaitforcomposite 
	if modelbuilderiscompositingactive
		begin
		printf \{'Waiting for Compositing...'}
		wait \{1
			gameframe}
		if NOT modelbuilderiscompositingactive
			break
		endif
		repeat
	endif
endscript

script casblockforcomposite 
	if modelbuilderiscompositingactive
		modelbuilderblockforcompositing
	endif
endscript

script pushtemporarycasappearance 
	addarrayelement array = ($cas_temporary_appearance_stack) element = ($cas_current_appearance)
	change cas_temporary_appearance_stack = <array>
endscript

script printtemporarycasappearancestack 
	printcompactstruct ($cas_temporary_appearance_stack)
endscript

script poptemporarycasappearance 
	getarraysize ($cas_temporary_appearance_stack)
	if (<array_size> > 0)
		removearrayelement array = ($cas_temporary_appearance_stack) index = (<array_size> -1)
		change cas_temporary_appearance_stack = <array>
	endif
endscript

script restoretoptemporarycasappearance 
	getarraysize ($cas_temporary_appearance_stack)
	if (<array_size> > 0)
		change cas_current_appearance = (($cas_temporary_appearance_stack) [(<array_size> -1)])
	endif
	if gotparam \{update_cap}
		updatecasmodelcap part = <part>
	elseif gotparam \{update_color}
		updatecurrentcasmodel \{buildscript = modelbuilder_update_colors}
	else
		rebuildcurrentcasmodel
	endif
endscript

script mergepartintotemporarycasappearance 
	requireparams \{[
			part_list
		]
		all}
	part_list_instances = []
	getarraysize <part_list>
	i = 0
	begin
	if NOT getcasappearancepartinstance part = (<part_list> [<i>])
		<part_instance> = {}
	endif
	addarrayelement array = <part_list_instances> element = <part_instance>
	part_list_instances = <array>
	i = (<i> + 1)
	repeat <array_size>
	getarraysize ($cas_temporary_appearance_stack)
	if (<array_size> > 0)
		change cas_current_appearance = (($cas_temporary_appearance_stack) [(<array_size> -1)])
		removearrayelement array = ($cas_temporary_appearance_stack) index = (<array_size> -1)
		change cas_temporary_appearance_stack = <array>
		getarraysize <part_list>
		i = 0
		begin
		if structurecontains structure = (<part_list_instances> [<i>]) desc_id
			setcasappearancepartinstance part = (<part_list> [<i>]) part_instance = (<part_list_instances> [<i>])
		endif
		if ((<part_list> [<i>]) = cas_hair)
			resolvebodyspecificpartinappearance \{part = cas_hat_hair}
			editcasappearance {
				target = clearpart
				targetparams = {part = <part>}
			}
			if getcasappearancepartinstance \{part = cas_hat}
				resolvebodyspecificpartinappearance \{part = cas_hat}
				editcasappearance {
					target = clearpart
					targetparams = {part = <part>}
				}
				cas_add_item_to_appearance part = <part> desc_id = (<part_instance>.desc_id) no_rebuild
				setcasappearancepartinstance part = <part> part_instance = <part_instance>
			endif
		endif
		i = (<i> + 1)
		repeat <array_size>
		rebuildcurrentcasmodel
	endif
endscript

script comparetoptemporarycasappearance 
	getarraysize ($cas_temporary_appearance_stack)
	if comparestructs struct1 = (($cas_temporary_appearance_stack) [(<array_size> -1)]) struct2 = ($cas_current_appearance)
		return \{true}
	else
		return \{false}
	endif
endscript

script generic_exit_restore 
	restoretoptemporarycasappearance
	ui_event \{event = menu_back}
endscript

script generic_exit_restore_refresh 
	restoretoptemporarycasappearance
	ui_event \{event = menu_back
		data = {
			refresh_previous_state
		}}
endscript
musician_heaps = [
	heap_musician1
	heap_musician2
	heap_musician3
	heap_musician4
]
g_best_heap_score_iterative_bias = 0.01
g_best_heap_score_iterative_bias_index = 0

script get_best_heap_for_appearance \{appearance = 0x69696969
		instrument = !q1768515945}
	best_heap = none
	best_score = -1.0
	gethathairchoice
	filterappearance appearance_name = appearance part_set = $instrument_part_sets chosen_set = <instrument>
	filterappearance appearance_name = appearance part_set = $hair_part_sets chosen_set = <hat_hair_choice>
	getarraysize \{$musician_heaps}
	i = 0
	begin
	heap_name = ($musician_heaps [<i>])
	get_appearance_heap_score appearance = <appearance> heap_name = <heap_name>
	if (($g_best_heap_score_iterative_bias_index) = <i>)
		<score> = (<score> + ($g_best_heap_score_iterative_bias))
	endif
	if (<score> >= <best_score>)
		best_score = <score>
		best_heap = <heap_name>
	endif
	i = (<i> + 1)
	repeat <array_size>
	change g_best_heap_score_iterative_bias_index = (($g_best_heap_score_iterative_bias_index) + 1)
	if (($g_best_heap_score_iterative_bias_index) = <array_size>)
		change \{g_best_heap_score_iterative_bias_index = 0}
	endif
	printstruct {best_heap = <best_heap> best_score = <best_score>}
	if (<best_score> < 0.0)
		scriptassert \{'No available heaps'}
	endif
	if casisassetstorageused name = <best_heap>
		scriptassert 'Asset storage %s is already used' s = <best_heap>
	endif
	return best_heap = <best_heap>
endscript

script get_appearance_heap_score \{appearance = 0x69696969
		heap_name = !q1768515945}
	if casisassetstorageused name = <heap_name>
		printf 'get_appearance_heap_score - %s is being used!' s = <heap_name>
		return \{score = -1.0}
	else
		cascompareassetstorage name = <heap_name> appearance = <appearance>
		return score = <comparevalue>
	endif
endscript

script get_appearance_checksum \{appearance = 0x69696969
		instrument = !q1768515945
		mic = !i1768515945}
	generatechecksumfromstruct \{structname = appearance}
	appearance_checksum = <structure_checksum>
	if gotparam \{instrument}
		appearance_checksum = (<appearance_checksum> + <instrument>)
	endif
	if (<mic> > 0)
		appearance_checksum = (<appearance_checksum> + mic)
	endif
	return new_appearance_checksum = <appearance_checksum>
endscript

script flushallcompositetexturesfromui 
	printscriptinfo \{'FlushAllCompositeTexturesFromUI'}
	flushallcompositetextures
	if scriptisrunning \{updatecurrentcasmodelspawned}
		printf \{'DEALING WITH AN ONGOING UPDATE!'}
		killspawnedscript \{name = updatecurrentcasmodelspawned}
		rebuildcurrentcasmodel instrument = ($cas_current_instrument)
	endif
endscript

script is_preset_type_in_appearance \{preset_type = !q1768515945}
	<appearance> = ($cas_current_appearance)
	if NOT structurecontains structure = <appearance> presets
		return \{false}
	endif
	<gender> = male
	cas_get_is_female player = ($cas_current_player)
	if (<is_female> = 1)
		<gender> = female
	endif
	if structurecontains structure = (<appearance>.presets) <preset_type>
		return true preset_index = (<appearance>.presets.<preset_type>.index) preset_list = ($<preset_type>.<gender>)
	else
		return \{false}
	endif
endscript

script add_preset_to_appearance \{preset_type = !q1768515945
		preset_index = !i1768515945}
	<appearance> = ($cas_current_appearance)
	if NOT structurecontains structure = <appearance> presets
		return \{false}
	endif
	<presets> = (<appearance>.presets)
	addparam structure_name = presets name = <preset_type> value = {index = <preset_index>}
	<appearance> = {<appearance> presets = <presets>}
	change cas_current_appearance = <appearance>
endscript

script remove_preset_from_appearance \{preset_type = !q1768515945}
	<appearance> = ($cas_current_appearance)
	if NOT structurecontains structure = <appearance> presets
		return \{false}
	endif
	<presets> = (<appearance>.presets)
	if NOT structurecontains structure = presets <preset_type>
		return
	endif
	removecomponent structure_name = presets name = <preset_type>
	<appearance> = {<appearance> presets = <presets>}
	change cas_current_appearance = <appearance>
endscript
