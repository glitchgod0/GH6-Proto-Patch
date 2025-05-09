g_quickplay_rewards_just_unlocked = [
]

script create_quickplay_rewards_atoms_array \{async = 0}
	getarraysize \{$award_point_progression}
	createlocalarray name = atoms type = struct size = <array_size>
	index = 0
	begin
	formattext checksumname = name 'quickplay_reward_%a_unlock' a = (<index> + 1) addtostringlookup = true
	depends_on = []
	addarrayelement array = <depends_on> element = {
		type = scr
		scr = progression_quickplay_check_reward_unlock
		params = {($award_point_progression [<index>]) savegame = <savegame>}
	}
	depends_on = <array>
	atom = {
		name = <name>
		type = scr
		atom_script = 0xd60327a2
		atom_params = {reward_data = ($award_point_progression [<index>]) reward_progression_index = <index> name = <name> savegame = <savegame>}
		depends_on = <depends_on>
	}
	setarrayelement arrayname = atoms index = <index> newvalue = <atom>
	index = (<index> + 1)
	conditional_async_wait async = <async> text = qs(0xb16bb15e)
	repeat <array_size>
	return completed_atoms_array = <atoms>
endscript

script progression_quickplay_check_reward_unlock 
	criteria_passed = 0
	getglobaltags career_progression_tags param = total_award_points savegame = <savegame> noassert = 1
	if (<total_award_points> >= <award_points>)
		return \{true}
	endif
	return \{false}
endscript

script 0xd60327a2 \{reward_data = 0x69696969
		reward_progression_index = !i1768515945
		savegame = !i1768515945}
	rewards_array = (<reward_data>.rewards)
	getarraysize <rewards_array>
	if (<array_size> > 0)
		index = 0
		begin
		0xd6692308 reward_struct = (<rewards_array> [<index>]) savegame = <savegame>
		<index> = (<index> + 1)
		repeat <array_size>
	endif
	reward_data = (<reward_data> + {reward_progression_index = <reward_progression_index>})
	progression_award_points_add_just_unlocked_item reward_struct = <reward_data> player_savegame = <savegame>
endscript

script progression_award_points_add_just_unlocked_item 
	gamemode_gettype
	if (<type> != quickplay)
		return
	endif
	temp_array = ($g_quickplay_rewards_just_unlocked)
	reward_struct = {<reward_struct> savegame = <player_savegame>}
	addarrayelement array = <temp_array> element = <reward_struct>
	change g_quickplay_rewards_just_unlocked = <array>
endscript

script progression_quickplay_get_rewards_just_unlocked \{player = -1}
	if (<player> = -1)
		return rewards_just_unlocked = ($g_quickplay_rewards_just_unlocked)
	endif
	printf \{'get rewards just unlocked'
		channel = jrdebug}
	getplayerinfo <player> controller
	getsavegamefromcontroller controller = <controller>
	array = []
	unlocks = ($g_quickplay_rewards_just_unlocked)
	getarraysize <unlocks>
	if (<array_size> > 0)
		i = 0
		begin
		if ((<unlocks> [<i>]).savegame = <savegame>)
			printf \{'adding one'
				channel = jrdebug}
			printstruct <...> channel = jrdebug
			addarrayelement array = <array> element = (<unlocks> [<i>])
		endif
		i = (<i> + 1)
		repeat <array_size>
	endif
	printf \{'done'
		channel = jrdebug}
	printstruct <...> channel = jrdebug
	return rewards_just_unlocked = <array>
endscript

script progression_quickplay_clear_rewards_just_unlocked 
	printf \{'CLEARING REWARDS'
		channel = jrdebug}
	change \{g_quickplay_rewards_just_unlocked = [
		]}
endscript

