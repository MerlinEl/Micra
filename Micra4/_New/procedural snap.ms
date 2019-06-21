source_center_vert = (roGenStruct.getClosestVert source_obj joint_pos)[1] 
target_center_vert = (roGenStruct.getClosestVert traget_obj joint_pos)[1] 
fn proceduralSnap obj_src obj_trgt range_start range_end = (
	
	
	
)


traget_obj = $generator_crossroad_4R_4_rail024
source_obj = $generator_connect_road_4_rail010
joint_pos = $Point098.pos
convertToPoly source_obj

source_border_vertices = roGenStruct.getRoadEdge source_obj joint_pos

for vd_src in source_border_vertices do (
	
	local src_pos = vd_src.pos 
	local vd_trgt = roGenStruct.getClosestVert traget_obj src_pos  maxDist:10
	format "src:% trgt:%\n" src_pos vd_trgt
	--polyop.setVert source_obj vd_src.index 
)



		 center_vert = (roGenStruct.getClosestVert traget_obj joint_pos)[1] 
		 border_edges = roGenStruct.getBorderEdgesFromVertex traget_obj center_vert
		traget_obj.selectedEdges = border_edges
		traget_obj.SelectEdgeLoop() --border edges
		 border_vertices = polyop.getVertsUsingEdge traget_obj (polyOp.getEdgeSelection traget_obj) --get border vertices
		 vd = struct VERTEX_DATA (index, pos)
		for v in border_vertices collect vd v (polyOp.getVert traget_obj v) --gather verts_data