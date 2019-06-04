


/*
line_path = roGen_Path startP:selection[1].pos endP: selection[2].pos name:(uniqueName "Road_Path_") build:true
*/
plugin Shape roGen_Path
name:"RoadPath"
classID:#(0x4f073ea0, 0x6a80ada1)
category:"Road Tool"
extends:SplineShape version:1
(
	local meshObj
	fn drawLineBetweenTwoPoints pointA pointB = (

		local sp = SplineShape pos:pointA
		addNewSpline sp
		addKnot sp 1 #corner #line PointA
		addKnot sp 1 #corner #line PointB
		updateShape sp
		sp.pivot = (sp.min + sp.max) / 2
		sp
	)
	parameters main rollout:params 
	(
		
		parent_node type:#maxObject
		startP type:#point3 animateable:false default:[0,0,0]
		endP type:#point3 animateable:false default:[0,0,0]
		is_deleted type:#boolean animateable:false default:false
		build type:#boolean animateable:false default:false
		node_name  type:#string animateable:false default:""
		
		on build set val do (
			
			if build do (
				
				format "build shape: % \n" val
				meshObj = drawLineBetweenTwoPoints startP endP
			)
		)

	)
	rollout params "RoadTool:" 
	(
		group "About:" (
			
			label lbl1 "Road Spline Helper" align:#left
		)
	)
	
	on getDisplayMesh do (
		
		if (meshObj == undefined) do (
			
-- 			meshObj = createInstance Sphere radius:size segments:8 mapCoords:false
-- 			lastSize = size
			format "roGen_Joint > getDisplayMesh >  mesh:%\n" meshObj
		)
-- 		if size != lastSize do (
-- 			 
-- 			lastSize = meshObj.radius = size
-- 		)
-- 		meshObj.mesh
	)
	
	on detachedFromNode obj do ( --when node is deleted
		
		format  "roGen_Path > detachedFromNode > node_name:%\n"  node_name
		if is_deleted do return false --prevent depency loop crash
		format  "roGen_Path > detachedFromNode > parent:% is_deleted:%\n"  parent_node is_deleted
		is_deleted = true
		if classOf parent_node == NodeTransformMonitor do ( --when spline is dleted delete also master obj
			local obj = parent_node.node
			if isValidNode obj and not (isDeleted obj) and not (obj.is_deleted) do (
				
				format "roGen_Path > detachedFromNode > Deleting parent node:%\n" obj.name
				try (delete parent_node.node) catch (format "roGen_Path > detachedFromNode > Error:%\n" (getCurrentException()))
			)
		)
	)
	on deleted do (
			
		is_deleted = true
		format "roGen_Path > deleted node:%\n"  node_name
	)
	tool create numPoints:3 (
		
		on mousePoint click do case click of (
			
			2: (
				format "this:%\n" this
				startP = gridPoint
				nodeTM.translation = startP
			)
			3: (
				#stop
				endP = gridPoint
				meshObj = drawLineBetweenTwoPoints startP endP
			)
		)
	)
)
