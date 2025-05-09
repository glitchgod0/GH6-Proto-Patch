
script quest_progression_create_chapter_atoms_array \{savegame = !i1768515945
		async = 0}
	<atoms> = []
	<chapter_num> = 1
	<unlock_index> = 0
	getarraysize \{$quest_progression_unlocks}
	<unlocks_size> = <array_size>
	begin
	<inner_index> = 0
	getarraysize ($quest_progression_unlocks [<unlock_index>])
	begin
	formattext checksumname = name 'chapter_%a_unlock' a = <chapter_num> addtostringlookup = true
	depends_on = []
	addarrayelement array = <depends_on> element = {
		type = scr
		scr = 0x15026426
		params = {unlock_index = <unlock_index> savegame = <savegame>}
	}
	<depends_on> = <array>
	atom = {
		name = <name>
		type = scr
		atom_script = quest_progression_career_do_chapter_unlock
		atom_params = {chapter = ($quest_progression_unlocks [<unlock_index>] [<inner_index>]) chapter_num = <chapter_num> savegame = <savegame>}
		depends_on = <depends_on>
	}
	addarrayelement array = <atoms> element = <atom>
	<atoms> = <array>
	<chapter_num> = (<chapter_num> + 1)
	<inner_index> = (<inner_index> + 1)
	repeat <array_size>
	<unlock_index> = (<unlock_index> + 1)
	conditional_async_wait async = <async> text = qs(0x43c3e6a9)
	repeat <unlocks_size>
	return chapter_atoms = <atoms>
endscript

script 0x04d11016 \{savegame = !i1768515945
		async = 0}
	<atoms> = []
	<chapter_num> = 1
	<unlock_index> = 0
	getarraysize \{$quest_progression_unlocks}
	<unlocks_size> = <array_size>
	begin
	<inner_index> = 0
	getarraysize ($quest_progression_unlocks [<unlock_index>])
	begin
	formattext checksumname = name 'chapter_encore_%a_unlock' a = <chapter_num> addtostringlookup = true
	depends_on = []
	addarrayelement array = <depends_on> element = {
		type = scr
		scr = 0x7f0e6656
		params = {chapter = ($quest_progression_unlocks [<unlock_index>] [<inner_index>]) savegame = <savegame>}
	}
	<depends_on> = <array>
	atom = {
		name = <name>
		type = scr
		atom_script = quest_progression_career_do_chapter_unlock
		atom_params = {chapter = ($quest_progression_unlocks [<unlock_index>] [<inner_index>]) chapter_num = <chapter_num> savegame = <savegame>}
		depends_on = <depends_on>
	}
	addarrayelement array = <atoms> element = <atom>
	<atoms> = <array>
	<chapter_num> = (<chapter_num> + 1)
	<inner_index> = (<inner_index> + 1)
	repeat <array_size>
	<unlock_index> = (<unlock_index> + 1)
	conditional_async_wait async = <async> text = qs(0x43c3e6a9)
	repeat <unlocks_size>
	return chapter_atoms = <atoms>
endscript

script 0x15026426 \{unlock_index = !i1768515945
		savegame = !i1768515945}
	quest_progression_get_number_of_completed_chapters savegame = <savegame>
	<required_unlocked> = ($quest_progression_thresholds [<unlock_index>])
	if (<number_of_unlocked_chapters> >= <required_unlocked>)
		return \{true}
	endif
	return \{false}
endscript

script quest_progression_career_do_chapter_unlock \{chapter = !q1768515945
		savegame = !i1768515945}
	<chapter_name> = ($<chapter>.name)
	quest_progression_set_chapter_tags savegame = <savegame> chapter_global = <chapter> params = {unlocked = 1}
	<venue_name> = ($levelzones.($<chapter>.venue).name)
	formattext checksumname = venue_checksum 'venue_%s' s = <venue_name>
	setglobaltags <venue_checksum> savegame = <savegame> params = {unlocked = 1} progression = true
	if NOT ($<chapter>.rocker_id = gh_rocker_demigod)
		unlock_profile id = ($<chapter>.rocker_id) savegame = <savegame>
	endif
