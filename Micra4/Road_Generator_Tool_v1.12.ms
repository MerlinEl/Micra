-------------------------
-->modyfy by MerlinEl 1.3.2019
-------------------------


--###################################################################################--
--	                               Custom Attributes                                 --
--###################################################################################--
Global gRoadGenCa = attributes RoadGenCa attribID:#(0x2949a7a0, 0x5246449a) ( --genClassID()

	parameters params(
		
		roadSpline 		type:#node
		startPoint		type:#node
		endPoint		type:#node
		controlsStr		type:#string
	)
)
-------------------------------------------------------------------------------------
Global gSplineGenCa = attributes SplineGenCa attribID:#(0x2d6fe027, 0x4236cbe9) ( ---- buuuuu

	parameters params(
	
		road 			type:#string
	)
)
-------------------------------------------------------------------------------------
Global gCACrossRoadKids = attributes CrossRoadKids attribID:#(0x449b771a, 0x1d589bab) (

	parameters params(
	
		kids 			type:#nodeTab tabSizeVariable:true
		controlsStr type:#string
	)
)
-------------------------------------------------------------------------------------
Global gShortcutCa = attributes ShortcutCa attribID:#(0x1635194a, 0x171142a1)(

	parameters params( 
		
		-- roadSpline 		type:#node --not used maybe ?
		-- startPoint		type:#node --not used maybe ?
		-- endPoint		type:#node --not used maybe ?
		controlsStr		type:#string
	)
)


fn runLocalScript script_name = (

	local fpath = getSourceFileName()
	local local_dir = getFilenamePath fpath
	local script_file = local_dir+script_name+".ms"
	if doesFileExist script_file then (
	
		fileIn script_file
		
	) else (
	
		messageBox ("Script ["+script_file+"] Not Found.") title:"Road Generator:"
	)
)


--Load all functions as struct
Global roGenStruct
runLocalScript "Road_Generator_Struct_v1.12"
--< 


--###################################################################################--
--	                                 ASCII SIGNS                                     --
--###################################################################################--
main_sign 	= bit.intAsChar 10134
top_sign 	= bit.intAsChar 10200
bot_sign	= bit.intAsChar 10201
side_sign	= bit.intAsChar 10073


-- because of delete callback  
global generated_road = undefined


--###################################################################################
--															CROSSROADS FN and Constatns
--###################################################################################
------------------------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------------------------

C_LAYER_NAME = "---noexport---terrain_generator_modules"
H_LAYER_NAME = "---noexport---terrain_generator_helpers"
-- C_COMPONENTS_PATH = "E:\\Aprog\\Orien\Micra\\repo_sync\\_NEW\\Road Tool\\terrain_generator_components.max"
-- C_COMPONENTS_PATH = LS3DGUP.LS3DGUP.UtilsPath+"terrain_generator_components.max"
-- C_COMPONENTS_PATH = "D:\\!2K_Games\\scotch_dev\\resources\\graphics\\_data_\\3dsmax\\terrain_generator_components.max"
--C_COMPONENTS_PATH = "D:\\ReneBaca\\3DsMax\\terrain_generator_components.max"
--C_COMPONENTS_PATH = "D:\\!2k_games\scotch_dev\\resources\\utilities\\3dsmax\\terrain_generator_components.max"
-- C_COMPONENTS_PATH = "E:\\Work\\2K Games\\DriveD\\!2K_Games\\scotch_dev\\resources\\graphics\\_data_\\3dsmax\\terrain_generator_components.max"
C_COMPONENTS_PATH = "E:\\Work\\2K Games\\DriveD\\!2K_Games\\scotch_dev\\resources\\graphics\\_data_\\3dsmax\\terrain_generator_components_nomat.max"

C_SIDEWALK_LEFT = 1
C_SIDEWALK_RIGHT = 2

C_PARKING_LANE_LEFT = 1
C_PARKING_LANE_RIGHT = 2

C_CORNER = 1
C_CORNER_P = 2

C_FLIP = TRUE
C_DONT_FLIP = FALSE

C_OLD_MATERIAL_ID = 11
C_NEW_MATERIAL_ID = 13

C_TANGENT_OFFSET = 3000

------------------------------------------------------------------------------
-- GLOBALS
------------------------------------------------------------------------------

global gCrossroadGenerator = undefined
global gCrossroadGeneratorUI = undefined

------------------------------------------------------------------------------
-- STRUCTURES
------------------------------------------------------------------------------

struct PlaneGeometry
(
  position = [0, 0, 0],
  normal = [0, 0, 1],
  
  fn SetPosition pos =
  (
    position = pos
  ),
  
  fn RotatePlane q =
  (
    normal = [0, 0, 1] * q
    --print normal
  ),
  
  fn IsVertIn vert =
  (
    vec = vert - position
    res = dot normal vec
    if (res >= 0) then (
      return true
    ) else (
      return false
    )
  ),
  
  fn IsEdgeIn vertices =
  (
	  if (IsVertIn vertices[1]) and (IsVertIn vertices[2]) then (
		  return 2
	  ) else if  (IsVertIn vertices[1]) or (IsVertIn vertices[2]) then (
		  return 1
	  ) else (
		  return 0
	  )
  )
)

------------------------------------------------------------------------------
-- HELP FUNCTIONS
------------------------------------------------------------------------------

fn IsGreaterEqual val1 val2 =
(
	if val1 > val2 or abs (val1 - val2) < 1.0 then
		return true
	else 
		return false
)

fn IsLesserEqual val1 val2 =
(
	if val1 < val2 or abs (val1 - val2) < 1.0 then
		return true
	else 
		return false
)


fn GetSign boolean =
(
	if boolean == true then
		return 1
	else
		return -1
)

fn PackArrays arr1 arr2 arr3 arr4 arr5 =
(
	packed_arr = #()
	for i in 1 to arr1.count do (
		append packed_arr #(arr1[i], arr2[i], arr3[i], arr4[i], arr5[i])
	)
	return packed_arr
)


/*delete all children items*/
fn FullDelete item =
(
	if item != undefined do (
-- 		if (isKindOf item node) do
-- 		(
-- 			for child in item.children do
-- 			(
-- 				FullDelete child
-- 			)
-- 		)
		delete item
	)
)


--get angle between two vectors
fn GetVectorsAngle v1 v2 =
(
	return acos(dot (normalize v1) (normalize v2))
)

-----------------------------------------------------------------------------------------
-- COMPARATORS
-----------------------------------------------------------------------------------------

fn ComparePointX p1 p2 =
(
	if p1.x < p2.x then
		return -1
	else
		return 1
)

fn ComparePointXRev p1 p2 =
(
	if p1.x > p2.x then
		return -1
	else
		return 1
)

fn ComparePointY p1 p2 =
(
	if p1.y < p2.y then
		return -1
	else
		return 1
)

fn CompareDistRoadCorner p1 p2 =
(
	d1 = (distance [0, 0, 0] p1[2])
	d2 = (distance [0, 0, 0] p2[2])
	if d1 < d2 then
		return -1
	else if abs (d1 - d2) < 0.1 then (
		if p1[5] < p2[5] then
			return -1
		else
			return 1
	) else (
		return 1
	)
)

fn ComparePointAngular p1 p2 =
(
	local up = [0, 1, 0]
	local a1 = GetVectorsAngle up p1
	local a2 = GetVectorsAngle up p2
	if a1 < a2 then
		return -1
	else
		return 1
)

-----------------------------------------------------------------------------------------
-- HELP FUNCTIONS
-----------------------------------------------------------------------------------------

--returns all vertices on right side of road
fn GetRoadVertices &road =
(
	left_vertices = #()
	right_vertices = #()
	for i in 1 to road.GetNumVertices() do
	(
		if (polyop.isVertDead road i) != true then
		(	
			v = road.GetVertex i
			
			if v.x < 0.0 then (
				append left_vertices v
			)
			if v.x > 0.0 then (
				append right_vertices v
			)
		)
	)
	
	qsort left_vertices ComparePointY
	qsort right_vertices ComparePointY
	
	vertices = #()
	vertices = join left_vertices right_vertices
	
	--deleteItem right_vertices 1
	--deleteItem right_vertices right_vertices.count
	
	--print ("Road vertices:"+(right_vertices as string))
	--return #(left_top, right_top, right_bottom, left_bottom)
	return right_vertices
)

--rotate all vertices by angle
fn RotateVertices verts ang =
(
	new_verts = #()
	rot_matrix = rotateZMatrix ang
	for v in verts do
	(
		append new_verts (v * rot_matrix)
	)
	return new_verts
)

--translate all vertices by vector
fn TranslateVertices verts vec =
(
	new_verts = #()
	for v in verts do
	(
		append new_verts (v + vec)
	)
	return new_verts
)

--linear interpolation
fn Lerp p1 p2 t =
(
	return p1 * t + p2 * (1.0 - t)
)


--returns road corner object with correct angle and texture mapping
fn CreateRoadCorner _obj _angle _bb =
(
	copy_obj = copy _obj
	
	q1 = quat 90 [0, 1, 0] 
	q2 = quat _angle [0, 0, 1] 
	q = (q1 * q2)
	
	planeGeom = PlaneGeometry()
	planeGeom.SetPosition (_obj.position + [0, 1.0, 0])
	planeGeom.RotatePlane q
	
	facelist = #()
	intersection_facelist = #()
	
	for i in 1 to copy_obj.getNumFaces() do
	(
		edges = polyop.getFaceEdges copy_obj i
		intersection = false
		contain = true
		for e_index in edges do (
			vert_indices = polyop.getEdgeVerts copy_obj e_index
			v1 = polyop.getVert copy_obj vert_indices[1]
			v2 = polyop.getVert copy_obj vert_indices[2]
			--skip this edge if one of the vertex is center
			if (distance v1 _obj.position) < 1.0 or (distance v2 _obj.position) < 1.0 then (
				continue
			)
			verts = #(v1, v2)
			if (planeGeom.IsEdgeIn verts == 2) then (
				--print "Contain both vertices"
				intersection = true
			) else if (planeGeom.IsEdgeIn verts == 1) then (
				intersection = true
				contain = false
			) else (
				contain = false
			)
		)
		if (intersection == false) then (
			--print "cut"
			append facelist i
		)
		if(intersection == true and contain == false) then (
			append intersection_facelist i
		)
	)
	
	planeGeom.SetPosition (_obj.position + [0, -1.0, 0])
	
	bottom_vertlist = #()
	bottom_poslist = #()
	bottom_texidlist = #()
	bottom_texlist = #()
	bottom_facelist = #()
	top_vertlist = #()
	top_poslist = #()
	top_texidlist = #()
	top_texlist = #()
	top_facelist = #()
	bottom_to_rotate_verts = #()
	bottom_to_rotate_poss = #()
	center_vertex_index = 0
	center_tex = [0, 0, 0]
	--najit vsechny body za rovinou
	correction_angle = (floor (_angle/5.625) + 1)*5.625-_angle
	--print ("Correction angle:"+(correction_angle as string))
	for j in 1 to intersection_facelist.count do
	(
		face_verts = polyop.getFaceVerts copy_obj intersection_facelist[j]
		tex_verts = polyop.getMapFace copy_obj 1 intersection_facelist[j]
		for i in 1 to (face_verts.count) do
		(
			index = face_verts[i]
			v = polyop.getVert copy_obj index
			tex_id = tex_verts[i]
			tex = polyop.getMapVert copy_obj 1 tex_id
			if (not (planeGeom.IsVertIn v)) and (not (polyop.isVertDead copy_obj i)) and ((distance v _obj.position) > 1.0) then  (
				--print "Bottom feeder!"
				append bottom_poslist v
				append bottom_vertlist index
				append bottom_texidlist tex_id
				append bottom_texlist tex
				append bottom_facelist intersection_facelist[j]
			)
			if ((planeGeom.IsVertIn v)) and (not (polyop.isVertDead copy_obj i)) and ((distance v _obj.position) > 1.0) then  (
				--print "Top feeder!"
				append top_poslist v
				append top_vertlist index
				append top_texidlist tex_id
				append top_texlist tex
				append top_facelist intersection_facelist[j]
			)
			if (distance v _obj.position) < 1.0 then (
				center_vertex_index = index
				center_tex = tex
			)
		)
	)
	
	--print("Center vertex index:"+(center_vertex_index as string))
	--print("Center tex:"+(center_tex as string))
	
	--print("Bottom")
	--print ("Pos list:"+(bottom_poslist as string))
	--print ("Tex list:"+(bottom_texlist as string))
	--print("Top")
	--print ("Pos list:"+(top_poslist as string))
	--print ("Tex list:"+(top_texlist as string))
	
	mult = mod _angle 5.625
	--print ("Mult: "+(mult as string))
		
	if (mult) > 0.01 then
	(
		bottom_poslist = TranslateVertices bottom_poslist (-copy_obj.position)
		top_poslist = TranslateVertices top_poslist (-copy_obj.position)
		
		packed_arr_bottom = PackArrays bottom_vertlist bottom_poslist bottom_texidlist bottom_texlist bottom_facelist
		packed_arr_top = PackArrays top_vertlist top_poslist top_texidlist top_texlist top_facelist
		qsort packed_arr_bottom CompareDistRoadCorner 
		qsort packed_arr_top CompareDistRoadCorner 
		
		--print ("Packed bottom: "+(packed_arr_bottom.count as string))
		--print ("Packed top: "+(packed_arr_top.count as string))
		
		amount = correction_angle / 5.625
		--correct uvs of verts which has to be moved of amount in direction of connection edge
		for i in 1 to packed_arr_bottom.count do (
			i1 = packed_arr_bottom[i][3]
			i2 = packed_arr_top[i][3]
			uv_1 = packed_arr_bottom[i][4]
			uv_2 = packed_arr_top[i][4]
			--print ("uv1: "+(uv_1 as string))
			--print ("uv2: "+(uv_2 as string))
			new_uv = Lerp uv_2 uv_1 amount
			polyop.setMapVert copy_obj 1 i1 new_uv
		)
	)
		
	polyOp.deleteFaces copy_obj facelist
	
	if (mult) > 0.01 then
	(
		vertlist = #()
		poslist = #()
		--najit vsechny body za rovinou
		for i in 1 to (polyop.getNumVerts copy_obj) do
		(
			v = polyop.getVert copy_obj i
			if not (planeGeom.IsVertIn v) and not (polyop.isVertDead copy_obj i) then  (
				append poslist v
				append vertlist i
			)
		)
		poslist = TranslateVertices poslist (-copy_obj.position)
		poslist = RotateVertices poslist correction_angle
		poslist = TranslateVertices poslist (copy_obj.position)
		
		polyop.setVert copy_obj vertlist poslist
	)
		
	return copy_obj
)

