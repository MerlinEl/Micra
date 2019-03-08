plugin simpleManipulator Eye_Gizmo
name:"Eye Gizmo"
invisible:true
classID:#(0x47294766, 0x7c49a8b6) --genClassID()
( 
	--******************************************************************************************
	--Events
	--******************************************************************************************
	on canManipulateNode n do
	(
		--If node is geometry or helper...
		if (Superclassof n == GeometryClass) or (Superclassof n == helper) then (true)
	) 

	on updateGizmos do 
	( 
			local giz
			local thisNode = node 
		( 
			this.clearGizmos() 

			nodeTM = matrix3 1 
			--Reverse any scewing caused by scale (if any)
			preScale nodeTM (inverse (scaleMatrix thisNode.scale)).scalepart
			--Rotate eyes to look up
			rotateX nodeTM 90

			giz = manip.makeGizmoShape()

			this.addGizmoShape giz 0  white yellow

			------------------------------------------------------------------------------------------------------------------
			--/////////////////////////////////////////////////////////////////////////////////////////////
			--EYES--------------------------------------------------------------------------------------------------------
			fn makeEye eye2 eClr obj m =
			(
				radius = 10
				eyeDistance = 30
				eyeMatrix = ( -- Separate transform offsets for left/right eyes
				
					if (eye2 == true) then (
						
						matrix3 1
						
					) else (
					
						matrix3 1
					)
				)

				fn drawCircle tm g =
				( --Function for building gizmo lines circles with a given radius
					
					thePoint = [0,0,0]
					axis = [1,0,0]
					em = 1
				
					divs = 30
					g.addPoint (thePoint * em)
					for i=1 to divs do
					(
						thePoint = thePoint * ((angleaxis (360/divs) axis) as quat)
						g.addPoint (thePoint * em)
					)
					g.startNewLine()
				)

				gizTmp = manip.makeGizmoShape()

				drawCircle   eyeMatrix gizTmp
				drawCircle   eyeMatrix gizTmp
				drawCircle   eyeMatrix gizTmp
				drawCircle   eyeMatrix gizTmp --iris
				drawCircle   eyeMatrix gizTmp --pupil

				--Apply transform to the given eye shape
				gizTmp.transform m
				--Add new eye shape to gizmo
				this.addGizmoShape gizTmp 2 eClr eClr
			)
			
			makeEye false red thisNode nodeTM --Left eye
			makeEye true green thisNode nodeTM --Right eye
		)
	)
)
manipulateMode = on