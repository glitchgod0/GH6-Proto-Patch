
script modelbuilder_build_model 
	modelbuilder_set_lock \{lock = 1}
	if NOT gotparam \{hat_hair_choice}
		hat_hair_choice = hair
	endif
	if NOT gotparam \{instrument}
		instrument = none
	endif
	if NOT gotparam \{caching}
		if gotparam \{preload}
			if NOT gotparam \{new_object}
				foreachincas \{do = geombackuplightcachedata}
			endif
		else
			modelrunscript \{scriptname = cas_reset_bones}
		endif
		modelclearallgeoms
	endif
	foreachincas do = modeladdgeom params = {use_body_skeleton2 = <use_body_skeleton2>}
	foreachincas \{do = geomreplacetexture}
	foreachincas \{do = geomtexturereplacecleanup}
	foreachincas \{do = modelreskinpart
		params = {
			scriptname = cas_part_reskin
		}}
	foreachincas \{do = geomsetuvmatrix}
	if NOT gotparam \{preload}
		modelupdatemainrigforreskinning \{part = cas_body
			scriptname = cas_lowres_rig_reskin}
		foreachincas \{do = modelcopygeom
			params = {
				materials = $cas_reskin_materials
			}}
		foreachincas \{do = modeldeletereskintemporaries}
		foreachincas \{do = deformmainskeleton
			params = {
				scriptname = cas_main_skel_scale
			}}
	endif
	foreachincas \{do = modeladdcloth}
	foreachincas \{do = geompolyremoval}
	foreachincas \{do = geomsetmaterialvariables}
	if gotparam \{new_object}
		modelexpandboundingsphere
	endif
	modelupdateskinningpolyremoval
	foreachincas \{do = createapiececomposite}
	if NOT gotparam \{caching}
		if NOT gotparam \{preload}
			if NOT gotparam \{new_object}
				foreachincas \{do = geomrestorelightcachedata}
			endif
			modelrunscript scriptname = modelbuilder_set_difference_anim params = {instrument = <instrument>}
			modelrunscript \{scriptname = modelbuilder_update_pose}
			modelrunscript \{scriptname = modelbuilder_set_guitar_offset}
		endif
	endif
	modelbuilder_set_lock \{lock = 0}
endscript

script modelbuilder_build_logo 
	modelbuilder_set_lock \{lock = 1}
	modelclearallgeoms
	foreachincas \{do = modeladdgeom}
	foreachincas \{do = createapiececomposite}
	modelbuilder_set_lock \{lock = 0}
endscript

script modelbuilder_update_poly_removal 
	modelbuilder_set_lock \{lock = 1}
	foreachincas \{do = geompolyremoval}
	modelbuilder_set_lock \{lock = 0}
endscript

script modelbuilder_update_colors 
	modelbuilder_set_lock \{lock = 1}
	foreachincas \{do = geomsetmaterialvariables}
	modelbuilder_set_lock \{lock = 0}
endscript

script modelbuilder_update_single_cap_texture 
	modelbuilder_set_lock \{lock = 1}
	createapiececomposite part = <part> incremental
	modelbuilder_set_lock \{lock = 0}
endscript

script modelbuilder_update_reskins 
	modelbuilder_set_lock \{lock = 1}
	if NOT gotparam \{kill_objects}
		do_not_kill_flags = {do_not_kill}
	endif
	if NOT gotparam \{caching}
		modelrunscript \{scriptname = cas_reset_bones}
	endif
	foreachincas \{do = modelreskinpart
		params = {
			scriptname = cas_part_reskin
			force_reskin
		}}
	modelupdatemainrigforreskinning \{part = cas_body
		scriptname = cas_lowres_rig_reskin
		force_reskin}
	foreachincas \{do = modelcopygeom
		params = {
			materials = $cas_reskin_materials
		}}
	foreachincas do = modeldeletereskintemporaries params = <do_not_kill_flags>
	foreachincas \{do = deformmainskeleton
		params = {
			scriptname = cas_main_skel_scale
		}}
	getmodelbuilderappearance
	modelbuilder_set_lock \{lock = 0}
