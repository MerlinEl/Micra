--------------------------------------------------------------------------
					/*MORPH COLLECTOR*/
						/*2012*/
--------------------------------------------------------------------------


Global morphCollectorMarkers =#()
Global drawMorphCollectorMarkers
Global unregisterMorphCollectorCallback
Global morphEdgeDialog

--------------------------------------------------------------------------
/*CALLBACKS >>>*/
--------------------------------------------------------------------------
callbacks.removeScripts id:#morphCollectorCallback
unregisterRedrawViewsCallback drawMorphCollectorMarkers
CompleteRedraw()


fn unregisterMorphCollectorCallback type= 
(
	local node = callbacks.notificationParam()
	case type of
	(
		#new:
		(
			callbacks.removeScripts id:#morphCollectorCallback
			unregisterRedrawViewsCallback drawMorphCollectorMarkers
		)
		#delmod:
		(
			
			if classOf node[2]==MorphCollector do
			(
				callbacks.removeScripts id:#morphCollectorCallback
				unregisterRedrawViewsCallback drawMorphCollectorMarkers
			)
		)
		#del:
		(
			callbacks.removeScripts id:#morphCollectorCallback
			unregisterRedrawViewsCallback drawMorphCollectorMarkers
		)
		#sel:
		(
			if modpanel.getCurrentObject() == undefined do unregisterRedrawViewsCallback drawMorphCollectorMarkers
		)
	)
)

fn drawMorphCollectorMarkers = 
(	
	gw.setTransform(Matrix3 1)
	for d in morphCollectorMarkers do for p in d.points do 
	(
		local p = gw.hTransPoint p
		gw.hMarker p #hollowBox color:orange
		gw.hMarker p #asterisk color:yellow
	)
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)
--------------------------------------------------------------------------
/*<<< CALLBACKS*/
--------------------------------------------------------------------------


