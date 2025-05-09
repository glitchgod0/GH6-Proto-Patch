
script ui_create_privacy_policy \{type = !q1768515945}
	<text> = qs(0x00000000)
	switch (<type>)
		case facebook
		case twitter
		social_networks_get_privacy_policy
		<text> = <privacy_policy_text>
		default
		softassert qs(0x81a87aac) t = <type>
	endswitch
	createscreenelement {
		type = descinterface
		desc = 'privacy_policy'
		id = privacy_policy
		parent = root_window
		dlog_body_text = <text>
		event_handlers = [
			{pad_back generic_event_back}
		]
	}
	clean_up_user_control_helpers
	add_user_control_helper \{text = qs(0xaf4d5dd2)
		button = red
		z = 100000}
	launchevent \{type = unfocus
		target = current_menu}
endscript

script ui_destroy_privacy_policy 
	clean_up_user_control_helpers
	if screenelementexists \{id = privacy_policy}
		destroyscreenelement \{id = privacy_policy}
	endif
endscript
