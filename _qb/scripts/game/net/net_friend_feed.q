friend_feed_defs = [
	{
		titleid = 5263
		def = gh6_friend_feed_def
	}
	{
		titleid = 5264
		def = gh6_friend_feed_def
	}
]
gh6_friend_feed_def = {
	game_variables = {
		retrievable = [
			{
				name = score
				type = int
			}
			{
				name = num_songs
				type = int
			}
			{
				name = star_count
				type = int
			}
			{
				name = instrument_type
				type = enumeration
				values = [
					{
						name = guitar
						value = qs(0x09048d9e)
					}
					{
						name = bass
						value = qs(0xb6237ee8)
					}
					{
						name = drums
						value = qs(0xbcbd3cf7)
					}
					{
						name = vocals
						value = qs(0x879f5b50)
					}
				]
			}
			{
				name = song_name
				type = function_lookup
				value = ff_get_song_string
			}
		]
		passable = [
			{
				name = encore_complete
				type = enumeration
				values = [
					{
						name = quest_chapter_pandora
						value = qs(0x0dee3094)
					}
					{
						name = quest_chapter_judy
						value = qs(0x5e7bf074)
					}
					{
						name = quest_chapter_casey
						value = qs(0x08eb1c35)
					}
					{
						name = quest_chapter_axel
						value = qs(0x30867e8d)
					}
					{
						name = quest_chapter_johnny
						value = qs(0x4d75ec17)
					}
					{
						name = quest_chapter_newfemale
						value = qs(0x35e65374)
					}
					{
						name = quest_chapter_newmale
						value = qs(0x3eec17e4)
					}
					{
						name = quest_chapter_lars
						value = qs(0x8fce59b7)
					}
					{
						name = quest_chapter_finale
						value = qs(0xb5bd032e)
					}
					{
						name = quest_chapter_demigod
						value = qs(0x865bc98d)
					}
				]
			}
			{
				name = item_type
				type = enumeration
				values = [
					{
						name = cas
						value = qs(0x3546f363)
					}
					{
						name = venue
						value = qs(0x09bc6def)
					}
					{
						name = venue_reward
						value = qs(0x09bc6def)
					}
					{
						name = character
						value = qs(0xe75bddf8)
					}
					{
						name = cheat
						value = qs(0xb55b2189)
					}
					{
						name = cas_texture
						value = qs(0x6761b7dc)
					}
				]
			}
		]
		do_not_send = [
			gamertag_string
		]
	}
	message_array = [
		{
			name = 0x95031b48
			consolidate = 1
			priority = 1
			shortcut = 0xe151797b
			cross_title = 1
			strings = [
				{
					type = `default`
					format_string = qs(0x29cca53e)
					string_items = [
						{
							name = a
							value = gamertag_string
						}
						{
							name = b
							value = instrument_type
						}
					]
				}
				{
					type = facebook
					format_string = qs(0x29cca53e)
					string_items = [
						{
							name = a
							value = gamertag_string
						}
						{
							name = b
							value = instrument_type
						}
					]
					image_url = qs(0x80ed4126)
				}
				{
					type = twitter
					format_string = qs(0xf7b85dc1)
					string_items = [
						{
							name = a
							value = gamertag_string
						}
						{
							name = b
							value = instrument_type
						}
					]
				}
			]
			passed_variables = [
			]
		}
		{
			name = cheated
			consolidate = 0
			priority = 1
			shortcut = none
			cross_title = 0
			strings = [
				{
					type = `default`
					format_string = qs(0x1d673475)
					string_items = [
						{
							name = a
							value = gamertag_string
						}
						{
							name = b
							value = song_name
						}
					]
				}
			]
			passed_variables = [
			]
		}
		{
			name = created_rocker
			consolidate = 0
			priority = 1
			shortcut = car
			cross_title = 0
			strings = [
				{
					type = `default`
					format_string = qs(0xef699da9)
					string_items = [
						{
							name = a
							value = gamertag_string
						}
					]
				}
			]
			passed_variables = [
			]
		}
		{
			name = encore_complete
			consolidate = 0
			priority = 1
			shortcut = car
			cross_title = 0
			strings = [
				{
					type = `default`
					format_string = qs(0xfbc8ae3e)
					string_items = [
						{
							name = a
							value = gamertag_string
						}
						{
							name = b
							value = encore_complete
						}
					]
				}
			]
			passed_variables = [
			]
		}
		{
			name = unlock_item_type
			consolidate = 0
			priority = 1
			shortcut = band_lobby
			cross_title = 0
			strings = [
				{
					type = `default`
					format_string = qs(0xfe5ff809)
					string_items = [
						{
							name = a
							value = gamertag_string
						}
						{
							name = b
							value = item_type
						}
					]
				}
			]
			passed_variables = [
				item_type
			]
		}
	]
}
g_friend_feed_extra_output = 0
g_friend_feed_additional_asserts = 0

