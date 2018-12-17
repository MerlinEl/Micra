Global MorphActivePointMarker
Global drawMorphActivePointMarker

plugin shape MorphTagger
name:"MorphTagger"
classID:#(0x2be399d0, 0x564b0294)
extends:circle version:1
invisible:true
replaceUI:true
category:"Splines"
( 
	local helpers = #()
	parameters main rollout:params
	(
		control_points type:#integer ui:control_points default:4
		circle_radius type:#integer ui:circle_radius default:10
	)
	rollout params "Parameters"
	(
		spinner circle_radius "Radius:" range:[0,10000,0] type:#float /*scale:0.001*/
		spinner control_points "Points:" range:[2,10,4] type:#integer
		on circle_radius changed val do (this[#Circle].radius = val)
		on control_points changed val do (addRemoveConstrain val)
	)
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