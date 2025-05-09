0xa3159be3 = 1.3339999
g_default_scoring = {
	gem_score = 50
	gem_hopo_score = 50
	gem_chord_score = 50
	gem_chord_hopo_score = 50
	gem_tap_score = 50
	sustain_beat_score = 25
	multiplier_1 = 1
	multiplier_2 = 2
	multiplier_3 = 3
	multiplier_4 = 4
	multiplier_5 = 0
	multiplier_6 = 0
	multiplier_speed = 1
	min_multiplier = 1
	star_power_multiplier = 2
	star_power_gain_multiplier = 1.0
	star_power_per_note_streak = 0.0
	crowd_meter_start_bonus = 0.0
	miss_note_bonus_allowed = 0
	miss_note_bonus_ms = 0.0
	0x03e6e6e2 = 0
}
g_scoring_max_multiplier = {
	level1 = [
		{
			name = multiplier_1
			value = 0
		}
		{
			name = multiplier_2
			value = 0
		}
		{
			name = multiplier_3
			value = 0
		}
		{
			name = multiplier_4
			value = 0
		}
		{
			name = multiplier_5
			value = 5
		}
		{
			name = multiplier_6
			value = 0
		}
	]
	level2 = [
		{
			name = multiplier_1
			value = 0
		}
		{
			name = multiplier_2
			value = 0
		}
		{
			name = multiplier_3
			value = 0
		}
		{
			name = multiplier_4
			value = 0
		}
		{
			name = multiplier_5
			value = 5
		}
		{
			name = multiplier_6
			value = 6
		}
	]
}
g_scoring_star_power_per_note_streak = {
	level1 = [
		{
			name = star_power_per_note_streak
			value = 6.0
		}
	]
	level2 = [
		{
			name = star_power_per_note_streak
			value = 12.0
		}
	]
}
g_scoring_crowd_meter_start_bonus = {
	level1 = [
		{
			name = crowd_meter_start_bonus
			value = 1.3349999
		}
	]
	level2 = [
		{
			name = crowd_meter_start_bonus
			value = 2.0
		}
	]
}
g_scoring_miss_note_bonus = {
	level1 = [
		{
			name = miss_note_bonus_allowed
			value = 1
		}
		{
			name = miss_note_bonus_ms
			value = 3000
		}
	]
	level2 = [
		{
			name = miss_note_bonus_allowed
			value = 2
		}
		{
			name = miss_note_bonus_ms
			value = 1000
		}
	]
}
g_scoring_star_power_gain_multiplier = {
	level1 = [
		{
			name = star_power_gain_multiplier
			value = 1.0
		}
	]
	level2 = [
		{
			name = star_power_gain_multiplier
			value = 3.0
		}
	]
}
g_scoring_resurrection = {
	level1 = [
		{
			name = 0x03e6e6e2
			value = 1
		}
	]
	level2 = [
		{
			name = 0x03e6e6e2
			value = 2
		}
	]
}
g_scoring_min_multiplier = {
	level1 = [
		{
			name = min_multiplier
			value = 1
		}
	]
	level2 = [
		{
			name = min_multiplier
			value = 1
		}
		{
			name = multiplier_speed
			value = 1
		}
	]
}
g_scoring_star_power_multiplier = {
	level1 = [
		{
			name = star_power_multiplier
			value = 1
		}
	]
	level2 = [
		{
			name = star_power_multiplier
			value = 3
		}
	]
}
g_scoring_demigod = {
}

