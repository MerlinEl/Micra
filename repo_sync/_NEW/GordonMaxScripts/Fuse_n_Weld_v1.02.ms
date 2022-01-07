	--  Fuse n' Weld v1.02
	--  for MAX 3.1
	--  Takes all vertices in a shape, compares them to their closest neighbour 
    	--  and moves them to an average position if within the threshold.
    	--  Fuse; moves only,
	--  Weld; moves and welds.
        --  If many vertices are within the threshold, it only operates on the closest 
        --  so it may be nesseccary to run the script a couple of times.
        --  If multiple shapes are selected then all shapes are combined.
        --  Detach All Splines; dissolves a shape or shapes into it's component splines.
	--  Thanks to Swami Lama for his help in writing this and other scripts.
	--  Rab Gordon -- Rainnea Graphics -- http://development.rainnea.com -- rab@rainnea.com

	---------------------------------------------------------------------------------------------------------------
	
	if Fuse_n_Weld_threshold == undefined then global Fuse_n_Weld_threshold=5
	if prefix_no == undefined then global prefix_no=1
	---------------------------------------------------------------------------------------------------------------
	function create_vertex_array =  --creates a vertex array from selected shape
	( 
	global vertex_array= #(#(),#(),#())
		ns=numsplines sel
		for pns= 1 to ns do
				(	nk= numknots sel pns
							for pnk=1 to nk do
							(		vertex_pos1=getknotpoint sel pns pnk
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
			setknotpoint sel vertex_array[1][ii] vertex_array[2][ii] ave_pos
			updateshape sel
			)
		)
	)
	------------------------------------------------------------------------------------------------------------------
	function weld_vertices=
	(	
			setCommandPanelTaskMode mode:#modify
			subObjectLevel = 1
			max select all
			updateshape sel
			splineOps.weld sel
			subObjectLevel = 0	
			updateshape sel
	)
	------------------------------------------------------------------------------------------------------------------
	function attach_splines =
	(	disableSceneRedraw()
		Shapes_to_Process = selection as array
		tmp_shape = splineShape prefix: "F n' W "
		for i = 1 to Shapes_to_Process.count do
		( 	spline_to_attach = Shapes_to_Process[i]
			if spline_to_attach.category != #shape then spline_to_attach = copy spline_to_attach; converttosplineshape spline_to_attach
			for pns = 1 to numSplines spline_to_attach do
				(	tmp_spline = addNewSpline tmp_shape
					nk = numknots spline_to_attach pns 
					for pnk = 1 to nk do															
					(	knot_pos1=getknotpoint  spline_to_attach pns pnk
						in_vec_pos1=getInVec  	spline_to_attach pns pnk
						out_vec_pos1=getOutvec  spline_to_attach pns pnk			
						addknot tmp_shape tmp_spline #beziercorner #curve knot_pos1 in_vec_pos1 out_vec_pos1
						if pnk==nk and isClosed spline_to_attach pns then close tmp_shape tmp_spline
					)-- number knots
				)-- number splines
			delete spline_to_attach
		)-- selection count
		updateshape tmp_shape; select tmp_shape
		sel= tmp_shape
		enableSceneRedraw(); redrawViews()		
	)												
	------------------------------------------------------------------------------------------------------------------
	
	function detach_splines=  ----Splits shape into its component splines
	(	Shapes_to_Process = selection as array
		Detached_Splines = #()
	for i = 1 to Shapes_to_Process.count do
		(
		Original_shape=Shapes_to_Process[i]
		if Original_shape.category != #shape then Converttosplineshape Original_shape				
	
		for pns = 1 to numSplines Original_shape do																
		(			tmp_shape = splineShape name:("Detached_Spline"+ pns as string); tmp_shape.adaptive=true; tmp_shape.wirecolor=random black white 
					tmp_spline = addNewSpline tmp_shape
					nk = numknots Original_shape pns 											

			for pnk = 1 to nk do															
				(				
					knot_pos1=getknotpoint  Original_shape pns pnk
					in_vec_pos1=getInVec  	Original_shape pns pnk
					out_vec_pos1=getOutvec  Original_shape pns pnk		
					addknot tmp_shape tmp_spline #beziercorner #curve knot_pos1 in_vec_pos1 out_vec_pos1
					if pnk==nk and isClosed Original_shape pns then close tmp_shape 1
					
				)-- number knots in spline
				updateshape tmp_shape
				append Detached_Splines tmp_shape
								
		)-- number splines in shape
		delete Original_shape
		)-- selection count
 		set1= selectionsets ["Detached_Splines" + prefix_no as string ] = Detached_Splines; prefix_no+=1
	)
	
	
	---------------------- Floater -----------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	Fuse_n_Weld_Floater rollout Fuse_n_Weld_rollout "Fuse n' Weld" (
	
		Button  b_Fuse						"Fuse"      width:52 height:18 offset:[-27,-5]
		Button  b_Weld						"Weld"      width:52 height:18 offset:[27,-23]
		
		Spinner s_Fuse_n_Weld_threshold		"Threshold "range:[0,1000,Fuse_n_Weld_threshold] fieldwidth:35 type:#Float offset:[10,0]
		
		Button  b_Detach					"Detach All Splines"      width:105 height:22
		
		on s_Fuse_n_Weld_threshold			changed val do ( Fuse_n_Weld_threshold= val )		

		on b_Fuse pressed do
		(			setWaitCursor()
				try (
					if selection.count > 1 then attach_splines()else \
					(sel = selection[1]; if sel.category != #shape then converttosplineshape sel )
					create_vertex_array()
					closest_vertex()
					check_vertices()
					fuse_vertices()
					) catch ( enableSceneRedraw(); redrawViews() )
		)

		on b_Weld pressed do
		(			setWaitCursor()
				try (
					if selection.count > 1 then attach_splines()else \
					(sel = selection[1]; if sel.category != #shape then converttosplineshape sel )
					create_vertex_array()
					closest_vertex()
					check_vertices()
					fuse_vertices()
					weld_vertices()
					) catch ( enableSceneRedraw(); redrawViews() )
		)							
		
		on b_Detach pressed do 
		(			setWaitCursor()
				try (
					detach_splines()
					) catch ( enableSceneRedraw(); redrawViews() )
		)
	)
	-------------------------------------------------------------------------------------------------------------
	 	if Fuse_n_Weld_Floater != undefined then (closerolloutfloater Fuse_n_Weld_Floater)
		Fuse_n_Weld_Floater = newrolloutfloater "Fuse_n_Weld" 135 135
	 	addrollout Fuse_n_Weld_rollout Fuse_n_Weld_Floater
		