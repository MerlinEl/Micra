--Texture color picker
rollout mcTextureColorPickerDiaolog "Untitled" width:152 height:88
(
	local pObj
	GroupBox grp1 "Texture Color Picker:" pos:[8,8] width:136 height:72
	button btn_pick "Pick" pos:[16,32] width:72 height:32 --pickbutton
	colorPicker cp_wirecolor "" pos:[88,32] width:40 height:32
	fn get3Points ObjSnp rayP img = 
	(
		if ObjSnp == undefined or rayP == undefined do return undefined
		
		-->get vert pos
		local p3_B = meshop.getVert ObjSnp 4
		local p3_S = meshop.getVert ObjSnp 3
		local p3_A = meshop.getVert ObjSnp 1
		--point pos:p3_S name:"S"
		--point pos:p3_B name:"B"
		--point pos:p3_A name:"A"
		--format "S:%\tB:%\tA:%\n" p3_S p3_B p3_A

		-->get 3d pos on surface
		local p3_M = (intersectRayEx ObjSnp rayP)
		if p3_M == undefined do return undefined
		p3_M = p3_M[1].pos
		--point pos:p3_M
		
		-->Calculate 2d pos from 3d pos
		local v1=(p3_A - p3_S)
		local v2=(p3_B - p3_S)
		local v3=(p3_M - p3_S)
	
		local p1_X = dot v2 v3 
		local p1_Y = dot v1 v3
		p1_X = p1_X / length v2
		p1_Y = p1_Y / length v1
		
		local p2  = [p1_X,p1_Y] 
		if p2 == undefined do return undefined
 		--format "2DPos:%\n" p2
		
		-->when mesh plane resolution is changed
		local hImg   = img.height
		local wImg   = img.width
		local hPlane = length v1
		local wPlane = length v2

		local Rx = p1_X / (length (p3_A - p3_S)) * hImg
		local Ry = p1_Y / (length (p3_B - p3_S)) * wImg
		p2 = [Rx, Ry]


		--format "wImg:%\twPlane:%\thImg:%\thPlane:%\n" hImg (length v1) wImg (length v2) 
		
		local col = getPixels img p2 1
		if col == undefined do return undefined  
		
		--format "2DPos:%\tcolor_points:%\n" p2 col
		
		return col[1]
	)
	
	--fn rayTo2P pPoint ()
	
	tool mcTCPicker
	(
		local pPos, rayInt, ObjSnp, img
		on start do
		(
			local imgFile = pObj.material.diffusemap.bitmap.filename
			img = openBitmap imgFile
			hide (ObjSnp = snapshot pObj name:"Texture_Color_Picker_Snapshot")
		)
		on mousePoint clickno do
		(
			if clickno > 1 do
			(
				--print clickno
				local rayP = mapScreentoWorldRay viewPoint
				local col = get3Points ObjSnp rayP img
				if col != undefined do 
				(
					cp_wirecolor.color = col 
				)
				--format "2DPos:%\tcolor_points:%\n" p2 col
			)
		)
		on stop do
		(
			try (delete ObjSnp) catch ()
			print "end"
		)
	)
	on btn_pick pressed do
	(
		pObj = selection[1]
		if pObj != undefined do startTool mcTCPicker
	)
)
createDialog mcTextureColorPickerDiaolog
