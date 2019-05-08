plugin Helper Mc_Helper_Box
name:"DummyD"
classID:#(0x74830183, 0x38f7483a)
category:"Standard"
extends:dummy
(
	local lastSize, meshObj
	parameters pblock rollout:params (
		
		size type:#float animatable:true ui:amount default:0
	)
	rollout params "Parameters" (
		
		Spinner amount "Size:" range:[0, 1e9, 0]
	)
	on getDisplayMesh do (
		
		if (meshObj == undefined) do (

			meshObj = createInstance box length:size width:size height:size wirecolor:green mapCoords:false
			lastSize = size
		)
		
		if size != lastSize do (
			
			meshObj.length = meshObj.width = meshObj.height = size 
			lastSize = size
		)
		meshObj.mesh
	)
	tool create (
		
		local p1
		on mousePoint click do (
			
			case click of  ( 
				
				1: (
					p1=gridPoint
					nodeTM.translation =  p1
				)
				2: #stop
			)
		)
		on mousemove click do (
			
			size = distance p1 gridPoint
		)
	)
)


plugin Helper Mc_Helper_Sphere 
name:"DummyS"
classID:#(0x276a2b75, 0x57c59af8)--genClassID()
category:"Standard"
extends:dummy
(
	parameters pblock rollout:params (
		
		size type:#float animatable:true ui:amount default:0
		location type:#point3tab tabSizeVariable:true
	)
	rollout params "Parameters" (
		
		Spinner amount "Size:" range:[0, 1e9, 0]
	)
	on getDisplayMesh do (
		
		meshObj = createInstance sphere radius:size  wirecolor:green mapCoords:false 
		meshObj.mesh
	)
	tool create (
		
		local p1
		on mousePoint click do (
			
			case click of  ( 
				
				1: (
					p1=gridPoint
					nodeTM.translation =  p1
				)
				2: #stop
			)
		)
		on mousemove click do (
			
			size = (distance p1 gridPoint)
		)
	)
)