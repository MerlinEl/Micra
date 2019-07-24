
-- VCanvas = undefined
if PolyBoost.ViewportCanvasOpen then (
	cui.unRegisterDialogBar VCMainFloater
	closeRolloutFloater VCMainFloater
)
if (not PolyBoost.ViewportCanvasOpen) do filein ((GetDir #maxroot) + "stdplugs\\stdscripts\\(PolyTools)\\ViewportCanvas.ms")

fn createPSD size_w size_h save_dir image_name clr layers = (

	local bmp_fpath = save_dir + image_name + ".bmp"
	local bm = bitmap size_w size_h color:clr filename:bmp_fpath
	save bm; close bm
	local btex = BitmapTexture filename:bmp_fpath
	format "btex:% bmp_fpath:%\n" btex btex.filename
	
	local bo = box width:100 heighr:100 length:100 wirecolor:blue selected:true
	convertToPoly bo
	select bo
	polyop.setMapSupport bo 1 true --enable map channel 1
	
	local map_channel = 1
	VCanvas.currentObject = bo
	bo.material = StandardMaterial()
	bo.material.diffuseMap = btex
	bo.material.diffuseMap.coords.mapchannel = map_channel
	VCanvas.currentMaterial =  bo.material
	VCanvas.usedMapSlot = btex
	VCanvas.currentTextureFile = bmp_fpath
	VCSetup.createTextureIndices = [2,2]
	ViewportCanvasSetup 1 bmp_fpath "" "" false	
	VCSetLayerSetting 8 1 layers[1] --rename frist layer		
	--generate layers
	for i=2 to layers.count do (
		
		VCNewLayer() --create next layer
		VCSetLayerSetting 8 i layers[i] --rename  layer
	)
-- 	VCLayers.OpenLayerDialog()
	local psd_fpath = save_dir + image_name + ".psd"
	VCSavePSD psd_fpath
	---final clean
-- 	ViewportCanvasEnd()
-- 	VCLayers.CloseLayerDialog()
-- 	VCanvas.RemoveCallbacksInViewportCanvas()
	cui.unRegisterDialogBar VCMainFloater
	closeRolloutFloater VCMainFloater
-- 	PolyBoost.ViewportCanvasOpen = false
	resumeEditing()
	bo.material.diffuseMap = undefined
	delete bo
	deleteFile bmp_fpath
	enablesceneredraw()
	CompleteRedraw()
)
createPSD 256 128 "c:\\temp\\"  "bmp_test_7" blue #("opacity", "diffuse", "normalmap", "roughness", "alpha")

/*
viewport.ResetAllViews()
viewport.SetRenderLevel #smooth


	VCPaintRoll.ResetButtons()
	VCEndTrack()
	ViewportCanvasEnd()



globalDXDisplayManager.isDXActive()
 DisplayManager.IsEnabled()
DisplayManager.IsEnabled = false
IDisplayGamma.colorCorrectionMode = #none
enablesceneredraw()
VCanvas.RemoveCallbacksInViewportCanvas()
*/

/*
ViewportCanvasSetup 1 fname "" "" false		
VCanvas.StartPaintTool 1
VCNewLayer() --NewLayer

VCLayers.CloseLayerDialog()
	/*
	setSubTexmap VCanvas.mapSlotArray[2] 2 btex
	local mapSlot = getSubTexmap VCanvas.mapSlotArray[2] 2
	mapSlot.coords.mapchannel = mapchannel
	VCanvas.usedMapSlot = mapSlot
	showTextureMap bo.material btex true
	VCanvas.currentTextureFile = fname*/

/*
bm = bitmap size_w size_h color:clr filename:fname
forceReloadBitmapFile bm
VCLoadBitmapIntoLayer bm


						VCOptionsRoll.mapbut.enabled = false
						VCPaintRoll.view2Dbut.enabled = true
						VCPaintRoll.layerdiagbut.enabled = true
if VCLayers.LayerDialogLeftOpen do VCLayers.OpenLayerDialog()
VCanvas.ReloadMap()
size_w = 256
size_h = 128
fname = "c:\\temp\\bmp_test3.bmp"
clr = blue
*/


/*

VCPaintRoll.ResetButtons()
VCanvas.currentObject = $
VCanvas.currentMaterial =  $.material
VCanvas.currentTextureFile = "c:\\temp\\bmp_test2.bmp"
doesFileExist VCanvas.currentTextureFile
VCanvas.currentTool = 1 
VCanvas.doRestartTool = false

VCNewLayer() --NewLayer
VCLayers.OpenLayerDialog()
VCLayers.CloseLayerDialog()




					with redraw off
					(
						VCOptionsRoll.mapbut.enabled = false
						VCPaintRoll.view2Dbut.enabled = true
						VCPaintRoll.layerdiagbut.enabled = true
						undo off (selObjInViewportCanvas = $; hide selObjInViewportCanvas)
						AddCallbacksInViewportCanvas()
						if VCLayers.LayerDialogLeftOpen do VCLayers.OpenLayerDialog()
					)
*/


/*
VCGetSetting 100
VCSetLayerSetting 9 0 true --set layerdialog as open setting
VCLayers.BuildLayerRollout()
	numLayers = VCGetLayerSetting 1 0
	currentLayer = VCGetLayerSetting 2 0
	if selectLayer do
	(
		VCSetCurrentLayer index
		UpdateLayerUI()
	)
*/

