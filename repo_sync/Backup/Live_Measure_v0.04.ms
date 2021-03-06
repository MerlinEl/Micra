--------------------------------------------------------------------------------
/* mcLiveMeasure by Orien 2019 */
--------------------------------------------------------------------------------
Global mcLiveMeasure --need instance
Global mcLiveMeasureDialog
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
struct mcLiveMeasure	(
	
	--variables
	id = mcDate.getUniqueId(),
	externalCallback,
	sel_color = orange,
	unsel_color = green,
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
	_obj,
	_vert_a,
	_vert_b,
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn isValidComponents = (
		
		if not isValidNode _obj or classOf _obj != Editable_Poly do return false
		if not _obj.isSelected do return false 
		if _vert_a == undefined or _vert_b == undefined do return false 
		if _vert_a > _obj.numverts or _vert_b > _obj.numverts do return false 
		true
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
		
		local rect_text = dist as String + " " + mcSystem.unitsType()
		local text_size = gw.getTextExtent rect_text
		local pos2d = gw.wTransPoint (mid_pos)
		local box_rect = (box2 (pos2d.x-3) (pos2d.y-text_size.y-5) (text_size.x+8) (text_size.y+6)) --(box2 x y width height )
		gw.wrect box_rect rect_colors[color_index] 
		gw.wtext pos2d rect_text color:text_colors[color_index] 
		
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
	fn setEdgeLength val way = ( --way == #ab, #ba, #center
		
		if not isValidComponents() do return false
		local p1 = polyop.getVert _obj _vert_a
		local p2 = polyop.getVert _obj _vert_b
		case way of (
			
			#ab		: (
				
				local nba = normalize (p2 - p1) --normalize vector P1 ------> P2
				polyop.setVert _obj _vert_b (p1+(nba*val))
			)
			#ba		: (
				
				local nab = normalize (p1 - p2) --normalize vector P1 <------ P2
				polyop.setVert _obj _vert_a (p2+(nab*val))
			)
			#center:(
	
				local center = (p1 + p2) / 2 -- P1<---- C ---->P2
				local nab = normalize (p1 - center) --normalize vector P1 <------ C
				local nba = normalize (p2 - center) --normalize vector C ------> P2
				polyop.setVert _obj _vert_a (center+(nab*(val/2)))
				polyop.setVert _obj _vert_b (center+(nba*(val/2)))
			)
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

if mcLiveMeasureDialog != undefined do DestroyDialog mcLiveMeasureDialog
rollout mcLiveMeasureDialog "Live Measure:" width:236 height:208
(
	
	GroupBox grp1 "Active:" pos:[4,4] width:228 height:200
	listbox lbx_measures "" pos:[8,20] width:220 height:7
	spinner spn_edge_length "" pos:[88,180] width:76 height:16 range:[0, 1000000, 0.001] scale:0.001
	button btn_add_line "Add Line" pos:[8,120] width:108 height:24
	button btn_add_tripod "Add Tripod" pos:[120,120] width:108 height:24
	button btn_delete "Delete" pos:[8,148] width:108 height:24
	button btn_delete_all "Delete All" pos:[120,148] width:108 height:24
	button btn_set_length "Set Length" pos:[8,176] width:76 height:24
	checkButton btn_up "?" pos:[172,176] width:16 height:24
	checkButton btn_down "?" pos:[192,176] width:16 height:24
	checkButton btn_center "�" pos:[212,176] width:16 height:24 checked:true
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
	
		local m = mcLiveMeasure()
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
		if obj == undefined or classOf obj != Editable_Poly do return false
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
		undo "Set Edge Length" on m.setEdgeLength spn_edge_length.value checked_state
	)
	on btn_add_line pressed  do addLineMeasure()
	on btn_add_tripod pressed  do addTripodMeasure()
	on btn_delete pressed  do removeMeasure()
	on lbx_measures selected index do markSelectedMeasure index--lbx_measures.selected = name
	on lbx_measures doubleClicked itm do ()
	on btn_delete_all pressed do removeAllMeasures()
	on btn_set_length pressed do setEdgeLength()
	on mcLiveMeasureDialog close do removeAllMeasures()
	on btn_up changed state do checkButtonsSwitch btn_up state
	on btn_down changed state do checkButtonsSwitch btn_down state
	on btn_center changed state do checkButtonsSwitch btn_center state
)
createDialog mcLiveMeasureDialog


/*
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
