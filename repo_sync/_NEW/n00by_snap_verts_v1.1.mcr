

macroScript Macro_SnapVerts  category: "N00BY"  buttonText: "Snap Verts"  toolTip: "Snap Verts"
(
	local Collapse_Target = False

	fn Copy_And_Collapse TheObj =
	(
		TempObj = copy TheObj
		maxOps.CollapseNodeTo TempObj 1 true
		if classOf TempObj != Editable_Poly do convertTo TempObj Editable_Poly
		Collapse_Target = True
		return TempObj
	)
	
	if selection.count != 1 do return 0
	if subobjectlevel != 1 do return 0
	
	TheObj = selection[1]
	TargetObj = pickObject prompt:"Pick target object" forceListenerFocus:false
	if TargetObj == undefined do return 0
	
	TM = timeStamp()
	
	local TheCurrentLevel = modPanel.getCurrentObject()
	
	if ClassOf TargetObj != Editable_Poly and TheObj != TargetObj do TargetObj = Copy_And_Collapse TargetObj
	modPanel.setCurrentObject TheCurrentLevel
	
	if classOf TheCurrentLevel == Edit_Poly then
	(
		if TargetObj == TheObj then
		(
			local Selected_Verts = Edit_Poly.GetSelection TheCurrentLevel #Vertex as array
			actionMan.executeAction 0 "40044" -- Selection: Select Invert
			local Target_Verts = Edit_Poly.GetSelection TheCurrentLevel #Vertex as array
			actionMan.executeAction 0 "40044" -- Selection: Select Invert
			
			print Selected_Verts.count
			print Target_Verts.count
			
			for v in Selected_Verts do
			(
				local v_pos
				max modify mode
				TheCurrentLevel.SetSelection #Vertex #{}
				local min_distance = 9999999999
				local New_Position = [0,0,0]
				
				for v2 in Target_Verts do
				(
					v_pos = TheCurrentLevel.getVertex v
					v2_pos = TheCurrentLevel.getVertex v2
					
					the_distance = distance v_pos v2_pos
					
					if the_distance < min_distance then 
					(
						min_distance = the_distance
						New_Position = v2_pos
					)
				)
				
				subobjectlevel = 1
				VectorToAdd = New_Position - v_pos
				TheCurrentLevel.Select #Vertex #{v}
				TheCurrentLevel.MoveSelection VectorToAdd
				TheCurrentLevel.Commit ()
			)
		)
		else
		(
			local Selected_Verts = Edit_Poly.GetSelection TheCurrentLevel #Vertex as array
			print Selected_Verts.count
			print TargetObj.verts.count
			
			for v in Selected_Verts do
			(
				local v_pos
				max modify mode
				TheCurrentLevel.SetSelection #Vertex #{}
				local min_distance = 9999999999
				local New_Position = [0,0,0]
				
				for v2 in TargetObj.verts do
				(
					v_pos = TheCurrentLevel.getVertex v
					
					the_distance = distance v_pos v2.pos
					
					if the_distance < min_distance then 
					(
						min_distance = the_distance
						New_Position = v2.pos
					)
				)
				
				subobjectlevel = 1
				VectorToAdd = New_Position - v_pos
				TheCurrentLevel.Select #Vertex #{v}
				TheCurrentLevel.MoveSelection VectorToAdd
				TheCurrentLevel.Commit ()
			)
		)
	)
	else if classOf TheCurrentLevel == Editable_Poly do
	(
		if TargetObj == TheObj then
		(
			local Selected_Verts = polyOp.getVertSelection TheObj
			max select invert
			local Target_Verts = polyOp.getVertSelection TheObj
			max select invert
			
			print Selected_Verts.count
			print Target_Verts.count
			
			for v in Selected_Verts do 
			(
				local min_distance = 9999999999
				local New_Position = [0,0,0]
				
				for v2 in Target_Verts do
				(
					the_distance = distance (polyop.getVert TheObj v) (polyop.getVert TheObj v2)
					if the_distance < min_distance do
					(
						min_distance = the_distance
						New_Position = polyop.getVert TheObj v2
					)
				)
				polyop.setVert TheObj v New_Position
			)
		)
		else
		(
			print TheObj.selectedverts.count
			print TargetObj.selectedverts.count
			
			for v in TheObj.selectedverts do 
			(
				min_distance = 9999999999
				New_Position = [0,0,0]
				
				for v2 in TargetObj.verts do
				(
					the_distance = distance v.pos v2.pos
					if the_distance < min_distance do
					(
						min_distance = the_distance
						New_Position = v2.pos
					)
				)
				v.pos = New_Position
			)
		)
	)
	
	if Collapse_Target do delete TargetObj
	print (((timeStamp()-TM)/1000.0) as string + " seconds")
)