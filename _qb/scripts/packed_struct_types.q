max_temporary_profiles_small = 20
max_temporary_profiles_large = 20
g_max_song_globaltag_plays = 4095

script get_savegame_constants 
	getsonglistsize \{on_disc_only = true}
	printf 'Songs on disc: %a' a = <array_size>
	num_songs = (86 + 164 + 85 + 52 + 48 + 50 + 255 + 85 + 60 + 60 + 60)
	<num_songs> = (<num_songs> + 255 + 85 + 200)
	if (<num_songs> > 1600)
		scriptassert \{'1600 song assumption is no longer good'}
	endif
	num_songs = 1600
	printf 'Total songs: %b' b = <num_songs>
	num_parts = 5
	num_singleplayer_parts = 4
	num_diffs = 5
	num_completetags = 64
	num_unlockedtags = 256
	getarraysize ($levelzonearray)
	num_venuetags = ((<array_size> + 1) * 2)
	<num_gigtags> = 0
	<num_gigsongtags> = 0
	quest_progression_get_num_tags
	num_songtags_global = (<num_songs>)
	getarraysize ($preset_musician_profiles_modifiable)
	num_preset_profiles = <array_size>
	getarraysize ($preset_musician_profiles_ghrockers)
	num_preset_profiles = (<num_preset_profiles> + <array_size>)
	max_challenge_grade = 3
	if isxenon
		num_preset_profiles = (<num_preset_profiles> + 1)
	endif
	max_global_structs = (
		($max_num_create_a_rockers) +
		<num_preset_profiles> +
		($max_num_logo_saves) +
		(($max_num_instrument_saves) * 4) +
		<num_completetags> +
		<num_unlockedtags> +
		<num_songtags_global> +
		64
	)
	<global_buckets> = 24593
	max_progression_structs = (
		<num_venuetags> +
		<num_gigtags> +
		<num_gigsongtags> +
		64
	)
	<progression_buckets> = 389
	return <...>
endscript