endscript

script 0x7f0e6656 \{unlock_index = !i1768515945
		savegame = !i1768515945}
endscript

script quest_progression_get_number_of_completed_chapters \{savegame = !i1768515945}
	<number_of_unlocked_chapters> = 0
	<unlock_index> = 0
	getarraysize \{$quest_progression_unlocks}
	<unlocks_size> = <array_size>
	begin
	<inner_index> = 0
	getarraysize ($quest_progression_unlocks [<unlock_index>])
	<inner_size> = <array_size>
	begin
	<chapter> = ($quest_progression_unlocks [<unlock_index>] [<inner_index>])
	<chapter_name> = ($<chapter>.name)
	quest_progression_get_chapter_tag savegame = <savegame> chapter_global = <chapter> param = completed
	if (<completed> = 1)
		<number_of_unlocked_chapters> = (<number_of_unlocked_chapters> + 1)
	endif
	<inner_index> = (<inner_index> + 1)
	repeat <inner_size>
	<unlock_index> = (<unlock_index> + 1)
	repeat <unlocks_size>
	return number_of_unlocked_chapters = <number_of_unlocked_chapters>
endscript

script quest_progression_get_number_of_stars_earned \{savegame = !i1768515945
		chapter = !q1768515945}
	<chapter_name> = ($<chapter>.name)
	<songs_array> = ($<chapter>.songs)
	<stars_earned> = 0
	getarraysize <songs_array>
	<idx> = 0
	begin
	<song> = (<songs_array> [<idx>])
	get_song_name song = <song>
	format_career_song_gigtag chapter_name = <chapter_name> song_name = <song_name>
	getglobaltags savegame = <savegame> <song_gigtag> param = stars
	if (<stars> > 0)
		<stars_earned> = (<stars_earned> + <stars>)
	endif
	<idx> = (<idx> + 1)
	repeat <array_size>
	return stars_earned = <stars_earned>
endscript

script for_each_quest_progression_unlock \{callback = !q1768515945}
	<outer_index> = 0
	<chapter_num> = 1
	getarraysize \{$quest_progression_unlocks}
	<unlocks_size> = <array_size>
	begin
	<inner_index> = 0
	getarraysize ($quest_progression_unlocks [<outer_index>])
	begin
	<chapter> = ($quest_progression_unlocks [<outer_index>] [<inner_index>])
	<callback> chapter_global = <chapter> chapter_num = <chapter_num>
	<chapter_num> = (<chapter_num> + 1)
	<inner_index> = (<inner_index> + 1)
	repeat <array_size>
	<outer_index> = (<outer_index> + 1)
	repeat <unlocks_size>
endscript

script quest_progression_get_num_tags 
	<num_gigtags> = 0
	<num_gigsongtags> = 0
	getarraysize ($quest_progression_unlocks)
	<progression_unlocks_size> = <array_size>
	<index> = 0
	begin
	<chapter_array> = ($quest_progression_unlocks [<index>])
	getarraysize <chapter_array>
	<chapter_array_size> = <array_size>
	<num_gigtags> = (<num_gigtags> + <array_size>)
	<chapter_index> = 0
	begin
	<songs_struct> = (<chapter_array> [<chapter_index>])
	getarraysize ($<songs_struct>.songs)
	<num_gigsongtags> = (<num_gigsongtags> + <array_size>)
	<chapter_index> = (<chapter_index> + 1)
	repeat <chapter_array_size>
	<index> = (<index> + 1)
	repeat <progression_unlocks_size>
	return num_gigtags = <num_gigtags> num_gigsongtags = <num_gigsongtags>
endscript

