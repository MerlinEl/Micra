
text_file_path = micra.TempDir +  "road_texts.txt"
shapes_file_path = micra.TempDir +  "road_shapes.txt"
geom_file_path = micra.TempDir +  "road_geometry.txt"

fn getValueFromData data_arr key = (
	
	local str = (for s in data_arr where findString s key != undefined collect s)[1]
	if str == undefined do return undefined
	local val = trimLeft str key
	format "getValueFromData > key:% val:%\n" key val
	val
)

fn getObjectRotation obj = (

	[obj.controller.rotation.x_rotation, obj.controller.rotation.y_rotation, obj.controller.rotation.z_rotation]
)

fn setObjectRotation obj angles = (
	
	obj.controller.rotation.x_rotation = angles[1]
	obj.controller.rotation.y_rotation = angles[2]
	obj.controller.rotation.z_rotation = angles[3]
)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--data_arr =  #("type:TEXT", "name:road_rool_mapping_hleper02", "pos:[160377,32211.3,0]", "rot:[0,0,-90]", "text:corner_p")
fn createTextObject data_str = (
	
	local data_arr  = filterString data_str "|"
	format "createTextObject: %\n" data_arr
	local n		= getValueFromData data_arr "name:"
	local p		= getValueFromData data_arr "pos:"
	local r		= getValueFromData data_arr "rot:"
	local t		= getValueFromData data_arr "text:"
	local w	= getValueFromData data_arr "wirecolor:"
	if n == undefined or p == undefined or r == undefined or t == undefined or w == undefined do return false
	local obj_text =  text pos:(execute p) name:n text:t wirecolor:(execute w)
	setObjectRotation obj_text (execute r)
	--additional ($.modifiers[1].amount)
	local ex= extrude amount:14
	addModifier obj_text ex
)


fn createShapeObject data_str = (
	
	local data_arr  = filterString data_str "|"
	format "createShapeObject: %\n" data_arr
	local n		= getValueFromData data_arr "name:"
	local p		= getValueFromData data_arr "pos:"
	local r		= getValueFromData data_arr "rot:"
	local len	= getValueFromData data_arr "length:"
	local wid	= getValueFromData data_arr "width:"
	local w	= getValueFromData data_arr "wirecolor:"
	if n == undefined or p == undefined or r == undefined or len == undefined or wid == undefined or w == undefined do return false
	local obj_rect =  rectangle pos:(execute p) name:n text:t wirecolor:(execute w) length:(execute len) width:(execute wid)
	setObjectRotation obj_rect (execute r)
)

--"type:MESH|name:%|pos:%|rot:%|wirecolor:%\n" o.name o.pos (getObjectRotation o) o.wirecolor to:f
fn importGeometryObject data_str root_dir = (
	
	local data_arr  = filterString data_str "|"
	format "importGeometryObject: %\n" data_arr
	local n		= getValueFromData data_arr "name:"
	local p		= getValueFromData data_arr "pos:"
	local r		= getValueFromData data_arr "rot:"
	local w	= getValueFromData data_arr "wirecolor:"
	if n == undefined or p == undefined or r == undefined or w == undefined do return false
	importFile (root_dir+n+".obj") #noPrompt
	local obj = $
	convertToPoly obj	
	obj.pos = (execute p)
	obj.wirecolor = (execute w)
	setObjectRotation obj (execute r)
)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn saveTextObjects fpath = (

	local f = createFile fpath
	for o in objects where classOf o.baseobject == text do (
	
		format "type:TEXT|name:%|pos:%|rot:%|wirecolor:%|text:%\n" o.name o.pos (getObjectRotation o) o.wirecolor o.baseobject.text to:f
	)
	close f
	format "saveTextObjects > Done!\n"
)

fn loadTextObjects fpath = (

	local fs = openFile fpath mode:"r+" 
	while not eof fs do(
		
	   text_line = readline fs
		if text_line.count > 1 do (
			
			createTextObject text_line
		)
	)
	close fs
	format "loadTextObjects > Done!\n"
)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn saveShapeObjects fpath = (
	
	local f = createFile fpath
	for o in objects where classOf o == Rectangle do (
	
		format "type:SHAPE|name:%|pos:%|rot:%|wirecolor:%|length:%|width:%\n" o.name o.pos (getObjectRotation o) o.wirecolor o.length o.width to:f
	)
	close f
	format "exportGeometryObjects > Done!\n"
)

fn loadShapeObjects fpath = (

	local fs = openFile fpath mode:"r+" 
	while not eof fs do(
		
	   text_line = readline fs
		if text_line.count > 1 do (
			
			createShapeObject text_line
		)
	)
	close fs
	format "loadShapeObjects > Done!\n"
)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fn saveGeometryObjects fpath root_dir = (
	
	max select none
	local f = createFile fpath	
	for o in objects where classOf o.baseobject == Editable_Poly do (
	
		format "type:MESH|name:%|pos:%|rot:%|wirecolor:%\n" o.name o.pos (getObjectRotation o) o.wirecolor to:f
		select o
		exportFile (root_dir+o.name+".obj") #noPrompt selectedOnly:true 
	)
	format "saveGeometryObjects > Done!\n"
)

fn loadGeometryObjects fpath root_dir = (
	
	
	local fs = openFile fpath mode:"r+" 
	while not eof fs do(
		
	   text_line = readline fs
		if text_line.count > 1 do (
			
			importGeometryObject text_line root_dir
		)
	)
	close fs
	format "loadGeometryObjects > Done!\n"
)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- saveShapeObjects shapes_file_path
-- loadShapeObjects shapes_file_path

-- saveTextObjects text_file_path
-- loadTextObjects text_file_path

-- seveGeometryObjects geom_file_path micra.TempDir
loadGeometryObjects geom_file_path micra.TempDir