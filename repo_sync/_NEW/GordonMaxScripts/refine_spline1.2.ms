	-- Refine Spline Utility ver 1.2
	-- 22/08/00  -- MAX3.1
	-- This script is designed to adaptively add extra points 
	-- to a shape while retaining the shape's existing points and curvature 
	-- Thanks to Doug McNabb and to Swami Lama for their advice and encouragement
	-- This version adds an info feature that gives usefull info on the shape and helps with setting values. 
	-- Still a bit crude and I need to tidy it up a bit yet.
	-- Rab Gordon -- Rainnea Graphics -- http://development.rainnea.com -- rab@rainnea.com
	
	-------------------------------------------------------------
	clearlistener()
	if Offset_Maximum == undefined then Offset_Maximum= 1
	if Number_of_Passes == undefined then Number_of_Passes= 3
	if min_seg_length == undefined then min_seg_length= 5
 	global selected_shape

------------------------------------------------------------------------------
------------------------------------------------------------------------------
	function get_info =										---- Get info about selected shape
	(
	
	selected_shape = selection[1]
	if selection[1] != splineshape then
					(tmpshape = copy selection[1]  
					converttosplineshape tmpshape)
					else tmpshape = copy selection[1]
	global n_vertices_spline	
	global total_n_splines_selected_shape=0					----total number of knots in selected shape
	global n_segs_selected_shape=0							----total number of segments in selected shape
	global ave_seg_length_selected_shape					----average segment length
	global min_seg_length_selected_shape=10000				----min segment length
	global max_seg_length_selected_shape=0					----max segment length
	global ave_offset_selected_shape=0 						----average offset
	global min_offset_selected_shape=10000					----min offset
	global max_offset_selected_shape=0						----max offset
	local curvelength_total=0								----total curvelength in selected shape
	local offset_total=0									----total offset
							
	ns = numsplines tmpshape
	for pns= 1 to ns do  									--- number splines in shape
						(
						nk = numknots tmpshape pns
						total_n_splines_selected_shape+=nk
						if isclosed tmpshape pns then (nk=nk+1)
						n_vertices_spline=0
			for pnk = 1 to nk-1 do							--- number knots in spline
							(
				n_vertices_spline+= 1			
				tmp_shape = splineShape name:"Tmp_Shape"  
				tmp_spline = addNewSpline tmp_shape		
				if n_vertices_spline < numknots tmpshape pns then
						(
						knot_pos1=getknotpoint  tmpshape pns n_vertices_spline
						knot_pos2=getknotpoint  tmpshape pns (n_vertices_spline+1)
						in_vec_pos1=getInVec  tmpshape pns n_vertices_spline
						out_vec_pos1=getOutvec  tmpshape pns n_vertices_spline
						in_vec_pos2=getInVec  tmpshape pns (n_vertices_spline+1)
						out_vec_pos2=getOutvec  tmpshape pns (n_vertices_spline+1)
						)
							else
							(
							knot_pos1=getknotpoint  tmpshape pns n_vertices_spline
							knot_pos2=getknotpoint  tmpshape pns 1
							in_vec_pos1=getInVec  tmpshape pns n_vertices_spline
							out_vec_pos1=getOutvec  tmpshape pns n_vertices_spline
							in_vec_pos2=getInVec  tmpshape pns 1
							out_vec_pos2=getOutvec  tmpshape pns 1
							)
				addknot tmp_shape tmp_spline #beziercorner #curve knot_pos1 in_vec_pos1 out_vec_pos1
				addknot tmp_shape tmp_spline #beziercorner #curve knot_pos2 in_vec_pos2 out_vec_pos2
				np1=nearestpathparam tmp_shape tmp_spline out_vec_pos1
				np2=nearestpathparam tmp_shape tmp_spline in_vec_pos2
				
				os1=length (out_vec_pos1 - pathinterp tmp_shape tmp_spline np1)
				os2=length (in_vec_pos2 - pathinterp tmp_shape tmp_spline np2)
				os3=curvelength tmp_shape 1
				delete tmp_shape
					n_segs_selected_shape+=1
					offset_total= offset_total + os1 + os2
					curvelength_total= curvelength_total+os3
					if os3 < min_seg_length_selected_shape then min_seg_length_selected_shape=os3
					if os3 > max_seg_length_selected_shape then max_seg_length_selected_shape=os3
					if os1 < min_offset_selected_shape then min_offset_selected_shape=os1
					if os2 < min_offset_selected_shape then min_offset_selected_shape=os2
					if os1 > max_offset_selected_shape then max_offset_selected_shape=os1
					if os2 > max_offset_selected_shape then max_offset_selected_shape=os2
					
							)
						)

	delete tmpshape
					ave_offset_selected_shape= (offset_total/(n_segs_selected_shape*2))
					ave_seg_length_selected_shape= curvelength_total/n_segs_selected_shape
				

	)
	-------------------------------------------------------------
