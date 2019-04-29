-------------------------
--> MerlinEl 1.3.2019
-------------------------
/* Mod List:

*@Modifications

	fill_material = MaterialModifier materialId:7 name:"fill_material"
	roGenStruct.setVertexColor fill_poly red 0		
	on bt_fixBrokenCrossroad pressed do roGenStruct.fixBrokenCrossroad selection[1]
	on bt_roadAnatomy pressed do runLocalScript "Road_Generator_Anatomy"
	on bt_showRoadColorTable pressed do runLocalScript "Road_Generator_Colors"
	if not (roGenStruct.isRoad road) do (
	FinishCrossRoadSetups road_1 dlgCrossroadGenerator3 controlsArr finalPos #ThreeR sw:sw weldThreshold: 1.0 ---1.5  (2x)
*/

/**
*@Example
	runLocalScript "Road_Generator_Anatomy"
	runLocalScript "Road_Generator_Colors"
*/
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
--Load all functions
runLocalScript "Road_Generator_Struct"
--< MerlinEl


gRoadGenCa = attributes RoadGenCa
attribID:#(0x2949a7a0, 0x5246449a)
(
	parameters params(
		roadSpline 		type:#node
		startPoint		type:#node
		endPoint			type:#node
		controlsStr		type:#string
	)
)

-------------------------------------------------------------------------------------
gSplineGenCa = attributes SplineGenCa
attribID:#(0x2d6fe027, 0x4236cbe9)  ---- buuuuu
(
	parameters params(
		road 			type:#string
	)
)


-------------------------------------------------------------------------------------  <<<<<<<<<
gCACrossRoadKids = attributes CrossRoadKids
attribID:#(0x449b771a, 0x1d589bab)
(
	parameters params(
		kids 			type:#nodeTab tabSizeVariable:true
		controlsStr type:#string
	)
)


--###################################################################################
-- 															ASCII SIGNS
--###################################################################################
one_six 		= bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604
two_two	= bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 12140 +" "+ bit.intAsChar 12140 + bit.intAsChar 9604 + bit.intAsChar 9604
two_four	= bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " "+ bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604
two_four_r	= bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 12140 + " "+ bit.intAsChar 12140 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604
two_five		= bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " "+ bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604

four_four	= bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " "+ bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " " + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604  + " "+ bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 
four_five 	= bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " " + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " "+ bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " " + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + bit.intAsChar 9604 + " "

main_sign 	= bit.intAsChar 10134
top_sign 	= bit.intAsChar 10200
bot_sign		= bit.intAsChar 10201
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
-- C_COMPONENTS_PATH = LS3DGUP.LS3DGUP.UtilsPath+"terrain_generator_components.max"
C_COMPONENTS_PATH = "D:\\!2K_Games\\scotch_dev\\resources\\graphics\\_data_\\3dsmax\\terrain_generator_components.max"

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

