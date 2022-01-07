-- Contour_Creator-v1.2c.ms
-- from cross_section-v2_1.ms
-- for Max 3.1
-- Creates contour lines of an object with controls for start, stop and spacing.
-- Uses the section command to get a cross-section from an object 
-- Adds these sections and welds the many open vertices left over from section to form one spline.
-- Thanks to Swami* for solving a problem I encountered with welding the vertices and sorting the vertices.
-- Rab Gordon -- Rainnea Graphics -- http://development.rainnea.com -- rab@rainnea.com
	--------------------------------------------------------------------------------------------
	if Dist_from_top==undefined then global Dist_from_top= 1		
	if Dist_from_base==undefined then global Dist_from_base= 1
	if Spacing==undefined then global Spacing= 10
	if Fuse_n_Weld_threshold == undefined then global Fuse_n_Weld_threshold= 1
	-------------------------------------------------------
	function make_contour_lines=
	try(
	global non_contour_obj = #()
	global contour_obj = #()
	global contour_lines_array = #()

	for viz_obj= 1 to selection.count do contour_obj[viz_obj] = selection[viz_obj]
	max select invert
	for hide_objs = 1 to selection.count do non_contour_obj[hide_objs] = selection[hide_objs]
	hide selection
	select (contour_obj)
	contour_lines = splineShape prefix: "Contour"
	minZ = (selection.min.z) + Dist_from_base 
	maxZ = (selection.max.z) - Dist_from_top  

		for currentZ = maxZ to minZ by -Spacing do -- start loop... 
		( 
		s = section pos:[0, 0, currentZ] -- create Section 
		max views redraw 
		tmp_shape=convertToSplineShape s -- convert Section to SplineShape 
		append contour_lines_array tmp_shape
		) 
		
	unhide non_contour_obj
	) catch ()

	------------------------------------------------------------------------------------------------------------------
	function attach_splines =
	(	disableSceneRedraw()
		tmp_shape = splineShape prefix:"Attached_Splines"; tmp_shape.wirecolor=random black white 
		for i = 1 to contour_lines_array.count do
		( 	spline_to_attach=contour_lines_array[i]
			for pns = 1 to numSplines spline_to_attach do
				(	tmp_spline = addNewSpline tmp_shape
					for pnk = 1 to numknots spline_to_attach pns do															
					(	knot_pos1=getknotpoint  spline_to_attach pns pnk
						addknot tmp_shape tmp_spline #corner #line knot_pos1
						if pnk==nk and isClosed spline_to_attach pns then close tmp_shape tmp_spline
					)-- number knots
				)-- number splines
								
		)
		updateshape tmp_shape; select tmp_shape
		delete contour_lines_array
		enableSceneRedraw(); redrawViews()
		
	)												
												
	---------------------------------------------------------------------------------------------------------------
	----- functions from Fuse n' Weld
	---------------------------------------------------------------------------------------------------------------
	function create_vertex_array =  --creates a vertex array from selected shape
	( 
	global vertex_array= #(#(),#(),#())
		ns=numsplines tmp_shape
		for pns= 1 to ns do
				(	nk= numknots tmp_shape pns
							for pnk=1 to nk do
							(		vertex_pos1=getknotpoint tmp_shape pns pnk
									append vertex_array [1]pns
									append vertex_array [2]pnk
									append vertex_array [3]vertex_pos1
							)
				)
	)

	--------------------------------------------------------------------------------------------------------------------

	function closest_vertex=		--	creates an array of closest vertices -- based on a Swami Script
	(
	global closest_vertex_array=#(#(),#(),#())
	global vc=vertex_array[1].count
	global a, b, dist_1, dist_min
		for a = 1 to vc do
			( pos_1= vertex_array[3][a]
				global dist_min = 1e+38
				for b= 1 to vc do
				(								--compare vertex 'a' with every other vertex 'b'
				pos_2= vertex_array[3][b]
					dist_1= distance pos_1 pos_2
						if dist_1 > 0 and dist_1 < dist_min and dist_1 < Fuse_n_Weld_threshold then
						( 	dist_min=dist_1 
							closest_vertex_array[1][a]=a		--vertex 'a' index number
							closest_vertex_array[2][a]=b		--vertex 'b' index number
							closest_vertex_array[3][a]=dist_min --distance from a to b
						)
				)
			 		
			)
	)
	----------------------------------------------------------------------------------------------------------
	function check_vertices=			-- checks that there isn't another vertex closer
	for c= 1 to closest_vertex_array[1].count do 
	(	if (closest_vertex_array[3][c]) != undefined and (closest_vertex_array[3][c]) < Fuse_n_Weld_threshold then --- just processes relevant vertices
		(	dd= (closest_vertex_array[2][c])		
			if (closest_vertex_array[3][c]) > (closest_vertex_array[3][dd]) then closest_vertex_array[3][c]= 0.0
		)
	)
	------------------------------------------------------------------------------------------------------------------
	function fuse_vertices=			-- moves a vertex and its closest neighbour to the average position of the pair
	(
	for ii=1 to vc do
		( 
			if (closest_vertex_array[3][ii]) != undefined and (closest_vertex_array[3][ii]) > 0 and (closest_vertex_array[3][ii]) < Fuse_n_Weld_threshold then 
			(
			ave_pos = ((vertex_array [3][ii]) + (vertex_array [3][(closest_vertex_array[2][ii])]))/2
			setknotpoint tmp_shape vertex_array[1][ii] vertex_array[2][ii] ave_pos
			updateshape tmp_shape
			)
		)
	)
	------------------------------------------------------------------------------------------------------------------
	function weld_vertices=
	(	
			setCommandPanelTaskMode mode:#modify
			subObjectLevel = 1
			max select all
			updateshape tmp_shape
			splineOps.weld tmp_shape
			subObjectLevel = 0	
			updateshape tmp_shape
	)

	---------------------- Floater -----------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	contour_Spline_Floater rollout contour_spline_rollout "Contour Creator"
	(
	
	Spinner s_Dist_from_top			"Start dist. from top   "	range:[0,1000,Dist_from_top]  	fieldwidth:35 type:#Float offset:[9,0]
	Spinner s_Dist_from_base		"Stop dist. from base"   	range:[0,1000,Dist_from_base]  	fieldwidth:35 type:#Float offset:[9,0]
	Spinner s_Spacing			"Contour Spacing "    		range:[1,1000,Spacing] 		fieldwidth:35 type:#Float offset:[9,0]
		
	on s_Dist_from_top			changed val do ( Dist_from_top= val )		
	on s_Dist_from_base       		changed val do ( Dist_from_base= val )
	on s_Spacing			        changed val do ( Spacing= val )


	Button  	b_contour		"Contour Selected Mesh/s" 	width:142 height:20 offset:[0,-2]
	Checkbox	c_attach		"Weld all Contours ?"  		checked:False 
		
	Spinner s_Fuse_n_Weld_threshold		"Threshold "    	range:[0,1000,Fuse_n_Weld_threshold] fieldwidth:35 type:#Float offset:[9,-3]
		
	on s_Fuse_n_Weld_threshold		changed val do ( Fuse_n_Weld_threshold= val )		
		
	on b_contour	pressed do 
						(	startTime=timeStamp()
							setWaitCursor()
							make_contour_lines()
							if c_attach.checked then 
							(
							attach_splines()
							create_vertex_array()
							closest_vertex()
							check_vertices()
							fuse_vertices()
							weld_vertices()
							) else 
							(set1= selectionsets ["Contour_Lines"+contour_obj[1].name] = contour_lines_array; select set1)
							
							endTime=timeStamp()
							dt=(endTime-startTime)/1000.
							format "Processing Time: % seconds\n" dt
						)
		)
	-------------------------------------------------------------------------------------------------------------
	 	if contour_Spline_Floater != undefined then (closerolloutfloater contour_Spline_Floater)
		contour_Spline_Floater = newrolloutfloater "Contour Creator" 180 193
	 	addrollout contour_Spline_rollout contour_Spline_Floater