script set_scoring_attributes_to_player \{player = !i1768515945
		globalname = g_default_scoring}
	setplayerinfo <player> gem_score = ($<globalname>.gem_score)
	setplayerinfo <player> gem_hopo_score = ($<globalname>.gem_hopo_score)
	setplayerinfo <player> gem_chord_score = ($<globalname>.gem_chord_score)
	setplayerinfo <player> gem_chord_hopo_score = ($<globalname>.gem_chord_hopo_score)
	setplayerinfo <player> gem_tap_score = ($<globalname>.gem_tap_score)
	setplayerinfo <player> sustain_beat_score = ($<globalname>.sustain_beat_score)
	setplayerinfo <player> multiplier_speed = ($<globalname>.multiplier_speed)
	setplayerinfo <player> min_multiplier = ($<globalname>.min_multiplier)
	setplayerinfo <player> star_power_multiplier = ($<globalname>.star_power_multiplier)
	setplayerinfo <player> star_power_gain_multiplier = ($<globalname>.star_power_gain_multiplier)
	setplayerinfo <player> star_power_per_note_streak = ($<globalname>.star_power_per_note_streak)
	setplayerinfo <player> crowd_meter_start_bonus = ($<globalname>.crowd_meter_start_bonus)
	setplayerinfo <player> miss_note_bonus_allowed = ($<globalname>.miss_note_bonus_allowed)
	setplayerinfo <player> miss_note_bonus_ms = ($<globalname>.miss_note_bonus_ms)
	setplayerinfo <player> 0x03e6e6e2 = ($<globalname>.0x03e6e6e2)
	setplayerinfo <player> multiplier_1 = ($<globalname>.multiplier_1)
	setplayerinfo <player> multiplier_2 = ($<globalname>.multiplier_2)
	setplayerinfo <player> multiplier_3 = ($<globalname>.multiplier_3)
	setplayerinfo <player> multiplier_4 = ($<globalname>.multiplier_4)
	setplayerinfo <player> multiplier_5 = ($<globalname>.multiplier_5)
	setplayerinfo <player> multiplier_6 = ($<globalname>.multiplier_6)
endscript

script add_character_scoring_attributes_to_player \{player = !i1768515945}
	getplayerinfo <player> score_attribute_level
	getplayerinfo <player> character_id
	switch (<character_id>)
		case gh_rocker_newmale
		<global_struct> = ($newmale_hero_info.power_global)
		case gh_rocker_2009
		<global_struct> = ($newfemale_hero_info.power_global)
		case gh_rocker_johnny
		<global_struct> = ($johnny_hero_info.power_global)
		case gh_rocker_axel
		<global_struct> = ($axel_hero_info.power_global)
		case gh_rocker_judy
		<global_struct> = ($judy_hero_info.power_global)
		case gh_rocker_pandora
		<global_struct> = ($pandora_hero_info.power_global)
		case gh_rocker_lars
		<global_struct> = ($lars_hero_info.power_global)
		case gh_rocker_casey
		<global_struct> = ($casey_hero_info.power_global)
		default
		return
	endswitch
	add_scoring_attributes_to_player player = <player> globalname = <global_struct> level = <score_attribute_level>
endscript

script add_scoring_attributes_to_player \{player = !i1768515945
		globalname = !q1768515945
		level = 1}
	formattext checksumname = levelchecksum 'level%d' d = <level>
	<level_array> = ($<globalname>.<levelchecksum>)
	<level_index> = 0
	getarraysize <level_array>
	begin
	<attrib_name> = (<level_array> [<level_index>].name)
	<attrib_value> = (<level_array> [<level_index>].value)
	getplayerinfo <player> <attrib_name>
	<scoring_attrib> = {}
	addparam structure_name = scoring_attrib name = <attrib_name> value = ((<...>.<attrib_name>) + <attrib_value>)
	setplayerinfo <player> <scoring_attrib>
	if (<attrib_name> = miss_note_bonus_allowed)
		getplayerinfo <player> band
		getbandinfo <band> <attrib_name>
		<scoring_attrib> = {}
		addparam structure_name = scoring_attrib name = <attrib_name> value = ((<...>.<attrib_name>) + <attrib_value>)
		setbandinfo <band> <scoring_attrib>
	endif
	<level_index> = (<level_index> + 1)
	repeat <array_size>
endscript

script print_player_scoring_info \{player = !i1768515945}
	getplayerinfo <player> score_attribute_level
	getplayerinfo <player> gem_score
	getplayerinfo <player> gem_hopo_score
	getplayerinfo <player> gem_chord_score
	getplayerinfo <player> gem_chord_hopo_score
	getplayerinfo <player> gem_tap_score
	getplayerinfo <player> sustain_beat_score
	getplayerinfo <player> multiplier_speed
	getplayerinfo <player> min_multiplier
	getplayerinfo <player> star_power_multiplier
	getplayerinfo <player> star_power_gain_multiplier
	getplayerinfo <player> star_power_per_note_streak
	getplayerinfo <player> crowd_meter_start_bonus
	getplayerinfo <player> miss_note_bonus_allowed
	getplayerinfo <player> miss_note_bonus_ms
	getplayerinfo <player> 0x03e6e6e2
	getplayerinfo <player> multiplier_1
	getplayerinfo <player> multiplier_2
	getplayerinfo <player> multiplier_3
	getplayerinfo <player> multiplier_4
	getplayerinfo <player> multiplier_5
	getplayerinfo <player> multiplier_6
	printstruct <...>
