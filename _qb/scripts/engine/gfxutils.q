isolate_2d_render = 0
pix_output = 0

script hiresscreenshot \{scale = 1}
	pausegame
	setslomo \{visualeffects = 0.0}
	getcurrentcameraobject
	<cameraid> = <camid>
	printstruct <...>
	<i> = 0
	wait \{30
		frames
		ignoreslomo}
	printf \{qs(0xeb008437)}
	begin
	<j> = 0
	begin
	printf \{qs(0x9f298246)}
	formattext textname = text 'hi_res_screen_%a_%b_' a = <i> b = <j>
	sub = ((<i> * <scale>) + <j>)
	<cameraid> :setsubfrustum res = <scale> subimage = <sub>
	wait \{16
		frame
		ignoreslomo}
	screenshot filename = <text>
	wait \{16
		frames
		ignoreslomo}
	<j> = (<j> + 1)
	repeat <scale>
	<i> = (<i> + 1)
	repeat <scale>
	<cameraid> :setsubfrustum res = 1 subimage = 0
	root_window :se_setprops \{alpha = 1}
	if gotparam \{do2d}
		if isxenon
			change \{isolate_2d_render = 1}
			wait \{3
				frames}
			<i> = 0
			begin
			<j> = 0
			begin
			formattext textname = text 'hi_res_screen_2d_%a_%b_' a = <i> b = <j>
			sub = ((<i> * <scale>) + <j>)
			<cameraid> :setsubfrustum res = <scale> subimage = <sub>
			wait \{16
				frames}
			screenshot filename = <text>
			wait \{16
				frames}
			<j> = (<j> + 1)
			repeat <scale>
			<i> = (<i> + 1)
			repeat <scale>
			<cameraid> :setsubfrustum res = 1 subimage = 0
			change \{isolate_2d_render = 0}
		endif
	endif
	setslomo \{visualeffects = 1.0}
	if cutscenefinished \{name = cutscene}
		unpausegame
	else
		killskatercamanim \{name = hires_cutscene_hack}
	endif
endscript

script spawnhiresscreenshot 
	spawnscriptlater hiresscreenshot params = <...>
endscript
g_cur_screenshot_call = 0

script cubemapscreenshots 
	if viewportexists \{id = bg_viewport}
		destroy_cameracuts
		hide_crowd_models \{active = true}
	endif
	setenablemovies \{1}
	setviewmode \{2}
	change \{show_zone_budget_warnings = 0}
	change \{no_render_metrics = 1}
	root_window :se_setprops \{alpha = 0}
	if compositeobjectexists \{skater}
		skater :hide
	endif
	if compositeobjectexists \{player0_body}
		player0_body :hide
	endif
	if (($g_cur_screenshot_call) > 9)
		formattext textname = screennamea 'cubemap_screen_%iA' i = ($g_cur_screenshot_call)
		formattext textname = screennameb 'cubemap_screen_%iB' i = ($g_cur_screenshot_call)
		formattext textname = screennamec 'cubemap_screen_%iC' i = ($g_cur_screenshot_call)
		formattext textname = screennamed 'cubemap_screen_%iD' i = ($g_cur_screenshot_call)
		formattext textname = screennamee 'cubemap_screen_%iE' i = ($g_cur_screenshot_call)
		formattext textname = screennamef 'cubemap_screen_%iF' i = ($g_cur_screenshot_call)
	else
		formattext textname = screennamea 'cubemap_screen_0%iA' i = ($g_cur_screenshot_call)
		formattext textname = screennameb 'cubemap_screen_0%iB' i = ($g_cur_screenshot_call)
		formattext textname = screennamec 'cubemap_screen_0%iC' i = ($g_cur_screenshot_call)
		formattext textname = screennamed 'cubemap_screen_0%iD' i = ($g_cur_screenshot_call)
		formattext textname = screennamee 'cubemap_screen_0%iE' i = ($g_cur_screenshot_call)
		formattext textname = screennamef 'cubemap_screen_0%iF' i = ($g_cur_screenshot_call)
	endif
	printstruct <...>
	setscreen \{aspect = 1.0
		angle = 90.0}
	wait \{16
		gameframes}
	lock_cam_cube_dir \{dir = (1.0, 0.0, 0.0)}
	wait \{16
		gameframes}
	screenshot filename = <screennamea>
	wait \{16
		gameframes}
	lock_cam_cube_dir \{dir = (-1.0, 0.0, 0.0)}
	wait \{16
		gameframes}
	screenshot filename = <screennameb>
	wait \{16
		gameframes}
	lock_cam_cube_dir \{dir = (0.0, -1.0, 0.0)
		left = (-1.0, 0.0, 0.0)
		up = (0.0, 0.0, -1.0)}
	wait \{16
		gameframes}
	screenshot filename = <screennamec>
	wait \{16
		gameframes}
	lock_cam_cube_dir \{dir = (0.0, 1.0, 0.0)}
	wait \{16
		gameframes}
	screenshot filename = <screennamed>
	wait \{16
		gameframes}
	lock_cam_cube_dir \{dir = (0.0, 0.0, -1.0)}
	wait \{16
		gameframes}
	screenshot filename = <screennamee>
	wait \{16
		gameframes}
	lock_cam_cube_dir \{dir = (0.0, 0.0, 1.0)}
	wait \{16
		gameframes}
	screenshot filename = <screennamef>
	wait \{16
		gameframes}
	setscreen \{aspect = 1.3333334
		angle = $widescreen_camera_fov}
	change g_cur_screenshot_call = ($g_cur_screenshot_call + 1)
	root_window :se_setprops \{alpha = 1}
	if compositeobjectexists \{skater}
		skater :unhide
	endif
	if compositeobjectexists \{player0_body}
		player0_body :unhide
	endif
	change \{show_zone_budget_warnings = 1}
	change \{no_render_metrics = 0}
	if viewportexists \{id = bg_viewport}
		hide_crowd_models \{active = false}
		create_cameracuts
	endif
	setviewmode \{0}
	setenablemovies \{0}
	toggleviewmode
	toggleviewmode
endscript

script spawncubemapscreenshots 
	spawnscriptlater cubemapscreenshots params = <...>
endscript

script lock_cam_top_down 
	killskatercamanim \{all}
	getcurrentcameraobject
	<camid> :obj_getposition
	<camid> :gethfov
	playigccam {
		facing = (0.0, -1.0, 0.0)
		pos = <pos>
		fov = <hfov>
		play_hold
	}
endscript

script lock_cam_cube_dir \{dir = (1.0, 0.0, 0.0)}
	getcurrentcameraobject
	<camid> :obj_getposition
	<camid> :gethfov
	if viewportexists \{id = bg_viewport}
		setviewportcameraorient viewport = bg_viewport at = <dir> <...>
	else
		setviewportcameraorient viewport = 0 at = <dir> <...>
	endif
endscript
