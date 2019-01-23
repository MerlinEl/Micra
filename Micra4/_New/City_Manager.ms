fn sityManager = (
	Global mcCityManagerDialog
	if ::mcCityManagerDialog != undefined do try(destroyDialog mcCityManagerDialog)catch()
	rollout mcCityManagerDialog "City Manager v0.01" width:220 height:68
	(
		button 'btn_get' "Get Parent" pos:[12,20] width:96 height:32 align:#left
		button 'btn_set' "Set Parent" pos:[112,20] width:96 height:32 align:#left
		groupBox 'grp1' "Action:" pos:[4,4] width:212 height:60 align:#left
		local cur_parent
		on btn_get pressed  do
		(
			local obj = selection[1]
			if obj == undefined do return false
			cur_parent = obj.parent
			format "get parent:%\n" cur_parent.name
		)
		on btn_set pressed  do
		(
			if cur_parent == undefined do return false
			if selection.count == 0 do return false
			selection.parent = cur_parent
			format "set parent:%\n" cur_parent.name
		)
	)
	CreateDialog mcCityManagerDialog
)
sityManager()

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