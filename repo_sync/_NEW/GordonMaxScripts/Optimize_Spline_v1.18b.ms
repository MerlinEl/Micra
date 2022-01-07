	-- Optimize Spline Utility ver 1.18b
	-- 03/10/00  -- MAX3.1
	-- This script is designed to adaptively remove points from a curve
	-- while retaining the shape's existing curvature
	-- Thanks to Swami Lama for suggestions on changes to this script and help with getting to grips with MAXScript
	-- Thanks to Doug McNabb for advice and encouragement to get started scripting in the first place
	-- Rab Gordon -- Rainnea Graphics -- http://development.rainnea.com -- rab@rainnea.com
	
	-------------------------------------------------------------
	clearlistener()
	if max_ratio == undefined then max_ratio= 10
	if min_seg_length == undefined then min_seg_length= 5
	if nth_seg == undefined then nth_seg= 1
	global knots_before_optimization 
	global knots_after_optimization
	global Optimized_shape
------------------------------------------------------------------
------------------------------------------------------------------ 
	
	function Optimize_spline =
	--try
	(
	Optimized_shape = copy selection[1] prefix: ("Optimized_" + (selection[1].name as string))-- make a copy of shape
	knots_before_optimization = numknots Optimized_shape										-- get number of knots in shape
	if classof Optimized_shape != splineshape then Converttosplineshape Optimized_shape					-- and convert to a spline
	ns= numsplines Optimized_shape																-- get number of splines in shape
	global Knots_To_Delete=#()																	-- create an array of knots to be deleted
	
		for pns = 1 to ns do																-- number of splines in shape
		(	vx0=0
			nk = numknots Optimized_shape pns 												-- number of knots in selected spline
	--		if isclosed Optimized_shape pns then (nk+=1)									-- if shape is closed then compensate
			for pnk = 1 to nk-2 do															-- number knots in spline by stepover
				(
					vx0+=1
					vx1=vx0+1
					vx2=vx0+2
					vx3=vx0+3
				--	format "n: %\n" vx1
				
		if vx3 <= nk then
			(
			knot_pos1=getknotpoint  Optimized_shape pns vx0
			knot_pos2=getknotpoint  Optimized_shape pns vx1
			knot_pos3=getknotpoint  Optimized_shape pns vx2		
			in_vec_pos1=getInVec  	Optimized_shape pns vx0
			out_vec_pos1=getOutvec  Optimized_shape pns vx0
			in_vec_pos2=getInVec  	Optimized_shape pns vx1
			out_vec_pos2=getOutvec  Optimized_shape pns vx1
			in_vec_pos3=getInVec  	Optimized_shape pns vx2
			out_vec_pos3=getOutvec  Optimized_shape pns vx2
			knot_pos4=getknotpoint  Optimized_shape pns vx3		
			in_vec_pos4=getInVec  	Optimized_shape pns vx3
			out_vec_pos4=getOutvec  Optimized_shape pns vx3
						
		
			tmp_shape = splineShape name:"Tmp_Shape"  
			tmp_spline = addNewSpline tmp_shape		
			addknot tmp_shape tmp_spline #beziercorner #curve knot_pos1 in_vec_pos1 out_vec_pos1
			addknot tmp_shape tmp_spline #beziercorner #curve knot_pos2 in_vec_pos2 out_vec_pos2
			addknot tmp_shape tmp_spline #beziercorner #curve knot_pos3 in_vec_pos3 out_vec_pos3
			c1_before=curvelength tmp_shape
			deleteKnot tmp_shape tmp_spline 2
			c1_after=curvelength tmp_shape
			delete tmp_shape
		--	format "c1_before: %\n"c1_before
		--	format "c1_after: %\n"c1_after
		
			tmp_shape = splineShape name:"Tmp_Shape"  
			tmp_spline = addNewSpline tmp_shape		
			addknot tmp_shape tmp_spline #beziercorner #curve knot_pos2 in_vec_pos2 out_vec_pos2
			addknot tmp_shape tmp_spline #beziercorner #curve knot_pos3 in_vec_pos3 out_vec_pos3
			addknot tmp_shape tmp_spline #beziercorner #curve knot_pos4 in_vec_pos4 out_vec_pos4
			c2_before=curvelength tmp_shape
			deleteKnot tmp_shape tmp_spline 2
			c2_after=curvelength tmp_shape
			delete tmp_shape
		--	format "c2_before: %\n"c2_before
		--	format "c2_after: %\n"c2_after	
			
		
			ratio1=(100-((c1_after/c1_before)*100))*100
		--	format "ratio1: %\%\n" ratio1
		--	ratio2=(1/(c2_before/c2_after))
		--	format "ratio2: %\%\n" ratio2
		--	ratio3= ratio1+ratio2
		--	format "ratio3: %\n" ratio3
			ratio4= (ratio1*((c2_before/c2_after)/1))+ratio1
		--	format "ratio4: %\n" ratio4


		-- ratio1 could be used instead of ratio4 but I was trying to make allowances for when many vertexs make up a slow curve
		-- ratio4 looks ahead one vertex and skews ratio1, I'll probably work on this some more or leave it out to speed things up  
			if (ratio4<max_ratio and ((vx1/nth_seg as float) == (vx1/nth_seg))) or \
			 (((c1_before/2) < min_seg_length) and ((vx1/nth_seg as float) == (vx1/nth_seg))) \
				then append Knots_To_Delete vx1
		)								
		)-- number knots in spline	
					---- delete knots in array as determined above
					v=0									
					for t = 0 to (Knots_To_Delete.count)-1 do
					(
					t+=1
					Knot_to_go= ( Knots_To_Delete [t] ) - v
					deleteKnot Optimized_shape pns Knot_to_go
					v+=1
					)
				--	format "ARRAY:% \n" Knots_To_Delete

					Knots_To_Delete=#()  	-- reset array
				
		)-- number splines in shape 
	try (updateshape tmp_shape) catch()
	try (updateshape Optimized_shape) catch ()
	select Optimized_shape
	knots_after_optimization = numknots Optimized_shape					-- get new number of knots in shape after optimization
	)
	--catch()
	------------------------------------------------------------------------------------------------------------
	-----------------------roundoff to 2 decimal places---------------------
	function roundoff var= ((((((var*100) + 0.5)as integer) /100 as float) ) as string)
	
	------------------------------------------------------------------------------------------------------------
	---------------------- Floater -----------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	Optimize_Spline_Floater rollout Optimize_spline_rollout "Optimize Spline" (
	
		Button  b_Optimize				"Optimize Selected"      width:108 height:17
	    Spinner s_nth_seg				"Nth Vertex"		 		range:[1,10,nth_seg]  fieldwidth:42 type:#integer 	
		Spinner s_min_seg_length		"Min Seg. Length"   	range:[0,1000,min_seg_length]  fieldwidth:42 type:#Float
		Spinner s_threshold				"Threshold"    			range:[0,1000,max_ratio] fieldwidth:42 type:#Float
		
		on s_threshold					changed val do ( max_ratio= val )		
	    on s_min_seg_length        		changed val do ( min_seg_length= val )
	    on s_nth_seg	        		changed val do ( nth_seg= val )

group""(
		Label l_dis 	""align:#centre
		Label l_header 	""align:#centre
		Label l_nverts 	""align:#left
		)
		
		on b_Optimize pressed do
		(
			if selection.count != 1 or superclassof selection[1] != shape then messagebox "Please choose one shape \n or spline to optimize" else
			(
			( Optimize_spline())
			l_dis.text= 	(Optimized_shape.name as string)
			l_header.text= 	"   Before / After"					
			l_nverts.text= 	"Vertices: " +  (knots_before_optimization as string) + " / " +( knots_after_optimization as string)
			)
		)							

		
	)
	-------------------------------------------------------------------------------------------------------------
	 	if Optimize_Spline_Floater != undefined then (closerolloutfloater Optimize_Spline_Floater)
		Optimize_Spline_Floater = newrolloutfloater "Optimize Spline" 175 233
	 	addrollout Optimize_Spline_rollout Optimize_Spline_Floater