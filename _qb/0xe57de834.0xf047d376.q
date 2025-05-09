0x368f01c6 = null

script 0x68a3db82 
	requireparams \{[
			goal_struct
			goal_name
		]
		all}
	change 0x368f01c6 = <goal_name>
	gman_quickstartgoal goal_struct = <goal_struct> goal_name = <goal_name>
endscript

script 0xec51c3a0 
	gman_quickremovegoal goal_name = ($0x368f01c6)
	change \{0x368f01c6 = null}
endscript

script 0x95fe58ab 
	gman_passcheckpoint goal = ($0x368f01c6)
endscript

script 0x6395d918 
	generic_event_back
	spawnscriptnow \{0xec51c3a0}
endscript
