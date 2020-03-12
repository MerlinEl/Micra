/**
*@Author MerlinEl 2020
*@Thanks to Michal Drimalka, 
*@Usage Create layers with LOD1 & LOD2 from Layer LOD0
*/

if mcCloneLayerTreeDialog != undefined do destroyDialog mcCloneLayerTreeDialog
rollout mcCloneLayerTreeDialog "Clone Layer Tree" width:328 height:231
(
	GroupBox 'grp1' "Geometry Settings:" pos:[4,32] width:172 height:132 align:#left
	label 'lbl1' "Info > Pick Layer with LOD0, fill setup and press Clone Hierarchy." pos:[8,8] width:316 height:20 align:#left
	checkbox 'chk_lod1' "" pos:[12,76] width:20 height:24 enabled:false checked:true align:#left
	label 'lbl2' "lod1 distance:" pos:[36,80] width:72 height:16 align:#left
	label 'lbl3' "lod2 distance:" pos:[36,108] width:72 height:16 align:#left
	spinner 'spn_lod1_dist' "" pos:[112,80] width:56 height:16 range:[1,10000,250] type:#integer scale:1 align:#left
	checkbox 'chk2' "infinite" pos:[116,105] width:52 height:20 enabled:false checked:true align:#left
	checkbox 'chk_lod2' "" pos:[12,104] width:20 height:24 enabled:false checked:true align:#left
	label 'lbl4' "Single Instances to modules" pos:[36,136] width:134 height:20 align:#left
	checkbox 'chk4' "" pos:[12,132] width:20 height:24 enabled:false checked:true align:#left
	button 'btn_clone_hierarchy' "Clone Hierarchy" pos:[4,168] width:320 height:40 align:#left
	GroupBox 'grp2' "Collisions Settings:" pos:[184,32] width:140 height:68 align:#left
	checkbox 'chk10' "" pos:[12,48] width:20 height:24 enabled:false checked:true align:#left
	label 'lbl9' "lod0 distance:" pos:[36,52] width:72 height:16 align:#left
	spinner 'spn_lod0_dist' "" pos:[112,52] width:56 height:16 range:[1,10000,5] type:#integer scale:1 align:#left
	GroupBox 'grp7' "Custom Tools:" pos:[180,108] width:140 height:56 align:#left
	button 'btn_destroy_lodes' "Destroy lodes on Sel" pos:[184,128] width:128 height:28 align:#left
	progressBar 'doit_prog' "" pos:[4,213] width:320 height:14 color:(color 255 127.5 0) align:#left 
-- 	fn getLayersTree main_layer &layerTree &lvl = (

-- 		var cnt = main_layer.getNumChildren()
-- 		var sub_layers = #()
-- 		for i = 1 to cnt do (

-- 			var la = main_layer.getChild i
-- 			append sub_layers la
-- 			if la.getNumChildren() > 0 do (

-- 				var lvl_ex = lvl + 1
-- 				getLayersTree la &layerTree &lvl_ex
-- 			)
-- 		)
-- 		append layerTree[lvl] sub_layers
-- 	)
-- 	/*
-- 	main_layer = getSelectedLayer()
-- 	cloneLayerHierarchy main_layer
-- 	*/
-- 	fn cloneLayerHierarchy main_layer = (

-- 		var lvl = 2
-- 		var layerTree = #(main_layer)
-- 		getLayersTree main_layer &layerTree &lvl
-- 		format "get layers tree:%\n\tmax lvl:%\n" &layerTree &lvl
-- 	)
	fn getOrCreateLayerFromName layer_name = (
			
			local la = layermanager.getLayerFromName layer_name
			if la == undefined do la = layermanager.newLayerFromName layer_name
			la
	)
	fn copyLayersTree  obj = (
		
		local cnt = obj.getNumChildren()
		if cnt > 0 do (
			
			for i = 1 to cnt do (
				
				local ch = obj.getChild i
				local o =  getOrCreateLayerFromName ch.name
				--format "class:% of o:%\n" (classOf o) o.name 
				if classOf o != MixinInterface do continue
				if o.getNumChildren() > 0 do copyLayersTree o
					
				local layer_name =  trimRight o.name "LOD0" --remove last suffix	
				local la_1 = getOrCreateLayerFromName (layer_name + "LOD1")
				local la_2 = getOrCreateLayerFromName (layer_name + "LOD2")
				
				local obj_parent = o.getParent() 
				if obj_parent == undefined do continue
					
				local parent_layer_name = trimRight obj_parent.name "LOD0" --remove last suffix
				local parent_lod1 = getOrCreateLayerFromName (parent_layer_name + "LOD1")
				local parent_lod2 = getOrCreateLayerFromName (parent_layer_name + "LOD2")
				la_1.setParent parent_lod1
				la_2.setParent parent_lod2
			)
		)
	) 
	fn destroyLodesOnSelection sel = (
	
		if queryBox ("This operation is not undoable.\nYou are sure to destroy lodes on ("+sel.count as string+") objects?") title:"Warning:" do 	(
		
			max select none
			for o in sel where superClassOf o == GeometryClass do (

				select o 
				if (LS3DGUP.LODU.GetNumLODs()) != 0 do LS3DGUP.LODU.DestroySet()
			)
			messageBox "Done!" title:"Finished:"
		)
	)
	fn getSelectedLayer = (((SceneExplorerManager.GetActiveExplorer()).SelectedItems())[1])
	fn getLayerNodes layer_node &layerNodes  subLayers:true = (
			
		if (classOf layer_node == undefined) do return #()
		--get layer objects
		local objs_in_layer = #()
		layer_node.nodes &objs_in_layer
		join layerNodes objs_in_layer
		if subLayers do (
			
			local sub_layers_count = layer_node.getNumChildren()
			for i = 1 to sub_layers_count do getLayerNodes (layer_node.getChild i) &layerNodes	
		) 
	)
	fn addNodeInLodSet trgt_obj src_obj lod_index lod_dist= (
		
		select trgt_obj
		if (LS3DGUP.LODU.GetNumLODs()) == 0 then ( --create lode if not exists (first time when add  LOD1)
			
			LS3DGUP.LODU.CreateSet()
			LS3DGUP.LODU.SetSelectedLOD 0
			LS3DGUP.LODU.SetDistance spn_lod0_dist.value
		) 
		LS3DGUP.LODU.AddNodesToSet #(src_obj)
		LS3DGUP.LODU.SetSelectedLOD lod_index
		LS3DGUP.LODU.SetDistance lod_dist
	)
	fn isUniqueInstancesSet collection instances = (
		
		local dupes = 0
		for o in instances where findItem collection o do dupes += 1
		dupes == 0
	)
	fn cloneObjAs obj suffix = (
		
		local new_obj = copy obj
		local new_name =  trimRight obj.name "lod0" --remove last suffix
		new_obj.name = new_name + suffix
		new_obj
	)
	fn cloneHierarchy = (
		
		subobjectlevel = 0
		max create mode
		--get selected layer
		local sel_layer = getSelectedLayer()
		if sel_layer == undefined do (
			
			messageBox ("Select a layer to progress") title:"Warning:"
			return false
		)
		if findString sel_layer.name "LOD0" == undefined do (
			
			messageBox ("Select layer LOD0") title:"Warning:"
			return false
		)
		if not (queryBox ("Do you wish to generate lodes from:\n"+sel_layer.name+"?") title:"Query:") do return OK
		--create  lyers for LOD1 LOD2
		copyLayersTree sel_layer
		--get objs from selected layer tree
		local layer_nodes = #()
		getLayerNodes sel_layer &layer_nodes
		if layer_nodes.count == 0 do (
			
			messageBox ("The Layer:" + sel_layer.name + " is Empty") title:"Warning:"
			return false
		)
		--filter clones to remain only one from each
		local collection = #() --collect only single objects (no multiple instances)
		for o in layer_nodes do (
			
			local object_instances = #()
			InstanceMgr.GetInstances o &object_instances
			 --check if we added a instance member already
			if object_instances.count > 1 then ( --add one instance from objects
				
				 if  (isUniqueInstancesSet collection object_instances) do (
					 
					--it is prefered to chosse instance from layer "modules_LOD0"
					local prefered_o = for inst_o in object_instances where inst_o.layer.name == "modules_LOD0" do exit with inst_o
					if classOf prefered_o == OkClass then append collection o else append collection prefered_o
				)	
				
			) else (
				
				append collection o --add not instanced objects
			)
		)
		format "all layer objects:% objs without instances:%\n" layer_nodes.count collection.count
		--clone each obj from unique collection
		--destroy lode on clone if exists
		--insert lod in to LOD0 and set distance
		--create new layer for each obj  --> LOD1
		for i = 1  to collection.count do with redraw off (
			
			local o = collection[i]
			local o_wirecolor_lod_1 = copy o.wirecolor
			local o_wirecolor_lod_2 = copy o.wirecolor
			o_wirecolor_lod_1.s = 100
			o_wirecolor_lod_2.s = 200
			local parent_layer = o.layer.getParent()	
			--format "PROCESS > obj:%\n" o.name
			--LOD 1
			local new_obj_lod1 = cloneObjAs o "lod1"
			new_obj_lod1.parent = undefined --unlink lod
			new_obj_lod1.wirecolor = o_wirecolor_lod_1
			select new_obj_lod1 --prevent error msg
			if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet()) --of obj has lodes destroy it
			addNodeInLodSet o new_obj_lod1 1 spn_lod1_dist.value
			local layer_name = trimRight o.layer.name "LOD0" --remove last suffix
			local new_layer_lod1 = getOrCreateLayerFromName (layer_name + "LOD1")
			new_layer_lod1.addNode new_obj_lod1 --add new_obj_lod1 in to desired layer
			--check the parent of the main layer
			if parent_layer != undefined do (
				
				local parent_layer_name_lod1 = trimRight parent_layer.name "LOD0" --remove last suffix
				local new_parent_lod1 = getOrCreateLayerFromName (parent_layer_name_lod1 + "LOD1")
				--format "\tLOD1 > new obj:% new layer:% \n" new_obj_lod1.name new_parent_lod1.name
				new_layer_lod1.setParent new_parent_lod1
			)
			--LOD 2	
			local new_obj_lod2 = cloneObjAs o "lod2"
			new_obj_lod2.parent = undefined --unlink lod
			new_obj_lod2.wirecolor = o_wirecolor_lod_2
			select new_obj_lod2 --prevent error msg
			if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet()) --of obj has lodes destroy it
			addNodeInLodSet o new_obj_lod2 1 spn_lod1_dist.value
			local new_layer_lod2 = getOrCreateLayerFromName (layer_name + "LOD2")
			new_layer_lod2.addNode new_obj_lod2 --add new_obj_lod2 in to desired layer	
			--check the parent of the main layer
			if parent_layer != undefined do (
				
				local parent_layer_name_lod2 = trimRight parent_layer.name "LOD0" --remove last suffix
				local new_parent_lod2 = getOrCreateLayerFromName (parent_layer_name_lod2 + "LOD2")
				--format "\tLOD2 > new obj:% new layer:% \n" new_obj_lod2.name new_parent_lod2.name
				new_layer_lod2.setParent new_parent_lod2
			)
			doit_prog.value = 100.*i/collection.count
		)
		doit_prog.value = 0 -- when ready, reset the progress bar to 0%
		messageBox "Done!" title:"Finished:"
	)
	on btn_clone_hierarchy pressed  do undo off  cloneHierarchy()
	on btn_destroy_lodes pressed do undo off destroyLodesOnSelection (selection as array)
)
createDialog mcCloneLayerTreeDialog

/*
objs = getObjectsInLayer layer:sel_layer
select objs

sel_layer = getSelectedLayer()

layer_nodes.count
trimRight sel_layer.name "LOD0"
superClassOf sel_layer == MixinInterface


sel_layer.select true
sel_layer.getNumChildren()
sel_layer.getNumNodes()

cloneHierarchy()

sel_layer.nodes  &theNodes
sel_layer.layerNodes 
bNodes = for i in $* where i.layer == sel_layer and classof i == Container collect i

layer = layermanager.getLayerFromName "lh_loc_steamboat_LOD0"
 layer.nodes &thenodes
 select thenodes
 */