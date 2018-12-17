Global MorphActivePointMarker
Global drawMorphActivePointMarker

plugin shape MorphTagger
name:"MorphTagger"
classID:#(0x2be399d0, 0x564b0294)
extends:circle version:1
/*invisible:true*/
replaceUI:true
category:"Splines"
( 
	fn drawMorphActivePointMarker = 
	(
		gw.setTransform(Matrix3 1)
		if MorphActivePointMarker != undefined and isValidNode MorphActivePointMarker do 
		(
			local p = gw.hTransPoint MorphActivePointMarker.pos
			gw.hText p MorphActivePointMarker.name color:yellow
			gw.hMarker p #bigBox color:[255,255,255]
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		)
	)
	fn redistributeConstrainObjects node_list =
	(
		local percent = 0
		local incr =  (100/node_list.count)
		for i in node_list do
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
		/*obj.pos.controller.appendTarget parent 100*/
		obj.pos.controller.follow = on
		obj.pos.controller.PERCENT = percent
		return obj
	)
	fn addRemoveConstrain val  =
	(
		print val
		if val > node_list.count 
		then 
		(
			--print "add" 
			local percent = (100/(node_list.count+1))
			local thisNode = (refs.dependentNodes this)[1]
			node_list += #(addToConstrain thisNode percent)
			redistributeConstrainObjects node_list
		)
		else if val != node_list.count do
		(
			--print "remove"
			if node_list.count > 2 do 
			(
				delete node_list[node_list.count]
				deleteItem node_list node_list.count
				redistributeConstrainObjects node_list
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
		--search for duplicates in list --search for duplicates in scene
		if findItemString items txt or  findItemString objects txt then
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
		circle_radius type:#float ui:circle_radius default:10
		node_list type:#nodeTab tabSize:0 tabSizeVariable:true
	)
	rollout params "Parameters"
	(
		spinner circle_radius "Radius:" range:[0,10000,0] type:#float /*scale:0.001*/
		spinner control_points "Points:" range:[2,10,4] type:#integer
		on circle_radius changed val do (this[#Circle].radius = val)
		on control_points changed val do (addRemoveConstrain val)
	)
	rollout interpoints "Interpoints"
	(
		listBox lbx "" pos:[2,2] width:158 height:6 items:(for i in node_list collect i.name)--#("p1","p2","p3","p4")
		editText edt "" pos:[0,88] width:159 height:20
		button btn_add "Add" pos:[4,112] width:48 height:24
		button btn_ren "Rename" pos:[56,112] width:52 height:24
		button btn_del "Del" pos:[112,112] width:48 height:24
		on lbx selected sel do (selectPoint  lbx.items[sel])
		on lbx doubleClicked sel do (edt.text = lbx.items[sel])
		on btn_ren pressed do (if edt.text !="" and  lbx.selection != 0 and notDupplicateFound  lbx.items edt.text  do (lbx.selected = edt.text) )
		on btn_add pressed do ( if edt.text !="" and notDupplicateFound  lbx.items edt.text do (lbx.items += #(edt.text ))) -- lbx.selection
		on btn_del pressed do ( if  lbx.selection != 0 do lbx.items = deleteItem lbx.items lbx.selection) -- lbx.selection
	)
	on reload do --create do
	(

	)
	on update do
	(
		unregisterRedrawViewsCallback drawMorphActivePointMarker
		registerRedrawViewsCallback drawMorphActivePointMarker
		/*print delegate.radius*/
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
						node_list[i] = addToConstrain thisNode percent
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
				2: (this[#Circle].radius = circle_radius = abs(gridDist.y) ) --params.circle_radius.value
				3: ( #stop)
			)
		)
	)--end create
)