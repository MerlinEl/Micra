for o in objects do
(
	local mod_morph = o.modifiers[#MorphCollector]
	if mod_morph != undefined do mod_morph.main.removeCallbacks()
)
/*unregisterRedrawViewsCallback drawMorphMarkers*/

/*
Global drawMorphMarkers
$.modifiers[1].main.removeCallbacks()
CompleteRedraw()
*/

plugin modifier MorphCollector
name:"Morph Collector"
classID:#(0x6b0f2189, 0x17b2df79)
(
	parameters param_main rollout:main
	(
		ring_names type:#filenameTab tabSize:0 tabSizeVariable:true
		tag_points type:#point3Tab tabSize:0 tabSizeVariable:true
		--tag_names type:#filenameTab tabSize:0 tabSizeVariable:true
		last_sel type:#integer default:1
	)
	rollout main "Collections:"
	(
		Global drawMorphMarkers
		fn isMorphTagger obj = (classOf obj == MorphTagger and findItem main.ring_list.items obj.name == 0)
		group "Rings:"
		(
			listBox ring_list "" pos:[7,24] width:147 height:8  items:#()
			editText edt "" pos:[4,136] width:150 height:20 
			pickButton btn_add "Add" pos:[8,160] width:45 height:24 filter:isMorphTagger
			button btn_ren "Rename" pos:[56,160] width:50 height:24
			button btn_rem "Rem" pos:[109,160] width:45 height:24
		)
		group "Interpoints:"
		(
			listBox tag_list "" pos:[7,212] width:147 height:8 items:#()
		)
		fn drawMorphMarkers = 
		(	
			gw.setTransform(Matrix3 1)
			for p in tag_points do
			(
				local p = gw.hTransPoint p
				gw.hMarker p #hollowBox color:orange
				gw.hMarker p #asterisk color:yellow
			)
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
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
		fn getProjectedPoints =
		(
			local this_node = (refs.dependentNodes this)[1]
			/*format "this node:%\n" this_node*/
			tag_points = #()
			local rings = for n in ring_names where (local obj = getNodeByName n) != undefined collect obj
			for o in rings do
			(
				for n in o.tag_names where (local obj = getNodeByName n) != undefined do 
				(
					local tag_pos = obj.pos
					local ring_pos = o.pos
					local vert_pos = getVertPosByHit tag_pos ring_pos this_node
					if vert_pos != undefined do append tag_points vert_pos
				)
			)
		)
		fn loadTags = 
		(
			local ring_node = getNodeByName ring_names[last_sel]
			if ring_node == undefined do return false
			tag_list.items =  ring_node.tag_names as array
		)
		fn updateNodeList  = 
		(
			ring_list.items = for n in ring_names where (getNodeByName n) != undefined collect n
			if ring_list.items.count != 0 do 
			(
				ring_list.selection = last_sel
				loadTags()
				getProjectedPoints()
			)			
		)
		fn addRing obj =
		(
			append ring_names obj.name 
			ring_list.items += #(obj.name) 
			last_sel = ring_list.items.count
			updateNodeList()
		)
		fn remRing num =
		(
			if num == 0 do return false
			deleteItem ring_names num
			ring_list.items = deleteItem ring_list.items num
			last_sel = ring_list.items.count
			updateNodeList()
		)
		fn removeCallbacks = (unregisterRedrawViewsCallback drawMorphMarkers)
		fn refreshCallbacks =
		(
			unregisterRedrawViewsCallback drawMorphMarkers
			registerRedrawViewsCallback drawMorphMarkers
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
		fn renamePoint txt =
		(
			if ring_list.items.count != 0 do 
			(
				local obj = getNodeByName ring_names[last_sel]
				if obj == undefined do return false
				ring_names[last_sel] = txt
				obj.name = txt
			)
			updateNodeList()
		)
		on main open do (updateNodeList(); refreshCallbacks(); print "open")
		on ring_list doubleClicked sel do (edt.text = ring_list.items[sel])
		on btn_ren pressed do (if edt.text !="" and  ring_list.selection != 0 and notDupplicateFound  ring_list.items edt.text  do renamePoint edt.text )
		on btn_add picked obj do (addRing obj)
		on btn_rem pressed do (remRing ring_list.selection)	
		on ring_list selected sel do (last_sel = sel ; loadTags())
		
    )
	on getDisplayMesh do (print "dsiplay")
	on update do 
	(
		unregisterRedrawViewsCallback drawMorphMarkers
		main.removeCallbacks(); print "update"
	)
)

/*
	on main reload do (print "on reload")
	on main deleted  do (print "on deleted")--unregisterRedrawViewsCallback drawMorphMarkers)
	on update do (print "on update")--refreshCallbacks())
	on buildMesh do (print "building")
	on load do (print "on load")
	on deleted  do (print "on deleted")--unregisterRedrawViewsCallback drawMorphMarkers)
	tagger_node_list type:#nodeTab tabSize:0 tabSizeVariable:true
	on node_list tabChanged change tabIndex tabCount do this.theRollout.updateNodeList()

on load do <expr>
on postLoad do <expr>
on update do <nodeVar>
on deleted do...

group "Limits"


*/