plugin modifier MorphCollector
name:"Morph Collector"
classID:#(0x6b0f2189, 0x17b2df79)
(
	struct MORPH_DATA(ring, tags=#(), points=#())
	local MD = #()
	parameters param_main rollout:main
	(
		ring_names type:#filenameTab tabSize:0 tabSizeVariable:true
		last_sel type:#integer default:1
		morph_obj_name  type:#string default:""
		edge_list type:#filenameTab tabSize:0 tabSizeVariable:true
	)
	rollout main "Collections:"
	(
		fn isMorphTagger obj = 
		(
			local this_node = (refs.dependentNodes this)[1]
			obj.parent != this_node and  
			(classOf obj == MorphTagger or classOf obj == Dummy) and
			findItem main.ring_list.items obj.name == 0
		)
		fn isMorphObject obj = (classOf obj == MorphObj2)
		group "Rings:"
		(
			listBox ring_list "" pos:[7,24] width:147 height:8  items:#()
			editText edt "" pos:[4,136] width:150 height:20 
			pickButton btn_add "Add" pos:[8,160] width:45 height:24 tooltip:"Add ring[s] to list" filter:isMorphTagger
			button btn_ren "Rename" pos:[56,160] width:50 height:24 tooltip:"Rename selected ring"
			button btn_rem "Del" pos:[109,160] width:45 height:24 tooltip:"Remove selected ring from list"
			button btn_ref "Rerfresh" pos:[7,186] width:147 height:24 tooltip:"Redraw marker points"
		)
		group "Interpoints:"
		(
			listBox tag_list "" pos:[7,240] width:147 height:8 items:#()
		)
		group "Distribution:"
		(
			button btn_def_edges "Define Edges" pos:[7,380] width:147 height:24 tooltip:"Add Edges"
			button btn_pick_morph "Pick Morph Object" pos:[7,406] width:147 height:24 tooltip:"Pick Morph Object" 
			button btn_trans_hy "Transfer Hierarchy" pos:[7,432] width:147 height:24 tooltip:"Build Hierarchy Tags and Edges" 
			button btn_trans_po "Transfer Points" pos:[7,458] width:147 height:24 tooltip:"Transfer Tag Positions"
		)
		fn insPectMorphObject morph_obj =
		(
			for i=0 to (MorphObj_GetNEdges morph_obj)-1 do 
			(
				local a=MorphObj_GetEdgePoint0 morph_obj i
				local b=MorphObj_GetEdgePoint1 morph_obj i
				local p1=MorphObj_GetPointName morph_obj a
				local p2=MorphObj_GetPointName morph_obj b
				format "index:%\tpoints:%\ta:%\tb:%\n" i(#(p1, p2)) a b 
			)
		)
		fn markActiveRing sel =
		(
			if ring_names.count == 0 do return false
			local obj = (getNodeByName ring_names[sel])
			if obj == undefined do return false
			for n in ring_names do 
			(
				local o =  getNodeByName n
				if o != undefined do (o.wirecolor = (color 27 120 27))
			)
			obj.wirecolor = green
			last_sel = sel
			CompleteRedraw()
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
			MD = #()
			local rings = for n in ring_names where (local obj = getNodeByName n) != undefined collect obj
			for o in rings do
			(
				append MD (MORPH_DATA ring:o.name) --add new data list to  array
				for n in o.tag_names where (local obj = getNodeByName n) != undefined do 
				(
					local tag_pos = obj.pos
					local ring_pos = o.pos
					local vert_pos = getVertPosByHit tag_pos ring_pos this_node
					if vert_pos != undefined do --fill data list
					(	
						MD[MD.count].tags += #(n)
						MD[MD.count].points += #(vert_pos)
					)
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
			--chek this sort propery if not making trouble in ordering
			ring_list.items =sort ( for n in ring_names where (getNodeByName n) != undefined collect n)
			ring_names = ring_list.items 
			morphCollectorMarkers = MD
			if ring_list.items.count != 0 do 
			(
				ring_list.selection = last_sel
				loadTags()
				getProjectedPoints()
				markActiveRing last_sel 
			)		
			if getNodeByName morph_obj_name != undefined do btn_pick_morph.text = morph_obj_name
			CompleteRedraw()
		)
		fn addRing obj =
		(
			if classOf obj == Dummy then
			(
				if obj.children.count == 0 do return false
				ring_names = for o in obj.children where classOf o == MorphTagger collect o.name
				ring_list.items = ring_names as array
				local this_node = (refs.dependentNodes this)[1]
				obj.parent = this_node
				last_sel = ring_list.items.count
				select this_node
			)
			else if classOf obj == MorphTagger do
			(
				append ring_names obj.name 
				ring_list.items += #(obj.name) 
				last_sel = ring_list.items.count
			)
			updateNodeList()
			completeRedraw()
		)
		fn remRing num =
		(
			if num == 0 do return false
			local obj = getNodeByName ring_names[num]
			if obj != undefined do obj.wirecolor = (color 27 120 27)
			deleteItem ring_names num
			ring_list.items = deleteItem ring_list.items num
			last_sel = ring_list.items.count
			updateNodeList()
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
		fn getPointByName morph_obj  tag_name =
		(
			for i=0 to (MorphObj_GetNPoints morph_obj)-1 where MorphObj_GetPointName morph_obj i == tag_name do return i
			return undefined
		)
		fn transferMorphHierarchy =
		(
			local morph_obj=getNodeByName morph_obj_name
			if morph_obj == undefined do
			(
				messageBox "Pick a Morph Object First."  title:"Morph Collector:"
				return false
			) 
			--delete old point names
			if MorphObj_GetNPoints morph_obj as Integer != 0 do
			(
				if not queryBox "Do you want reset all settings and add new hierarchy?" title:"Morph Collector:" do return false 
				while (MorphObj_GetNPoints morph_obj) > 0 do MorphObj_DelPoint morph_obj 0
			)
			--add new point names
			for n in ring_names where (local ring = getNodeByName n) != undefined do for t in ring.tag_names do 
			(
				MorphObj_AddPoint morph_obj t
			)
			--clear edge definition
			while (MorphObj_GetNEdges morph_obj ) > 0 do MorphObj_DelEdge morph_obj 0
			--add edges definition
			for i=0 to edge_list.count-1 do
			(
				local flt=filterString edge_list[i+1] ", "
				local index_a = getPointByName morph_obj  flt[1]
				local index_b = getPointByName morph_obj  flt[2]
				--format "index:%\tpoints:%\ta:%\tb:%\n" i flt index_a index_b
				MorphObj_AddEdge morph_obj index_a index_b
			)
			--select morph_obj
			completeRedraw()
			--insPectMorphObject morph_obj
		)
		fn transferMorphPoints=
		(
			local this_node = (refs.dependentNodes this)[1]
			local m = this_node.modifiers[#MorphEditMod]
			if m == undefined do return undefined
			local morph_obj=getNodeByName morph_obj_name
			if morph_obj == undefined do 
			(
				messageBox "Pick a Morph Object First."  title:"Morph Collector:"
				return false
			) 
			fn getMorphObjectIndex this_node morph_obj =
			(
				for i=0 to (MorphObj_GetNTargets morph_obj as Integer)-1 where 
				(
					MorphObj_GetTargetControlMesh morph_obj i == this_node	
				) do return i
				return undefined
			)
			local this_node_index = getMorphObjectIndex this_node morph_obj
			local this_node_inv_tm = Inverse this_node.transform
			--format "this_node_index:%\n" this_node_index
			local tag_index = 0
			for d in morphCollectorMarkers do for p in d.points do 
			(
				local local_pos =  p*this_node_inv_tm
				MorphObj_SetPointPos morph_obj this_node_index tag_index local_pos
				tag_index +=1
				format "point pos:%\tlocal pos:%\n"  p  local_pos
			)
		)
		fn pickMorphObject =
		(
			local o = selectByName	title:"Select Morph Object:" buttonText:"Pick" filter:isMorphObject showHidden:false single:true
			if o!= undefined do btn_pick_morph.text = morph_obj_name = o.name
		)
		on main open do 
		(
			print "Selected Morph Collector"
			callbacks.removeScripts id:#morphCollectorCallback
			unregisterRedrawViewsCallback drawMorphCollectorMarkers
			registerRedrawViewsCallback drawMorphCollectorMarkers
			callbacks.addScript #systemPostNew "unregisterMorphCollectorCallback #new" id:#morphCollectorCallback
			callbacks.addScript #systemPostReset "unregisterMorphCollectorCallback #new" id:#morphCollectorCallback
			callbacks.addScript #filePostOpen "unregisterMorphCollectorCallback #new" id:#morphCollectorCallback
			callbacks.addScript #preModifierDeleted "unregisterMorphCollectorCallback #delmod" id:#morphCollectorCallback
			callbacks.addScript #nodePreDelete "unregisterMorphCollectorCallback #del" id:#morphCollectorCallback
			--callbacks.addScript #selectionSetChanged "unregisterMorphCollectorCallback #sel" id:#morphCollectorCallback
			updateNodeList()
		)
		on main close do ()
		on ring_list doubleClicked sel do (edt.text = ring_list.items[sel])
		on btn_ren pressed do (if edt.text !="" and  ring_list.selection != 0 and notDupplicateFound  ring_list.items edt.text  do renamePoint edt.text )
		on btn_add picked obj do (addRing obj)
		on btn_rem pressed do (remRing ring_list.selection)	
		on ring_list selected sel do (markActiveRing sel; loadTags())
		on btn_ref pressed do (getProjectedPoints())
		on btn_pick_morph pressed do (pickMorphObject())
		on btn_trans_hy pressed do (transferMorphHierarchy())
		on btn_trans_po pressed do (transferMorphPoints())
		on btn_def_edges pressed do (mcfileInVersion "Morph_Edges" ;  morphEdgeDialog.fillItems (edge_list as array))
    )
	on update do (print "updated....")
)

/*
	on create do (print "new modifier aded")
	on deleted do --finished creation tool mode or max file reset
	(
		print  "deleted modifier"
		unregisterRedrawViewsCallback drawMorphCollectorMarkers
		CompleteRedraw()
	)
	on getDisplayMesh do (print "dsiplay")
	on update do 
	(
		print "update"
	)
	on main reload do (print "on reload")
	on main deleted  do (print "on deleted")--unregisterRedrawViewsCallback drawMorphCollectorMarkers)
	on update do (print "on update")
	on buildMesh do (print "building")
	on load do (print "on load")
	on deleted  do (print "on deleted")--unregisterRedrawViewsCallback drawMorphCollectorMarkers)
	tagger_node_list type:#nodeTab tabSize:0 tabSizeVariable:true
	on node_list tabChanged change tabIndex tabCount do this.theRollout.updateNodeList()

on load do <expr>
on postLoad do <expr>
on update do <nodeVar>
on deleted do...

group "Limits"


*/


/*
select $point*
po=for i in selection collect i.pos
p1=MorphObj_GetPointPos $MorphObj001 0 2
po=$
ob=$
p2=po.pos*(inverse ob.transform)
p3=in coordsys $Sphere001_ControlMesh po.pos
MorphObj_SetPointPos $MorphObj001 0 2 p2
*/

