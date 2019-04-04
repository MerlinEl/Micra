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
	/*fn getDist = (
		
		local p1 = polyop.getVert _obj _vert_a
		local p2 = polyop.getVert _obj _vert_b
		mcMath.roundFloat (distance p1 p2) pre:0.001
	),*/
	fn snapSelectedGeometry obj measures snap_step:1 = (
	
		format "geometryChanged:%\n" obj.name	
		case subobjectlevel of (
					
			1: undefined
			2: undefined
			3: undefined
			4: (
				--get selected face
				local subsel = getSubobjectSelection obj
				local sel_faces = subsel as Array
				if sel_faces.count != 1 do return false
				local face_verts = polyop.getFaceVerts obj sel_faces[1]
				--get first measure length
				local len = mcMath.roundIntLimited (measures[1].getDist()) step:snap_step
				--round all face verts pos to cm, relative from shrouds
				for m in measures do (
					
					local p1 = polyop.getVert obj m._vert_a
					local p2 = polyop.getVert obj m._vert_b	
					if findItem face_verts m._vert_a != 0 then ( --only face vertex will be moved
						
						local n =  normalize (p1 - p2) --normalized vector p1 <---- p2
						local new_pos = n*len
						polyop.setVert obj m._vert_a (p2+new_pos)
						
					) else ( 
						
						local n =  normalize (p2 - p1) --normalized vector p1 ----> p2
						local new_pos = n*len
						polyop.setVert obj m._vert_b (p1+new_pos)
					)
				)
			)
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
	debug = false,
	id = mcDate.getUniqueId(),
	externalCallback,
	sel_color = green,
	unsel_color = gray,
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
	line_collor = sel_color,
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
		if line_collor == sel_color do ( --selected measure line have two markers
			
			gw.Marker p1 #diamond color:sel_color
			gw.Marker p2 #diamond color:sel_color
		)
		if classOf p1 != Point3 or classOf p2 != Point3 do return false 
		local dist = mcMath.roundFloat (distance p1 p2) pre:0.001
		local mid_pos = (p1 + p2)/2
		gw.setTransform(Matrix3 1)
		gw.setColor #line line_collor
		gw.polyline #(p1, p2) false --close shape true - false
		----------------------------------
		-- draw line thickness --
		---------------------------------
		--create matrix
		local len = if debug then 5 else 0.1
		local v1 = normalize (p1 - p2) --*_obj.transform
		local vz = [0,0,1] --yellow in gizmo
		local vx = normalize (cross vz v1)  --red in gizmo
		local vy = normalize ( cross vx v1 ) --green in gizmo
		--local tm = matrix3 vx vy vz [0,0,0]
		--	 					  	            o
		--	 						             |
		-- get cross points       o --- + --- o
		-- perpendicular 	to  v1        |
		--	 						            o
		local p1_a = p1+vx*len
		local p1_b = p1+vy*len
		local p1_c = p1-vx*len
		local p1_d = p1-vy*len
		local p2_a = p2+vx*len
		local p2_b = p2+vy*len
		local p2_c = p2-vx*len
		local p2_d = p2-vy*len
		if debug do (
			
			--draw perpendicular cross top on vector v1 end
			gw.polyline #(p1, p1_a) false
			gw.polyline #(p1, p1_b) false
			gw.polyline #(p1, p1_c) false
			gw.polyline #(p1, p1_d) false
			--draw perpendicular cross top on vector v1 begin	
			gw.polyline #(p2, p2_a) false
			gw.polyline #(p2, p2_b) false
			gw.polyline #(p2, p2_c) false
			gw.polyline #(p2, p2_d) false
		)
		--draw four paralel lines to achive thickness
		gw.polyline #(p1_a, p2_a) false	
		gw.polyline #(p1_b, p2_b) false	
		gw.polyline #(p1_c, p2_c) false	
		gw.polyline #(p1_d, p2_d) false	
	
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
	fn toString = (

		"Measure:[" + _vert_a as String + ", " + _vert_b as String + "] len:" + (getDist()) as String + " " + mcSystem.unitsType()
	),
	fn selected state = (
		
		line_collor = if state then sel_color else unsel_color
	),
	fn start = (
	
		unRegisterRedrawViewsCallback drawMeasure --simple prevent double run
		registerRedrawViewsCallback drawMeasure
	),
	fn stop = (
		format "unregister measure\n"
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
	GroupBox grp1 "Active:" pos:[4,4] width:228 height:236
	listbox lbx_measures "" pos:[8,20] width:220 height:7
	spinner spn_edge_length "" pos:[88,180] width:76 height:16 range:[0,1000000,0.001] scale:0.001
	button btn_add_line "Add Line" pos:[8,120] width:108 height:24
	button btn_add_tripod "Add Tripod" pos:[120,120] width:108 height:24
	button btn_delete "Delete" pos:[8,148] width:108 height:24
	button btn_delete_all "Delete All" pos:[120,148] width:108 height:24
	button btn_set_length "Set Length" pos:[8,176] width:76 height:24
	checkbutton btn_up "?" pos:[172,176] width:16 height:24
	checkbutton btn_down "?" pos:[192,176] width:16 height:24
	checkbutton btn_center "¤" pos:[212,176] width:16 height:24 checked:true
	checkbox chk_snap "" pos:[8,204] width:16 height:16 checked:true
	radioButtons rdo_snap_offset "Live Snapping:" pos:[26,204] width:187 height:30 labels:#("1", "5", "10", "50", "100") default:3 columns:5
	
	local all_measures = #()
	local checked_state = #center
	fn markSelectedMeasure index = (
	
		for i=1 to all_measures.count do all_measures[i].selected (if i == index then true else false)	
		CompleteRedraw()
		spn_edge_length.value = (all_measures[index]).getDist()
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
	fn addLineMeasure = (
	
		local m = mcLiveMeasureDraw()
		if not m.isValidComponents() do return false
		m.externalCallback = updateListDataCallback
		m.start()
		append all_measures m
		lbx_measures.items = append lbx_measures.items	(m.toString())
		lbx_measures.selection	= lbx_measures.items.count	
		markSelectedMeasure lbx_measures.selection	
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
		local m = all_measures[lbx_measures.selection]
		m.stop()
		deleteItem all_measures lbx_measures.selection
		--Remove currently selected item from the list
		lbx_measures.items = deleteItem lbx_measures.items lbx_measures.selection
		CompleteRedraw()
	)
	fn removeAllMeasures = (
		
		for m in all_measures do m.stop() --unregister each measure
		all_measures = #() --clear data array
		lbx_measures.items = #() --clear measures list
		spn_edge_length.value = 0
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
	fn setEdgeLength = (
	
		if lbx_measures.items.count == 0 or lbx_measures.selection == 0 do return false
		local m = all_measures[lbx_measures.selection]	
		undo "Set Edge Length" on mcLiveMeasureActions.setEdgeLength m spn_edge_length.value checked_state
	)
	fn init = (
		--register callbacks
		/*mcLiveMeasureCallbacks = NodeEventCallback mouseUp:true delay:1000 \
		selectionChanged:selectionChanged \
		subobjectSelectionChanged:subobjectSelectionChanged \
		deleted:nodeDeleted \
		geometryChanged:geometryChanged \
		callbackBegin: cbBegin \
		callbackEnd: cbEnd
		
		selectionChanged undefined undefined
		subobjectSelectionChanged undefined undefined*/
	)
	on btn_add_line pressed  do addLineMeasure()
	on btn_add_tripod pressed  do addTripodMeasure()
	on btn_delete pressed  do removeMeasure()
	on lbx_measures selected index do markSelectedMeasure index--lbx_measures.selected = name
	on lbx_measures doubleClicked itm do ()
	on btn_delete_all pressed do removeAllMeasures()
	on btn_set_length pressed do setEdgeLength()
	on mcLiveMeasureDialog open do Init()
	on mcLiveMeasureDialog close do removeAllMeasures()
	on btn_up changed state do checkButtonsSwitch btn_up state
	on btn_down changed state do checkButtonsSwitch btn_down state
	on btn_center changed state do checkButtonsSwitch btn_center state
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
