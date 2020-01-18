(
	global testTabs 
	try(destroyDialog testTabs )catch()
	
	local LastSubRollout = 1
	
	rollout testTabsRollout01 "Rollout 01"
	(
		spinner spn_spinner "Spinner"
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
	
	rollout testTabs "Test Tabs"
	(
			dotNetControl dn_tabs "System.Windows.Forms.TabControl" height:20 width:420 align:#center
			subRollout theSubRollout width:420 height:140 align:#center
			
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
				for aTab in testTabs_Rollouts do
				(
					dn_tabs.TabPages.add aTab[1]
				)
				for subroll in testTabs_Rollouts[1][2] do 
					addSubRollout theSubRollout subroll				
			)
	)
	createDialog testTabs 440 200
)	