ToolMode.nonUniformScale()
Max Scale
Max Move
Max Rotate



		if toolmode.commandmode == #squash or toolmode.commandmode == #nuscale or toolmode.commandmode == #uscale then max scale cycle
		Else max scale 
		
		
		
fn setCoordsysForAllTools coord = --#view,#screen,#world,#parent,#local,#Grid,#Gimbal
(
	local old_tool = toolmode.commandmode
	
	max move
	Toolmode.coordsys coord 
	max rotate
	Toolmode.coordsys coord 
	max scale	
	Toolmode.coordsys coord 
	max select
	Toolmode.coordsys coord 
	
	case old_tool of
	(
		#move   :(max move)
		#rotate :(max rotate)
		#uscale :(max scale)
		#nscale :(max scale)
		#squash :(max scale)
		#select :(max select)
	)
)	
	
setCoordsys #local		
	



	
		
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