script friend_feed_test 
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x76ecdc10)}
	endif
	if friend_feed_get_message_structure \{titleid = 5263
			msg_type = `default`
			event = unlock_item_type
			platform = xen
			item_type = cas
			out_param = the_string
			out_image = the_image
			controller_index = 0
			player = 1
			gamertag_string = 'derpy'}
		printf \{qs(0xd3c26582)}
	else
		printf \{qs(0x05731881)}
	endif
	printstruct <...>
endscript

script friend_feed_get_message_structure \{titleid = !i1768515945
		event = !q1768515945
		msg_type = !q1768515945
		controller_index = !i1768515945
		player = !i1768515945
		out_param = !q1768515945}
	printf \{qs(0x1b503bb8)}
	ret = true
	friend_feed_get_msg_def titleid = <titleid> event = <event> out_param = msg_def
	friend_feeed_get_variable_definitions titleid = <titleid> out_param = variable_defs
	if friend_feed_check_dynamic_params msg_def = <msg_def> <...>
		if friend_feed_get_msg_string_def msg_def = <msg_def> msg_type = <msg_type> out_param = string_def
			getarraysize (<string_def>.string_items)
			i = 0
			return_struct = {}
			begin
			value_to_get = (<string_def>.string_items [<i>].value)
			if friend_feed_should_add_variable variable = <value_to_get> titleid = <titleid>
				if NOT gotparam <value_to_get>
					if friend_feed_can_lookup_value variable_defs = <variable_defs> variable_name = <value_to_get>
						printf qs(0x06fb400d) d = <value_to_get>
					endif
					if ff_get_source_value controller_index = <controller_index> type = <value_to_get> player = <player>
						tmp_param = <value>
					else
						printf qs(0xc4979b50) s = <value_to_get>
						ret = false
						break
					endif
				else
					tmp_param = (<...>.<value_to_get>)
				endif
				if gotparam \{tmp_param}
					addparam structure_name = tmp_struct name = <value_to_get> value = <tmp_param>
					removeparameter \{tmp_param}
				endif
			endif
			i = (<i> + 1)
			repeat <array_size>
			if gotparam \{tmp_struct}
				addparam structure_name = return_struct name = <out_param> value = <tmp_struct>
			endif
		else
			printf qs(0x336319b4) d = <event> e = <msg_type>
		endif
	else
		ret = false
	endif
	return <ret> <return_struct>
endscript

