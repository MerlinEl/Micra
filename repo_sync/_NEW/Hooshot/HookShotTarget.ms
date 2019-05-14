plugin simpleObject P3D_HookShotTarget
	name:"HookShotTarget"
	classID:#(0x5eb78b6b, 0xec2d505)
	invisible: True
	category:gP3D_PluginName
(	
	local obj, theMesh 
	local delHandler
-- 	local me
	----------------------------------------------------------------------------------------------------------------
	parameters main rollout:params
	(
-- 		temp 			type:	#worldUnits ui:temp default:0
		mainHandle 	type: #integer
		middleHandle	type: #integer
		delIndex			type: #texturemap
	)
	rollout params "HookShot(target) Parameters"
	(
-- 		spinner temp "Temp" type:#worldunits range:[-1000,1000,0]
	)
	----------------------------------------------------------------------------------------------------------------	On Build Mesh
	on buildMesh do
	(
-- 		format "- build Target- \n"
		
-- 		obj = createinstance Cone radius1:0 radius2:3 height:10 sides: 10 heightsegs: 1
-- 		obj = createinstance Box width:5 length:5 height:5
		obj = createinstance Hedra family:0 scalep:100 scaleq:100 scaler:100 mapcoords:on radius:5.0
		theMesh = obj.mesh
		
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
				2: (
-- 						gP3DHookShot.StartTracking me --starts callback
						#stop
					)
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
-- 		me = theNode
		theNode.wirecolor = color 0 255 0
-- 		theNode.wirecolor = color 8 110 135
-- 		delHandler = when theNode deleted id:#del delNode do (
-- 			local mainDelHandl, midDelHandl, targetDelHandl
-- 			
-- 			if (selection as array).count >1 then select delNode
-- 			
-- 			format "%\n" (isValidNode delNode)
-- 			local main 		= (maxOps.getNodeByHandle delNode.mainHandle)
-- 			local mid 		= (maxOps.getNodeByHandle delNode.middleHandle)
-- 			mainDelHandl 	= main.delHandler
-- 			midDelHandl 	= mid.delHandler
-- 			deleteChangeHandler mainDelHandl
-- 			deleteChangeHandler midDelHandl
-- 					
-- 			if main 	!= undefined then delete main
-- 			if mid 	!= undefined then delete mid
-- 		)
	)
)