--------------------------------------------------------------------------------
/* mcLiveMeasure by Orien 2019 */
--------------------------------------------------------------------------------
Global mcLiveMeasure --need instance
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

struct mcLiveMeasure	(
	
	--variables
	_obj,
	_vert_a,
	_vert_b,
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
	)
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
rollout mcLiveMeasureDialog "Live Measure:" width:236 height:160 (
	
	local snap_vals = #("1", "5", "10", "50", "100")
	GroupBox grp1 "Active:" pos:[4,4] width:228 height:152
	listbox lbx_measures "" pos:[8,20] width:220 height:7
	radioButtons rdo_snap "Snap:" pos:[12,120] width:187 height:30 labels:snap_vals default:2 columns:5
	local all_measures = #()
	local checked_state = #center
	fn markSelectedMeasure index = (
	
		for i=1 to all_measures.count do all_measures[i].selected (if i == index then true else false)	
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
	fn addLineMeasureFromVerts obj verts = (
		
		local m = mcLiveMeasure obj verts[1] verts[2]
		--format "create measure m:% obj:% verts:%\n" m obj verts	
		m.externalCallback = updateListDataCallback
		m.start()
		append all_measures m
		lbx_measures.items = append lbx_measures.items	(m.toString())
		lbx_measures.selection	= lbx_measures.items.count	
		markSelectedMeasure lbx_measures.selection
	)
	fn addTripodMeasure = ( --when one vertex is selected (pick three edges)
		
		local obj = (selection as array )[1]
		if not mcLiveMeasureCollector.isValidObject obj do return false
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
	fn addPolygonShrouds obj face_index = (
		
		format "addPolygonShrouds obj:% face_index:%\n"  obj face_index 
		local face_verts = polyop.getFaceVerts obj face_index as Array
		local face_edges = #{}
		for vindex in face_verts do ( --grow edges

			join face_edges (polyop.getEdgesUsingVert obj vindex)
		)
		--collect only edges which both vertices is not part of face
		local measure_edges = for eindex in face_edges as Array where (
			
			local edge_verts = polyop.getEdgeVerts obj eindex
			--format "face_verts:% edge_verts:%\n" face_verts edge_verts
			findItem face_verts edge_verts[1] == 0 or findItem face_verts edge_verts[2] == 0 
				
		) collect eindex
		--format "measure_edges:%\n" measure_edges
		for eindex in measure_edges do addLineMeasureFromVerts obj (polyop.getEdgeVerts obj eindex)
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
		
		format "unregister all measures:%\n" all_measures
		for m in all_measures do m.stop() --unregister each measure
		all_measures = #() --clear data array
		lbx_measures.items = #() --clear measures list
		CompleteRedraw()
	)
	fn updateAllMeasures sel type = (
		
		removeAllMeasures() --first clear all last used measures
		case type of (
			
			#obj: (
				
				format "Objects selection changed to:%\n" sel
			)
			#subobj:(
			
				local obj = selection[1]
				if not mcLiveMeasureCollector.isValidObject obj do return false
				local subsel = mcLiveMeasureCollector.getSubobjectSelection obj
				format "Subobject selection changed to:%\n" subsel
				if subsel.numberset == 0 do ( --if subsel deleselected
				
					return OK
				)
				case subobjectlevel of (
					
					1: undefined
					2: undefined
					3: undefined
					4: if subsel.numberset == 1 do addPolygonShrouds obj (subsel as Array)[1] --only one face at time can be interactive
					5: undefined
				)
			)
		)
	)
	fn unload = (
		
		removeAllMeasures() --remove and unregister all measures
		mcLiveMeasureCallbacks = undefined --unregister selection change callbacks
		gc()-- light:true
	)
	--objects selection has changed
	fn selectionChanged ev nd = (updateAllMeasures (selection as Array) #obj)
	--geometry selection has changed 
	fn subobjectSelectionChanged ev nd = (updateAllMeasures  (selection as Array)  #subobj)
	--geometry has changed (vertex, edge, face has been moved)
	fn geometryChanged ev nd = (
	
		if mcLiveMeasureCollector.in_progress < 1 do ( --prevent endless loop
			
			local snap_step = execute snap_vals[rdo_snap.state]
			--undo "Live Modeling Snap" on 
			mcLiveMeasureCollector.snapSelectedGeometry selection[1] all_measures snap_step:snap_step
		)
		mcLiveMeasureCollector.in_progress += 1
		--after 2x passes event will restart (prevent endless loop)
		if mcLiveMeasureCollector.in_progress > 1 do mcLiveMeasureCollector.in_progress = 0
	)
	fn nodeDeleted ev nd = (
		
		format "nodeDeleted >  Event:%, Nodes:%\n" ev nd 
		unload()
	)
	fn cbBegin ev nd = (
		
		--format "cb begin:%\n" mcLiveMeasureCollector.in_progress
	)
	fn cbEnd ev nd = (
		
		--format "cb end:%\n" mcLiveMeasureCollector.in_progress
	)
	fn init = (
		--register callbacks
		mcLiveMeasureCallbacks = NodeEventCallback mouseUp:true delay:1000 \
		selectionChanged:selectionChanged \
		subobjectSelectionChanged:subobjectSelectionChanged \
		deleted:nodeDeleted \
		geometryChanged:geometryChanged \
		callbackBegin: cbBegin \
		callbackEnd: cbEnd
		
		selectionChanged undefined undefined
		subobjectSelectionChanged undefined undefined
	)
	on lbx_measures selected index do markSelectedMeasure index--lbx_measures.selected = name
	on lbx_measures doubleClicked itm do ()
	on mcLiveMeasureDialog open do Init()
	on mcLiveMeasureDialog close do unload()
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
