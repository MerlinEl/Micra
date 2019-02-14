---------------------
---------------------
--                 --
--    	 SMG	   --   
--                 --      Created by: Rene Baca & Vladimir Zadrazil / 2006
---------------------    //------------------------------------------------\\   
--------------------- 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o--
--o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--Dialog---------------------------------------------------------------------
if smgDialog != undefined do DestroyDialog smgDialog
-----------------------------------------------------------------------------
rollout smgDialog "Smoothing Groups & ID" width:144 height:240
(
	--Local--------------------------------------------------------------
	Local cStatus = true
	---------------------------------------------------------------------
	GroupBox grp1 "Material:" pos:[4,4] width:136 height:80
	label lblID "ID:" pos:[4,216] width:136 height:32
	button btnM1 "Select ID" pos:[12,40] width:52 height:16
	spinner spn1 "Set ID:" pos:[31,20] width:105 height:16 range:[1,500,0] type:#integer Indeterminate:true --setMaterialIndex
	spinner spn2 "" pos:[68,40] width:68 height:16 range:[1,500,0] type:#integer Indeterminate:true --set matID for select ID
	checkbox chk1 "Clear Selection" pos:[12,64] width:92 height:16 checked:true  --cStatus
	GroupBox grp2 "Smoothing Groups:" pos:[4,88] width:136 height:88
	spinner spn3 "" pos:[72,196] width:68 height:16 range:[0,180,45] scale:0.01 --set Autosmooth val
	button btnS2 "Select by SG" pos:[4,180] width:68 height:16
	button btnS3 "Clear All" pos:[72,180] width:68 height:16
	button btnS4 "Auto Smooth" pos:[4,196] width:68 height:16
	checkbutton ckb_1 "1" pos:[8,108] width:15 height:15
	checkbutton ckb_2 "2" pos:[24,108] width:15 height:15
	checkbutton ckb_3 "3" pos:[40,108] width:15 height:15
	checkbutton ckb_4 "4" pos:[56,108] width:15 height:15
	checkbutton ckb_5 "5" pos:[72,108] width:15 height:15
	checkbutton ckb_6 "6" pos:[88,108] width:15 height:15
	checkbutton ckb_7 "7" pos:[104,108] width:15 height:15
	checkbutton ckb_8 "8" pos:[120,108] width:15 height:15
	checkbutton ckb_9 "9" pos:[8,124] width:15 height:15
	checkbutton ckb_10 "10" pos:[24,124] width:15 height:15
	checkbutton ckb_11 "11" pos:[40,124] width:15 height:15
	checkbutton ckb_12 "12" pos:[56,124] width:15 height:15
	checkbutton ckb_13 "13" pos:[72,124] width:15 height:15
	checkbutton ckb_14 "14" pos:[88,124] width:15 height:15
	checkbutton ckb_15 "15" pos:[104,124] width:15 height:15
	checkbutton ckb_16 "16" pos:[120,124] width:15 height:15
	checkbutton ckb_17 "17" pos:[8,140] width:15 height:15
	checkbutton ckb_18 "18" pos:[24,140] width:15 height:15
	checkbutton ckb_19 "19" pos:[40,140] width:15 height:15
	checkbutton ckb_20 "20" pos:[56,140] width:15 height:15
	checkbutton ckb_21 "21" pos:[72,140] width:15 height:15
	checkbutton ckb_22 "22" pos:[88,140] width:15 height:15
	checkbutton ckb_23 "23" pos:[104,140] width:15 height:15
	checkbutton ckb_24 "24" pos:[120,140] width:15 height:15
	checkbutton ckb_25 "25" pos:[8,156] width:15 height:15
	checkbutton ckb_26 "26" pos:[24,156] width:15 height:15
	checkbutton ckb_27 "27" pos:[40,156] width:15 height:15
	checkbutton ckb_28 "28" pos:[56,156] width:15 height:15
	checkbutton ckb_29 "29" pos:[72,156] width:15 height:15
	checkbutton ckb_30 "30" pos:[88,156] width:15 height:15
	checkbutton ckb_31 "31" pos:[104,156] width:15 height:15
	checkbutton ckb_32 "32" pos:[120,156] width:15 height:15
	------------------------------------------------------------------
	/* Structure */
	------------------------------------------------------------------
	struct mcSMG
	(
		fn isEditPoly obj = (classOf obj == editable_poly),
		fn restoreButtons =
		(
			for i in 1 to 32 do 
			(
				local ckb = execute ("smgDialog.ckb_"+i as string)
				ckb.checked = false
				ckb.caption = i as string
			)
		),
		fn getFaceSmoothgroups obj face = 
		( 
			local smgroup_val = polyOp.getFaceSmoothGroup obj face 
			local smg_bitarray = #{} 
			if smgroup_val < 0 do 
			( 
				smg_bitarray[32]=true 
				smgroup_val -= 2^31 
			) 
			for i = 1 to 31 do 
			( 
				smg_bitarray[i]= (mod smgroup_val 2 > .5) 
				smgroup_val /= 2 
			) 
			smg_bitarray 
		), 
		fn updateInterface =
		(
			if not mcSMG.isEditPoly $ do return false 
			local fSel = (polyOp.getFaceSelection $) as array
			local facesIDs = #()
			local ckbNumstates = #()
			mcSMG.restoreButtons()
			
			if fSel.count == 0 do 
			(
				smgDialog.spn1.value = 0 ; smgDialog.spn1.Indeterminate = true 
				smgDialog.spn2.value = 0 ; smgDialog.spn2.Indeterminate = true
				return false
			)
			
			--Loop faces
			for f in fSel do
			(
				--Update Button states and text
				for i in 1 to 32 do
				(
					local ckb = execute ("smgDialog.ckb_"+i as string)
					
					if bit.get (polyOp.getFaceSmoothGroup $ f) i == true do
					(
						--format "ckbNumstates:%\n" ckbNumstates
						if ckbNumstates[i] == undefined then ckbNumstates[i] = 1 else ckbNumstates[i] += 1
					)
					if ckbNumstates[i] == fSel.count then (ckb.checked = on ; ckb.text = i as string)
					else
					if ckbNumstates[i] != undefined do (ckb.text = "")
				)
				--Get IDs from selected faces
				facesIDs += #(polyOp.getFaceMatID $ f)
		
			)
			
			--Assing result
			local facesID = (facesIDs as bitarray) as array
			smgDialog.lblID.text = ("ID:" + facesID as string)
			
			if facesID.count == 1 
			then (smgDialog.spn1.value = facesID[1] ; smgDialog.spn2.value = facesID[1])
			else
			(
				smgDialog.spn1.value = 0 ; smgDialog.spn1.Indeterminate = true 
				smgDialog.spn2.value = 0 ; smgDialog.spn2.Indeterminate = true
			)
		),
		fn setTo ckbNum bit =
		(
			setFocus smgDialog
			local ckb = execute ("smgDialog.ckb_"+ckbNum as string)
			if (polyOp.getFaceSelection $ as array).count == 0 do (ckb.checked = off ; return false)
			
			if ckb.checked
			then 
			(
				polyOp.setFaceSmoothGroup $ (polyOp.getFaceSelection $.baseobject as array) bit add:true
				ckb.caption = ckbNum as string
				--print ("Bit:"+ bit as string)
			)
			else 
			(
				local smgArray = #(1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,
				2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,-2147483648)
				
				local fSel = (polyOp.getFaceSelection $) as array
				for f in 1 to fSel.count do 
				(
					local fSmg = (polyOp.getFaceSmoothGroup $ fSel[f] - smgArray[ckbNum] as integer) 
					polyOp.setFaceSmoothGroup $ fSel[f] fSmg
					--print ("Bit: " + fSmg as string )
				)
			)
		),
		fn isInPolygonLevel = (if not (subobjectlevel == 4 or subobjectlevel == 5) do DestroyDialog smgDialog)
	)
	-----------------------------------------------------------------------------
	/* Dialog */
	-----------------------------------------------------------------------------
	on smgDialog rbuttonup pos do (DestroyDialog smgDialog)
	on smgDialog open  do
	(
		--DestroyDialog smgDialog if subobjectlevel 4 is false
		registerRedrawViewsCallback mcSMG.isInPolygonLevel		

		mcSMG.updateInterface()
		
		--ID update
		when select selection[1] changes id:#IDsmgSelection do (mcSMG.updateInterface())
		
	)
	on smgDialog close  do
	(
		unregisterRedrawViewsCallback mcSMG.isInPolygonLevel
		deleteAllChangeHandlers id:#IDsmgSelection
		--mcFile.saveDialogSettings "smgDialog" "Properties_2"
	)
	-----------------------------------------------------------------------------
	/* Actions */
	-----------------------------------------------------------------------------
	on chk1 changed state do (if chk1.checked then cStatus = true else cStatus = false)
	on spn1 changed val do
	(
		if is #fSel_2 then
			(
			$.setMaterialIndex val selection.count
			smgDialog.lblID.text = "ID:#{"+ (val as string)+"}"
			smgDialog.spn2.value = val
			)
		else (smgDialog.spn1.Indeterminate = true)
	)
	on spn3 changed val do ($.autoSmoothThreshold = val)
	on btnM1 pressed  do (if smgDialog.spn2.value > 0 do $.selectByMaterial smgDialog.spn2.value clearCurrentSelection:cStatus)
	on btnS2 pressed do ($.buttonOp #SelectBySmoothingGroups)
	on btnS3 pressed do 
	(
		if (polyOp.getFaceSelection $.baseobject).count > 0 do 
		polyOp.setFaceSmoothGroup $ (polyOp.getFaceSelection $.baseobject as array) 0 -- clear all smoothing groups
		mcSMG.restoreButtons()
	)
	on btnS4 pressed do
	(
		mcSMG.restoreButtons()
		$.buttonOp #Autosmooth
		mcSMG.updateInterface()
	)
	on ckb_1  changed state do mcSMG.setTo 1 1
	on ckb_2  changed state do mcSMG.setTo 2 2
	on ckb_3  changed state do mcSMG.setTo 3 4
	on ckb_4  changed state do mcSMG.setTo 4 8
	on ckb_5  changed state do mcSMG.setTo 5 16
	on ckb_6  changed state do mcSMG.setTo 6 32
	on ckb_7  changed state do mcSMG.setTo 7 64
	on ckb_8  changed state do mcSMG.setTo 8 128
	on ckb_9  changed state do mcSMG.setTo 9 256
	on ckb_10 changed state do mcSMG.setTo 10 512
	on ckb_11 changed state do mcSMG.setTo 11 1024
	on ckb_12 changed state do mcSMG.setTo 12 2048
	on ckb_13 changed state do mcSMG.setTo 13 4096
	on ckb_14 changed state do mcSMG.setTo 14 8192
	on ckb_15 changed state do mcSMG.setTo 15 16384
	on ckb_16 changed state do mcSMG.setTo 16 32768
	on ckb_17 changed state do mcSMG.setTo 17 65536
	on ckb_18 changed state do mcSMG.setTo 18 131072
	on ckb_19 changed state do mcSMG.setTo 19 262144
	on ckb_20 changed state do mcSMG.setTo 20 524288
	on ckb_21 changed state do mcSMG.setTo 21 1048576
	on ckb_22 changed state do mcSMG.setTo 22 2097152
	on ckb_23 changed state do mcSMG.setTo 23 4194304
	on ckb_24 changed state do mcSMG.setTo 24 8388608
	on ckb_25 changed state do mcSMG.setTo 25 16777216
	on ckb_26 changed state do mcSMG.setTo 26 33554432
	on ckb_27 changed state do mcSMG.setTo 27 67108864
	on ckb_28 changed state do mcSMG.setTo 28 134217728
	on ckb_29 changed state do mcSMG.setTo 29 268435456
	on ckb_30 changed state do mcSMG.setTo 30 536870912
	on ckb_31 changed state do mcSMG.setTo 31 1073741824
	on ckb_32 changed state do mcSMG.setTo 32 -2147483648
)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o--

