Global MorphActivePointMarker
Global drawMorphActivePointMarker

plugin shape MorphTagger
name:"MorphTagger"
classID:#(0x2be399d0, 0x564b0294)
extends:circle version:2
/*
invisible:true
replaceUI:true
*/
category:"Splines"
( 
	tool create
	(
		on mousePoint click do
		(
			case click of
			(
				1: 
				(
					coordsys grid nodeTM.translation = gridPoint
					local thisNode = (refs.dependentNodes this)[1]
					local percent = 0
					for i=1 to 4 do 
					(	
						helpers[i] = addToConstrain thisNode percent
						percent += (100/4)
					)
					thisNode.wirecolor = green
					thisNode.name = (uniqueName "morpher_prent_")
				)
			)
		)
		 
		on mouseMove click do
		(
		case click of
		  (
			2: 
			(
				this[#Circle].radius = circle_radius = abs(gridDist.y)
			)
			3: (#stop)
		  )
		)
	)--end create
)