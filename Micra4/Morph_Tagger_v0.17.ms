--------------------------------------------------------------------------
					/*MORPH TAGGER*/
						/*2012*/
--------------------------------------------------------------------------

Global mcMorphCollectorDialog
Global morphCollectorMarkers
Global MorphTagger
Global MorphCollector


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
	fn getVertPosByHit p1 p2 mesh_obj =
	(
		if classOf mesh_obj != Editable_Mesh do return undefined
		local the_ray = ray p1 (normalize (p2 - p1) ) 
		local hit_array = intersectRayEx mesh_obj the_ray
		if hit_array == undefined do return undefined
		local hit_pos=(hit_array[1]).pos
		local hit_face=(hit_array[2])
		if hit_face == undefined  do return undefined
		local face_verts =  (meshop.getVertsUsingFace mesh_obj hit_face) as array
		/*format "face_verts:%|n"  face_verts*/
		local dist = (for v in face_verts collect distance (meshOp.getVert mesh_obj v) hit_pos)
		local min_dist  = (amin dist)
		local the_vert = face_verts[ findItem dist min_dist ]
		return (meshOp.getVert mesh_obj the_vert)
	)
	fn getProjectedPoints mesh_obj ring=
	(
		tag_points = #()
		for n in ring.tag_names where (local obj = getNodeByName n) != undefined do 
		(
			local tag_pos = obj.pos
			local ring_pos = ring.pos
			local vert_pos = getVertPosByHit tag_pos ring_pos mesh_obj
			if vert_pos != undefined do append tag_points vert_pos
		)
		return tag_points
	)
	parameters param_params rollout:params
	(
		control_points type:#integer ui:control_points default:4
		circle_radius type:#float ui:circle_radius default:10
		control_points_enabled type:#boolean default:true
	)
	parameters param_interpoints rollout:interpoints
	(
		tag_names type:#stringTab tabSize:0 tabSizeVariable:true
		morph_collector type:#string default:""
		last_sel type:#integer default:1
	)
	rollout params "Parameters:"
	(
		spinner circle_radius "Radius:" range:[0,10000,0] type:#float /*scale:0.001*/
		spinner control_points "Points:" range:[1,10,4] type:#integer enabled:control_points_enabled
		on circle_radius changed val do (this[#Circle].radius = val)
		on control_points changed val do (this.interpoints.addRemovePoint val)
	)
	local clr_ring= color 0 128 131, clr_tag = color 31 255 217
	rollout interpoints "Interpoints:"
	(
		listBox tag_list "" pos:[2,2] width:158 height:8 items:#()
		editText edt "" pos:[0,114] width:159 height:20 
		button btn_add "Add" pos:[4,138] width:48 height:24 enabled:control_points_enabled
		button btn_ren "Rename" pos:[56,138] width:52 height:24 enabled:control_points_enabled
		button btn_del "Del" pos:[112,138] width:48 height:24 enabled:control_points_enabled
		timer tmr "Timer" pos:[0,0] width:24 height:24 enabled:true interval:1000 active:true
		spinner spn_percent "Percentage:" range:[0,100,0] type:#integer
		fn getCollectorModifier str:undefined =
		(
			local obj = getNodeByName (if str!= undefined then str else morph_collector)
			if obj == undefined do return undefined
			local m = obj.modifiers[#MorphCollector]
			return m
		)
		fn markActiveTag sel =
		(
			if tag_names.count == 0 do return false
			local obj = (getNodeByName tag_names[sel])
			if obj == undefined do return false
			for n in tag_names do 
			(
				local o =  getNodeByName n
				if o != undefined do (o.wirecolor = clr_tag ; o.boxmode = true)
			)
			obj.wirecolor = red ; obj.boxmode = false
			last_sel = sel
			spn_percent.value = obj.pos.controller.percent
			CompleteRedraw()
		)
		fn updateNodeList = 
		(
			tag_list.items = for n in tag_names where (getNodeByName n) != undefined collect n
			if tag_list.items.count != 0 do (tag_list.selection = last_sel)
			params.control_points.value = tag_list.items.count 
			markActiveTag last_sel
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
			--local obj  = box pos: [0,0,0] width:1 height:1 length:1 name:(if dname != unsupplied then dname else (uniqueName "morpher_tag_"))
			local obj  = sphere pos: [0,0,0] radius:0.8 name:(if dname != unsupplied then dname else (uniqueName "tg_"))
			obj.pivot = (obj.min+obj.max)/2
			obj.wirecolor = clr_tag	
			obj.boxmode = on
			obj.pos.controller = Path_Constraint ()
			obj.pos.controller.appendTarget parent 100
			obj.pos.controller.follow = on
			obj.pos.controller.PERCENT = percent
			if obj.isAnimated do deleteKeys obj
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
		on tag_list selected sel do (markActiveTag  sel)
		on tag_list doubleClicked sel do (edt.text = tag_list.items[sel])
		on btn_ren pressed do (if edt.text !="" and  tag_list.selection != 0 and notDupplicateFound  tag_list.items edt.text  do renamePoint edt.text )
		on btn_add pressed do ( if edt.text !="" and notDupplicateFound  tag_list.items edt.text do (addRemovePoint -1 dname:edt.text))
		on btn_del pressed do ( if  tag_list.selection != 0 do addRemovePoint -2)
		on interpoints load do( print "aaa")
		on interpoints open do 
		(
			--print "Selected Morph Tagger"
			updateNodeList()
			if mcMorphCollectorDialog == undefined or mcMorphCollectorDialog.isDisplayed == false do mcFile.fileInVersion "Morph_Collector_Manager"
		)
		on spn_percent changed val do 
		(
			if tag_names.count == 0 do return false
			local obj = (getNodeByName tag_names[last_sel])
			if obj == undefined do return false
			obj.pos.controller.percent = val
		)
		on tmr tick  do 
		(
			local this_node = (refs.dependentNodes this)[1]
			local collector_obj = getNodeByName morph_collector
			if collector_obj == undefined do return false
			if getCollectorModifier() == undefined do return false
			morphCollectorMarkers =#()
			struct MORPH_DATA(ring, tags=#(), points=#())
			append morphCollectorMarkers (MORPH_DATA ring:this_node.name  tags:(this_node.tag_names)  points:(getProjectedPoints collector_obj this_node))
			--m.tag_points = getProjectedPoints collector_obj this_node
			--m.main.btn_ref.pressed()
		)
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
		this_node.wirecolor = clr_ring
		this_node.name = (uniqueName "mt_parent_")
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
						tag_names[i] = obj.name
						/*tag_nodes[i] = obj*/
						percent += (100/4)
					)
					this_node.wirecolor = clr_ring
					this_node.name = (uniqueName "mt_parent_")
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

/*
for i in selection where i.wirecolor != red do i.wirecolor = color 31 255 217
for i in selection do i.wirecolor = color 0 128 131

deleteNoteKeys $.pos.controller.Path_Constraint #allKeys 
$.pos.controller.keys = #()
n = getNoteTrack $.pos.controller 1

$.interpoints.controls[7]
on load do (print "updating rings..") --when max file open
on postCreate do
on deleted do --finished creation tool mode or max file reset
(
	print  "deleted"
)	

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


/*
for o in selection where classOf o==dummy do 
(
	o.baseobject = box width:1 height:1 length:1 
	o.wirecolor=green; o.boxmode=true; o.pivot = (o.min+o.max)/2
)
*/