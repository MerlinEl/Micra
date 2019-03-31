--------------------------------------------------------------------------------
/* mcLiveMeasureDraw by Orien 2019 */
--------------------------------------------------------------------------------
Global mcLiveMeasureDraw --need instance
Global mcLiveMeasureActions
Global mcLiveMeasureCollector
Global mcLiveMeasureDialog
Global mcLiveMeasureCallbacks
/*
*@Used Structures
	mcStructMan
	mcMath
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MC_LIVE_MEASURE_COLLECTOR (
	
	in_progress = 0,
	fn isValidObject obj = (isValidNode obj and classOf obj == Editable_Poly),
	fn getSubobjectSelection obj = (
		
		if not isValidObject obj do return #{}
		case subobjectlevel of (
			
			0: #{}
			1: obj.getSelection #Vertex
			2: obj.getSelection #Edge
			3: obj.getSelection #Edge
			4: obj.getSelection #Face
			5: obj.getSelection #Face
			default:#{}
		)
	),
	--get measure vector pionting to selected face
	fn getVectorPointToFace active_measure face_index = (
	
		local obj = active_measure._obj
		local vert_a = active_measure._vert_a
		local vert_b = active_measure._vert_b
		local p1 = polyop.getVert obj vert_a
		local p2 = polyop.getVert obj vert_b
		local face_verts = polyop.getFaceVerts obj face_index as Array
		local found_a = findItem face_verts vert_a != 0
		local found_b = findItem face_verts vert_b != 0
		if found_a and found_b then (
			
			undefined
			
		)else if found_a then (
			
			normalize (p1 - p2)
			
		) else if found_b then (
		
			normalize (p2 - p1)	
			
		) else ( --neighbour face vertices not found
			
			undefined
		)
	),	
	fn getVectorPointToEdge active_measure edge_index = (
	
		local obj = active_measure._obj
		local vert_a = active_measure._vert_a
		local vert_b = active_measure._vert_b
		local p1 = polyop.getVert obj vert_a
		local p2 = polyop.getVert obj vert_b
		local edge_verts = polyop.getEdgeVerts obj edge_index as Array
		local found_a = findItem edge_verts vert_a != 0
		local found_b = findItem edge_verts vert_b != 0
		if found_a and found_b then (
			
			undefined
			
		)else if found_a then (
			
			normalize (p1 - p2)
			
		) else if found_b then (
		
			normalize (p2 - p1)	
			
		) else ( --neighbour face vertices not found
			
			undefined
		)
	),	
	fn getVectorPointToVertex active_measure vertex_index = (
	
		local obj = active_measure._obj
		local vert_a = active_measure._vert_a
		local vert_b = active_measure._vert_b
		local p1 = polyop.getVert obj vert_a
		local p2 = polyop.getVert obj vert_b
		local found_a = vertex_index == vert_a
		local found_b = vertex_index == vert_b
		if found_a and found_b then (
			
			undefined
			
		)else if found_a then (
			
			normalize (p1 - p2)
			
		) else if found_b then (
		
			normalize (p2 - p1)	
			
		) else ( --neighbour face vertices not found
			
			undefined
		)
	),
	fn moveFaceAlongVector active_measure face_index snap_step = (
		
		local vect = getVectorPointToFace active_measure face_index
		if vect == undefined do return false 
		local obj = active_measure._obj
		--local p2 = polyop.getVert obj active_measure._vert_b
		local len = active_measure.getDist()
		local len_round = mcMath.roundIntLimited len step:snap_step
		local face_verts = polyop.getFaceVerts obj face_index as Array
		for vert in face_verts do (
		
			local p_end = polyop.getVert obj vert --vector end
			local p_start = (p_end - (vect*len)) --vector start 
			local dir = normalize (p_end	- p_start)
			--local p_end = point pos:p_end wirecolor:green
			--local p_start = point pos: p_start wirecolor:red
			local new_pos = dir*len_round
			polyop.setVert obj vert (p_start+new_pos)	
		)
	),
	fn moveEdgeAlongVector active_measure edge_index snap_step = (
		
		local vect = getVectorPointToEdge active_measure edge_index
		if vect == undefined do return false 
		local obj = active_measure._obj	
		local len = active_measure.getDist()
		local len_round = mcMath.roundIntLimited len step:snap_step
		local edge_verts = polyop.getVertsUsingEdge obj edge_index as Array	
		for vert in edge_verts do (
		
			local p_end = polyop.getVert obj vert --vector end
			local p_start = (p_end - (vect*len)) --vector start 
			local dir = normalize (p_end	- p_start)
			local new_pos = dir*len_round
			polyop.setVert obj vert (p_start+new_pos)	
		)
	),
	fn moveVertexAlongVector active_measure vertex_index snap_step = (
		
		local vect = getVectorPointToVertex active_measure vertex_index
		if vect == undefined do return false 
		local obj = active_measure._obj	
		local len = active_measure.getDist()
		local len_round = mcMath.roundIntLimited len step:snap_step
		local p_end = polyop.getVert obj vertex_index --vector end
		local p_start = (p_end - (vect*len)) --vector start 
		local dir = normalize (p_end	- p_start)
		local new_pos = dir*len_round
		polyop.setVert obj vertex_index (p_start+new_pos)	
	),
	fn snapSelectedGeometry active_measure snap_step:1 = (
		
		local obj = active_measure._obj
		--format "geometryChanged:%\n" obj.name	
		local subsel = (getSubobjectSelection obj) as Array --get selected face
		if subsel.count == 0 do return undefined 
		case subobjectlevel of (
					
			1: moveVertexAlongVector active_measure subsel[1] snap_step
			2: moveEdgeAlongVector active_measure subsel[1] snap_step
			3: undefined
			4: moveFaceAlongVector active_measure subsel[1] snap_step
			5: undefined
		)
	)	
)
mcLiveMeasureCollector = MC_LIVE_MEASURE_COLLECTOR()

struct mcLiveMeasureDraw	(
	
	--variables
	_obj,
	_vert_a,
	_vert_b,
	_selected = false,
	debug = false,
	id = mcDate.getUniqueId(),
	externalCallback,
	line_collor = green,
	color_index =6, --get text and bg color from array
	rect_colors = #(
		
		mcColor.hexToRGB #fff38d, 
		mcColor.hexToRGB #f2a808,
		mcColor.hexToRGB #e340e0,
		mcColor.hexToRGB #40c1e3,
		mcColor.hexToRGB #09d9da,
		mcColor.hexToRGB #2edd88
	),
	text_colors = #(
		
		mcColor.hexToRGB #a48e2e, 
		mcColor.hexToRGB #9f5103,
		mcColor.hexToRGB #981a94,
		mcColor.hexToRGB #1f8a9d,
		mcColor.hexToRGB #008379,
		mcColor.hexToRGB #1e8c45
	),
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn isValidComponents = (
		
		if not isValidNode _obj or classOf _obj != Editable_Poly do return false
		if not _obj.isSelected do return false 
		if _vert_a == undefined or _vert_b == undefined do return false 
		if _vert_a > _obj.numverts or _vert_b > _obj.numverts do return false 
		true
	),
	fn placeAlongVector pos vec offset =
	(
		pos + (normalize (vec)) * offset
	),
	function calculateLookatMatrix orientation origin target up:[0,0,1] =
	(
	  local lookatmatrix = matrix3 1
	  lookatmatrix.row1 = normalize(target-origin)
	  lookatmatrix.row2 = normalize (cross up lookatmatrix.row1)
	  lookatmatrix.row3 = normalize (cross lookatmatrix.row1 lookatmatrix.row2)
	  lookatmatrix.row4 = origin
	  orientation * lookatmatrix
		lookatmatrix
	),
	fn drawMeasure = (

		if not isValidComponents() do return false --skip render
		local p1 = polyop.getVert _obj _vert_a
		local p2 = polyop.getVert _obj _vert_b
		if classOf p1 != Point3 or classOf p2 != Point3 do return false 
		local dist = mcMath.roundFloat (distance p1 p2) pre:0.001
		local mid_pos = (p1 + p2)/2
		gw.setTransform(Matrix3 1)	
		if _selected do ( --draw Measure only if is selected
			
			gw.Marker p1 #diamond color:line_collor --selected measure line have two markers
			gw.Marker p2 #diamond color:line_collor		
			gw.setColor #line line_collor
			gw.polyline #(p1, p2) false --close shape true - false
			----------------------------------
			-- draw line thickness -- (cylinder)
			---------------------------------
			--create circles around p1 and p2
			local radius = if debug then 5 else 0.1 --circle radius
			local points_1 = mcMath.rotatePointAroundCenter p1 (normalize (p1 - p2) ) radius steps:6 debug:debug
			local points_2 = mcMath.rotatePointAroundCenter p2 (normalize (p2 - p1) ) radius steps:6 inverse:true debug:debug clr:red
			for i=1 to points_1.count do gw.polyline #(points_1[i], points_2[i]) false --connect circle points
		)
		--draw rectangle with text(line length)
		local rect_text = dist as String + " " + mcSystem.unitsType()
		local text_size = gw.getTextExtent rect_text
		local pos2d = gw.wTransPoint (mid_pos)
		local box_rect = (box2 (pos2d.x-3) (pos2d.y-text_size.y-5) (text_size.x+8) (text_size.y+6)) --(box2 x y width height )
		gw.wrect box_rect rect_colors[color_index] 
		gw.wtext pos2d rect_text color:text_colors[color_index] 
		--draw rect border
		gw.setColor #line yellow	
		gw.wpolyline #(
			[box_rect.left, box_rect.top, 0], 
			[box_rect.right, box_rect.top, 0], 
			[box_rect.right, box_rect.bottom, 0], 
			[box_rect.left, box_rect.bottom, 0]
		) true --close shape true - false			
			
		
		--Think about recalculate size of UPDATE rect ...
		/*
		gw.getTextExtent < string > --get text size?
		local rect = (box2 13 47 96 97)
		gw.wrect rect red
		eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
		eRect.right += 1
		eRect.bottom += 1
		gw.enlargeUpdateRect eRect
		*/

		gw.enlargeUpdateRect #whole
		gw.updateScreen()
		if externalCallback != undefined do externalCallback()
	),
	fn getSelVertices = (
		
		local vsel = _obj.getSelection #Vertex as Array
		if vsel.count != 2 do return false
		_vert_a = vsel[1]
		_vert_b = vsel[2]
	),
	fn getSelEdgeVertices = (
		
		local esel = _obj.getSelection #Edge as Array
		if esel.count != 1 do return false
		local vsel = polyop.getEdgeVerts	_obj esel[1] as Array	
		_vert_a = vsel[1]
		_vert_b = vsel[2]
	),
	fn getDist = (
		
		if isValidComponents() then (
			
			local p1 = polyop.getVert _obj _vert_a
			local p2 = polyop.getVert _obj _vert_b
			mcMath.roundFloat (distance p1 p2) pre:0.001
			
		) else (
			
			undefined
		)
	),
	fn isIdentical m = (
	
		_obj.name == m._obj.name and _vert_a == m._vert_a and _vert_b == m._vert_b	
	),
	fn toString = (

		"Measure:[" + _vert_a as String + ", " + _vert_b as String + "] len:" + (getDist()) as String + " " + mcSystem.unitsType()
	),
	fn selected state = (_selected = state),
	fn start = (
	
		unRegisterRedrawViewsCallback drawMeasure --simple prevent double run
		registerRedrawViewsCallback drawMeasure
	),
	fn stop = (
		--format "unregister measure\n"
		unRegisterRedrawViewsCallback drawMeasure
	),	
	fn onCreate = ( 
		
		local obj = (selection as array )[1]
		if obj == undefined or classOf obj != Editable_Poly do return false
		_obj = obj
		case subobjectlevel of (
			
			1: getSelVertices()
			2: getSelEdgeVertices()
			3: undefined
			4: undefined
			5: undefined
		)
	),
	init = onCreate()
	/*<end>*/
)	
struct mcLiveMeasureActions (
	
	fn setEdgeLength lm val way = ( --way == #ab, #ba, #center
			
			if not lm.isValidComponents() do return false
			local obj = lm._obj
			local vert_a = lm._vert_a
			local vert_b = lm._vert_b
			local p1 = polyop.getVert obj vert_a
			local p2 = polyop.getVert obj vert_b
			case way of (
				
				#ab		: (
					
					local nba = normalize (p2 - p1) --normalize vector P1 ------> P2
					polyop.setVert obj vert_b (p1+(nba*val))
				)
				#ba		: (
					
					local nab = normalize (p1 - p2) --normalize vector P1 <------ P2
					polyop.setVert obj vert_a (p2+(nab*val))
				)
				#center:(
		
					local center = (p1 + p2) / 2 -- P1<---- C ---->P2
					local nab = normalize (p1 - center) --normalize vector P1 <------ C
					local nba = normalize (p2 - center) --normalize vector C ------> P2
					polyop.setVert obj vert_a (center+(nab*(val/2)))
					polyop.setVert obj vert_b (center+(nba*(val/2)))
				)
		)
	)	
)
	
