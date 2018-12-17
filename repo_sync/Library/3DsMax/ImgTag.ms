		local file_name = mcPath()+"Img\\3DGallery_Icon.bmp"
		if doesFileExist file_name do tg_icn.bitmap = openBitmap file_na



(if dia != undefined do DestroyDialog dia)
-----------------------------------------------------------------

rollout dia "Untitled" width:162 height:300
(
	bitmap bmp_1 "Bitmap" fileName:"Expression.bmp"
	ImgTag tagpos "Bitmap"pos:[0,0] width:149 height:270
	checkbutton ckb_01 "" pos:[31,18] width:10 height:10
	
	on tagpos mouseup do (print mouse.pos)
	on tagpos dblclick do (destroyDialog dia)
)
CreateDialog dia 149 290 -5 10 style:#(#style_toolwindow)