script quickplay_get_awards_for_song \{song_name = !q1768515945
		player = !i1768515945}
	if song_is_jamsession song = <song_name>
		return
	endif
	gman_getsongchallengeprops song_name = <song_name>
	instruments = [guitar , bass , drum , vocals , band]
	getarraysize <instruments>
	0x664a6c1c = <array_size>
	num_challenges = 0
	i = 0
	begin
	current_instrument = (<instruments> [<i>])
	challenges = (<challenge_props>.<current_instrument>)
	getarraysize <challenges>
	<num_challenges> = (<num_challenges> + <array_size>)
	i = (<i> + 1)
	repeat <0x664a6c1c>
	0xea0673c4 \{grade = 3}
	<awards_total> = (<award_points> * <num_challenges>)
	awards_earned = 0
	if NOT gotparam \{controller}
		getplayerinfo <player> controller
	endif
	getsavegamefromcontroller controller = <controller>
	getglobaltags savegame = <savegame> <song_name>
	i = 1
	begin
	if (<i> < 10)
		formattext checksumname = grade_checksum 'challenge0%s_grade' s = <i>
	else
		formattext checksumname = grade_checksum 'challenge%s_grade' s = <i>
	endif
	grade = (<...>.<grade_checksum>)
	awards_earned = (<awards_earned> + <grade>)
	i = (<i> + 1)
	repeat <num_challenges>
	return num_challenges = <num_challenges> awards_earned = <awards_earned> awards_total = <awards_total>
endscript

script quickplay_get_recent_award_points \{player = !i1768515945}
	getplayerinfo <player> recent_award_points
	return recent_award_points = <recent_award_points>
endscript

script quickplay_get_overall_awards_progress \{player = !i1768515945}
	get_current_progression_award_points savegame = <savegame>
	current_award_points_level = -1
	next_award_points_threshold = -1
	getarraysize ($award_point_progression)
	if (<array_size> > 0)
		<index> = 0
		begin
		award_struct = ($award_point_progression [<index>])
		if (<award_struct>.award_points > <total_award_points>)
			current_award_points_level = (<index> + 1)
			next_award_points_threshold = (<award_struct>.award_points)
			break
		endif
		index = (<index> + 1)
		repeat <array_size>
	endif
	if (<current_award_points_level> = -1)
		current_award_points_level = <array_size>
		next_award_points_threshold = <total_award_points>
	endif
	return {
		current_award_points_total = <total_award_points>
		current_award_points_level = <current_award_points_level>
		next_award_points_threshold = <next_award_points_threshold>
	}
endscript

script 0xea0673c4 \{grade = !i1768515945}
	return award_points = ($0x084270c2 [<grade> -1])
endscript

script quickplay_complete_all_current_challenges 
	getnumplayersingame \{local}
	getfirstplayer \{local}
	begin
	gman_getgoalsbyplayer player = <player>
	if (0 = <goals_by_player_size>)
		return
	endif
	index = 0
	begin
	gman_setpendinggrade goal = (<goals_by_player> [<index>]) grade = 3
	index = (<index> + 1)
	repeat <goals_by_player_size>
	getnextplayer player = <player> local
	repeat <num_players>
endscript

script quickplay_get_best_stars_for_song \{song = !q1768515945}
	<best_stars> = 0
	<instrument> = none
	getarraysize ($difficulty_list) param = difficulty_size
	<difficulty_index> = 0
	<instrument_list> = [guitar bass drum vocals band]
	get_song_prefix song = <song>
	if (<difficulty_size> > 0)
		begin
		<diff> = ($difficulty_list [<difficulty_index>])
		get_difficulty_text_nl difficulty = <diff>
		getarraysize <instrument_list> param = instrument_size
		<instrument_index> = 0
		begin
		<part> = (<instrument_list> [<instrument_index>])
		0x4cb6620f {
			song_prefix = <song_prefix>
			difficulty_text_nl = <difficulty_text_nl>
			part = ($instrument_list.<part>.text_nl)
		}
		if (<setlist_beststars> > <best_stars>)
			<best_stars> = <setlist_beststars>
			<instrument> = <part>
		endif
		<instrument_index> = (<instrument_index> + 1)
		repeat <instrument_size>
		<difficulty_index> = (<difficulty_index> + 1)
		repeat <difficulty_size>
	endif
	return best_stars = <best_stars> instrument = <instrument>
endscript