script friend_feed_get_message_string_from_message \{platform = !q1768515945
		titleid = !i1768515945
		event = !q1768515945
		msg_type = !q1768515945
		msg = 0x69696969
		gamertag_string = 0x69696969
		out_string = !q1768515945
		out_params = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x1b1e5629)}
	endif
	ret = false
	if friend_feed_get_msg_def titleid = <titleid> event = <event> out_param = msg_def
		friend_feeed_get_variable_definitions titleid = <titleid> out_param = variable_defs
		if friend_feed_get_msg_string_def msg_def = <msg_def> msg_type = <msg_type> out_param = string_def
			msg_params = {<msg> gamertag_string = <gamertag_string>}
			if friend_feed_verify_all_params msg_params = <msg_params> string_def = <string_def>
				friend_feed_get_string_format_params msg_params = <msg_params> string_def = <string_def> variable_defs = <variable_defs> out_param = format_params
				formattext textname = tmp_string (<string_def>.format_string) <format_params>
				if gotparam \{tmp_string}
					addparam structure_name = return_struct name = <out_string> value = <tmp_string>
					addparam {
						structure_name = return_struct
						name = <out_params>
						value = {
							consolidate = (<msg_def>.consolidate)
							cross_title = (<msg_def>.cross_title)
							shortcut = (<msg_def>.shortcut)
							priority = (<msg_def>.priority)
						}
					}
					ret = true
				endif
			endif
		endif
	endif
	return <ret> <return_struct>
endscript

script friend_feed_get_message_string \{platform = !q1768515945
		titleid = !i1768515945
		player = !i1768515945
		controller_index = !i1768515945
		event = !q1768515945
		msg_type = !q1768515945
		out_param = !q1768515945}
	printf \{qs(0x3ce8cd3d)}
	ret = false
	getlocalgamertag controller = <controller_index>
	gamertag_string = <gamertag>
	removeparameter \{gamertag}
	friend_feed_get_msg_def titleid = <titleid> event = <event> out_param = msg_def
	friend_feeed_get_variable_definitions titleid = <titleid> out_param = variable_defs
	if friend_feed_get_msg_string_def msg_def = <msg_def> msg_type = <msg_type> out_param = string_def
		tmp_struct_pass = <...>
		addparam \{structure_name = tmp_struct_pass
			name = out_param
			value = msg_struct}
		if friend_feed_get_message_structure <tmp_struct_pass>
			msg_struct = {<msg_struct> gamertag_string = <gamertag_string>}
			if friend_feed_verify_all_params msg_params = <msg_struct> string_def = <string_def>
				friend_feed_get_string_format_params msg_params = <msg_struct> string_def = <string_def> variable_defs = <variable_defs> out_param = format_params
				formattext textname = tmp_string (<string_def>.format_string) <format_params>
				if gotparam \{tmp_string}
					addparam structure_name = return_struct name = <out_param> value = <tmp_string>
					if gotparam \{out_image}
						image_url = qs(0x00000000)
						friend_feed_get_message_image_url string_def = <string_def> out_param = image_url
						addparam structure_name = return_struct name = <out_image> value = <image_url>
					endif
					ret = true
				endif
			endif
		endif
	endif
	return <ret> <return_struct>
endscript

script friend_feed_test_all_messages {
	}
	printf \{qs(0x024306c7)}
	getarraysize ($friend_feed_defs)
	i = 0
	begin
	printf qs(0xf13d3432) d = ($friend_feed_defs [<i>].def)
	friend_feed_def = ($friend_feed_defs [<i>].def)
	friend_feed_test_definition feed_def = ($<friend_feed_def>) titleid = ($friend_feed_defs [<i>].titleid)
	i = (<i> + 1)
	repeat <array_size>
endscript

script friend_feed_get_message_image_url \{string_def = 0x69696969
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0xf2cbfe4e)}
	endif
	ret = false
	if structurecontains structure = <string_def> name = image_url
		tmp_image = (<string_def>.image_url)
		addparam structure_name = return_struct name = <out_param> value = <tmp_image>
		ret = true
	endif
	return <ret> <return_struct>
endscript

script friend_feed_test_definition \{feed_def = 0x69696969
		titleid = !i1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x877005da)}
	endif
	friend_feed_get_general_test_params feed_def = <feed_def> titleid = <titleid> out_param = test_params
	var_defs = (<feed_def>.game_variables)
	getarraysize (<feed_def>.message_array)
	i = 0
	begin
	appended_test_params = <test_params>
	addparam structure_name = appended_test_params name = event value = (<feed_def>.message_array [<i>].name)
	friend_feed_test_message feed_msg = (<feed_def>.message_array [<i>]) var_defs = <var_defs> test_params = <appended_test_params>
	i = (<i> + 1)
	repeat <array_size>
