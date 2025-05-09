goal_types = [
	playable
	testing
]
goal_type_info = {
	core = {
		type = core
		name = qs(0x56b5400b)
	}
	game_mode = {
		type = game_mode
		name = qs(0xa61ab41d)
	}
	quickplay_challenge = {
		type = quickplay_challenge
		name = qs(0x00863293)
	}
	challenge = {
		type = challenge
		name = qs(0x2b2138f9)
	}
	testing = {
		type = testing
		name = qs(0x718ed750)
	}
}

script goal_get_type_info 
	requireparams \{[
			goal
		]
		all}
	gman_getgoaltype goal = <goal>
	return goal_type_info = ($goal_type_info.<goal_type>)
endscript
