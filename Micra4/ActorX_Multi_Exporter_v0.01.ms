--ActorX MULTI EXPORTER
( 
	if keyboard.shiftPressed then
	(
		if ActorXMultiExportDialog != undefined do destroyDialog ActorXMultiExportDialog 
		rollout ActorXMultiExportDialog " ActorX Multiexporter:" width:448 height:112
		(
			
			GroupBox grp1 "Output Folder:" pos:[4,4] width:440 height:104
			checkbox chk_all_skin "Set All Skin Type" pos:[16,52] width:104 height:16 checked:true
			checkbox chk_selected_only "Set Selected Geometry" pos:[16,72] width:132 height:16 checked:true
			dropdownList ddl_path_list "" pos:[16,28] width:356 height:21
			button btn_browse "Browse..." pos:[376,28] width:60 height:20
			button btn_export_mesh "Export" pos:[268,52] width:168 height:48 toolTip:""
			on ActorXMultiExportDialog open  do
			(
				local p = maxFilePath
				if p != "" do ddl_path_list.items = #(p)
			)
			on chk_all_skin changed state do ()--AX.setallskintype (if state then 1 else 0)
			on chk_selected_only changed state do ()--AX.setselectedgeometry (if state then 1 else 0)
			on btn_browse pressed do
			(
				local p = maxFilePath
				local path  = getSavePath caption:" Chose Dir..." initialDir:(if p != "" then p else "C:\\")
				if path != undefined do 
				(
					local dirs = ddl_path_list.items
					dirs += #(path)
					ddl_path_list.items = dirs
					ddl_path_list.selection = findItem dirs path
				)
			)
			on btn_export_mesh pressed do
			(
				AX.setallskintype      (if chk_all_skin.checked then 1 else 0)
				AX.setselectedgeometry (if chk_selected_only.checked then 1 else 0)
				AX.setbakesmoothing 1
				local sel = selection as array
				for i in sel do 
				(
					select i
					AX.setoutputpath (ddl_path_list.items[1]+"\\")
					AX.exportmesh i.name --if is already on disc, will be owerwriten
				)
			)
		)
		createDialog ActorXMultiExportDialog style:#(#style_toolWindow, #style_sysMenu)
	)
	else
	(
		local delete_before_export = keyboard.controlPressed
		local mpath = maxFilePath
		fn deleteOthers i =
		(
			max modify mode
			local i_skin = i.modifiers[#Skin]
			local i_bones = for b=1 to skinOps.GetNumberBones i_skin collect (skinOps.GetBoneName i_skin b 0)
			local objects_for_export =  i_bones + #( i.name )
			local objects_for_delete = (for o in objects where findItem objects_for_export o.name == 0 collect o)
			undo "Delete_Others"  on delete objects_for_delete
		)
		fn collectSelectedSkinSets=
		(
			struct SKIN_DATA (oname, bnames=#())
			local sel_names=for o in selection collect o.name
			local skined_sets=#()
			max modify mode
			for n in sel_names do
			(
				local o = getNodeByName n
				select o
				local o_skin = o.modifiers[#Skin]
				if o_skin != undefined do
				(
					local o_bones = for b=1 to skinOps.GetNumberBones o_skin collect (skinOps.GetBoneName o_skin b 0)
					skined_sets += #(SKIN_DATA o.name o_bones )
				)
			)
			select (for n in sel_names where (local o = getNodeByName n) != undefined collect o)
			skined_sets
		)
		fn clearScene=(max unhide all; max select all; delete selection)--resetMaxFile #noPrompt)
		fn mergeBySet fpath s =
		(
			local names_array	=  (s.bnames+#(s.oname))
			try  
			(
				mergeMAXFile fpath names_array #useSceneMtlDups #deleteOldDups 
				select (getNodeByName s.oname)
			) 
			catch()
		)
		fn reloadMaxFile fpath=(loadMaxFile fpath)
		fn exportSelectionOneByOne=
		(
			local fpath =maxFilePath + maxFileName
			local skin_sets = collectSelectedSkinSets()
			if skin_sets.count == 0 do return false
			for s in skin_sets do
			(
				clearScene()
				mergeBySet fpath s
				completeredraw()
				sleep 1
				AX.exportmesh s.oname --will be owerwriten
				--format "% has ben exported to :%\n" s.oname fpath
			)
			reloadMaxFile fpath
		)
		/* debug
		sk=(collectSelectedSkinSets())[1]
na= (sk.bnames+#(sk.oname))
select(for i in na collect getnodebyname i)
		*/
		AX.setallskintype  1
		AX.setselectedgeometry 1
		AX.setbakesmoothing 1
		AX.setoutputpath maxFilePath
		local sel = selection as array
		if sel.count == 1 
		then
		(
			if delete_before_export do deleteOthers sel[1]
			AX.exportmesh sel[1].name --will be owerwriten
			messageBox ("( " + sel[1].name + " )  was exported to:\n\n"+maxFilePath) title:" ActorX Multiexporter:"
		)
		else if sel.count > 1 do
		if delete_before_export then exportSelectionOneByOne()
		else
		(
			for i in sel do 
			(
				select i
				AX.exportmesh i.name --will be owerwriten
			)
			messageBox ("\tExported:[" + sel.count as string + "] object(s) in to:\n\n"+maxFilePath) title:" ActorX Multiexporter:"
		)
	)
)

/*
fn getControlMeshIndex morph_obj ctrl_mesh =
(
	for i=0 to (MorphObj_GetNTargets morph_obj as Integer)-1 where 
	(
		MorphObj_GetTargetControlMesh morph_obj i == ctrl_mesh
	) do return i
	return undefined
)
fn getPointIndexByName morph_obj n=
(
	for i=0 to (MorphObj_GetNPoints morph_obj)-1 where MorphObj_GetPointName morph_obj i == n do return i; return undefined
)


p_top   =$point_top.pos
p_btm   =$point_bottom.pos
p_left  =$point_left.pos
p_right =$point_right.pos
p_back  =$point_back.pos
p_front =$point_front.pos

n_top = "tg_007"
ctrl_mesh = $_Sphere001_ControlMesh
morph_mesh = $MorphObj001

local_pos = p_top * (inverse morph_mesh.transform)
ctrl_mesh_index = getControlMeshIndex morph_mesh ctrl_mesh
point_index = (getPointIndexByName morph_mesh n_top)

MorphObj_SetPointPos morph_mesh ctrl_mesh_index point_index local_pos
*/



/*
No Info Found on: <Interface:AX>
  Interface: AX
   Properties:
   Methods:
    <integer>setoutputpath <string>newDestinationPathName
    <void>exportmesh <string>newMeshFilename
    <integer>exportanimset <string>newAnimFilename
    <integer>digestanim <string>inputSequenceName <integer>inStartFrame <integer>inEndFrame <float>optionalForcedRate
    <integer>setallskintype <integer>inSwitch
    <integer>setalltextured <integer>inSwitch
    <integer>settangentuvsplit <integer>inSwitch
    <integer>setbakesmoothing <integer>inSwitch
    <integer>setcullunuseddummies <integer>inSwitch
    <integer>setselectedgeometry <integer>inSwitch
   Actions:
*/