--returns correct road using settings
fn SelectRoad roads lane_number lane_width_1 lane_width_2 spec =
(	
	lane_width = 0
	if lane_width_1 == 0 then
		lane_width = lane_width_2 + 1
	else 
		lane_width = lane_width_1
	
	offset = 0
	if spec then (
		offset = 1
	)		
	if lane_number == 2 then (
		lane_width -= 1
	)
	print roads[(lane_number-1)*6 + (lane_width-1)*2 + offset + 1]
	return roads[(lane_number-1)*6 + (lane_width-1)*2 + offset + 1]
)

--returns correct corner using settings
fn SelectCorner corners parking =
(
	return corners[parking+1]
)

--check if array contains value
fn ArrayContainsValue arr val =
(
	--print ("Arr count: "+(arr.count as string))
	for i in 1 to arr.count do (
		--print ("arr[i]: "+(arr[i] as string)+" val: "+(val as string))
		--print (".")
		if arr[i] == val then (
			return true
		)
	)
	return false
)

--returns edge index of top edge and bottom edge
fn GetRoadEdgeIndices road =
(
	left_top = [0, 0, 0]
	left_top_index = 0
	right_top = [0, 0, 0]
	right_top_index = 0 
	left_bottom = [0, 0, 0]
	left_bottom_index = 0
	right_bottom = [0, 0, 0]
	right_bottom_index = 0
	
	for i in 1 to road.GetNumVertices() do
	(
		if (polyop.isVertDead road i) != true then
		(	
			v = road.GetVertex i
			--print ("Vertex: "+(v as string))
			if IsLesserEqual v.x left_top.x and IsGreaterEqual v.y left_top.y and IsLesserEqual v.z left_top.z then (
				left_top = v
				left_top_index = i
			)
			if IsGreaterEqual v.x right_top.x and IsGreaterEqual v.y right_top.y and IsLesserEqual v.z right_top.z then (
				right_top = v
				right_top_index = i
			)
			if IsLesserEqual v.x left_bottom.x and IsLesserEqual v.y left_bottom.y and IsLesserEqual v.z left_bottom.z then (
				left_bottom = v
				left_bottom_index = i
			)
			if IsGreaterEqual v.x right_bottom.x and IsLesserEqual v.y right_bottom.y and IsLesserEqual v.z right_bottom.z then (
				right_bottom = v
				right_bottom_index = i 
			)
		)
	)
	
	--print ("indices"+(left_top_index as string)+" "+(right_top_index as string)+" "+(left_bottom_index as string)+" "+(right_bottom_index as string))
	top_edge_index = 0
	bottom_edge_index = 0
	top_left_to_right = true
	bottom_left_to_right = true
	for i in 1 to (polyop.getNumEdges road) do
	(
		if(polyop.isEdgeDead road i) != true then 
		(
			controlled_edge = polyop.getEdgeVerts road i
			--print ("Edge: "+(controlled_edge as string))
			if (ArrayContainsValue controlled_edge left_top_index) and (ArrayContainsValue controlled_edge right_top_index) then (
				top_edge_index = i
				min = roGenStruct.RMin left_top_index right_top_index
				if(min == left_top_index) then (
					top_left_to_right = false
				)
			)
			if (ArrayContainsValue controlled_edge left_bottom_index) and (ArrayContainsValue controlled_edge right_bottom_index) then (
				bottom_edge_index = i
				min = roGenStruct.RMin left_bottom_index right_bottom_index
				if(min == left_bottom_index) then (
					bottom_left_to_right = false
				)
			)
		)
	)
	
	return #(#(top_edge_index, top_left_to_right), #(bottom_edge_index, bottom_left_to_right))
)

--returns all vertices 
fn GetRoadCornerVertices corner fromBottom bb =
(
	radius = roGenStruct.getWidthBB bb
	vertices = #()
	
	for i in 1 to corner.GetNumVertices() do
	(
		v = corner.GetVertex i
		if (distance v [0, 0, 0]) > (radius*0.95) and v.z < (roGenStruct.getBottomBB bb + (roGenStruct.getHeightBB bb)/2) and (not (polyop.isVertDead corner i)) then 
		(
			append vertices v
		)
	)
	
	qsort vertices ComparePointAngular
	
	if fromBottom == true then
	(
		vertices = roGenStruct.reverseArray vertices
	)
	
	return vertices
)

fn CreateConnectingRoad road_2 bb_1 bb_2 corner bb_corner angle_road placed_items rotate_angle offset prevPt:undefined=
(
	left_corner = CreateRoadCorner corner (angle_road) bb_corner

	right_corner = CreateRoadCorner corner (180-angle_road) bb_corner
	
	radius = (roGenStruct.getWidthBB bb_corner)
	--print ("Radius:"+(radius as string))
	l1 = (roGenStruct.getLengthBB bb_1)/2 + radius
	l2 = (roGenStruct.getLengthBB bb_2)/2 + radius
	--print ("L1:"+(l1 as string))
	--print ("L2:"+(l2 as string))
	a = l1/(tan angle_road)
	b = l2/(sin angle_road)
	c = l1/(sin angle_road)
	d = l2/(tan angle_road)
		
	if angle_road > 90 then  (
		a = l1/(tan (180-angle_road))
		b = l2/(sin (180-angle_road))
		c = l1/(sin (180-angle_road))
		d = l2/(tan (180-angle_road))
	)
	
	rotate left_corner (angleaxis (180+angle_road) [0,0,1])
	rotate right_corner (angleaxis (180) [0,0,1])
	
	sign = GetSign (rotate_angle != 180)
	
	cut_offset = c+d
	left_offset = a-b
	right_offset = a+b
	difference =  2*d
	if angle_road > 90 then  (
		left_offset = -a-b
		right_offset = -a+b
	)
	left_offset += offset
	right_offset += offset
		
	left_position =  [left_offset, l1, roGenStruct.getHeightBB bb_corner]
	right_position = [right_offset, l1, roGenStruct.getHeightBB bb_corner]

	left_corner.position = copy left_position
	right_corner.position = copy right_position
		
	left_corner.pivot = [0, 0, 0]
	right_corner.pivot = [0, 0, 0]
		
	rotate left_corner (angleaxis rotate_angle [0,0,1])
	rotate right_corner (angleaxis rotate_angle [0,0,1])
		
	left_corner.pivot = [sign * left_position.x, sign * left_position.y, left_position.z]
	right_corner.pivot = [sign * right_position.x, sign * right_position.y, right_position.z]
		
	slicer_2 = SliceModifier Slice_Type:2
	slicer_2.slice_plane.position = [0, 0, cut_offset]
	slicer_2.slice_plane.rotation = rotateYMatrix -90
	addModifier road_2 slicer_2
	
	center_point = (left_corner.pivot+right_corner.pivot)/2
	center_point.z = 0.0
	offset_point = [sign * offset, 0, 0]
	direction = normalize (center_point - offset_point)
	
	/*helper point for road generator tool*/
	
	
	
	
	if prevPt == undefined then(
		pt = point wirecolor:red
		roGenStruct.SetPointAppearance pt		
		/*helper point for tangent determination*/
		tn = point wirecolor:red
		-- hide tn
	-- 	format "%\n%\n%\n%\n" offset_point direction cut_offset C_TANGENT_OFFSET
		append pt.children tn
	)else(
		pt = prevPt
		tn = prevPt.children[1]
	)
	pt.position = offset_point + direction * cut_offset
	tn.position = offset_point + direction * (cut_offset + C_TANGENT_OFFSET)
	
	
	
	
	sliced_road = ConvertTo road_2 Editable_Poly
	road_vertices = GetRoadVertices sliced_road
	road_vertices = RotateVertices road_vertices (angle_road+rotate_angle)
	road_vertices = TranslateVertices road_vertices [sign*offset, 0.0, 0.0]
	road_vertices = roGenStruct.reverseArray road_vertices
			
	right_verts = GetRoadCornerVertices right_corner true bb_corner	
	right_verts = RotateVertices right_verts (180+rotate_angle)
	right_verts = TranslateVertices right_verts right_corner.position
  
	left_verts = GetRoadCornerVertices left_corner true bb_corner	
	left_verts = RotateVertices left_verts (180+angle_road+rotate_angle)
	left_verts = TranslateVertices left_verts left_corner.position
	
	vertices = #()
	
	if (distance left_verts[left_verts.count] road_vertices[1]) < 1.0 then
	(
		deleteItem road_vertices 1
	)
	
	if (distance right_verts[1] road_vertices[road_vertices.count]) < 1.0 then
	(
		deleteItem road_vertices road_vertices.count
	)
	
	vertices = join left_verts road_vertices
	vertices = join vertices right_verts
	
	py = (roGenStruct.getLengthBB bb_1)/2*sign
	dir = [1, 0, 0] * (rotateZMatrix (rotate_angle+angle_road))
	t = py/dir.y
	
	
	middle = [dir.x * t+sign*offset, dir.y * t, 0.0]
	append vertices middle
	
	facelist = #()
		
	for i in 1 to (vertices.count-2) do
	(
		append facelist [i+1, i, vertices.count]
	)
	
	fill_mesh = mesh vertices:vertices faces:facelist
	fill_mesh.material =  meditMaterials["bc_terrain"]
	
	for i in 1 to meshop.getNumFaces fill_mesh do
	(
		--smoothing group is represented as bits so integer 4 is like 100
		--so only smoothing group 3 is set
		setFaceSmoothGroup fill_mesh i 4
	)
	
	uvwmapping = uvwmap()
	uvwmapping.width = 400.0;
	uvwmapping.length= 400.0;
	addModifier fill_mesh uvwmapping
	--add universal tilable material in generated geometry > ID 6 (based on multimaterial Road_Material_D) MerlinEl 2019
	fill_material = MaterialModifier materialId:6 name:"fill_material"
	addModifier fill_mesh fill_material
	
	fill_poly = ConvertTo fill_mesh Editable_poly
	
	--ser vertex color to red (show base texture in 3 blend material) MerlinEl 2019
	roGenStruct.setVertexColor fill_poly red 0	
	
	return #(#(left_corner, right_corner, fill_poly, pt), #(sign * left_offset, sign * right_offset, difference, middle.x))
)

fn PlaceSidewalks corner rotate_angle sidewalk bb placed_items =
(
	direction = [1, 0, 0] * (rotateZMatrix rotate_angle)
	
	sidewalk_copy = copy sidewalk
	rotate sidewalk_copy (angleaxis rotate_angle [0,0,1])
	sidewalk_copy.position = corner.position
	--append placed_items sidewalk_copy
	return sidewalk_copy
)

fn PlaceParkingLane corner rotate_angle parking_lane placed_items =
(
	direction = [1, 0, 0] * (rotateZMatrix rotate_angle)
	parking_lane_copy = copy parking_lane
	
	copy parking_lane_copy
	
	rotate parking_lane_copy (angleaxis rotate_angle [0,0,1])
	parking_lane_copy.position = corner.position
	--append placed_items parking_lane_copy
	
-- 	test = copy parking_lane_copy
-- 	print test
	
	return parking_lane_copy
)

fn AddPathSlicer path_object bb offset slice_type =
(
	slicer = SliceModifier Slice_Type:slice_type
	slicer.slice_plane.position = [0, 0, offset]
	slicer.slice_plane.rotation = rotateYMatrix -90
	addModifier path_object slicer
)

fn ChangeMaterialId edit_pol matId newMatId =
(
	facelist = #()
	
	for i in 1 to edit_pol.getNumFaces() do
	(
		m_id = polyop.getFaceMatID edit_pol i
		if m_id == matId then
		(
			append facelist i
		)
	)
	polyop.setFaceMatId edit_pol facelist newMatId
)

