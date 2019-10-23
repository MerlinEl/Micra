fn getEdgeLength obj edge_index = (

	local everts = (polyop.getEdgeVerts obj edge_index) as array
	local p1 = polyop.getVert obj everts[1]
	local p2 = polyop.getVert obj everts[2]	
	distance p1 p2
)

fn getLongestEdge obj edges = (

	local longest_edge = (edges as array)[1]
	local longest_len = getEdgeLength obj longest_edge
	for ei in edges do (

		local len  = getEdgeLength obj ei
		if longest_len < len do (

			longest_edge = ei
			longest_len = len
		)
	) 
	longest_edge
)

fn twoPointSlicePlane obj p1 p2 size:10 = if iskindof obj editable_poly do
(
	local dir = normalize (p2 - p1)
	local center = (p1 + p2) / 2 
	polyop.setSlicePlane obj (ray center (dir * obj.objectoffsetrot)) size
	update obj
)

fn slicePlaneToEdge = (

	local obj=selection[1]
	if classof obj != Editable_poly do return false
	local esel = #{}
	local allow_progress = false
	if subobjectlevel == 4 or subobjectlevel == 5 then (

		local fsel = polyop.getFaceSelection obj
		if fsel.numberset == 0 do return false 
		esel = polyop.getEdgesUsingFace obj fsel
		allow_progress = true

	) else if subobjectlevel == 2 do (

		esel = polyop.getEdgeSelection obj
		allow_progress = true
	) 
	if not allow_progress or esel.numberset == 0 do return false
	local longest_edge = getLongestEdge obj esel
	if not (polyop.inSlicePlaneMode obj) do (obj.toggleCommandMode #SlicePlane) --enable sliceplane mode
	local everts = (polyop.getEdgeVerts obj longest_edge) as array
	local p1 = polyop.getVert obj everts[1]
	local p2 = polyop.getVert obj everts[2]
	twoPointSlicePlane obj p1 p2 size:(distance p1 p2)
)
undo "SlicePlane2" on slicePlaneToEdge()