endscript

script friend_feed_get_general_test_params \{feed_def = 0x69696969
		titleid = !i1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x57479860)}
	endif
	ret = true
	tmp_struct = {}
	addparam \{structure_name = tmp_struct
		name = gamertag_string
		value = 'gamertag_string'}
	addparam structure_name = tmp_struct name = titleid value = <titleid>
	addparam \{structure_name = tmp_struct
		name = platform
		value = xbox360}
	addparam structure_name = return_struct name = <out_param> value = <tmp_struct>
	return <ret> <return_struct>
endscript

script friend_feed_test_message \{feed_msg = 0x69696969
		var_defs = 0x69696969
		test_params = 0x69696969}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0xd391be37)}
	endif
	printf qs(0x7c1e2320) d = (<feed_msg>.name)
	passed_vars = (<feed_msg>.passed_variables)
	getarraysize (<feed_msg>.strings)
	i = 0
	begin
	printf qs(0x9a47b7c1) d = (<feed_msg>.strings [<i>].type)
	appended_test_params = <test_params>
	addparam structure_name = appended_test_params name = msg_type value = (<feed_msg>.strings [<i>].type)
	if friend_feed_test_message_string {
			msg_string = (<feed_msg>.strings [<i>])
			var_defs = <var_defs>
			passed_vars = <passed_vars>
			test_params = <appended_test_params>
			out_param = test_string
		}
		printf qs(0x63852812) a = <test_string>
	else
		printf \{qs(0x0e98f901)}
	endif
	i = (<i> + 1)
	repeat <array_size>
endscript

script friend_feed_test_message_string \{msg_string = 0x69696969
		var_defs = 0x69696969
		passed_vars = !a1768515945
		test_params = 0x69696969
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x1f0bd697)}
	endif
	ret = false
	if friend_feed_generate_dummy_message passed_vars = <passed_vars> string_def = <msg_string> var_defs = <var_defs> titleid = (<test_params>.titleid) out_param = dummy_msg_struct
		if friend_feed_get_message_string_from_message {
				<test_params>
				msg = <dummy_msg_struct>
				out_string = tmp_string
				out_params = tmp_params
			}
			addparam structure_name = return_struct name = <out_param> value = <tmp_string>
			ret = true
		else
		endif
	else
		printf \{qs(0x575a8c20)}
	endif
	return <ret> <return_struct>
endscript

script friend_feed_generate_dummy_message \{string_def = 0x69696969
		var_defs = 0x69696969
		passed_vars = !a1768515945
		titleid = !i1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0xe00c010f)}
	endif
	ret = true
	getarraysize (<string_def>.string_items)
	i = 0
	return_struct = {}
	tmp_struct = {}
	begin
	value_to_add = (<string_def>.string_items [<i>].value)
	if friend_feed_should_add_variable titleid = <titleid> variable = <value_to_add>
		if friend_feed_find_variable_definition variable_defs = <var_defs> variable_name = <value_to_add> out_param = variable_def
		else
			printf qs(0x4270be98) d = <value_to_add>
		endif
		formattext textname = dummy_value qs(0x35b12509) a = <value_to_add> dontassertforchecksums
		addparam structure_name = tmp_struct name = <value_to_add> value = <dummy_value>
	endif
	i = (<i> + 1)
	repeat <array_size>
	getarraysize <passed_vars>
	if (<array_size> > 0)
		i = 0
		begin
		value_to_add = (<passed_vars> [<i>])
		formattext textname = dummy_value qs(0x35b12509) a = <value_to_add> dontassertforchecksums
		addparam structure_name = tmp_struct name = <value_to_add> value = <dummy_value>
		i = (<i> + 1)
		repeat <array_size>
	endif
	if gotparam \{tmp_struct}
		addparam structure_name = return_struct name = <out_param> value = <tmp_struct>
	endif
	return <ret> <return_struct>