C_FLOAT_MAX = 2147483647

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
  
  fn SetNormal nor =
  (
	  normal = nor
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
  ),  
  
  fn PrintParams =
  (
		print ("Plane pos: "+(position as string)+"nor: "+(normal as string))
  ),
  
  fn Project pt =
  (
	  w = -(normal.x * position.x + normal.y * position.y + normal.z * position.z)
	  t = -(w + normal.x * pt.x + normal.y * pt.y + normal.z * pt.z)/(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z)
	  --print ("w: "+(w as string)+" t: "+(t as string)) 
	  new_pt = pt + normal * t
	  return new_pt
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

fn CompareFloat val1 val2 =
(
	if (abs (val1 - val2)) < 0.01 then
		return 0
	else if val1 > val2 then
		return 1
	else
		return -1
)

fn RMin a b =
(
	if a > b then return b else return a
)

fn RMax a b =
(
	if a < b then return b else return a
)	

fn ReverseArray arr =
(
	new_arr = #()
	for i in arr.count to 1 by -1 do
	(
		--swap_items arr[i] arr[arr.count-i+1]
		append new_arr arr[i]
	)
	return new_arr
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

--print vertices
fn PrintVertices edit_pol =
(
	for i in 1 to edit_pol.GetNumVertices() do
	(
		v = edit_pol.GetVertex i
-- 		print v
	)
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

--get width of bounding box
fn GetWidthBB bb =
(
	return abs(bb[2].x - bb[1].x)
)

--get length of bounding box
fn GetLengthBB bb =
(
	return abs (bb[2].y - bb[1].y)
)

--get height of bounding box
fn GetHeightBB bb =
(
	return abs (bb[2].z - bb[1].z)
)

fn GetBottomBB bb =
(
	return bb[1].z
)

fn GetTopBB bb =
(
	return bb[2].z
)

fn GetFrontBB bb =
(
	return bb[1].y
)

fn GetLeftBB bb =
(
	return bb[1].x
)

fn GetRightBB bb =
(
	return bb[2].x
)	

fn GetBoundingBox &poly = 
(
	local p_min = [C_FLOAT_MAX, C_FLOAT_MAX, C_FLOAT_MAX]
	local p_max = [-C_FLOAT_MAX, -C_FLOAT_MAX, -C_FLOAT_MAX]

	--go through all vertices and find min and max
	local numVert = poly.GetNumVertices()
	for i in 1 to numVert do
	(
		if not (polyop.isVertDead poly i) then (
			v = poly.GetVertex i
			p_min = [RMin p_min.x v.x, RMin p_min.y v.y, RMin p_min.z v.z]
			p_max = [RMax p_max.x v.x, RMax p_max.y v.y, RMax p_max.z v.z]
		)
	)
	
	bb = #(p_min, p_max)
	
	--print ("BB: "+(GetWidthBB bb as string)+" "+(GetLengthBB bb as string)+" "+(GetHeightBB bb as string))
	--print ("Bottom: "+(GetBottomBB bb as string)+" "+(GetTopBB bb as string))
			
	return bb
)

fn DrawBoundingBox pos bb =
(
	bb_box = box pos:pos width:(GetWidthBB bb) length:(GetLengthBB bb) height:(GetHeightBB bb)
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


--returns arrays with unique values
fn UniqueArr arr =
(
	new_arr = #()
	for o in arr do (
		appendIfUnique new_arr o
	)
	return new_arr
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
				min = RMin left_top_index right_top_index
				if(min == left_top_index) then (
					top_left_to_right = false
				)
			)
			if (ArrayContainsValue controlled_edge left_bottom_index) and (ArrayContainsValue controlled_edge right_bottom_index) then (
				bottom_edge_index = i
				min = RMin left_bottom_index right_bottom_index
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
	radius = GetWidthBB bb
	vertices = #()
	
	for i in 1 to corner.GetNumVertices() do
	(
		v = corner.GetVertex i
		if (distance v [0, 0, 0]) > (radius*0.95) and v.z < (GetBottomBB bb + (GetHeightBB bb)/2) and (not (polyop.isVertDead corner i)) then 
		(
			append vertices v
		)
	)
	
	qsort vertices ComparePointAngular
	
	if fromBottom == true then
	(
		vertices = ReverseArray vertices
	)
	
	return vertices
)

fn CheckResource file fileName =
(
	if file == undefined then
	(
		MessageBox (fileName+" resources is missing")
		throw fileName
	)
)



--#########################################################
fn SetPointAppearance p =
(
	p.size = 600
	p.centermarker = off
	p.axistripod = off
	p.cross = on
	p.Box = on
	p.constantscreensize = off
	p.drawontop = off
-- 	p.wirecolor = color 87 225 87
	p.wirecolor = color 27 177 27
)
--#########################################################
fn SetCrossRoadWireColor crossRoad oldColor:undefined=
(
	if oldColor != undefined then(
		crossRoad.wirecolor = oldColor
	)else crossRoad.wirecolor = color 7 206 224
)
--#########################################################







fn CreateConnectingRoad road_2 bb_1 bb_2 corner bb_corner angle_road placed_items rotate_angle offset prevPt:undefined=
(
	left_corner = CreateRoadCorner corner (angle_road) bb_corner

	right_corner = CreateRoadCorner corner (180-angle_road) bb_corner
	
	radius = (GetWidthBB bb_corner)
	--print ("Radius:"+(radius as string))
	l1 = (GetLengthBB bb_1)/2 + radius
	l2 = (GetLengthBB bb_2)/2 + radius
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
		
	left_position =  [left_offset, l1, GetHeightBB bb_corner]
	right_position = [right_offset, l1, GetHeightBB bb_corner]

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
		pt = point()
		SetPointAppearance pt		
		/*helper point for tangent determination*/
		tn = point()
		hide tn
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
	road_vertices = ReverseArray road_vertices
			
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
	
	py = (GetLengthBB bb_1)/2*sign
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
	--add universal tilable material in generated geometry > ID 7 (based on multimaterial Road_Material_D) MerlinEl 2019
	fill_material = MaterialModifier materialId:7 name:"fill_material"
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



fn WeldEditPoly epoly precision =
(
	vert_count = (polyop.getNumVerts epoly)
    all_vert_list = #{1..vert_count}
    
	--weld all vertices
    epoly.weldThreshold = precision
    polyop.weldVertsByThreshold epoly all_vert_list
)




--###################################################################################
--														NEW ADDTIONAL FUNCTIONS 
--###################################################################################

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn GetObjFaceCenter obj =
(
	if (selection as array).count == 1 then(
		if (classof obj == Editable_poly) then(
			faceSelect = (polyOp.getFaceSelection obj) as array
			if faceSelect.count == 1 then(
				faceCenter = polyop.getFaceCenter obj faceSelect[1]
				return faceCenter
			)else return false
		)else return false
	)else false
)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn GetRestOfKids kids =
(
	joiningKids = #()				-- hidden points from tangents
	for kid in kids do(
		if kid != undefined then append joiningKids kid.children[1]
		else append joiningKids undefined
	)
	join kids joiningKids
)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn GetKidsOfCrossRoad children =
(
	childCount = children.count
	yPoses = #()
	kids = #() -- list containing normal road points and hidden points
	
	if childCount < 4 then(
		for p in children do append yPoses p.pos.y
		
		thirdPointPos = yPoses[3]
		if thirdPointPos > yPoses[2] then(
			kids[1] = children[1]
			kids[2] = children[2]
			kids[3] = children[3]
			kids[4] = undefined
		)else(
			kids[1] = children[1]
			kids[2] = children[2]
			kids[3] = undefined
			kids[4] = children[3]
		)
	)else(
		select children
		kids = selection as Array
	)
	kids = GetRestOfKids kids
	kids 
	
)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn GetCAControlsSTR dialog controlsArr =
(	
	result = ""
	subStr = ""
	
	for cntr in controlsArr do (
		if classof cntr == SpinnerControl then ( 	-- spinner
			subStr = dialog.name  + "." + cntr.name + ".value = " + (cntr.value as string)
		)
		
		if classof cntr == CheckBoxControl or classof cntr == RadioControl then( -- checkbox, radiobutton
			subStr = dialog.name  + "." + cntr.name + ".state = " + (cntr.state as string)
		)
		
		if classof cntr == ComboBoxControl then (
			subStr = dialog.name  + "." + cntr.name + ".selection = " + (cntr.selection as string)
		)
		
		result += subStr
		result += ";"
	)
	result
)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

fn SetCrossRoadCA obj dialog controlsArr=
(
	custAttributes.add obj gCACrossRoadKids #unique
	obj.kids = GetKidsOfCrossRoad obj.children
	obj.controlsStr = GetCAControlsSTR dialog controlsArr
)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn DeleteCrossRoadChildren obj =
(
	crossChildren = obj.kids
	crossCount = crossChildren.count
	
	for i in crossCount to 1 by -1 do(
		if isValidNode crossChildren[i] then delete crossChildren[i]

	)
)

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
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NEW PREFAB SELECT:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn PickRoadPrefab roads dd_selection spec =
(	
	roadPointer = dd_selection
	
-- 	roadPointer = ((dd_selection - 1) + dd_selection)
-- 	if spec then roadPointer += 1
-- 		
-- 	print roads[roadPointer]
	roads[roadPointer]
)












--###################################################################################
--														FUNCTIONS FROM ROLLOUTS
--###################################################################################
fn CheckPrefabsOfRoads = 
(
-- 	to do add spec files for new prefabs
	
	CheckResource $generator_road_1_6 "generator_road_1_6"   						--<<
	
	CheckResource $generator_road_2_2_rail "generator_road_2_2_rail"				--<<
	
	CheckResource $generator_road_2_4 "generator_road_2_4"
	CheckResource $generator_road_2_4_spec "generator_road_2_4_spec"
	
	CheckResource $generator_road_2_4_rail "generator_road_2_4_rail"				--<<
	
	CheckResource $generator_road_2_5 "generator_road_2_5"
	CheckResource $generator_road_2_5_spec "generator_road_2_5_spec"
-- 	CheckResource $generator_road_2_6 "generator_road_2_6"
-- 	CheckResource $generator_road_2_6_spec "generator_road_2_6_spec"
	CheckResource $generator_road_4_4 "generator_road_4_4"
	CheckResource $generator_road_4_5 "generator_road_4_5"
	CheckResource $generator_road_4_5_spec "generator_road_4_5_spec"
-- 	CheckResource $generator_road_4_6 "generator_road_4_6"
-- 	CheckResource $generator_road_4_6_spec "generator_road_4_6_spec"
	CheckResource $generator_sidewalk_left "generator_sidewalk_left"
	CheckResource $generator_sidewalk_right "generator_sidewalk_right"
	CheckResource $generator_corner "generator_corner"
	CheckResource $generator_corner_p "generator_corner_p"
	CheckResource $generator_parking_lane_left "generator_parking_lane_left"
	CheckResource $generator_parking_lane_right "generator_parking_lane_right"
)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn AppendPrefabsToArrays &roads &sidewalks &corners &parking_lanes =
(
-- 	append new prefabs twice to prevent overflow because of missing spec parts
	
	append roads $generator_road_1_6
-- 	append roads $generator_road_1_6     		--<< instead of spec just For NOW
	
	append roads $generator_road_2_2_rail
-- 	append roads $generator_road_2_2_rail	--<< instead of spec just For NOW
	
	append roads $generator_road_2_4
--     append roads $generator_road_2_4_spec
	
	append roads $generator_road_2_4_rail
-- 	append roads $generator_road_2_4_rail	--<< instead of spec just For NOW		
	
    append roads $generator_road_2_5
--     append roads $generator_road_2_5_spec
	
--     append roads $generator_road_2_6
--     append roads $generator_road_2_6_spec
	append roads $generator_road_4_4
-- 	append roads $generator_road_4_4 			--<< instead of spec just For NOW
	
    append roads $generator_road_4_5
--     append roads $generator_road_4_5_spec
	
--     append roads $generator_road_4_6
--     append roads $generator_road_4_6_spec


    --load sidewalks
    append sidewalks $generator_sidewalk_left
    append sidewalks $generator_sidewalk_right
    --load corners
    append corners $generator_corner
    append corners $generator_corner_p
    --load parking lanes
    append parking_lanes $generator_parking_lane_left
    append parking_lanes $generator_parking_lane_right
)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  fn InitFirstOpenRollout &roads &sidewalks &corners &parking_lanes = 
  (
    layer = LayerManager.getLayerFromName C_LAYER_NAME
--     print ("Layer = "+(layer as string))
    if layer == undefined then (
--       print ("Merging "+C_COMPONENTS_PATH)
		
      mergemaxfile C_COMPONENTS_PATH
      
      try (
		CheckPrefabsOfRoads()				-- check if prefabs are accessible
      ) catch (
        destroyDialog CrossroadGenerator
      )
    )
    
	AppendPrefabsToArrays &roads &sidewalks &corners &parking_lanes	
  )
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn PreSetupAndChecks &generated_road &finalPos=
(
	generated_road = CheckIfSelectionIsRoad()
	finalPos = GetObjFaceCenter $
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
	roadParent = undefined
-- 	road = ConvertTo road Editable_poly
    if sw != undefined then road.EditablePoly.attach sw road
	
	
    vert_count = (polyop.getNumVerts road)
    all_vert_list = #{1..vert_count}
    
    road.weldThreshold = weldThreshold
    polyop.weldVertsByThreshold road all_vert_list
	

	
	SetCrossRoadCA road dialog controlsArr
-- 	CreateNameBuffer road
	
-- 	when road deleted id:#CrossDelete obj do --define a when construct
-- 	(
-- 		DeleteCrossRoadChildren obj
-- 		generated_road = undefined
-- 	)
	
	if generated_road != undefined then (
		road.transform = generated_road.transform
		
		oldWireColor = generated_road.wirecolor
		
		if generated_road.parent != undefined then roadParent = generated_road.parent
		
		generated_road.kids = #()
		FullDelete generated_road

    )else(
		if finalPos != false then road.pos = finalPos
	)

    generated_road = road
	
	SetCrossRoadWireColor generated_road oldColor:oldWireColor
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
	normalRoad = PickRoadPrefab roads crossroadIndex false
	pl_Left =  parkingLanes[1]
	pl_Right = parkingLanes[2]
			
	copyRoad 		= copy normalRoad
-- 	copyLeftPl 		= copy pl_Left
-- 	copyRighttPl	= copy pl_Right
			
	copyRoad.pos 			= [0,0,0]
-- 	copyLeftPl.pos 		= [0,0,0]
-- 	copyRighttPl.pos		= [0,0,0]
			
	bbRoad 			= GetBoundingBox copyRoad
	
-- 			
-- 			-------------------------------------------------------------------------------------
	if leftPL then (
		placeLeftPl 		= [bbRoad[1][1], bbRoad[2][2], 0]
		
		copyLeftPl 			= copy pl_Left
		copyLeftPl.pos 	= [0,0,0]
		bbPlLeft 			= GetBoundingBox copyLeftPl
		copyLeftPl.pivot 	= bbPlLeft[1]
		copyLeftPl.pos 	= placeLeftPl
		
		copyRoad.attach copyLeftPl copyRoad 
	)
	
	if rightPL then (
		placeRightPl		= bbRoad[1]
		
		copyRighttPl		= copy pl_Right
		copyRighttPl.pos	= [0,0,0]
		bbPlRight 			= GetBoundingBox copyRighttPl
		copyRighttPl.pivot= [bbPlRight[1][1], bbPlRight[2][2], bbPlRight[1][3]]
		copyRighttPl.pos		= placeRightPl
		
		copyRoad.attach copyRighttPl copyRoad 
	)
	
	
-- 	bbPlLeft 	= GetBoundingBox copyLeftPl
-- 	print bbPlLeft
-- 	copyLeftPl.pivot = bbPlLeft[1]
-- 			
-- 	bbPlRight 	= GetBoundingBox copyRighttPl
-- 	print bbPlRight
-- 	copyRighttPl.pivot = [bbPlRight[1][1], bbPlRight[2][2], bbPlRight[1][3]]
-- 			
-- 	copyLeftPl.pos 		= placeLeftPl
-- 	copyRighttPl.pos		= placeRightPl
	
-- 	copyRoad.attach copyLeftPl copyRoad 
-- 	copyRoad.attach copyRighttPl copyRoad 

	--MerlinEl 26.4.2019
	WeldEditPoly copyRoad 0.1	
	
	
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
  group " ROAD" 
  (
	label mainRoad main_sign offset:[-100,0]
-- 	dropdownlist dd_crossroad_prefabs "" items:#(	"L: 1 W: 6" ,
-- 																				"L: 2 W: 4 ",
-- 																				"L: 2 W: 5 ",
-- 																				"L: 4 W: 4 ",
-- 																				"L: 4 W: 5 ",
-- 																				"L: 2 W: 4 ",
-- 																				"L: 2 W: 2 + Train ",
-- 																				"L: 2 W: 4 + Train") height:9
	dropdownlist dd_crossroad_prefabs_1 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 
--     label label_1 "Lane number: " align:#left
--     radiobuttons rb_lane_number_1 labels:#("2", "4") default:1 align:#left
--     label label_2 "Lane width: " align:#left
--     radiobuttons rb_lane_width_1 labels:#("4") default:0 align:#left across:2
--     radiobuttons rb_lane_width_1_1 labels:#("5", "6") default:1 align:#left offset:[-38, 0]
    checkbox  cb_parking_lane_1 "Parking lane" checked:true align:#right
  )


  group " SIDE ROADS"
  (
	label sideRoad  side_sign offset:[-100,0]
--     label label_3 "Lane number: " align:#left
--     radiobuttons rb_lane_number_2 labels:#("2", "4") default:1 align:#left
--     label label_4 "Lane width: " align:#left
--     radiobuttons rb_lane_width_2 labels:#("4") default:0 align:#left across:2
--     radiobuttons rb_lane_width_2_1 labels:#("5", "6") default:1 align:#left offset:[-38, 0]
	  
	dropdownlist dd_crossroad_prefabs_2 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 
																		
																		
    checkbox  cb_parking_lane_2 "Parking lane" checked:true align:#right
	  
	spinner spnr_angle_1 "Top Angle: " type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,15] width:70
	spinner spnr_angle_2 "Bot. Angle:" type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,5] width:70
	
	spinner spnr_offset_1 "Top Offset:" type:#float range:[-1.0e6, 1.0e6, 0] align:#right offset:[0,-47] width:70
    spinner spnr_offset_2 "Bot. Offset:" type:#float range:[-1.0e6, 1.0e6, 0] align:#right offset:[0,6] width:70
  )
	
	button btn_generate "Generate" width: 200 height: 35 offset:[0, 10] 
  
  
  
--   button btn_done "Done"
  
--   global generated_road = undefined   				-- Global because of delete callback
  
  local initialized = false
  local roads = #()
  local sidewalks = #()
  local corners = #()
  local parking_lanes = #()
  local layer = undefined
  
    
--   local controlsArr = #(rb_lane_number_1, rb_lane_width_1, rb_lane_width_1_1, cb_parking_lane_1, 
-- 								rb_lane_number_2, rb_lane_width_2, rb_lane_width_2_1, cb_parking_lane_2, spnr_angle_1, spnr_offset_1, spnr_angle_2, spnr_offset_2,dd_crossroad_prefabs)
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
		else road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
		
		if spec_1 != false then(
			road_2_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			plRoad2 = True
			plTopBot = false
		)
		else road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
		if spec_1 != false or spec_2 != false then corner_model  = corners[1]
		else corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
		
		------------------------------------------------------------------------------------------------------------
-- 		road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
-- 		road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		

-- 		format "%\n%\n" road_1_model road_2_model
-- 		road_1_model = SelectRoad roads rb_lane_number_1.state rb_lane_width_1.state rb_lane_width_1_1.state spec_1e
-- 		road_2_model = SelectRoad roads rb_lane_number_2.state rb_lane_width_2.state rb_lane_width_2_1.state spec_2
		
-- 		corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
			
		road_1 = copy road_1_model

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
		  
		road_1_bb = GetBoundingBox road_1
		road_2_bb = GetBoundingBox road_2_a
		
		road_1_length = GetLengthBB road_1_bb
		
		corner_bb = GetBoundingBox corner_model
		
		
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
		  
		max_dist_left = RMin (attributes_1[2][1]) (attributes_2[2][2])
		max_dist_right = RMax (attributes_1[2][2]) (attributes_2[2][1])
		--print ("max dist left "+(max_dist_left as string)) 
		--print ("max dist right "+(max_dist_right as string))
		
		AddRoadSlicer road_1 (max_dist_left) 3
		AddRoadSlicer road_1 (max_dist_right) 2
		
			
		if generated_road == undefined then (
			pt1 = point()
			SetPointAppearance pt1
			tn1 = point()
			hide tn1
			append pt1.children tn1
			pt2 = point()
			SetPointAppearance pt2
			tn2 = point()
			hide tn2
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

		
		
		append road_1.children pt1
		append road_1.children pt2
		append road_1.children attributes_1[1][4]
		append road_1.children attributes_2[1][4]
		
		road_1 = ConvertTo road_1 editable_poly
		cutted_road_bb = GetBoundingBox road_1
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
		
		sidewalk_bb = GetBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = GetBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		  
-- 		place_pl_1 = cb_parking_lane_1.state or cb_parking_lane_2.state
-- 		place_pl_2 = cb_parking_lane_1.state or cb_parking_lane_2.state
		
-- 		place_pl_1 = True
-- 		place_pl_2 = True
		
-- 		if plTopBot == false then(
-- 			place_pl_1 = false
-- 			place_pl_2 = false
-- 		)
		place_pl_1 = cb_parking_lane_1.state or cb_parking_lane_2.state
		place_pl_2 = cb_parking_lane_1.state or cb_parking_lane_2.state
		
		
		
		pts_to_connect_top = #()
		pts_to_connect_bottom = #()
		append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
		append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
		  
		road_width = (GetWidthBB cutted_road_bb)
		road_left = (GetLeftBB cutted_road_bb)
		road_right = (GetRightBB cutted_road_bb)
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
  
  
  --first
--   on rb_lane_number_1 changed arg do (
--     if arg == 1 then (
--       rb_lane_width_1.visible = true
--     ) else (
--       rb_lane_width_1.visible = false
--       if rb_lane_width_1.state == 1 then (
--         rb_lane_width_1.state = 0
--         rb_lane_width_1_1.state = 1
--       )
--     )
--   )
--   
--   on rb_lane_width_1 changed arg do (
--     print "is called 1"
--     rb_lane_width_1_1.state = 0
--   )
--   
--   on rb_lane_width_1_1 changed arg do (
--     print "is called 2"
--     rb_lane_width_1.state = 0
--   )
--   
--   --second
--   on rb_lane_number_2 changed arg do (
--     if arg == 1 then (
--       rb_lane_width_2.visible = true
--     ) else (
--       rb_lane_width_2.visible = false
--       if rb_lane_width_2.state == 1 then (
--         rb_lane_width_2.state = 0
--         rb_lane_width_2_1.state = 1
--       )
--     )
--   )
--   
--   on rb_lane_width_2 changed arg do (
--     print "is called 1"
--     rb_lane_width_2_1.state = 0
--   )
--   
--   on rb_lane_width_2_1 changed arg do (
--     print "is called 2"
--     rb_lane_width_2.state = 0
--   )
  
)









--###################################################################################
--													2. 	ROLLOUT  TWO DIFF SIDEROADS 
--###################################################################################

rollout dlgCrossroadGenerator2 "Crossroad Generator"
(
  group " ROAD"
  (
	label mainRoad  main_sign offset:[-100,0]
	dropdownlist dd_crossroad_prefabs_1 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 
																		
    checkbox  cb_parking_lane_1 "Parking lane" checked:true align:#right
  )

  group " TOP ROAD"
  (
	label topRoad  top_sign offset:[-100,0]
	dropdownlist dd_crossroad_prefabs_2 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 
																		
																		
    checkbox  cb_parking_lane_2 "Parking lane" checked:true align:#right
	  
	spinner spnr_angle_1 "Top Angle: " type:#float range:[24, 156, 90] scale:1.0 align:#left offset:[0,10] width:70
	spinner spnr_offset_1 "Top Offset:" type:#float range:[-1.0e6, 1.0e6, 0] align:#right offset:[0,-22] width:70
  )
  
  group " BOTTOM ROAD" 
  (
	label botRoad  bot_sign offset:[-100,0]
	dropdownlist dd_crossroad_prefabs_3 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 
																		
																		
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
		AppendPrefabsToArrays &roads &sidewalks &corners &parking_lanes
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
			road_1_model 	= PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 	= PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 	= PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			corner_model 		= corners[2]
			corner_model_2 	= corners[2]
			plTop = True
			plBot = True
		)
		
		else if spec_1 == false and spec_2 == false and spec_3 == false then (
			road_1_model 	= PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 	= PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 	= PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
		)

		else if spec_1 == True and spec_2 == false and spec_3 == false then (
			road_1_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			road_2_model 		= PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 		= PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			plRoad = road_1_model
		)
		
		else if spec_1 == True and spec_2 == True and spec_3 == false then (
			road_1_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 false True &origPivot
			corner_model 		= corners[2]
			corner_model_2 	= corners[1]
			road_2_model 		= PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 		= PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			
			plTop = True
			plRoad = road_1_model
		)
		
		else if spec_1 == True and spec_2 == false and spec_3 == true then (
			road_1_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1 True false &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[2]
			road_2_model 		= PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			road_3_model 		= PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			
			plBot = True
			plRoad = road_1_model
		)
		
		else if spec_1 == false and spec_2 == True and spec_3 == false then (
			road_2_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			road_1_model 		= PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_3_model 		= PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
			plRoad = road_2_model
		)
		
-- 		print spec_1
		else if spec_1 == false and spec_2 == false and spec_3 == True then (
			road_3_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_3.selection &spec_3 True True &origPivot
			road_1_model 		= PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 		= PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			plRoad = road_3_model
		)
		
		else if spec_1 == false and spec_2 == True and spec_3 == True then (
			
			road_1_model 		= PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
			road_2_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			road_3_model 		= CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_3.selection &spec_3 True True &origPivot
			corner_model 		= corners[1]
			corner_model_2 	= corners[1]
			plRoad 	= road_3_model
			plRoad2 	= road_2_model
		)
		
		
-- 		if spec_1 != false then(
-- 			road_1_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_1.selection &spec_1
-- 			plRoad1 = True
-- 		)
-- 		else road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
-- 		
-- 		
-- 		if spec_2 != false then(
-- 			road_2_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2
-- 			plRoad2 = True
-- 		)
-- 		else road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
-- 		
-- 		
-- 		if spec_3 != false then(
-- 			road_3_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_3.selection &spec_3
-- 			plRoad3 = True
-- 		)
-- 		else road_3_model = PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3


-- 		if spec_1 != false or spec_2 != false then corner_model  = corners[1]
-- 		else corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
-- 		
-- 		if spec_1 != false or spec_3 != false then corner_model_2  = corners[1]
-- 		else corner_model_2 = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
		-------------------------------------------------------------------------------------------------------------------------------------------------------

-- 		road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
-- 		road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
-- 		road_3_model = PickRoadPrefab roads dd_crossroad_prefabs_3.selection spec_3
		
		
				
		
-- 		road_1_model = SelectRoad roads rb_lane_number_1.state rb_lane_width_1.state rb_lane_width_1_1.state spec_1
-- 		road_2_model = SelectRoad roads rb_lane_number_2.state rb_lane_width_2.state rb_lane_width_2_1.state spec_2
-- 		road_3_model = SelectRoad roads rb_lane_number_3.state rb_lane_width_3.state rb_lane_width_3_1.state spec_3
		
	-- 	format "%\n" spec_3
		
		
		
-- 		corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
-- 		corner_model_2 = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_3.triState)
		




	-- 	format "%\n%\n%\n%\n" roads rb_lane_number_1.state rb_lane_width_1.state rb_lane_width_1_1.state
		
		  

		road_1 = copy road_1_model
	-- 	road_1.name = replace road_1.name 11 4 "crossroad"

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
		  
		road_1_bb = GetBoundingBox road_1
		road_2_bb = GetBoundingBox road_2_a
		road_3_bb = GetBoundingBox road_2_b
		
		road_1_length = GetLengthBB road_1_bb
		
		corner_bb = GetBoundingBox corner_model
		corner_2_bb = GetBoundingBox corner_model_2
		
		
		
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
		
		
		
		  
		max_dist_left = RMin (attributes_1[2][1]) (attributes_2[2][2])
		max_dist_right = RMax (attributes_1[2][2]) (attributes_2[2][1])
		--print ("max dist left "+(max_dist_left as string)) 
		--print ("max dist right "+(max_dist_right as string))
		
		AddRoadSlicer road_1 (max_dist_left) 3
		AddRoadSlicer road_1 (max_dist_right) 2
		
		
		
		
		if generated_road == undefined then (
			pt1 = point()
			SetPointAppearance pt1
			tn1 = point()
			hide tn1
			append pt1.children tn1
			pt2 = point()
			SetPointAppearance pt2
			tn2 = point()
			hide tn2
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
		cutted_road_bb = GetBoundingBox road_1
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
		
		sidewalk_bb = GetBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = GetBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		
		
		
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
		  
		road_width = (GetWidthBB cutted_road_bb)
		road_left = (GetLeftBB cutted_road_bb)
		road_right = (GetRightBB cutted_road_bb)
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
  group " ROAD"
  (
	label mainRoad main_sign offset:[-100,0]
	dropdownlist dd_crossroad_prefabs_1 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 

    checkbox  cb_parking_lane_1 "Parking lane" checked:true align:#right
  )

  group " SIDE ROAD"
  (
	label topRoad top_sign offset:[-100,0]
	label botRoad bot_sign offset:[-85,-18]
	dropdownlist dd_crossroad_prefabs_2 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 

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
  
  
  local controlsArr = #(dd_crossroad_prefabs_1, cb_parking_lane_1, 
								dd_crossroad_prefabs_2, cb_parking_lane_2, spnr_angle_1)


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--   EVENT HANDLERS :
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  on dlgCrossroadGenerator3 open do
  (
--     print "--Crossroad Generator--"
    
    if initialized == false then (
		AppendPrefabsToArrays &roads &sidewalks &corners &parking_lanes
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
		else road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
		
		if spec_1 != false then(
			road_2_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			plRoad2 = True
			plTopBot = false
		)
		else road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
		if spec_1 != false or spec_2 != false then corner_model  = corners[1]
		else corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
-- 		road_1_model = SelectRoad roads rb_lane_number_1.state rb_lane_width_1.state rb_lane_width_1_1.state spec_1
-- 		road_2_model = SelectRoad roads rb_lane_number_2.state rb_lane_width_2.state rb_lane_width_2_1.state spec_2
		
-- 		road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
-- 		road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
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
		  
		road_1_bb = GetBoundingBox road_1
		road_2_bb = GetBoundingBox road_2_a
		
		road_1_length = GetLengthBB road_1_bb
		
		corner_bb = GetBoundingBox corner_model
		
		
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
	--     max_dist_left = RMin (attributes_1[2][1]) (attributes_2[2][2])
	--     max_dist_right = RMax (attributes_1[2][2]) (attributes_2[2][1])
		
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
		cutted_road_bb = GetBoundingBox road_1
		--AddRoadSlicer road_1 (attributes_1[2][4]) 1
		--AddRoadSlicer road_1 (attributes_2[2][4]) 1
		  
		road_edge_indices = GetRoadEdgeIndices road_1
		  
		  
		tri_left_top_further = 1
		tri_right_top_further = 1
		
		
		sidewalk_bb = GetBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = GetBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		  
		place_pl_1 = cb_parking_lane_1.state or cb_parking_lane_2.state
		place_pl_2 = cb_parking_lane_1.state or cb_parking_lane_2.state
		pts_to_connect_top = #()
	--     pts_to_connect_bottom = #()
		append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
		
	-- 	format "%\n" pts_to_connect_top
	--     append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
		  
		road_width = (GetWidthBB cutted_road_bb)
		road_left = (GetLeftBB cutted_road_bb)
		road_right = (GetRightBB cutted_road_bb)
		
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
		sidewalkBBLenght = GetLengthBB sidewalk_bb
		parkLineBBLenght = GetLengthBB parking_lane_bb
		
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
			pt1 = point()
			SetPointAppearance pt1
			tn1 = point()
			hide tn1
			append pt1.children tn1
			pt2 = point()
			SetPointAppearance pt2
			tn2 = point()
			hide tn2
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
			pBot = point()
			SetPointAppearance pBot
			tnBot = point()
			hide tnBot
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
		else road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
		
		if spec_1 != false then(
			road_2_model = CreateRoadWithPL roads parking_lanes dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
			plRoad2 = True
			plTopBot = false
		)
		else road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
		if spec_1 != false or spec_2 != false then corner_model  = corners[1]
		else corner_model = SelectCorner corners (bit.or cb_parking_lane_1.triState cb_parking_lane_2.triState)
		
		
		
		
		
		
-- 		road_1_model = SelectRoad roads rb_lane_number_1.state rb_lane_width_1.state rb_lane_width_1_1.state spec_1
-- 		road_2_model = SelectRoad roads rb_lane_number_2.state rb_lane_width_2.state rb_lane_width_2_1.state spec_2
		
		
		
-- 		road_1_model = PickRoadPrefab roads dd_crossroad_prefabs_1.selection spec_1
-- 		road_2_model = PickRoadPrefab roads dd_crossroad_prefabs_2.selection spec_2
		
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
		  
		road_1_bb = GetBoundingBox road_1
		road_2_bb = GetBoundingBox road_2_b
		
		road_1_length = GetLengthBB road_1_bb
		
		corner_bb = GetBoundingBox corner_model
		
		
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
	--     max_dist_left = RMin (attributes_1[2][1]) (attributes_2[2][2])
	--     max_dist_right = RMax (attributes_1[2][2]) (attributes_2[2][1])
		
	-- 	format "%\n%\n" attributes_1[2][1] attributes_1[2][2]
		
		max_dist_left = attributes_2[2][1]
		max_dist_right = attributes_2[2][2]
		
	--     print ("max dist left "+(max_dist_left as string)) 
	--     print ("max dist right "+(max_dist_right as string))
		
		AddRoadSlicer road_1 (max_dist_right) 3
		AddRoadSlicer road_1 (max_dist_left) 2

		
		road_1 = ConvertTo road_1 editable_poly
		cutted_road_bb = GetBoundingBox road_1
		--AddRoadSlicer road_1 (attributes_1[2][4]) 1
		--AddRoadSlicer road_1 (attributes_2[2][4]) 1
		  
		road_edge_indices = GetRoadEdgeIndices road_1
		  
		  
		tri_left_top_further = -1
		tri_right_top_further = -1
		
		
		sidewalk_bb = GetBoundingBox sidewalks[C_SIDEWALK_LEFT]
		parking_lane_bb = GetBoundingBox parking_lanes[C_PARKING_LANE_LEFT]
		  
-- 		place_pl_1 = cb_parking_lane_1.state or cb_parking_lane_2.state
		place_pl_2 = cb_parking_lane_1.state or cb_parking_lane_2.state
		

-- 		place_pl_1 = spec_1
-- 		place_pl_2 = spec_2
	
	
	--     pts_to_connect_top = #()
		pts_to_connect_bottom = #()
	--     append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
		
	-- 	format "%\n" pts_to_connect_top
		append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
		  
		road_width = (GetWidthBB cutted_road_bb)
		road_left = (GetLeftBB cutted_road_bb)
		road_right = (GetRightBB cutted_road_bb)
		
	-- 	print road_left
		
		--top side
		-- 	print sidewalk_bb
	-- 	format "%\n" cutted_road_bb
		roadTopYBB =  cutted_road_bb[2][2]
		sidewalkBBLenght = GetLengthBB sidewalk_bb
		parkLineBBLenght = GetLengthBB parking_lane_bb
		
		
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
			pt1 = point()
			SetPointAppearance pt1
			tn1 = point()
			hide tn1
			append pt1.children tn1
			pt2 = point()
			SetPointAppearance pt2
			tn2 = point()
			hide tn2
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
			pTop = point()
			SetPointAppearance pTop
			tnTop= point()
			hide tnTop
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



























------------------------------------------------------------------------------
-- Struct Crossroad Generator
------------------------------------------------------------------------------

-- struct sCrossroadGenerator
-- (
--   fn openDialog =
--   (
--     if gCrossroadGeneratorUI == undefined then
--     (
--       gCrossroadGeneratorUI = createDialog dlgCrossroadGenerator modal:false
--     )
--     else
--       destroyDialog dlgCrossroadGenerator
--   ),
--   
--   fn init =
--   (
--   )
-- )

------------------------------------------------------------------------------
-- INIT
------------------------------------------------------------------------------

-- if (gCrossroadGenerator == undefined) do
-- (
-- 	gCrossroadGenerator = sCrossroadGenerator()
-- 	gCrossroadGenerator.init()
-- )

------------------------------------------------------------------------------
-- MACRO SCRIPTS
------------------------------------------------------------------------------

-- macroScript CrossroadGenerator 
-- category:"LS3D Engine" 
-- tooltip:"Crossroad generator" 
-- Icon:#("Patches",1)
-- (	
--   gCrossroadGenerator.openDialog()
-- )

-- createDialog dlgCrossroadGenerator





















--###################################################################################
--															HELP FN ROADS and TURNS
--###################################################################################


TANGENT_TEST_COUNT = 100

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

-- fn WeldEditPoly epoly precision =
-- (
-- 	vert_count = (polyop.getNumVerts epoly)
--     all_vert_list = #{1..vert_count}
--     
-- 	--weld all vertices
--     epoly.weldThreshold = precision
--     polyop.weldVertsByThreshold epoly all_vert_list
-- )

fn GetFaceCenter editable verts =
(
	point_avg = [0,0,0]
	for i in 1 to verts.count do
	(
		pt = polyop.getVert editable verts[i]
		point_avg += pt
-- 		print("pt to sum: "+pt as string)
	)
-- 	print("pt sum: "+point_avg as string)
	point_avg /= verts.count
-- 	print ("Face vert count: "+verts.count as string)
	return point_avg
)

fn GetRoadFaceCenterDistances editable =
(
	face_count = polyop.getNumFaces editable
	face_offsets = #()
	for i in 1 to face_count do
	(
		face_center = GetFaceCenter editable (polyop.getFaceVerts editable i)
		--pt = point()
		--pt.position = face_center
-- 		print ("Face center: "+pt as string)
		dist = length (editable.position-face_center)
		append face_offsets ((dot (normalize(editable.position-face_center)) [0,1,0]) * dist)
	)
	return face_offsets
)

fn GetRoadFaceCenters editable =
(
	face_count = polyop.getNumFaces editable
	face_offsets = #()
	for i in 1 to face_count do
	(
		face_center = GetFaceCenter editable (polyop.getFaceVerts editable i)
		--pt = point()
		--pt.position = face_center
-- 		print ("Face center: "+pt as string)
		face_center_origin = (face_center-editable.position)
		normal = polyop.getFaceNormal editable i
		append face_offsets #(face_center_origin+5.0*normal, -polyop.getFaceNormal editable i)
	)
	return face_offsets
)

fn GetMeshFaceToPoly epoly mesh_face =
(
-- 	print ("Mesh available: "+(epoly.mesh != undefined) as string)
	-- get polys for this face
	local mesh_polys = meshop.getpolysusingface epoly.mesh #{mesh_face} threshhold:360
	-- get verts using these polys
	local mesh_verts = meshop.getvertsusingface epoly.mesh mesh_polys

	-- get polys in editable_poly using these verts
	local vert_polys = (polyop.getfacesusingvert epoly mesh_verts) as array
	local p = 1
	local poly_verts

	-- poly index returned by this function
	local poly = undefined

	-- find poly
	while p <= vert_polys.count do
	(
		-- get verts from poly
		poly_verts = polyop.getvertsusingface epoly vert_polys[p]
		
		-- same number of vertices?
		if (poly_verts as array).count == (mesh_verts as array).count do
		(
			-- intersecting the bitarray should result in array of identical size
			if ((poly_verts + mesh_verts) as array).count == (mesh_verts as array).count then
			(
				-- poly found!
				poly = vert_polys[p]
				-- exit the loop
				p = vert_polys.count + 1
			)
		)

		-- check next poly
		p += 1
	)

	-- return the found poly (undefined if not found)
	poly
)

fn GetMeshFacesToPoly epoly mesh_faces =
(
	face_indices = #()
	for i in 1 to mesh_faces.count do
	(
		append face_indices (GetMeshFaceToPoly epoly mesh_faces[i])
	)
	
	return face_indices
)


fn drawLineBetweenTwoPoints pointA pointB col =
(
  ss = SplineShape pos:pointA
  addNewSpline ss
  addKnot ss 1 #corner #line PointA
  addKnot ss 1 #corner #line PointB
  updateShape ss
  ss.wirecolor = col
)

fn FindAllIntersectionsUsingRays mpoly rays =
(
	rm = RayMeshGridIntersect()
	rm.Initialize 10
	rm.AddNode mpoly
	rm.buildGrid()
	
	hit_array = #()
	for i in 1 to rays.count do
	(
		hit_count = rm.intersectRay rays[i].pos rays[i].dir true
		--drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*50.0) (color 0 0 255)
-- 		print("Hit count: "+hit_count as string)
		if(hit_count > 0) then (
			hit_index = rm.getClosestHit()
			face_index = rm.getHitFace hit_index
			append hit_array face_index
		)
	)
	--free all resources
	rm.Free()
	--return result
	return hit_array
)

fn CreateRoadFromSpline road_prefabric spline adaption =
(
	disableSceneRedraw() 
	-- get segment length
	segment_lengths = (getSegLengths spline 1 cum:false)
	spline_length = segment_lengths[segment_lengths.count]
	
	-- get knots position
	knot_count = numKnots spline 1
	pt1 = getKnotPoint spline 1 1
	tn1 = getOutVec spline 1 1
	pt2 = getKnotPoint spline 1 knot_count
	tn2 = getInVec spline 1 knot_count
	
	-- create road assembled from number of parts to cover whole spline
	road_bb = GetBoundingBox road_prefabric
	road_length = GetWidthBB road_bb
			
	road_sum = copy road_prefabric
	road_sum.pivot -= road_prefabric.transform.row1 * 0.5 * road_length
	road_count = spline_length/road_length as integer
	road_sum_length = road_length
-- 	print ("Road count: "+(road_count as string))
	for i in 1 to road_count do
	(
		copy_road = copy road_prefabric
		copy_road.position += copy_road.transform.row1 * road_length * i
		road_sum.attach copy_road road_sum
		road_sum_length += road_length
	)
	road_sum.position = pt1
	
	WeldEditPoly road_sum 1.0
	
	-- cut road along spline
	tangent_fst = tangentCurve3D spline 1 ((1 as double)/TANGENT_TEST_COUNT)
	last_i = 1
	sum_d = 0.0
	for i in 2 to TANGENT_TEST_COUNT do
	(
		tangent_snd = tangentCurve3D spline 1 ((i as double)/TANGENT_TEST_COUNT)
		d = acos (dot (normalize tangent_fst) (normalize tangent_snd))
		sum_d += d
-- 		print ("Angle sum: "+sum_d as string)
		if sum_d > adaption then (
-- 			print("Diff: "+(i-last_i) as string)
			-- compute params
			param = (((i+last_i)/2.0)/TANGENT_TEST_COUNT)
			pt = interpCurve3D spline 1 param pathParam:true
			--p = point ()
			--p.position = pt
			--add slice modifier
			slice = sliceModifier()
			addModifier road_sum slice 
			--setup modifier
			slice.slice_type = 1
			slice.slice_plane.position = [0.0, 0.0, param*spline_length-road_length*0.5]
			slice.slice_plane.rotation = (angleaxis (90) [0, 1, 0]) as quat
			
			-- save for next iteration
			last_i = i
			sum_d = 0.0
		)
		
		tangent_fst = tangent_snd
	)
	
	
	
	slice = sliceModifier()
	addModifier road_sum slice 
	--setup modifier
	slice.slice_type = 2
	slice.slice_plane.position = [0.0, 0.0, spline_length-road_length*0.5]
	slice.slice_plane.rotation = (angleaxis (90) [0, 1, 0]) as quat
	
	road_sum = ConvertTo road_sum editable_poly
	
	-- transform matrix vectors for road
	t_x = normalize (tn1-pt1)
	t_y = normalize([-t_x.y, t_x.x, 0.0])
	t_z = cross t_x t_y
	
	road_transform = road_sum.transform
	road_transform.row1 = t_x
	road_transform.row2 = t_y
	road_transform.row3 = t_z
		
	road_sum.transform = road_transform
	
	-- update path deform gizmo to be at start of road (calculation translate world position to object space of road)
	path_deform = pathDeform()
	addModifier road_sum path_deform
	
	path_deform.axis = 0
	path_deform.path = spline
	path_deform.gizmo.position = pt1 * (getModContextTM road_sum path_deform) * (inverse road_sum.objecttransform)
	
	road_sum_mesh = ConvertTo road_sum editable_mesh
	road_sum = ConvertTo road_sum editable_poly
	
	-- compute face distances, 
	--face_distances = GetRoadFaceCenterDistances road_prefabric
	face_centers = GetRoadFaceCenters road_prefabric
	t2_x = normalize(tn2-pt2)
	t2_y = normalize([-t2_x.y, t2_x.x, 0.0])
	t2_z = normalize(cross t2_x t2_y)
	
	t_matrix = matrix3 0
	t_matrix.row1 = t2_x
	t_matrix.row2 = t2_y
	t_matrix.row3 = t2_z
	
	rays = #()
	for i in 1 to face_centers.count do
	(
		--rayOrigin = (pt2+t2_y*face_distances[i]+t2_z*100.0)
		--dir = (-t2_z)
		rayOrigin = face_centers[i][1] * t_matrix + pt2
		dir = face_centers[i][2] * t_matrix
		--drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 255 0 0)
		append rays (ray rayOrigin dir)
	)
	hitArray = FindAllIntersectionsUsingRays road_sum_mesh rays
		
	--slice
	polyop.slice road_sum (GetMeshFacesToPoly road_sum hitArray) (ray pt2 t2_x)
	
	road_sum_mesh = ConvertTo road_sum editable_mesh
	--rebuild ray mesh intersect with updated data
	
	rays = #()
	for i in 1 to face_centers.count do
	(
		--rayOrigin = (pt2+t2_y*face_distances[i]+t2_z*10.0-t2_x*10.0)
		--dir = (-t2_z)
		rayOrigin = face_centers[i][1] * t_matrix + pt2 - t2_x*10.0
		dir = face_centers[i][2] * t_matrix
		--drawLineBetweenTwoPoints rayOrigin (rayOrigin+dir*20.0) (Color 0 255 0)
		append rays (ray rayOrigin dir)
	)
	hitArray = FindAllIntersectionsUsingRays road_sum_mesh rays
	
	road_sum = ConvertTo road_sum editable_poly
	
	--remove all wrong faces
	polyop.deleteFaces road_sum (GetMeshFacesToPoly road_sum hitArray)
	
	WeldEditPoly road_sum 1.0
		
	--polyop.detachFaces road_sum hitArray
	
	--Slice modifier removes overlapping part
	/*sl = sliceModifier()
	addModifier road_sum sl
	
	slice_transform_matrix = (getModContextTM road_sum sl) * (inverse road_sum.objecttransform)
	
	--place slice to the end of spline
	s_z = normalize(tn2 * slice_transform_matrix - pt2 * slice_transform_matrix)
	s_y = normalize([-s_z.y, s_z.x, 0.0])
	s_x = cross s_z s_y
	
	slice_matrix = matrix3 0
	slice_matrix.row1 = s_x
	slice_matrix.row2 = s_y
	slice_matrix.row3 = s_z
	slice_matrix.row4 = pt2 * slice_transform_matrix
	
	--sl.Faces___Polygons_Toggle = 1
	sl.slice_type = 3
	sl.slice_plane.transform = slice_matrix*/
	enableSceneRedraw()
	return road_sum
)

fn CheckResource file fileName =
(
	if file == undefined then
	(
		MessageBox (fileName+" resources is missing")
		throw fileName
	)
)

-- fn SelectRoad roads lane_number lane_width_1 lane_width_2 spec =
-- (	
-- 	lane_width = 0
-- 	if lane_width_1 == 0 then
-- 		lane_width = lane_width_2 + 1
-- 	else 
-- 		lane_width = lane_width_1
-- 	
-- 	offset = 0
-- 	if spec then (
-- 		offset = 1
-- 	)		
-- 	if lane_number == 2 then (
-- 		lane_width -= 1
-- 	)
-- 	return roads[(lane_number-1)*6 + (lane_width-1)*2 + offset + 1]
-- )

--specs(parking_left, parking_right, sidewalk_left, sidewalk_right)
fn ConstructRoadPrototype road specs placeParkingLeft placeParkingRight placeSidewalkLeft placeSidewalkRight =
(
	--
	bb = GetBoundingBox road
	bb_parking = GetBoundingBox specs[1]
	bb_sidewalk = GetBoundingBox specs[3]
	cpy_road = copy road
	offset = GetLengthBB bb_sidewalk
	
	offsetLeft 	= offset
	offsetRight	= offset
	
	if(placeParkingLeft) 		then offsetLeft += GetLengthBB bb_parking
	if(placeParkingRight) 	then offsetRight += GetLengthBB bb_parking

	
	
	--	
	left_pivot = road.position - (GetWidthBB bb)/2.0 * road.transform.row1 + ((GetLengthBB bb)/2.0 + offsetLeft) * road.transform.row2 + (GetHeightBB bb_sidewalk) * road.transform.row3
	right_pivot = road.position - (GetWidthBB bb)/2.0 * road.transform.row1 - ((GetLengthBB bb)/2.0 + offsetRight) * road.transform.row2 + (GetHeightBB bb_sidewalk) * road.transform.row3
	
	-- parking left
	if (placeParkingLeft) then
	(
		parking_left = copy specs[1]
		parking_left.position = left_pivot
		cpy_road.attach parking_left cpy_road
	)
	-- parking right
	if (placeParkingRight) then
	(
		parking_right = copy specs[2]
		parking_right.position = right_pivot
		cpy_road.attach parking_right cpy_road
	)
	--place sidewalk Left
	if (placeSidewalkLeft) then
	(
		sidewalk_left = copy specs[3]
		sidewalk_left.position = left_pivot
		cpy_road.attach sidewalk_left cpy_road
	)
	--place sidewalk Right
	if (placeSidewalkRight) then
	(
		sidewalk_right = copy specs[4]
		sidewalk_right.position = right_pivot
		cpy_road.attach sidewalk_right cpy_road
	)
	
	
	--
	--WeldEditPoly road_sum 1.0
	
	
	--return road
	return cpy_road
	
)












---------------------------------------------------------------------------------------------------------------------
fn SetCustomAttrForRoad road rSpline sPoint ePoint dialog controlsArr = 
(
	custAttributes.add road gRoadGenCa #unique --BaseObject:True
	road.roadSpline 	= rSpline
	road.startPoint 	= sPoint
	road.endPoint 		= ePoint
	road.controlsStr	= GetCAControlsSTR dialog controlsArr
	True
)

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

rollout RoadGeneratorTool "Road Generator"
(	

	local roads = #()
	local specs = #()
	local dummies = #()
	
	group ""
	(
	dropdownlist dd_road_prefabs_1 "" items:#(	"(1-6)                      " + one_six ,
																		"(2-2)R                   " + two_two ,
																		"(2-4)                   "  + two_four,
																		"(2-4)R                " + two_four_r ,
																		"(2-5)                " + two_five,
																		"(4-4)       " + four_four ,
																		"(4-5)  " + four_five) height:8 

		checkbox  cb_parking_lane_left "Parking lane Left" checked:true align:#left offset:[0,5]
		checkbox  cb_parking_lane_right "Parking lane Right" checked:true align:#right offset:[3,-22]
-- 		checkbox  cb_narrow_road_1 "Narrow road:" checked:false align:#right
		
		
		checkbox  cb_sidewalks_right "Sidewalks Right   " checked:true align:#right offset:[0,5]
		checkbox  cb_sidewalks_left "Sidewalks Left" checked:true align:#left offset:[0,-17]
		spinner spinner_tangent "Adapt. [Deg]: " range:[0,90.0,4.0] scale:0.05 type:#float allign:#center offset:[0,10] width:70

	)
	
	button btn_edit_tangents "Edit Tangents" width: 100 height: 35 offset:[-50, 10] align:#center
	button btn_sync_spline "Sync Spline" width: 100 height: 35 offset:[50, -40] align:#center
-- 	button btn_update "Update Road" width: 160 height: 28 offset:[0, -5] align:#center
	button btn_generate "Generate Road" width: 200 height: 35 offset:[0, 10] align:#center
	
	
	
	local controlsArr = #(dd_road_prefabs_1, cb_parking_lane_left, cb_parking_lane_right, cb_sidewalks_left, cb_sidewalks_right, spinner_tangent)
	
	on RoadGeneratorTool open do
	(
		--check resource
-- 		try (
-- 			CheckResource $generator_road_2_4 "generator_road_2_4"
-- 			CheckResource $generator_road_2_4_spec "generator_road_2_4_spec"
-- 			CheckResource $generator_road_2_5 "generator_road_2_5"
-- 			CheckResource $generator_road_2_5_spec "generator_road_2_5_spec"
-- 			CheckResource $generator_road_2_6 "generator_road_2_6"
-- 			CheckResource $generator_road_2_6_spec "generator_road_2_6_spec"
-- 			CheckResource $generator_road_4_5 "generator_road_4_5"
-- 			CheckResource $generator_road_4_5_spec "generator_road_4_5_spec"
-- 			CheckResource $generator_road_4_6 "generator_road_4_6"
-- 			CheckResource $generator_road_4_6_spec "generator_road_4_6_spec"
-- 			CheckResource $generator_sidewalk_left "generator_sidewalk_left"
-- 			CheckResource $generator_sidewalk_right "generator_sidewalk_right"
-- 			CheckResource $generator_corner "generator_corner"
-- 			CheckResource $generator_corner_p "generator_corner_p"
-- 			CheckResource $generator_parking_lane_left "generator_parking_lane_left"
-- 			CheckResource $generator_parking_lane_right "generator_parking_lane_right"
-- 		) catch (
-- 			destroyDialog CrossroadGenerator
-- 		)
		
		--load road types
		append roads $generator_road_1_6
-- 		append roads $generator_road_1_6     		--<< instead of spec just For NOW
		
		append roads $generator_road_2_2_rail
-- 		append roads $generator_road_2_2_rail	--<< instead of spec just For NOW
		
		append roads $generator_road_2_4
-- 		append roads $generator_road_2_4_spec
		
		append roads $generator_road_2_4_rail
-- 		append roads $generator_road_2_4_rail	--<< instead of spec just For NOW		
		
		append roads $generator_road_2_5
-- 		append roads $generator_road_2_5_spec
		
	--     append roads $generator_road_2_6
	--     append roads $generator_road_2_6_spec
		append roads $generator_road_4_4
-- 		append roads $generator_road_4_4 			--<< instead of spec just For NOW
		
		append roads $generator_road_4_5
-- 		append roads $generator_road_4_5_spec
		
		--load sidewalks and parking places
		append specs $generator_parking_lane_left
		append specs $generator_parking_lane_right
		append specs $generator_sidewalk_left
		append specs $generator_sidewalk_right
	)
	
	on btn_generate pressed do
	(
format "btn_generate :%\n" btn_generate	
		undo off(
			sel = selection as Array
			selCount = sel.count
			---------------------------------------------------------------------------
-- 			TWO POINTS  (Create)
			---------------------------------------------------------------------------
			if selCount == 2 and classof sel[1] == Point and classof sel[2] == Point then (
				
				p1 = sel[1].position
				t1 = sel[1].children[1].position
				p2 = sel[2].position
				t2 = sel[2].children[1].position
						
				-- create spline from selected points
				local sp = splineShape()
				addNewSpline sp
				addKnot sp 1 #corner #curve p1
				addKnot sp 1 #corner #curve p2
				setKnotType sp 1 1 #bezierCorner
				setKnotType sp 1 2 #bezierCorner
				setOutVec sp 1 1 (t1)
				setInVec sp 1 2 (t2)
				updateShape sp
				sp.adaptive = true
				sp.pivot = [0, 0, 0]
				
				sp.wirecolor = color 7 206 224
				
				selected_road = PickRoadPrefab roads dd_road_prefabs_1.selection false

				road = ConstructRoadPrototype selected_road specs cb_parking_lane_left.state cb_parking_lane_right.state cb_sidewalks_left.state cb_sidewalks_right.state
				finalRoad = CreateRoadFromSpline road sp spinner_tangent.value
				------------------------------------------------------------------
				finalRoad.name = replace finalRoad.name 11 6 "connect_road"
				finalRoad.name = uniquename(finalRoad.name)
				
				SetCustomAttrForRoad finalRoad sp $[1] $[2] RoadGeneratorTool controlsArr
				custAttributes.add sp gSplineGenCa #unique
				sp.road = finalRoad.name
				--sp.parent = finalRoad --MerlinEl (2.24.2019) --can't do this, depency loop
				------------------------------------------------------------------
				delete road

				SetCrossRoadWireColor finalRoad
				select finalRoad				
			)

			---------------------------------------------------------------------------
-- 			ROAD or SPLINE  (Update)
			---------------------------------------------------------------------------
			if selCount == 1 then(
				obj = sel[1]
				if classOf obj == SplineShape then (
					spline = obj
					road = getNodeByName spline.road
				)else(
					spline = obj.roadSpline
					road = obj
				)
				
				fSel = #(road, spline)
				
				oldWireColor = road.wirecolor
				
				prevParent = undefined
				
				if fSel[1] != undefined and fSel[2] != undefined then(
					select fSel
					selected_road = PickRoadPrefab roads dd_road_prefabs_1.selection false
					selected_road = ConstructRoadPrototype selected_road specs cb_parking_lane_left.state cb_parking_lane_right.state cb_sidewalks_left.state cb_sidewalks_right.state
					road = undefined
					spline = undefined
					-- get items from selection
					for i in 1 to $.count do
					(
-- 						print ("ClassOf "+(classOf $[i] as string))
						if (classOf $[i] == Editable_Poly) or (classOf $[i] == PolyMeshObject) then
						(
							road = $[i]
-- 							print ("Road was detected.")
						)
						if (classOf $[i] == SplineShape) then
						(
							spline = $[i]
-- 							print ("Spline was detected.")
						)
					)
					if(road == undefined or spline == undefined) then
					(
						messageBox "Road or spline wasn't selected."
					) else 
					(
						--create road
						finalRoad = CreateRoadFromSpline selected_road spline spinner_tangent.value
						finalRoad.name = replace finalRoad.name 11 6 "connect_road"
						finalRoad.name = uniquename(finalRoad.name)
						
						SetCustomAttrForRoad finalRoad spline road.startPoint road.endPoint RoadGeneratorTool controlsArr
						spline.road = finalRoad.name
						-- delete old road
						
						prevParent = road.parent
											
						delete road
						delete selected_road
						
						SetCrossRoadWireColor finalRoad oldColor:oldWireColor
						finalRoad.parent = prevParent
						select finalRoad
					)
					
				)
			)
		)
	)

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
			macros.run "Tools" "SmartScale"
		)
	)
	
	on btn_sync_spline pressed do
	(
		sel = selection as array
		
		for road in sel do (
		
			-->MerlinEL 26.4.2019
			if not (roGenStruct.isRoad road) do (
			
				format "btn_sync_spline > Unable sync Spline on:%\n" road.name
				continue
			)
			--<
			rSpline 	= road.roadSpline
			startPoint = road.startPoint
			endPoint = road.endPoint

			sPointPos 	= startPoint.pos
			ePointPos 	= endPoint.pos
			
			tIn 	= startPoint.children[1].pos
			tOut	= endPoint.children[1].pos
			
			knot_count = numKnots rSpline 1
			setKnotPoint    rSpline 1 1 sPointPos
			setKnotPoint    rSpline 1 knot_count ePointPos
			
			setOutVec rSpline 1 1 (tIn)
			setInVec rSpline 1 knot_count (tOut)
			
			updateShape rSpline
		)
	)
	-----------------------------------------------------------------------------------
)




