tb_global_zoom_tunnel_3 = [
	{
		type = sprite
		pos = (0.5, 0.5, 0.0)
		scale = (1.0, 1.0)
		width = 1.0
		height = 1.0
		color = [
			17
			7
			20
			255
		]
		material = tb_mat_gradient
		angle = 0
		angularvel = 0
	}
	{
		type = blendprev
		offset = (0.0, 0.0)
		scale = (0.9, 0.9)
		color = [
			255
			255
			255
			254
		]
		angle = 0
		angularvel = 0
		blendmode = blend
		controls = [
			{
				type = beaton
				response = green2modulation
				scalemod = 3.4
				responsefunc = sintimescalerate
				fade = 0.3
			}
		]
	}
	{
		type = circle
		pos = (0.5, 0.5, 0.0)
		radius = 0.02
		color = [
			94
			83
			64
			29
		]
		color2 = [
			255
			249
			240
			209
		]
		blendmode = blend
		thickness = 1.0
		angle = 0
		angularvel = 0.26179898
		controls = [
			{
				type = beaton
				response = radiusscale
				scalemod = 0.01
				responsefunc = costime
				fade = 0.1
			}
		]
	}
	{
		type = sprite
		pos = (0.5, 0.5, 0.0)
		scale = (0.05, 0.05)
		width = 0.5
		height = 0.5
		color = [
			77
			77
			77
			198
		]
		material = og_mat_sphere_sub
		angle = 0
		angularvel = 1.5708001
	}
	{
		type = hypotrochoid
		pos = (0.5, 0.5, 0.0)
		scale = (0.5, 0.5)
		length = 0.1005
		innerradius = 0.005
		outerradius = 0.05
		tracelength = 23
		color = [
			28
			27
			23
			255
		]
		material = og_mat_flare_add_b
		thickness = 20.0
		angularvel = 1.7453301
		controls = [
			{
				type = frequency
				response = anglemod
				scalemod = 2.6
				responsefunc = costime
				spectrumband = 0
			}
		]
	}
]
