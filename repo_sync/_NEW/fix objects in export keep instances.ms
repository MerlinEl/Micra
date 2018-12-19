--set vertec color in all objects
for o in selection do (
	--local clr = green
	local clr = color (random 0 255) (random 0 255) (random 0 255);
	local map_channel = 0
	for i = 1 to o.numVerts do(


		case (classOf o) of (

			Editable_Poly: (polyOp.setVertColor o map_channel i clr)
			Editable_Mesh: (meshOp.setVertColor o map_channel i clr)
		)
		
	)
	update o
	--$.showVertexColors = true;
	--$.vertexColorsShaded = false;	
)
		
		
		
		
		--vertex color all
		(
			local color_1 = color 0 255 0
			local color_2 = color 32 0 128
			local color_3 = color 64 225 225
			local color_4 = color 96 128 0
			local color_5 = color 128 128 128
			local color_6 = color 160 128 255
			local color_7 = color 192 0 0
			local color_8 = color 224 0 255
			
			local clr = color_2
			local sel = selection as array 
			max modify mode
			with redraw off for o in sel do (
				
				
				select o
				local base_obj = o.baseobject
				if superClassOf o != GeometryClass do continue
				--if (classof o != Editable_Poly or classOf o != PolyMeshObject) do continue
				modPanel.setCurrentObject base_obj
				subobjectlevel = 4
				
			/*local face_selection = #{}
			local num_faces = polyop.getNumFaces base_obj f
			for f = 1 to num_faces do
			(
				 face_selection[f] = true
	
			)--end f loop
			polyop.setFaceSelection base_obj face_selection*/
				
				max select all
				o.SetFaceColor clr #VertexColor
				max select none
				subobjectlevel = 0
			)
			select sel
		)
		
		--reset scale 
		ResetScale $
		ResetTransform $
		
		
		--select objects without vartex color
		(
			local default_clr = white
			local sel = selection as array 
			max select none
			local objs_without_vertex_color = #()
			max modify mode
			
			with redraw off for o in sel do (
				
				select o
				local base_obj = o.baseobject
				if superClassOf o != GeometryClass do continue
				if (base_obj.GetFaceColor #VertexColor == default_clr) do objs_without_vertex_color = append objs_without_vertex_color o
			)
			select objs_without_vertex_color
		)
		

/*
 for o in selection do format "class:%\n" (classOf o)
		
--unlink all from node
for o in $_test_farm_01.children do o.parent = undefined
	
--link unlinked objects to node
unlinked_objects = for o in selection where o.parent == undefined do o.parent = $_test_farm_01	
	

sel8 = for o in selection collect o.name
obj8= for n in sel8 collect (getNodeByName n)
select obj8



resettransform $
for o in selection where o.scale != [1,1,1] do resetTransform o
*/


fn selUnlinked = (

	local unlinked_objs = for o in selection where o.parent == undefined collect o
	select unlinked_objs
)
fn copyPositions =(
	
		return (for o in selection collect mcItem o.name o.pos)
)
fn pastePositions data = (

	for item in 	data do (
		
		local obj = getNodeByName item.key
		if obj == undefined do continue
		obj.pos = data.val
	)
)
/*
$.parent = $lh_loc_farm_geometry
$.parent = $barn_pig_floor
selection_pos = copyPositions()
pastePositions selection_pos
selUnlinked()
*/


fn selectObjectsByID mat_id = (
	
	local objs = #()
	for o in selection do (
	
		local face_id = case classOf o.baseobject of (

			Editable_Poly:polyop.getFaceMatID o.baseobject 1
			Editable_Mesh:getFaceMatID  o.baseobject 1
		)
		if face_id == mat_id do objs = append objs o
	)
	select objs
)
selectObjectsByID 10