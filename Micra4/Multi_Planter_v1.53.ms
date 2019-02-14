Global mcDGalleryExtr
Global mcDgalleryDialog
Global mcMultiPlanterDialog
Global mcMultiPlanterEnabled
(
	-----------------------------------------------------------------
	local rootPath = getINISetting Micra.UserSettings "Gallery3D" "RootPath"
	local profilePath = Micra.RootDir + "User\\Gallery3D_Profiles.ini"
	-----------------------------------------------------------------
	
	rollout objectList "Object List" 
	(
		label lbl16 "Count:" pos:[236,8] width:44 height:12
		label lbl17 "Random Object List:" pos:[8,8] width:120 height:12
		button btn_add "Add" pos:[124,256] width:108 height:20
		button btn_remove "Remove" pos:[8,256] width:108 height:20
		listbox lbx_models "" pos:[8,24] width:224 height:17
		listbox lbx_count "" pos:[236,24] width:52 height:17
		spinner spn_count "" pos:[236,258] width:52 height:16 range:[0,100,0] type:#integer scale:1
		fn notDupplicated nameArr name = (for i in nameArr where name == i do return false ; return true )
		fn divideNums val: sel: =
		(
			--mabe other way
		)
		on lbx_models selected sel do (lbx_count.selection  = sel ; spn_count.value = lbx_count.selected as integer)
		on lbx_count  selected sel do (lbx_models.selection = sel ; spn_count.value = lbx_count.selected as integer)
		on btn_add pressed do
		(
			local ATD = mcDgalleryDialog.fun.selectedTags[1]
			if ATD == undefined do return false
			local pt = getFilenamePath ATD.bitmap.filename
			local na = getFilenameFile ATD.bitmap.filename
			local mf  = pt+na+".max"
			local pe  = "1"
			--add to listbox and object array
			if notDupplicated lbx_models.items p do 
			(
				mcDgalleryDialog.ObjectListArray.MaxFilePath += #(mf)
				mcDgalleryDialog.ObjectListArray.LocalDir    += #(pt)
				mcDgalleryDialog.ObjectListArray.Percentage  += #(pe)
				lbx_models.items = mcDgalleryDialog.ObjectListArray.LocalDir --make instance
				lbx_count.items  = mcDgalleryDialog.ObjectListArray.Percentage --make instance
			)
		)
		on btn_remove pressed do
		(
			local sel = lbx_models.selection
			if sel == 0 do return false
			deleteItem mcDgalleryDialog.ObjectListArray.MaxFilePath sel
			deleteItem mcDgalleryDialog.ObjectListArray.LocalDir    sel -- also delete an item from list because is a instance
			deleteItem mcDgalleryDialog.ObjectListArray.Percentage  sel -- also delete an item from list because is a instance
			--lists need to be refreshed now
			lbx_models.items = lbx_models.items 
			lbx_count.items  = lbx_count.items
			if lbx_models.items.count != 0 do lbx_models.selection = 1
			if lbx_count.items.count  != 0 do lbx_count.selection  = 1
		)
		on objectList close do 
		(
			setINISetting Micra.UserSettings "Gallery3D" "ObjectList_RolledUp" ((not ObjectList.open) as string)
		)
		on spn_count changed val do 
		(
			local sel = lbx_count.selection
			if sel != 0 do
			(
				mcDgalleryDialog.ObjectListArray.Percentage[sel] = val as string
				lbx_count.items[sel] = val as string
				lbx_count.items = lbx_count.items
			)
		)
	)
	
	rollout RandomSettings "Random Settings:" 
	(
		label lbl7 "X" pos:[84,8] width:8 height:12
		label lbl8 "Y" pos:[144,8] width:8 height:12
		label lbl9 "Z" pos:[204,8] width:8 height:12
		label lbl2 "Size:" pos:[8,28] width:44 height:12
		label lbl3 "Rotation:" pos:[8,48] width:44 height:16
		label lbl4 "Position:" pos:[8,68] width:44 height:16 
		spinner spn_siz_x "" pos:[64,28] width:52 height:16 range:[0,100,0] type:#integer scale:1
		spinner spn_siz_y "" pos:[124,28] width:52 height:16 range:[0,100,0] type:#integer scale:1
		spinner spn_siz_z "" pos:[184,28] width:52 height:16 range:[0,100,0] type:#integer scale:1
		spinner spn_rot_x "" pos:[64,48] width:52 height:16 range:[0,360,0] type:#integer scale:1
		spinner spn_rot_y "" pos:[124,48] width:52 height:16 range:[0,360,0] type:#integer scale:1
		spinner spn_rot_z "" pos:[184,48] width:52 height:16 range:[0,180,0] type:#integer scale:1
		spinner spn_pos_x "" pos:[64,68] width:52 height:16 range:[0,1000,0] type:#integer scale:1
		spinner spn_pos_y "" pos:[124,68] width:52 height:16 range:[0,1000,0] type:#integer scale:1
		spinner spn_pos_z "" pos:[184,68] width:52 height:16 range:[0,1000,0] type:#integer scale:1
		checkbox chk_lock_siz "Lock" pos:[240,28] width:44 height:16 checked:false
		checkbox chk_lock_rot "Lock" pos:[240,48] width:44 height:16 checked:false
		checkbox chk_lock_pos "Lock" pos:[240,68] width:44 height:16 checked:false
		fn collectIndividualParams spn val type =
		(
			local dia = mcDgalleryDialog
			case type of
			(
				#siz: 
				(
					if chk_lock_siz.checked do (spn_siz_x.value = val ; spn_siz_y.value = val ; spn_siz_z.value = val)
					dia.lockSiz = chk_lock_siz.checked
					dia.singleSize = [spn_siz_x.value, spn_siz_y.value, spn_siz_z.value]
				)
				#rot: 
				(
					if chk_lock_rot.checked do (spn_rot_x.value = val ; spn_rot_y.value = val ; spn_rot_z.value = val)
					dia.lockRot = chk_lock_rot.checked
					dia.singleRotation = [spn_rot_x.value, spn_rot_y.value, spn_rot_z.value] 
				)
				#pos: 
				(
					if chk_lock_pos.checked do (spn_pos_x.value = val ; spn_pos_y.value = val ; spn_pos_z.value = val)
					dia.lockPos = chk_lock_pos.checked
					dia.singlePosition = [spn_pos_x.value, spn_pos_y.value, spn_pos_z.value]
				)
			)
		)
		on spn_siz_x changed val    do collectIndividualParams spn_siz_x val #siz
		on spn_siz_y changed val    do collectIndividualParams spn_siz_y val #siz
		on spn_siz_z changed val    do collectIndividualParams spn_siz_z val #siz
		
		on spn_rot_x changed val    do collectIndividualParams spn_rot_x val #rot
		on spn_rot_y changed val    do collectIndividualParams spn_rot_y val #rot
		on spn_rot_z changed val    do collectIndividualParams spn_rot_z val #rot
		
		on spn_pos_x changed val    do collectIndividualParams spn_pos_x val #pos
		on spn_pos_y changed val    do collectIndividualParams spn_pos_y val #pos
		on spn_pos_z changed val    do collectIndividualParams spn_pos_z val #pos
		
		on chk_lock_siz changed state do
		(
			local val = spn_siz_x.value
			if state do (spn_siz_x.value = val ; spn_siz_y.value = val ; spn_siz_z.value = val)
		)	
		on chk_lock_rot changed state do
		(
			local val = spn_rot_x.value
			if state do (spn_rot_x.value = val ; spn_rot_y.value = val ; spn_rot_z.value = val)
		)	
		on chk_lock_pos changed state do
		(
			local val = spn_pos_x.value
			if state do (spn_pos_x.value = val ; spn_pos_y.value = val ; spn_pos_z.value = val)
		)
		on RandomSettings close do 
		(
			setINISetting Micra.UserSettings "Gallery3D" "RandomSettings_RolledUp" ((not RandomSettings.open) as string)
		)
	)
	
	rollout GlobalSettings "Global Setings"
	(
		label lbl1 "Orientation:" pos:[8,8] width:72 height:16
		label lbl5 "Distance:" pos:[8,28] width:48 height:16
		label lbl_units_1 "units" pos:[116,48] width:28 height:16
		label lbl_units_2 "units" pos:[116,28] width:28 height:16
		label lbl78 "Manual Spin:" pos:[8,68] width:64 height:16
		label lbl79 "Sensitivity:" pos:[176,68] width:52 height:16
		label lbl119 "Implant:" pos:[8,48] width:48 height:16
		radiobuttons rdo_ori "" pos:[80,8] width:185 height:16 labels:#("Local", "Parent", "World") default:1 columns:3
		radiobuttons rdo_spin "" pos:[76,68] width:97 height:16 labels:#("X", "Y", "Z") default:1 columns:3
		spinner spn_dist "" pos:[60,28] width:52 height:16 range:[0,1000,0] type:#integer scale:1
		spinner spn_sens "" pos:[228,68] width:52 height:16 range:[0,50,0] type:#float scale:0.1
		spinner spn_offset "" pos:[60,48] width:52 height:16 range:[-5000,5000,0] type:#float scale:0.1
		checkbox chk_pres_over "Preserve Overlaps" pos:[136,28] width:108 height:16
		on GlobalSettings close do 
		(
			setINISetting Micra.UserSettings "Gallery3D" "GlobalSettings_RolledUp" ((not GlobalSettings.open) as string)
		)
		on spn_dist   changed val      do mcDgalleryDialog.spnDist          = val
		on spn_sens   changed val      do mcDgalleryDialog.spnSens          = val
	    on rdo_spin   changed state    do mcDgalleryDialog.maualSpinAxis    = state
		on rdo_ori    changed state    do mcDgalleryDialog.plantOrientation = state
		on spn_offset changed val      do mcDgalleryDialog.plantSnapOffset  = val
		on chk_pres_over changed state do mcDgalleryDialog.PreserveOverlaps = state
	)
	
	rollout ProfileSettings "Profiles"
	(
		dropdownList ddl_profile "" pos:[8,32] width:204 height:21
		edittext edt_profile "" pos:[4,8] width:208 height:20
		button btn_save_add_profile "Save" pos:[216,8] width:68 height:20
		button btn_del_profile "Delete" pos:[216,32] width:68 height:20
		-->structure
		struct thumbnail (MaxFilePath, LocalDir, Percentage)
		-->functions
		fn enabled = (mcDgalleryDialog != undefined and mcDgalleryDialog.isDisplayed)
		---check
		fn saveProfile iniFile  head:edt_profile.text = 
		(
			setINISetting iniFile head "Plant_Distance"    (GlobalSettings.spn_dist.value   as string)
			setINISetting iniFile head "Plant_Sensitivity" (GlobalSettings.spn_sens.value   as string)
			setIniSetting iniFile head "Maual_Spin_Axis"   (GlobalSettings.rdo_spin.state   as string)
			setIniSetting iniFile head "Plant_Orientation" (GlobalSettings.rdo_ori.state    as string)
			setIniSetting iniFile head "Plant_Snap_Offset" (GlobalSettings.spn_offset.value as string)
			setIniSetting iniFile head "Preserve_Overlaps" (GlobalSettings.chk_pres_over.checked as string)
			setIniSetting iniFile head "Lock_Size"         (RandomSettings.chk_lock_siz.checked as string)
			setIniSetting iniFile head "Lock_Rotation"     (RandomSettings.chk_lock_rot.checked as string)
			setIniSetting iniFile head "Lock_Position"     (RandomSettings.chk_lock_pos.checked as string)
			
			local s = [RandomSettings.spn_siz_x.value, RandomSettings.spn_siz_y.value, RandomSettings.spn_siz_z.value] as string
			setIniSetting iniFile head "Single_Size"     s
			local r = [RandomSettings.spn_rot_x.value, RandomSettings.spn_rot_y.value, RandomSettings.spn_rot_z.value] as string
			setIniSetting iniFile head "Single_Rotation" r
			local p = [RandomSettings.spn_pos_x.value, RandomSettings.spn_pos_y.value, RandomSettings.spn_pos_z.value] as string
			setIniSetting iniFile head "Single_Position" p
			
			setIniSetting Micra.UserSettings   "Gallery3D" "Last_Profile" (ddl_profile.selection as string)
			if head != "Gallery3DDefault" do
			(
				setIniSetting iniFile head "MaxFilePath" (mcDgalleryDialog.ObjectListArray.MaxFilePath as string)
				setIniSetting iniFile head "LocalDir"    (mcDgalleryDialog.ObjectListArray.LocalDir    as string)
				setIniSetting iniFile head "Percentage"  (mcDgalleryDialog.ObjectListArray.Percentage  as string)
			)
		)
		fn saveAddProfile =
		(
			if not doesFileExist profilePath do try (close (createFile profilePath)) catch ( return false)
			local lbl = edt_profile.text
			local itm = ddl_profile.selected
			format "lbl:%\titm:%\n" lbl itm
			if lbl != ""
			then
			(
				if objectList.notDupplicated ddl_profile.items lbl then --add new profile
				(
					saveProfile profilePath head:lbl
					ddl_profile.items += #(lbl)
					ddl_profile.selection = findItem ddl_profile.items lbl
				)
				else if querybox ( "Owerwrite ["+lbl+"] profile?") title:" Do you wish?" do --owerwrite
				(
					if lbl == "Default" 
					then saveProfile Micra.UserSettings head:"Gallery3DDefault"
					else saveProfile profilePath head:lbl
					ddl_profile.selection = findItem ddl_profile.items lbl
				)
			)
			else if querybox ( "Owerwrite ["+itm+"] profile?") title:" Do you wish?" do --owerwrite
			(
				if itm == "Default" 
				then saveProfile Micra.UserSettings head:"Gallery3DDefault"
				else saveProfile profilePath head:itm
				ddl_profile.selection = findItem ddl_profile.items itm
			)
		)
		---check
		fn loadProfile iniFile head:ddl_profile.selected =
		(
			if head == undefined do return false
			if not doesFileExist iniFile do return false
			--setup spinners  for mcMultiPlanterDialog
			GlobalSettings.spn_dist.value       = execute (getIniSetting iniFile head "Plant_Distance"   )
			GlobalSettings.spn_sens.value       = execute (getIniSetting iniFile head "Plant_Sensitivity")
			GlobalSettings.rdo_spin.state       = execute (getIniSetting iniFile head "Maual_Spin_Axis"  )
			GlobalSettings.rdo_ori.state        = execute (getIniSetting iniFile head "Plant_Orientation")	
			GlobalSettings.spn_offset.value     = execute (getIniSetting iniFile head "Plant_Snap_Offset")
			GlobalSettings.chk_pres_over.checked= execute (getIniSetting iniFile head "Preserve_Overlaps")
			RandomSettings.chk_lock_siz.checked = execute (getIniSetting iniFile head "Lock_Size"        )
			RandomSettings.chk_lock_rot.checked = execute (getIniSetting iniFile head "Lock_Rotation"    )
			RandomSettings.chk_lock_pos.checked = execute (getIniSetting iniFile head "Lock_Position"    )
			
			local s = execute (getIniSetting iniFile head "Single_Size")
			RandomSettings.spn_siz_x.value = s.x
			RandomSettings.spn_siz_y.value = s.y
			RandomSettings.spn_siz_z.value = s.z
			local r = execute (getIniSetting iniFile head "Single_Rotation")
			RandomSettings.spn_rot_x.value = r.x
			RandomSettings.spn_rot_y.value = r.y
			RandomSettings.spn_rot_z.value = r.z
			local p = execute (getIniSetting iniFile head "Single_Position") 
			RandomSettings.spn_pos_x.value = p.x
			RandomSettings.spn_pos_y.value = p.y
			RandomSettings.spn_pos_z.value = p.z
			--setup variables for mcDgalleryDialog
			mcDgalleryDialog.spnDist          = GlobalSettings.spn_dist.value
			mcDgalleryDialog.spnSens          = GlobalSettings.spn_sens.value
		    mcDgalleryDialog.maualSpinAxis    = GlobalSettings.rdo_spin.state
			mcDgalleryDialog.plantOrientation = GlobalSettings.rdo_ori.state
			mcDgalleryDialog.plantSnapOffset  = GlobalSettings.spn_offset.value
			mcDgalleryDialog.lockSiz = RandomSettings.chk_lock_siz.checked
			mcDgalleryDialog.lockRot = RandomSettings.chk_lock_rot.checked
			mcDgalleryDialog.lockPos = RandomSettings.chk_lock_pos.checked
			
			mcDgalleryDialog.singleSize = [RandomSettings.spn_siz_x.value, RandomSettings.spn_siz_y.value, RandomSettings.spn_siz_z.value]
			mcDgalleryDialog.singleRotation = [RandomSettings.spn_rot_x.value, RandomSettings.spn_rot_y.value, RandomSettings.spn_rot_z.value] 
			mcDgalleryDialog.singlePosition = [RandomSettings.spn_pos_x.value, RandomSettings.spn_pos_y.value, RandomSettings.spn_pos_z.value]
			
			mcDgalleryDialog.ObjectListArray  = thumbnail #() #() #()
			mcDgalleryDialog.PreserveOverlaps = GlobalSettings.chk_pres_over.checked
			
			if head != "Gallery3DDefault" 
			then
			(
				local mf = execute (getIniSetting iniFile head "MaxFilePath")
				local ld = execute (getIniSetting iniFile head "LocalDir"   )
				local pt = execute (getIniSetting iniFile head "Percentage" )
				
				if classOf mf != array or mf.count == 0 
				then
				(
					objectList.lbx_models.items = #()
					objectList.lbx_count.items  = #()
				)
				else
				(

					objectList.lbx_models.items = ld  --make instance
					objectList.lbx_count.items  = pt  --make instance
				
					mcDgalleryDialog.ObjectListArray.MaxFilePath = mf
					mcDgalleryDialog.ObjectListArray.LocalDir    = ld  --make instance
					mcDgalleryDialog.ObjectListArray.Percentage  = pt  --make instance
				)
				--format "mcDgalleryDialog.ObjectListArray:%\n" mcDgalleryDialog.ObjectListArray
			)
			else 
			(
				objectList.lbx_models.items = #()
				objectList.lbx_count.items  = #() 
			)
			--refill multipack
			if mcMultiPlanterEnabled == true do mcDgalleryDialog.InterfaceStruct.createMultipack()
		)
		fn delProfile =
		(
			local itm = ddl_profile.selected
			if itm == undefined or itm == "Default"  do return false
			if not doesFileExist profilePath do return false
			if querybox ( " Delete ["+itm+"] profile?") title:" You are sure?" do
			(
				delIniSetting profilePath itm
				ddl_profile.items = deleteItem ddl_profile.items ddl_profile.selection
				if ddl_profile.items.count > 0 
				then (ddl_profile.selection = 1; edt_profile.text = ddl_profile.items[1])
				else (edt_profile.text = "")
				loadProfile Micra.UserSettings head:"Gallery3DDefault"
			)
		)
		fn getProfileList =
		(
			if doesFileExist profilePath 
			then
			(
				local profiles = getIniSetting profilePath
				ddl_profile.items = #( "Default") + profiles
				ddl_profile.selection = 1
				loadProfile Micra.UserSettings head:"Gallery3DDefault"
			)
		)
		-->dialog
		on ProfileSettings open do
		(
			GlobalSettings.lbl_units_1.text = mcSystem.units_type()
			GlobalSettings.lbl_units_2.text = mcSystem.units_type()
			mcDgalleryDialog.ObjectListArray = thumbnail #() #() #()
			getProfileList()
		)
		on ProfileSettings close do 
		(
			setIniSetting Micra.UserSettings "Gallery3D" "Dialog_Plant_Pos"         (mcMultiPlanterDialog.pos as string )
			setIniSetting Micra.UserSettings "Gallery3D" "Dialog_Plant_Size"        (mcMultiPlanterDialog.size as string)
			setINISetting Micra.UserSettings "Gallery3D" "ProfileSettings_RolledUp" ((not ProfileSettings.open) as string)
			if mcDgalleryDialog != undefined do mcDgalleryDialog.ckb_plant_dialog.checked = false
		)
		on btn_save_add_profile pressed do saveAddProfile()	
		on btn_del_profile pressed do delProfile()
		on ddl_profile selected sel do
		(
			local itm = ddl_profile.selected
			edt_profile.text = itm
			if itm == "Default" 
			then loadProfile Micra.UserSettings head:"Gallery3DDefault"
			else loadProfile profilePath head:itm	
			setFocus edt_profile
		)
	)
	--Multi Planter
	local DPos  = execute(getINISetting Micra.UserSettings "Gallery3D" "Dialog_Plant_Pos"       )
	local DSize = execute(getIniSetting Micra.UserSettings "Gallery3D" "Dialog_Plant_Size"      )
	local OL    = execute(getINISetting Micra.UserSettings "Gallery3D" "ObjectList_RolledUp"     )
	local RS    = execute(getINISetting Micra.UserSettings "Gallery3D" "RandomSettings_RolledUp" )
	local GS    = execute(getINISetting Micra.UserSettings "Gallery3D" "GlobalSettings_RolledUp" )
	local PS    = execute(getINISetting Micra.UserSettings "Gallery3D" "ProfileSettings_RolledUp")
	if mcMultiPlanterDialog != undefined do closeRolloutFloater mcMultiPlanterDialog
	mcMultiPlanterDialog = newRolloutFloater " Multi Planter:" DSize.x DSize.y DPos.x DPos.y
	addRollout ObjectList      mcMultiPlanterDialog rolledUp:OL
	addRollout RandomSettings  mcMultiPlanterDialog rolledUp:RS
	addRollout GlobalSettings  mcMultiPlanterDialog rolledUp:GS
	addRollout ProfileSettings mcMultiPlanterDialog rolledUp:PS
)