endscript

script modelbuilder_set_difference_anim \{instrument = none}
	<diff_anim> = 'none'
	<diff_anim_name> = none
	<fat_anim_name> = none
	<is_fat> = 0
	<is_female> = 0
	getsingletag \{is_female}
	getsingletag \{is_fat}
	if NOT modelbuilder :getmodelbuilderactualstructkey \{key = diff_anim
			part = cas_female_shoes}
		if NOT modelbuilder :getmodelbuilderactualstructkey \{key = diff_anim
				part = cas_male_shoes}
			modelbuilder :getmodelbuilderactualstructkey \{key = diff_anim
				part = cas_full_body}
		endif
	endif
	if (<is_fat> = 0)
		if NOT modelbuilder :getmodelbuilderactualstructkey \{key = is_fat
				part = cas_male_physique}
			modelbuilder :getmodelbuilderactualstructkey \{key = is_fat
				part = cas_female_physique}
		endif
	endif
	if (<diff_anim> = 'none')
		if (<is_female> = 1)
			<diff_anim_name> = gh_rocker_female_empty_d
		else
			<diff_anim_name> = gh_rocker_male_empty_d
		endif
	else
		if (<instrument> = drum)
			formattext checksumname = diff_anim_name 'GH_Drummer_%d' d = <diff_anim>
		else
			formattext checksumname = diff_anim_name 'GH_Rocker_%d' d = <diff_anim>
		endif
	endif
	if (<is_fat> = 1)
		if (<is_female> = 1)
			<fat_anim_name> = gh_rocker_fat_female_d
		else
			<fat_anim_name> = gh_rocker_fat_male_d
		endif
	else
		if (<is_female> = 1)
			<fat_anim_name> = gh_rocker_female_empty_d
		else
			<fat_anim_name> = gh_rocker_male_empty_d
		endif
	endif
	if (<diff_anim_name> != none || <fat_anim_name> != none)
		printf 'Clothing difference anim = %s' s = <diff_anim_name> donotresolve
		hero_add_clothing_difference_anim heel_anim = <diff_anim_name> fat_anim = <fat_anim_name>
	endif
endscript

script modelbuilder_set_guitar_offset 
	<total_offset> = (0.0, 0.0, 0.0)
	<guitar_offset> = (0.0, 0.0, 0.0)
	<frontend_character> = 0
	getsingletag \{frontend_character}
	if (<frontend_character> = 1)
		return
	endif
	if NOT modelbuilder :getmodelbuilderactualstructkey \{key = guitar_offset
			part = cas_body}
		modelbuilder :getmodelbuilderactualstructkey \{key = guitar_offset
			part = cas_full_body}
	endif
	<total_offset> = <guitar_offset>
	<guitar_offset> = (0.0, 0.0, 0.0)
	modelbuilder :getmodelbuilderactualstructkey \{key = guitar_offset
		part = cas_guitar_body}
	<total_offset> = (<total_offset> + <guitar_offset>)
	if (<total_offset> != (0.0, 0.0, 0.0))
		anim_command {
			target = tweakbonesnode
			command = tweakbones_relativetranslatebone
			params = {
				bone = bone_guitar_body
				relative_bone = bone_pelvis
				<total_offset>
			}
		}
	endif
endscript

script modelbuilder_update_pose 
	anim_updatepose
endscript

script modelbuilder_set_lock \{lock = !i1768515945}
	change model_builder_lock = <lock>
endscript

script modelbuilder_check_lock 
	if NOT ($model_builder_lock = 0)
		scriptassert \{'Profile/appearance modification functions should not be called during a modelbuild'}
	endif
endscript

