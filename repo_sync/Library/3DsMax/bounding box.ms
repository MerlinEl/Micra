nodeGetBoundingBox <node> <matrix3>
nodeLocalBoundingBox <node>


(
      	local trgNode	= Teapot() -- The object to create a bounding box for
      	local refNode	= Box() -- The object to use as a reference
      
      	-- Get the reference node's transform matrix
      	local refTm = refNode.transform
      	
      	-- Move the matrix to the center of the target node
      	local refBb = nodeGetBoundingBox trgNode refTm
      	refTm.translation = (refBb[1] + ((refBb[2]-refBb[1]) / 2)) * refTm
      	
      	-- Get the target node's bounding box using this matrix
      	local bb = nodeGetBoundingBox trgNode refTm
      	local bbs = bb[2] - bb[1]
      	
      	-- Boxes are created with their pivots at the bottom,
      	-- so we need to compensate for that
      	preTranslate refTm [0, 0, bbs.z/-2]
      	
      	-- Create the bounding box!
      	box width:bbs[1] length:bbs[2] height:bbs[3] transform:refTm
      )
	  
	  
	  (
newdummy = dummy()
newdummy.name = uniquename("Bounding_Box_01")
Dummin = $.min
Dummax = $.max
Dumsize = Dummin - Dummax
dumsize.x = abs(dumsize.x)
dumsize.y = abs(dumsize.y)
dumsize.z = abs(dumsize.z)
newdummy.boxsize = dumsize
newdummy.pos = $.center
 
s = selection as array
for j in s do
(
 j.parent = newdummy
)
)