script quest_progression_check_for_chapter_complete \{savegame = !i1768515945
		chapter_global = !q1768515945}
	<num_songs_completed> = 0
	<total_stars> = 0
	<chapter_name> = ($<chapter_global>.name)
	<songs_array> = ($<chapter_global>.songs)
	getarraysize <songs_array>
	<song_array_size> = <array_size>
	<song_index> = 0
	begin
	<song> = (<songs_array> [<song_index>])
	get_song_name song = <song>
	format_career_song_gigtag chapter_name = <chapter_name> song_name = <song_name>
	getglobaltags savegame = <savegame> <song_gigtag> param = stars
	if (<stars> > 0)
		<total_stars> = (<total_stars> + <stars>)
	endif
	<song_index> = (<song_index> + 1)
	repeat <song_array_size>
	get_song_name song = ($<chapter_global>.encore)
	format_career_song_gigtag chapter_name = <chapter_name> song_name = <song_name>
	getglobaltags savegame = <savegame> <song_gigtag> param = stars
	if (<stars> > 0)
		return true total_stars = <total_stars>
	endif
	return false total_stars = <total_stars>
endscript

script quest_progression_set_chapter_tags \{savegame = !i1768515945
		chapter_global = !q1768515945
		params = 0x69696969}
	<chapter_name> = ($<chapter_global>.name)
	formattext checksumname = chapter_unlock 'quest_chapter_%s' s = <chapter_name>
	setglobaltags <chapter_unlock> savegame = <savegame> params = <params> progression = true
endscript

script quest_progression_get_chapter_tag \{savegame = !i1768515945
		chapter_global = !q1768515945
		param = !q1768515945}
	<chapter_name> = ($<chapter_global>.name)
	formattext checksumname = chapter_unlock 'quest_chapter_%s' s = <chapter_name>
	getglobaltags <chapter_unlock> savegame = <savegame> param = <param>
	<struct> = {}
	addparam structure_name = struct name = <param> value = (<...>.<param>)
	return <struct>
endscript

script quest_progression_get_encore_stars_required \{chapter_global = !q1768515945}
	return encore_stars_required = ($<chapter_global>.stars_for_encore)
endscript

script quest_progression_get_transition_level_name 
	formattext checksumname = transition_level_name '%aTran' a = ($levelzones.$current_level.name)
	return transition_level_name = <transition_level_name>
endscript

script quest_progression_is_song_transformation \{song = !q1768515945}
	quest_progression_get_transition_level_name
	if (<song> = <transition_level_name>)
		return \{true}
	endif
	return \{false}
endscript

script quest_progression_check_for_transformation_encore 
	playlist_getcurrentsong
	if quest_progression_is_song_transformation song = <current_song>
		return \{true}
	endif
	return \{false}
endscript

script quest_progression_add_transformation_songs \{chapter_global = !q1768515945}
	quest_progression_get_transition_level_name
	playlist_addsong song = <transition_level_name> insert_at = back
	playlist_addsong song = ($<chapter_global>.encore) insert_at = back
endscript

script quest_progression_reset_career_progression_tags {
		savegame = ($primary_controller)
	}
	setglobaltags savegame = <savegame> career_progression_tags params = {encore_ready = 0} progression = true
endscript

script quest_progression_transform_character 
	quest_progression_set_player_score_attribute \{level = 2}
endscript

script quest_progression_set_player_score_attribute \{level = !i1768515945}
	getnumplayersingame \{local}
	if (<num_players> > 0)
		getfirstplayer \{local}
		begin
		getplayerinfo <player> controller
		if (<controller> = $primary_controller)
			setplayerinfo <player> score_attribute_level = <level>
			break
		endif
		getnextplayer \{local}
		repeat <num_players>
	endif
endscript

script quest_progression_check_for_transformation \{player = !i1768515945}
	getplayerinfo <player> controller
	getsavegamefromcontroller controller = <controller>
	getglobaltags savegame = <savegame> career_progression_tags param = current_chapter
	<chapter_name> = ($<current_chapter>.name)
	get_song_name song = ($<current_chapter>.encore)
	format_career_song_gigtag chapter_name = <chapter_name> song_name = <song_name>
	getglobaltags savegame = <savegame> <song_gigtag> param = stars
	if (<stars> > 0)
		return \{true}
	endif
	return \{false}
endscript
