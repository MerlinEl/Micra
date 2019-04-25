Global roadAnatomyToolDialog
if roadAnatomyToolDialog != undefined do DestroyDialog roadAnatomyToolDialog
rollout roadAnatomyToolDialog "Road Anatomy:" width:336 height:752
(

	GroupBox 'grp1' "" pos:[52,28] width:236 height:56 align:#left 
	GroupBox 'grp2' "" pos:[12,56] width:312 height:2 align:#left 
	GroupBox 'grp9' "Road:" pos:[4,8] width:328 height:236 align:#left 

	label 'lbl1' "D1" pos:[16,32] width:16 height:16 align:#left 
	label 'lbl2' "D2" pos:[304,32] width:16 height:16 align:#left 
	label 'lbl3' "P1" pos:[120,36] width:16 height:16 align:#left 
	label 'lbl4' "P2" pos:[212,36] width:16 height:16 align:#left 
	label 'lbl5' "S1" pos:[168,60] width:16 height:16 align:#left 
	
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
	
 	GroupBox 'grp8' "Cross Road:" pos:[4,252] width:328 height:496 align:#left 
	GroupBox 'grp7' "" pos:[137,324] width:56 height:130 align:#left 
	GroupBox 'grp6' "" pos:[100,361] width:130 height:56 align:#left 
	
	label 'lbl21' "D1" pos:[76,384] width:16 height:16 align:#left 
	label 'lbl22' "D2" pos:[160,300] width:16 height:16 align:#left 
	label 'lbl25' "D3" pos:[240,384] width:16 height:16 align:#left 
	label 'lbl26' "D4" pos:[156,464] width:16 height:16 align:#left 
	label 'lbl23' "P1" pos:[48,384] width:16 height:16 align:#left 
	label 'lbl24' "P2" pos:[160,272] width:16 height:16 align:#left 
	label 'lbl27' "P3" pos:[264,384] width:16 height:16 align:#left 
	label 'lbl28' "P4" pos:[156,492] width:16 height:16 align:#left 
	
	label 'lbl_cr_d1' "" pos:[44,514] width:240 height:16 align:#left
	label 'lbl_cr_p1' "" pos:[76,538] width:204 height:16 align:#left
	label 'lbl_cr_d2' "" pos:[44,574] width:240 height:16 align:#left
	label 'lbl_cr_p2' "" pos:[76,598] width:204 height:16 align:#left
	label 'lbl_cr_d3' "" pos:[44,634] width:240 height:16 align:#left
	label 'lbl_cr_p3' "" pos:[76,658] width:204 height:16 align:#left
	label 'lbl_cr_d4' "" pos:[44,694] width:240 height:16 align:#left
	label 'lbl_cr_p4' "" pos:[76,718] width:204 height:16 align:#left
	
	button 'btn_cr_d1' "D1" pos:[4,510] width:36 height:24 toolTip:"Start Point" align:#left
	button 'btn_cr_d2' "D2" pos:[4,570] width:36 height:24 toolTip:"Start Point" align:#left
	button 'btn_cr_d3' "D3" pos:[4,630] width:36 height:24 toolTip:"Start Point" align:#left
	button 'btn_cr_d4' "D4" pos:[4,690] width:36 height:24 toolTip:"Start Point" align:#left
	button 'btn_cr_p1' "P1" pos:[36,534] width:36 height:24 toolTip:"Tangent Start" align:#left
	button 'btn_cr_p2' "P2" pos:[36,594] width:36 height:24 toolTip:"Tangent Start" align:#left
	button 'btn_cr_p3' "P3" pos:[36,654] width:36 height:24 toolTip:"Tangent Start" align:#left
	button 'btn_cr_p4' "P4" pos:[36,714] width:36 height:24 toolTip:"Tangent Start" align:#left
	button 'btn_cr_reset' "reset" pos:[284,272] width:40 height:16 align:#left
	
	pickbutton 'pbtn_cr_d1' "pick" pos:[288,508] width:36 height:24 align:#left
	pickbutton 'pbtn_cr_d2' "pick" pos:[288,568] width:36 height:24 align:#left
	pickbutton 'pbtn_cr_d3' "pick" pos:[288,628] width:36 height:24 align:#left	
	pickbutton 'pbtn_cr_d4' "pick" pos:[288,688] width:36 height:24 align:#left	
	pickbutton 'pbtn_cr_p1' "pick" pos:[288,534] width:36 height:24 align:#left
	pickbutton 'pbtn_cr_p2' "pick" pos:[288,594] width:36 height:24 align:#left
	pickbutton 'pbtn_cr_p3' "pick" pos:[288,654] width:36 height:24 align:#left
	pickbutton 'pbtn_cr_p4' "pick" pos:[288,714] width:36 height:24 align:#left
	
	local active_road
	--Road Functions
	fn addRoadComponent obj type = (
		
		if not (isValidNode active_road) do return false
		case type of (
			
			#d1:	(
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				active_road.startPoint = obj
				lbl_d1.text = obj.name
				if active_road.startPoint.children[1] != undefined do lbl_p1.text =  active_road.startPoint.children[1].name
			)
			#d2: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				active_road.endPoint = obj
				lbl_d2.text = obj.name
				if active_road.endPoint.children[1] != undefined do lbl_p2.text =  active_road.endPoint.children[1].name
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
				lbl_p1.text =  obj.name
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
				lbl_p2.text = obj.name
			)
			#s1: (
				
				if classOf obj != SplineShape do (
					
					messageBox "Invalid operation. Target must be Shape."
					return false
				)
				obj.SplineGenCa.road = active_road.name
				active_road.roadSpline = obj
				lbl_s1.text = obj.name
			)
		)
	)
	
	fn selRoadComponent type = (
			
		local obj = case type of (
			
			#d1: getNodeByName lbl_d1.text 
			#d2: getNodeByName lbl_d2.text 
			#p1: getNodeByName lbl_p1.text 
			#p2: getNodeByName lbl_p2.text 
			#s1: getNodeByName lbl_s1.text 
		)
		if isValidNode obj do select obj
	)
	
	fn clearRoadFields = ( 
		
		lbl_s1.text =  "undefined"
		lbl_d1.text = "undefined"
		lbl_d2.text = "undefined"
		lbl_p1.text = "undefined"
		lbl_p2.text = "undefined"
	)
	
	--CrossRoad Functions
	fn addCrossRoadComponent  obj type = (
		
		if not (isValidNode active_road) do return false
		case type of (
			
			#d1:	(
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				obj.parent = active_road
				active_road.CrossRoadKids.kids[1] = obj
				lbl_cr_d1.text = obj.name
				if obj.children[1] != undefined do (
					
					lbl_cr_p1.text =  obj.children[1].name
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
				lbl_cr_d2.text = obj.name
				if obj.children[1] != undefined do (
					
					lbl_cr_p2.text =  obj.children[1].name
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
				lbl_cr_d3.text = obj.name
				if obj.children[1] != undefined do (
					
					lbl_cr_p3.text =  obj.children[1].name
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
				lbl_cr_d4.text = obj.name
				if obj.children[1] != undefined do (
					
					lbl_cr_p4.text =  obj.children[1].name
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
				lbl_cr_p1.text =  obj.name
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
				lbl_cr_p2.text =  obj.name
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
				lbl_cr_p3.text =  obj.name
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
				lbl_cr_p4.text =  obj.name
			)
		)
	)
	
	fn selCrossRoadComponent type = (
			
		local obj = case type of (
			
			#d1: getNodeByName lbl_cr_d1.text 
			#d2: getNodeByName lbl_cr_d2.text 
			#d3: getNodeByName lbl_cr_d3.text 
			#d4: getNodeByName lbl_cr_d4.text 
			#p1: getNodeByName lbl_cr_p1.text 
			#p2: getNodeByName lbl_cr_p2.text 
			#p3: getNodeByName lbl_cr_p3.text 
			#p4: getNodeByName lbl_cr_p4.text 
		)
		if isValidNode obj do select obj
	)
	
	fn clearCrossRoadFields = ( 
		
		lbl_cr_d1.text = "undefined"
		lbl_cr_d2.text = "undefined"
		lbl_cr_d3.text = "undefined"
		lbl_cr_d4.text = "undefined"
		lbl_cr_p1.text = "undefined"
		lbl_cr_p2.text = "undefined"
		lbl_cr_p3.text = "undefined"
		lbl_cr_p4.text = "undefined"
	)
	
	fn resetCrossRoad = (
		
		if active_road == undefined do return false  --if nothing selected, reset fields
		local is_cross_road = findString active_road.name "generator_crossroad" != undefined	
		if is_cross_road do active_road.CrossRoadKids.kids = #() --clear data
	)
	
	fn init = (
	
		clearRoadFields() 
		clearCrossRoadFields() 
		
		active_road = selection[1]
		if active_road == undefined do return false  --if nothing selected, reset fields

		local is_road = findString active_road.name "generator_connect_road" != undefined
		local is_cross_road = findString active_road.name "generator_crossroad" != undefined
		if  is_road then (
			
			format "selected road\n"
			local roadSpline = active_road.roadSpline
			local startPoint = active_road.startPoint
			local endPoint = active_road.endPoint	
			lbl_s1.text = if roadSpline != undefined then roadSpline.name else "undefined"
			lbl_d1.text = if startPoint != undefined then startPoint.name else "undefined"
			lbl_d2.text = if endPoint != undefined then endPoint.name else "undefined"
			lbl_p1.text = if (startPoint != undefined and startPoint.children[1] != undefined) then startPoint.children[1].name else "undefined"
			lbl_p2.text = if (endPoint  != undefined and endPoint.children[1]  != undefined) then endPoint.children[1].name else "undefined"
			
		) else if is_cross_road do (

			format "selected crossroad\n"
			--local road_helpers =  for kid in active_road.CrossRoadKids.kids where isValidNode kid collect kid --get all helpers from nodeTab
			local road_helpers =  active_road.CrossRoadKids.kids
			if road_helpers.count != 8 do return false
			local fields = #(lbl_cr_d1, lbl_cr_d2, lbl_cr_d3, lbl_cr_d4, lbl_cr_p1, lbl_cr_p2, lbl_cr_p3, lbl_cr_p4)
			for i = 1 to 8 do (

				local obj = road_helpers[i]
				if obj == undefined do continue
				fields[i].text = obj.name	
			)
		)
	)

	on roadAnatomyToolDialog open do (init())
		
	--Road Controlls
	on pbtn_d1 picked obj do (addRoadComponent obj #d1)
	on pbtn_d2 picked obj do (addRoadComponent obj #d2)
	on pbtn_p1 picked obj do (addRoadComponent obj #p1)
	on pbtn_p2 picked obj do (addRoadComponent obj #p2)
	on pbtn_s1 picked obj do (addRoadComponent obj #s1)
		
	on btn_d1 pressed  do (selRoadComponent #d1)
	on btn_d2 pressed  do (selRoadComponent #d2)
	on btn_p1 pressed  do (selRoadComponent #p1)
	on btn_p2 pressed  do (selRoadComponent #p2)
	on btn_s1 pressed  do (selRoadComponent #s1)
		
	--Crossroad Controls
	on pbtn_cr_d1 picked obj do (addCrossRoadComponent obj #d1)
	on pbtn_cr_d2 picked obj do (addCrossRoadComponent obj #d2)
	on pbtn_cr_d3 picked obj do (addCrossRoadComponent obj #d3)
	on pbtn_cr_d4 picked obj do (addCrossRoadComponent obj #d4)
	on pbtn_cr_p1 picked obj do (addCrossRoadComponent obj #p1)
	on pbtn_cr_p2 picked obj do (addCrossRoadComponent obj #p2)
	on pbtn_cr_p3 picked obj do (addCrossRoadComponent obj #p3)
	on pbtn_cr_p4 picked obj do (addCrossRoadComponent obj #p4)
	
	on btn_cr_d1 pressed  do (selCrossRoadComponent #d1)
	on btn_cr_d2 pressed  do (selCrossRoadComponent #d2)
	on btn_cr_d3 pressed  do (selCrossRoadComponent #d3)
	on btn_cr_d4 pressed  do (selCrossRoadComponent #d4)
	on btn_cr_p1 pressed  do (selCrossRoadComponent #p1)
	on btn_cr_p2 pressed  do (selCrossRoadComponent #p2)
	on btn_cr_p3 pressed  do (selCrossRoadComponent #p3)
	on btn_cr_p4 pressed  do (selCrossRoadComponent #p4)
	on btn_cr_reset pressed do (resetCrossRoad())
)
CreateDialog roadAnatomyToolDialog