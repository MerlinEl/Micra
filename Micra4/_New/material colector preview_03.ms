Global previewSelectedMaterialsDialog
if previewSelectedMaterialsDialog != undefined do DestroyDialog previewSelectedMaterialsDialog
rollout previewSelectedMaterialsDialog "Preview Selected Materials" width:1632 height:988
(
	GroupBox 'grp1' "Gallery:" pos:[4,4] width:1620 height:980 align:#left
	dotNetControl 'flp_cat' "flowlayoutpanel" pos:[8,20] width:1608 height:960 align:#left
	button 'btn_collect' "Collect" pos:[1550,4] width:68 height:12 align:#left
	local thumb_size = [264, 200]
	fn dotnetColor clr = (
	
		return (dotnetclass "system.drawing.color").fromARGB clr.r clr.g clr.b
	)
	fn getObjectMaterials obj = (

		local mat = obj.material
		--get all unique ids
		local mats_id = #{}
		for f = 1 to obj.faces.count do (

			mats_id += #{polyop.getFaceMatID obj f}
		)
		--collect materials from ids
		local used_mats = #()
		for id in mats_id do (

			for i = 1 to mat.materialList.count do (

				if mat.materialIDList[i] != id do continue
				--format "ID:% MAT:%\n" id mat.materialList[i].name
				appendIfUnique used_mats mat.materialList[i]
			)
		)
		used_mats
	)

	fn getObjectsMaterials objs = (

		local used_mats = #()
		for o in objs do (
			
			local obj_mats = getObjectMaterials o
			for mat in obj_mats where findItem used_mats mat == 0 do (

				append used_mats mat
			)
		)
		used_mats
	)
	
	fn stretchBitmapTo bm w h = (
	
		local bb= bitmap w h color:black 
		local tx = bitmaptexture bitmap:bm
		rendermap tx into:bb size:[bb.width,bb.height] filter:on display:off	
		bb
	)
	
	fn resizeBitmapNET srcBitmap width height useHighQuality:false= (
		local destBitmap = (dotNetObject "System.Drawing.Bitmap" width height) --Create new bitmap object
		destBitmap.SetResolution srcBitmap.HorizontalResolution srcBitmap.VerticalResolution
		local theGraphics = (dotNetClass "System.Drawing.Graphics").fromImage destBitmap --Create new Graphics object
		local destRec = (dotnetObject "System.Drawing.rectangle" 0 0 width height) --Set destination image size
		IF useHighQuality DO theGraphics.InterpolationMode = theGraphics.InterpolationMode.HighQualityBicubic
		theGraphics.drawImage srcBitmap destRec --Resize the image
		theGraphics.dispose() --gc
		return destBitmap
	)
	
	fn addImageToButton diffuse_map button_text = (
		
		local img_btn = dotnetobject "button"
		img_btn.size = dotnetobject "system.drawing.size" thumb_size.x thumb_size.y --160 120
		img_btn.forecolor = dotnetColor (color 176 196 222)  --text color
		img_btn.margin =  dotnetobject "system.windows.forms.padding" 2 -- thumbs distance
		img_btn.flatstyle = (dotNetclass "System.Windows.Forms.FlatStyle").flat
		img_btn.FlatAppearance.BorderSize = 2
		img_btn.text = button_text
		img_btn.textalign =  (dotnetclass "System.Drawing.ContentAlignment").BottomCenter
		
		if classOf diffuse_map == Bitmaptexture then (
			
			try (
				
				local bm = diffuse_map.bitmap
				bm = stretchBitmapTo bm thumb_size.x thumb_size.y 
				setClipboardBitmap bm
				local clipboardObj = dotNetClass "System.Windows.Forms.Clipboard"
				local imgObj = clipboardObj.GetImage()
				img_btn.Image = imgObj
				setClipboardBitmap (Bitmap thumb_size.x thumb_size.y color:green ) --reset clipboard
				/*local fpath = diffuse_map.fileName
				format "bm:%\n" fpath
				local fpath = dotNetObject "System.Drawing.Bitmap" fpath
				local img_copy = resizeBitmapNET fpath thumb_size.x thumb_size.y
				fpath.Dispose()
				img_btn.Image = img_copy*/

			) catch (
				
				format "addImageToButton >  %  Error:%\n" button_text (getCurrentException())
			)
		) else (
			
			format "Unable get bitmap from:% DiffuseMap is Undefined.\n" button_text
		)
		img_btn
	)
	fn generateThumbnails mats = (

		local dnobjarray = #()
		for mat in mats do (
			
			local diffuse_map = case classOf mat of (

				DirectX_9_Shader: (
					
					local mt = mat.renderMaterial
					if classOf mt == LS3DMaterial then mt.diffuseMap else undefined
				)
				LS3DMaterial: (

						 mat.diffuseMap
					)
					default: undefined
			)
			append dnobjarray (addImageToButton diffuse_map mat.name)
		)
		flp_cat.controls.clear()
		flp_cat.controls.addrange dnobjarray
	)
	fn init = (
		
		flp_cat.AutoSize = true
		flp_cat.autoscroll = true
		flp_cat.padding = dotnetobject "system.windows.forms.padding" 2
		flp_cat.BackColor = dotnetColor (color 40 45 66)	
	)
	on btn_collect pressed  do (
		
		local used_mats = getObjectsMaterials (selection as array)
		--local used_mats = GetUsedMaterialsFromObjects (selection as array)
		previewSelectedMaterialsDialog.title = "Preview Selected Materials > found("+used_mats.count as String+")"
		generateThumbnails used_mats
	)
	on previewSelectedMaterialsDialog open do (init())
)
CreateDialog previewSelectedMaterialsDialog