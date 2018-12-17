plugin Helper HelperTest_DisplayMesh
name:"HelperTest"
classID:#(0x47db14fe, 0x4e9b5f90)
category:"Standard"
extends:dummy
(
	local lastSize, meshObj
	parameters pblock rollout:params
	(
		size type:#float animatable:true ui:amount default:40.0
	)
	rollout params "HelperTest Parameters"
	(
		Spinner amount "Size:" range:[0, 1e9, 40]
	)
	on getDisplayMesh do
	(
		if (meshObj == undefined) do
		(
			meshObj = createInstance box length:size width:size height:size mapCoords:false lastSize = size
		)
		if size != lastSize do
		(
			meshObj.length = meshObj.width = meshObj.height = size lastSize = size
		)
		meshObj.mesh
	)
	tool create
	(
		on mousePoint click do
		(
			nodeTM.translation = gridPoint;#stop
		)
	)
)