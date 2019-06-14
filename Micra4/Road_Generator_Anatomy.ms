Global roadAnatomyToolDialog
Global roadAnatomyToolSubDialogA
Global roadAnatomyToolSubDialogB
Global roadAnatomyToolSubDialogA_Height = 354
Global roadAnatomyToolSubDialogB_Height = 536
if classOf ::roadAnatomyToolDialog == RolloutClass do DestroyDialog ::roadAnatomyToolDialog
rollout roadAnatomyToolSubDialogA "Road" 
(
	GroupBox 'grp1' "" pos:[52,28] width:236 height:56 align:#left 
	GroupBox 'grp2' "" pos:[12,56] width:312 height:2 align:#left 
	GroupBox 'grp9' "Road:" pos:[4,8] width:328 height:236 align:#left 
	label 'lbl1' "D1" pos:[16,32] width:16 height:16 align:#left 
	label 'lbl2' "D2" pos:[304,32] width:16 height:16 align:#left 
	label 'lbl3' "P1" pos:[120,36] width:16 height:16 align:#left 
	label 'lbl4' "P2" pos:[212,36] width:16 height:16 align:#left 
	label 'lbl5' "S1" pos:[168,66] width:16 height:16 align:#left 
	label 'lbl_d1' "" pos:[48,128] width:240 height:16 align:#left 
	label 'lbl_d2' "" pos:[48,180] width:240 height:16 align:#left 
	label 'lbl_p1' "" pos:[80,152] width:204 height:16 align:#left 
	label 'lbl_p2' "" pos:[80,208] width:208 height:16 align:#left 
	label 'lbl_s1' "" pos:[48,100] width:240 height:16 align:#left 
	button 'btn_d1' "D1" pos:[8,124] width:36 height:24 toolTip:"Start Point" align:#left 
	button 'btn_d2' "D2" pos:[8,176] width:36 height:24 toolTip:"End Point" align:#left 
	button 'btn_p1' "P1" pos:[40,148] width:36 height:24 toolTip:"Tangent Start" align:#left 
	button 'btn_p2' "P2" pos:[40,204] width:36 height:24 toolTip:"Tangent End" align:#left 
	button 'btn_s1' "S1" pos:[8,92] width:36 height:24 toolTip:"Path Spline" align:#left 
	pickbutton 'pbtn_d1' "pick" pos:[292,122] width:36 height:24 align:#left 
	pickbutton 'pbtn_d2' "pick" pos:[292,174] width:36 height:24 align:#left 
	pickbutton 'pbtn_p1' "pick" pos:[292,148] width:36 height:24 align:#left 
	pickbutton 'pbtn_p2' "pick" pos:[292,200] width:36 height:24 align:#left 
	pickbutton 'pbtn_s1' "pick" pos:[292,96] width:36 height:24 align:#left 
 	GroupBox 'grp4' "Advanced:" pos:[4,248] width:328 height:80 align:#left
-- 	button 'btn_revert_to_shortcut' "Rebuild Shortcut" pos:[12,268] width:100 height:24 toolTip:"Select Spline to Rebuild Shortcut" align:#left
-- 	button 'btn_unique_name' "Unique Name" pos:[12,295] width:100 height:24 toolTip:"Set Object Unique Name" align:#left
	--Road Controlls
	on pbtn_d1 picked obj do (roadAnatomyToolDialog.addRoadComponent obj #d1)
	on pbtn_d2 picked obj do (roadAnatomyToolDialog.addRoadComponent obj #d2)
	on pbtn_p1 picked obj do (roadAnatomyToolDialog.addRoadComponent obj #p1)
	on pbtn_p2 picked obj do (roadAnatomyToolDialog.addRoadComponent obj #p2)
	on pbtn_s1 picked obj do (roadAnatomyToolDialog.addRoadComponent obj #s1)
		
	on btn_d1 pressed  do (roadAnatomyToolDialog.selRoadComponent #d1)
	on btn_d2 pressed  do (roadAnatomyToolDialog.selRoadComponent #d2)
	on btn_p1 pressed  do (roadAnatomyToolDialog.selRoadComponent #p1)
	on btn_p2 pressed  do (roadAnatomyToolDialog.selRoadComponent #p2)
	on btn_s1 pressed  do (roadAnatomyToolDialog.selRoadComponent #s1)
	
-- 	on btn_revert_to_shortcut pressed do (roGenStruct.rebuildBrokenShortcut selection[1])
-- 	on btn_unique_name pressed do (roGenStruct.fixDuplicitNames ())
)
 
rollout roadAnatomyToolSubDialogB "CrossRoad"
(
	GroupBox grp8 "Cross Road:" pos:[4,4] width:328 height:496 
	GroupBox grp7 "" pos:[137,76] width:56 height:130 
	GroupBox grp6 "" pos:[100,113] width:130 height:56 
	label lbl21 "D1" pos:[76,136] width:16 height:16 
	label lbl22 "D2" pos:[160,52] width:16 height:16 
	label lbl25 "D3" pos:[240,136] width:16 height:16 
	label lbl26 "D4" pos:[156,216] width:16 height:16 
	label lbl23 "P1" pos:[48,136] width:16 height:16 
	label lbl24 "P2" pos:[160,24] width:16 height:16 
	label lbl27 "P3" pos:[264,136] width:16 height:16 
	label lbl28 "P4" pos:[156,244] width:16 height:16 
	label lbl_cr_d1 "" pos:[48,266] width:240 height:16
	label lbl_cr_p1 "" pos:[80,290] width:204 height:16
	label lbl_cr_d2 "" pos:[48,326] width:240 height:16
	label lbl_cr_p2 "" pos:[80,350] width:204 height:16
	label lbl_cr_d3 "" pos:[48,386] width:240 height:16
	label lbl_cr_p3 "" pos:[80,410] width:204 height:16
	label lbl_cr_d4 "" pos:[48,446] width:240 height:16
	label lbl_cr_p4 "" pos:[80,470] width:204 height:16
	button btn_cr_d1 "D1" pos:[8,262] width:36 height:24 toolTip:"Start Point"
	button btn_cr_d2 "D2" pos:[8,322] width:36 height:24 toolTip:"Start Point"
	button btn_cr_d3 "D3" pos:[8,382] width:36 height:24 toolTip:"Start Point"
	button btn_cr_d4 "D4" pos:[8,442] width:36 height:24 toolTip:"Start Point"
	button btn_cr_p1 "P1" pos:[40,286] width:36 height:24 toolTip:"Tangent Start"
	button btn_cr_p2 "P2" pos:[40,346] width:36 height:24 toolTip:"Tangent Start"
	button btn_cr_p3 "P3" pos:[40,406] width:36 height:24 toolTip:"Tangent Start"
	button btn_cr_p4 "P4" pos:[40,466] width:36 height:24 toolTip:"Tangent Start"
	button btn_cr_reset "reset" pos:[284,24] width:40 height:16 toolTip:" Clear road.CrossRoadKids.kids"
	pickbutton pbtn_cr_d1 "pick" pos:[292,260] width:36 height:24
	pickbutton pbtn_cr_d2 "pick" pos:[292,320] width:36 height:24
	pickbutton pbtn_cr_d3 "pick" pos:[292,380] width:36 height:24	
	pickbutton pbtn_cr_d4 "pick" pos:[292,440] width:36 height:24	
	pickbutton pbtn_cr_p1 "pick" pos:[292,286] width:36 height:24
	pickbutton pbtn_cr_p2 "pick" pos:[292,346] width:36 height:24
	pickbutton pbtn_cr_p3 "pick" pos:[292,406] width:36 height:24
	pickbutton pbtn_cr_p4 "pick" pos:[292,466] width:36 height:24	
	--Crossroad Controls
	on pbtn_cr_d1 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #d1)
	on pbtn_cr_d2 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #d2)
	on pbtn_cr_d3 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #d3)
	on pbtn_cr_d4 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #d4)
	on pbtn_cr_p1 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #p1)
	on pbtn_cr_p2 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #p2)
	on pbtn_cr_p3 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #p3)
	on pbtn_cr_p4 picked obj do (roadAnatomyToolDialog.addCrossRoadComponent obj #p4)
	
	on btn_cr_d1 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #d1)
	on btn_cr_d2 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #d2)
	on btn_cr_d3 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #d3)
	on btn_cr_d4 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #d4)
	on btn_cr_p1 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #p1)
	on btn_cr_p2 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #p2)
	on btn_cr_p3 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #p3)
	on btn_cr_p4 pressed  do (roadAnatomyToolDialog.selCrossRoadComponent #p4)
	on btn_cr_reset pressed do (rroadAnatomyToolDialog.resetCrossRoad())
)
 
rollout roadAnatomyToolDialog "Road Anatomy:" width:352 height:(amax #(roadAnatomyToolSubDialogA_Height, roadAnatomyToolSubDialogB_Height))
(
	subRollout roSubA "" width:346 height:roadAnatomyToolSubDialogA_Height pos:[4,4]
	subRollout roSubB "" width:346 height:536 visible:false pos:[4,4]
 	local active_road
	local handler 
	--Road Functions
	fn addRoadComponent obj type = (
		
		local ro = roadAnatomyToolSubDialogA
		if not (roGenStruct.isRoad active_road) do (
			
			messageBox "Select Road first." title:"Road Generator"
			return false
		)
		case type of (
			
			#d1:	(
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				active_road.startPoint = obj
				ro.lbl_d1.text = obj.name
				if active_road.startPoint.children[1] != undefined do ro.lbl_p1.text =  active_road.startPoint.children[1].name
			)
			#d2: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				active_road.endPoint = obj
				ro.lbl_d2.text = obj.name
				if active_road.endPoint.children[1] != undefined do ro.lbl_p2.text =  active_road.endPoint.children[1].name
			)
			#p1: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				if active_road.startPoint == undefined do (
					
					messageBox "Invalid operation. Define D1 first."
					return false
				)
				obj.parent = active_road.startPoint 
				ro.lbl_p1.text =  obj.name
			)
			#p2: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				if active_road.endPoint == undefined do (
					
					messageBox "Invalid operation. Define D1 first."
					return false
				)
				obj.parent = active_road.endPoint 
				ro.lbl_p2.text = obj.name
			)
			#s1: (
				
				if classOf obj != SplineShape do (
					
					messageBox "Invalid operation. Target must be Shape."
					return false
				)
				obj.road = active_road.name
				active_road.roadSpline = obj
				ro.lbl_s1.text = obj.name
			)
		)
	)
	
	fn selRoadComponent type = (
			
		local ro = roadAnatomyToolSubDialogA
		local obj = case type of (
			
			#d1: getNodeByName ro.lbl_d1.text 
			#d2: getNodeByName ro.lbl_d2.text 
			#p1: getNodeByName ro.lbl_p1.text 
			#p2: getNodeByName ro.lbl_p2.text 
			#s1: getNodeByName ro.lbl_s1.text 
		)
		if isValidNode obj do select obj
	)
	
	fn clearRoadFields = ( 
		
		local ro = roadAnatomyToolSubDialogA
		ro.lbl_s1.text =  "undefined"
		ro.lbl_d1.text = "undefined"
		ro.lbl_d2.text = "undefined"
		ro.lbl_p1.text = "undefined"
		ro.lbl_p2.text = "undefined"
	)
	
	--CrossRoad Functions
	fn addCrossRoadComponent  obj type = (
		
		local ro = roadAnatomyToolSubDialogB
		if not (roGenStruct.isCrossRoad active_road) do (
			
			messageBox "Select Crossroad first." title:"Road Generator"
			return false
		)
		case type of (
			
			#d1:	(
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				obj.parent = active_road
				active_road.CrossRoadKids.kids[1] = obj
				ro.lbl_cr_d1.text = obj.name
				if obj.children[1] != undefined do (
					
					ro.lbl_cr_p1.text =  obj.children[1].name
					active_road.CrossRoadKids.kids[5] = obj.children[1]
				)
			)
			#d2: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				obj.parent = active_road
				active_road.CrossRoadKids.kids[2] = obj
				ro.lbl_cr_d2.text = obj.name
				if obj.children[1] != undefined do (
					
					ro.lbl_cr_p2.text =  obj.children[1].name
					active_road.CrossRoadKids.kids[6] = obj.children[1]
				)
			)
			#d3: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				obj.parent = active_road
				active_road.CrossRoadKids.kids[3] = obj
				ro.lbl_cr_d3.text = obj.name
				if obj.children[1] != undefined do (
					
					ro.lbl_cr_p3.text =  obj.children[1].name
					active_road.CrossRoadKids.kids[7] = obj.children[1]
				)
			)
			#d4: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				obj.parent = active_road
				active_road.CrossRoadKids.kids[4] = obj
				ro.lbl_cr_d4.text = obj.name
				if obj.children[1] != undefined do (
					
					ro.lbl_cr_p4.text =  obj.children[1].name
					active_road.CrossRoadKids.kids[8] = obj.children[1]
				)
			)
			#p1: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				if active_road.CrossRoadKids.kids[1] == undefined do (
					
					messageBox "Invalid operation. Define D1 first."
					return false
				)
				obj.parent = active_road.CrossRoadKids.kids[1]
				active_road.CrossRoadKids.kids[5] = obj
				ro.lbl_cr_p1.text =  obj.name
			)
			#p2: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				if active_road.CrossRoadKids.kids[2] == undefined do (
					
					messageBox "Invalid operation. Define D1 first."
					return false
				)
				obj.parent = active_road.CrossRoadKids.kids[2]
				active_road.CrossRoadKids.kids[6] = obj
				ro.lbl_cr_p2.text =  obj.name
			)
			#p3: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				if active_road.CrossRoadKids.kids[3] == undefined do (
					
					messageBox "Invalid operation. Define D1 first."
					return false
				)
				obj.parent = active_road.CrossRoadKids.kids[3]
				active_road.CrossRoadKids.kids[7] = obj
				ro.lbl_cr_p3.text =  obj.name
			)
			#p4: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				if active_road.CrossRoadKids.kids[4] == undefined do (
					
					messageBox "Invalid operation. Define D1 first."
					return false
				)
				obj.parent = active_road.CrossRoadKids.kids[4]
				active_road.CrossRoadKids.kids[8] = obj
				ro.lbl_cr_p4.text =  obj.name
			)
		)
	)
	
	fn selCrossRoadComponent type = (
			
		local ro = roadAnatomyToolSubDialogB
		local obj = case type of (
			
			#d1: getNodeByName ro.lbl_cr_d1.text 
			#d2: getNodeByName ro.lbl_cr_d2.text 
			#d3: getNodeByName ro.lbl_cr_d3.text 
			#d4: getNodeByName ro.lbl_cr_d4.text 
			#p1: getNodeByName ro.lbl_cr_p1.text 
			#p2: getNodeByName ro.lbl_cr_p2.text 
			#p3: getNodeByName ro.lbl_cr_p3.text 
			#p4: getNodeByName ro.lbl_cr_p4.text 
		)
		if isValidNode obj do select obj
	)
	
	fn clearCrossRoadFields = ( 
		
		local ro = roadAnatomyToolSubDialogB
		ro.lbl_cr_d1.text = "undefined"
		ro.lbl_cr_d2.text = "undefined"
		ro.lbl_cr_d3.text = "undefined"
		ro.lbl_cr_d4.text = "undefined"
		ro.lbl_cr_p1.text = "undefined"
		ro.lbl_cr_p2.text = "undefined"
		ro.lbl_cr_p3.text = "undefined"
		ro.lbl_cr_p4.text = "undefined"
	)
	
	fn resetCrossRoad = (
		
		if active_road == undefined do return false  --if nothing selected, reset fields
		local is_cross_road = findString active_road.name "generator_crossroad" != undefined	
		if is_cross_road do active_road.CrossRoadKids.kids = #() --clear data
	)
	
	fn showInterfaceRoad = (

		roadAnatomyToolDialog.height = roadAnatomyToolSubDialogA_Height + 4
		roadAnatomyToolDialog.roSubA.visible = true
		roadAnatomyToolDialog.roSubB.visible = false
	)
 
	fn showInterfaceCrossRoad = ( 
	
		roadAnatomyToolDialog.height = roadAnatomyToolSubDialogB_Height + 4
		roadAnatomyToolDialog.roSubA.visible = false
		roadAnatomyToolDialog.roSubB.visible = true
	)
	
	fn getObjectInfo a s = (
	
		active_road = selection[1]
		if active_road == undefined or classOf active_road != Editable_Poly do return false  --if nothing selected, reset fields

		clearRoadFields() 
		clearCrossRoadFields() 
		
		local is_road = roGenStruct.isRoad active_road --findString active_road.name "generator_connect_road" != undefined
		local is_cross_road = roGenStruct.isCrossRoad active_road --findString active_road.name "generator_crossroad" != undefined
		
		if  is_road then (
			
			format "selected road\n"
			showInterfaceRoad()
			local roadSpline = active_road.roadSpline
			local startPoint = active_road.startPoint
			local endPoint = active_road.endPoint	
			local ro = roadAnatomyToolSubDialogA
			ro.lbl_s1.text = if roadSpline != undefined then roadSpline.name else "undefined"
			ro.lbl_d1.text = if startPoint != undefined then startPoint.name else "undefined"
			ro.lbl_d2.text = if endPoint != undefined then endPoint.name else "undefined"
			ro.lbl_p1.text = if (startPoint != undefined and startPoint.children[1] != undefined) then startPoint.children[1].name else "undefined"
			ro.lbl_p2.text = if (endPoint  != undefined and endPoint.children[1]  != undefined) then endPoint.children[1].name else "undefined"
			
		) else if is_cross_road do (

			format "selected crossroad\n"
			showInterfaceCrossRoad()
			--local road_helpers =  for kid in active_road.CrossRoadKids.kids where isValidNode kid collect kid --get all helpers from nodeTab
			local road_helpers =  active_road.CrossRoadKids.kids
			if road_helpers.count != 8 do return false
			local ro = roadAnatomyToolSubDialogB
			local fields = #(ro.lbl_cr_d1, ro.lbl_cr_d2, ro.lbl_cr_d3, ro.lbl_cr_d4, ro.lbl_cr_p1, ro.lbl_cr_p2, ro.lbl_cr_p3, ro.lbl_cr_p4)
			for i = 1 to 8 do (

				local obj = road_helpers[i]
				if obj == undefined do continue
				fields[i].text = obj.name	
			)
		)
	)
	fn registerCalbacks = (
		
		handler = nodeEventCallback selectionChanged:getObjectInfo
	)
	fn unregisterCalbacks = (
	
		handler = undefined
		gc light:true
	)
	fn init = (

		AddSubRollout roadAnatomyToolDialog.roSubA roadAnatomyToolSubDialogA
		AddSubRollout roadAnatomyToolDialog.roSubB roadAnatomyToolSubDialogB
		getObjectInfo null null
		registerCalbacks()
	)
	fn shut = (
		
		unregisterCalbacks()
	)
	on roadAnatomyToolDialog open do (init())
	on roadAnatomyToolDialog close do (shut())
)
createDialog roadAnatomyToolDialog

/*
gRoadGenCa
gSplineGenCa
gCACrossRoadKids
--SETUP
--spline
custAttributes.add $Line001 gSplineGenCa #unique
--road
custAttributes.add $generator_connect_road16 gRoadGenCa #unique
road.roadSpline 	= rSpline
road.startPoint 	= sPoint
road.endPoint 		= ePoint
road.controlsStr	= GetCAControlsSTR dialog controlsArr
--crossroad
custAttributes.add $generator_crossroad_4DR002 gCACrossRoadKids #unique
$generator_crossroad_4DR002.kids = GetKidsOfCrossRoad obj.children
$generator_crossroad_4DR002.controlsStr = GetCAControlsSTR dialog controlsArr

--DETECT
$generator_crossroad_4DR001.controlsStr
*/