--Spliting part of geometry and replace it with a primitive
--Calculate rotation/position in space from boundingbox of detached part geometry


fn insertReplaceFace type:#box mode:#insert =
(
	local obj = selection[1]
	if subObjectLevel != 4 or classOf obj != Editable_Poly do return false
	
	case type of
	(
		#box:()
		#sphere:()
		#cylinder:()
		#oiltank:()
		#chamferbox:()
	)

	--detach selected face
	local fsel = polyOp.getFaceSelection obj
	if fsel.numberset != 1 do return false
	local new_node_name = uniqueName obj.name
	polyOp.detachFaces obj fsel delete:true asNode:true name:new_node_name
	subObjectLevel = 0
	clearSelection()
	local new_node = getNodeByName new_node_name
	--center node pivot
	local fverts = polyOp.getVertsUsingFace obj fsel
	local vpos = [0,0,0]
	for v in fverts do vpos += polyOp.getVert obj v
	local ppos = vpos / fverts.numberset
	new_node.pivot  = ppos
	--get node local bounding box
	--replace node by
)

insertReplaceFace()