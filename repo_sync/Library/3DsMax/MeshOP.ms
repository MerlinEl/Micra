fn explodeEMesh mesh_obj =
(
	if classOf mesh_obj != Editable_Mesh do return false
	local fCount = meshop.getNumFaces mesh_obj
	max modify mode
	subObjectLevel = 4
	while fCount > 0 do
	( 
		local element = meshop.getElementsUsingFace mesh_obj 1
		if element.numberset == 0 do return ok
		local element_pos = [0,0,0]
		for i in element do element_pos += meshop.getFaceCenter mesh_obj i
		element_pos = element_pos/element.numberset
		local newMesh = meshop.detachFaces mesh_obj element delete:true asMesh:true  
		update mesh_obj
		local emesh = Editable_mesh pos:element_pos
		emesh.mesh = newMesh
		update emesh
		CenterObject emesh
		fCount = meshop.getNumFaces mesh_obj
	)
)

explodeEMesh $


--po=[0,0,0]
--(for i in selection do po+= i.pos)
--sphere pos:(po/selection.count)
--for i in selection do point pos:i.pos




	--setEdgeSelection $ #(6) 
	--meshOps.visibleEdge $
	--meshOps.invisibleEdge $
	--meshop.SetSelection
	
	--meshOps.unhideAll $
	--meshOps.hide $