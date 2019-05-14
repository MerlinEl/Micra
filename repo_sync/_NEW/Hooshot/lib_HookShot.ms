
--																				P3D HookShot Plugin (library)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gP3DHookShot = undefined
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
struct sP3DHookShot
(
	private hookLayer,
	private delMainObjects,		-- to prevent delete callback crossing (using predelete callback)
	------------------------------------------------------------------------------------------------------------- Layer >>
	public fn SetHookLayer =
	(
		hookLayer = LayerManager.getLayerFromName "[HookShot]"
		if hookLayer == undefined then hookLayer = LayerManager.newLayer()
		hookLayer.setname "[HookShot]"
		True
	),
	-------------------------------------------------------------------------------------------------------------
	public fn MoveHookSetToLayer hookSet =
	(
		for hookPart in hookSet do(
			hookLayer.addNode hookPart
		)
	),
	------------------------------------------------------------------------------------------------------------- Hide/Unhide >>
	public fn HideUnhideAll =
	(
		if hookLayer.on == true then hookLayer.on = false
		else hookLayer.on = True
	),
	------------------------------------------------------------------------------------------------------------- CA Refresh >>
	public fn SetCAParameters main mainPos targetPos normalV =
	(
		main.HSE_point1 	= mainPos[1] as string		+ " "+ mainPos[2] as string 	+ " "+mainPos[3] as string  
		main.HSE_point2 	= targetPos[1] as string	+ " "+ targetPos[2] as string + " "+targetPos[3] as string  
		main.HSE_normal 	= normalV[1] as string		+ " "+ normalV[2] as string 	+ " "+normalV[3] as string
		True
	),
	------------------------------------------------------------------------------------------------------------- CA Refresh >>
	public fn UpdateCA main targetPos normV classOfObj=
	(
		
		local mainPos = main.transform.row4
		
		Case (classOfObj) of (
			P3D_HookShotMain : (
				main.point1X = mainPos[1]		
				main.point1Y = mainPos[2]	
				main.point1Z = mainPos[3]
			)
		
			P3D_HookShotTarget : (
				main.point2X = targetPos[1]		
				main.point2Y = targetPos[2]			
				main.point2Z = targetPos[3]
			)
		)
-- 		main.normalX = normV[1]		
-- 		main.normalY = normV[2]		
-- 		main.normalZ = normV[3]
-- 		
-- 		main.point1X = mainPos[1]		
-- 		main.point1Y = mainPos[2]	
-- 		main.point1Z = mainPos[3]		
-- 		
-- 		main.point2X = targetPos[1]		
-- 		main.point2Y = targetPos[2]			
-- 		main.point2Z = targetPos[3]			
-- 		
		main.normalX = normV[1]		
		main.normalY = normV[2]		
		main.normalZ = normV[3] 		
		SetCAParameters main mainPos targetPos normV
		True
	),
	------------------------------------------------------------------------------------------------------------- Build >>
	public fn BuildHookSet gridPoint main middle target classOfObj =
	(
		local vDirect 	= gridPoint - main.pos
		local mVz		= normalize main.transform.row3
		local mVy		= normalize (cross (normalize mVz) (normalize vDirect))
		local nVz		= normalize (cross (normalize vDirect) mVy)
		--------------------------------------------------------------
		local tVx		= normalize [vDirect[1], vDirect[2], 0]
		target.transform = matrix3 tVx mVy mVz target.pos
		--------------------------------------------------------------
		middle.pos 		= main.pos + 0.5*(vDirect)
		middle.lenght	= distance main.pos target.pos
		middle.transform 	= matrix3  nVz (normalize vDirect) (-mVy) middle.pos
		--------------------------------------------------------------
		main.transform 	= matrix3 tVx mVy mVz main.pos
		--------------------------------------------------------------	
-- 		UpdateCA main target.pos (-mVy) classOfObj
		True
	)
	------------------------------------------------------------------------------------------------------------- Flip >>
-- 	public fn FlipCurrent obj =
-- 	(
-- 		local main	= maxOps.getNodeByHandle obj.mainHandle
-- 		local mVx 	= main.transform.row1
-- 		local mVy 	= main.transform.row2
-- 		local mVz 	= -(main.transform.row3)
-- 		local pos	= main.transform.row4
-- 		
-- 		main.transform = matrix3 mVx mVy mVz pos
-- 		redrawViews() 
-- 	)

	------------------------------------------------------------------------------------------------------------- CallBacks >>
-- 	public fn StartTracking obj=		-- only tracking main and it also works for other parts of HookSet    (Strange?)
-- 	(
-- 		format "Trans_Track\n"
-- 		when transform obj changes do (
-- 			
-- 			local obj 			= (selection as array)[1]
-- 			
-- 			local classofObj 	=  classof obj
-- 			format "%\n" classofObj
-- 			Case (classofObj) of (
-- 				P3D_HookShotMain : 	gP3DHookShot.BuildHookSet obj.second.pos obj obj.middle obj.second
-- 				P3D_HookShotMiddle : 	select #((maxOps.getNodeByHandle obj.mainHandle), obj, (maxOps.getNodeByHandle obj.targetHandle))
-- 				P3D_HookShotTarget : 	gP3DHookShot.BuildHookSet obj.pos (maxOps.getNodeByHandle obj.mainHandle) (maxOps.getNodeByHandle obj.middleHandle) obj
-- 			)
-- 		)
-- 	),
	-------------------------------------------------------------------------------------------------------------
-- 	public fn TrackingForDelete obj=
-- 	(
-- 		when obj  deleted id:#del delNode do (
-- 			local classofObj 	=  classof delNode
-- 			local mainDelHandl, midDelHandl, targetDelHandl
-- 			
-- 			if (selection as array).count >1 then select delNode
-- 			
-- 			Case (classofObj) of (
-- 				P3D_HookShotMain : (
-- 					format "%\n" (isValidNode delNode)
-- 					midDelHandl 		= delNode.middle.delHandler
-- 					targetDelHandl 	= delNode.second.delHandler
-- 					deleteChangeHandler midDelHandl
-- 					deleteChangeHandler targetDelHandl

-- 					if delNode.middle 		!= undefined then delete delNode.middle
-- 					if delNode.second 	!= undefined then delete delNode.second
-- 				)
-- 				P3D_HookShotMiddle : (
-- 					format "%\n" (isValidNode delNode)
-- 					local main 		= (maxOps.getNodeByHandle delNode.mainHandle)
-- 					local target 	= (maxOps.getNodeByHandle delNode.targetHandle)
-- 					mainDelHandl 		= main.delHandler
-- 					targetDelHandl 	= target.delHandler
-- 					deleteChangeHandler mainDelHandl
-- 					deleteChangeHandler targetDelHandl
-- 					
-- 					if main 	!= undefined then delete main
-- 					if target != undefined then delete target
-- 				)
-- 				P3D_HookShotTarget : (
-- 					format "%\n" (isValidNode delNode)
-- 					local main 		= (maxOps.getNodeByHandle delNode.mainHandle)
-- 					local mid 		= (maxOps.getNodeByHandle delNode.middleHandle)
-- 					mainDelHandl 	= main.delHandler
-- 					midDelHandl 	= mid.delHandler
-- 					deleteChangeHandler mainDelHandl
-- 					deleteChangeHandler midDelHandl
-- 					
-- 					if main 	!= undefined then delete main
-- 					if mid 	!= undefined then delete mid
-- 				)
-- 			)
-- 		)
-- 		
-- 	)
	-------------------------------------------------------------------------------------------------------------