script buildcasmodel \{appearance = 0x69696969
		buildscript = modelbuilder_build_model
		buildscriptparams = 0x69696969
		async = !i1768515945
		use_cache = 0
		appearance_checksum = !q1768515945}
	change \{safe_to_free_cas_temporaries = 0}
	change \{g_cas_model_build_success = 0}
	build_incremental = 0
	if structurecontains structure = <buildscriptparams> build_incremental
		build_incremental = 1
	endif
	gettruestarttime
	onexitrun buildcasmodel_cleanup params = {starttime = <starttime> build_incremental = <build_incremental>}
	if structurecontains \{structure = buildscriptparams
			instrument}
		instrument = (<buildscriptparams>.instrument)
	else
		instrument = none
	endif
	printscriptinfo 'BuildCASModel %a' a = <async> donotresolve
	getsingletag \{asset_heap}
	getsingletag \{lightgroup}
	gethathairchoice
	if (<instrument> = drum)
		use_body_skeleton2 = true
	endif
	filterappearance appearance_name = appearance part_set = $instrument_part_sets chosen_set = <instrument>
	filterappearance appearance_name = appearance part_set = $hair_part_sets chosen_set = <hat_hair_choice>
	buildscriptparams = {
		<buildscriptparams>
		lightgroup = <lightgroup>
		temporary_heap = heap_cas_build
		hat_hair_choice = <hat_hair_choice>
		use_body_skeleton2 = <use_body_skeleton2>
	}
	change \{cancelled_model_build = 0}
	waitunloadgroup cas async = <async>
	modelbuilder_waitforavatar {
		async = <async>
	}
	if ($cancelled_model_build = 1)
		return \{false}
	endif
	archivecancelloading \{cas_building_cache}
	archivewaitloading cas_building_cache async = <async>
	original_async = <async>
	if (<use_cache> = 1)
		cascacheflushvram
		if ($cancelled_model_build = 1)
			return \{false}
		endif
		cascachemodel {
			appearance = <appearance>
			buildscript = <buildscript>
			buildscriptparams = <buildscriptparams>
			async = <async>
			global_storage = <asset_heap>
		}
		if ($cancelled_model_build = 1)
			return \{false}
		endif
		async = 0
	endif
	if (<async> = 1)
		hide
	endif
	archivecancelloading \{cas}
	cascancelavatars
	archivewaitloading \{cas}
	modelbuilder_preload {
		async = <async>
		appearance = <appearance>
		buildscript = <buildscript>
		buildscriptparams = <buildscriptparams>
	}
	if ($cancelled_model_build = 1)
		return \{false}
	endif
	modelbuilder_loadassets {
		async = <async>
	}
	if ($cancelled_model_build = 1)
		printf \{'CancelledLoadAssets-beforeprocess'}
		modelbuilder_processassets
		printf \{'CancelledLoadAssets-afterprocess'}
		return \{false}
	endif
	modelbuilder_waitforavatar {
		async = <async>
	}
	modelbuilder_processassets
	if ($cancelled_model_build = 1)
		return \{false}
	endif
	modelbuilder_build {
		appearance = <appearance>
		buildscript = <buildscript>
		buildscriptparams = <buildscriptparams>
	}
	buildcasmodel_compositewait async = <original_async>
	if ($cancelled_model_build = 1)
		return \{false}
	endif
	if (<build_incremental> = 0)
		flushallcompositetextures \{no_block}
	endif
	settags appearance_checksum = <appearance_checksum>
	unhide
	forceinstanceupdate
	change \{g_cas_model_build_success = 1}
	return \{true}
endscript

script buildcasmodel_cleanup 
	printf \{'********************************************************************'}
	print_loading_time starttime = <starttime> text = qs(0xfea2c3fc)
	printf \{'********************************************************************'}
	change \{safe_to_free_cas_temporaries = 1}
	castemporariesflush
	if (<build_incremental> = 0)
		buildcasmodel_compositewait \{async = 0}
		flushallcompositetextures
	endif
endscript

script buildcasmodel_compositewait 
	if (<async> = 1)
		caswaitforcomposite
	else
		casblockforcomposite
	endif
endscript

script cascancelloading 
	archivecancelloading \{cas}
	cascancelavatars
	cas_queue_cancel_loading
	change \{cancelled_model_build = 1}
endscript

script casblockforloading 
	archivewaitloading \{cas
		async = 0}
endscript