fn PlaceAdditional corner rotate_angle sidewalk sidewalk_bb place_parking_lane change_mat parking_lane parking_lane_bb crop_offset placed_items =
(
	--print ("Change mat:"+(change_mat as string))
	sw = PlaceSidewalks corner rotate_angle sidewalk sidewalk_bb placed_items
	AddPathSlicer sw sidewalk_bb crop_offset 2
	sw = ConvertTo sw editable_poly
	if (place_parking_lane) then
	(
		pl = PlaceParkingLane corner rotate_angle parking_lane placed_items
		
		AddPathSlicer pl parking_lane_bb crop_offset 2
		pl = ConvertTo pl editable_poly
		
		if (change_mat) then (
			ChangeMaterialId pl C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		)
		sw.attach pl pl
	)
	return sw
)

fn AddRoadSlicer road dist slice_type =
(
	slicer = SliceModifier Slice_Type:slice_type
	slicer.slice_plane.position = [0, 0, dist]
	slicer.slice_plane.rotation = rotateYMatrix -90
	addModifier road slicer
	road = ConvertTo road editable_poly
)



--###################################################################################
--														NEW ADDTIONAL FUNCTIONS 
--###################################################################################

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

fn CheckIfSelectionIsRoad =
(
	result = undefined
	selObj = selection[1]
	
	if selection.count != 0 and matchPattern selObj.name pattern:"generator_crossroad_*" then result = selObj
)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--			Point Hide/Unhide
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn HideUnhidePoint pt state =
(
	if not pt.isHidden !=  state then (
		if state == True then unhide pt
		else hide pt
	)
)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn HideUnhidePoints pointArrStates road=
(
	pointPoses = #(3,4)
	roadChildren = road.children
	
	statePos = 1
	
	for pPos in pointPoses do (
		HideUnhidePoint roadChildren[pPos] pointArrStates[statePos]
		statePos += 1
	)
	
)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn ShowHidePoints roadType road =
(
-- #FourR
-- #FourDR
-- #ThreeFR
-- #ThreeR
	
	Case (roadType) of (
		#FourR : (
			HideUnhidePoints #(True,True) road
		)
	
		#FourDR : (
			HideUnhidePoints #(True,True) road
		)
		
		#ThreeFR : (
			HideUnhidePoints #(false,True) road
		)
		
		#ThreeR : (
			HideUnhidePoints #(True,false) road
		)
	)
)

--###################################################################################
--														FUNCTIONS FROM ROLLOUTS
--###################################################################################

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn InitFirstOpenRollout &roads &sidewalks &corners &parking_lanes = (

	--check prefabs 
	-- try (roGenStruct.validatePrefabs C_COMPONENTS_PATH) catch (destroyDialog dialog)
	local succes = roGenStruct.validatePrefabs C_COMPONENTS_PATH
	if not succes do (
	
		try (destroyDialog ::dlgCrossroadGenerator) catch()
		return false
	)
	--collect components
	roGenStruct.collectAllPrefabs &roads &sidewalks &corners &parking_lanes	
	true
)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn PreSetupAndChecks &generated_road &finalPos=
(
	generated_road = CheckIfSelectionIsRoad()
	finalPos = roGenStruct.getSelectedFacesCenter $
	deselect $*
)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn DeleteWrongParkingLines coll:false=  -- stupid workaround :(
(
	local nodes
	selectedLayer = LayerManager.current
	selectedLayer.nodes &nodes
	
	for obj in nodes do(
		
		if coll then(
			if matchPattern obj.name pattern:"coll_generator_parking_lane_left*" or matchPattern obj.name pattern:"coll_generator_parking_lane_right*" then (
				delete obj
			)
		)else(
			if matchPattern obj.name pattern:"generator_parking_lane_left*" or matchPattern obj.name pattern:"generator_parking_lane_right*" then (
				delete obj
			)
		)
		
		
		
	)
)


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn FinishCrossRoadSetups road dialog controlsArr finalPos roadType sw:undefined weldThreshold: 1.0 =
(
	local oldWireColor = roadParent = undefined
-- 	road = ConvertTo road Editable_poly
    if sw != undefined then road.EditablePoly.attach sw road
	
	
    vert_count = (polyop.getNumVerts road)
    all_vert_list = #{1..vert_count}
    
    road.weldThreshold = weldThreshold
    polyop.weldVertsByThreshold road all_vert_list
	

	
	roGenStruct.setCrossRoadCA road dialog controlsArr
-- 	CreateNameBuffer road
	
-- 	when road deleted id:#CrossDelete obj do --define a when construct
-- 	(
-- 		roGenStruct.deleteCrossRoadChildren obj
-- 		generated_road = undefined
-- 	)
	
	if generated_road != undefined then (
	
		road.transform = generated_road.transform
		oldWireColor = generated_road.wirecolor
		if generated_road.parent != undefined then roadParent = generated_road.parent
		generated_road.kids = #()
		FullDelete generated_road

    )else(
	
		if finalPos != undefined then road.pos = finalPos
	)

    generated_road = road
	
	roGenStruct.SetCrossRoadWireColor generated_road oldColor:oldWireColor
    select generated_road
	
-- 	generated_road.name = uniqueName (road.name)
-- 	print generated_road.name
	
	ShowHidePoints roadType road
	
	road.parent = roadParent

	generated_road = undefined
	
	DeleteWrongParkingLines()
)


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn CreateRoadWithPL  roads parkingLanes crossroadIndex &spec leftPL rightPL &originalPivot=
(
	normalRoad = roGenStruct.pickRoadPrefab roads crossroadIndex false
	pl_Left =  parkingLanes[1]
	pl_Right = parkingLanes[2]
			
	copyRoad 		= copy normalRoad
-- 	copyLeftPl 		= copy pl_Left
-- 	copyRighttPl	= copy pl_Right
			
	copyRoad.pos 			= [0,0,0]
-- 	copyLeftPl.pos 		= [0,0,0]
-- 	copyRighttPl.pos		= [0,0,0]
			
	bbRoad 			= roGenStruct.getBoundingBox copyRoad
	
-- 			
-- 			-------------------------------------------------------------------------------------
	if leftPL then (
		placeLeftPl 		= [bbRoad[1][1], bbRoad[2][2], 0]
		
		copyLeftPl 			= copy pl_Left
		copyLeftPl.pos 	= [0,0,0]
		bbPlLeft 			= roGenStruct.getBoundingBox copyLeftPl
		copyLeftPl.pivot 	= bbPlLeft[1]
		copyLeftPl.pos 	= placeLeftPl
		
		copyRoad.attach copyLeftPl copyRoad 
	)
	
	if rightPL then (
		placeRightPl		= bbRoad[1]
		
		copyRighttPl		= copy pl_Right
		copyRighttPl.pos	= [0,0,0]
		bbPlRight 			= roGenStruct.getBoundingBox copyRighttPl
		copyRighttPl.pivot= [bbPlRight[1][1], bbPlRight[2][2], bbPlRight[1][3]]
		copyRighttPl.pos		= placeRightPl
		
		copyRoad.attach copyRighttPl copyRoad 
	)
	
	
-- 	bbPlLeft 	= roGenStruct.getBoundingBox copyLeftPl
-- 	print bbPlLeft
-- 	copyLeftPl.pivot = bbPlLeft[1]
-- 			
-- 	bbPlRight 	= roGenStruct.getBoundingBox copyRighttPl
-- 	print bbPlRight
-- 	copyRighttPl.pivot = [bbPlRight[1][1], bbPlRight[2][2], bbPlRight[1][3]]
-- 			
-- 	copyLeftPl.pos 		= placeLeftPl
-- 	copyRighttPl.pos		= placeRightPl
	
-- 	copyRoad.attach copyLeftPl copyRoad 
-- 	copyRoad.attach copyRighttPl copyRoad 

	--MerlinEl 26.4.2019
	roGenStruct.weldEditPoly copyRoad 0.1	
	
	
-- 	if origPivot != undefined then (
-- 		origPivot = copyRoad.pivot
-- 	)
	
	spec = false
	centerpivot copyRoad
	resetxform copyRoad
	
-- 	print copyRoad.pivot
	if originalPivot != undefined then originalPivot = copyRoad.pivot
	
	
-- 	print copyRoad
-- 	print "-----------------------------------"
	copyRoad
)




--###################################################################################
--														1. 	ROLLOUT  TWO SIDEROADS
--###################################################################################

rollout dlgCrossroadGenerator "Crossroad Generator"
(
	local list_items = roGenStruct.getUIPrefabsIcons()
	group " ROAD" 
	(
		label mainRoad main_sign offset:[-100,0]
		dropdownlist dd_crossroad_prefabs_1 "" items:list_items height:list_items.count
		checkbox  cb_parking_lane_1 "Parking lane" checked:true align:#right
	)

	group " SIDE ROADS"
	(
		label sideRoad  side_sign offset:[-100,0]
		dropdownlist dd_crossroad_prefabs_2 "" items:list_items height:list_items.count 
		checkbox  cb_parking_lane_2 "Parking lane" checked:true align:#right
		spinner spnr_angle_1 "Top Angle: " type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,15] width:70
		spinner spnr_angle_2 "Bot. Angle:" type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,5] width:70
		spinner spnr_offset_1 "Top Offset:" type:#float range:[-1.0e6, 1.0e6, 0] align:#right offset:[0,-47] width:70
		spinner spnr_offset_2 "Bot. Offset:" type:#float range:[-1.0e6, 1.0e6, 0] align:#right offset:[0,6] width:70
	)

	button btn_generate "Generate Cross Road" width: 200 height: 35 offset:[0, 10] 
  
