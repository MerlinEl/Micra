/**
*@Author MerlinEl 2020
*@Thanks to Michal Drimalka, Jakub Vavrik, Vit Selinger, Bernardo Ruas
*@Usage Create layers with LOD1 & LOD2 from Layer LOD0
*/

if mcCloneLayerTreeDialog != undefined do destroyDialog mcCloneLayerTreeDialog
rollout mcCloneLayerTreeDialog "Clone Layer Tree" width:348 height:312
(
	GroupBox 'grp1' "Models Settings:" pos:[4,32] width:172 height:132 align:#left
	label 'lbl1' "Info > Pick Layer with LOD0, fill setup and press Clone Hierarchy." pos:[8,8] width:316 height:20 align:#left
	checkbox 'chk_lod1' "" pos:[12,76] width:20 height:24 enabled:false checked:true align:#left
	label 'lbl2' "lod1 distance:" pos:[36,80] width:72 height:16 align:#left
	label 'lbl3' "lod2 distance:" pos:[36,108] width:72 height:16 align:#left
	spinner 'spn_lod1_dist' "" pos:[112,80] width:56 height:16 range:[1,10000,250] type:#integer scale:1 align:#left
	checkbox 'chk2' "infinite" pos:[116,105] width:52 height:20 enabled:false checked:true align:#left
	checkbox 'chk_lod2' "" pos:[12,104] width:20 height:24 enabled:false checked:true align:#left
	label 'lbl4' "Single Instances to modules" pos:[36,136] width:134 height:20 align:#left
	checkbox 'chk4' "" pos:[12,132] width:20 height:24 enabled:false checked:true align:#left
	button 'btn_clone_geo_hierarchy' "Clone Models Hierarchy" pos:[4,168] width:172 height:48 align:#left
	GroupBox 'grp2' "Collisions Settings:" pos:[184,32] width:160 height:48 align:#left
	checkbox 'chk10' "" pos:[12,48] width:20 height:24 enabled:false checked:true align:#left
	label 'lbl9' "lod0 distance:" pos:[36,52] width:72 height:16 align:#left
	spinner 'spn_lod0_dist' "" pos:[112,52] width:56 height:16 range:[1,10000,5] type:#integer scale:1 align:#left
	GroupBox 'grp7' "Custom Tools:" pos:[180,84] width:164 height:180 align:#left
	button 'btn_destroy_lodes' "Destroy lodes on Sel" pos:[184,104] width:152 height:24 align:#left
	progressBar 'doit_prog' "" pos:[4,292] width:340 height:14 color:(color 255 127.5 0) align:#left 
	button 'btn_generate_cols' "Generate Collisions" pos:[4,220] width:172 height:40 align:#left
	label 'lbl16' "layer index:" pos:[192,52] width:72 height:16 align:#left
	spinner 'spn_layer_index' "" pos:[268,52] width:68 height:16 range:[-10000,10000,-1] type:#integer scale:1 align:#left
	button 'btn_fix_sufix' "Fix suffix" pos:[185,132] width:52 height:24 toolTip:"Fix suffix in selected object(s)" align:#left
	edittext 'edt_suffix' pos:[240,134] width:72 height:20 align:#left text:"coll"
	button 'btn_manage_instances' "Manage Modules ( Lod0 )" pos:[184,184] width:152 height:24 toolTip:"Move leader from each instance in to layer modules_LOD0.Select Objects to progress." align:#left
	button 'btn_sel_instances' "Select instances" pos:[184,160] width:152 height:24 toolTip:"Select an object instances" align:#left
	button 'btn_sel_lod_1_2_instances' "Manage Modules (Lod1 - Lod2)" pos:[180,236] width:156 height:24 toolTip:"Manage instances for LOD1 and LOD2" align:#left
	label 'lbl_modules_offset' "modules offset:" pos:[184,216] width:72 height:16 align:#left
	spinner 'spn_modules_offset' "" pos:[260,216] width:76 height:16 range:[0,1e+06,10983.5] type:#float scale:1 align:#left
	edittext 'edt_coll_node_name' "coll node name" pos:[12,268] width:332 height:20 align:#left
	fn cutRight str trimChars:"" ignoreCase:false = (
		
		if str == undefined do return ""
		local rgx, pattern
		if trimChars.count != 0 then (		--remove word from begin
			
			pattern = trimChars+"+$" 
			if ignoreCase then (
			
				local option = dotnetClass "System.Text.RegularExpressions.RegexOptions"
				rgx = dotnetObject "System.Text.RegularExpressions.Regex" pattern option.IgnoreCase
			) else (
			
				rgx = dotnetObject "System.Text.RegularExpressions.Regex" pattern
			)	
			rgx.Replace str ""
			
		) else (	--remove all spaces from left
			
			pattern = "\s+$" 
			local rgx = dotnetObject "System.Text.RegularExpressions.Regex" pattern
			rgx.Replace str ""
		)
	)
	fn getRotation obj = (
		local x = obj.rotation.x_rotation
		local y = obj.rotation.y_rotation
		local z = obj.rotation.z_rotation
		return [x,y,z]
	)
	fn setRotation obj rot = (
		obj.rotation.x_rotation = rot.x
		obj.rotation.y_rotation = rot.y
		obj.rotation.z_rotation = rot.z
	)
	fn getOrCreateLayerFromName layer_name = (
			
			local la = layermanager.getLayerFromName layer_name
			if la == undefined do la = layermanager.newLayerFromName layer_name
			la
	)
	fn getSelectedLayer topMost:false = (
	
		local active_explorer = SceneExplorerManager.GetActiveExplorer()
		local selected_items = active_explorer.SelectedItems()
		local first_item = selected_items[1]
		if first_item == undefined do return undefined
		if superClassOf first_item != Base_Layer do first_item = first_item.layer   
		if topMost and first_item != undefined do (
			--get top most parent
			while first_item.getParent() != undefined do first_item = first_item.getParent() 
		)
		first_item
	)
	fn getNameSuffix name_str lowerCase:false = ( --LOD0, LOD1, LOD2
	
		local name_arr = filterString name_str "_"
		local suffix = name_arr[name_arr.count]
		if lowerCase then toLower suffix else suffix
	)
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
	fn isUniqueInstancesSet collection instances = (
		
		local dupes = 0
		for o in instances where findItem collection o do dupes += 1
		dupes == 0
	)
	fn selectObjectInstances objs = (
		
		if objs.count != 1 do (
			
			messageBox ("Select an Object to get instances.") title:"Warning:"
			return false
		)
		local object_instances = #()
		InstanceMgr.GetInstances objs[1] &object_instances
		select object_instances
	) 
	fn manageLod1Lod2Instances = (

		max select none
		local layer_modules_lod0 = getOrCreateLayerFromName "modules_LOD0"
		if layer_modules_lod0 == undefined do (
		
			messageBox ("The Layer modules_LOD0 not found") title:"Warning:"
			return false
		)
		local layer_nodes = #()
		getLayerNodes layer_modules_lod0 &layer_nodes
		if layer_nodes.count == 0 do (
			
			messageBox ("The Layer modules_LOD0  is empty.") title:"Warning:"
			return false
		)
		local lod_instances = #()
		max select none
		for o in layer_nodes where superClassOf o == GeometryClass do with redraw off(
		
			select o
			local num_lods = LS3DGUP.LODU.GetNumLODs() 
			if num_lods < 2 do continue
			for i=1 to num_lods-1 do ( --begin from second lod1

				LS3DGUP.LODU.SetSelectedLOD i
				local lod_node = LS3DGUP.LODU.GetNode()
				local lod_offset = spn_modules_offset.value
				lod_node.pos = o.pos + [lod_offset*i, 0, 0]
				setRotation lod_node (getRotation o)
				local layer_modules_x = getOrCreateLayerFromName ("modules_LOD" + i as string)
				layer_modules_x.addNode lod_node --add obj in to collision layer
			
				append lod_instances lod_node
			)
		)
		max select none
		select lod_instances
		messageBox ("Done! ( "+lod_instances.count as string+" )") title:"Finished:"	
	)
	fn manageInstances = (
		
		local models_layer = getSelectedLayer topMost:true
		if models_layer == undefined or (getNameSuffix models_layer.name lowerCase:true) != "lod0" or findString (toLower models_layer.name) "modules" != undefined do (
			
			messageBox ("The Models Layer LOD0 must be selected.") title:"Warning:"
			return false
		)
		local models_lod0 = #()
		getLayerNodes models_layer &models_lod0
		if models_lod0.count == 0 do (
			
			messageBox ("The Models Layer LOD0  is empty.") title:"Warning:"
			return false
		)
		max select none
		local collection = #() --collect only single objects (no multiple instances)
		local single_ones = #()
		local target_layer = getOrCreateLayerFromName "modules_LOD0"
		if (target_layer.getNumChildren() > 0) do getLayerNodes target_layer &collection --append existing instance to exclude from check 
		for o in models_lod0 do (
			
			local object_instances = #()
			InstanceMgr.GetInstances o &object_instances
			 --check if we added a instance member already
			if object_instances.count > 1 do ( --add one instance from objects
				
				 if  (isUniqueInstancesSet collection object_instances) do (
					 
					--it is prefered to chosse instance from layer "modules_LOD0"
					local prefered_o = for inst_o in object_instances where inst_o.layer.name == target_layer.name do exit with inst_o
					if classOf prefered_o == OkClass then (
					
						append single_ones (instance o)
									
					) else append single_ones prefered_o
				)	
			)
			append collection o --append each to exclude from check later
		)
		local cnt = 0;
		for o in single_ones where o.layer.name != target_layer.name do (
			cnt+=1
			target_layer.addNode o
		)
		select single_ones
		messageBox ("Done! ( "+cnt as string+" )") title:"Finished:"	
	)
	fn copyModelsLayersTree  obj = (
		
		local cnt = obj.getNumChildren()
		if cnt > 0 do (
			
			for i = 1 to cnt do (
				
				local ch = obj.getChild i
				local o =  getOrCreateLayerFromName ch.name
				--format "class:% of o:%\n" (classOf o) o.name 
				if classOf o != MixinInterface do continue
				if o.getNumChildren() > 0 do copyModelsLayersTree o
					
				local layer_name = cutRight o.name trimChars:"_LOD0" ignoreCase:true
				local la_1 = getOrCreateLayerFromName (layer_name + "_LOD1")
				local la_2 = getOrCreateLayerFromName (layer_name + "_LOD2")
				
				local obj_parent = o.getParent() 
				if obj_parent == undefined do continue
					
				local parent_layer_name = cutRight obj_parent.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
				local parent_lod1 = getOrCreateLayerFromName (parent_layer_name + "_LOD1")
				local parent_lod2 = getOrCreateLayerFromName (parent_layer_name + "_LOD2")
				la_1.setParent parent_lod1
				la_2.setParent parent_lod2
			)
		)
	) 
	fn copyCollisionsLayersTree obj = (
				
		local cnt = obj.getNumChildren()
		if cnt > 0 do (
			
			for i = 1 to cnt do (
				
				local ch = obj.getChild i
				local o =  getOrCreateLayerFromName ch.name
				--format "class:% of o:%\n" (classOf o) o.name 
				if classOf o != MixinInterface do continue
				if o.getNumChildren() > 0 do copyCollisionsLayersTree o
					
				local layer_name = cutRight o.name trimChars:"_LOD0" ignoreCase:true
				local la_1 = getOrCreateLayerFromName (layer_name + "_COLL")
				
				local obj_parent = o.getParent() 
				if obj_parent == undefined do continue
				
				local parent_layer_name = cutRight obj_parent.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
				local parent_lod1 = getOrCreateLayerFromName (parent_layer_name + "_COLL")
				la_1.setParent parent_lod1
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
	fn cloneObjAs obj suffix = (
		
		local new_obj = copy obj
		local new_name = cutRight obj.name trimChars:"_LOD0" ignoreCase:true --remove last suffix if exists
		new_obj.name = new_name + suffix
		new_obj
	)
	fn fixObjectSuffix obj suff = (
		
		local o_name = obj.name
		local coll_index = findString o_name ("_"+suff)
		if coll_index != undefined do o_name = replace o_name coll_index ("_"+suff).count ""
		coll_index = findString o_name suff
		if coll_index != undefined do o_name = replace o_name coll_index suff.count ""
		obj.name = (uniqueName o_name)	+ "_" + suff
	)
	----------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------
	fn generateCollisions = (
		

		if edt_coll_node_name.text.count > 0 do (
		
			local coll_node = getNodeByName edt_coll_node_name.text
			if coll_node == undefined do (
			
				messageBox "Collision Node ( "+edt_coll_node_name.text+" ). Not Found" title:"Aborted"
				return false;
			)
		)
		
		subobjectlevel = 0
		max create mode
		--get selected layer
		local layer_models = getSelectedLayer()
		if layer_models == undefined do (
			
			messageBox ("Select a layer to progress...") title:"Warning:"
			return false
		)
		local suffix = ((local arr = filterString layer_models.name "_"); arr[arr.count])
		if suffix != "LOD0" do (
			
			messageBox ("Select MODELS layer( _LOD0 )") title:"Warning:"
			return false
		)
		local s_mat = currentMaterialLibrary["semantic_materials"]
		if s_mat == undefined do  s_mat = meditmaterials["semantic_materials"]
		if s_mat == undefined then (
				
			messageBox ("Semantic Materials Not Found.\nPlease add Semantic Materials in to Library") title:"Warning:"
			return false
		)
		--get modules_COLL Layer
		local layer_modules_lod0 = layermanager.getLayerFromName "modules_LOD0"
		if layer_modules_lod0 == undefined then (
				
			messageBox ("Layer modules_LOD0 not found.") title:"Warning:"
			return false
		)
		if not (queryBox ("Do you wish to generate Collisions:\n[ "+layer_models.name+" ]?") title:"Query:") do return OK
		--get objs from selected layer tree
		local layer_nodes = #()
		getLayerNodes layer_models &layer_nodes
		if layer_nodes.count == 0 do (
			
			messageBox ("The Layer:" + layer_models.name + " is Empty") title:"Warning:"
			return false
		)
		--get objs from modules_COLL layer
		local modules_nodes = #()
		getLayerNodes layer_modules_lod0 &modules_nodes
		--merge objs
		join layer_nodes modules_nodes
		--clone all layer objects (local instances will remains)
		local node_clones = #()
		maxOps.cloneNodes layer_nodes cloneType:#copy newNodes:&node_clones
		--create or pick collisions layer
		local layer_name = cutRight layer_models.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
		local layer_colls_name = layer_name + "_COLL"
		local layer_colls = getOrCreateLayerFromName layer_colls_name
		--create or pick modules_COLL Layer
		local layer_modules = getOrCreateLayerFromName "modules_COLL"
		--create collisions lyers for LOD0
		copyCollisionsLayersTree layer_models
		--manage new collisions objects
		local collection = #() --collect only single objects (no multiple instances)
		for i = 1 to node_clones.count do with redraw off  (
			
			local o = node_clones[i]
			if superClassOf o != GeometryClass do continue;
			--fix clone name
			local obj_name = cutRight o.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
			o.name = obj_name + "_coll"
			--add default wirecolor
			o.wirecolor = color 177 28 149
			--ling to node if is defined else nothing
			if coll_node != undefined do o.parent = coll_node
			--move clone in to coll layer
			local parent_layer = o.layer.getParent()
			local layer_name = cutRight o.layer.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
			if layer_name != "modules" then (
			
				local new_layer_coll = getOrCreateLayerFromName (layer_name + "_COLL")
				new_layer_coll.addNode o --add obj in to collision layer
				if parent_layer != undefined do ( --move coll layer in to coll parent layer
					
					local parent_layer_name = cutRight parent_layer.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
					local new_parent = getOrCreateLayerFromName (parent_layer_name + "_COLL")
					new_layer_coll.setParent new_parent
				)
			) else (
			
				layer_modules.addNode o
			)
			--collect one Leader from each instance and move him in to modules_COLL layer
			local object_instances = #()
			InstanceMgr.GetInstances o &object_instances
			if object_instances.count > 1 then ( --add one instance from objects
				 --check if we added instance member already
				 if  (isUniqueInstancesSet collection object_instances) do (
					 
					--it is prefered to chosse instance from layer "modules_LOD0"
					local prefered_o = for inst_o in object_instances where inst_o.layer.name == "modules_COLL" do exit with inst_o
					if classOf prefered_o == OkClass then ( --any of instances is in modules
					
						join collection object_instances --remove from search all instances from this object
						select o --prevent error msg in LOD destroy
						--destroy lod if collision have one
						if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet()) --of obj has lodes destroy it
						--add sementic material
						o.material = s_mat
						--change material id to 1 (uni hard)
						local mat_mod = Materialmodifier()
						addModifier o mat_mod
						mat_mod.materialID = 1
						maxops.CollapseNodeTo o 1 false
						--add collision prameter (Data Manager)
						AddCustomAttributeByName o "CollisionMesh"
						o.'~layer' = spn_layer_index.value
						
					) else ( --is already in modules
					
						append collection prefered_o
					)
				)	
			) else ( --process objects without instances
			
				select o --prevent error msg in LOD destroy
				--destroy lod if collision have one
				if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet()) --of obj has lodes destroy it
				--add sementic material
				o.material = s_mat
				--change material id to 1 (uni hard)
				local mat_mod = Materialmodifier()
				addModifier o mat_mod
				mat_mod.materialID = 1
				maxops.CollapseNodeTo o 1 false
				--add collision prameter (Data Manager)
				AddCustomAttributeByName o "CollisionMesh"
				o.'~layer' = spn_layer_index.value
			)
			doit_prog.value = 100.*i/node_clones.count
		)
		doit_prog.value = 0 -- when ready, reset the progress bar to 0%
		messageBox "Done!" title:"Finished:"
	)
	----------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------
	fn cloneGeoHierarchy = (
		
		subobjectlevel = 0
		max create mode
		--get selected layer
		local layer_models = getSelectedLayer()
		if layer_models == undefined do (
			
			messageBox ("Select a layer to progress...") title:"Warning:"
			return false
		)
		local suffix = ((local arr = filterString layer_models.name "_"); arr[arr.count])
		if suffix != "LOD0" do (
			
			messageBox ("Select MODELS layer( _LOD0 )") title:"Warning:"
			return false
		)
		if not (queryBox ("Do you wish to clone models hierarchy:\n[ "+layer_models.name+" ]?") title:"Query:") do return OK
		--get objs from selected layer tree
		local layer_nodes = #()
		getLayerNodes layer_models &layer_nodes
		if layer_nodes.count == 0 do (
			
			messageBox ("The Layer:" + layer_models.name + " is Empty") title:"Warning:"
			return false
		)
		--create  model lyers for LOD1 LOD2
		copyModelsLayersTree layer_models
		--filter clones to remain only one from each
		local collection = #() --collect only single objects (no multiple instances)
		for o in layer_nodes do (
			
			local object_instances = #()
			InstanceMgr.GetInstances o &object_instances
			if object_instances.count > 1 then ( --add one instance from objects
				 --check if we added instance member already
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
			local new_obj_lod1 = cloneObjAs o "_lod1"
			new_obj_lod1.parent = undefined --unlink lod
			new_obj_lod1.wirecolor = o_wirecolor_lod_1
			select new_obj_lod1 --prevent error msg
			if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet()) --of obj has lodes destroy it
			addNodeInLodSet o new_obj_lod1 1 spn_lod1_dist.value
			local layer_name = cutRight o.layer.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
			local new_layer_lod1 = getOrCreateLayerFromName (layer_name + "_LOD1")
			new_layer_lod1.addNode new_obj_lod1 --add new_obj_lod1 in to desired layer
			--check the parent of the main layer
			if parent_layer != undefined do (
				
				local parent_layer_name_lod1 = cutRight parent_layer.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
				local new_parent_lod1 = getOrCreateLayerFromName (parent_layer_name_lod1 + "_LOD1")
				--format "\tLOD1 > new obj:% new layer:% \n" new_obj_lod1.name new_parent_lod1.name
				new_layer_lod1.setParent new_parent_lod1
			)
			--LOD 2	
			local new_obj_lod2 = cloneObjAs o "_lod2"
			new_obj_lod2.parent = undefined --unlink lod
			new_obj_lod2.wirecolor = o_wirecolor_lod_2
			select new_obj_lod2 --prevent error msg
			if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet()) --of obj has lodes destroy it
			addNodeInLodSet o new_obj_lod2 1 spn_lod1_dist.value
			local new_layer_lod2 = getOrCreateLayerFromName (layer_name + "_LOD2")
			new_layer_lod2.addNode new_obj_lod2 --add new_obj_lod2 in to desired layer	
			--check the parent of the main layer
			if parent_layer != undefined do (
				
				local parent_layer_name_lod2 = cutRight parent_layer.name trimChars:"_LOD0" ignoreCase:true --remove last suffix
				local new_parent_lod2 = getOrCreateLayerFromName (parent_layer_name_lod2 + "_LOD2")
				--format "\tLOD2 > new obj:% new layer:% \n" new_obj_lod2.name new_parent_lod2.name
				new_layer_lod2.setParent new_parent_lod2
			)
			doit_prog.value = 100.*i/collection.count
		)
		doit_prog.value = 0 -- when ready, reset the progress bar to 0%
		messageBox "Done!" title:"Finished:"
	)
	on btn_clone_geo_hierarchy pressed  do undo off  cloneGeoHierarchy()
	on btn_generate_cols pressed  do undo off  generateCollisions()
	on btn_destroy_lodes pressed do undo off destroyLodesOnSelection (selection as array)
	on btn_fix_sufix pressed do undo "Fix Suffix" on (for o in selection do fixObjectSuffix o edt_suffix.text)
	on btn_sel_instances pressed do selectObjectInstances (selection as array)
	on btn_manage_instances pressed do undo "Manage Instances" on manageInstances ()
	on btn_sel_lod_1_2_instances pressed do undo "Manage Lod1 - Lod2 Instances" on manageLod1Lod2Instances ()
)
createDialog mcCloneLayerTreeDialog

/*

		local target_layer = getOrCreateLayerFromName ("modules_" + sel_layer_suffix)
		if ((toLower sel_layer_suffix) == "lod1" or (toLower sel_layer_suffix) == "lod2") do (
		
			messageBox "is not lod 0" title:sel_layer_suffix
			return ok
		)
*/



/*
maxOps.cloneNodes objs cloneType:#copy actualNodeList:cur_objs newNodes:&new_objs
objs = getObjectsInLayer layer:layer_models
select objs

layer_models = getSelectedLayer()

layer_nodes.count
trimRight layer_models.name "LOD0"
superClassOf layer_models == MixinInterface


layer_models.select true
layer_models.getNumChildren()
layer_models.getNumNodes()

cloneHierarchy()

layer_models.nodes  &theNodes
layer_models.layerNodes 
bNodes = for i in $* where i.layer == layer_models and classof i == Container collect i

layer = layermanager.getLayerFromName "lh_loc_steamboat_LOD0"
 layer.nodes &thenodes
 select thenodes
 */