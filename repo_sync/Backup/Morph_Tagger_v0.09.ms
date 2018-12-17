Global MorphActivePointMarker

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
		if findItemString items txt or  findItemString (for o in objects collect o.name) txt then
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
	parameters param_params rollout:params
	(
		control_points type:#integer ui:control_points default:4
		circle_radius type:#float ui:circle_radius default:10
	)
	
	parameters param_interpoints rollout:interpoints
	(
		tag_nodes type:#nodeTab tabSize:0 tabSizeVariable:true
	)
	
	rollout params "Parameters:"
	(
		spinner circle_radius "Radius:" range:[0,10000,0] type:#float /*scale:0.001*/
		spinner control_points "Points:" range:[2,10,4] type:#integer
		on circle_radius changed val do (this[#Circle].radius = val)
		on control_points changed val do (this.interpoints.addRemovePoint val)
	)
	rollout interpoints "Interpoints:"
	(
		listBox lbx "" pos:[2,2] width:158 height:6 --items:(for i in helpers collect i.name)--#("p1","p2","p3","p4")
		editText edt "" pos:[0,88] width:159 height:20
		button btn_add "Add" pos:[4,112] width:48 height:24
		button btn_ren "Rename" pos:[56,112] width:52 height:24
		button btn_del "Del" pos:[112,112] width:48 height:24
		fn updateNodeList = 
		(
			lbx.items = for o in helpers where isValidNode o collect o.name
			if lbx.items.count != 0 do 
			(
				MorphActivePointMarker = getNodeByName lbx.selected
			)
			params.control_points.value = lbx.items.count 
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
		fn createPoint parent percent  dname:unsupplied =
		(
			local obj  = dummy pos: [0,0,0] boxsize: [2,2,2] name:(if dname != unsupplied then dname else (uniqueName "morpher_tag_"))
			obj.pos.controller = Path_Constraint ()
			obj.pos.controller.appendTarget parent 100
			obj.pos.controller.follow = on
			obj.pos.controller.PERCENT = percent
			return obj
		)
		fn addRemovePoint val  dname:unsupplied =
		(
			if val == -1 or val > helpers.count 
			then 
			(
				--print "add" 
				local percent = (100/(helpers.count+1))
				local this_node = (refs.dependentNodes this)[1]
				local new_node = createPoint this_node percent dname:dname
				helpers += #(new_node)
				redistributeConstrainObjects helpers
			)
			else if val == -2 or val != helpers.count do
			(
				--print "remove"
				if helpers.count > 2 do 
				(
					local sel_num = lbx.selection
					local obj = helpers[sel_num]
					deleteItem helpers sel_num
					delete obj
					redistributeConstrainObjects helpers
				)
			)	
			lbx.selection = lbx.items.count
			updateNodeList()
		)
		fn renamePoint txt =
		(
			if lbx.items.count != 0 do 
			(
				local sel_num = lbx.selection
				helpers[sel_num].name = txt
				lbx.selected = txt
			)
			updateNodeList()
		)
		on lbx selected sel do (selectPoint  lbx.items[sel])
		on lbx doubleClicked sel do (edt.text = lbx.items[sel])
		on btn_ren pressed do (if edt.text !="" and  lbx.selection != 0 and notDupplicateFound  lbx.items edt.text  do renamePoint edt.text )
		on btn_add pressed do ( if edt.text !="" and notDupplicateFound  lbx.items edt.text do (addRemovePoint -1 dname:edt.text)) -- lbx.selection
		on btn_del pressed do ( if  lbx.selection != 0 do addRemovePoint -2)
		on interpoints open do updateNodeList()
		on interpoints reload do updateNodeList()
	)
	on clone obj do
	(
		local this_node = (refs.dependentNodes obj)[1]
		local percent = 0
		for i=1 to 4 do 
		(	
			helpers[i] = interpoints.createPoint this_node percent
			
			percent += (100/4)
		)
		this_node.wirecolor = green
		this_node.name = (uniqueName "morpher_prent_")
	)
	/*on postCreate do*/
	/*on deleted do (try (delete helpers) catch(); CompleteRedraw(); print "deleted")*/
	on create do
	(
		unregisterRedrawViewsCallback drawMorphActivePointMarker
		registerRedrawViewsCallback drawMorphActivePointMarker
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
					local this_node = (refs.dependentNodes this)[1]
					local percent = 0
					for i=1 to 4 do 
					(	
						local obj =  interpoints.createPoint this_node percent
						helpers[i] = obj
						/*tag_nodes[i] = obj*/
						percent += (100/4)
					)
					this_node.wirecolor = green
					this_node.name = (uniqueName "morpher_prent_")
				)
			)
			print tag_nodes
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

/*

		target = node.target
		c = node.controller = transform_script()
		c.addtarget "TM" target[#transform]
		c.addtarget "radius" this[#radius]
		c.addtarget "height" this[#height]
		c.addtarget "yaw" this[#yaw]
		c.addtarget "pinch" this[#pinch]
		c.addtarget "roll" this[#roll]


	print delegate.radius
	$.delegate.radius
	on getDisplayMesh do (drawMorphActivePointMarker(); print 1)
	--on reload, create, update do
Global drawMorphActivePointMarker

$.delegate.thickness = 4
$.delegate.sides = 6
$.delegate .radius : float
$.delegate.render_renderable = false
$.delegate.render_displayRenderMesh = true
$.delegate.render_viewport_thickness = 4
$.delegate.render_viewport_sides = 6



$.delegate.render_renderable = false
$.delegate.render_displayRenderMesh = false

*/