createDialog smgDialog style:#(#style_titlebar)

--o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

/*
		when select selection[1] changes id:#IDsmgSelection do	
		(
			local fSel = mcGet #fSel
			--Get ID from selected faces for ID label
			if fSel.count > 0 then
			(
				local facesID = ((for f in fSel collect (polyOp.getFaceMatID $ f)) as bitarray) as array
				smgDialog.lblID.text = ("ID:" + facesID as string)
			)
			else (smgDialog.lblID.text = "ID:")
			--Get ID from selected faces for spinner1 & spinner2 & ID label
			if is #fSel_2 then
			( 
				local fID = polyOp.getFaceMatID $ (polyOp.getFaceSelection $.baseobject as array)[1]
				for f in fSel do 
				(
					if fID == (polyOp.getFaceMatID $ f) 
					then (smgDialog.spn1.value = fID ; smgDialog.spn2.value = fID)	
					else 
					(
						smgDialog.spn1.value = 0 ; smgDialog.spn1.Indeterminate = true 
						smgDialog.spn2.value = 0 ; smgDialog.spn2.Indeterminate = true
					)
					)
				)
			else
			(
				smgDialog.spn1.value = 0 ; smgDialog.spn1.Indeterminate = true 
				smgDialog.spn2.value = 0 ; smgDialog.spn2.Indeterminate = true
			)
			--Redraw smgButtons
			mcSMG.restoreButtons()
			mcSMG.updateInterface()
*/


/*
-----------------------------------------------------------------------------
polyOp.getFaceSelection $ as array
($.modifiers[#Edit_Poly].GetSelection #Face) as array
bit.get (polyOp.getFaceSmoothGroup $ f) i == true
polyOp.setFaceSmoothGroup $ (polyOp.getFaceSelection $.baseobject as array) bit add:true
polyOp.getFaceMatID $ (($.modifiers[#Edit_Poly].GetSelection #Face) as array)
(polyOp.setFaceSmoothGroup $ (polyOp.getFaceSelection $.baseobject as array) smgDialog add:true)
(polyOp.getFaceSmoothGroup $ 2)
-----------------------------------------------------------------------------
*/