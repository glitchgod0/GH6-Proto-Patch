
script generic_scrollbar_wgt_initialize \{id = !q1768515945}
	<id> :se_getprops
	<scroll_height> = (<scroll_height_dims>.(0.0, 1.0))
	if <id> :desc_resolvealias name = alias_thumb_offset
		<resolved_id> :se_getprops
		<offset> = (<dims>.(0.0, 1.0))
		<scroll_height> = (<scroll_height> - <offset>)
	else
		scriptassert \{qs(0x7631f46d)}
	endif
	<id> :settags {
		scroll_height = <scroll_height>
	}
endscript

script generic_scrollbar_wgt_set_resolution \{id = !q1768515945
		num_elements = !i1768515945}
	if (<num_elements> > 1)
		<id> :getsingletag scroll_height
		<id> :settags {
			resolution = (<scroll_height> / (<num_elements> - 1))
		}
		<id> :se_setprops {
			alpha = 1.0
		}
	else
		<id> :se_setprops {
			alpha = 0.0
		}
	endif
endscript

script generic_scrollbar_wgt_update_thumb_pos \{id = !q1768515945
		index = -1
		dir = down
		count = 1}
	if <id> :getsingletag resolution
		if (<index> >= 0)
			<id> :se_setprops {
				scroll_thumb_pos = ((0.0, 1.0) * (<resolution> * <index>))
				time = 0.1
			}
		else
			<id> :se_getprops scroll_thumb_pos
			if (<dir> = down)
				<id> :se_setprops scroll_thumb_pos = (<scroll_thumb_pos> + (<resolution> * (0.0, 1.0) * <count>))
			else
				<id> :se_setprops scroll_thumb_pos = (<scroll_thumb_pos> - (<resolution> * (0.0, 1.0) * <count>))
			endif
		endif
	endif
endscript