script init_packed_structs \{globaltag_sets = 1}
	get_savegame_constants
	packed_compression = (2.0 / 3.0)
	max_player_score = (2147483647)
	min_stars = 0
	max_quickplay_stars = 6
	max_career_stars = 15
	pushmemprofile \{'packedstructs'}
	setuppackedstructtypes {
		types =
		[
			{
				name = createarocker
				pool_size = (<num_savegames> * ($max_num_create_a_rockers))
				buffer_size = (21000 * <packed_compression>)
			}
			{
				name = presetcars
				pool_size = (<num_savegames> * <num_preset_profiles>)
				buffer_size = (13500 * <packed_compression>)
			}
			{
				name = logos
				pool_size = (<num_savegames> * ($max_num_logo_saves))
				buffer_size = (1850 * <packed_compression>)
			}
			{
				name = guitars
				pool_size = (<num_savegames> * ($max_num_instrument_saves))
				buffer_size = (4300 * <packed_compression>)
			}
			{
				name = basses
				pool_size = (<num_savegames> * ($max_num_instrument_saves))
				buffer_size = (4300 * <packed_compression>)
			}
			{
				name = drums
				pool_size = (<num_savegames> * ($max_num_instrument_saves))
				buffer_size = (2000 * <packed_compression>)
			}
			{
				name = vocals
				pool_size = (<num_savegames> * ($max_num_instrument_saves))
				buffer_size = 150
			}
			{
				name = completetags
				pool_size = (<num_completetags> * <num_savegames>)
				fields =
				[
					{
						name = complete
						type = bool
					}
				]
			}
			{
				name = unlockedtags
				pool_size = (<num_unlockedtags> * <num_savegames>)
				fields =
				[
					{
						name = unlocked
						type = bool
					}
				]
			}
			{
				name = venuetags
				pool_size = (<num_venuetags> * <num_savegames>)
				fields =
				[
					{
						name = unlocked
						type = bool
					}
					{
						name = venue_stars
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
				]
			}
			{
				name = gigtags
				pool_size = (<num_gigtags> * <num_savegames>)
				fields =
				[
					{
						name = unlocked
						type = bool
					}
					{
						name = has_been_played
						type = bool
					}
					{
						name = completed
						type = bool
					}
					{
						name = started
						type = bool
					}
					{
						name = encore_unlocked
						type = bool
					}
				]
			}
			{
				name = gigsongtags
				pool_size = (<num_gigsongtags> * <num_savegames>)
				fields =
				[
					{
						name = stars
						type = int
						low_limit = <min_stars>
						high_limit = <max_career_stars>
						default_value = 0
					}
				]
			}
			{
				name = songtags_global
				pool_size = (<num_songtags_global> * <num_savegames>)
				fields =
				[
					{
						name = challenge01_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge02_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge03_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge04_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge05_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge06_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge07_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge08_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge09_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge10_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge11_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge12_best_score
						type = int
						low_limit = 0
						high_limit = <max_player_score>
						default_value = 0
					}
					{
						name = challenge01_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge02_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge03_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge04_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge05_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge06_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge07_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge08_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge09_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge10_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge11_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = challenge12_grade
						type = int
						low_limit = 0
						high_limit = <max_challenge_grade>
						default_value = 0
					}
					{
						name = num_times_played
						type = int
						low_limit = 0
						high_limit = $g_max_song_globaltag_plays
						default_value = 0
					}
					{
						name = unlocked
						type = bool
						default_value = 0
					}
					{
						name = available_on_other_client
						type = bool
						default_value = 0
					}
					{
						name = setlist_bestscore_guitar_beginner
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_guitar_beginner
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_guitar_beginner
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_guitar_easy
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_guitar_easy
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_guitar_easy
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_guitar_medium
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_guitar_medium
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_guitar_medium
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_guitar_hard
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_guitar_hard
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_guitar_hard
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_guitar_expert
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_guitar_expert
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_guitar_expert
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_bass_beginner
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_bass_beginner
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_bass_beginner
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_bass_easy
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_bass_easy
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_bass_easy
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_bass_medium
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_bass_medium
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_bass_medium
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_bass_hard
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_bass_hard
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_bass_hard
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_bass_expert
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_bass_expert
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_bass_expert
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_drum_beginner
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_drum_beginner
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_drum_beginner
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_drum_easy
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_drum_easy
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_drum_easy
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_drum_medium
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_drum_medium
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_drum_medium
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_drum_hard
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_drum_hard
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_drum_hard
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_drum_expert
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_drum_expert
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_drum_expert
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_vocals_beginner
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_vocals_beginner
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_vocals_beginner
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_vocals_easy
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_vocals_easy
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_vocals_easy
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_vocals_medium
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_vocals_medium
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_vocals_medium
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_vocals_hard
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_vocals_hard
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_vocals_hard
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_vocals_expert
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_vocals_expert
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_vocals_expert
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_band_beginner
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_band_beginner
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_band_beginner
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_band_easy
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_band_easy
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_band_easy
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_band_medium
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_band_medium
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_band_medium
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_band_hard
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_band_hard
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_band_hard
						type = int
						low_limit = 0
						high_limit = 100
					}
					{
						name = setlist_bestscore_band_expert
						type = int
						low_limit = 0
						high_limit = <max_player_score>
					}
					{
						name = setlist_beststars_band_expert
						type = int
						low_limit = <min_stars>
						high_limit = <max_quickplay_stars>
					}
					{
						name = setlist_bestpercentage_band_expert
						type = int
						low_limit = 0
						high_limit = 100
					}
				]
			}
			{
				name = temporary_profiles_large
				pool_size = $max_temporary_profiles_large
				buffer_size = (21000 * <packed_compression>)
			}
			{
				name = temporary_profiles_small
				pool_size = $max_temporary_profiles_small
				buffer_size = (3072 * <packed_compression>)
			}
		]
	}
	popmemprofile
endscript
