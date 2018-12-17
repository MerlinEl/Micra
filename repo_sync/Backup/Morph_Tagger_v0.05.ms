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
	local helpers = #()
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
	fn createNewDummy =
	(
		dummy pos: [0,0,0] boxsize: [5,5,5] name:(uniqueName "morpher_tag_")
	)
	fn addToConstrain parent obj percent =
	(
		format "parent:%\t object:%\t precent:%\n" parent obj percent
		obj.pos.controller = Path_Constraint ()
		format "add target:%\n" (obj.pos.controller.appendTarget parent 100)
		obj.pos.controller.follow = on
		obj.pos.controller.PERCENT = percent
		print obj.pos.controller.PERCENT
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
		--helpers_dummy type:#floatTab tabSize:4 tabSizeVariable:true ui:(25.3, 85, 333, 1.5) --("p1", "p2", "p3", "p4")
		--mapAmounts type:#floatTab tabSize:4 tabSizeVariable:true  ui:(map1Amount=1, map2Amount=2, map3Amount=3, map4Amount=4)
		node_list type:#nodeTab tabSize:0 tabSizeVariable:true
		on node_list tabChanged change tabIndex tabCount do this.interpoints.updateNodeList()
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
		listBox lbx "" pos:[2,2] width:158 height:6  --items:(for i in helpers collect i.name)--#("p1","p2","p3","p4")
		editText edt "" pos:[0,88] width:159 height:20
		button btn_add "Add" pos:[4,112] width:48 height:24
		button btn_ren "Rename" pos:[56,112] width:52 height:24
		button btn_del "Del" pos:[112,112] width:48 height:24
		fn updateNodeList = (lbx.items = for o in node_list where isValidNode o collect o.name)
		on lbx selected sel do (selectPoint  lbx.items[sel])
		on lbx doubleClicked sel do (edt.text = lbx.items[sel])
		on btn_ren pressed do (if edt.text !="" and  lbx.selection != 0 and notDupplicateFound  lbx.items edt.text  do (lbx.selected = edt.text) )
		on btn_add pressed do ( if edt.text !="" and notDupplicateFound  lbx.items edt.text do (lbx.items += #(edt.text ))) -- lbx.selection
		on btn_del pressed do ( if  lbx.selection != 0 do lbx.items = deleteItem lbx.items lbx.selection) -- lbx.selection
		on interpoints open do updateNodeList()
	)
	on getDisplayMesh do (drawMorphActivePointMarker())
	on reload do --create do
	(

	)
	on update do
	(
		/*
		unregisterRedrawViewsCallback drawMorphActivePointMarker
		registerRedrawViewsCallback drawMorphActivePointMarker
		*/
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
					print "click 1"
					coordsys grid nodeTM.translation = gridPoint
					local thisNode = (refs.dependentNodes this)[1]	
					thisNode.wirecolor = green
					thisNode.name = (uniqueName "morpher_prent_")
					for i=1 to 4 do append node_list (createNewDummy())
					local percent = 100/4
					for o in node_list do addToConstrain thisNode o percent

				)
			)
		)
		 
		on mouseMove click do
		(
			case click of
			(
				2: (this[#Circle].radius = circle_radius = abs(gridDist.y); print "click2" ) --params.circle_radius.value
				3: ( #stop)
			)
		)
	)--end create
)

/*
$.pos.controller.weight = #(100,100,100,100)

$morpher_tag_004.pos.controller.appendTarget $morpher_prent_001 100
*/