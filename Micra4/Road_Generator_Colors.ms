Global roadGeneratorColorDialog
if roadGeneratorColorDialog != undefined do DestroyDialog roadGeneratorColorDialog
rollout roadGeneratorColorDialog "Types:" width:104 height:308
(
	struct marker(clr, txt)
	fn imgIcon clr = (#(bitmap 23 23 color:clr, undefined, 1,1,1,1,1 ))
	local colors = #(
		
		marker clr:(color 101 45 0)  txt:"DiRo",    
		marker clr:(color 174 0 1)  txt:"ShCt",  
		marker clr:(color 246 0 0 )  txt:"1_6",    
		marker clr:(color 247 0 215)  txt:"2_4",   
		marker clr:(color 174 0 247)  txt:"2-5",   
		marker clr:(color 46 1 247)  txt:"2_4P",   
		marker clr:(color 0 145 247)  txt:"2_5P",   
		marker clr:(color 0 221 247)  txt:"4_4P",   
		marker clr:(color 0 247 13)  txt:"4_5",   
		marker clr:(color 1 93 6)  txt:"2_2R",   
		marker clr:(color 215 247 0)  txt:"2_4R",   
		marker clr:(color 247 168 2) txt:"2_4RP"
	)
	GroupBox grp1 "Color:" pos:[4,4] width:96 height:300
	label 'lbl2' "Dirt Road" pos:[48,28] width:48 height:16
	label 'lbl3' "Shortcut" pos:[48,51] width:48 height:16
	label 'lbl4' "1-6" pos:[48,74] width:48 height:16
	label 'lbl5' "2-4" pos:[48,97] width:48 height:16
	label 'lbl6' "2-5" pos:[48,120] width:48 height:16
	label 'lbl7' "2-4P" pos:[48,143] width:48 height:16
	label 'lbl8' "2-5P" pos:[48,166] width:48 height:16
	label 'lbl9' "4-4P" pos:[48,189] width:48 height:16
	label 'lbl10' "4-5" pos:[48,212] width:48 height:16
	label 'lbl11' "2-2R" pos:[48,235] width:48 height:16
	label 'lbl12' "2-4R" pos:[48,258] width:48 height:16
	label 'lbl13' "2-4RP" pos:[48,281] width:32 height:16
	button 'btn_1' "" pos:[8,24] width:32 height:23 images:(imgIcon colors[1].clr)
	button 'btn_2' "" pos:[8,47] width:32 height:23 images:(imgIcon colors[2].clr)
	button 'btn_3' "" pos:[8,70] width:32 height:23 images:(imgIcon colors[3].clr)
	button 'btn_4' "" pos:[8,93] width:32 height:23 images:(imgIcon colors[4].clr)
	button 'btn_5' "" pos:[8,116] width:32 height:23 images:(imgIcon colors[5].clr)
	button 'btn_6' "" pos:[8,139] width:32 height:23 images:(imgIcon colors[6].clr)
	button 'btn_7' "" pos:[8,162] width:32 height:23 images:(imgIcon colors[7].clr)
	button 'btn_8' "" pos:[8,185] width:32 height:23 images:(imgIcon colors[8].clr)
	button 'btn_9' "" pos:[8,208] width:32 height:23 images:(imgIcon colors[9].clr)
	button 'btn_10' "" pos:[8,231] width:32 height:23 images:(imgIcon colors[10].clr)
	button 'btn_11' "" pos:[8,254] width:32 height:23 images:(imgIcon colors[11].clr)
	button 'btn_12' "" pos:[8,277] width:32 height:23 images:(imgIcon colors[12].clr)
	fn setMarkerTo color_index = (
		
			local obj = selection[1]
			if obj == undefined or classOf obj.baseObject != text do return false 
			undo "Change Marker"on (
				
				obj.wirecolor = colors[color_index].clr
				obj.baseObject.text = colors[color_index].txt
			)
	)
	on btn_1 pressed do setMarkerTo 1
	on btn_2 pressed do setMarkerTo 2
	on btn_3 pressed do setMarkerTo 3
	on btn_4 pressed do setMarkerTo 4
	on btn_5 pressed do setMarkerTo 5
	on btn_6 pressed do setMarkerTo 6
	on btn_7 pressed do setMarkerTo 7
	on btn_8 pressed do setMarkerTo 8
	on btn_9 pressed do setMarkerTo 9
	on btn_10 pressed do setMarkerTo 10
	on btn_11 pressed do setMarkerTo 11
	on btn_12 pressed do setMarkerTo 12
)
CreateDialog roadGeneratorColorDialog
if floaterGenerator != undefined do SetDialogPos roadGeneratorColorDialog [floaterGenerator.pos.x+floaterGenerator.size.x+8, floaterGenerator.pos.y]