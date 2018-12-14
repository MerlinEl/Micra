--Aditional Functions for Unwrap Editor 2012

--Convert selection between subobject levels*
--Select edge border*
--Pack selection together in place*
--offset selection by one frame x y z*

try (destroyDialog mcUnwrapEditorDialog) catch ()

rollout mcUnwrapEditorDialog "UV+" width:96 height:456
(
	-->Locals
	local gco
	--<
	GroupBox grp6 "Selection" pos:[4,4] width:88 height:128
	button btn_verts "V" pos:[8,24] width:24 height:24 images:(mcCall.getIcon 103)  tooltip:"Convert Selection to Vertices"
	button btn_edges "E" pos:[36,24] width:24 height:24 images:(mcCall.getIcon 216) tooltip:"Convert Selection to Edges"
	button btn_faces "F" pos:[64,24] width:24 height:24 images:(mcCall.getIcon 40) tooltip:"Convert Selection to Faces"
	button btn_border "B" pos:[8,52] width:24 height:24 images:(mcCall.getIcon 41) tooltip:"Select Edge border"
	button btn_sel_similar "B" pos:[64,52] width:24 height:24 images:(mcCall.getIcon 220) tooltip:"Select Similar Faces"
	label lbl_min "min:" pos:[8,84] width:24 height:16
	spinner spn_min "" pos:[32,84] width:44 height:16 range:[0,100,100] type:#float
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
	button 'btn_lm' "p1" pos:[8,372] width:24 height:24 images:(mcCall.getIcon 116) toolTip:"Add Lightmap"
	button 'btn_randomize_x' "RandX" pos:[8,400] width:36 height:24 toolTip:"Move Elements Random X" align:#left
	button 'btn_randomize_y' "RandY" pos:[48,400] width:36 height:24 toolTip:"Move Elements Random Y" align:#left
	spinner 'spn_randomize' "" pos:[8,428] width:80 height:16 range:[0,100,0.5] align:#left

	--> Functions
	fn errorCheck = --if error found do return true
	(
		gco = modpanel.getcurrentobject()	
		if classOf gco != Unwrap_UVW do return true
		return false
	)
		
	fn convetrSelectionTo type =
	(
		if errorCheck() do return false
		local lvl = subobjectLevel
		case type of
		(	
			#verts:  
			(
				subobjectLevel = 1
				--if keyboard.controlPressed do
				(if lvl == 3 then gco.faceToVertSelect() else if lvl == 2 do gco.edgeToVertSelect())
			)
			#edges: 
			(
				subobjectLevel = 2
				--if keyboard.controlPressed do
				(if lvl == 3 then gco.faceToEdgeSelect() else if lvl == 1 do gco.vertToEdgeSelect())
			)
			#faces:  
			(
				subobjectLevel =3
				--if keyboard.controlPressed do
				(if lvl == 2 then gco.edgeToFaceSelect() else if lvl == 1 do gco.vertToFaceSelect())
			)
		)
	)
	fn selectBorder =
	(
		if errorCheck() do return false
		if subobjectLevel !=2 do return false
		gco.openEdgeSelect()
	)
	fn packInPlace = 
	(
		if errorCheck() do return false
		local sel_center = gco.getSelCenter()
		local sel_faces = gco.getSelectedFaces()
		if sel_faces.numberset < 2 do return false
		local excluded_faces = #()
		for i in sel_faces do
		(
			if findItem excluded_faces i  != 0 do continue
			format "fcount:%\n" sel_faces.numberset
			gco.SelectFaces #{i}
			gco.selectElement()
			gco.MoveSelected (sel_center - (gco.getSelCenter()) )
			excluded_faces += gco.getSelectedFaces()
		)
	)
	fn resizeUVW val axis =
	(
		if errorCheck() do return false
		local axis = case axis of
		(
			#x: 1 
			#y: 2
			#xy: 0
		)
		undo "Resize_UVW" on gco.scaleSelectedCenter val axis
	)
	fn offsetResizeSelection type =
	(
		if errorCheck() do return false
		case type of
		(	
			#right:   ( if keyboard.controlPressed then resizeUVW 2 #x else undo "Offset Right" on gco.MoveSelected [1,0,0])
			#left:     ( if keyboard.controlPressed then resizeUVW 0.5 #x else undo "Offset Left"  on gco.MoveSelected [-1,0,0])
			#up:      ( if keyboard.controlPressed then resizeUVW 2 #y else undo "Offset Up"    on gco.MoveSelected [0,1,0])
			#down:  ( if keyboard.controlPressed then resizeUVW 0.5 #y else undo "Offset Down" on gco.MoveSelected [0,-1,0])
			#center: 
			( 
				if keyboard.controlPressed then resizeUVW 2 #xy else
				if keyboard.altPressed       then resizeUVW 0.5 #xy else
				undo "Offset Center" on gco.MoveSelected (0.5 - (gco.getSelCenter() ) ) 
			)
		)
	)
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
	fn selectUVWElementsBySize min_treeshold:0.5 max_treeshold:0.5 =
	(
		if errorCheck() do return false
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
		local all_elements = getElements gco (all_faces as array)
		--filter only elements with treeshold
		local chosen_faces = #{}
		format "elements found:%\n" (all_elements.count+1)
		format "first element area:%\n" areaUVW
		
		local min_val = areaUVW - (areaUVW/100)*min_treeshold
		local max_val = areaUVW + (areaUVW/100)*max_treeshold
		
		format "min:%\tmax:%\n" min_val max_val 
		for a in all_elements where (a.area >= min_val ) and (a.area <= max_val) do --min max
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
		if errorCheck() do return false
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
		if errorCheck() do return false
		local sel_center = gco.getSelCenter()
		local sel_faces = gco.getSelectedFaces()
		if sel_faces.numberset < 2 do return false
		local excluded_faces = #() --always remove an element faces
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
	fn randomizeElements axis = (
		
		gco = modpanel.getcurrentobject()
		local sel_faces = gco.getSelectedFaces()
		local excluded_faces = #()
		undo "Shift Uv Elements" on for i in sel_faces do
		(
			if findItem excluded_faces i  != 0 do continue
			--format "fcount:%\n" sel_faces.numberset
			gco.SelectFaces #{i}
			gco.selectElement()
			local sel_center = gco.getSelCenter()
			case axis of (
				
				#X:sel_center.x += random 0.1 spn_randomize.value
				#Y:sel_center.y += random 0.1 spn_randomize.value
			)
			gco.MoveSelected (sel_center)
			excluded_faces += gco.getSelectedFaces()
		)
		print "Shift Uv Elements > Done!"
	)
	--<
	
	-->Actions
	on btn_verts pressed do convetrSelectionTo #verts
	on btn_edges pressed do convetrSelectionTo #edges
	on btn_faces pressed do convetrSelectionTo #faces
	on btn_sel_similar pressed do selectUVWElementsBySize min_treeshold:spn_min.value max_treeshold:spn_max.value
	on btn_sel_over pressed do selectOverlapped()
	on btn_border pressed do undo "Select Border" on selectBorder()
	on btn_move_r pressed do offsetResizeSelection #right
	on btn_move_l pressed  do offsetResizeSelection #left
	on btn_move_u pressed do offsetResizeSelection #up
	on btn_move_d pressed do offsetResizeSelection #down
	on btn_move_c pressed do offsetResizeSelection #center
	on btn_align_l pressed do alignTo #left
	on btn_align_r pressed do alignTo #right
	on btn_align_t pressed do alignTo #top
	on btn_align_b pressed do alignTo #bottom
	on btn_align_c pressed do alignTo #center
	on btn_lm pressed do undo "Add Lightmap" on mcAction.addLightMap 2
	on btn_randomize_x pressed do randomizeElements #X
	on btn_randomize_y pressed do randomizeElements #Y	
	--<
)
createDialog mcUnwrapEditorDialog


/*
showinterfaces (Unwrap_UVW())
*/