endscript

script friend_feed_lookup_value_from_checksum \{variable_defs = 0x69696969
		variable_name = !q1768515945
		variable_value = !q1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x87e34134)}
	endif
	ret = false
	if friend_feed_find_variable_definition variable_defs = <variable_defs> variable_name = <variable_name> out_param = variable_def
		if checksumequals a = (<variable_def>.type) b = enumeration
			getarraysize (<variable_def>.values)
			i = 0
			begin
			if checksumequals a = (<variable_def>.values [<i>].name) b = <variable_value>
				addparam structure_name = return_struct name = <out_param> value = (<variable_def>.values [<i>].value)
				ret = true
				break
			endif
			i = (<i> + 1)
			repeat <array_size>
		elseif checksumequals a = (<variable_def>.type) b = function_lookup
			function_to_call = (<variable_def>.value)
			if <function_to_call> param = <variable_value>
				addparam structure_name = return_struct name = <out_param> value = <result>
				ret = true
			endif
		else
			printf qs(0x6ff71438) d = (<variable_def>.type) c = <variable_name>
		endif
	endif
	return <ret> <return_struct>
endscript

script friend_feed_find_variable_definition \{variable_defs = 0x69696969
		variable_name = !q1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x0a42c467)}
	endif
	ret = false
	getarraysize (<variable_defs>.retrievable)
	if (<array_size> > 0)
		i = 0
		begin
		if checksumequals a = (<variable_defs>.retrievable [<i>].name) b = <variable_name>
			addparam structure_name = return_struct name = <out_param> value = (<variable_defs>.retrievable [<i>])
			ret = true
			break
		endif
		i = (<i> + 1)
		repeat <array_size>
	endif
	if (<ret> = false)
		getarraysize (<variable_defs>.passable)
		if (<array_size> > 0)
			i = 0
			begin
			if checksumequals a = (<variable_defs>.passable [<i>].name) b = <variable_name>
				addparam structure_name = return_struct name = <out_param> value = (<variable_defs>.passable [<i>])
				ret = true
				break
			endif
			i = (<i> + 1)
			repeat <array_size>
		endif
	endif
	return <ret> <return_struct>
endscript

script friend_feeed_get_variable_definitions \{titleid = !i1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x3f091577)}
	endif
	ret = false
	ret = false
	if friend_feed_get_product_feed_def titleid = <titleid> out_param = feed_def
		addparam structure_name = return_struct name = <out_param> value = (<feed_def>.game_variables)
		ret = true
	endif
	return <ret> <return_struct>
endscript

script friend_feed_should_add_variable \{variable = !q1768515945
		titleid = !i1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x1265d423)}
	endif
	ret = true
	if friend_feed_get_product_feed_def titleid = <titleid> out_param = feed_def
		getarraysize (<feed_def>.game_variables.do_not_send)
		i = 0
		begin
		if checksumequals a = <variable> b = (<feed_def>.game_variables.do_not_send [<i>])
			ret = false
			break
		endif
		i = (<i> + 1)
		repeat <array_size>
	endif
	return <ret>
endscript

script friend_feed_get_string_format_params \{msg_params = 0x69696969
		string_def = 0x69696969
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x4b858e4d)}
	endif
	ret = true
	getarraysize (<string_def>.string_items)
	i = 0
	begin
	value_name = (<string_def>.string_items [<i>].value)
	if ischecksum (<msg_params>.<value_name>)
		if friend_feed_lookup_value_from_checksum {
				variable_defs = <variable_defs>
				variable_name = <value_name>
				variable_value = (<msg_params>.<value_name>)
				out_param = tmp_value
			}
			addparam structure_name = tmp_struct name = (<string_def>.string_items [<i>].name) value = <tmp_value>
		else
			scriptassert qs(0x7149c3f0) d = <value_name>
		endif
	else
		addparam structure_name = tmp_struct name = (<string_def>.string_items [<i>].name) value = (<msg_params>.<value_name>)
	endif
	i = (<i> + 1)
	repeat <array_size>
	addparam structure_name = return_struct name = <out_param> value = <tmp_struct>
	return <ret> <return_struct>