if mcLiveMeasureDialog != undefined do DestroyDialog mcLiveMeasureDialog
rollout mcLiveMeasureDialog "Live Measure:" width:236 height:244
(
	local snap_vals = #("1", "5", "10", "50", "100")
	local all_measures = #()
	local active_measure = undefined
	local checked_state = #center
	
	GroupBox grp1 "Active:" pos:[4,4] width:228 height:236
	listbox lbx_measures "" pos:[8,20] width:220 height:7
	button btn_add_lines "Add Line(s)" pos:[8,120] width:108 height:24
	button btn_add_tripod "Add Tripod" pos:[120,120] width:108 height:24
	button btn_delete "Delete" pos:[8,148] width:108 height:24
	button btn_delete_all "Delete All" pos:[120,148] width:108 height:24
	--spinner spn_edge_length "" pos:[88,180] width:76 height:16 range:[0,1000000,0.001] scale:0.001
	--button btn_set_length "Set Length" pos:[8,176] width:76 height:24
	--checkbutton btn_up "?" pos:[172,176] width:16 height:24
	--checkbutton btn_down "?" pos:[192,176] width:16 height:24
	--checkbutton btn_center "¤" pos:[212,176] width:16 height:24 checked:true
	checkbox chk_snap "" pos:[8,204] width:16 height:16 checked:true
	radioButtons rdo_snap "Snap:" pos:[26,204] width:187 height:30 labels:snap_vals default:3 columns:5
	
	fn markSelectedMeasure index = (
	
		--selected measure change color to Selected
		--all other measures change color to Unselected
		for i=1 to all_measures.count do (
			
			local m = all_measures[i]
			m.selected (if i == index then true else false)	
		)
		active_measure = all_measures[index] --set selected measure as current
		--spn_edge_length.value = active_measure.getDist()
		CompleteRedraw()
	)
	fn updateListDataCallback  = ( --fill all list data each time when any measure scale is changed
		
		if all_measures.count == 0 do return false
		local updated_items = #()
		for m in all_measures do (
		
			updated_items  = append updated_items (m.toString())
		)
		--condition if something is changed then update list
		if not mcArray.isEqualArrays lbx_measures.items updated_items do (
			
			lbx_measures.items = updated_items	
		)
	)
	fn isMeasureExists src_m = (
		
		if all_measures.count == 0 do return false	
		for m in all_measures do (	
			
			if src_m.isIdentical m do return true
		)
		false
	)
	fn addLineMeasure = (
	
		local m = mcLiveMeasureDraw()
		if not m.isValidComponents() do return false
		if isMeasureExists m do (
			
			--format "mcLiveMeasureDialog > Skipped Measure [ %, % ] already exists.\n" m._vert_a m._vert_b
			return false
		)
		m.externalCallback = updateListDataCallback
		m.start()
		append all_measures m
		lbx_measures.items = append lbx_measures.items	(m.toString())
		lbx_measures.selection	= lbx_measures.items.count	
		markSelectedMeasure lbx_measures.selection	
	)
	fn addLineMeasures = (
			
		local obj = (selection as array )[1]
		if subobjectlevel != 2 or obj == undefined or classOf obj != Editable_Poly do return false
		local esel = obj.getSelection #Edge as Array	
		for eindex in esel do (
			
			polyop.setEdgeSelection obj eindex
			addLineMeasure()
		)
	)
	fn addTripodMeasure = ( --when one vertex is selected (pick three edges)
		
		local obj = (selection as array )[1]
		if subobjectlevel != 1 or obj == undefined or classOf obj != Editable_Poly do return false
		local vsel = obj.getSelection #Vertex as Array
		if vsel.count != 1 do return false	
		local esel = polyop.getEdgesUsingVert obj vsel[1] as Array
		if esel.count < 3 do return false	
		subobjectlevel = 2	
		for eindex in esel do (
			
			polyop.setEdgeSelection obj eindex
			addLineMeasure()
		)
		subobjectlevel = 1
	)
	fn removeMeasure = (
		
		if lbx_measures.items.count == 0 or lbx_measures.selection == 0 do return false
		--Unregister selected measure
		active_measure.stop()
		active_measure = undefined
		deleteItem all_measures lbx_measures.selection
		--Remove currently selected item from the list
		lbx_measures.items = deleteItem lbx_measures.items lbx_measures.selection
		CompleteRedraw()
	)
	fn checkButtonsSwitch btn state = (
		
		for b in #(btn_up, btn_down, btn_center) do b.checked =  b.name == btn.name  
		checked_state = case btn of (
			
			btn_up: #ab
			btn_down: #ba
			btn_center: #center
		)
	)
	/*fn setEdgeLength = (
	
		if lbx_measures.items.count == 0 or lbx_measures.selection == 0 do return false
		local m = all_measures[lbx_measures.selection]	
		undo "Set Edge Length" on mcLiveMeasureActions.setEdgeLength m spn_edge_length.value checked_state
	)*/
	/*fn updateAllMeasures sel type = (
		
		format "updateAllMeasures...\n"
		case type of (
			
			#obj: (
				
				format "Objects selection changed to:%\n" sel
			)
			#subobj:(
			
				if lbx_measures.items.count == 0 or lbx_measures.selection == 0 do return false
				local m = all_measures[lbx_measures.selection] --get selected measure
				local obj = m._obj
				local subsel = mcLiveMeasureCollector.getSubobjectSelection obj
				format "Subobject selection changed to:%\n" subsel
				if subsel.numberset == 0 do ( --if subsel deleselected
				
					return OK
				)
				case subobjectlevel of (
					
					1: undefined
					2: undefined
					3: undefined
					4: if subsel.numberset == 1 do (
						
						--local active_measure = all_measures[lbx_measures.selection] --pick current selected measure
						--addPolygonShrouds obj (subsel as Array)[1] --only one face at time can be interactive
					)
					5: undefined
				)
			)
		)
	)*/
	fn unregisterLiveSnap = (
		
		--format "unregisterLiveSnap\n"
		mcLiveMeasureCallbacks = undefined --unregister selection change callbacks
		gc()-- light:true
	)
	fn removeAllMeasures = (
		
		active_measure = undefined
		for m in all_measures do m.stop() --unregister each measure
		all_measures = #() --clear data array
		lbx_measures.items = #() --clear measures list
		--spn_edge_length.value = 0
		CompleteRedraw()
	)
	--objects selection has changed
	fn selectionChanged ev nd = (
		
		removeAllMeasures() --for now after selected different object then clear all measures
		--updateAllMeasures (selection as Array) #obj
	)
	--geometry selection has changed 
	--fn subobjectSelectionChanged ev nd = (updateAllMeasures  (selection as Array)  #subobj)
	--geometry has changed (vertex, edge, face has been moved)
	fn geometryChanged ev nd = (
	
		--if no measure selected or undo pressed
		if active_measure == undefined or keyboard.controlPressed do return OK
		if mcLiveMeasureCollector.in_progress < 1 do ( --prevent endless loop
			
			local snap_step = execute snap_vals[rdo_snap.state]
			undo "Live Modeling Snap" on (
				
				mcLiveMeasureCollector.snapSelectedGeometry active_measure snap_step:snap_step
			)
		)
		mcLiveMeasureCollector.in_progress += 1
		--after 2x passes event will restart (prevent endless loop)
		if mcLiveMeasureCollector.in_progress > 1 do mcLiveMeasureCollector.in_progress = 0
	)
	fn nodeDeleted ev nd = (
		
		format "mcLiveMeasureDialog > nodeDeleted >  Event:%, Nodes:%\n" ev nd 
		unregisterLiveSnap()
		removeAllMeasures()
	)
	fn cbBegin ev nd = (
		
		--format "cb begin:%\n" mcLiveMeasureCollector.in_progress
	)
	fn cbEnd ev nd = (
		
		--format "cb end:%\n" mcLiveMeasureCollector.in_progress
	)
	fn registerLiveSnap = (
		
		unregisterLiveSnap()
		--format "registerLiveSnap\n"
		--register callbacks
		mcLiveMeasureCallbacks = NodeEventCallback mouseUp:true delay:1000 \
		selectionChanged:selectionChanged \
		deleted:nodeDeleted \
		geometryChanged:geometryChanged \
		callbackBegin: cbBegin \
		callbackEnd: cbEnd
		
		--selectionChanged undefined undefined
		--subobjectSelectionChanged:subobjectSelectionChanged \
		--subobjectSelectionChanged undefined undefined
	)
	fn unload = (
		
		unregisterLiveSnap()
		removeAllMeasures()	
	)
	fn init = (
	
		if chk_snap.checked do registerLiveSnap()
	)
	on btn_add_lines pressed  do addLineMeasures()
	on btn_add_tripod pressed  do addTripodMeasure()
	on btn_delete pressed  do removeMeasure()
	on lbx_measures selected index do markSelectedMeasure index--lbx_measures.selected = name
	on lbx_measures doubleClicked itm do ()
	on btn_delete_all pressed do removeAllMeasures()
	--on btn_set_length pressed do setEdgeLength()
	on mcLiveMeasureDialog open do Init()
	on mcLiveMeasureDialog close do unload()
	on btn_up changed state do checkButtonsSwitch btn_up state
	on btn_down changed state do checkButtonsSwitch btn_down state
	on btn_center changed state do checkButtonsSwitch btn_center state
	on chk_snap changed state do if state then registerLiveSnap() else unregisterLiveSnap()
)
createDialog mcLiveMeasureDialog


/*
for a=0 to 360 by 90 do (
	
	--local v1 = (normalize (p1 - p2))*5 --vector length 2
	---local v1 = [0,1,0]*5 --vector length 2
	local v1 = normalize (p1 - p2)
	local rm = rotateZMatrix a --create a rotation matrix from the value
	local v1_rotated = v1 * rm --transform the original vector using the matrix
	gw.polyline #(p1, p1+v1_rotated) false --close shape true - false
)

You could set the colour of the line to the opposite of the viewport:
gw.setColor #line ((color 255 255 255) - (((GetUIColor 41) * 255) as color))


local p = obj.pos
for i = 0 to (360 - step) by step do (
-- make a point helper
-- define the current angle around the circle
local angle = i
-- calculate the X and Y coordinates of the point on the circle using the current angle
local x = cos(angle) * radius
local y = sin(angle) * radius
-- 1 = X axis
-- 2 = Y axis
-- 3 = Z axis
global p3 = case axis of (
1:[0,x,y]
2:[x,0,y]
3:[x,y,0]
)
-- using the coordinate system of the object, define the coordinates of the current point
newP = ( (matrix3 [1,0,0] [0,1,0] [0,0,1] p3) * (obj.transform) ).translationPart

on addToList pressed do
  testList.items = append testList.items ("Item "+ (testList.items.count+1) as string)
--Instert new item before current item
on insertToList pressed do
(
  --Check whether current item selection exists (greater than 0)
  if testList.selection > 0 do
  (
    --Because insertItem returns OK instead of the resulting array,
    --you cannot assign the result of the expression directly to the property.
    --Instead, you have to get a copy of the items array in a local variable...
    temp_array = testList.items
    --...perform the insertion with the temp. array in the local variable...
    insertItem ("Item "+ (testList.items.count+1) as string) temp_array testList.selection
    --...and assign back the temp. array to the .items property
    testList.items = temp_array
  )
)
--Remove currently selected item from the list:
on removeFromList pressed do
(
  --Check whether there are any items left and there is a valid selection.
  --Then delete the current item. DeleteItem returns the resulting array,
  --so you can assign the result directly to the .items property
  if testList.items.count > 0 and testList.selection > 0 do
    testList.items = deleteItem testList.items testList.selection
)
*/
