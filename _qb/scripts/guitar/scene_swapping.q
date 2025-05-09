0x39740651 = '_ven'
g_scene_swap_prefixes = [
	'_ven'
	'_vis'
	'_char'
	'_dre'
	'_tem'
	'_cub'
]
g_scene_swap_viewport_masks = [
	4
	32768
	16384
	8192
	4096
]
g_viewport_visibility = {
	ven = 4
	vis = 32768
	char = 16384
	all = 65535
	dre = 8192
	tem = 4096
	cub = 8192
}
g_viewport_visibility_default = [
	ven
]

script 0xff42fd94 
	change \{0x39740651 = '_ven'}
endscript

script scene_swap \{name = unknown}
	if (<name> = unknown)
		scriptassert \{'scene_swap missing name param'}
	endif
	getpakmancurrent \{map = zones}
	switch <name>
		case main
		<prefix_index> = 0
		case hypersphere
		<prefix_index> = 1
		case none
		<prefix_index> = 2
		case dream
		<prefix_index> = 3
		case temple
		<prefix_index> = 4
		case cube
		<prefix_index> = 3
		default
		scriptassert 'scene_swap received unknown name %n' n = <name>
	endswitch
	if gotparam \{prefix_index}
		<viewport_mask> = ($g_scene_swap_viewport_masks [<prefix_index>])
		<partial_prefix> = ($g_scene_swap_prefixes [<prefix_index>])
	endif
	if (<partial_prefix> = $0x39740651)
		return
	endif
	setviewportproperties viewport = bg_viewport viewport_mask = <viewport_mask>
	change 0x39740651 = <partial_prefix>
endscript

script 0xa88b2616 
	if ($0x39740651 = '_ven')
		return \{true}
	else
		return \{false}
	endif
endscript
