/* by denisT */

plugin Helper ProDummy name:"ProDummy"
classID:#(0x00001967, 0x4023088b)
category:"Standard" 
extends:Dummy
version:1
( 
	parameters main rollout:params
	(
		width type:#float ui:ui_width default:0
		length type:#float ui:ui_length default:0
		height type:#float ui:ui_height default:0
		
		on width set val do delegate.boxsize.x = val
		on length set val do delegate.boxsize.y = val
		on height set val do delegate.boxsize.z = val
	)
	rollout params "Parameters"
	(
		spinner ui_width "Width: " fieldWidth:64 type:#worldunits range:[0,1e9,0] align:#right offset:[4,0] tooltip:"X"
		spinner ui_length "Length: " fieldWidth:64 type:#worldunits range:[0,1e9,0] align:#right offset:[4,-2] tooltip:"Y"
		spinner ui_height "Height: " fieldWidth:64 type:#worldunits range:[0,1e9,0] align:#right offset:[4,-2] tooltip:"Z"
	)
	tool create
	(
		local pos
		on mousePoint click do case click of
		(
			1: pos = nodeTM.translation = gridPoint
			2: pos = nodeTM.translation
			3: #stop
		)
		on mouseMove click do case click of
		(
			2: 
			(
				nodeTM.translation = pos + [griddist.x*0.5, griddist.y*0.5, 0]
				width = abs griddist.x
				length = abs griddist.y
			)
			3: 
			(
				nodeTM.translation = pos + [0, 0, griddist.z*0.5]
				height = abs griddist.z
			)
		)
	)
)