--   button btn_done "Done"
--   global generated_road = undefined   				-- Global because of delete callback
  
	local initialized = false
	local roads = #()
	local sidewalks = #()
	local corners = #()
	local parking_lanes = #()
	local layer = undefined
	local controlsArr = #(dd_crossroad_prefabs_1, cb_parking_lane_1, dd_crossroad_prefabs_2, cb_parking_lane_2, spnr_angle_1, spnr_offset_1, spnr_angle_2, spnr_offset_2)
  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--   EVENT HANDLERS :
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  on dlgCrossroadGenerator open do
  (
--     print "--Crossroad Generator--"
    
    if initialized == false then (
		InitFirstOpenRollout  &roads &sidewalks &corners &parking_lanes	
		initialized = true
    )
  )
  
  on dlgCrossroadGenerator close do
  (
    gCrossroadGeneratorUI = undefined
  )
  
  on btn_generate pressed do
  (
	undo off(
		
		
		
-- 		start = timeStamp()
		
		PreSetupAndChecks &generated_road &finalPos

		format "generated_road:% finalPos:%" generated_road finalPos
		
		spec_1 = (not cb_parking_lane_1.state) and cb_parking_lane_2.state
		spec_2 = cb_parking_lane_1.state and (not cb_parking_lane_2.state)
		
		
-- 		print spec_1
-- 		print spec_2
		
		
		------------------------------------------------------------------------------------------------------------
		road_1_model = undefined
		road_2_model = undefined
		plRoad1 = false
		plRoad2 = false
		
		plTopBot = True
		
		if spec_2 != false then(
			road_1_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
			plRoad1 = True
			plTopBot = false
		)
		else road_1_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
		
		if spec_1 != false then(
			road_2_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			plRoad2 = True
			plTopBot = false
		)
		else road_2_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
		if spec_1 != false or spec_2 != false then corner_model  = corners[1]
		else corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
		
			
		road_1 = copy road_1_model
		
		print ("road:" + road_1 as string)

		road_1.name = replace road_1.name 11 6 "crossroad_4R"
		road_1.name = uniquename(road_1.name)	
		
		road_1.position = [0, 0, 0]
		road_2_a = copy road_2_model
		road_2_a.position = [0, 0, 0]
		road_2_b = copy road_2_model
		road_2_b.position = [0, 0, 0]
		
		---------------------------------------------------------------------------
		if plRoad1 then delete road_1_model
		if plRoad2 then delete road_2_model
		---------------------------------------------------------------------------
		
		  
		  
		-- 	GenereteCrossRoad road_1 road_2_a road_2_b corner_model spnr_angle_1.value spnr_angle_2.value spnr_offset_1.value spnr_offset_2.value cb_parking_lane_1.state cb_parking_lane_2.state
		  
		road_1_bb = roGenStruct.getBoundingBox road_1
		road_2_bb = roGenStruct.getBoundingBox road_2_a
		
		road_1_length = roGenStruct.getLengthBB road_1_bb
		
		corner_bb = roGenStruct.getBoundingBox corner_model
		
		
		pTop 	= undefined
		pBot 		= undefined
		pRight 	= undefined
		pLeft 	= undefined
		if generated_road != undefined then (
		
			pTop 	= generated_road.kids[3]
			pBot 		= generated_road.kids[4]
			pRight 	= generated_road.kids[1]
			pLeft 	= generated_road.kids[2]
		)

		attributes_1 = CreateConnectingRoad road_2_a road_1_bb road_2_bb corner_model corner_bb spnr_angle_1.value placed_items 0 spnr_offset_1.value prevPt:pTop
		attributes_2 = CreateConnectingRoad road_2_b road_1_bb road_2_bb corner_model corner_bb spnr_angle_2.value placed_items 180 spnr_offset_2.value prevPt:pBot
		
		delete road_2_a
		delete road_2_b
		
		--print ("Attr1: "+(attributes_1 as string))
		--print ("Attr2: "+(attributes_2 as string))
		
		top_corners = attributes_1[1]
		bottom_corners = attributes_2[1]
		  
		if not ((cb_parking_lane_1.state) and (cb_parking_lane_2.state)) then
		(
		  ChangeMaterialId top_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId top_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId bottom_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId bottom_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		)
		  
		max_dist_left = roGenStruct.RMin (attributes_1[2][1]) (attributes_2[2][2])
		max_dist_right = roGenStruct.RMax (attributes_1[2][2]) (attributes_2[2][1])
		--print ("max dist left "+(max_dist_left as string)) 
		--print ("max dist right "+(max_dist_right as string))
		
		AddRoadSlicer road_1 (max_dist_left) 3
		AddRoadSlicer road_1 (max_dist_right) 2
		
		local pts = roGenStruct.setUpCrossRoadPoints max_dist_left max_dist_right c_tangent_offset road:generated_road hidden_tn:false
		append road_1.children pts[1]
		append road_1.children pts[2]
		append road_1.children attributes_1[1][4]
		append road_1.children attributes_2[1][4]
		
		road_1 = ConvertTo road_1 editable_poly
		cutted_road_bb = roGenStruct.getBoundingBox road_1
		--AddRoadSlicer road_1 (attributes_1[2][4]) 1
		--AddRoadSlicer road_1 (attributes_2[2][4]) 1
		  
		road_edge_indices = GetRoadEdgeIndices road_1
		  
		--tri state
		tri_left_top_further = 0
		if attributes_1[2][1] < attributes_2[2][2] then 
		  tri_left_top_further = 1
		else
		  tri_left_top_further = -1
		tri_right_top_further = 0
		if attributes_1[2][2] > attributes_2[2][1] then
		  tri_right_top_further = 1
		else
		  tri_right_top_further = -1

		
		sidewalk_bb = roGenStruct.getBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = roGenStruct.getBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		  

		place_pl_1 = cb_parking_lane_1.state or cb_parking_lane_2.state
		place_pl_2 = cb_parking_lane_1.state or cb_parking_lane_2.state
		
		
		
		pts_to_connect_top = #()
		pts_to_connect_bottom = #()
		append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
		append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
		  
		road_width = (roGenStruct.getWidthBB cutted_road_bb)
		road_left = (roGenStruct.getLeftBB cutted_road_bb)
		road_right = (roGenStruct.getRightBB cutted_road_bb)
		--top side
		if tri_right_top_further == -1 then
		(
			if cb_parking_lane_1.state == True and cb_parking_lane_2.state == false then place_pl_1 = false
			if cb_parking_lane_1.state == false and cb_parking_lane_2.state == True then place_pl_1 = false
			sw = PlaceAdditional top_corners[2] 0 sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_right - (attributes_1[2][2]))) placed_items
			road_1.attach sw road_1 
			append pts_to_connect_top [attributes_1[2][2], road_1_length/2, 0.0]
		)
		if spnr_angle_1.value > 90.0 then
		(
			if spec_1 or spec_2 then place_pl_2 = false
			if cb_parking_lane_1.state == false and cb_parking_lane_2.state == True then place_pl_2 = false
				
		  sw = PlaceAdditional top_corners[2] (spnr_angle_1.value) sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_1[2][3]) placed_items
		  road_1.attach sw road_1
		)
		if tri_left_top_further == -1 then
		(
			if cb_parking_lane_1.state == True and cb_parking_lane_2.state == false then place_pl_1 = false
			if cb_parking_lane_1.state == false and cb_parking_lane_2.state == True then place_pl_1 = false
		  sw = PlaceAdditional top_corners[1] 180 sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_left - (attributes_1[2][1]))) placed_items
		  road_1.attach sw road_1
		  append pts_to_connect_top [attributes_1[2][1], road_1_length/2, 0.0]
		)
		if spnr_angle_1.value < 90.0 then 
		(
		  if spec_1 or spec_2 then place_pl_2 = false
		  sw = PlaceAdditional top_corners[1] (spnr_angle_1.value) sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_1[2][3]) placed_items
		  road_1.attach sw road_1
		)
		
		--bottom side
		if tri_right_top_further == 1 then
		(
			if cb_parking_lane_1.state == True and cb_parking_lane_2.state == false then place_pl_1 = false
			if cb_parking_lane_1.state == false and cb_parking_lane_2.state == True then place_pl_1 = false
		  sw = PlaceAdditional bottom_corners[1] 0 sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_right - (attributes_2[2][1]))) placed_items
		  road_1.attach sw road_1
		  append pts_to_connect_bottom [attributes_2[2][1], -road_1_length/2, 0.0]
		)
		if spnr_angle_2.value < 90.0 then
		(
		  if spec_1 or spec_2 then place_pl_2 = false
		  sw = PlaceAdditional bottom_corners[1] (spnr_angle_2.value+180) sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_2[2][3]) placed_items
		  road_1.attach sw road_1
		)
		if tri_left_top_further == 1 then
		(
			if cb_parking_lane_1.state == True and cb_parking_lane_2.state == false then place_pl_1 = false
			if cb_parking_lane_1.state == false and cb_parking_lane_2.state == True then place_pl_1 = false
		  sw = PlaceAdditional bottom_corners[2] 180 sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_left - (attributes_2[2][2]))) placed_items
		  road_1.attach sw road_1
		  append pts_to_connect_bottom [attributes_2[2][2], -road_1_length/2, 0.0]
		)
		if spnr_angle_2.value > 90.0 then
		(
		  if spec_1 or spec_2 then place_pl_2 = false
		  sw = PlaceAdditional bottom_corners[2] (spnr_angle_2.value+180) sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_2[2][3]) placed_items
		  road_1.attach sw road_1
		)
		
		qsort pts_to_connect_top ComparePointX
		qsort pts_to_connect_bottom ComparePointXRev
		
		top_width = road_width
		top_road_left = (abs road_left)
		for pt in pts_to_connect_top do (
		  --print ("Pt: "+(pt.x as string))
		  --print ("Top width: "+(top_width as string))
		  --print ("Top road left: "+(top_road_left as string))
		  t = ((pt.x+top_road_left)/(top_width))
		  --print ("Coef: "+(t as string))
		  if road_edge_indices[1][2] then
			road_1.insertVertexInEdge road_edge_indices[1][1]  (t)
		  else 
			road_1.insertVertexInEdge road_edge_indices[1][1]  (1.0-t)
		  top_width = road_right - pt.x
		  top_road_left = -pt.x
		)
		
		bottom_width = road_width
		bottom_road_right = (abs road_right)
		bottom_road_left = abs road_left
		for pt in pts_to_connect_bottom do (
		  --print ("Pt: "+(pt.x as string))
		  --print ("Bottom width: "+(bottom_width as string))
		  --print ("Bottom road left: "+(bottom_road_right as string))
		  t = ((bottom_road_left+pt.x)/(bottom_width))
		  --print ("Coef: "+(t as string))
		  if road_edge_indices[2][2] then
			road_1.insertVertexInEdge road_edge_indices[2][1]  (1.0-t)
		  else 
			road_1.insertVertexInEdge road_edge_indices[2][1]  (t)
		  bottom_width = abs (pt.x - road_left)
		  bottom_road_right = pt.x
		)
		
		road_1.attach top_corners[1] road_1
		road_1.attach top_corners[2] road_1
		road_1.attach attributes_1[1][3] attributes_1[1][3]
		road_1.attach bottom_corners[1] road_1
		road_1.attach bottom_corners[2] road_1
		road_1.attach attributes_2[1][3] attributes_2[1][3]

		
		FinishCrossRoadSetups road_1 dlgCrossroadGenerator controlsArr finalPos #FourR
		
-- 		end = timeStamp()
-- 		format "Processing took % seconds\n" ((end - start) / 1000.0)
	)
  )
)









--###################################################################################
--													2. 	ROLLOUT  TWO DIFF SIDEROADS 
--###################################################################################

rollout dlgCrossroadGenerator2 "Crossroad Generator"
(
	local list_items = roGenStruct.getUIPrefabsIcons()
	group " ROAD"
	(
		label mainRoad  main_sign offset:[-100,0]
		dropdownlist dd_crossroad_prefabs_1 "" items:list_items height:list_items.count																	
		checkbox  cb_parking_lane_1 "Parking lane" checked:true align:#right
	)

	group " TOP ROAD"
	(
		label topRoad  top_sign offset:[-100,0]
		dropdownlist dd_crossroad_prefabs_2 "" items:list_items height:list_items.count 																
		checkbox  cb_parking_lane_2 "Parking lane" checked:true align:#right
		spinner spnr_angle_1 "Top Angle: " type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,10] width:70
		spinner spnr_offset_1 "Top Offset:" type:#float range:[-1.0e6, 1.0e6, 0] align:#right offset:[0,-22] width:70
	)

	group " BOTTOM ROAD" 
	(
		label botRoad  bot_sign offset:[-100,0]
		dropdownlist dd_crossroad_prefabs_3 "" items:list_items height:list_items.count																	
		checkbox  cb_parking_lane_3 "Parking lane" checked:true align:#right
		spinner spnr_angle_2 "Bot. Angle:" type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,10] width:70
		spinner spnr_offset_2 "Bot. Offset:" type:#float range:[-1.0e6, 1.0e6, 0] align:#right offset:[0,-22] width:70
	)
  
  button btn_generate "Generate" width: 200 height: 35 offset:[0, 5]
--   button btn_done "Done"
  
