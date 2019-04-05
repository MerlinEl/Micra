--TODO > Bind measure to vertices. When object changes then measure changes too (edge or teo vertices)

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
	mode = #line, --#tripod
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
		
		if classOf p1 != Point3 or classOf p2 != Point3 do return false 
		local dist = mcMath.roundFloat (distance p1 p2) pre:0.001
		local mid_pos = (p1 + p2)/2
		gw.setTransform(Matrix3 1)
		gw.setColor #line green 
		gw.polyline #(p1, p2) false --close shape true - false
		gw.text mid_pos (dist as String) color:yellow
		
		--Think about recalculate size of UPDATE rect ...
		/*local rect = (box2 13 47 96 97)
		gw.wrect rect red
		eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
		eRect.right += 1
		eRect.bottom += 1
		gw.enlargeUpdateRect eRect*/

		gw.enlargeUpdateRect #whole
		gw.updateScreen()
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
	fn toString = (
		
		local dist = undefined
		if isValidComponents() do (
			
			local p1 = polyop.getVert _obj _vert_a
			local p2 = polyop.getVert _obj _vert_b
			dist = mcMath.roundFloat (distance p1 p2) pre:0.001
		)
		"Measure:[" + _vert_a as String + ", " + _vert_b as String + "] len:" + dist as String
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
rollout mcLiveMeasureDialog "Live Measure:" width:236 height:180
(
	
	GroupBox grp1 "Active:" pos:[4,4] width:228 height:172
	button btn_add_line "Add Line" pos:[8,120] width:108 height:24
	button btn_add_tripod "Add Tripod" pos:[120,120] width:108 height:24
	listBox lbx_measures "" pos:[8,20] width:220 height:7
	button btn_delete "Delete" pos:[8,148] width:108 height:24
	button btn_delete_all "Delete All" pos:[120,148] width:108 height:24
	local all_measures = #()
	struct LIVE_MEASURE (measure_struct, list_index) 
	fn addLineMeasure = (
		
		local m = mcLiveMeasure mode:#line
		if not m.isValidComponents() do return false
		m.start()
		local cnt = lbx_measures.items.count
		local lm = LIVE_MEASURE m (cnt+1)
		append all_measures lm
		local str = "( " + (cnt+1) as String + " ) " + m.toString()
		lbx_measures.items = append lbx_measures.items	str
	)
	fn addTripodMeasure = (
		
		
	)
	fn removeMeasure = (
		
		if lbx_measures.items.count == 0 or lbx_measures.selection == 0 do return false
		--Unregister selected measure
		local lm =  all_measures[lbx_measures.selection]
		lm.stop() 
		--Remove currently selected item from the list
		lbx_measures.items = deleteItem lbx_measures.items lbx_measures.selection
		--Reindexing data and listbox
		for i=1 to all_measures.count do all_measures[i].list_index = i
		for i=1 to lbx_measures.items do (

			
		)
		CompleteRedraw()
	)
	fn removeAllMeasures = (
		
		for m in all_measures do m.measure_struct.stop() --unregister each measure
		lbx_measures.items = #() --clear measures list
		CompleteRedraw()
	)
	on btn_add_line pressed  do addLineMeasure()
	on btn_add_tripod pressed  do addTripodMeasure()
	on btn_delete pressed  do removeMeasure()
	on lbx_measures selected index do () --lbx_measures.selected = name
	on lbx_measures doubleClicked itm do ()
	on btn_delete_all pressed do removeAllMeasures()
	on mcLiveMeasureDialog close do removeAllMeasures()
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



/*
rect = (box2 13 47 96 97)
gw.wrect rect red
eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
eRect.right += 1
eRect.bottom += 1


(
	local local_bbox = nodeLocalBoundingBox $ --(required AvGuard Extension)
	local tm = $.transform
	local bmin = local_bbox[1]*(inverse tm) 
	local bmax = local_bbox[2]*(inverse tm)
	local bbox_size = local_bbox[2] - local_bbox[1] -- w l h
	local center = (bmin + bmax)/2

	local p0 = center --center red
	local p1 = [center.x,center.y,bmin.z] --bottom green
	local p2 = [center.x,center.y,bmax.z] --top blue
	local p3 = [center.x,bmin.y,center.z] --front yellow
	local p4 = [center.x,bmax.y,center.z] --back gray
	local p5 = [bmin.x,center.y,center.z] --left white
	local p6 = [bmax.x,center.y,center.z] --right brown
	local points = #(p0, p1, p2, p3, p4, p5, p6)
	local colors = #(red, green, blue, yellow, gray, white, brown)
	global geo_points = #()
	for i=1 to points.count do append geo_points (point pos:(points[i]*$.transform) wirecolor:colors[i])
)

delete geo_points
*/

