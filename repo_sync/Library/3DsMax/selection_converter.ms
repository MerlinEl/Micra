rollout selectionconverter "sel converter"
(
	button face_vert "face_vert" width:150
	button face_edge " face_edge"width:150
	button edge_vert "edge_vert"width:150
	button edge_face "edge_face"width:150
	button vert_face "vert_face"width:150
	button vert_edge "vert_edge"width:150
	on face_vert pressed do
	(
		case of
		(
		(classof $ == editable_poly):(faces = getfaceselection $
		vert_sel = polyop.getvertsusingface $ faces
		polyop.setvertselection $ vert_sel
		subobjectlevel = 1)
		(classof $ == editable_mesh):(faces = getfaceselection $
		vert_sel = meshop.getvertsusingface $ faces
		setvertselection $ vert_sel
		subobjectlevel = 1)
		)
	)
	on face_edge pressed do
	(
		case of
		(
		(classof $ == editable_poly):(faces = getfaceselection $
		edge_sel = polyop.getedgesusingface $ faces
		polyop.setedgeselection $ edge_sel
		subobjectlevel = 2 )
		(classof $ == editable_mesh):(faces = getfaceselection $
		edge_sel = meshop.getedgesusingface $ faces
		setedgeselection $ edge_sel
		subobjectlevel = 2 )
		)
	)
	on edge_vert pressed do
	(
		case of
		(
		(classof $ == editable_poly):(edges = getedgeselection $
		vert_sel = polyop.getvertsusingedge $ edges
		polyop.setvertselection $ vert_sel
		subobjectlevel = 1)
		(classof $ == editable_mesh):(edges = getedgeselection $
		vert_sel = meshop.getvertsusingedge $ edges
		setvertselection $ vert_sel
		subobjectlevel = 1 )
		)
	)
	on edge_face pressed do
	(
	case of
	(
		(classof $ == editable_poly):( edges = getedgeselection $
		face_sel = polyop.getfacesusingedge $ edges
		polyop.setfaceselection $ face_sel
		subobjectlevel = 4)
		(classof $ == editable_mesh):(edges = getedgeselection $
		face_sel = meshop.getfacesusingedge $ edges
		setfaceselection $ face_sel
		subobjectlevel = 3)
		)
	)
	on vert_face pressed do
	(
		case of
		(
			(classof $ == editable_poly):(vert = getvertselection $
			face_sel = polyop.getfacesusingvert $ vert
			polyop.setfaceselection $ face_sel
			subobjectlevel = 4)
			(classof $ == editable_mesh):(vert = getvertselection $
			face_sel = meshop.getfacesusingvert $ vert
			setfaceselection $ face_sel
			subobjectlevel = 3)
		)
	)
	on vert_edge pressed do
	(
		case of
		(
			(classof $ == editable_poly):(vert = getvertselection $
			edge_sel = polyop.getedgesusingvert $ vert
			polyop.setedgeselection $ edge_sel
			subobjectlevel = 2)
			(classof $ == editable_mesh):(vert = getvertselection $
			edge_sel = meshop.getedgesusingvert $ vert
			setedgeselection $ edge_sel
			subobjectlevel = 2)
		)
	)
)
createdialog selectionconverter