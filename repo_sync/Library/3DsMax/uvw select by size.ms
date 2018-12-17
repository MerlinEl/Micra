--select uvw by size
--select all elements with seme size + treeshold


fn getElements gco faces_array =
(
	struct ELEMENTS (faces=#{}, area=0)
	local el = #()
	while faces_array.count != 0 do --or not keyboard.controlPressed 
	(
		local next_face = faces_array[1]
		gco.selectFaces #{next_face}
		gco.selectElement()
		local el_faces = gco.getSelectedFaces()
		local areaUVW
		gco.getArea el_faces &x &y &width &height &areaUVW &areaGeom 
		el += #(ELEMENTS el_faces areaUVW) 
		faces_array = (faces_array as bitarray - el_faces) as array --remove faces from array
	)
	return el
)
fn selectUVWElementsBySize treeshold:0.5 =
(
	local gco = modpanel.getcurrentobject()	
	gco.selectElement()
	case gco.getTVSubObjectMode() of
	(
		1:(gco.vertToFaceSelect())
		2:(gco.edgeToFaceSelect())
		3:()
	)
	gco.setTVSubObjectMode 3 --set level to faces
	local first_element  = gco.getSelectedFaces()
	local areaUVW
	gco.getArea first_element &x &y &width &height &areaUVW &areaGeom 
	--gco.getAreaByNode first_element &areaUVW &areaGeom  $
	max select all
	local all_faces = gco.getSelectedFaces() 
	all_faces -= first_element --remove first element
	--circle trough all faces to make elements
	local all_elements = getElements gco (all_faces as array)
	--filter only elements with treeshold
	local chosen_faces = #{}
	format "elements found:%\n" all_elements.count
	format "first element area:%\n" areaUVW
	for a in all_elements where (a.area >=  areaUVW - areaUVW/treeshold) and (a.area <= areaUVW + areaUVW/treeshold) do --min max
	(
		chosen_faces += a.faces
	)
	--select faces in treeshold
	format "faces found in treeshold:%\t count:%\n" treeshold chosen_faces.numberset
	if chosen_faces.numberset != 0 do (gco.selectFaces chosen_faces)
)

selectUVWElementsBySize treeshold:.5


/*
.selectOverlappedFaces()
--gco.getSelectedGeomVerts()
*/

/*
fn getAreaFromFacePoints points_array =
(
	local area = 0
	for p=1 to points_array.count do
	(
		local self = points_array[ p ]
		local next = points_array[ if p != points_array.count then p+1 else 1]
		area += ( ( self.x * next.y ) - ( next.x * self.y ) )
	)
	return (abs area)
)
fn getUVWFaceArea face =
(
	local verts_count = ( gco.numberPointsInFace face )
	local face_verts = for v = 1 to verts_count collect gco.getVertexIndexFromFace face v
	local vert_pos =  for v in face_verts collect gco.getVertexPosition 0 v 
	local face_uv_area = getAreaFromFacePoints vert_pos -- Add up each UV face area for this element.
	return (face_uv_area *= 0.5)
) --thanks to Paul Greveson
fn getElementArea faces =
(
	element_uv_area = 0
	for f in faces do element_uv_area += getUVWFaceArea f
	return element_uv_area
)
*/


