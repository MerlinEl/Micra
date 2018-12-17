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

	fn redistributeConstrainObjects helpers =
	(
		local percent = 0
		local incr =  (100/helpers.count)
		for i in helpers do
		(			
			percent +=incr
			/*format "percent:%\n" percent*/
			i.pos.controller.PERCENT = percent
		)
	)
	fn addToConstrain parent percent =
	(
		local obj  = dummy pos: [0,0,0] boxsize: [5,5,5] name:(uniqueName "morpher_tag_")
		obj.pos.controller = Path_Constraint ()
		obj.pos.controller.appendTarget parent 100
		obj.pos.controller.follow = on
		obj.pos.controller.PERCENT = percent
		return obj
	)
	fn addRemoveConstrain val  =
	(
		print val
		if val > helpers.count 
		then 
		(
			--print "add" 
			local percent = (100/(helpers.count+1))
			local thisNode = (refs.dependentNodes this)[1]
			helpers += #(addToConstrain thisNode percent)
			redistributeConstrainObjects helpers
		)
		else if val != helpers.count do
		(
			--print "remove"
			if helpers.count > 2 do 
			(
				delete helpers[helpers.count]
				deleteItem helpers helpers.count
				redistributeConstrainObjects helpers
			)
		)	
		updateInterface
	)
	fn findItemString arr str  ignoreCase:true =
	(
		if  ignoreCase then 
		(
			local lower_arr = for i in arr collect toLower i
			local lower_str = toLower str
			return ( findItem lower_arr lower_str != 0 )
		)
		else return ( findItem arr str != 0 )
	)
	fn notDupplicateFound items txt =
	(
		if findItemString items txt then
			(
				messageBox ("Name: [ "+ txt +" ] is used. Try something else." ) title:"Dupplicate Found!"
				return false
			)
			else return true
	)
	fn selectPoint  txt =
	(
		local obj = getNodeByName txt
		if obj != undefined do 
		(	
			MorphActivePointMarker = obj
		)
	)
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