--   global generated_road = undefined
  
  local initialized = false
  local roads = #()
  local sidewalks = #()
  local corners = #()
  local parking_lanes = #()
  local layer = undefined
  
  
  local controlsArr = #(dd_crossroad_prefabs_1 , cb_parking_lane_1, 
								dd_crossroad_prefabs_2, cb_parking_lane_2, spnr_angle_1, spnr_offset_1, 
								dd_crossroad_prefabs_3, cb_parking_lane_3, spnr_angle_2, spnr_offset_2)
  

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--   EVENT HANDLERS :
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  on dlgCrossroadGenerator2 open do
  (
--     print "--Crossroad Generator--"
    
    if initialized == false then (
		roGenStruct.collectAllPrefabs &roads &sidewalks &corners &parking_lanes
		initialized = true
    )
  )
  
  on dlgCrossroadGenerator2 close do
  (
    gCrossroadGeneratorUI = undefined
  )
   
  on btn_generate pressed do
  ( 
	undo off(
		PreSetupAndChecks &generated_road &finalPos
		  
		spec_1 = cb_parking_lane_1.state--(not cb_parking_lane_1.state) and cb_parking_lane_2.state
		spec_2 = cb_parking_lane_2.state--cb_parking_lane_1.state and (not cb_parking_lane_2.state)
		spec_3 = cb_parking_lane_3.state--cb_parking_lane_1.state and (not cb_parking_lane_3.state)
		
-- 		print spec_1
-- 		print spec_2
-- 		print spec_3
-- 		-------------------------------------------------------------------------------------------------------------------------------------------------------
		road_1_model = undefined
		road_2_model = undefined
		road_3_model = undefined
		
		plRoad = undefined
		plRoad2 = undefined
		
		plTop = false
		plBot = false
		
		origPivot = [0,0,0]
		
		
		if spec_1 == True and spec_2 == True and spec_3 == True then (
			road_1_model 	= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 	= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 	= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			corner_model 		= corners[2]
			corner_model_2 	= corners[2]
			plTop = True
			plBot = True
		)
		
		else if spec_1 == false and spec_2 == false and spec_3 == false then (
			road_1_model 	= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 	= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 	= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
		)

		else if spec_1 == True and spec_2 == false and spec_3 == false then (
			road_1_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			road_2_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			plRoad = road_1_model
		)
		
		else if spec_1 == True and spec_2 == True and spec_3 == false then (
			road_1_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 false True &origPivot
			corner_model 		= corners[2]
			corner_model_2 	= corners[1]
			road_2_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			
			plTop = True
			plRoad = road_1_model
		)
		
		else if spec_1 == True and spec_2 == false and spec_3 == true then (
			road_1_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 True false &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[2]
			road_2_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			
			plBot = True
			plRoad = road_1_model
		)
		
		else if spec_1 == false and spec_2 == True and spec_3 == false then (
			road_2_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			road_1_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_3_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			plRoad = road_2_model
		)
		
-- 		print spec_1
		else if spec_1 == false and spec_2 == false and spec_3 == True then (
			road_3_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_3.selection &spec_3 True True &origPivot
			road_1_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			plRoad = road_3_model
		)
		
		else if spec_1 == false and spec_2 == True and spec_3 == True then (
			
			road_1_model 		= roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			road_3_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_3.selection &spec_3 True True &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			plRoad 	= road_3_model
			plRoad2 	= road_2_model
		)
		
		road_1 = copy road_1_model
		road_1.name = replace road_1.name 11 6 "crossroad_4DR"
		road_1.name = uniquename(road_1.name)	
		
		
		road_1.position = [0, 0, 0]
		road_2_a = copy road_2_model
		road_2_a.position = [0, 0, 0]
		road_2_b = copy road_3_model
		road_2_b.position = [0, 0, 0]
		
-- 		print road_1
-- 		print road_2_a
-- 		print road_2_b
-- 		print plRoad
		---------------------------------------------------------------------------
		if plRoad != undefined then delete plRoad
		if plRoad2 != undefined then delete plRoad2
		---------------------------------------------------------------------------  
		  
		  
		  
		  
		  
		  
		-- 	GenereteCrossRoad road_1 road_2_a road_2_b corner_model spnr_angle_1.value spnr_angle_2.value spnr_offset_1.value spnr_offset_2.value cb_parking_lane_1.state cb_parking_lane_2.state
		  
		road_1_bb = roGenStruct.getBoundingBox road_1
		road_2_bb = roGenStruct.getBoundingBox road_2_a
		road_3_bb = roGenStruct.getBoundingBox road_2_b
		
		road_1_length = roGenStruct.getLengthBB road_1_bb
		
		corner_bb = roGenStruct.getBoundingBox corner_model
		corner_2_bb = roGenStruct.getBoundingBox corner_model_2
		
		
		
		pTop 	= undefined
		pBot 		= undefined
		pRight 	= undefined
		pLeft 	= undefined
		if generated_road != undefined then (
			pTop 	= generated_road.kids[3]
			pBot 		= generated_road.kids[4]
			pRight 	= generated_road.kids[1]
			pLeft 	= generated_road.kids[2]
		)

		
		attributes_1 = CreateConnectingRoad road_2_a road_1_bb road_2_bb corner_model corner_bb spnr_angle_1.value placed_items 0 spnr_offset_1.value prevPt:pTop
		attributes_2 = CreateConnectingRoad road_2_b road_1_bb road_3_bb corner_model_2 corner_2_bb spnr_angle_2.value placed_items 180 spnr_offset_2.value prevPt:pBot
		format "attributes_1:%\n" attributes_1
		delete road_2_a
		delete road_2_b
		
		--print ("Attr1: "+(attributes_1 as string))
		--print ("Attr2: "+(attributes_2 as string))
		
		top_corners = attributes_1[1]
		bottom_corners = attributes_2[1]
		  
		if not ((cb_parking_lane_1.state) and (cb_parking_lane_2.state)) then
		(
		  ChangeMaterialId top_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId top_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		)
		
		if not ((cb_parking_lane_1.state) and (cb_parking_lane_3.state)) then
		(
		  ChangeMaterialId bottom_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId bottom_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		)
		
		
		
		  
		max_dist_left = roGenStruct.RMin (attributes_1[2][1]) (attributes_2[2][2])
		max_dist_right = roGenStruct.RMax (attributes_1[2][2]) (attributes_2[2][1])
		--print ("max dist left "+(max_dist_left as string)) 
		--print ("max dist right "+(max_dist_right as string))
		
		AddRoadSlicer road_1 (max_dist_left) 3
		AddRoadSlicer road_1 (max_dist_right) 2
		
		
		
		
		if generated_road == undefined then (
			pt1 = point wirecolor:red
			roGenStruct.SetPointAppearance pt1
			tn1 = point wirecolor:red
			-- hide tn1
			append pt1.children tn1
			pt2 = point wirecolor:red
			roGenStruct.SetPointAppearance pt2
			tn2 = point wirecolor:red
			-- hide tn2
			append pt2.children tn2
		)else(
			pt1 = pRight
			tn1 = pRight.children[1]
			pt2 = pLeft
			tn2 = pLeft.children[1]
		)
		
		if origPivot == [0,0,0] then (
			pt1.position = [max_dist_right, 0, 0]/*+road_1.position*/
			tn1.position = [max_dist_right+C_TANGENT_OFFSET, 0, 0]
			pt2.position = [max_dist_left, 0, 0]/*+road_1.position*/
			tn2.position = [max_dist_left-C_TANGENT_OFFSET, 0, 0]
		)else(
			pt1.position = [max_dist_right, -origPivot[2], 0]/*+road_1.position*/
			tn1.position = [max_dist_right+C_TANGENT_OFFSET, -origPivot[2], 0]
			pt2.position = [max_dist_left, -origPivot[2], 0]/*+road_1.position*/
			tn2.position = [max_dist_left-C_TANGENT_OFFSET, -origPivot[2], 0]
		)
		
		
		append road_1.children pt1
		append road_1.children pt2
		append road_1.children attributes_1[1][4]
		append road_1.children attributes_2[1][4]
		
		road_1 = ConvertTo road_1 editable_poly
		cutted_road_bb = roGenStruct.getBoundingBox road_1
		--AddRoadSlicer road_1 (attributes_1[2][4]) 1
		--AddRoadSlicer road_1 (attributes_2[2][4]) 1
		  
		road_edge_indices = GetRoadEdgeIndices road_1
		  
		--tri state
		tri_left_top_further = 0
		if attributes_1[2][1] < attributes_2[2][2] then 
		  tri_left_top_further = 1
		else
		  tri_left_top_further = -1
		tri_right_top_further = 0
		if attributes_1[2][2] > attributes_2[2][1] then
		  tri_right_top_further = 1
		else
		  tri_right_top_further = -1
		  
		--print ("Left top"+((attributes_1[2][1])  as string)) 
		--print ("Right top"+((attributes_1[2][2])  as string)) 
		--print ("Left bottom"+((attributes_2[2][2])  as string)) 
		--print ("Right bottom"+((attributes_2[2][1])  as string)) 
		  
		--print ("Tri state left "+(tri_left_top_further  as string)) 
		--print ("Tri state right "+(tri_right_top_further as string))
		
		sidewalk_bb = roGenStruct.getBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = roGenStruct.getBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		
		
		
		-------------------------------------------------------------------
		place_pl_1 = false
		place_pl_2 = false
		-------------------------------------------------------------------
		if plTop then place_pl_1 = true
		if plBot then place_pl_2 = true
		
		
		
		pts_to_connect_top = #()
		pts_to_connect_bottom = #()
		append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
		append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
		  
		road_width = (roGenStruct.getWidthBB cutted_road_bb)
		road_left = (roGenStruct.getLeftBB cutted_road_bb)
		road_right = (roGenStruct.getRightBB cutted_road_bb)
		--top side
		if tri_right_top_further == -1 then
		(
		  sw = PlaceAdditional top_corners[2] 0 sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_right - (attributes_1[2][2]))) placed_items
		  road_1.attach sw road_1 
		  append pts_to_connect_top [attributes_1[2][2], road_1_length/2, 0.0]
		)
		if spnr_angle_1.value > 90.0 then
		(
		  sw = PlaceAdditional top_corners[2] (spnr_angle_1.value) sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_1[2][3]) placed_items
		  road_1.attach sw road_1
		)
		if tri_left_top_further == -1 then
		(
		  sw = PlaceAdditional top_corners[1] 180 sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_left - (attributes_1[2][1]))) placed_items
		  road_1.attach sw road_1
		  append pts_to_connect_top [attributes_1[2][1], road_1_length/2, 0.0]
		)
		if spnr_angle_1.value < 90.0 then 
		(
-- 		  if plTop then place_pl_1 = false
		  sw = PlaceAdditional top_corners[1] (spnr_angle_1.value) sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_1[2][3]) placed_items
		  road_1.attach sw road_1
		)
		
		--bottom side
		if tri_right_top_further == 1 then
		(
		  sw = PlaceAdditional bottom_corners[1] 0 sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_right - (attributes_2[2][1]))) placed_items
		  road_1.attach sw road_1
		  append pts_to_connect_bottom [attributes_2[2][1], -road_1_length/2, 0.0]
		)
		if spnr_angle_2.value < 90.0 then
		(
-- 		  if plBot then place_pl_2 = true
		  sw = PlaceAdditional bottom_corners[1] (spnr_angle_2.value+180) sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_2[2][3]) placed_items
		  road_1.attach sw road_1
		)
		if tri_left_top_further == 1 then
		(
		  sw = PlaceAdditional bottom_corners[2] 180 sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_left - (attributes_2[2][2]))) placed_items
		  road_1.attach sw road_1
		  append pts_to_connect_bottom [attributes_2[2][2], -road_1_length/2, 0.0]
		)
		if spnr_angle_2.value > 90.0 then
		(
-- 		  if plBot then place_pl_2 = true
		  sw = PlaceAdditional bottom_corners[2] (spnr_angle_2.value+180) sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_2[2][3]) placed_items
		  road_1.attach sw road_1
		)
		
		qsort pts_to_connect_top ComparePointX
		qsort pts_to_connect_bottom ComparePointXRev
		
		top_width = road_width
		top_road_left = (abs road_left)
		for pt in pts_to_connect_top do (
		  --print ("Pt: "+(pt.x as string))
		  --print ("Top width: "+(top_width as string))
		  --print ("Top road left: "+(top_road_left as string))
		  t = ((pt.x+top_road_left)/(top_width))
		  --print ("Coef: "+(t as string))
		  if road_edge_indices[1][2] then
			road_1.insertVertexInEdge road_edge_indices[1][1]  (t)
		  else 
			road_1.insertVertexInEdge road_edge_indices[1][1]  (1.0-t)
		  top_width = road_right - pt.x
		  top_road_left = -pt.x
		)
		
		bottom_width = road_width
		bottom_road_right = (abs road_right)
		bottom_road_left = abs road_left
		for pt in pts_to_connect_bottom do (
		  --print ("Pt: "+(pt.x as string))
		  --print ("Bottom width: "+(bottom_width as string))
		  --print ("Bottom road left: "+(bottom_road_right as string))
		  t = ((bottom_road_left+pt.x)/(bottom_width))
		  --print ("Coef: "+(t as string))
		  if road_edge_indices[2][2] then
			road_1.insertVertexInEdge road_edge_indices[2][1]  (1.0-t)
		  else 
			road_1.insertVertexInEdge road_edge_indices[2][1]  (t)
		  bottom_width = abs (pt.x - road_left)
		  bottom_road_right = pt.x
		)
		
		road_1.attach top_corners[1] road_1
		road_1.attach top_corners[2] road_1
		road_1.attach attributes_1[1][3] attributes_1[1][3]
		road_1.attach bottom_corners[1] road_1
		road_1.attach bottom_corners[2] road_1
		road_1.attach attributes_2[1][3] attributes_2[1][3]
		
		
		if origPivot != [0,0,0] then centerpivot road_1
		FinishCrossRoadSetups road_1 dlgCrossroadGenerator2 controlsArr finalPos #FourDR
		
	)
  )
)







--###################################################################################
--											3.			ROLLOUT  ONE SIDEROAD
--###################################################################################