--###################################################################################
-- 														DIALOG FLOATER
--###################################################################################









-- createDialog dlgPickObjectType
Global floaterGenerator
try(closeRolloutFloater  floaterGenerator)catch()
floaterGenerator = newRolloutFloater "" 270 440

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

fn SetCrosroadRoll index = 
(
	Case (index) of (
		1: (
			floaterGenerator.size = [270,440]
			addRollout dlgCrossroadGenerator floaterGenerator
			
		)
		2 :(
			floaterGenerator.size = [270,522]
			addRollout dlgCrossroadGenerator2 floaterGenerator
			
		)
		3 : (
			floaterGenerator.size = [270,420]
			addRollout dlgCrossroadGenerator3 floaterGenerator
		)
	)
)


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fn CopyUniqueCrossRoad  crossroad= (
	if crossroad != undefined then (
		kidsShift = 4
		
		newCR = copy crossroad
		SetCrossRoadWireColor newCR oldColor:crossroad.wirecolor
		
		originalCRChildren = crossroad.children
		childrenCount = originalCRChildren.count
		
		for i =1 to childrenCount do (
			origPt 	= originalCRChildren[i]
			origTn 	= origPt.children[1]
			
			newPt = copy origPt
			newTn = copy origTn
			
			SetPointAppearance newPt
			hide newTn
			
			newTn.parent = newPt
			append newCR.children newPt
			
			
			newCR.kids[i] = newPt
			newCR.kids[i +kidsShift] = newTn
			
		)

		when newCR deleted id:#CrossDelete obj do --define a when construct
		(
			DeleteCrossRoadChildren obj
		)
		select newCR
	)
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn HideHelpPoint =
(
	for obj in geometry do(
		if matchPattern obj.name pattern:"generator_crossroad_4*" or matchPattern obj.name pattern:"generator_crossroad_3*"then(
			crossChildren = obj.children
			for kid in crossChildren do(
				hide kid.children
			)
		)
	)	
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn SelectVisuals =
(
		
	roadsCrossToselect = #()

	for obj in geometry do(
		crossForuCheck 	= matchPattern obj.name pattern:"generator_crossroad_4*"
		crossThreeCheck	= matchPattern obj.name pattern:"generator_crossroad_3*"
		roadCheck			= matchPattern obj.name pattern:"generator_connect_road*"
		
		if  crossForuCheck or crossThreeCheck or roadCheck then(
			append roadsCrossToselect obj
		)
	)
	
	if keyboard.controlPressed then(
		sel = selection as Array
		join roadsCrossToselect sel
		select roadsCrossToselect
	)
	
	select roadsCrossToselect
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn SelectCollisions =
(
	roadsCollsToselect = #()

	for obj in geometry do(
		crossForuCheck 	= matchPattern obj.name pattern:"coll_generator_crossroad_4*"
		crossThreeCheck	= matchPattern obj.name pattern:"coll_generator_crossroad_3*"
		roadCheck			= matchPattern obj.name pattern:"coll_generator_connect_road*"
		
		if  crossForuCheck or crossThreeCheck or roadCheck then(
			append roadsCollsToselect obj
		)
	)
	
	if keyboard.controlPressed then(
		sel = selection as Array
		join roadsCollsToselect sel
		select roadsCollsToselect
	)
	
	select roadsCollsToselect
)









------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn SelectChildren =
(
	sel = selection as Array
	addSel = #()
	
	for obj in sel do (
		crossForuCheck 	= matchPattern obj.name pattern:"generator_crossroad_4*"
		crossThreeCheck	= matchPattern obj.name pattern:"generator_crossroad_3*"
		roadCheck			= matchPattern obj.name pattern:"generator_connect_road*"
		
		if crossForuCheck or crossThreeCheck then(
			objChildren = obj.children
			for child in objChildren do(
				append addSel child
				append addSel child.children[1]
			)			
		)
		
		if roadCheck then append addSel obj.roadSpline
	)
	
	join sel addSel
	select sel
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn FixDuplicitNames =
(
	sel = selection as Array
	
	for obj in sel do (
		obj.name = uniquename obj.name
		if matchPattern obj.name pattern:"generator_connect_road*" then obj.roadSpline.road = obj.name
	)
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rollout rGeneratorUtilities "Generator Utilities"
(
	button bt_SelectVisuals 		"Select Visuals" 	offset:[-90,0] width:90 height:25 
	button bt_SelectColls 			"Select Colls    " 	offset:[-90,0] width:90 height:25 
	button bt_SelectChildren 		"Select Children" 	offset:[-90,0] width:90 height:25 
	
	button bt_FixDuplicitNames		"Unique Names" 	offset:[0,-90] width:90 height:25 toolTip:"Fix duple names"
	button bt_fixBrokenCrossroad	"Fix Crossroad"	offset:[0,0] width:90 height:25 toolTip:"Repair helpers hierarchy"	
	button bt_roadAnatomy			"Road Anatomy"		offset:[0,0] width:90 height:25 toolTip:"Show - Repair (cross)road hierarchy"	
	
	button bt_hidePoints 			"Hide Help Points"	offset:[90,-90] width:90 height:25 
	button bt_showRoadColorTable	"Road Colors"	offset:[90,0] width:90 height:25 toolTip:"Road Color Types"
	button bt_ReloadPrefabs			"Reload Prefabs"	offset:[90,0] width:90 height:25 toolTip:"Delete old prefabs and load new ones"

	on bt_hidePoints pressed do (
		HideHelpPoint()
	)
	
	on bt_SelectVisuals pressed do (
		SelectVisuals()
	)
	
	on bt_SelectColls pressed do (
		SelectCollisions()
	)
	
	on bt_SelectChildren pressed do ( 
		SelectChildren()
	)
	
	on bt_FixDuplicitNames pressed do ( 
-- 		SelectVisuals()
		FixDuplicitNames()
	)
	
	on bt_fixBrokenCrossroad pressed do roGenStruct.fixBrokenCrossroad selection[1]
	on bt_roadAnatomy pressed do runLocalScript "Road_Generator_Anatomy"
	on bt_showRoadColorTable pressed do runLocalScript "Road_Generator_Colors"
	on bt_ReloadPrefabs pressed do roGenStruct.reloadPrefabs(getSourceFileName())
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn AppendCollsToArrays &collsRoads &collsSidewalks &collsCorners &collsParking_lanes =
(
	--load roads coll prefabs
	append collsRoads $coll_generator_road_1_6
	append collsRoads $coll_generator_road_2_2_rail
	append collsRoads $coll_generator_road_2_4
	append collsRoads $coll_generator_road_2_4_rail
    append collsRoads $coll_generator_road_2_5
	append collsRoads $coll_generator_road_4_4
    append collsRoads $coll_generator_road_4_5

    --load sidewalks coll prefabs
    append collsSidewalks $coll_generator_sidewalk_left
    append collsSidewalks $coll_generator_sidewalk_right
	
    --load corners coll prefabs
    append collsCorners $coll_generator_corner
    append collsCorners $coll_generator_corner_p
	
    --load parking lanes coll prefabs
    append collsParking_lanes $coll_generator_parking_lane_left
    append collsParking_lanes $coll_generator_parking_lane_right
	
	True
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn GetSpecsForRoadGenerator =
(
	specs = #()
	append specs $coll_generator_parking_lane_left
	append specs $coll_generator_parking_lane_right
	append specs $coll_generator_sidewalk_left
	append specs $coll_generator_sidewalk_right
	specs
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn MoveCollToLayer obj =
(
	local collLayer = LayerManager.getLayerFromName "[CrossRoad_Generator_Colls]"

	if collLayer == undefined then collLayer = LayerManager.newLayer()
	collLayer.setname "[CrossRoad_Generator_Colls]"
		
	collLayer.addNode obj
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rollout dlgPickObjectType "Menu"
(
	radiobuttons rb_type labels:#("CROSSROAD    ",  "ROAD               ", "UTILITIES") default:1 align:#left  columns:1   --"TURN                           "
	dropdownlist dd_crossroad_types "" items:#("2 Side Roads", "2 Different Side Roads", "1 Side Road" ) height:6  offset:[100,-50] width:140
	button bt_createColl "Create Collisions" offset:[55,-90] width:140 height:25
	button bt_createShortcut "Create Shortcut" offset:[55,0] width:140 height:25
	button bt_copyUnique "Copy Unique CrossRoad" offset:[55,-3] width:140 height:25

-- 	label fill ""
	
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
-- 		print arg
		ClearRollFloater floaterGenerator
-- 		rb_lane_width_2_1.state = 0
		
		Case (arg) of (
			1: (
					SetCrosroadRoll dd_crossroad_types.selection
-- 					addRollout dlgCrossroadGenerator floaterGenerator
					dd_crossroad_types.visible = True
					bt_copyUnique.visible = True
					bt_createColl.visible = True
					bt_createColl.pos = [113,60]
					bt_createShortcut.visible = false
					dlgPickObjectType.height = 90
				)
			2 :(
					floaterGenerator.size = [270,360]
					addRollout RoadGeneratorTool floaterGenerator
					dd_crossroad_types.visible = False
					bt_copyUnique.visible = false
					bt_createColl.visible = True
					bt_createColl.pos = [113,30]
					bt_createShortcut.visible = True
					dlgPickObjectType.height = 65
				)
			3 :(
					floaterGenerator.size = [270,220]
					addRollout rGeneratorUtilities floaterGenerator
					dd_crossroad_types.visible = False
					bt_copyUnique.visible = false
					bt_createColl.visible = false
					bt_createShortcut.visible = false
					dlgPickObjectType.height = 65
			)
		)
	)
	
	on dd_crossroad_types selected  arg do (
		ClearRollFloater floaterGenerator
		SetCrosroadRoll arg
	)	
	
	on dlgPickObjectType open do (
		dlgPickObjectType.height = 90
	)
	
	on dlgPickObjectType close do (
		callbacks.removeScripts id:#crossGenRoll
		callbacks.removeScripts id:#crossGenDell
		callbacks.removeScripts id:#removeCAs
	)

	on bt_copyUnique pressed do (
		CopyUniqueCrossRoad $
	)
	on bt_createShortcut pressed do roGenStruct.createCrossroadFromRoad selection[1]
	-------------------------------------------------	COLLS -------------------------------------------------------------------------
-- 	#### Prasecina na ENTOU:] kdyz rychle tak rychle########################################################
	on bt_createColl pressed do (
		roadObj  = undefined 
		sel = selection as array
		
		local toSelect = #()
		
		for obj in sel do(
			
-- 		if sel.count == 1 then(
-- 			obj = sel[1]
			if matchPattern obj.name pattern:"generator_crossroad_4R*" then roadObj = #FourCross
			if matchPattern obj.name pattern:"generator_crossroad_4DR*" then roadObj = #FourDiffCross
			if matchPattern obj.name pattern:"generator_crossroad_3R*" then roadObj = #ThreeCross
			if matchPattern obj.name pattern:"generator_crossroad_3FR*" then roadObj = #ThreeFlipCross
			if matchPattern obj.name pattern:"generator_connect_road*" then roadObj = #Road
-- 		)
		
			if roadObj != undefined then (
				
				select obj
				
				local collsRoads = #()
				local collsSidewalks = #()
				local collsCorners = #()
				local collsParking_lanes = #()
				
				
				
				
				AppendCollsToArrays &collsRoads &collsSidewalks &collsCorners &collsParking_lanes
				
	-- 			print roadObj
					
				Case (roadObj) of (
					
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 			 ######################## FOUR  #################################################################################################
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					#FourCross : (
						
						generated_road  = obj
					
						------------------------------------------------------------------------------------------------------------
						spec_1 = (not dlgCrossroadGenerator.cb_parking_lane_1.state) and dlgCrossroadGenerator.cb_parking_lane_2.state
						spec_2 = dlgCrossroadGenerator.cb_parking_lane_1.state and (not dlgCrossroadGenerator.cb_parking_lane_2.state)
						
						------------------------------------------------------------------------------------------------------------
						road_1_model = undefined
						road_2_model = undefined
						plRoad1 = false
						plRoad2 = false
						
						plTopBot = True
						
						if spec_2 != false then(
							road_1_model = CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator.dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
							plRoad1 = True
							plTopBot = false
						)
						else road_1_model = PickRoadPrefab collsRoads dlgCrossroadGenerator.dd_crossroad_prefabs_1.selection spec_1
						
						if spec_1 != false then(
							road_2_model = CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator.dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
							plRoad2 = True
							plTopBot = false
						)
						else road_2_model = PickRoadPrefab collsRoads dlgCrossroadGenerator.dd_crossroad_prefabs_2.selection spec_2
						
						if spec_1 != false or spec_2 != false then corner_model  = collsCorners[1]
						else corner_model = SelectCorner collsCorners (bit.or dlgCrossroadGenerator.cb_parking_lane_1.triState dlgCrossroadGenerator.cb_parking_lane_2.triState)
						
						------------------------------------------------------------------------------------------------------------					
						road_1 = copy road_1_model

						road_1.name = replace road_1.name 16 6 "crossroad_4R"
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
						  
						road_1_bb = GetBoundingBox road_1
						road_2_bb = GetBoundingBox road_2_a
						
						road_1_length = GetLengthBB road_1_bb
						
						corner_bb = GetBoundingBox corner_model
						
						attributes_1 = CreateConnectingRoad road_2_a road_1_bb road_2_bb corner_model corner_bb dlgCrossroadGenerator.spnr_angle_1.value placed_items 0 dlgCrossroadGenerator.spnr_offset_1.value 
						attributes_2 = CreateConnectingRoad road_2_b road_1_bb road_2_bb corner_model corner_bb dlgCrossroadGenerator.spnr_angle_2.value placed_items 180 dlgCrossroadGenerator.spnr_offset_2.value 
						
						delete road_2_a
						delete road_2_b
						
						
						top_corners = attributes_1[1]
						bottom_corners = attributes_2[1]
						  
						if not ((dlgCrossroadGenerator.cb_parking_lane_1.state) and (dlgCrossroadGenerator.cb_parking_lane_2.state)) then
						(
						  ChangeMaterialId top_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						  ChangeMaterialId top_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						  ChangeMaterialId bottom_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						  ChangeMaterialId bottom_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						)
						  
						max_dist_left = RMin (attributes_1[2][1]) (attributes_2[2][2])
						max_dist_right = RMax (attributes_1[2][2]) (attributes_2[2][1])
						
						AddRoadSlicer road_1 (max_dist_left) 3
						AddRoadSlicer road_1 (max_dist_right) 2
						
						
						delete attributes_1[1][4].children
						delete attributes_2[1][4].children
						
						delete attributes_1[1][4]
						delete attributes_2[1][4]
						
						
						road_1 = ConvertTo road_1 editable_poly
						cutted_road_bb = GetBoundingBox road_1
						  
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

						sidewalk_bb = GetBoundingBox collsSidewalks[C_SIDEWALK_LEFT]
						parking_lane_bb = GetBoundingBox collsParking_lanes[C_PARKING_LANE_LEFT]

						place_pl_1 = dlgCrossroadGenerator.cb_parking_lane_1.state or dlgCrossroadGenerator.cb_parking_lane_2.state
						place_pl_2 = dlgCrossroadGenerator.cb_parking_lane_1.state or dlgCrossroadGenerator.cb_parking_lane_2.state
						
						
						
						pts_to_connect_top = #()
						pts_to_connect_bottom = #()
						append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]
						append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
						  
						road_width = (GetWidthBB cutted_road_bb)
						road_left = (GetLeftBB cutted_road_bb)
						road_right = (GetRightBB cutted_road_bb)
						
						--top side
						if tri_right_top_further == -1 then
						(
							if dlgCrossroadGenerator.cb_parking_lane_1.state == True and dlgCrossroadGenerator.cb_parking_lane_2.state == false then place_pl_1 = false
							if dlgCrossroadGenerator.cb_parking_lane_1.state == false and dlgCrossroadGenerator.cb_parking_lane_2.state == True then place_pl_1 = false
							sw = PlaceAdditional top_corners[2] 0 collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_right - (attributes_1[2][2]))) placed_items
							road_1.attach sw road_1 
							append pts_to_connect_top [attributes_1[2][2], road_1_length/2, 0.0]
						)
						
						if dlgCrossroadGenerator.spnr_angle_1.value > 90.0 then
						(
							if spec_1 or spec_2 then place_pl_2 = false
							if dlgCrossroadGenerator.cb_parking_lane_1.state == false and dlgCrossroadGenerator.cb_parking_lane_2.state == True then place_pl_2 = false
								
						  sw = PlaceAdditional top_corners[2] (dlgCrossroadGenerator.spnr_angle_1.value) collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_1[2][3]) placed_items
						  road_1.attach sw road_1
						)
						
						if tri_left_top_further == -1 then
						(
							if dlgCrossroadGenerator.cb_parking_lane_1.state == True and dlgCrossroadGenerator.cb_parking_lane_2.state == false then place_pl_1 = false
							if dlgCrossroadGenerator.cb_parking_lane_1.state == false and dlgCrossroadGenerator.cb_parking_lane_2.state == True then place_pl_1 = false
						  sw = PlaceAdditional top_corners[1] 180 collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_left - (attributes_1[2][1]))) placed_items
						  road_1.attach sw road_1
						  append pts_to_connect_top [attributes_1[2][1], road_1_length/2, 0.0]
						)
						
						if dlgCrossroadGenerator.spnr_angle_1.value < 90.0 then 
						(
						  if spec_1 or spec_2 then place_pl_2 = false
						  sw = PlaceAdditional top_corners[1] (dlgCrossroadGenerator.spnr_angle_1.value) collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_1[2][3]) placed_items
						  road_1.attach sw road_1
						)
						
						--bottom side
						if tri_right_top_further == 1 then
						(
							if dlgCrossroadGenerator.cb_parking_lane_1.state == True and dlgCrossroadGenerator.cb_parking_lane_2.state == false then place_pl_1 = false
							if dlgCrossroadGenerator.cb_parking_lane_1.state == false and dlgCrossroadGenerator.cb_parking_lane_2.state == True then place_pl_1 = false
						  sw = PlaceAdditional bottom_corners[1] 0 collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_right - (attributes_2[2][1]))) placed_items
						  road_1.attach sw road_1
						  append pts_to_connect_bottom [attributes_2[2][1], -road_1_length/2, 0.0]
						)
						if dlgCrossroadGenerator.spnr_angle_2.value < 90.0 then
						(
						  if spec_1 or spec_2 then place_pl_2 = false
						  sw = PlaceAdditional bottom_corners[1] (dlgCrossroadGenerator.spnr_angle_2.value+180) collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_2[2][3]) placed_items
						  road_1.attach sw road_1
						)
						if tri_left_top_further == 1 then
						(
							if dlgCrossroadGenerator.cb_parking_lane_1.state == True and dlgCrossroadGenerator.cb_parking_lane_2.state == false then place_pl_1 = false
							if dlgCrossroadGenerator.cb_parking_lane_1.state == false and dlgCrossroadGenerator.cb_parking_lane_2.state == True then place_pl_1 = false
						  sw = PlaceAdditional bottom_corners[2] 180 collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_left - (attributes_2[2][2]))) placed_items
						  road_1.attach sw road_1
						  append pts_to_connect_bottom [attributes_2[2][2], -road_1_length/2, 0.0]
						)
						if dlgCrossroadGenerator.spnr_angle_2.value > 90.0 then
						(
						  if spec_1 or spec_2 then place_pl_2 = false
						  sw = PlaceAdditional bottom_corners[2] (dlgCrossroadGenerator.spnr_angle_2.value+180) collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_2[2][3]) placed_items
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
						road_1 = ConvertTo road_1 Editable_poly
						
						vert_count = (polyop.getNumVerts road_1)
						all_vert_list = #{1..vert_count}
						
						road_1.weldThreshold = 1.0
						polyop.weldVertsByThreshold road_1 all_vert_list
						
						if generated_road != undefined then road_1.transform = generated_road.transform 			
			
						generated_road = road_1
						
						SetCrossRoadWireColor generated_road
						
						
						append toSelect generated_road
						
						DeleteWrongParkingLines coll:True
						
						MoveCollToLayer generated_road
						
					)
					
					
					
					
					
					
					
					
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 			 ######################## FOUR DIFFS #################################################################################################
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
					
					#FourDiffCross : (
						
						generated_road  = obj
						  
						spec_1 = dlgCrossroadGenerator2.cb_parking_lane_1.state--(not cb_parking_lane_1.state) and cb_parking_lane_2.state
						spec_2 = dlgCrossroadGenerator2.cb_parking_lane_2.state--cb_parking_lane_1.state and (not cb_parking_lane_2.state)
						spec_3 = dlgCrossroadGenerator2.cb_parking_lane_3.state--cb_parking_lane_1.state and (not cb_parking_lane_3.state)
						
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
							road_1_model 	= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection spec_1
							road_2_model 	= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection spec_2
							road_3_model 	= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection spec_3
							corner_model 		= collsCorners[2]
							corner_model_2 	= collsCorners[2]
							plTop = True
							plBot = True
						)
						
						else if spec_1 == false and spec_2 == false and spec_3 == false then (
							road_1_model 	= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection spec_1
							road_2_model 	= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection spec_2
							road_3_model 	= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection spec_3
							corner_model 		= collsCorners[1]
							corner_model_2 	= collsCorners[1]
						)

						else if spec_1 == True and spec_2 == false and spec_3 == false then (
							road_1_model 		= CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
							corner_model 		= collsCorners[1]
							corner_model_2 	= collsCorners[1]
							road_2_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection spec_2
							road_3_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection spec_3
							plRoad = road_1_model
						)
						
						else if spec_1 == True and spec_2 == True and spec_3 == false then (
							road_1_model 		= CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection &spec_1 false True &origPivot
							corner_model 		= collsCorners[2]
							corner_model_2 	= collsCorners[1]
							road_2_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection spec_2
							road_3_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection spec_3
							
							plTop = True
							plRoad = road_1_model
						)
						
						else if spec_1 == True and spec_2 == false and spec_3 == true then (
							road_1_model 		= CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection &spec_1 True false &origPivot
							corner_model 		= collsCorners[1]
							corner_model_2 	= collsCorners[2]
							road_2_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection spec_2
							road_3_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection spec_3
							
							plBot = True
							plRoad = road_1_model
						)
						
						else if spec_1 == false and spec_2 == True and spec_3 == false then (
							road_2_model 		= CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
							corner_model 		= collsCorners[1]
							corner_model_2 	= collsCorners[1]
							road_1_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection spec_1
							road_3_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection spec_3
							plRoad = road_2_model
						)
						
				-- 		print spec_1
						else if spec_1 == false and spec_2 == false and spec_3 == True then (
							road_3_model 		= CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection &spec_3 True True &origPivot
							road_1_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection spec_1
							road_2_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection spec_2
							corner_model 		= collsCorners[1]
							corner_model_2 	= collsCorners[1]
							plRoad = road_3_model
						)
						
						else if spec_1 == false and spec_2 == True and spec_3 == True then (
							
							road_1_model 		= PickRoadPrefab collsRoads dlgCrossroadGenerator2.dd_crossroad_prefabs_1.selection spec_1
							road_2_model 		= CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator2.dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
							road_3_model 		= CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator2.dd_crossroad_prefabs_3.selection &spec_3 True True &origPivot
							corner_model 		= collsCorners[1]
							corner_model_2 	= collsCorners[1]
							plRoad 	= road_3_model
							plRoad2 	= road_2_model
						)
				
						road_1 = copy road_1_model
					-- 	road_1.name = replace road_1.name 11 4 "crossroad"

						road_1.name = replace road_1.name 16 6 "crossroad_4DR"
						road_1.name = uniquename(road_1.name)	
						
						
						road_1.position = [0, 0, 0]
						road_2_a = copy road_2_model
						road_2_a.position = [0, 0, 0]
						road_2_b = copy road_3_model
						road_2_b.position = [0, 0, 0]

						---------------------------------------------------------------------------
						if plRoad != undefined then delete plRoad
						if plRoad2 != undefined then delete plRoad2
						---------------------------------------------------------------------------  
						  
						road_1_bb = GetBoundingBox road_1
						road_2_bb = GetBoundingBox road_2_a
						road_3_bb = GetBoundingBox road_2_b
						
						road_1_length = GetLengthBB road_1_bb
						
						corner_bb = GetBoundingBox corner_model
						corner_2_bb = GetBoundingBox corner_model_2
						
						
						attributes_1 = CreateConnectingRoad road_2_a road_1_bb road_2_bb corner_model corner_bb dlgCrossroadGenerator2.spnr_angle_1.value placed_items 0 dlgCrossroadGenerator2.spnr_offset_1.value --prevPt:pTop
						attributes_2 = CreateConnectingRoad road_2_b road_1_bb road_3_bb corner_model_2 corner_2_bb dlgCrossroadGenerator2.spnr_angle_2.value placed_items 180 dlgCrossroadGenerator2.spnr_offset_2.value --prevPt:pBot
						
						delete road_2_a
						delete road_2_b
						
						--print ("Attr1: "+(attributes_1 as string))
						--print ("Attr2: "+(attributes_2 as string))
						
						top_corners = attributes_1[1]
						bottom_corners = attributes_2[1]
						  
						if not ((dlgCrossroadGenerator2.cb_parking_lane_1.state) and (dlgCrossroadGenerator2.cb_parking_lane_2.state)) then
						(
						  ChangeMaterialId top_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						  ChangeMaterialId top_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						)
						
						if not ((dlgCrossroadGenerator2.cb_parking_lane_1.state) and (dlgCrossroadGenerator2.cb_parking_lane_3.state)) then
						(
						  ChangeMaterialId bottom_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						  ChangeMaterialId bottom_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						)
						
						
						max_dist_left = RMin (attributes_1[2][1]) (attributes_2[2][2])
						max_dist_right = RMax (attributes_1[2][2]) (attributes_2[2][1])
						--print ("max dist left "+(max_dist_left as string)) 
						--print ("max dist right "+(max_dist_right as string))
						
						AddRoadSlicer road_1 (max_dist_left) 3
						AddRoadSlicer road_1 (max_dist_right) 2


						delete attributes_1[1][4].children
						delete attributes_2[1][4].children
						
						delete attributes_1[1][4]
						delete attributes_2[1][4]
						
						
						road_1 = ConvertTo road_1 editable_poly
						cutted_road_bb = GetBoundingBox road_1
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
						  
						sidewalk_bb = GetBoundingBox collsSidewalks[C_SIDEWALK_LEFT]
						parking_lane_bb = GetBoundingBox collsParking_lanes[C_PARKING_LANE_LEFT]
						
						
						
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
						  
						road_width = (GetWidthBB cutted_road_bb)
						road_left = (GetLeftBB cutted_road_bb)
						road_right = (GetRightBB cutted_road_bb)
						--top side
						if tri_right_top_further == -1 then
						(
						  sw = PlaceAdditional top_corners[2] 0 collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_right - (attributes_1[2][2]))) placed_items
						  road_1.attach sw road_1 
						  append pts_to_connect_top [attributes_1[2][2], road_1_length/2, 0.0]
						)
						if dlgCrossroadGenerator2.spnr_angle_1.value > 90.0 then
						(
						  sw = PlaceAdditional top_corners[2] (dlgCrossroadGenerator2.spnr_angle_1.value) collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_1[2][3]) placed_items
						  road_1.attach sw road_1
						)
						if tri_left_top_further == -1 then
						(
						  sw = PlaceAdditional top_corners[1] 180 collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_left - (attributes_1[2][1]))) placed_items
						  road_1.attach sw road_1
						  append pts_to_connect_top [attributes_1[2][1], road_1_length/2, 0.0]
						)
						if dlgCrossroadGenerator2.spnr_angle_1.value < 90.0 then 
						(
				-- 		  if plTop then place_pl_1 = false
						  sw = PlaceAdditional top_corners[1] (dlgCrossroadGenerator2.spnr_angle_1.value) collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_1[2][3]) placed_items
						  road_1.attach sw road_1
						)
						
						--bottom side
						if tri_right_top_further == 1 then
						(
						  sw = PlaceAdditional bottom_corners[1] 0 collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (abs (max_dist_right - (attributes_2[2][1]))) placed_items
						  road_1.attach sw road_1
						  append pts_to_connect_bottom [attributes_2[2][1], -road_1_length/2, 0.0]
						)
						if dlgCrossroadGenerator2.spnr_angle_2.value < 90.0 then
						(
				-- 		  if plBot then place_pl_2 = true
						  sw = PlaceAdditional bottom_corners[1] (dlgCrossroadGenerator2.spnr_angle_2.value+180) collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_2[2][3]) placed_items
						  road_1.attach sw road_1
						)
						if tri_left_top_further == 1 then
						(
						  sw = PlaceAdditional bottom_corners[2] 180 collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_1 spec_1 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (abs (max_dist_left - (attributes_2[2][2]))) placed_items
						  road_1.attach sw road_1
						  append pts_to_connect_bottom [attributes_2[2][2], -road_1_length/2, 0.0]
						)
						if dlgCrossroadGenerator2.spnr_angle_2.value > 90.0 then
						(
				-- 		  if plBot then place_pl_2 = true
						  sw = PlaceAdditional bottom_corners[2] (dlgCrossroadGenerator2.spnr_angle_2.value+180) collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_2[2][3]) placed_items
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
							
						
						road_1 = ConvertTo road_1 Editable_poly
						
						vert_count = (polyop.getNumVerts road_1)
						all_vert_list = #{1..vert_count}
						
						road_1.weldThreshold = 1.0
						polyop.weldVertsByThreshold road_1 all_vert_list
						
						if generated_road != undefined then road_1.transform = generated_road.transform 			
			
						generated_road = road_1
						
						SetCrossRoadWireColor generated_road
						
						append toSelect generated_road
						
						DeleteWrongParkingLines coll:True
						
						MoveCollToLayer generated_road
						
					)
					
					
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 			 ######################## THREE  #################################################################################################
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					#ThreeCross : (
						
						generated_road  = obj
						
						spec_1 = (not dlgCrossroadGenerator3.cb_parking_lane_1.state) and dlgCrossroadGenerator3.cb_parking_lane_2.state
						spec_2 = dlgCrossroadGenerator3.cb_parking_lane_1.state and (not dlgCrossroadGenerator3.cb_parking_lane_2.state)

						road_1_model = undefined
						road_2_model = undefined
						plRoad1 = false
						plRoad2 = false
						
						plTopBot = True
						
						if spec_2 != false then(
							road_1_model = CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator3.dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
							plRoad1 = True
							plTopBot = false
						)
						else road_1_model = PickRoadPrefab collsRoads dlgCrossroadGenerator3.dd_crossroad_prefabs_1.selection spec_1
						
						if spec_1 != false then(
							road_2_model = CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator3.dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
							plRoad2 = True
							plTopBot = false
						)
						else road_2_model = PickRoadPrefab collsRoads dlgCrossroadGenerator3.dd_crossroad_prefabs_2.selection spec_2
						
						if spec_1 != false or spec_2 != false then corner_model  = collsCorners[1]
						else corner_model = SelectCorner collsCorners (bit.or dlgCrossroadGenerator3.cb_parking_lane_1.triState dlgCrossroadGenerator3.cb_parking_lane_2.triState)
						
							
						road_1 = copy road_1_model
						  
						road_1.name = replace road_1.name 16 6 "crossroad_3R"
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
						  
						road_1_bb = GetBoundingBox road_1
						road_2_bb = GetBoundingBox road_2_a
						
						road_1_length = GetLengthBB road_1_bb
						
						corner_bb = GetBoundingBox corner_model
										

						attributes_1 = CreateConnectingRoad road_2_a road_1_bb road_2_bb corner_model corner_bb dlgCrossroadGenerator3.spnr_angle_1.value placed_items 0 dlgCrossroadGenerator3.spnr_offset_1.value --prevPt:pTop
						
						delete road_2_a
						
						top_corners = attributes_1[1]
						  
						if not ((dlgCrossroadGenerator3.cb_parking_lane_1.state) and (dlgCrossroadGenerator3.cb_parking_lane_2.state)) then
						(
						  ChangeMaterialId top_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						  ChangeMaterialId top_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						)
						
						max_dist_left = attributes_1[2][1]
						max_dist_right = attributes_1[2][2]
									
						AddRoadSlicer road_1 (max_dist_left) 3
						AddRoadSlicer road_1 (max_dist_right) 2
						
						
						delete attributes_1[1][4].children				
						delete attributes_1[1][4]

						
						road_1 = ConvertTo road_1 editable_poly
						cutted_road_bb = GetBoundingBox road_1

						road_edge_indices = GetRoadEdgeIndices road_1
						  
						tri_left_top_further = 1
						tri_right_top_further = 1
						
						sidewalk_bb = GetBoundingBox collsSidewalks[C_SIDEWALK_LEFT]
						parking_lane_bb = GetBoundingBox collsParking_lanes[C_PARKING_LANE_LEFT]
						  
						place_pl_1 = dlgCrossroadGenerator3.cb_parking_lane_1.state or dlgCrossroadGenerator3.cb_parking_lane_2.state
						place_pl_2 = dlgCrossroadGenerator3.cb_parking_lane_1.state or dlgCrossroadGenerator3.cb_parking_lane_2.state
						pts_to_connect_top = #()

						append pts_to_connect_top [attributes_1[2][4], road_1_length/2, 0.0]

						road_width = (GetWidthBB cutted_road_bb)
						road_left = (GetLeftBB cutted_road_bb)
						road_right = (GetRightBB cutted_road_bb)
						
						

						if dlgCrossroadGenerator3.spnr_angle_1.value > 90.0 then
						(
						if spec_1 or spec_2 then place_pl_2 = false
						  sw = PlaceAdditional top_corners[2] (dlgCrossroadGenerator3.spnr_angle_1.value) collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_1[2][3]) placed_items
						  road_1.attach sw road_1
						)

						if dlgCrossroadGenerator3.spnr_angle_1.value < 90.0 then 
						(
						  if spec_1 or spec_2 then place_pl_2 = false
						  sw = PlaceAdditional top_corners[1] (dlgCrossroadGenerator3.spnr_angle_1.value) collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_1[2][3]) placed_items
						  road_1.attach sw road_1
						)
						
						
						
						
						--bottom side
						roadBotBB =  cutted_road_bb[1][2]
						sidewalkBBLenght = GetLengthBB sidewalk_bb
						parkLineBBLenght = GetLengthBB parking_lane_bb
						
						sidewalk_copy = copy collsSidewalks[C_SIDEWALK_RIGHT]
						sw = ConvertTo sidewalk_copy editable_poly
						
						AddRoadSlicer sw (road_width) 2
						
						
						yMove = roadBotBB - sidewalkBBLenght
						if dlgCrossroadGenerator3.cb_parking_lane_1.state and dlgCrossroadGenerator3.cb_parking_lane_2.state then (
							yMove -= parkLineBBLenght
							parking_lane_copy = copy collsParking_lanes[C_PARKING_LANE_RIGHT]
							pl = ConvertTo parking_lane_copy editable_poly
							-- 	rotate parking_lane_copy (angleaxis rotate_angle [0,0,1])
							pl.position = [max_dist_left,yMove,12.265]
							AddRoadSlicer pl (road_width) 2
							sw.position = [max_dist_left,yMove,12.265]
							sw.attach pl pl
						)else(
							sw.position = [max_dist_left,yMove,12.265]
						)


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

						
						road_1.attach top_corners[1] road_1
						road_1.attach top_corners[2] road_1
						road_1.attach attributes_1[1][3] attributes_1[1][3]	

						
						
						road_1 = ConvertTo road_1 Editable_poly
						
						
						road_1.EditablePoly.attach sw road_1
						
						vert_count = (polyop.getNumVerts road_1)
						all_vert_list = #{1..vert_count}
						
						road_1.weldThreshold = 1.0
						polyop.weldVertsByThreshold road_1 all_vert_list
						
						if generated_road != undefined then road_1.transform = generated_road.transform 			
			
						generated_road = road_1
						
						SetCrossRoadWireColor generated_road
						
						append toSelect generated_road
						
						DeleteWrongParkingLines coll:True
						
						MoveCollToLayer generated_road
					)
					
					
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 			 ######################## THREE FLIPPED  #################################################################################################
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------				
					#ThreeFlipCross : (
						
						generated_road  = obj
			
						spec_1 = (not dlgCrossroadGenerator3.cb_parking_lane_1.state) and dlgCrossroadGenerator3.cb_parking_lane_2.state
						spec_2 = dlgCrossroadGenerator3.cb_parking_lane_1.state and (not dlgCrossroadGenerator3.cb_parking_lane_2.state)
						
						------------------------------------------------------------------------------------------------------------
						road_1_model = undefined
						road_2_model = undefined
						plRoad1 = false
						plRoad2 = false
						
						plTopBot = True
						
						if spec_2 != false then(
							road_1_model = CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator3.dd_crossroad_prefabs_1.selection &spec_1 True True &origPivot
							plRoad1 = True
							plTopBot = false
						)
						else road_1_model = PickRoadPrefab collsRoads dlgCrossroadGenerator3.dd_crossroad_prefabs_1.selection spec_1
						
						if spec_1 != false then(
							road_2_model = CreateRoadWithPL collsRoads collsParking_lanes dlgCrossroadGenerator3.dd_crossroad_prefabs_2.selection &spec_2 True True &origPivot
							plRoad2 = True
							plTopBot = false
						)
						else road_2_model = PickRoadPrefab collsRoads dlgCrossroadGenerator3.dd_crossroad_prefabs_2.selection spec_2
						
						if spec_1 != false or spec_2 != false then corner_model  = collsCorners[1]
						else corner_model = SelectCorner collsCorners (bit.or dlgCrossroadGenerator3.cb_parking_lane_1.triState dlgCrossroadGenerator3.cb_parking_lane_2.triState)
							
						road_1 = copy road_1_model
						road_1.name = replace road_1.name 16 6 "crossroad_3FR"
						road_1.name = uniquename(road_1.name)
						  
						road_1.position = [0, 0, 0]
						road_2_b = copy road_2_model
						road_2_b.position = [0, 0, 0]
						
						
						---------------------------------------------------------------------------
						if plRoad1 then delete road_1_model
						if plRoad2 then delete road_2_model
						---------------------------------------------------------------------------
						  
						road_1_bb = GetBoundingBox road_1
						road_2_bb = GetBoundingBox road_2_b
						
						road_1_length = GetLengthBB road_1_bb
						
						corner_bb = GetBoundingBox corner_model
						
						
						
						flippedAngle = 90
						if dlgCrossroadGenerator3.spnr_angle_1.value < 90 then flippedAngle += abs(flippedAngle - dlgCrossroadGenerator3.spnr_angle_1.value)
						if dlgCrossroadGenerator3.spnr_angle_1.value > 90 then flippedAngle -= abs(flippedAngle - dlgCrossroadGenerator3.spnr_angle_1.value)

						attributes_2 = CreateConnectingRoad road_2_b road_1_bb road_2_bb corner_model corner_bb flippedAngle placed_items 180 dlgCrossroadGenerator3.spnr_offset_1.value 
						
						delete road_2_b

						bottom_corners = attributes_2[1]
						  
						if not ((dlgCrossroadGenerator3.cb_parking_lane_1.state) and (dlgCrossroadGenerator3.cb_parking_lane_2.state)) then
						(
						  ChangeMaterialId bottom_corners[1] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						  ChangeMaterialId bottom_corners[2] C_OLD_MATERIAL_ID C_NEW_MATERIAL_ID
						)
						  
						
						max_dist_left = attributes_2[2][1]
						max_dist_right = attributes_2[2][2]
						
						
						AddRoadSlicer road_1 (max_dist_right) 3
						AddRoadSlicer road_1 (max_dist_left) 2


						delete attributes_2[1][4].children				
						delete attributes_2[1][4]
						
						road_1 = ConvertTo road_1 editable_poly
						cutted_road_bb = GetBoundingBox road_1

						  
						road_edge_indices = GetRoadEdgeIndices road_1
						  
						  
						tri_left_top_further = -1
						tri_right_top_further = -1
						
						
						sidewalk_bb = GetBoundingBox collsSidewalks[C_SIDEWALK_LEFT]
						parking_lane_bb = GetBoundingBox collsParking_lanes[C_PARKING_LANE_LEFT]
						  
						place_pl_2 = dlgCrossroadGenerator3.cb_parking_lane_1.state or dlgCrossroadGenerator3.cb_parking_lane_2.state
						

						pts_to_connect_bottom = #()
						
						append pts_to_connect_bottom[attributes_2[2][4], -road_1_length/2, 0.0]
						  
						road_width = (GetWidthBB cutted_road_bb)
						road_left = (GetLeftBB cutted_road_bb)
						road_right = (GetRightBB cutted_road_bb)

						roadTopYBB =  cutted_road_bb[2][2]
						sidewalkBBLenght = GetLengthBB sidewalk_bb
						parkLineBBLenght = GetLengthBB parking_lane_bb
						
						
						--BOT side
						
						if dlgCrossroadGenerator3.spnr_angle_1.value < 90.0 then
						(
							if spec_1 or spec_2 then place_pl_2 = false

							sw = PlaceAdditional bottom_corners[2] (flippedAngle +180) collsSidewalks[C_SIDEWALK_RIGHT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_RIGHT] parking_lane_bb (attributes_2[2][3]) placed_items
							road_1.attach sw road_1
						)

						if dlgCrossroadGenerator3.spnr_angle_1.value > 90.0 then
						(
							if spec_1 or spec_2 then place_pl_2 = false
							sw = PlaceAdditional bottom_corners[1] (flippedAngle + 180) collsSidewalks[C_SIDEWALK_LEFT] sidewalk_bb place_pl_2 spec_2 collsParking_lanes[C_PARKING_LANE_LEFT] parking_lane_bb (attributes_2[2][3]) placed_items	
							road_1.attach sw road_1
						)
						

						--TOP SIDE
						sidewalk_copy = copy collsSidewalks[C_SIDEWALK_LEFT]
						sw = ConvertTo sidewalk_copy editable_poly
						
					-- 	rotate sw (angleaxis rotate_angle [0,0,1])	
						AddRoadSlicer sw (road_width) 2
						
						
						yMove = roadTopYBB + sidewalkBBLenght
						if dlgCrossroadGenerator3.cb_parking_lane_1.state and dlgCrossroadGenerator3.cb_parking_lane_2.state then (
							yMove += parkLineBBLenght
							parking_lane_copy = copy collsParking_lanes[C_PARKING_LANE_LEFT]
							pl = ConvertTo parking_lane_copy editable_poly
							-- 	rotate parking_lane_copy (angleaxis rotate_angle [0,0,1])
							pl.position = [max_dist_right,yMove,12.265]
							AddRoadSlicer pl (road_width) 2
							sw.position = [max_dist_right,yMove,12.265]
							sw.attach pl pl
						)else(
							sw.position = [max_dist_right,yMove,12.265]
						)
						
						
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
						

						
						road_1 = ConvertTo road_1 Editable_poly

						road_1.EditablePoly.attach sw road_1
						
						vert_count = (polyop.getNumVerts road_1)
						all_vert_list = #{1..vert_count}
						
						road_1.weldThreshold = 1.0
						polyop.weldVertsByThreshold road_1 all_vert_list
						
						if generated_road != undefined then road_1.transform = generated_road.transform 			
			
						generated_road = road_1
						
						SetCrossRoadWireColor generated_road
						
						append toSelect generated_road
						
						DeleteWrongParkingLines coll:True
						
						MoveCollToLayer generated_road			

						
					)
					
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- 			 ######################## ROAD  #################################################################################################
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
					#Road : (
						
						spline = obj.roadSpline
						road = obj
						specs = GetSpecsForRoadGenerator()
						
						
						fSel = #(road, spline)
						
	-- 					oldWireColor = road.wirecolor
						
						
						
	-- 					prevParent = undefined
						
						if fSel[1] != undefined and fSel[2] != undefined then(
							select fSel
							selected_road = PickRoadPrefab collsRoads RoadGeneratorTool.dd_road_prefabs_1.selection false
							selected_road = ConstructRoadPrototype selected_road specs RoadGeneratorTool.cb_parking_lane_left.state RoadGeneratorTool.cb_parking_lane_right.state RoadGeneratorTool.cb_sidewalks_left.state RoadGeneratorTool.cb_sidewalks_right.state
							road = undefined
							spline = undefined
							-- get items from selection
							for i in 1 to $.count do
							(
		-- 						print ("ClassOf "+(classOf $[i] as string))
								if (classOf $[i] == Editable_Poly) or (classOf $[i] == PolyMeshObject) then
								(
									road = $[i]
		-- 							print ("Road was detected.")
								)
								if (classOf $[i] == SplineShape) then
								(
									spline = $[i]
		-- 							print ("Spline was detected.")
								)
							)
							if(road == undefined or spline == undefined) then
							(
								messageBox "Road or spline wasn't selected."
							) else 
							(
								--create road
								finalRoad = CreateRoadFromSpline selected_road spline RoadGeneratorTool.spinner_tangent.value
								finalRoad.name = replace finalRoad.name 16 6 "connect_road"
								finalRoad.name = uniquename(finalRoad.name)
								
								-- delete old road
								
	-- 							prevParent = road.parent
								
								
	-- 							delete road
								delete selected_road
								
								
								SetCrossRoadWireColor finalRoad --oldColor:oldWireColor
	-- 							finalRoad.parent = prevParent
								
								MoveCollToLayer finalRoad
								append toSelect finalRoad
							)
						)
					)
				)
			)
		)
		select toSelect
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
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
	local params = callbacks.notificationParam()

	if matchPattern params.name pattern:"generator_crossroad_4*" or matchPattern params.name pattern:"generator_crossroad_3*"then(
		DeleteCrossRoadChildren params
	)
	
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn CleanCAs =
(
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