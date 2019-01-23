fn vertexSnap = (
	Global mcVertexSnapDialog
	if ::mcVertexSnapDialog != undefined do try(destroyDialog mcVertexSnapDialog)catch()
	rollout mcVertexSnapDialog "Snap Vertex v0.01" width:220 height:68
	(
		button 'btn_get_pos' "Get Target" pos:[12,20] width:96 height:32 align:#left
		button 'btn_set_pos' "Snap Vert" pos:[112,20] width:96 height:32 align:#left
		groupBox 'grp1' "Action:" pos:[4,4] width:212 height:60 align:#left
		local vert_pos = [0,0,0]
		on btn_get_pos pressed  do
		(
			local obj = selection[1]
			if obj == undefined do return false
			local vert = (polyop.getVertSelection obj as array)[1]
			if vert == undefined do return false
			vert_pos = polyop.getVert obj vert	
			format "vert pos:%\n" vert_pos
		)
		on btn_set_pos pressed  do
		(
			if vert_pos == undefined do return false
			local obj = selection[1]
			if obj == undefined do return false
			local vert = (polyop.getVertSelection obj as array)[1]
			if vert == undefined do return false
			undo "Snap vertex" on polyop.setVert obj vert vert_pos
		)
	)
	CreateDialog mcVertexSnapDialog
)
vertexSnap()

/*
uv_channel = 1
uvVert1 = polyOp.getMapVert $ uv_channel 210
polyOp.setMapVert $ uv_channel 210 -uvVert1
*/


/*
channel = 1;
local num_faces = polyop.getNumFaces $;
for f = 1 to num_faces do(
	uvF = polyOp.getMapFace $ channel f;
	
	uvVert1 = polyOp.getMapVert $ channel uvF[1];
	uvVert2 = polyOp.getMapVert $ channel uvF[2];
	uvVert3 = polyOp.getMapVert $ channel uvF[3];
	--manipulate each uvVert, like uvVert1.x = 0.5; 
	--or like this: uvVert2.x+= 0.5; 
	
	--store them back
	polyOp.setMapVert $ channel uvF[1] uvVert1;
	polyOp.setMapVert $ channel uvF[2] uvVert2;
	polyOp.setMapVert $ channel uvF[3] uvVert3;
)
*/

/*
PreserveUV = $.modifiers[#Edit_Poly].preserveUVs
if preserveUV == false then (
    $.modifiers[#Edit_Poly].preserveUVs = on
    )
else (
    $.modifiers[#Edit_Poly].preserveUVs = off
    )
)


myEPoly.preserveUvs = True
myObject.modifiers[#Edit_Poly].preserveUVs = True
*/