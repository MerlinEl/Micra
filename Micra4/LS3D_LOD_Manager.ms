---NOT USED ---
Global ls3dLodManagerDialog
if ls3dLodManagerDialog != undefined do destroyDialog ls3dLodManagerDialog
rollout ls3dLodManagerDialog "LS3D LOD Manager:" width:480 height:116
(
	struct LOD_OBJECTS (lod0, lod1, lod2)
	local force_load_structures = true
	GroupBox 'grp1' "Columns" pos:[4,4] width:112 height:84 align:#left
	label 'lbl1' "Lod0:" pos:[12,24] width:32 height:16 align:#left
	spinner 'spn_a_lod0' "" pos:[40,24] width:68 height:16 range:[0,10000,250] type:#integer scale:1 align:#left
	button 'btn_build_rebuild' "BUILD - REBUILD" pos:[4,92] width:472 height:20 align:#left
	GroupBox 'grp2' "Fences" pos:[124,4] width:112 height:84 align:#left
	label 'lbl4' "Lod0:" pos:[132,24] width:32 height:16 align:#left
	spinner 'spn_b_lod0' "" pos:[160,24] width:68 height:16 range:[0,10000,50] type:#integer scale:1 align:#left
	label 'lbl5' "Lod1:" pos:[132,44] width:32 height:16 align:#left
	spinner 'spn_b_lod1' "" pos:[160,44] width:68 height:16 range:[0,10000,150] type:#integer scale:1 align:#left
	GroupBox 'grp4' "Terrain" pos:[244,4] width:112 height:84 align:#left
	label 'lbl7' "Lod0:" pos:[252,24] width:32 height:16 align:#left
	spinner 'spn_c_lod0' "" pos:[280,24] width:68 height:16 range:[0,10000,250] type:#integer scale:1 align:#left
	label 'lbl8' "Lod2:" pos:[252,44] width:32 height:16 align:#left
	spinner 'spn_c_lod2' "" pos:[280,44] width:68 height:16 range:[0,10000,0] type:#integer scale:1 align:#left
	GroupBox 'grp8' "Special" pos:[364,4] width:112 height:84 align:#left
	label 'lbl16' "Lod0:" pos:[372,24] width:32 height:16 align:#left
	spinner 'spn_d_lod0' "" pos:[400,24] width:68 height:16 range:[0,10000,50] type:#integer scale:1 align:#left
	label 'lbl17' "Lod1:" pos:[372,44] width:32 height:16 align:#left
	spinner 'spn_d_lod1' "" pos:[400,44] width:68 height:16 range:[0,10000,150] type:#integer scale:1 align:#left
	label 'lbl18' "Lod2:" pos:[372,64] width:32 height:16 align:#left
	spinner 'spn_d_lod2' "" pos:[400,64] width:68 height:16 range:[0,10000,250] type:#integer scale:1 align:#left
	--functions
	fn addLod ld = (
		
		local obj_lod0 = ld.lod0
		local obj_lod1 = ld.lod1
		local obj_lod2 = ld.lod2
		format "addLod >obj:%\n\tolod0:%\n\tlod1:%\n\tlod2:%\n" obj_lod0.name obj_lod0 obj_lod1 obj_lod2
		try (
			--first destroy old lod set at lod0 and create new
			select obj_lod0
			if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet())
			LS3DGUP.LODU.CreateSet()
			
			--teake action depend on lods count and type 
			if obj_lod1 != undefined and obj_lod2 != undefined then ( --D ) create lod set and all three distances
			
				obj_lod1 = gCityManager.rebuildObject obj_lod1 --recreate lod
				obj_lod2 = gCityManager.rebuildObject obj_lod2 --recreate lod
				obj_lod1.pivot = obj_lod0.pivot --copy pivot from lod0
				obj_lod2.pivot = obj_lod0.pivot --copy pivot from lod0
			select obj_lod0
				LS3DGUP.LODU.SetSelectedLOD 0
				LS3DGUP.LODU.SetDistance spn_d_lod0.value
				LS3DGUP.LODU.AddNodesToSet #(obj_lod1)
				LS3DGUP.LODU.AddNodesToSet #(obj_lod2)
				LS3DGUP.LODU.SetSelectedLOD 1
				LS3DGUP.LODU.SetDistance spn_d_lod1.value
				if spn_d_lod2.value > 0 do (
				
					LS3DGUP.LODU.SetSelectedLOD 2
					LS3DGUP.LODU.SetDistance spn_d_lod2.value
				)
			
			) else if obj_lod2 != undefined then ( --C ) create lod set and only first distance
			
				obj_lod2 = gCityManager.rebuildObject obj_lod2
				obj_lod2.pivot = obj_lod0.pivot --copy pivot from lod0
			select obj_lod0
				LS3DGUP.LODU.SetSelectedLOD 0
				LS3DGUP.LODU.SetDistance spn_c_lod0.value
				LS3DGUP.LODU.AddNodesToSet #(obj_lod2) --leave it with infinite distance
			
			) else if obj_lod1 != undefined then ( --B ) create lod set and add both distances
						
				obj_lod1 = gCityManager.rebuildObject obj_lod1 --recreate lod	
				obj_lod1.pivot = obj_lod0.pivot --copy pivot from lod0
			select obj_lod0			
				LS3DGUP.LODU.SetSelectedLOD 0
				LS3DGUP.LODU.SetDistance spn_b_lod0.value
				LS3DGUP.LODU.AddNodesToSet #(obj_lod1)
				LS3DGUP.LODU.SetSelectedLOD 1
				LS3DGUP.LODU.SetDistance spn_b_lod1.value
			
			) else ( --A ) create lod set only for lod0
			
				LS3DGUP.LODU.SetSelectedLOD 0
				LS3DGUP.LODU.SetDistance spn_a_lod0.value
			)
		) catch (
		
			return false
		)
		true
	)
	fn addLodes = (
		
		if not (queryBox "Add - Rebuild Lodes?" title:"Warning:") do return false
		mcFile.initStruct gCityManager "City_Manager_Struct" force:force_load_structures
		
		
		local objs =  selection as array
		if objs.count == 0 do return (mcMsgList.warn "not_sel")
		
		gProgLog.progSub 0 0
		gProgLog.msg "TLS3D LOD MANAGER:" ti:"Initialize...." ty:"new_task"
		gProgLog.msg "Proces Start" ti:"3DsMax..." ty:"task_open"
		
		 --collect visible lod0
		local geo_objs = for o in objs where findString o.name "lod0" != undefined collect o
		--take out object instances
		--TODO > find which object from instances have a lod with same name (name_ + lod1 or lod2)
		geo_objs = ::gCityManager.filterObjectsInstances geo_objs
		local failed_atempts = 0
		
		for i=1 to geo_objs.count do (

			local obj_lod0 = geo_objs[i]
			gProgLog.progSub i geo_objs.count
			gProgLog.msg ("progress with obj:"+obj_lod0.name) ty:"proc"
			obj_lod0.pivot = (obj_lod0.min + obj_lod0.max) / 2 --center pivot of original object
			--try to get lod1 and lod2
			local lod0_name = obj_lod0.name
			local lod1_name = substituteString lod0_name "lod0" "lod1"
			local lod2_name = substituteString lod0_name "lod0" "lod2"

			local obj_lod1 = getNodeByName lod1_name
			local obj_lod2 = getNodeByName lod2_name
			format "n1:% n2:% l1:% l2:%\n" lod1_name lod2_name obj_lod1 obj_lod2
			
			local ld = LOD_OBJECTS lod0:obj_lod0
			if classOf obj_lod1 == Editable_Poly do ld.lod1 = obj_lod1
			if classOf obj_lod2 == Editable_Poly do ld.lod2 = obj_lod2
			if not (addLod ld) do failed_atempts += 1
		)
		if failed_atempts > 0 do gProgLog.msg ("( "+failed_atempts as string +" ) Lods was not aded. See trace log for more details.") ty:"proc"
		gProgLog.progSub geo_objs.count geo_objs.count
		gProgLog.msg "All Done" ty:"task_close"
	)
	on btn_build_rebuild pressed do undo off (addLodes())
)
createDialog ls3dLodManagerDialog