rollout dlgCrossroadGenerator3 "Crossroad Generator"
(
	local list_items = roGenStruct.getUIPrefabsIcons()
	group " ROAD"
	(
		label mainRoad main_sign offset:[-100,0]
		dropdownlist dd_crossroad_prefabs_1 "" items:list_items height:list_items.count
		checkbox  cb_parking_lane_1 "Parking lane" checked:true align:#right
	)

	group " SIDE ROAD"
	(
		label topRoad top_sign offset:[-100,0]
		label botRoad bot_sign offset:[-85,-18]
		dropdownlist dd_crossroad_prefabs_2 "" items:list_items height:list_items.count
		checkbox  cb_parking_lane_2 "Parking lane" checked:true align:#right																
		spinner spnr_angle_1 "Angle: " type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,0] width:70
	)

	--     spinner spnr_angle_2 "Angle 2: " type:#float range:[1, 180, 90] scale:1.0 align:#left
	spinner spnr_offset_1 "Offset 1: " type:#float range:[-1.0e6, 1.0e6, 0] align:#right
	--     spinner spnr_offset_2 "Offset 2: " type:#float range:[-1.0e6, 1.0e6, 0] align:#left

	local buttGenText = top_sign + "   Generate" 
	local buttFlipGenText = bot_sign + "    Generate Flipped"  

	--   button btn_generate2 "Generate Flipped Version"
	button btn_generate2 buttFlipGenText width: 200 height: 30 offset:[0, -15]
	button btn_generate buttGenText width: 200 height: 30 offset:[0, -5]
	--   button btn_done "Done"

	--   global generated_road = undefined

	local initialized = false
	local roads = #()
	local sidewalks = #()
	local corners = #()
	local parking_lanes = #()
	local layer = undefined
	local controlsArr = #(dd_crossroad_prefabs_1, cb_parking_lane_1, dd_crossroad_prefabs_2, cb_parking_lane_2, spnr_angle_1)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--   EVENT HANDLERS :
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  on dlgCrossroadGenerator3 open do
  (
--     print "--Crossroad Generator--"
    
    if initialized == false then (
		roGenStruct.collectAllPrefabs &roads &sidewalks &corners &parking_lanes
		initialized = true
		spnr_offset_1.visible = False
    )
  )
  
  on dlgCrossroadGenerator3 close do
  (
    gCrossroadGeneratorUI = undefined
  )
  
  on btn_generate pressed do
  (
	undo off(
		PreSetupAndChecks &generated_road &finalPos
		
		spec_1 = (not cb_parking_lane_1.state) and cb_parking_lane_2.state
		spec_2 = cb_parking_lane_1.state and (not cb_parking_lane_2.state)
		
		
		
		------------------------------------------------------------------------------------------------------------
		road_1_model = undefined
		road_2_model = undefined
		plRoad1 = false
		plRoad2 = false
		
		plTopBot = True
		
		if spec_2 != false then(
			road_1_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
			plRoad1 = True
			plTopBot = false
		)
		else road_1_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
		
		if spec_1 != false then(
			road_2_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			plRoad2 = True
			plTopBot = false
		)
		else road_2_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
		if spec_1 != false or spec_2 != false then corner_model  = corners[1]
		else corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
		
		
		
		
-- 		road_1_model = SelectRoad roads rb_lane_number_1.state rb_lane_width_1.state rb_lane_width_1_1.state spec_1
-- 		road_2_model = SelectRoad roads rb_lane_number_2.state rb_lane_width_2.state rb_lane_width_2_1.state spec_2
		
-- 		road_1_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
-- 		road_2_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
-- 		
-- 		
-- 		corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)

			
		road_1 = copy road_1_model
		  
		road_1.name = replace road_1.name 11 6 "crossroad_3R"
		road_1.name = uniquename(road_1.name)	  
		  
		  
		road_1.position = [0, 0, 0]
		road_2_a = copy road_2_model
		road_2_a.position = [0, 0, 0]
	--     road_2_b = copy road_2_model
	--     road_2_b.position = [0, 0, 0]
		
		
		---------------------------------------------------------------------------
		if plRoad1 then delete road_1_model
		if plRoad2 then delete road_2_model
		---------------------------------------------------------------------------
		
		  
		  
		-- 	GenereteCrossRoad road_1 road_2_a road_2_b corner_model spnr_angle_1.value spnr_angle_2.value spnr_offset_1.value spnr_offset_2.value cb_parking_lane_1.state cb_parking_lane_2.state
		  
		road_1_bb = roGenStruct.getBoundingBox road_1
		road_2_bb = roGenStruct.getBoundingBox road_2_a
		
		road_1_length = roGenStruct.getLengthBB road_1_bb
		
		corner_bb = roGenStruct.getBoundingBox corner_model
		
		
		pTop 	= undefined
		pBot 		= undefined
		pRight 	= undefined
		pLeft 	= undefined
		if generated_road != undefined then (
			pTop 	= generated_road.kids[3]
			pBot 		= generated_road.kids[4]
			pRight 	= generated_road.kids[1]
			pLeft 	= generated_road.kids[2]
		)
		

		attributes_1 = CreateConnectingRoad road_2_a road_1_bb road_2_bb corner_model corner_bb spnr_angle_1.value placed_items 0 spnr_offset_1.value prevPt:pTop
	--     attributes_2 = CreateConnectingRoad road_2_b road_1_bb road_2_bb corner_model corner_bb spnr_angle_2.value placed_items 180 spnr_offset_2.value
		
		delete road_2_a
	--     delete road_2_b
		
	--     print ("Attr1: "+(attributes_1 as string))
	--     print ("Attr2: "+(attributes_2 as string))
		
		top_corners = attributes_1[1]
	--     bottom_corners = attributes_2[1]
		  
		if not ((cb_parking_lane_1.state) and (cb_parking_lane_2.state)) then
		(
		  ChangeMaterialId top_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId top_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
	--       ChangeMaterialId bottom_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
	--       ChangeMaterialId bottom_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		)
		  
		
	-- 	EDIT:
	--     max_dist_left = roGenStruct.RMin (attributes_1[2][1]) (attributes_2[2][2])
	--     max_dist_right = roGenStruct.RMax (attributes_1[2][2]) (attributes_2[2][1])
		
	-- 	format "%\n%\n" attributes_1[2][1] attributes_1[2][2]
		
		max_dist_left = attributes_1[2][1]
		max_dist_right = attributes_1[2][2]
		
	--     print ("max dist left "+(max_dist_left as string)) 
	--     print ("max dist right "+(max_dist_right as string))
		
		AddRoadSlicer road_1 (max_dist_left) 3
		AddRoadSlicer road_1 (max_dist_right) 2
		
		
	-- 	format "%\n" attributes_1[1][4]
	-- 	append road_1.children attributes_2[1][4]
		
		road_1 = ConvertTo road_1 editable_poly
		cutted_road_bb = roGenStruct.getBoundingBox road_1
		--AddRoadSlicer road_1 (attributes_1[2][4]) 1
		--AddRoadSlicer road_1 (attributes_2[2][4]) 1
		  
		road_edge_indices = GetRoadEdgeIndices road_1
		  
		  
		tri_left_top_further = 1
		tri_right_top_further = 1
		
		
		sidewalk_bb = roGenStruct.getBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = roGenStruct.getBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		  
		place_pl_1 = cb_parking_lane_1.state or cb_parking_lane_2.state
		place_pl_2 = cb_parking_lane_1.state or cb_parking_lane_2.state
		pts_to_connect_top = #()
	--     pts_to_connect_bottom = #()
		append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
		
	-- 	format "%\n" pts_to_connect_top
	--     append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
		  
		road_width = (roGenStruct.getWidthBB cutted_road_bb)
		road_left = (roGenStruct.getLeftBB cutted_road_bb)
		road_right = (roGenStruct.getRightBB cutted_road_bb)
		
	-- 	print road_left
		
		--top side
	--     if tri_right_top_further == -1 then
	--     (
	-- 		print "-1 juf"
	--       sw = PlaceAdditional top_corners[2] 0 sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_right - (attributes_1[2][2]))) placed_items
	--       road_1.attach sw road_1 
	--       append pts_to_connect_top [attributes_1[2][2], road_1_length/2, 0.0]
	--     )
		if spnr_angle_1.value > 90.0 then
		(
		if spec_1 or spec_2 then place_pl_2 = false
		  sw = PlaceAdditional top_corners[2] (spnr_angle_1.value) sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_1[2][3]) placed_items
		  road_1.attach sw road_1
		)
	--     if tri_left_top_further == -1 then
	--     (
	-- 	print "-1 tuf"
	--       sw = PlaceAdditional top_corners[1] 180 sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_left - (attributes_1[2][1]))) placed_items
	--       road_1.attach sw road_1
	--       append pts_to_connect_top [attributes_1[2][1], road_1_length/2, 0.0]
	--     )
		if spnr_angle_1.value < 90.0 then 
		(
		  if spec_1 or spec_2 then place_pl_2 = false
		  sw = PlaceAdditional top_corners[1] (spnr_angle_1.value) sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_1[2][3]) placed_items
		  road_1.attach sw road_1
		)
		
		
		--bottom side
	-- 	print sidewalk_bb
		roadBotBB =  cutted_road_bb[1][2]
		sidewalkBBLenght = roGenStruct.getLengthBB sidewalk_bb
		parkLineBBLenght = roGenStruct.getLengthBB parking_lane_bb
		
	-- 	format "%\n%\n%\n" roadBotBB sidewalkTopBB parkLineTopBB
	-- 	copy road_1
		
		sidewalk_copy = copy sidewalks[C_SIDEWALK_RIGHT]
		sw = ConvertTo sidewalk_copy editable_poly
		
	-- 	rotate sw (angleaxis rotate_angle [0,0,1])	
		AddRoadSlicer sw (road_width) 2
		
		
		yMove = roadBotBB - sidewalkBBLenght
		if cb_parking_lane_1.state and cb_parking_lane_2.state then (
			yMove -= parkLineBBLenght
			parking_lane_copy = copy parking_lanes[C_PARKING_LANE_RIGHT]
			pl = ConvertTo parking_lane_copy editable_poly
			-- 	rotate parking_lane_copy (angleaxis rotate_angle [0,0,1])
			pl.position = [max_dist_left,yMove,12.265]
			AddRoadSlicer pl (road_width) 2
			sw.position = [max_dist_left,yMove,12.265]
			sw.attach pl pl
		)else(
			sw.position = [max_dist_left,yMove,12.265]
		)

		
		
		if generated_road == undefined then (
			pt1 = point wirecolor:red
			roGenStruct.SetPointAppearance pt1
			tn1 = point wirecolor:red
			-- hide tn1
			append pt1.children tn1
			pt2 = point wirecolor:red
			roGenStruct.SetPointAppearance pt2
			tn2 = point wirecolor:red
			-- hide tn2
			append pt2.children tn2
		)else(
			pt1 = pRight
			tn1 = pRight.children[1]
			pt2 = pLeft
			tn2 = pLeft.children[1]
		)
		pt1.position = [max_dist_right, 0, 0]/*+road_1.position*/
		tn1.position = [max_dist_right+C_TANGENT_OFFSET, 0, 0]
		pt2.position = [max_dist_left, 0, 0]/*+road_1.position*/
		tn2.position = [max_dist_left-C_TANGENT_OFFSET, 0, 0]
		
		--Bottom Point and Tangent:
		if pBot == undefined then(
			pBot = point wirecolor:red
			roGenStruct.SetPointAppearance pBot
			tnBot = point wirecolor:red
			-- hide tnBot
			append pBot.children tnBot
		)else(
			tnBot = pBot.children[1]
		)
			
		pBot.position = [0, yMove, 0]/*+road_1.position*/
		tnBot.position = [0, yMove-C_TANGENT_OFFSET, 0]
		
		
		
		append road_1.children pt1
		append road_1.children pt2
		append road_1.children attributes_1[1][4]
		append road_1.children pBot
		
		
		

		qsort pts_to_connect_top ComparePointX
	--     qsort pts_to_connect_bottom ComparePointXRev
		
	-- 	format "%\n" pts_to_connect_top
		
		top_width = road_width
		top_road_left = (abs road_left)
		for pt in pts_to_connect_top do (
		  --print ("Pt: "+(pt.x as string))
		  --print ("Top width: "+(top_width as string))
		  --print ("Top road left: "+(top_road_left as string))
		  t = ((pt.x+top_road_left)/(top_width))
		  --print ("Coef: "+(t as string))
		  if road_edge_indices[1][2] then
			road_1.insertVertexInEdge road_edge_indices[1][1]  (t)
		  else 
			road_1.insertVertexInEdge road_edge_indices[1][1]  (1.0-t)
		  top_width = road_right - pt.x
		  top_road_left = -pt.x
		)
		
		
		
		
	-- 	format "%\n" attributes_1[1][3]
		road_1.attach top_corners[1] road_1
		road_1.attach top_corners[2] road_1
		road_1.attach attributes_1[1][3] attributes_1[1][3]
		
		
		FinishCrossRoadSetups road_1 dlgCrossroadGenerator3 controlsArr finalPos #ThreeR sw:sw weldThreshold:1.0 -- 1.5 
	)
  )
  
  
  
  
  
  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  ## FLIPPED  ##############################	FLIPPED	################################ 	FLIPPED ##
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  on btn_generate2 pressed do
  ( 
	undo off(
		PreSetupAndChecks &generated_road &finalPos
		
		spec_1 = (not cb_parking_lane_1.state) and cb_parking_lane_2.state
		spec_2 = cb_parking_lane_1.state and (not cb_parking_lane_2.state)
		
		
		
		------------------------------------------------------------------------------------------------------------
		road_1_model = undefined
		road_2_model = undefined
		plRoad1 = false
		plRoad2 = false
		
		plTopBot = True
		
		if spec_2 != false then(
			road_1_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
			plRoad1 = True
			plTopBot = false
		)
		else road_1_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
		
		if spec_1 != false then(
			road_2_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			plRoad2 = True
			plTopBot = false
		)
		else road_2_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
		if spec_1 != false or spec_2 != false then corner_model  = corners[1]
		else corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
		
		
		
		
		
		
-- 		road_1_model = SelectRoad roads rb_lane_number_1.state rb_lane_width_1.state rb_lane_width_1_1.state spec_1
-- 		road_2_model = SelectRoad roads rb_lane_number_2.state rb_lane_width_2.state rb_lane_width_2_1.state spec_2
		
		
		
-- 		road_1_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
-- 		road_2_model = roGenStruct.pickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
-- 		corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
			
		road_1 = copy road_1_model
		road_1.name = replace road_1.name 11 6 "crossroad_3FR"
		road_1.name = uniquename(road_1.name)
		  
		road_1.position = [0, 0, 0]
	--     road_2_a = copy road_2_model
	--     road_2_a.position = [0, 0, 0]
		road_2_b = copy road_2_model
		road_2_b.position = [0, 0, 0]
		
		
		---------------------------------------------------------------------------
		if plRoad1 then delete road_1_model
		if plRoad2 then delete road_2_model
		---------------------------------------------------------------------------
		  
		  
		-- 	GenereteCrossRoad road_1 road_2_a road_2_b corner_model spnr_angle_1.value spnr_angle_2.value spnr_offset_1.value spnr_offset_2.value cb_parking_lane_1.state cb_parking_lane_2.state
		  
		road_1_bb = roGenStruct.getBoundingBox road_1
		road_2_bb = roGenStruct.getBoundingBox road_2_b
		
		road_1_length = roGenStruct.getLengthBB road_1_bb
		
		corner_bb = roGenStruct.getBoundingBox corner_model
		
		
		pTop 	= undefined
		pBot 		= undefined
		pRight 	= undefined
		pLeft 	= undefined
		if generated_road != undefined then (
			pTop 	= generated_road.kids[3]
			pBot 		= generated_road.kids[4]
			pRight 	= generated_road.kids[1]
			pLeft 	= generated_road.kids[2]
		)
		
		
	-- 	flippedAngle = abs(90 - spnr_angle_1.value)
	-- 	format "%\n" flippedAngle
		
		flippedAngle = 90
		if spnr_angle_1.value < 90 then flippedAngle += abs(flippedAngle - spnr_angle_1.value)
		if spnr_angle_1.value > 90 then flippedAngle -= abs(flippedAngle - spnr_angle_1.value)
		
	-- 	format "%\n" flippedAngle
	--     attributes_1 = CreateConnectingRoad road_2_a road_1_bb road_2_bb corner_model corner_bb spnr_angle_1.value placed_items 0 spnr_offset_1.value
		attributes_2 = CreateConnectingRoad road_2_b road_1_bb road_2_bb corner_model corner_bb flippedAngle placed_items 180 spnr_offset_1.value prevPt:pBot
		
	--     delete road_2_a
		delete road_2_b
		
	--     print ("Attr1: "+(attributes_1 as string))
	--     print ("Attr2: "+(attributes_2 as string))
		
	--     top_corners = attributes_1[1]
		bottom_corners = attributes_2[1]
		  
		if not ((cb_parking_lane_1.state) and (cb_parking_lane_2.state)) then
		(
	--       ChangeMaterialId top_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
	--       ChangeMaterialId top_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId bottom_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		  ChangeMaterialId bottom_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
		)
		  
		
-- 	-- 	EDIT:
	--     max_dist_left = roGenStruct.RMin (attributes_1[2][1]) (attributes_2[2][2])
	--     max_dist_right = roGenStruct.RMax (attributes_1[2][2]) (attributes_2[2][1])
		
	-- 	format "%\n%\n" attributes_1[2][1] attributes_1[2][2]
		
		max_dist_left = attributes_2[2][1]
		max_dist_right = attributes_2[2][2]
		
	--     print ("max dist left "+(max_dist_left as string)) 
	--     print ("max dist right "+(max_dist_right as string))
		
		AddRoadSlicer road_1 (max_dist_right) 3
		AddRoadSlicer road_1 (max_dist_left) 2

		
		road_1 = ConvertTo road_1 editable_poly
		cutted_road_bb = roGenStruct.getBoundingBox road_1
		--AddRoadSlicer road_1 (attributes_1[2][4]) 1
		--AddRoadSlicer road_1 (attributes_2[2][4]) 1
		  
		road_edge_indices = GetRoadEdgeIndices road_1
		  
		  
		tri_left_top_further = -1
		tri_right_top_further = -1
		
		
		sidewalk_bb = roGenStruct.getBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = roGenStruct.getBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		  
-- 		place_pl_1 = cb_parking_lane_1.state or cb_parking_lane_2.state
		place_pl_2 = cb_parking_lane_1.state or cb_parking_lane_2.state
		

-- 		place_pl_1 = spec_1
-- 		place_pl_2 = spec_2
	
	
	--     pts_to_connect_top = #()
		pts_to_connect_bottom = #()
	--     append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
		
	-- 	format "%\n" pts_to_connect_top
		append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
		  
		road_width = (roGenStruct.getWidthBB cutted_road_bb)
		road_left = (roGenStruct.getLeftBB cutted_road_bb)
		road_right = (roGenStruct.getRightBB cutted_road_bb)
		
	-- 	print road_left
		
		--top side
		-- 	print sidewalk_bb
	-- 	format "%\n" cutted_road_bb
		roadTopYBB =  cutted_road_bb[2][2]
		sidewalkBBLenght = roGenStruct.getLengthBB sidewalk_bb
		parkLineBBLenght = roGenStruct.getLengthBB parking_lane_bb
		
		
		--bottom side

	--     if tri_right_top_further == 1 then
	--     (
	-- 		sw = PlaceAdditional bottom_corners[1] 0 sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_right - (attributes_2[2][1]))) placed_items
	--       road_1.attach sw road_1
	--       append pts_to_connect_bottom [attributes_2[2][1], -road_1_length/2, 0.0]
	--     )
		if spnr_angle_1.value < 90.0 then
		(
			if spec_1 or spec_2 then place_pl_2 = false

			sw = PlaceAdditional bottom_corners[2] (flippedAngle +180) sidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_2[2][3]) placed_items
			road_1.attach sw road_1
		)
	--     if tri_left_top_further == 1 then
	--     (
	--       sw = PlaceAdditional bottom_corners[2] 180 sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_left - (attributes_2[2][2]))) placed_items
	--       road_1.attach sw road_1
	--       append pts_to_connect_bottom [attributes_2[2][2], -road_1_length/2, 0.0]
	--     )
		if spnr_angle_1.value > 90.0 then
		(
			if spec_1 or spec_2 then place_pl_2 = false
			sw = PlaceAdditional bottom_corners[1] (flippedAngle + 180) sidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 parking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_2[2][3]) placed_items	
			road_1.attach sw road_1
		)
		
		
		
		
		--TOP SIDE
		sidewalk_copy = copy sidewalks[C_SIDEWALK_LEFT]
		sw = ConvertTo sidewalk_copy editable_poly
		
	-- 	rotate sw (angleaxis rotate_angle [0,0,1])	
		AddRoadSlicer sw (road_width) 2
		
		
		yMove = roadTopYBB + sidewalkBBLenght
		if cb_parking_lane_1.state and cb_parking_lane_2.state then (
			yMove += parkLineBBLenght
			parking_lane_copy = copy parking_lanes[C_PARKING_LANE_LEFT]
			pl = ConvertTo parking_lane_copy editable_poly
			-- 	rotate parking_lane_copy (angleaxis rotate_angle [0,0,1])
			pl.position = [max_dist_right,yMove,12.265]
			AddRoadSlicer pl (road_width) 2
			sw.position = [max_dist_right,yMove,12.265]
			sw.attach pl pl
		)else(
			sw.position = [max_dist_right,yMove,12.265]
		)
		
		
		if generated_road == undefined then (
			pt1 = point wirecolor:red
			roGenStruct.SetPointAppearance pt1
			tn1 = point wirecolor:red
			-- hide tn1
			append pt1.children tn1
			pt2 = point wirecolor:red
			roGenStruct.SetPointAppearance pt2
			tn2 = point wirecolor:red
			-- hide tn2
			append pt2.children tn2
		)else(
			pt1 = pRight
			tn1 = pRight.children[1]
			pt2 = pLeft
			tn2 = pLeft.children[1]
		)
		
		pt1.position = [max_dist_left, 0, 0]/*+road_1.position*/
		tn1.position = [max_dist_left+C_TANGENT_OFFSET, 0, 0]--<<<<<<<<<<<<<<<
		pt2.position = [max_dist_right, 0, 0]/*+road_1.position*/
		tn2.position = [max_dist_right-C_TANGENT_OFFSET, 0, 0]  --<<<<<<<<<<<<<<<
		
		--Top Point and Tangent:
		if pTop == undefined then(
			pTop = point wirecolor:red
			roGenStruct.SetPointAppearance pTop
			tnTop= point wirecolor:red
			-- hide tnTop
			append pTop.children tnTop
		)else(
			tnTop = pTop.children[1]
		)
			
		pTop.position = [0, yMove, 0]/*+road_1.position*/
		tnTop.position = [0, yMove+C_TANGENT_OFFSET, 0]
		

		append road_1.children pt1
		append road_1.children pt2
		
		append road_1.children pTop
		append road_1.children attributes_2[1][4]
		
		
		
		
	--     qsort pts_to_connect_top ComparePointX
		qsort pts_to_connect_bottom ComparePointXRev
		
		
		
		bottom_width = road_width
		bottom_road_right = (abs road_right)
		bottom_road_left = abs road_left
		for pt in pts_to_connect_bottom do (
		  --print ("Pt: "+(pt.x as string))
		  --print ("Bottom width: "+(bottom_width as string))
		  --print ("Bottom road left: "+(bottom_road_right as string))
		  t = ((bottom_road_left+pt.x)/(bottom_width))
		  --print ("Coef: "+(t as string))
		  if road_edge_indices[2][2] then
			road_1.insertVertexInEdge road_edge_indices[2][1]  (1.0-t)
		  else 
			road_1.insertVertexInEdge road_edge_indices[2][1]  (t)
		  bottom_width = abs (pt.x - road_left)
		  bottom_road_right = pt.x
		)
		
		
		road_1.attach bottom_corners[1] road_1
		road_1.attach bottom_corners[2] road_1
		road_1.attach attributes_2[1][3] attributes_2[1][3]
		
		FinishCrossRoadSetups road_1 dlgCrossroadGenerator3 controlsArr finalPos #ThreeFR sw:sw weldThreshold: 1.0 -- 1.5 
	)
  )
)

