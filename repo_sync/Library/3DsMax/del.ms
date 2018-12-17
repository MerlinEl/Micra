	
Global morphCollectorMarkers =#()
Global drawMorphCollectorMarkers
Global unregisterMorphCollectorCallback
Global morphEdgeDialog
Global MorphTagger
Global MorphCollector



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
			if modpanel.getCurrentObject() == undefined do
			(
				--unregisterRedrawViewsCallback drawMorphCollectorMarkers
				morphCollectorMarkers =#()
			)

		)
	)
)


--------------------------------------------------------------------------
/*CALLBACKS >>>*/
--------------------------------------------------------------------------

--------------------------------------------------------------------------
/*<<< CALLBACKS*/
--------------------------------------------------------------------------

callbacks.removeScripts id:#morphCollectorCallback
unregisterRedrawViewsCallback drawMorphCollectorMarkers
CompleteRedraw()
	
		
		
				fn isMorphObject obj = (classOf obj == MorphObj2)
		
		
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

		fn loadTags = 
		(
			local ring_node = getNodeByName ring_names[last_sel]
			if ring_node == undefined do return false
			tag_list.items =  ring_node.tag_names as array
		)
		fn isMorrphObjPicked = (btn_pick_morph.text != "Pick Morph Object")
		fn isHierarchyCountMatch =
		(
			local morph_obj=getNodeByName morph_obj_name
			if morph_obj == undefined or morphCollectorMarkers.count  == 0 do return false
			local collector_tags_count = 0
			for s in morphCollectorMarkers do collector_tags_count += s.tags.count
			local morphobj_tags_count = MorphObj_GetNPoints morph_obj
			--format "collector_tags_count:%\t morphobj_tags_count:%\n" collector_tags_count  morphobj_tags_count
			collector_tags_count == morphobj_tags_count
		)
		fn updateNodeList  = 
		(
			--chek this sort propery if not making trouble in ordering
			ring_list.items =sort ( for n in ring_names where (getNodeByName n) != undefined collect n)
			ring_names = ring_list.items 
			if ring_list.items.count != 0 do 
			(
				ring_list.selection = last_sel
				loadTags()
				getProjectedPoints()
				markActiveRing last_sel 
			)		
			if getNodeByName morph_obj_name != undefined do btn_pick_morph.text = morph_obj_name
			CompleteRedraw()
			--buttons disable enable
			btn_def_edges.enabled = btn_trans_po.enabled = isMorrphObjPicked() 
		)
		fn correctRingMorphCollectorTag=
		(
			local this_node = (refs.dependentNodes this)[1]
			for n in ring_names do
			(
				local ring = getNodeByName n
				if classOf ring == MorphTagger do
				(
					ring.morph_collector = this_node.name
				)
			)
		)
		fn addRing obj =
		(
			local this_node = (refs.dependentNodes this)[1]
			if classOf obj == MorphTagger then
			(
				append ring_names obj.name 
				print ring_names
				ring_list.items += #(obj.name) 
				last_sel = ring_list.items.count
				obj.morph_collector = this_node.name --send this object name to tagger
			)
			else
			(
				if obj.children.count == 0 do return false
				ring_names = #()
				for o in obj.children where classOf o == MorphTagger do
				(
					append ring_names o.name
					o.morph_collector = this_node.name --send this object name to tagger
				)				
				ring_list.items = ring_names as array
				obj.parent = this_node
				last_sel = ring_list.items.count
				select this_node
			)
			updateNodeList()
			completeRedraw()
		)
		fn remRing num =
		(
			if num == 0 do return false
			local obj = getNodeByName ring_names[num]
			if obj != undefined do ( obj.wirecolor = color 27 120 27; obj.morph_collector = "")
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
		fn transferMorphPoints=
		(
			if not  isHierarchyCountMatch() do (messageBox "Hierarchy Not Match, Please Update Edge Definition." title:"Morph Collector:" ; return false)
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
			
			--way C
			fn findPosByName tname =
			(
				for s in morphCollectorMarkers do for i=1 to s.tags.count where s.tags[i] == tname do return s.points[i]
				undefined
			)
			local tags_count = (MorphObj_GetNPoints morph_obj)
			for i=1 to tags_count do
			(
				local tag_name = MorphObj_GetPointName morph_obj (i-1)
				local tag_pos = findPosByName  tag_name
				if tag_pos != undefined do
				(
					local local_pos =  tag_pos * this_node_inv_tm
					MorphObj_SetPointPos morph_obj this_node_index (i-1) local_pos
				)
				--format "tname:%\t tpos:%\n"  tag_name tag_pos
			)
			/*
			--way B
			local names_from_morph_obj = for index=0 to (MorphObj_GetNPoints morph_obj)-1 collect MorphObj_GetPointName morph_obj index
			for array_itm in morphCollectorMarkers do 
			(
				for i=1 to array_itm.tags.count do 
				(
					local tag_name = array_itm.tags[i]
					local tag_point = array_itm.points[i]
					local tag_index =  findItem names_from_morph_obj  tag_name
					if tag_index != undefined do
					(
						local local_pos =  tag_point * this_node_inv_tm
						MorphObj_SetPointPos morph_obj this_node_index (tag_index-1) local_pos
						--format "point pos:%\tlocal pos:%\n"  p  local_pos
					)
				)
			
				
			)
			*/
			
			/*
			--way A
			--format "this_node_index:%\n" this_node_index
			local tag_index = 0
			for d in morphCollectorMarkers do for p in d.points do 
			(
				local local_pos =  p*this_node_inv_tm
				MorphObj_SetPointPos morph_obj this_node_index tag_index local_pos
				tag_index +=1
				format "point pos:%\tlocal pos:%\n"  p  local_pos
			)
			*/
		)
		fn pickMorphObject =
		(
			local o = selectByName	title:"Select Morph Object:" buttonText:"Pick" filter:isMorphObject showHidden:false single:true
			if o!= undefined do 
			(
				btn_pick_morph.text = morph_obj_name = o.name
				btn_def_edges.enabled = btn_trans_po.enabled = true
			)
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
			callbacks.addScript #selectionSetChanged "unregisterMorphCollectorCallback #sel" id:#morphCollectorCallback
			updateNodeList()
		)
		on main close do ()
		on ring_list doubleClicked sel do (edt.text = ring_list.items[sel])
		on btn_ren pressed do (if edt.text !="" and  ring_list.selection != 0 and notDupplicateFound  ring_list.items edt.text  do renamePoint edt.text )
		on btn_add picked obj do (addRing obj)
		on btn_rem pressed do (remRing ring_list.selection)	
		on ring_list selected sel do (markActiveRing sel; loadTags())
		on btn_ref pressed do (getProjectedPoints(); correctRingMorphCollectorTag())
		on btn_pick_morph pressed do (pickMorphObject())
		on btn_trans_po pressed do (transferMorphPoints())
		on btn_def_edges pressed do (mcfileInVersion "Morph_Edges"; morphEdgeDialog.getHierarchyData morph_obj_name ring_names)
    )
	on update do (print "updated....")