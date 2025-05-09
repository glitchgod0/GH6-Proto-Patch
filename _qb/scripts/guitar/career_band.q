
script career_band_update \{band = rockerband_gh_rocker_axel
		rocker_part = guitarist
		female_vocals = 0
		savegame = 0
		use_power_rocker = 0
		transformation = 0}
	<guitarist> = none
	<bassist> = none
	<vocalist> = none
	<drummer> = none
	<male1_used> = 0
	<male2_used> = 0
	<female1_used> = 0
	change \{g_power_rocker_part = none}
	if (<use_power_rocker> = 1 && <transformation> = 0)
		<rocker> = (($<band>).power_rocker)
	else
		<rocker> = (($<band>).rocker)
	endif
	switch <rocker_part>
		case guitarist
		<guitarist> = <rocker>
		case bassist
		<bassist> = <rocker>
		case vocalist
		<vocalist> = <rocker>
		case drummer
		<drummer> = <rocker>
	endswitch
	if (<vocalist> = none)
		if (<transformation> = 1)
			<vocalist> = (($<band>).power_rocker)
			<transformation> = 0
			change \{g_power_rocker_part = vocals}
		elseif (<female_vocals> = 1)
			<vocalist> = (($<band>).female1)
			<female1_used> = 1
		else
			<vocalist> = (($<band>).male1)
			<male1_used> = 1
		endif
	endif
	if (<guitarist> = none)
		if (<transformation> = 1)
			<guitarist> = (($<band>).power_rocker)
			<transformation> = 0
			change \{g_power_rocker_part = guitar}
		elseif (<male1_used> = 0)
			<guitarist> = (($<band>).male1)
			<male1_used> = 1
		elseif (<male2_used> = 0)
			<guitarist> = (($<band>).male2)
			<male2_used> = 1
		elseif (<female1_used> = 0)
			<guitarist> = (($<band>).female1)
			<female1_used> = 1
		endif
	endif
	if (<drummer> = none)
		if (<male1_used> = 0)
			<drummer> = (($<band>).male1)
			<male1_used> = 1
		elseif (<male2_used> = 0)
			<drummer> = (($<band>).male2)
			<male2_used> = 1
		elseif (<female1_used> = 0)
			<drummer> = (($<band>).female1)
			<female1_used> = 1
		endif
	endif
	if (<bassist> = none)
		if (<male1_used> = 0)
			<bassist> = (($<band>).male1)
			<male1_used> = 1
		elseif (<male2_used> = 0)
			<bassist> = (($<band>).male2)
			<male2_used> = 1
		elseif (<female1_used> = 0)
			<bassist> = (($<band>).female1)
			<female1_used> = 1
		endif
	endif
	if (($g_career_band.guitarist) != <guitarist>
			|| ($g_career_band.bassist) != <bassist>
			|| ($g_career_band.vocalist) != <vocalist>
			|| ($g_career_band.drummer) != <drummer>
		)
		change g_career_band = {guitarist = <guitarist> bassist = <bassist> vocalist = <vocalist> drummer = <drummer>}
		return \{true}
	endif
	return \{false}
endscript