--###################################################################################
--															HELP FN ROADS and TURNS
--###################################################################################


-- some functions are shared with croasroad generator

fn HasObjProperty obj prop_name prop =
(
	if obj == undefined do
	(
		return false
	)
	item_prop = getUserProp obj prop_name
	return ((stricmp (item_prop as string) (prop as string)) == 0)
)


---------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------

fn EditSplineTangents road =
(
	max modify mode
	select road.roadSpline
	subobjectLevel = 1
	macros.run "Tools" "SmartScale"
)

---------------------------------------------------------------------------------------------------------------------



--###################################################################################
--															ROADS
--###################################################################################

rollout RoadGeneratorTool "Road Generator" (	

	local list_items = roGenStruct.getUIPrefabsIcons()
	group "" (
	
		dropdownlist dd_road_prefabs_1 "" items:list_items height:list_items.count
		checkbox  cb_parking_lane_left "Parking lane Left" checked:true align:#left offset:[0,5]
		checkbox  cb_parking_lane_right "Parking lane Right" checked:true align:#right offset:[3,-22]
		checkbox  cb_sidewalks_right "Sidewalks Right   " checked:true align:#right offset:[0,5]
		checkbox  cb_sidewalks_left "Sidewalks Left" checked:true align:#left offset:[0,-17]
		spinner spinner_tangent "Density: " range:[0,90.0,4.0] scale:0.05 type:#float allign:#left offset:[0,10] width:70 across:3 
		spinner spinner_rotate "Rotate: " range:[-90,90.0,0.0] scale:0.5 type:#float allign:#center offset:[0,10] width:70
		spinner spinner_twist "Twist: " range:[-90,90.0,0.0] scale:0.5 type:#float allign:#right offset:[0,10] width:70
	)
	
	button btn_edit_tangents "Edit Tangents" width: 100 height: 35 offset:[-50, 10] align:#center toolTip:"Edit Tangents\nHint:Insert new wertices on spline if you need."
	button btn_sync_spline "Sync Spline" width: 100 height: 35 offset:[50, -40] align:#center toolTip:"Snap spline Start, End points and Rebuild curve."
	checkbox cb_update_curve "Sync Curve" checked:true align:#right offset:[0,5]
	button btn_generate_old "Generate Road" width: 120 height: 35 align:#left offset:[0, 10] align:#center across:2 
	button btn_generate "Generate Road New" width: 120 height: 35 offset:[0, 10] align:#right enabled:false
	button bt_gen_shortcut_old "Generate Shortcut" width:120 height:35 offset:[0,0] align:#left across:2
	button bt_gen_shortcut "Generate Shortcut New" width:120 height:35 offset:[0,0] align:#right enabled:false

	local roads = #()
	local specs = #()
	local dummies = #()
	local controlsArr = #(dd_road_prefabs_1, cb_parking_lane_left, cb_parking_lane_right, cb_sidewalks_left, cb_sidewalks_right, spinner_tangent, spinner_twist, spinner_rotate)
	
	on RoadGeneratorTool open do (
	
		roGenStruct.collectRoadPrefabs &roads &specs
	)
	on bt_gen_shortcut_old pressed do (roGenStruct.generateRoadShortcut RoadGeneratorTool old_way:true)
	on bt_gen_shortcut pressed do (roGenStruct.generateRoadShortcut RoadGeneratorTool old_way:false)
	on btn_generate_old pressed do (roGenStruct.generateRoad RoadGeneratorTool roads specs old_way:true)
	on btn_generate     pressed do (roGenStruct.generateRoad RoadGeneratorTool roads specs old_way:false)
	

	-----------------------------------------------------------------------------------
	on btn_edit_tangents pressed do
	(
		road = selection[1]
		-->MerlinEL 26.4.2019
		if not (roGenStruct.isRoad road) then (
			
			format "btn_edit_tangents > Unable edit Tangents on:%\n" road.name
			
		) else (
		--<
			max modify mode
			select road.roadSpline
			subobjectLevel = 1
			toolMode.uniformScale()
			--macros.run "Tools" "SmartScale"
		)
	)
	
	on btn_sync_spline pressed do roGenStruct.syncSpline cb_update_curve.state
	-----------------------------------------------------------------------------------
)




--###################################################################################
-- 														DIALOG FLOATER
--###################################################################################

-- createDialog dlgPickObjectType
Global floaterGenerator
try(closeRolloutFloater  floaterGenerator)catch()
floaterGenerator = newRolloutFloater "" 320 440

