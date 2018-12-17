plugin simpleManipulator TestRotateManip 
name:"TestRotate" 
invisible:true
(
local g = [0, 0, 1], r = [1, 1, 0] 
local curNode = selection[1] 
local initLen = 0; 
local oldProj = [0,0,0]
local gizSize = (try(curNode.max.z - curNode.min.z)catch(5))
 
on canManipulate target return (try($.isselected)catch(false)) 
on updateGizmos do 
(
this.clearGizmos()
giz = manip.makeCircle [0,0,0] gizSize 6
--giz = manip.makeTorus [0,0,0] 20 1 6 6 
-- Add the circle to the manipulator 
this.addGizmoShape giz gizmoActiveViewportOnly g r 
--this.addGizmoMesh ($ESkel_Master.mesh) 0 g r 
--print gizSize;
)
 
 
on mouseMove m which do 
(
	 local pl = manip.makePlaneFromNormal z_axis [0, 0, 0], 
	 projectedPoint = [0,0,0]
 
	 -- Compute the hit-ray in local coordinates 
	 viewRay = this.getLocalViewRay m
	 -- Intersect the plane with the view ray 
	 res = pl.intersect viewRay &projectedPoint
 
	 difProj = oldProj - projectedPoint ------ this is where I am stuck
	 len = distance difProj oldProj	 -------
 
	 --angleee = acos(dot (normalize [0,0,0]) (normalize projectedPoint))
 
	 if (res) then 
	 (
		 if len > initLen then 
		 (
			 in coordsys local rotate node (angleaxis (node.rotation.z + \
			 (length projectedPoint)/10) [0,0,1]) 
		 )
		 else in coordsys local rotate node (angleaxis (node.rotation.z - (length \
		 projectedPoint)/10) [0,0,1]) 
 
		initLen = len
	 )
oldProj = projectedPoint 
)
)