--Aditional Functions for Unwrap Editor 2012
--Convert selection between subobject levels*
--Select edge border*
--Pack selection together in place*
--offset selection by one frame x y z*
--learn more about mapping api
--http://www.gritengine.com/maxscript_html/unwrap_uvw_modifier.htm

try (destroyDialog mcUnwrapEditorDialog) catch ()

rollout mcUnwrapEditorDialog "UV+" width:96 height:648
(
	-->Locals
	local vertex_position
	--<
	GroupBox grp6 "Selection" pos:[4,4] width:88 height:128
	button btn_verts "V" pos:[8,24] width:24 height:24 images:(mcCall.getIcon 103)  tooltip:"Convert Selection to Vertices"
	button btn_edges "E" pos:[36,24] width:24 height:24 images:(mcCall.getIcon 216) tooltip:"Convert Selection to Edges"
	button btn_faces "F" pos:[64,24] width:24 height:24 images:(mcCall.getIcon 40) tooltip:"Convert Selection to Faces"
	button btn_border "B" pos:[8,52] width:24 height:24 images:(mcCall.getIcon 41) tooltip:"Select Edge border"
	button btn_sel_similar "B" pos:[64,52] width:24 height:24 images:(mcCall.getIcon 220) tooltip:"Select Similar Faces"
	label lbl_min "min:" pos:[8,84] width:24 height:16
	spinner spn_min "" pos:[32,84] width:44 height:16 range:[0,100,10] type:#float
	label lbl_max "max:" pos:[8,104] width:24 height:16
	spinner spn_max "" pos:[32,104] width:44 height:16 range:[0,10000,20] type:#float
	label lbl6 "%" pos:[76,104] width:12 height:16
	label lbl7 "%" pos:[76,84] width:12 height:16
	button btn_sel_over "B" pos:[36,52] width:24 height:24 images:(mcCall.getIcon 240) toolTip:"Select Overlapped Faces (+Ctrl Grow to Element)"
	
	GroupBox grp7 "Move / Resize" pos:[4,140] width:88 height:104
	button btn_move_r "R" pos:[62,188] width:24 height:24 images:(mcCall.getIcon 177) tooltip:"Move Selection Right (+Ctrl Double Size In X)"
	button btn_move_l "L" pos:[6,188] width:24 height:24 images:(mcCall.getIcon 176)  tooltip:"Move Selection Left (+Ctrl Half Size In X)"
	button btn_move_u "U" pos:[34,160] width:24 height:24 images:(mcCall.getIcon 218) tooltip:"Move Selection Up (+Ctrl Double Size In Y)"
	button btn_move_d "D" pos:[34,216] width:24 height:24 images:(mcCall.getIcon 217) tooltip:"Move Selection Down (+Ctrl Half Size In Y)"
	button btn_move_c "c" pos:[34,188] width:24 height:24 images:(mcCall.getIcon 31) tooltip:"Move Selection Center (+Ctrl Double Size, +Alt Half Size)"
	
	GroupBox grp4 "Align:" pos:[4,248] width:88 height:104
	button btn_align_l "L" pos:[8,292] width:24 height:24 images:(mcCall.getIcon 232) toolTip:"Align Left"
	button btn_align_t "T" pos:[36,264] width:24 height:24 images:(mcCall.getIcon 233) toolTip:"Align Top"
	button btn_align_b "B" pos:[36,324] width:24 height:24 images:(mcCall.getIcon 234) toolTip:"Align Bottom"
	button btn_align_r "R" pos:[64,292] width:24 height:24 images:(mcCall.getIcon 235) toolTip:"Align Right"
	button btn_align_c "C" pos:[36,292] width:24 height:24 images:(mcCall.getIcon 236) toolTip:"Align Center"
	
	GroupBox 'grp12' "Complex" pos:[4,356] width:88 height:96 align:#left
	button 'btn_texel_density' "p1" pos:[8,372] width:24 height:24 images:(mcCall.getIcon 116) toolTip:"Texel Density"
	button 'btn_stitch' "St" pos:[34,372] width:24 height:24 toolTip:"Stitch Selected Edges (Experimental)"
	button 'btn_fit' "St" pos:[64,372] width:24 height:24 toolTip:"Fit To Rect (+Ctrl Proportionaly)" align:#left
	button 'btn_distr_x_plus' "Dx+" pos:[36,504] width:24 height:24 toolTip:"Distribute Elements At X Expand" align:#left
	button 'btn_distr_x_zero' "Dx-" pos:[60,504] width:24 height:24 toolTip:"Distribute Elements At X Contract" align:#left
	button 'btn_randomize_x' "RandX" pos:[8,400] width:36 height:24 toolTip:"Move Elements Random X (+Ctrl Random + -)" align:#left
	button 'btn_randomize_y' "RandY" pos:[48,400] width:36 height:24 toolTip:"Move Elements Random Y  (+Ctrl Random + -)" align:#left
	spinner 'spn_randomize' "" pos:[8,428] width:80 height:16 range:[0,100,0.5] align:#left
	button 'btn_rotate_verts' "R" pos:[12,504] width:24 height:24 toolTip:"ReformUV CV (Rotate Vertices Around Shape)" align:#left
	button 'btn_rotate_v' "Rot V" pos:[4,452] width:40 height:20 toolTip:"Rotate each UV element in selection Vertical" align:#left
	button 'btn_rotate_h' "Rot H" pos:[48,452] width:44 height:20 toolTip:"Rotate each UV element in selection Horizontal" align:#left
	
	GroupBox 'grp5' "Copy Paste" pos:[4,540] width:88 height:48 align:#left
	button 'btn_copy_pos' "C" pos:[8,556] width:24 height:24 toolTip:"Copy Vertex Position" align:#left
	button 'btn_paste_posx' "Px" pos:[36,556] width:24 height:24 toolTip:"Paste X" align:#left
	button 'btn_paste_posy' "Py" pos:[64,556] width:24 height:24 toolTip:"Paste Y" align:#left
	
	spinner 'spn_offset_steps' "" pos:[60,164] width:32 height:16 range:[1,99,1] type:#integer scale:1 align:#left
	label 'lbl_offset_steps' "step:" pos:[8,164] width:24 height:16 align:#left

	button 'button_skew_verts_minus' "-" pos:[8,612] width:24 height:24 align:#left toolTip:"Shew vertices CCW"
	button 'button_skew_verts_plus' "+" pos:[34,612] width:24 height:24 align:#left toolTip:"Shew vertices CW"
	GroupBox 'grp17' "Skew Verts" pos:[4,596] width:88 height:48 align:#left toolTip: "Skew Selected Vertices"
	spinner 'spn_skev_angle' "" pos:[60,616] width:32 height:16 range:[-360,360,5] type:#integer scale:1 align:#left
	button 'btn_sel_random' "Sel" pos:[5,476] width:28 height:20 toolTip:"Select random UV elements" align:#left
	spinner 'spn_sel_random' "" pos:[36,478] width:44 height:16 range:[1,100,10] type:#integer align:#left
	label 'lbl_sel_random' "%" pos:[80,479] width:12 height:16 align:#left

	--> Functions
	fn offsetResizeSelection type  = (
	
		if not (mcPolyMap.isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local gco = modpanel.getcurrentobject()
		local offset_steps = spn_offset_steps.value
		case type of (	
		
			#right:		( if keyboard.controlPressed then undo "Resize_UVW" on mcPolyMap.resizeUVW gco 2 #x else undo "Offset Right" on gco.MoveSelected [offset_steps,0,0])
			#left:		( if keyboard.controlPressed then undo "Resize_UVW" on mcPolyMap.resizeUVW gco 0.5 #x else undo "Offset Left"  on gco.MoveSelected [-offset_steps,0,0])
			#up:			( if keyboard.controlPressed then undo "Resize_UVW" on mcPolyMap.resizeUVW gco 2 #y else undo "Offset Up"    on gco.MoveSelected [0,offset_steps,0])
			#down:	( if keyboard.controlPressed then undo "Resize_UVW" on mcPolyMap.resizeUVW gco 0.5 #y else undo "Offset Down" on gco.MoveSelected [0,-offset_steps,0])
			#center:	( 
			
				if keyboard.controlPressed then undo "Resize_UVW" on  mcPolyMap.resizeUVW gco 2 #xy else
				if keyboard.altPressed     then undo "Resize_UVW" on  mcPolyMap.resizeUVW gco 0.5 #xy else
				undo "Offset Center" on gco.MoveSelected (0.5 - (gco.getSelCenter() ) ) 
			)
		)
	)

	fn selectUVWElementsBySize min_treeshold:0.5 max_treeshold:0.5 =
	(
		if not (mcPolyMap.isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local gco = modpanel.getcurrentobject()	
		case gco.getTVSubObjectMode() of
		(
			1: gco.selectVertices #{(gco.getSelectedVertices() as array)[1]}
			2: gco.selectEdges #{(gco.getSelectedEdges() as array)[1]}
			3: gco.selectFaces #{(gco.getSelectedFaces() as array)[1]}
		)
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
		local all_elements = mcPolyMap.getElements gco (all_faces as array)
		--filter only elements with treeshold
		local chosen_faces = #{}
		format "elements found:%\n" (all_elements.count+1)
		format "first element area:%\n" areaUVW
		
		local min_val = areaUVW - (areaUVW/100)*min_treeshold
		local max_val = areaUVW + (areaUVW/100)*max_treeshold
		
		format "min:%\tmax:%\n" min_val max_val 
		for a in all_elements where (a.area_uv >= min_val ) and (a.area_uv <= max_val) do --min max
		(
			chosen_faces += a.faces
		)
		chosen_faces += first_element
		--select faces in treeshold
		format "faces found in min:%\n"  chosen_faces.numberset
		if chosen_faces.numberset != 0 do (gco.selectFaces chosen_faces)
	)
	
	fn selectOverlapped =
	(
		if not (mcPolyMap.isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local gco = modpanel.getcurrentobject()	
		if keyboard.controlPressed then gco.selectElement()
		else
		(
			gco.setTVSubObjectMode 3
			gco.selectOverlappedFaces()
			gco.fitSelected()
			gco.updateView()
		)
	)
	
	fn alignTo type=
	(
		if not (mcPolyMap.isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local gco = modpanel.getcurrentobject()	
		local sel_center = gco.getSelCenter()
		local sel_faces = gco.getSelectedFaces()
		if sel_faces.numberset < 2 do return false
		local excluded_faces = #() --removed element faces
		undo "Align Elements" on
		(
			for i in sel_faces do
			(
				if findItem excluded_faces i  != 0 do continue
				--format "fcount:%\n" sel_faces.numberset
				gco.SelectFaces #{i}
				gco.selectElement()
				local fsel = gco.getSelectedFaces()
				local pos_x, pos_y, width, height
				local the_area = gco.getArea fsel &pos_x &pos_y &width &height &area_uvw &area_geom 
				--format "pos_x:%\t pos_y:%|n" pos_x pos_y
				local new_pos = case type of
				(
					#left:([-pos_x , 0, 0])
					#right:([1-pos_x-width, 0, 0])
					#top:([0 , 1-pos_y-height, 0])
					#bottom:([0 , -pos_y, 0])
					#center:(sel_center - (gco.getSelCenter()))
				)
				gco.MoveSelected new_pos
				excluded_faces += gco.getSelectedFaces()
			)
			gco.SelectFaces sel_faces
		)
	)
	
	fn randomizeElements axis = ( --works OK
		
		local gco = modpanel.getcurrentobject()
		local sel_faces = gco.getSelectedFaces()
		local excluded_faces = #()
		undo "Shift Uv Elements" on for i in sel_faces do
		(
			if findItem excluded_faces i  != 0 do continue
			--format "fcount:%\n" sel_faces.numberset
			gco.SelectFaces #{i}
			gco.selectElement()
			local element_pos = gco.getPivotOffset()
			local random_val = (
				if keyboard.controlPressed then ( --offset + or -
				
					if mcMath.randomBoolean() then spn_randomize.value else -spn_randomize.value
					
				) else (
				
					random 0.1 spn_randomize.value
				)
			)
			case axis of (
				
				#X:element_pos.x += random_val
				#Y:element_pos.y += random_val
			)
			gco.MoveSelected (element_pos)
			excluded_faces += gco.getSelectedFaces()
		)
		gco.SelectFaces sel_faces
		print "Shift Uv Elements > Done!"
	)
	
	fn alignElements way = ( --works ok
		
		local gco = modpanel.getcurrentobject()	
		local sel_faces = gco.getSelectedFaces()
		local excluded_faces = #()
		undo "Align Elements V-H" on for i in sel_faces do (
			
			if findItem excluded_faces i  != 0 do continue
			gco.SelectFaces #{i}
			gco.selectElement()
			local fsel = gco.getSelectedFaces()
			local pos_x, pos_y, width, height
			local the_area = gco.getArea fsel &pos_x &pos_y &width &height &area_uvw &area_geom 
			case way of (
			
				#vertical: if width > height do gco.rotateSelectedCenter (degToRad  90)
				#horizontal: if width < height do gco.rotateSelectedCenter (degToRad  90)
			)
			excluded_faces += fsel
		)
		print "Align Elements > Done!"
	)
	
	fn getEdgePos edge_index = (
	
		local gco = modpanel.getcurrentobject()
		gco.SelectEdges #{edge_index}
		gco.edgeToVertSelect() 	
		local vsel = (gco.getSelectedVertices()) as Array
		local p1 = gco.getVertexPosition 0 vsel[1]
		local p2 = gco.getVertexPosition 0 vsel[2]
		(p1 + p2) / 2
	)
	
	fn getEdgeByPos pos = (
		
		local gco = modpanel.getcurrentobject()
		local all_vertices = #{1..(gco.NumberVertices())} 
		gco.selectVertices all_vertices
		gco.vertToEdgeSelect()
		all_edges = gco.getSelectedEdges()		
		with redraw off for i in all_edges do (
			
			local edge_pos = getEdgePos i
			if edge_pos ==  pos do return i
		)
		return -1
	)
	
	fn stitchSelectedEdges = (
		
		--stitching cause reindex edges, then wee ned to > 
		--wee need to save edge selection as points of center position
		--after wee need to pick up each edge by position
		--edges will change scale while using gco.stitchVertsNoParams() 
		--thiss may cause missing conections 
		--to keep edge position same , disable scale cluster >  gco.stitchVerts true 0.0
		local gco = modpanel.getcurrentobject()	
		local sel_edges = gco.getSelectedEdges()
		format "stored selected edges:%\n" sel_edges
		local edges_pos = for i in sel_edges collect getEdgePos i
		undo "Stitch Selected Edges" on for p in edges_pos do ( --for each stored edge position
			
			local edge_index = getEdgeByPos p
			if edge_index == -1 then format "skip edge:%\n" edge_index else (
				
				format "stitch edge:%\n" edge_index
				gco.stitchVerts true  0.0 -- 0.0 disable stretch picked edge
				--gco.stitchVertsNoParams()
			)
		)
		messageBox "Stitching was Finnished." title:micra.version
	)	
	
	fn rotateVertices way = (
		
		local gco = modpanel.getcurrentobject()
		local sel_verts = mcPolyMap.getCurentSelectionAs gco #verts --this procedure also define gco and select vertices
		if sel_verts.count == 0 do return false
		local vertices_pos = for i in sel_verts collect (gco.getVertexPosition 0 i)
		format "A verts:%\n" vertices_pos
		mcArray.rotateItems vertices_pos 1 way:way
		format "B verts:%\n" vertices_pos
		undo "Reform" on for i=1 to sel_verts.count do (
			
			local vert_index =  sel_verts[i]
			--gco.selectVertices (#(vert_index) as BitArray)
			--gco.moveSelectedVertices vertices_pos[i]
			gco.setVertexPosition 0 vert_index vertices_pos[i]
		)
	)
	
	fn skewSelectedVertices cv = (
	
		local gco = modpanel.getcurrentobject()
		if not (mcPolyMap.isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local sel_verts = mcPolyMap.getCurentSelectionAs gco #verts
		local step = spn_skev_angle.value
		--local snap_state = mcSnap.getAngleSnapState()
		--if snap_state do mcSnap.setAngleSnapState false	--disable angle snap for avoid max rotation steps
		case cv of (
			
			#plus	: 	mcPolyMap.skewVerticesUvs gco sel_verts -step
			#minus	: 	mcPolyMap.skewVerticesUvs gco sel_verts step
		)
		--if snap_state do mcSnap.setAngleSnapState true
	)
	
	fn copyVertexPos = (
		
		local mod_uvw = modpanel.getcurrentobject()
		local sel_verts = mcPolyMap.getCurentSelectionAs mod_uvw #verts --this procedure also define gco and select vertices
		if sel_verts.count == 0 do return false
		vertex_position = mod_uvw.getVertexPosition 0 sel_verts[1]
	)
	
	fn pastePos way = (
-- 	format "vpos:%\n" vertex_position
		if vertex_position == undefined do return false
		local mod_uvw = modpanel.getcurrentobject()
		local sel_verts = mcPolyMap.getCurentSelectionAs mod_uvw #verts --this procedure also define gco and select vertices
		if sel_verts.count == 0 do return false
		local mod_uvw = modpanel.getcurrentobject()	
		undo "Paste UVW Position" on for i in sel_verts do (
			
			local p = mod_uvw.getVertexPosition 0 i
			if way == #X then p.x = vertex_position.x else p.y = vertex_position.y
			mod_uvw.setVertexPosition 0 i p
		)
	)
	fn distributeElementsToX obj gap:1 = (
		
		---TODO sort elements by geometry position
		---<void><Unwrap_UVW>.getAreaByNode <bitArray>faceSelection <&float>x <&float>y <&float>width <&float>height <node>node
		
		if subobjectLevel != 3 or obj == undefined do return false
		local mod_uvw = obj.modifiers[1]
		if classOf mod_uvw != Unwrap_UVW do return (mcMsgList.warn "not_unwrap") 
		local fsel = mod_uvw.getSelectedFaces()
		if fsel.numberset == 0 do return (mcMsgList.warn "not_fsel")
		local uv_faces = mcPolyMap.getCurentSelectionAs mod_uvw #faces
		local uv_faces_elements = mcPolyMap.getElements mod_uvw uv_faces
		--print uv_faces_elements
		--for el in uv_faces_elements do format "el left:%\n" el.bbox.le
		--sort by left value
		mcArray.sortByParam uv_faces_elements "left"
	-- 	for el in uv_faces_elements do format "el left:%\n" el.bbox.le
		--move elements by offset from first element in to right
		local next_bound = 0
		for el in uv_faces_elements do (

			if next_bound > 0 do el.moveTo [next_bound, 0, 0] axis:"x" --move element to x bound
			next_bound = el.right + gap --get right bound
			--format "next bound:%\n" next_bound
		)
	)
	fn fitUVS = (

		local mod_uvw = modpanel.getcurrentobject()
		if classOf  mod_uvw!= Unwrap_UVW do return false
		local sel_verts = mcPolyMap.getCurentSelectionAs mod_uvw #verts --this procedure also define gco and select vertices
		if keyboard.controlPressed then undo "Resize_UVW"  on (
			
			mcPolyMap.fitToSquareProportionally mod_uvw sel_verts move_zero:true
			
		) else undo  "Resize_UVW"  on (

			mcPolyMap.fitToSquare mod_uvw sel_verts
		)
	)
	fn selectRandomElements percent = (
	
		local mod_uvw = modpanel.getcurrentobject()
		if classOf  mod_uvw!= Unwrap_UVW do return false	
		if subObjectLevel != 3 do (messageBox "Works only in UV Faces." title:"Warning"; return false)
		local sel_faces = mod_uvw.getSelectedFaces()
		max select all
		local visible_faces = mod_uvw.getSelectedFaces()
		local percentage = spn_sel_random.value
		local sel_count = (percentage / 100.0) * visible_faces.numberset 
		--format "selectRandomElements > percentage:% select:%/% visible faces" percentage sel_count visible_faces.numberset 
		local faces_indexes = for f in visible_faces collect f
		mcArray.shuffle faces_indexes
		local faces_to_select = for i = 1 to sel_count collect faces_indexes[i]
		mod_uvw.selectFaces (faces_to_select as BitArray)
		
		-- mod_uvw.unwrap2.getDisplayHiddenEdges()
		-- mod_uvw.unwrap3.setDisplayHiddenEdges false
		-- mod_uvw.unhideAllPolygons() 
		-- <void><Unwrap_UVW>.hide() 
		-- <void><Unwrap_UVW>.unhide() 
		
		--get all faces
		/*local all_vertices = #{1..(mod_uvw.NumberVertices())} 
		mod_uvw.selectVertices all_vertices
		mod_uvw.vertToFaceSelect()
		local all_faces = mod_uvw.getSelectedFaces()*/

	)
	/*
		not works because of edges reindexing
		undo "Stitch Selected Edges" on for i in sel_edges do (
			gco.SelectEdges #{i}
			format "edge:%\n" i
			gco.stitchVertsNoParams() 
		)
		gco.SelectEdges sel_edges

	--another way is pick real geometry edges and find each in uvw
	fn stitchSelectedEdges = (
		
		gco = modpanel.getcurrentobject()	
		--#{203..204, 206, 217}
		local sel_edges_geo = gco.getSelectedGeomEdges()  --convert the UV edges to Geo Edges BitArray
		undo "Stitch Selected Edges" on for geo_edge_index in sel_edges_geo as Array do (
		--	gco.setSelectedGeomEdges #{}
		--	gco.setSelectedGeomEdges #{170}
			gco.SelectEdges sel_edges_geo
			local uv_edge_index 
			gco.SelectEdges #{uv_edge_index}
			format "edge:%\n" i
			gco.stitchVertsNoParams() 
		)
	)*/
	--<
	
	-->Actions
	on btn_verts pressed do mcPolyMap.convetrSelectionTo (modpanel.getcurrentobject()) #verts
	on btn_edges pressed do mcPolyMap.convetrSelectionTo (modpanel.getcurrentobject()) #edges
	on btn_faces pressed do mcPolyMap.convetrSelectionTo (modpanel.getcurrentobject()) #faces
	on btn_sel_similar pressed do selectUVWElementsBySize min_treeshold:spn_min.value max_treeshold:spn_max.value
	on btn_sel_over pressed do selectOverlapped()
	on btn_border pressed do (undo "Select Border" on mcPolyMap.selectBorder())
	on btn_move_r pressed do (offsetResizeSelection #right)
	on btn_move_l pressed  do (offsetResizeSelection #left	)
	on btn_move_u pressed do (offsetResizeSelection #up	)
	on btn_move_d pressed do (offsetResizeSelection #down)
	on btn_move_c pressed do (offsetResizeSelection #center)
	on btn_align_l pressed do alignTo #left
	on btn_align_r pressed do alignTo #right
	on btn_align_t pressed do alignTo #top
	on btn_align_b pressed do alignTo #bottom
	on btn_align_c pressed do alignTo #center
	on btn_texel_density pressed do mcFile.fileInVersion "LS3D_Texel_Density" 
	on btn_randomize_x pressed do randomizeElements #X
	on btn_randomize_y pressed do randomizeElements #Y	
	on btn_rotate_v pressed do alignElements #vertical
	on btn_rotate_h pressed do alignElements #horizontal
	on btn_sel_random pressed do undo "Select Random UV Elements" on (selectRandomElements spn_sel_random.value)
	on btn_stitch pressed do stitchSelectedEdges()
	on btn_fit pressed do fitUVS()
	on btn_rotate_verts pressed do rotateVertices #right
	on btn_copy_pos pressed do copyVertexPos()
	on btn_paste_posx pressed do pastePos #X
	on btn_paste_posy pressed do pastePos #Y
	on button_skew_verts_plus pressed do (undo "Skew Vertices" on skewSelectedVertices #plus)
	on button_skew_verts_minus pressed do (undo "Skew Vertices" on skewSelectedVertices #minus)
	on btn_distr_x_plus pressed do undo "Distribute Shells To X Expand" on (distributeElementsToX selection[1] gap:1)
	on btn_distr_x_zero pressed do undo "Distribute Shells To X Contract" on (distributeElementsToX selection[1] gap:0)
	--on spn_skew_verts changed val do  (undo "Skew Vertices" on skewSelectedVertices val)
	--<
)

(
	local parentUVW = windows.getChildHWND 0 "Edit UVWs"
	if parentUVW != undefined then (
		
		createdialog mcUnwrapEditorDialog  parent:parentUVW[1]
	
	) else (
		createdialog mcUnwrapEditorDialog
	)
)


/*

	on btnUp pressed do ( F_moveUV [0,1,0] )
	on btnLeft pressed do ( F_moveUV [-1,0,0] )
	on btnRight pressed do ( F_moveUV [1,0,0] )
	on btnDown pressed do ( F_moveUV [0,-1,0] )
	on btnCenter pressed do ( F_moveUV "C" )
-- move uv's
fn F_moveUV movePos = (
	if selection.count == 1 do
	(
		obj = selection[1]
		if obj.modifiers.count > 0 do
		(
			if classof obj.modifiers[1] == Unwrap_UVW do
			(
				objMod = obj.modifiers[1]
				objMod.faceToVertSelect() 
				vArray = objMod.getSelectedVertices()
				for vVar in vArray do
				(
					if movePos == "C" do
					(
						local oldSub = subobjectlevel
						subobjectlevel = 3
						midPos = objMod.getSelCenter()
						print midPos
						movePos = [-(floor midPos.x), -(floor midPos.y), 0]
						subobjectlevel = oldSub
					)
					
					oldPos = objMod.getVertexPosition 0 vVar
					objMod.setVertexPosition 0 vVar (oldPos + movePos)
				)
			)
		)
	)
)
on btnScale12H pressed do ( F_scaleUV [2,1] true)
on btnScale12V pressed do ( F_scaleUV [1,2] true )
on btnScale2H pressed do ( F_scaleUV [2,1] false )
on btnScale2V pressed do ( F_scaleUV [1,2] false  )
fn F_scaleUV scaleFactor divideBool = (
	if selection.count == 1 do
	(
		obj = selection[1]
		if obj.modifiers.count > 0 do
		(
			if classof obj.modifiers[1] == Unwrap_UVW do
			(
				objMod = obj.modifiers[1]
				objMod.faceToVertSelect() 
				vArray = objMod.getSelectedVertices()
				for vVar in vArray do
				(
					updPos = objMod.getVertexPosition 0 vVar
					
					if divideBool then
					(
						updPos.x = updPos.x / scaleFactor.x
						updPos.y = updPos.y / scaleFactor.y
					)
					else
					(
						updPos.x = updPos.x * scaleFactor.x
						updPos.y = updPos.y * scaleFactor.y
					)
					
					objMod.setVertexPosition 0 vVar updPos
				)
			)
		)
	)
)
*/



/*
Render UVVW to textures
for i=1 to objects.count do
(
	select( objects[i] )
	m = objects[i].modifiers["Unwrap UVW"]
	if m!= undefined then
	(
		s = print objects[i].name
		m.renderUV ("uvmap_"+s+".png")
	)
)




fn uvToMesh node channel:1 scaleFactor:1.0 = 
(
	_mesh = snapshotasmesh node
	sc = point3 scaleFactor scaleFactor scaleFactor
	verts = for v=1 to meshop.getnummapverts _mesh channel collect (meshop.getmapvert _mesh channel v)*sc
	faces = for f=1 to meshop.getnummapfaces _mesh channel collect meshop.getmapface _mesh channel f
		
	mesh name:(node.name + "_uvmesh") vertices:verts faces:faces	
)


		local all_vertices = #{1..(gco.NumberVertices())} 
		gco.selectVertices all_vertices
		gco.vertToEdgeSelect()
		all_edges = gco.getSelectedEdges()		
		gco.vertToFaceSelect()
		all_faces = gco.getSelectedFaces()	



showinterfaces (Unwrap_UVW())
*/
