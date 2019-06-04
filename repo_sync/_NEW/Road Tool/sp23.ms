
/*
line_path = roGen_Path startP:selection[1].pos endP: selection[2].pos name:(uniqueName "Road_Path_") build:true
*/
plugin shape roGen_Path
name:"RoadPath"
classID:#(0x13a5b2ee, 0x319bf3a8)
extends:line version:1
category:"Road Tool"
(
	local meshObj
	fn getNode = (
			
		refs.dependentnodes this firstonly:on
	)
	fn drawLineBetweenTwoPoints pointA pointB = (

		meshObj =  getNode()
		addNewSpline meshObj
		addKnot meshObj 1 #corner #line PointA
		addKnot meshObj 1 #corner #line PointB
		updateShape meshObj
	)
	parameters main rollout:params (
		
		parent_node type:#maxObject
		startP type:#point3 animateable:false default:[0,0,0]
		endP type:#point3 animateable:false default:[0,0,0]
		is_deleted type:#boolean animateable:false default:false
		build type:#boolean animateable:false default:false
		node_name  type:#string animateable:false default:""
		
		on build set val do (
			
			if build do (
				
				format "build shape: % \n" val
				drawLineBetweenTwoPoints startP endP
			)
		)
	)
	rollout params "RoadTool:"  (
		
		group "About:" (
			
			label lbl1 "Road Spline Helper" align:#left
		)
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
				startP = gridPoint
				nodeTM.translation = startP
			)
			3: (
				
				endP = gridPoint
				drawLineBetweenTwoPoints startP endP
				--meshObj.pivot = (meshObj.min + meshObj.max) / 2
				#stop
			)
		)
	)
)


/*
  .steps : integer
  .render_renderable(renderable) : boolean
  .render_mapcoords(mapcoords) : boolean
  .render_viewport_thickness(viewport_thickness) : float
  .render_viewport_sides(viewport_sides) : integer
  .render_viewport_angle(viewport_angle) : float
  .render_displayRenderMesh(displayRenderMesh) : boolean
  .render_useViewportSettings(useViewportSettings) : boolean
  .render_displayRenderSettings(displayRenderSettings) : boolean
  .thickness : float
  .sides : integer
  .angle : float
  .optimize : boolean
  .adaptive : boolean
  .render_viewport_length : float
  .render_viewport_width : float
  .render_viewport_angle2 : float
  .render_rectangular : boolean
  .render_viewport_rectangular : boolean
  .render_aspect_locked : boolean
  .render_viewport_aspect_locked : boolean
  .render_auto_smooth : boolean
  .realWorldMapSize : boolean
  .render_thickness
  .render_sides
  .render_angle
  .render_width
  .render_length
  .render_angle2
  .render_threshold
*/