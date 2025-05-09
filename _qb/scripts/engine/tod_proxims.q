se_brightness = 5
currenttodsettings = default_tod_manager

script tod_proxim_create_lightfx 
	screenfx_clearfxinstances \{viewport = 0}
	if insplitscreengame
		screenfx_clearfxinstances \{viewport = 0}
	endif
	tod_proxim_update_lightfx \{viewport = bg_viewport
		time = 0}
endscript

script tod_proxim_update_lightfx 
	tod_proxim_update_lightfx_viewport viewport = bg_viewport <...>
endscript

script toggle_default_sceenfx 
	tod_proxim_update_lightfx_viewport
endscript

script tod_proxim_update_lightfx_viewport \{fxparam = $default_tod_manager
		viewport = bg_viewport
		time = 1}
	screenfx_clearfxinstances viewport = <viewport>
	if structurecontains structure = <fxparam> screen_fx
		begin
		if getnextarrayelement (<fxparam>.screen_fx)
			screenfx_addfxinstance {
				viewport = <viewport>
				<element>
			}
		else
			break
		endif
		repeat
	endif
endscript

script tod_proxim_reapply_lightfx 
	tod_proxim_update_lightfx \{fxparam = $currenttodsettings
		time = 0.0}
endscript

script tod_proxim_apply_default 
	tod_proxim_update_lightfx \{fxparam = $default_tod_manager
		viewport = bg_viewport
		time = 0.0}
endscript

script tod_proxim_apply_bw_01 
	tod_proxim_update_lightfx \{fxparam = $bw_01_tod_manager
		viewport = bg_viewport
		time = 0.0}
endscript

script applyvenuetonemap_default 
	if NOT screenfx_fxinstanceexists viewport = <viewport> name = tone_map
		screenfx_addfxinstance {
			viewport = <viewport>
			name = tone_map
			scefname = tone_map
			type = tonemap
			texture = 'tex\\LUTs\\lut_default_dnc.dds'
		}
	else
		screenfx_updatefxinstanceparams {
			viewport = <viewport>
			name = tone_map
			scefname = tone_map
			type = tonemap
			texture = 'tex\\LUTs\\lut_default_dnc.dds'
		}
	endif
endscript

script venue_screenfx \{viewport = bg_viewport}
	if existspakmanmap \{map = zones}
		getpakmancurrent \{map = zones}
		switch <pak>
			default
			applyvenuetonemap_default {
				viewport = <viewport>
			}
		endswitch
	endif
endscript
