/*
callbacks.removeScripts id:#BBox_Meassure
callbacks.addScript #selectionSetChanged bbtxt id:#BBox_Meassure
*/


Global MorphActivePointMarker
Global drawMorphActivePoint
unregisterRedrawViewsCallback drawMorphActivePoint
fn drawMorphActivePoint = 
(
	if MorphActivePointMarker != undefined and isValidNode MorphActivePointMarker do 
	(
		MorphActivePointMarker.boxmode = off
		MorphActivePointMarker.wirecolor = red
	)
	/*
	gw.setTransform(Matrix3 1)
	if MorphActivePointMarker != undefined and isValidNode MorphActivePointMarker do 
	(
		local p = gw.hTransPoint MorphActivePointMarker.pos
		gw.hText p MorphActivePointMarker.name color:yellow
		gw.hMarker p #bigBox color:[255,255,255]
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	*/
)
registerRedrawViewsCallback drawMorphActivePoint


plugin shape MorphTagger
name:"MorphTagger"
classID:#(0x2be399d0, 0x564b0294)
extends:circle version:1
/*invisible:true*/
replaceUI:true
category:"Splines"
( 
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
	parameters param_params rollout:params
	(
		control_points type:#integer ui:control_points default:4
		circle_radius type:#float ui:circle_radius default:10
	)
	parameters param_interpoints rollout:interpoints
	(
		/*tag_nodes type:#nodeTab tabSize:0 tabSizeVariable:true*/
		tag_names type:#filenameTab tabSize:0 tabSizeVariable:true
		last_sel type:#integer default:1
	)
	rollout params "Parameters:"
	(
		spinner circle_radius "Radius:" range:[0,10000,0] type:#float /*scale:0.001*/
		spinner control_points "Points:" range:[1,10,4] type:#integer
		on circle_radius changed val do (this[#Circle].radius = val)
		on control_points changed val do (this.interpoints.addRemovePoint val)
	)
	rollout interpoints "Interpoints:"
	(
		listBox tag_list "" pos:[2,2] width:158 height:8 items:#()
		editText edt "" pos:[0,114] width:159 height:20 
		button btn_add "Add" pos:[4,138] width:48 height:24
		button btn_ren "Rename" pos:[56,138] width:52 height:24
		button btn_del "Del" pos:[112,138] width:48 height:24
		fn updateNodeList = 
		(
			tag_list.items = for n in tag_names where (getNodeByName n) != undefined collect n
			if tag_list.items.count != 0 do 
			(
				tag_list.selection = last_sel
				MorphActivePointMarker = getNodeByName tag_list.selected
			)
			params.control_points.value = tag_list.items.count 
		)
		fn redistributeConstrainObjects names =
		(
			local p = 0
			local incr =  (100/names.count)
			for n in names do
			(			
				/*format "percent:%\n" p*/
				local obj = getNodeByName n
				if obj != undefined do obj.pos.controller.percent = p
				p +=incr	
			)
		)
		fn createPoint parent percent  dname:unsupplied =
		(
			--local obj  = dummy pos: [0,0,0] boxsize: [2,2,2] name:(if dname != unsupplied then dname else (uniqueName "morpher_tag_"))
			local obj  = box pos: [0,0,0] size: [2,2,2] name:(if dname != unsupplied then dname else (uniqueName "morpher_tag_"))
			obj.pivot = (obj.min+obj.max)/2
			obj.wirecolor = green	
			obj.boxmode = on
			obj.pos.controller = Path_Constraint ()
			obj.pos.controller.appendTarget parent 100
			obj.pos.controller.follow = on
			obj.pos.controller.PERCENT = percent
			return obj
		)
		fn addRemovePoint val  dname:unsupplied =
		(
			if val == -1 or val > tag_names.count 
			then 
			(
				--print "add" 
				local p = (100/(tag_names.count+1))
				local this_node = (refs.dependentNodes this)[1]
				local new_node = createPoint this_node p dname:dname
				append tag_names new_node.name
				redistributeConstrainObjects tag_names
			)
			else if val == -2 or val != tag_names.count do
			(
				--print "remove"
				if tag_names.count > 1 do 
				(
					local sel_num = tag_list.selection
					local obj = getNodeByName tag_names[sel_num]
					deleteItem tag_names sel_num
					if obj != undefined do delete obj
					redistributeConstrainObjects tag_names
				)
			)
			last_sel = tag_names.count
			updateNodeList()
		)
		fn renamePoint txt =
		(
			if tag_list.items.count != 0 do 
			(
				local obj = getNodeByName tag_names[last_sel]
				if obj == undefined do return false
				tag_names[last_sel] = txt
				obj.name = txt
			)
			updateNodeList()
		)
		fn selectPoint sel =
		(
			MorphActivePointMarker = getNodeByName tag_names[sel]
			last_sel = sel
		)
		on tag_list selected sel do (selectPoint  sel)
		on tag_list doubleClicked sel do (edt.text = tag_list.items[sel])
		on btn_ren pressed do (if edt.text !="" and  tag_list.selection != 0 and notDupplicateFound  tag_list.items edt.text  do renamePoint edt.text )
		on btn_add pressed do ( if edt.text !="" and notDupplicateFound  tag_list.items edt.text do (addRemovePoint -1 dname:edt.text))
		on btn_del pressed do ( if  tag_list.selection != 0 do addRemovePoint -2)
		on interpoints load do( print "aaa")
		on interpoints open do (updateNodeList())
		on interpoints reload do updateNodeList()
	)
	on clone obj do
	(
		local this_node = (refs.dependentNodes obj)[1]
		local p = 0, incr= (100/tag_names.count)
		for i=1 to tag_names.count do 
		(	
			tag_names[i] =(interpoints.createPoint this_node p).name
			p +=incr
		)
		this_node.wirecolor = green
		this_node.name = (uniqueName "morpher_prent_")
	)
	on load do (print "updating..") --when max file open
	/*on postCreate do*/

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
						tag_names[i] = obj.name
						/*tag_nodes[i] = obj*/
						percent += (100/4)
					)
					this_node.wirecolor = green
					this_node.name = (uniqueName "morpher_prent_")
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
	on deleted do 
	(
		print  "deleted"
		/*unregisterRedrawViewsCallback drawMorphActivePoint*/
		/*clearUndoBuffer()*/
		/*delete (for n in tag_names where (local o = getNodeByName n) != undefined collect o)*/
	)
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
	on getDisplayMesh do (drawMorphActivePoint(); print 1)
	--on reload, create, update do
Global drawMorphActivePoint

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