-- 	public fn DeleteHookSet obj =
-- 	(
-- 		local classofObj 	=  classof obj
-- 		
-- 		Case (classofObj) of (
-- 			P3D_HookShotMain : (
-- 				format "%\n%\n" obj.middle obj.second
-- 				if obj.middle 	!= undefined then delete obj.middle
-- 				if obj.second 	!= undefined then delete obj.second
-- 			)
-- 			P3D_HookShotMiddle : (
-- 				local main 		= (maxOps.getNodeByHandle obj.mainHandle)
-- 				local target 	= (maxOps.getNodeByHandle obj.targetHandle)
-- 				
-- 				format "%\n%\n" main target
-- 				if main 	!= undefined then delete main
-- 				if target != undefined then delete target
-- 			)
-- 			P3D_HookShotTarget : (
-- 				local main 		= (maxOps.getNodeByHandle obj.mainHandle)
-- 				local mid 		= (maxOps.getNodeByHandle obj.middleHandle)
-- 				
-- 				format "%\n%\n" main mid
-- 			)
-- 		)
-- 	),


	-------------------------------------------------------------------------------------------------------------
-- 	public fn RebuildHookSet main middle target focus:#main =
-- 	(
-- 		Case (focus) of (
-- 			
-- 			
-- 		)
-- 	)
-- 	
	
)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Init :
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (gP3DHookShot == undefined) then (
	gP3DHookShot = sP3DHookShot()
)