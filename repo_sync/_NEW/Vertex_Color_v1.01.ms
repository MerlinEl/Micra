Global mcVertexColorDialog
if ::mcVertexColorDialog != undefined do try(destroyDialog mcVertexColorDialog)catch()
rollout mcVertexColorDialog "Vertex Color v1.01" width:408 height:184
(
	--local variables
	local bmp_colors = #(
		color 0 255 0, --1
		color 32 0 128,
		color 64 225 225,
		color 96 128 0,
		color 128 128 128,
		color 160 128 255,
		color 192 0 0,
		color 224 0 255 --8
	)
	--interface
	radiobuttons 'rdo_switch_color' "" pos:[12,24] width:29 height:144 labels:#("1", "2", "3", "4", "5", "6", "7", "8") columns:1 align:#left padding:10
	bitmap 'bmp_1' "bitmap" pos:[44,26] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[1])
	bitmap 'bmp_2' "bitmap" pos:[44,41] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[2])
	bitmap 'bmp_3' "bitmap" pos:[44,56] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[3])
	bitmap 'bmp_4' "bitmap" pos:[44,71] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[4])
	bitmap 'bmp_5' "bitmap" pos:[44,86] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[5])
	bitmap 'bmp_6' "bitmap" pos:[44,101] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[6])
	bitmap 'bmp_7' "bitmap" pos:[44,116] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[7])
	bitmap 'bmp_8' "bitmap" pos:[44,131] width:52 height:12 bitmap: (bitmap 52 12 color:bmp_colors[8])
	GroupBox 'grp1' "Color Sets:" pos:[4,4] width:104 height:172 align:#left
	button 'btn_set' "Assign" pos:[116,20] width:140 height:88 align:#left
	button 'btn_sel' "Select" pos:[264,20] width:136 height:88 align:#left
	GroupBox 'grp2' "Actions:" pos:[112,4] width:292 height:172 align:#left
	button 'btn_show_colors' "Show Vertex Colors" pos:[116,116] width:160 height:24 align:#left
	button 'btn_show_shaded' "Vertex Colors Shaded" pos:[116,144] width:160 height:24 align:#left
	radiobuttons 'rdo_show_color' "" pos:[288,120] width:103 height:16 labels:#("true", "false") columns:2 align:#left
	radiobuttons 'rdo_show_shaded' "" pos:[288,148] width:103 height:16 labels:#("true", "false") columns:2 align:#left
	--local functions
	fn getBaseNumVerts base_object = (
		
		return case (classOf base_object) of (

			Editable_Poly: polyop.getNumVerts base_object
			Editable_Mesh: meshOp.getNumVerts base_object
			Default: 0
		)
	)
	fn setObjectsColor sel verts_color map_channel = (
		
		for o in sel do (

			local base_object =  o.baseObject
			local num_verts = getBaseNumVerts base_object
			format "setObjectsColor > obj:% numverts:%\n"  base_object num_verts
			for i = 1 to num_verts do (
				
				--clr = color (random 0 255) (random 0 255) (random 0 255); --random colors (rainbow efect)
				case (classOf base_object) of (

					Editable_Poly: polyOp.setVertColor base_object map_channel i verts_color
					Editable_Mesh: meshOp.setVertColor base_object map_channel i verts_color
				)
			)
			update o
		)
	)
	fn setFacesColor obj verts_color = (
		
		format "setFacesColor > obj:% verts_color:%\n"  obj.name verts_color
		obj.SetFaceColor verts_color #VertexColor
		
	)
	fn setVertsColor obj verts_color = (
		
		format "setVertsColor > obj:% verts_color:%\n"  obj.name verts_color
		obj.SetVertexColor verts_color #VertexColor
		
	)
	fn getSelectionType sel= (
		
		if sel.count > 0 and  (subobjectLevel == undefined or subobjectLevel == 0) do return "objects"
		if subobjectLevel == 1 do return "verts"	
		if subobjectLevel == 4 or subobjectLevel == 5 do return "faces"	
	)
	--interface actions
	on rdo_switch_color changed stat do
	(

	)
	on btn_set pressed do	( 
		
		local sel = selection as array
		if (sel.count == 0) do (
		
			MessageBox "Nothing is selected." title:"Warning:" beep:off	
			return false
		)
		local verts_color =  bmp_colors[ rdo_switch_color.state ]
		local map_channel = 0
		local sel_type = getSelectionType sel
		format "sel_type:% objects:%\n" sel_type sel.count
		case sel_type of (
			
			"objects"	: setObjectsColor sel verts_color map_channel
			"faces"		: setFacesColor sel[1] verts_color
			"verts"		: setVertsColor  sel[1] verts_color
			"default"		: (undefined)
		)
		print "finished"
	)
	on btn_show_colors pressed  do
	(
		for o in selection do o.showVertexColors = rdo_show_color.state == 1
	)
	on btn_show_shaded pressed  do
	(
		for o in selection do o.vertexColorsShaded = rdo_show_shaded.state == 1
	)
	on mcVertexColorDialog open do
	(
		--bmp_1.bitmap = (bitmap 50 50 color:blue)
	)
	on mcVertexColorDialog close do
	(
		
	)	
)
createDialog mcVertexColorDialog