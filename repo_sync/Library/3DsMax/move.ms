fn cyrcleTools =
(
	case toolmode.commandmode of
	(
		#move   :(max rotate)
		#rotate :(max scale)
		#uscale :(max move)
		#nscale :(max move)
		#squash :(max move)
		#select :(max move)
	)
)



MacroScript CyrcleToolsUEStyle             
category:"Micra"
toolTip:""
(
	On execute do undo off 
	(
		local gco = modpanel.getcurrentobject()
		if classOf gco == Unwrap_UVW 
		then
			(
				--texture vertex scale mode
				--$.unwrap_uvw.unwrap.move()
				--$.unwrap_uvw.unwrap.rotate()
				--$.unwrap_uvw.unwrap.scale()
			)
		else
			case toolmode.commandmode of
			(
				#move   :(max rotate)
				#rotate :(max scale)
				#uscale :(max move)
				#nscale :(max move)
				#squash :(max move)
				#select :(max move)
			)

	)
)
----------------------------------------------------------------------------------------------------------