------------------------------------------------------------------ 
------------------------------------------------------------------ 
------------------------------------------------------------------ 
	
	function refine_spline =
	--try
	(
	selected_shape = selection[1]
	global new_refined_shape
	global n_segs_refined_shape=0																---- total number of segments in refined shape
	new_refined_shape = copy selection[1] prefix: ("refined_" + (selected_shape.name as string))  ---- make a copy of shape
	Converttosplineshape new_refined_shape														---- and convert to a spline
	local ns= numsplines new_refined_shape
	
		
			for pns = 1 to ns do		--- number splines in shape
			(			
	
				for pass= 1 to Number_of_Passes do	--- number of passes
				(
				n_segs_refined_shape=0	---- number of knots in newly created spline
				nk = numknots new_refined_shape pns --- number of knots in selected spline
				if isclosed new_refined_shape pns then (nk=nk+1)
			
				for pnk = 1 to nk-1 do		--- number knots in spline
					(
					
					n_segs_refined_shape=n_segs_refined_shape+1
					tmp_shape = splineShape name:"Tmp_Shape"  
					tmp_spline = addNewSpline tmp_shape		
					if n_segs_refined_shape < numknots new_refined_shape pns then
							(
							knot_pos1=getknotpoint  new_refined_shape pns n_segs_refined_shape
							knot_pos2=getknotpoint  new_refined_shape pns (n_segs_refined_shape+1)
							in_vec_pos1=getInVec  new_refined_shape pns n_segs_refined_shape
							out_vec_pos1=getOutvec  new_refined_shape pns n_segs_refined_shape
							in_vec_pos2=getInVec  new_refined_shape pns (n_segs_refined_shape+1)
							out_vec_pos2=getOutvec  new_refined_shape pns (n_segs_refined_shape+1)
							)
								else
								(
								knot_pos1=getknotpoint  new_refined_shape pns n_segs_refined_shape
								knot_pos2=getknotpoint  new_refined_shape pns 1
								in_vec_pos1=getInVec  new_refined_shape pns n_segs_refined_shape
								out_vec_pos1=getOutvec  new_refined_shape pns n_segs_refined_shape
								in_vec_pos2=getInVec  new_refined_shape pns 1
								out_vec_pos2=getOutvec  new_refined_shape pns 1
								)
												addknot tmp_shape tmp_spline #beziercorner #curve knot_pos1 in_vec_pos1 out_vec_pos1
												addknot tmp_shape tmp_spline #beziercorner #curve knot_pos2 in_vec_pos2 out_vec_pos2
												np1=nearestpathparam tmp_shape tmp_spline out_vec_pos1
												np2=nearestpathparam tmp_shape tmp_spline in_vec_pos2
												
												os1=length (out_vec_pos1 - pathinterp tmp_shape tmp_spline np1)
												os2=length (in_vec_pos2 - pathinterp tmp_shape tmp_spline np2)
												os3=curvelength tmp_shape 1
												delete tmp_shape
												
												if (((os1 + os2)/2)>= Offset_Maximum) and (os3 >= min_seg_length)  then 
												(
												refineSegment new_refined_shape pns (n_segs_refined_shape) 0.5
												n_segs_refined_shape=n_segs_refined_shape+1
												)
												
					)	--- number knots in spline
				)	--- number of passes
			)--- number splines in shape 
	----try (updateshape) tmp_shape catch()
	updateshape new_refined_shape
	select new_refined_shape
	----subobjectLevel = 1
	)
	--catch()
	------------------------------------------------------------------------------------------------------------
	function roundoff var= ((((((var*100) + 0.5)as integer) /100 as float) ) as string)
	
	------------------------------------------------------------------------------------------------------------
	---------------------- Floater -----------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	Floater rollout Refine_spline_rollout "Refine Spline" (
---------------------------------Pick Shape and Analyse------------------------------------------------------- 
	
		PickButton 	p_pickshape			"Pick Shape to Refine"		width:120 height:17 tooltip: "Pick Shape"
		
		Label l_ps_header "Pick any Shape"
		Label l_ps_dis "to select and get info on it"
		Label l_ps_nverts "------------------------------------------"align:#left
		Label l_ps_n_segs_selected_shape "'Offset' is the distance from"align:#left
		Label l_ps_ave_seg_length_selected_shape "a Bezier Handle to the"align:#left
		Label l_ps_min_seg_length_selected_shape "closest point on the spline"align:#left
		Label l_ps_max_seg_length_selected_shape "segment that it controls."align:#left
		Label l_ps_ave_offset_selected_shape "Generally a large Offset"align:#left
		Label l_ps_min_offset_selected_shape "implies more curvature."align:#left
		Label l_ps_max_offset_selected_shape "Offset of zero is a corner." align:#left
	
		on p_pickshape picked ps do 
			(
			selected_shape = ps
			select selected_shape		
			l_ps_header.text= "ORIGINAL SHAPE:"
			l_ps_dis.text= (selected_shape.name as string)
			( get_info())				
			l_ps_nverts.text= 		"Total Vertices:   " + (total_n_splines_selected_shape as string)
			l_ps_n_segs_selected_shape.text= 		"Total Segments:   " + (n_segs_selected_shape as string)
			l_ps_ave_seg_length_selected_shape.text= 		"Ave Seg Length:  " + roundoff ave_seg_length_selected_shape						
			l_ps_min_seg_length_selected_shape.text= 		"Min Seg Length:  " + roundoff min_seg_length_selected_shape
			l_ps_max_seg_length_selected_shape.text= 		"Max Seg Length:  " + roundoff max_seg_length_selected_shape							
			l_ps_ave_offset_selected_shape.text= 	"Ave Offset:       " +	roundoff ave_offset_selected_shape						
			l_ps_min_offset_selected_shape.text= 	"Min Offset:       " + roundoff min_offset_selected_shape
			l_ps_max_offset_selected_shape.text= 	"Max Offset:       " +	roundoff max_offset_selected_shape						
			)
---------------------------------Refine Selected--------------------------------------------------------------------------------------	
	
	
		group""(
	    Spinner s_Number_of_Passes		"No. of Passes"   range:[1,10,Number_of_Passes]  fieldwidth:35 type:#integer    
	    Spinner s_min_seg_length		"Min Seg. Length" range:[0,1000,min_seg_length]  fieldwidth:35 type:#Float
		Spinner s_Offset_Maximum		"Maximum Offset"  range:[0,1000,Offset_Maximum] fieldwidth:35 type:#Float
				)
		on s_Offset_Maximum					changed val do ( Offset_Maximum= val )
		on s_Number_of_Passes			changed val do ( Number_of_Passes= val )
	    on s_min_seg_length        		changed val do ( min_seg_length= val )


		Button  b_Refine				"Refine Picked Shape" 		     width:120 height:17

		Label l_rs_header "'Refine' places one extra"
		Label l_rs_dis "Vertex per segment per pass and will"align:#left
		Label l_rs_nverts "provided it is longer than"align:#left
		Label l_rs_n_segs_refined_shape "'Min Seg Length' and its"align:#left
		Label l_rs_ave_seg_length_refined_shape "curvature is greater than is"align:#left
		Label l_rs_min_seg_length_refined_shape "set by 'Maximum Offset'"align:#left
		Label l_rs_max_seg_length_refined_shape "--------- by Rab Gordon --------"align:#left
		Label l_rs_ave_offset_refined_shape "       Rainnea Graphics"align:#left
		Label l_rs_min_offset_refined_shape "email: rab@rainnea.com"align:#left
		Label l_rs_max_offset_refined_shape "http://www.rainnea.com"align:#left
		
		on b_Refine	pressed do 
			(
			setWaitCursor()
			refine_spline()

			l_rs_header.text= "REFINED SHAPE:"
			l_rs_dis.text= (new_refined_shape.name as string)
			
			get_info()
			
			l_rs_nverts.text = "Total Vertices:" + (total_n_splines_selected_shape as string)
			l_rs_n_segs_refined_shape.text= 		"Total Segments:   " +(n_segs_selected_shape as string)
			l_rs_ave_seg_length_refined_shape.text= "Ave Seg Length:  " +roundoff  ave_seg_length_selected_shape						
			l_rs_min_seg_length_refined_shape.text= "Min Seg Length:  " +roundoff min_seg_length_selected_shape
			l_rs_max_seg_length_refined_shape.text= "Max Seg Length:  " +roundoff max_seg_length_selected_shape							
			l_rs_ave_offset_refined_shape.text= 	"Ave Offset:       " +roundoff ave_offset_selected_shape						
			l_rs_min_offset_refined_shape.text= 	"Min Offset:       " +roundoff min_offset_selected_shape
			l_rs_max_offset_refined_shape.text= 	"Max Offset:       " +roundoff max_offset_selected_shape						
			)							
		
	)
	-------------------------------------------------------------------------------------------------------------
	 if Floater != undefined then (closerolloutfloater Floater)
	 Floater = newrolloutfloater "Refine Spline" 175 561
	 addrollout Refine_Spline_rollout Floater