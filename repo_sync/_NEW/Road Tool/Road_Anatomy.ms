Global roadAnatomyToolDialog
rollout roadAnatomyToolDialog "Road Anatomy:" width:336 height:224
(
	
	GroupBox 'grp1' "" pos:[52,8] width:236 height:56 align:#left
	GroupBox 'grp2' "" pos:[12,36] width:312 height:2 align:#left
	
	label 'lbl1' "D1" pos:[16,12] width:16 height:16 align:#left
	label 'lbl2' "D2" pos:[304,12] width:16 height:16 align:#left
	label 'lbl3' "P1" pos:[120,16] width:16 height:16 align:#left
	label 'lbl4' "P2" pos:[212,16] width:16 height:16 align:#left
	label 'lbl5' "S1" pos:[168,40] width:16 height:16 align:#left
	
	button 'btn_d1' "D1" pos:[8,112] width:36 height:24 toolTip:"Start Point" align:#left
	button 'btn_d2' "D2" pos:[8,168] width:36 height:24 toolTip:"End Point" align:#left
	button 'btn_p1' "P1" pos:[40,136] width:36 height:24 toolTip:"Tangent Start" align:#left
	button 'btn_p2' "P2" pos:[40,196] width:36 height:24 toolTip:"Tangent End" align:#left
	button 'btn_s1' "S1" pos:[8,72] width:36 height:24 toolTip:"Path Spline" align:#left
	
	label 'lbl_d1' "" pos:[48,116] width:240 height:16 align:#left
	label 'lbl_d2' "" pos:[48,172] width:240 height:16 align:#left
	label 'lbl_p1' "" pos:[80,140] width:204 height:16 align:#left
	label 'lbl_p2' "" pos:[80,200] width:208 height:16 align:#left
	label 'lbl_s1' "" pos:[48,80] width:240 height:16 align:#left
	
	pickButton 'pbtn_d1' "pick" pos:[292,112] width:36 height:24 align:#left
	pickButton 'pbtn_d2' "pick" pos:[292,168] width:36 height:24 align:#left
	pickButton 'pbtn_p1' "pick" pos:[292,136] width:36 height:24 align:#left
	pickButton 'pbtn_p2' "pick" pos:[292,192] width:36 height:24 align:#left
	pickButton 'pbtn_s1' "pick" pos:[292,76] width:36 height:24 align:#left
	local active_road
	fn addComponent obj type = (
		
		if not (isValidNode active_road) do return false
		case type of (
			
			#d1:	(
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				active_road.startPoint = obj
				lbl_d1.text = obj.name
			)
			#d2: (
				if classOf obj != Point do (
					
					messageBox "Invalid operation. Target must be Point."
					return false
				)
				active_road.endPoint = obj
				lbl_d2.text = obj.name
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
				active_road.roadSpline = obj
				lbl_s1.text = obj.name
			)
		)
	)
	
	fn selComponent type = (
			
		local obj = case type of (
			
			#d1: getNodeByName lbl_d1.text 
			#d2: getNodeByName lbl_d2.text 
			#p1: getNodeByName lbl_p1.text 
			#p2: getNodeByName lbl_p2.text 
			#s1: getNodeByName lbl_s1.text 
		)
		if isValidNode obj do select obj
	)
	
	fn init = (
	
		active_road = selection[1]
		if active_road == undefined or findString active_road.name "generator_connect_road" == undefined do (
			
			lbl_s1.text =  "undefined"
			lbl_d1.text = "undefined"
			lbl_d2.text = "undefined"
			lbl_p1.text = "undefined"
			lbl_p2.text = "undefined"
			return false 
		)
		local roadSpline = active_road.roadSpline
		local startPoint = active_road.startPoint
		local endPoint = active_road.endPoint	
		lbl_s1.text = if roadSpline != undefined then roadSpline.name else "undefined"
		lbl_d1.text = if startPoint != undefined then startPoint.name else "undefined"
		lbl_d2.text = if endPoint != undefined then endPoint.name else "undefined"
		lbl_p1.text = if startPoint.children[1] != undefined then startPoint.children[1].name else "undefined"
		lbl_p2.text = if endPoint.children[1] != undefined then endPoint.children[1].name else "undefined"
	)

	on roadAnatomyToolDialog open do (init())
	on pbtn_d1 picked obj do (addComponent obj #d1)
	on pbtn_d2 picked obj do (addComponent obj #d2)
	on pbtn_p1 picked obj do (addComponent obj #p1)
	on pbtn_p2 picked obj do (addComponent obj #p2)
	on pbtn_s1 picked obj do (addComponent obj #s1)
		
	on btn_d1 pressed  do (selComponent #d1)
	on btn_d2 pressed  do (selComponent #d2)
	on btn_p1 pressed  do (selComponent #p1)
	on btn_p2 pressed  do (selComponent #p2)
	on btn_s1 pressed  do (selComponent #s1)
)
CreateDialog roadAnatomyToolDialog