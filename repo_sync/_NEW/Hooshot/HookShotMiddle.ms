plugin simpleObject P3D_HookShotMiddle
	name:"HookShotTarget"
	classID:#(0x2c889771, 0x7088ca15)
	invisible: True
	category:gP3D_PluginName
(	
	local obj, theMesh 
	local delHandler
	----------------------------------------------------------------------------------------------------------------
	parameters main rollout:params
	(
-- 		temp 			type:	#worldUnits ui:temp default:0
		mainHandle 	type: #integer
		targetHandle	type: #integer
		lenght 			type:	#worldUnits default:1	--ui:len 
		delIndex			type: #integer
	)
	rollout params "HookShot(middle) Parameters"
	(
-- 		spinner temp "Temp" type:#worldunits range:[-1000,1000,0]
		button btFlip "Flip" width:150
		
		on btFlip pressed do
		(
-- 			gP3DHookShot.FlipCurrent $
			
			local main	= maxOps.getNodeByHandle mainHandle
			local mVx 	= main.transform.row1
			local mVy 	= main.transform.row2
			local mVz 	= -(main.transform.row3)
			local pos	= main.transform.row4
		
			main.transform = matrix3 mVx mVy mVz pos
			redrawViews() 
		)
	)
	----------------------------------------------------------------------------------------------------------------	On Build Mesh
	on buildMesh do
	(
-- 		format "- build Middle - \n"
		
		obj = createinstance box length:lenght width:1.5 height:2.0
		objTwo = createinstance Pyramid width:1.5 depth:8.0 height:25
		
		theMesh = obj.mesh + objTwo.mesh

		mesh = theMesh
	)--end buildMesh
	----------------------------------------------------------------------------------------------------------------	Tool Create
	tool create
	(
		on mousePoint click do (
			case click of
			(
				1: (
						nodeTM.translation = gridPoint
					)
				2: #stop
			)
		)

-- 		on mouseMove click do
-- 		case click of
-- 		(
-- 			2: (size = length gridDist)
-- 		)
	)
	---------------------------------------------------------------------------------------------------------------- 	Node Created
	on attachedToNode theNode do
	(
		theNode.wirecolor = color 0 255 0
		
-- 		delHandler = when theNode deleted id:#del delNode do (
-- 			local mainDelHandl, midDelHandl, targetDelHandl
-- 			
-- 			if (selection as array).count >1 then select delNode

-- 			format "%\n" (isValidNode delNode)
-- 			local main 		= (maxOps.getNodeByHandle delNode.mainHandle)
-- 			local target 	= (maxOps.getNodeByHandle delNode.targetHandle)
-- 			mainDelHandl 		= main.delHandler
-- 			targetDelHandl 	= target.delHandler
-- 			deleteChangeHandler mainDelHandl
-- 			deleteChangeHandler targetDelHandl
-- 					
-- 			if main 	!= undefined then delete main
-- 			if target != undefined then delete target
-- 		)
	)
)