endscript

script apply_scoring_attributes_for_players 
	debug_globals = [
		'debug_sp_mult_%d'
		'debug_mult_max_%d'
		'debug_mult_enhance_%d'
		'debug_star_power_gain_multiplier_%d'
		'debug_sp_note_streak_%d'
		'debug_crowd_meter_start_bonus_%d'
		'debug_miss_note_bonus_%d'
		'debug_resurrection_lives_%d'
	]
	debug_names = [
		g_scoring_star_power_multiplier
		g_scoring_max_multiplier
		g_scoring_min_multiplier
		g_scoring_star_power_gain_multiplier
		g_scoring_star_power_per_note_streak
		g_scoring_crowd_meter_start_bonus
		g_scoring_miss_note_bonus
		g_scoring_resurrection
	]
	getarraysize <debug_globals>
	<num_debugs> = <array_size>
	gamemode_gettype
	getnumplayersingame \{local}
	if (<num_players> > 0)
		getfirstplayer \{local}
		begin
		set_scoring_attributes_to_player player = <player>
		if (<type> = career)
			<using_debug> = 0
			<idx> = 0
			begin
			formattext checksumname = sa_global (<debug_globals> [<idx>]) d = <player>
			if ($<sa_global> > 0)
				add_scoring_attributes_to_player player = <player> level = ($<sa_global>) globalname = (<debug_names> [<idx>])
				<using_debug> = 1
			endif
			<idx> = (<idx> + 1)
			repeat <num_debugs>
			if (<using_debug> = 0)
				add_character_scoring_attributes_to_player player = <player>
			endif
		endif
		getnextplayer player = <player> local
		repeat <num_players>
	endif
endscript

script debug_show_scoring_attributes \{parent = !q1768515945
		player = !i1768515945}
	if NOT screenelementexists id = <parent>
		return
	endif
	getplayerinfo <player> score_attribute_level
	getplayerinfo <player> multiplier_speed
	getplayerinfo <player> min_multiplier
	getplayerinfo <player> star_power_multiplier
	getplayerinfo <player> star_power_gain_multiplier
	getplayerinfo <player> star_power_per_note_streak
	getplayerinfo <player> crowd_meter_start_bonus
	getplayerinfo <player> miss_note_bonus_allowed
	getplayerinfo <player> miss_note_bonus_ms
	getplayerinfo <player> 0x03e6e6e2
	getplayerinfo <player> multiplier_1
	getplayerinfo <player> multiplier_2
	getplayerinfo <player> multiplier_3
	getplayerinfo <player> multiplier_4
	getplayerinfo <player> multiplier_5
	getplayerinfo <player> multiplier_6
	<default_props> = {type = textelement parent = <parent> font = fontgrid_title_a1 scale = 0.2 just = [left top]}
	<pos> = (-500.0, -100.0)
	<pos_increase> = (0.0, 20.0)
	createscreenelement {
		<default_props>
		text = qs(0x168007dc)
		pos = <pos>
		rgba = [200 10 10 255]
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0xca762e35) d = <score_attribute_level>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x5e066daa) d = <min_multiplier>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x71e0604a) d = <star_power_multiplier>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x57a9f1f4) d = <star_power_gain_multiplier>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0xbc96c9a5) d = <star_power_per_note_streak>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x5c37603c) d = <crowd_meter_start_bonus>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x54d7bb79) d = <miss_note_bonus_allowed>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x544b5142) d = <0x03e6e6e2>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x524fbe77) d = <multiplier_1>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x25d16c87) d = <multiplier_2>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0xbe7420e8) d = <multiplier_3>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0xcaecc967) d = <multiplier_4>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x51498508) d = <multiplier_5>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
	formattext textname = text qs(0x26d757f8) d = <multiplier_6>
	createscreenelement {
		<default_props>
		text = <text>
		pos = <pos>
	}
	<pos> = (<pos> + <pos_increase>)
endscript
