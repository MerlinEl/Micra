---NOT USED ---
Global ls3dLodManagerDialog
if ls3dLodManagerDialog != undefined do destroyDialog ls3dLodManagerDialog
rollout ls3dLodManagerDialog  "LS3D LOD Manager:" width:184 height:116
(
	struct LOD_DATA (parent_obj, lod_obj, lod_name, dist_val, lod_index, inifinite)
	groupBox 'grp1' "Distances:" pos:[4,4] width:176 height:84 align:#left
	label 'lbl1' "Lod0:" pos:[12,24] width:32 height:16 align:#left
	spinner 'spn_lod0' "" pos:[40,24] width:68 height:16 range:[0,10000,250] type:#integer scale:1 align:#left
	label 'lbl2' "Lod1:" pos:[12,44] width:32 height:16 align:#left
	spinner 'spn_lod1' "" pos:[40,44] width:68 height:16 range:[0,10000,0] type:#integer scale:1 align:#left enabled:false
	label 'lbl3' "Lod2:" pos:[12,64] width:32 height:16 align:#left
	spinner 'spn_lod2' "" pos:[40,64] width:68 height:16 range:[0,10000,0] type:#integer scale:1 align:#left enabled:false
	checkbox 'chk_infinite_1' "Infinite" pos:[120,44] width:52 height:16 checked:true  align:#left
	checkbox 'chk_infinite_2' "Infinite" pos:[120,64] width:52 height:16 checked:true align:#left
	button 'btn_build_rebuild' "BUILD - REBUILD" pos:[4,92] width:176 height:20 align:#left
	fn setupControls chk spn state = (

		spn.enabled = not state
		if state do spn.value = 0
	)
	fn addLodTo data = (
		
		local lod1_obj = if data[]
		local lod2_obj = undefined
		
		for d in data do (
			
			local parent_obj = d.parent_obj
			local lod_obj = d.lod_obj
			local lod_name = d.lod_name
			local dist_val = d.dist_val
			local lod_index = d.lod_index
			local inifinite = d.inifinite
		
			lod2_obj = gCityManager.rebuildObject lod_obj
			lod_obj.pivot  = o.pivot --copy pivot from original object

		)
		local lod2_obj = 
		
		--add  and ssetup  lods
		try (
			
			select o
			if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet())
			LS3DGUP.LODU.CreateSet()
			LS3DGUP.LODU.AddNodesToSet #(lod2_obj)
			LS3DGUP.LODU.SetSelectedLOD 0
			LS3DGUP.LODU.SetDistance 150
			LS3DGUP.LODU.SetSelectedLOD 1
			LS3DGUP.LODU.SetDistance 250
		) catch (
	
			return false
		)

		true
	)
	fn addLodes = (
		
		local objs =  selection as array
		if objs.count == 1 do return (mcMsgList.warn "not_sel")
		gProgLog.progSub 0 0
		gProgLog.msg "TLS3D LOD MANAGER:" ti:"Initialize...." ty:"new_task"
		gProgLog.msg "Proces Start" ti:"3DsMax..." ty:"task_open"
		local geo_objs = for o in objs where findString o.name "lod0" != undefined collect o --collect lods 0
		local failed_atempts = 0
		for i=1 to geo_objs.count do (

			gProgLog.progSub i geo_objs.count
			gProgLog.msg ("progress obj:"+o.name) ty:"proc"
			local obj = geo_objs[i]
			obj.pivot = (obj.min + obj.max) / 2 --center pivot of original object
			local lod1_obj = getNodeByName lod1_name
			local lod2_obj = getNodeByName lod2_name
			local lod1_name = substituteString obj.name "lod0" "lod1"
			local lod2_name = substituteString obj.name "lod0" "lod2"
			local data = #()
			local lod_index = 1
			if classOf lod1_obj == Editable_Poly then append data ( LOD_DATA \
				
				parent_obj:	o \
				lod_obj:		lod1_obj \
				lod_name:	lod1_name \
				dist_val:		spn_lod1.value \
				lod_index:	lod_index
				infinite:			chk_infinite_1.checked
				
				lod_index += 1
				
			) else gProgLog.msg ("Skip lod1 for object:"+obj.name+". Missing Lod Node.") ty:"error"
			
			if classOf lod2_obj == Editable_Poly then append data ( LOD_DATA \
				
				parent_obj:	o \
				lod_obj:		lod2_obj \
				lod_name:	lod2_name \
				dist_val:		spn_lod2.value \
				lod_index:	lod_index
				infinite:			chk_infinite_2.checked
			) else gProgLog.msg ("Skip lod2 for object:"+obj.name+". Missing Lod Node.") ty:"error"
			
			local success = addLodTo o data
			if not success do failed_atempts += 1
		)
		if failed_atempts > 0 do gProgLog.msg ("( "+failed_atempts as string +" ) Lods was not aded. See trace log for more details.") ty:"proc"
		gProgLog.progSub geo_objs.count geo_objs.count
		gProgLog.msg "All Done" ty:"task_close"
	)
	on btn_build_rebuild pressed 	do  addLodes()
	on chk_infinite_1 changed state do (setupControls chk_infinite_1 spn_lod1 state)
	on chk_infinite_2 changed state do (setupControls chk_infinite_2 spn_lod2 state)
)
createDialog ls3dLodManagerDialog