floaterGenerator.pos = [400,250]



--###################################################################################
--															GUI HELP FUNCTIONS
--###################################################################################


fn ClearRollFloater floater =
(
	rollOuts = floater.rollouts
	count =  rollOuts.count
-- 	print count
	if count > 1 then (
		for i in count to 2 by -1 do removeRollout rollOuts[i] floater
	)
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rollout rGeneratorUtilities "Generator Utilities"
(
	group "Advanced Tools:" (
	
		button bt_show_road_color_table "Road Colors" offset:[0,0] width:100 height:25 toolTip:"Road Color Types"
		button bt_generate_custom_road "Custom Road Gnerator" offset:[0,0] width:140 height:25 toolTip:"Generate road from prefab and spline"
	)
	group "Analiysis and Repair:" (
	
		button bt_FixDuplicitNames "Unique Names" offset:[0,0] width:100 height:25 align:#left toolTip:"Fix duple names" across:2
		button bt_roadAnatomy "Road Anatomy" offset:[0,0] width:100 height:25 align:#right toolTip:"Show - Repair roads hierarchy"
		button bt_ReloadPrefabs "Reload Prefabs" offset:[0,0] width:100 height:25 align:#left toolTip:"Delete old prefabs and load new ones" across:2
		button bt_validate_roads "Validate Sel Roads" offset:[0,0] width:100 height:25 align:#right toolTip:"Validate Roads Structure"
		button bt_distr_to_laers "Redistribute Sel" offset:[0,0] width:100 height:25 align:#left toolTip:"Move road in to layers(name is teaken from Node)" across:2
		button bt_sel_unlinked_roads "Sel Orphan Roads" offset:[0,0] width:100 height:25 align:#right toolTip:"Select roads which are not linked"
	)
	group "Manage:" (
	
		label lbl_1 "Show - Hide objects which contains a Word:" offset:[0, 0] width:284 height:14 align:#left
		button btn_show_objs "Show" offset:[0,0] width:56 height:17 align:#left across:3 toolTip:"Unhide Objects By Name"
		button btn_hide_objs "Hide" offset:[-20,0] width:56 height:17 align:#left toolTip:"Hide Objects By Name"
		editText edt_sh_name "" offset:[-40,0] width:120 height:17 align:#left text:"building"
		button bt_hidePoints "Hide Help Points"	width:100 height:25 align:#left toolTip:"Hide Road Help Points" across:2 
		button bt_UnhideRoadsFull "Unhide Help Points"	width:100 height:25 align:#right toolTip:"Unhide Roads Help Points"
		button bt_SelectVisuals "Select Roads" width:100 height:25 align:#left toolTip:"Select Roads Geometry" across:2
		button bt_SelectColls 	"Select Collisions" width:100 height:25 align:#right toolTip:"Select Road Collisions"
		button bt_SelectChildren "Select Help points" width:100 height:25 toolTip:"Select Road Help Points"
	)
	on bt_hidePoints			pressed do ( roGenStruct.hideHelpPoints()										)
	on bt_SelectVisuals			pressed do ( roGenStruct.selectVisuals()										)
	on bt_SelectColls			pressed do ( roGenStruct.selectCollisions()										)
	on bt_SelectChildren		pressed do ( roGenStruct.selectChildren()										)
	on bt_FixDuplicitNames		pressed do ( roGenStruct.fixDuplicitNames()										)
	on bt_UnhideRoadsFull		pressed do ( roGenStruct.unhideRoadsFull()										)
	on bt_roadAnatomy			pressed do ( runLocalScript "Road_Generator_Anatomy"								)
	on bt_show_road_color_table	pressed do ( runLocalScript "Road_Generator_Colors"								)
	on bt_ReloadPrefabs			pressed do ( roGenStruct.reloadPrefabs(getSourceFileName())						)
	on btn_show_objs 			pressed do ( roGenStruct.showObjectsByNamePart objects edt_sh_name.text true	)
	on btn_hide_objs 			pressed do ( roGenStruct.showObjectsByNamePart objects edt_sh_name.text false	)
	on bt_validate_roads		pressed do ( roGenStruct.validateSelectedRoads()								)
	on bt_distr_to_laers		pressed do ( roGenStruct.distributeRoadsInToLayers()							)
	on bt_generate_custom_road	pressed do ( runLocalScript	"Road_Generator_Custom"								)
	on bt_sel_unlinked_roads	pressed do ( roGenStruct.selectUnlinkedRoads()									)
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rollout dlgPickObjectType "Menu"
(
 
	local roll_all_size = #([320,440], [320,420], [320,470]) --"CROSSROAD",  "ROAD", "UTILITIES"
	local roll_crossroad_size = #([320,440], [320,520], [320,420]) --"CROSSROAD",  "ROAD", "UTILITIES"
	radiobuttons rb_type labels:#("CROSSROAD    ",  "ROAD               ", "UTILITIES") default:1 align:#left  columns:1   --"TURN                           "
	dropdownlist dd_crossroad_types "" items:#("2 Side Roads", "2 Different Side Roads", "1 Side Road" ) height:6  offset:[100,-50] width:140
	button bt_createColl "Create Collisions" offset:[55, -5] width:140 height:25 visible:false
	button bt_copyUniqueCrossRoad "Copy Unique CrossRoad" offset:[55,-3] width:140 height:25 visible:false
	button bt_adjustTangentsLength "Adjust Tangets Length" offset:[55,-80] width:140 height:25 visible:false
	button bt_copyUniqueShortcut "Copy Unique Shortcut" offset:[55,0] width:140 height:25 visible:false
	dropDownList ddl_material_sets "" offset:[-15, -70] width:140 height:21 align:#right items:#("Road Material Set 1", "Road Material Set 2", "Road Material Set 3") visible:false
-- 	label fill ""
	fn setCrosroadRoll index arr_sizes = (
	
		floaterGenerator.size = arr_sizes[index]
		Case (index) of (
		
			1 : addRollout dlgCrossroadGenerator floaterGenerator
			2 : addRollout dlgCrossroadGenerator2 floaterGenerator
			3 : addRollout dlgCrossroadGenerator3 floaterGenerator
		)
	)
	fn switchRadioButton index crossRoadType: 1=
	(
		BM_SETCHECK = 241		-- checkbutton toggle message ID
		WM_COMMAND = 273		-- windows command message
		BN_CLICKED = 0				-- clicky message ID
		
		parent = dlgPickObjectType.hwnd
		maxChildren = windows.getChildrenHWND parent
		crossBtnID 	= maxChildren[2][1]
		roadBtnID 	= maxChildren[3][1]
		utilsBtniD 	= maxChildren[4][1]
		
		if index == 1 then (
			dd_crossroad_types.selection = crossRoadType
			resId = UIAccessor.getWindowResourceID crossBtnID
			windows.sendMessage crossBtnID 241 1 0
			windows.sendMessage roadBtnID 241 0 0
			windows.sendMessage utilsBtniD 241 0 0
			windows.sendMessage parent WM_COMMAND ((bit.shift BN_CLICKED 16) + resId) crossBtnID
		)
		
		if  index == 2 then (
			resId = UIAccessor.getWindowResourceID roadBtnID
			windows.sendMessage crossBtnID 241 0 0
			windows.sendMessage roadBtnID 241 1 0
			windows.sendMessage utilsBtniD 241 0 0
			windows.sendMessage parent WM_COMMAND ((bit.shift BN_CLICKED 16) + resId) roadBtnID
		)
-- 		format "%\n%\n" crossBtnID roadBtnID
	)

	on rb_type changed arg do (

		ClearRollFloater floaterGenerator
		Case (arg) of ( --"CROSSROAD",  "ROAD", "UTILITIES"
		
			1: (--crossroad menu group
			
					setCrosroadRoll dd_crossroad_types.selection roll_crossroad_size
					dd_crossroad_types.visible = True
					bt_copyUniqueCrossRoad.visible = True
					bt_copyUniqueShortcut.visible = false
					bt_adjustTangentsLength.visible = false
					bt_createColl.visible = false
					ddl_material_sets.visible = false
					dlgPickObjectType.height = 90 --Menu dialog height
				)
			2 :(	--road menu group
			
					floaterGenerator.size = roll_all_size[arg]
					addRollout RoadGeneratorTool floaterGenerator
					dd_crossroad_types.visible = False
					bt_copyUniqueCrossRoad.visible = false
					bt_copyUniqueShortcut.visible = true
					bt_adjustTangentsLength.visible = true
					bt_createColl.visible = false
					ddl_material_sets.visible = false
					dlgPickObjectType.height = 65 --Menu dialog height
				)
			3 :(	--utilites menu group
			
					floaterGenerator.size = roll_all_size[arg]
					addRollout rGeneratorUtilities floaterGenerator
					dd_crossroad_types.visible = False
					bt_copyUniqueCrossRoad.visible = false
					bt_copyUniqueShortcut.visible = false
					bt_adjustTangentsLength.visible = false
					bt_createColl.visible = True
					ddl_material_sets.visible = True
					dlgPickObjectType.height = 65 --Menu dialog height
			)
		)
	)
	
	on ddl_material_sets selected sel do roGenStruct.switchRoadMaterials sel
	
	on dd_crossroad_types selected  arg do ( --"2 Side Roads", "2 Different Side Roads", "1 Side Road"
	
		ClearRollFloater floaterGenerator
		setCrosroadRoll arg roll_crossroad_size
	)	
	
	on dlgPickObjectType open do (
	
		dlgPickObjectType.height = 90
	)
	
	on dlgPickObjectType close do (
		callbacks.removeScripts id:#crossGenRoll
		callbacks.removeScripts id:#crossGenDell
		callbacks.removeScripts id:#removeCAs
	)

	on bt_copyUniqueCrossRoad pressed do (roGenStruct.copyUniqueCrossRoad $ hidden_tn:false)
	on bt_adjustTangentsLength pressed do (roGenStruct.adjustTangentsLength())
	on bt_copyUniqueShortcut pressed do (roGenStruct.copyUniqueShortcut $ hidden_tn:false)
	-------------------------------------------------	COLLS -------------------------------------------------------------------------
	on bt_createColl pressed do (runLocalScript "Road_Generator_Collisions")
)
-- createDialog dlgPickObjectType





addRollout dlgPickObjectType floaterGenerator
addRollout dlgCrossroadGenerator floaterGenerator
-- addRollout RoadGeneratorTool floaterGenerator



--###################################################################################
-- 														CALLBACKS:
--###################################################################################
fn CrossRoadDelete =
(
	if not roGenStruct.All_CALLBACKS_ENABLED do return OK
	local params = callbacks.notificationParam()

	if matchPattern params.name pattern:"generator_crossroad_4*" or matchPattern params.name pattern:"generator_crossroad_3*"then(
		roGenStruct.deleteCrossRoadChildren params
	)
	
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn CleanCAs =
(
	if not roGenStruct.All_CALLBACKS_ENABLED do return OK
	local params = callbacks.notificationParam()
	if params[3] == 0 then (  -- copy
		for obj in params[2] do(
			if matchPattern obj.name pattern:"generator_crossroad_4*" or matchPattern obj.name pattern:"generator_crossroad_3*"then(
				obj.kids = #()
			)
		)
	)
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn ReadControlsFromRoad roadObj=
(
	controlsSetups = filterString roadObj.controlsStr ";"	
	for cntrSetup in controlsSetups do execute cntrSetup
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn whenSelecteRoad =
(
	if not roGenStruct.All_CALLBACKS_ENABLED do return OK
	if not roGenStruct.SLECT_OBJECT_CALLBACK_ENABLED do return OK
	sel = (selection as array)[1]
	if selection.count == 1 then (
		if classof sel == editable_poly and (matchPattern sel.name pattern:"generator_*road_*") then (
			check = false 
			
			if matchPattern sel.name pattern:"generator_crossroad_4R*" then(
				dlgPickObjectType.switchRadioButton 1 crossRoadType:1
				check = True
			)
			
			if matchPattern sel.name pattern:"generator_crossroad_4DR*" then(
				dlgPickObjectType.switchRadioButton 1 crossRoadType:2
				check = True
			)
			
			if matchPattern sel.name pattern:"generator_crossroad_3*" then(
				dlgPickObjectType.switchRadioButton 1 crossRoadType:3
				check = True
			)

			if matchPattern sel.name pattern:"generator_connect_road*" then(
				dlgPickObjectType.switchRadioButton 2
				check = True
			)
			
			if check then ReadControlsFromRoad sel
		)
	)
	
	if selection.count == 2 then (
		pointCheck = false
		for obj in selection do(
			if classof obj == Point then pointCheck = True
		)
		if pointCheck == True then (
			dlgPickObjectType.switchRadioButton 2
		)
	)
)
--###################################################################################
callbacks.addscript #nodePreDelete "CrossRoadDelete()" id:#crossGenDell
callbacks.addscript #selectionSetChanged "whenSelecteRoad()" id:#crossGenRoll
callbacks.addscript #postNodesCloned "CleanCAs()" id:#removeCAs
--###################################################################################


-- setup rollouts on start (depends on selection [nothing, road, crossroad]) MerlinEl 2019
whenSelecteRoad()


-- removeRollout  dlgCrossroadGenerator theNewFloater