endscript

script friend_feed_can_lookup_value \{variable_defs = 0x69696969
		variable_name = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x42c3c36c)}
	endif
	ret = false
	getarraysize (<variable_defs>.retrievable)
	i = 0
	begin
	if checksumequals a = (<variable_defs>.retrievable [<i>].name) b = <variable_name>
		ret = true
		break
	endif
	repeat <array_size>
	return <ret>
endscript

script friend_feed_verify_all_params \{msg_params = 0x69696969
		string_def = 0x69696969}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x2ef5ba87)}
	endif
	ret = true
	getarraysize (<string_def>.string_items)
	i = 0
	begin
	if NOT structurecontains structure = <msg_params> name = (<string_def>.string_items [<i>].value)
		printf qs(0xa7c5cf1f) d = (<string_def>.string_items [<i>].value)
		printstruct <msg_params>
		ret = false
		break
	endif
	i = (<i> + 1)
	repeat <array_size>
	return <ret>
endscript

script friend_feed_get_msg_string_def \{msg_def = 0x69696969
		msg_type = !q1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x3a4a1c8f)}
	endif
	ret = false
	getarraysize (<msg_def>.strings)
	i = 0
	begin
	if checksumequals a = (<msg_def>.strings [<i>].type) b = <msg_type>
		ret = true
		addparam structure_name = return_struct name = <out_param> value = (<msg_def>.strings [<i>])
		break
	endif
	i = (<i> + 1)
	repeat <array_size>
	return <ret> <return_struct>
endscript

script friend_feed_check_dynamic_params \{msg_def = 0x69696969}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0xf97cbf95)}
	endif
	ret = true
	getarraysize (<msg_def>.passed_variables)
	if (0 < <array_size>)
		i = 0
		begin
		if NOT gotparam (<msg_def>.passed_variables [<i>])
			printf qs(0xfaefa2eb) d = (<msg_def>.passed_variables [<i>])
			ret = false
		endif
		repeat <array_size>
	endif
	return <ret>
endscript

script friend_feed_get_msg_def \{titleid = !i1768515945
		event = !q1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x495128c4)}
	endif
	ret = false
	if friend_feed_get_product_msgs titleid = <titleid> out_param = product_msgs
		getarraysize <product_msgs>
		i = 0
		begin
		if checksumequals a = (<product_msgs> [<i>].name) b = <event>
			ret = true
			addparam structure_name = return_struct name = <out_param> value = (<product_msgs> [<i>])
		endif
		i = (<i> + 1)
		repeat <array_size>
	endif
	return <ret> <return_struct>
endscript

script friend_feed_get_product_msgs \{titleid = !i1768515945
		out_param = !q1768515945}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x3decb5c8)}
	endif
	ret = false
	if friend_feed_get_product_feed_def titleid = <titleid> out_param = feed_def
		addparam structure_name = return_struct name = <out_param> value = (<feed_def>.message_array)
		ret = true
	endif
	return <ret> <return_struct>
endscript

script friend_feed_get_product_feed_def {
		titleid = <titleid>
		0x54 out_param
	}
	if ($g_friend_feed_extra_output = 1)
		printf \{qs(0x2ee7a414)}
	endif
	ret = false
	feed_def = null
	getarraysize ($friend_feed_defs)
	i = 0
	begin
	if (($friend_feed_defs [<i>].titleid) = <titleid>)
		friend_feed_def = ($friend_feed_defs [<i>].def)
		ret = true
		break
	endif
	i = (<i> + 1)
	repeat <array_size>
	addparam structure_name = return_struct name = <out_param> value = ($<friend_feed_def>)
	return <ret> <return_struct>
endscript
