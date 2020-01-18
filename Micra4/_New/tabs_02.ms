(
	global testTabs 
	try(destroyDialog testTabs )catch()
	
	local LastSubRollout = 1
	
	rollout testTabsRollout01 "" width:188 height:88
	(
		button btn_verts "V" pos:[8,16] width:24 height:24 toolTip:"Convert Selection to Vertices"
		button btn_edges "E" pos:[36,16] width:24 height:24 toolTip:"Convert Selection to Edges"
		button btn_faces "F" pos:[64,16] width:24 height:24 itooltip:"Convert Selection to Faces"
		button btn_border "B" pos:[100,16] width:24 height:24 toolTip:"Select Edge border"
		button btn_sel_similar "B" pos:[156,16] width:24 height:24 toolTip:"Select Similar Faces"
		label lbl_min "min:" pos:[100,44] width:24 height:16
		spinner spn_min "" pos:[124,44] width:44 height:16 range:[0,100,100] type:#float
		label lbl_max "max:" pos:[100,64] width:24 height:16
		spinner spn_max "" pos:[124,64] width:44 height:16 range:[0,10000,20] type:#float
		label lbl6 "%" pos:[168,64] width:12 height:16
		label lbl7 "%" pos:[168,44] width:12 height:16
		button btn_sel_over "B" pos:[128,16] width:24 height:24 toolTip:"Select Overlapped Faces (+Ctrl Grow to Element)"
		GroupBox grp5 "Convert" pos:[4,0] width:88 height:44
		GroupBox grp6 "Select" pos:[96,0] width:88 height:84
	)
	rollout testTabsRollout02 "Rollout 02"
	(
		button btn_button "Button"
	)
	rollout testTabsRollout03 "Rollout 03"
	(
		label lbl_label "This is some text"
	)
	rollout testTabsRollout04 "Rollout 04"
	(
		colorpicker clr_picker "Color Picker"
	)
	rollout testTabsRollout05 "Rollout 05"
	(
		checkbox chk_box "Checkbox"
	)
	
	testTabs_Rollouts = #(
		#("Select",#(testTabsRollout01)),
		#("Move",#(testTabsRollout02)),
		#("Transform",#(testTabsRollout03)),
		#("Weld",#(testTabsRollout04,testTabsRollout05))
	)	
	
	rollout testTabs "UVW +" (
			dotNetControl dn_tabs "System.Windows.Forms.TabControl" height:20 width:200 align:#center
			subRollout theSubRollout width:202 height:140 align:#center
			
			on dn_tabs Selected itm do
			(
				if LastSubRollout != (itm.TabPageIndex+1) do --do not update if the same tab clicked twice
				(
					for subroll in testTabs_Rollouts[LastSubRollout][2] do
						removeSubRollout theSubRollout subroll
					for subroll in testTabs_Rollouts[LastSubRollout = itm.TabPageIndex+1][2] do	
						addSubRollout theSubRollout subroll
				) 
			)--end tabs clicked		
			
			on testTabs open do
			(
				for aTab in testTabs_Rollouts do dn_tabs.TabPages.add aTab[1]
				for subroll in testTabs_Rollouts[1][2] do addSubRollout theSubRollout subroll				
			)
	)
	createDialog testTabs 202 150
)	

-- 		groupBox grp2 "GroupBox" width:45 height:89
-- 	group "Conversion" (
-- 	button btn_1 "a"  across:4 width:24 align:#left tooltip:"Convert Selection To Vertices"
-- 	button btn_2 "b"  offset:[-34,0] width:24 tooltip:"Convert Selection To Edges"
-- 	button btn_3 "v"  offset:[-56,0] width:24 border:true tooltip:"Convert Selection To Faces" --aa
-- 	)