-- Soft Selection Manipulator
(
		if manipulateMode == off then 
		(
			manipulateMode = on
			selection[1].useSoftSel = on

			plugin simpleManipulator Poly_ssfalloffManip
			name:"Poly_SSFalloffManip"
			invisible:true
			(
				-- Create the green and red colors for the gizmo
				local g = [0,1,0]
				local r = [1,0,0]
				local b = [0,0,1]
				local y = [1,1,0]
				local a = black
				local GizPos
				-- This manipulator manipulates editable polys
				on canManipulate target do -- called at class level, can't access plugin local variables
				(	
					getCommandPanelTaskMode() == #modify and classof target == editable_poly
				)
				-- Create the manipulator gizmo.
				-- This is called initially and whenever the manipulator target changes
				on updateGizmos do
				(
					try
					(
						-- Clear the current gizmo cache
						this.clearGizmos()
						local size = target.falloff
						if target.useSoftSel and subobjectlevel > 0 then
						(	 
								
							local verts = case subObjectLevel of
							(
								1: polyop.getVertSelection  target
								2: polyop.getVertsUsingEdge target #selection
								4: polyop.getVertsUsingFace target #selection
							)
			
							GizPos = [0,0,0]
							for i in verts do (GizPos += polyop.getVert target i) -- local coord space
							GizPos /= verts.numberSet
			
							local giz1 = manip.makecircle [0,0,0] size 24 
							local my_tm = matrixFromNormal [0,1,0]
							my_tm.position = GizPos
							giz1.transform my_tm
			
							local giz2 = manip.makecircle gizpos size 24
			
							local giz3 = manip.makecircle [0,0,0] size 24
							my_tm = matrixfromnormal [1,0,0]
							my_tm.position = GizPos
							giz3.transform my_tm
			
							-- Add the circle to the manipulator
							this.addGizmoShape giz1 0 a r
							this.addGizmoShape giz2 0 a g
							this.addGizmoShape giz3 0 a b
			
							-- return the ToolTip string
							node.name + " SSel falloff = " + size as string 
						)
					)
					catch()
				)
			
				-- mouseMove is called on every mouse move when dragging the manip
				-- It needs to convert the mouse position 'm' into a new value for the falloff
				on mouseMove m which do
				(	try
					(	
						-- manip.makePlaneFromNormal takes a normal vector and a point
						-- and creates a plane passing through the point with the given normal
						local axis = case which of -- get axis based on which gizmo hit
						(	0:	y_axis
							1:	z_axis
							2:	x_axis
						)
						local pl = manip.makePlaneFromNormal axis GizPos
				
						-- Compute the hit-ray in local coordinates
						local viewRay = this.getLocalViewRay m
				
						-- Intersect the plane with the view ray
						local projectedPoint = [0,0,0]
						local res = pl.intersect viewRay &projectedPoint
			--			format "% : % : % : %\n" viewRay projectedPoint GizPos which 
						
						-- If the intersection worked, set the falloff
						if (res) then 
						( 	projectedPoint = GizPos - projectedPoint
							local size = sqrt(projectedPoint.x^2+ projectedPoint.y^2+ projectedPoint.z^2)
							target.falloff = size
						)
					)
					catch()
				)
			)
		)
		else (manipulateMode = off; selection[1].useSoftSel = off)
	)