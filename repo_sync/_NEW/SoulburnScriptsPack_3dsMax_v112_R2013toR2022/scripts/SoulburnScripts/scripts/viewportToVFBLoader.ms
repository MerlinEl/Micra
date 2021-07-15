-------------------------------------------------------------------------------
-- viewportToVFBLoader.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.03
-- Created On: 03/05/15
-- Modified On: 11/21/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Gets the currently active viewport and loads it into the VFB. Most useful 
-- in Vray so you don't have to do a render to set your render region. 
-- Originally written by Dave Wortley (http://davewortley.wordpress.com/), 
-- I added limited support for the scanline renderer and a number of extra 
-- options like better resize quality and overriding the viewport draw mode.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Open a file you intend to render in vray. You want to do a render region,
-- but you don't know where to set it in the vray vfb because it's blank. Set
-- active the viewport you want to render, run this script and hit Do. Now 
-- whatever was in the view is in the vfb, so you can set your render region
-- accurately.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed an issue that would stop the script from working in vray 3.2.
-- You can now do a manual gamma correction on the viewport image if you want.
-- Note that this is a gamma correction, not the gamma of the image. So a gamma
-- correction of 1 will make no change, a gamma correction of 0.45 will be 
-- darker, and a gamma correction of 2 will be lighter.
--
-- v 1.02 Moved some common code to slib.
--
-- v 1.03 Updated some functions, no change to user.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global viewportToVFBLoader
global viewportToVFBLoaderDefaults
global viewportToVFBLoaderUI

global vTVLCloseOpenUI

global vTVLDo
global vTVLApply
global vTVLHelp
global vTVLLoadDef
global vTVLSaveDef

global vTVLDefineUI
global vTVLRollout
global vTVLFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vTVLSaveValue = false
vTVLViewShadeValue = 1
vTVLManualGammaCorrectionValue = 1.0
vTVLPosValue = [400,400]

-- Functions

fn viewportToVFBLoader vTVLSave vTVLViewShade vTVLManualGammaCorrection = 
	(
	-- Setup
	local ShadeType = viewport.GetRenderLevel()
	local ShadeEdge = viewport.GetShowEdgeFaces() 
	local isMaxed = false
	local mysafeframes = displaySafeFrames
	if not displaySafeFrames do displaySafeFrames = true
	ViewportButtonMgr.EnableButtons = false
	if viewport.numViews != 1 then (max tool maximize) else (isMaxed = true)
	if vTVLViewShade > 1 then
		(
		if vTVLViewShade == 2 then viewport.SetRenderLevel #smoothhighlights
		else if vTVLViewShade == 3 then 
			(
			viewport.SetRenderLevel #smoothhighlights
			viewport.SetShowEdgeFaces true
			)
		else if vTVLViewShade == 4 then viewport.SetRenderLevel #smooth
		else if vTVLViewShade == 5 then viewport.SetRenderLevel #wireFrame 
		)	
	redrawViews()
	if doesfileexist (getdir #temp + "//BG.png") do deletefile (getdir #temp + "//BG.png")
	
	-- Get The Viewport
	local theCanvasBitmap = gw.getviewportDIB()
		
	local imageAspect = 1.0 * RenderWidth / RenderHeight
	local render_Width = RenderWidth
	local render_Height = RenderHeight
		
	local trimHeight = theCanvasBitmap.height
	local trimWidth = theCanvasBitmap.width
		
	local canvasAspect = 1.0 * theCanvasBitmap.width / theCanvasBitmap.height
	if imageAspect > canvasAspect then
		(
		trimHeight = 1.0 * theCanvasBitmap.width / render_width * render_height
		vbox = box2 0 ((theCanvasBItmap.height  / 2) - (trimheight / 2)) theCanvasBitmap.width trimHeight
		)
	else
		(
		trimWidth = 1.0 * theCanvasBitmap.Height / render_height * render_width
		vbox = box2 ((theCanvasBitmap.Width / 2) - (trimWidth / 2)) 0 trimWidth theCanvasBitmap.height
		)
		
	local trimmedViewport = bitmap trimWidth trimHeight
	pastebitmap theCanvasBitmap trimmedViewport vbox [0,0]
	
	-- Put in VFB
	render_width = renderWidth
	render_height = renderHeight
	trimmedViewport.filename = (getdir #temp + "//BG.png")
	save trimmedViewport 
	sLibResizeImageByPixelsFilter #((getdir #temp) + "//BG.png") ((getdir #temp)+"//") "" "_final" 1 render_width render_height "png" vTVLManualGammaCorrection
	(if doesfileexist (getdir #temp + "\BG.png") do deletefile (getdir #temp + "//BG.png"))
	close trimmedViewport
	close theCanvasBitmap

	-- Scanline
	if sLibWhatsCurrentRenderer() == "Scanline" then
		(
		fullImage = openBitMap (getdir #temp + "//BG_final.png")
		display fullimage
		)
	-- vray
	else if sLibWhatsCurrentRenderer() == "vray" then
		(
		vfbControl #loadimage (getdir #temp + "//BG_final.png")
		renderers.current.showLastVFB()
		)
	if vTVLSave == false then (if doesfileexist (getdir #temp + "//BG_final.png") do deletefile (getdir #temp + "//BG_final.png"))

	-- Put Scene Back
	ViewportButtonMgr.EnableButtons = true
	viewport.SetRenderLevel ShadeType
	viewport.SetShowEdgeFaces ShadeEdge
	if not isMaxed do max tool maximize
	displaySafeFrames = mysafeframes
	gc light:true
	)
	
fn viewportToVFBLoaderDefaults = 
	(
	vTVLLoadDef()
	viewportToVFBLoader vTVLSaveValue vTVLViewShadeValue vTVLManualGammaCorrectionValue
	)
	
fn viewportToVFBLoaderUI = 
	(
	vTVLLoadDef()
	vTVLCloseOpenUI vTVLPosValue
	)

fn vTVLCloseOpenUI pos = 
	(
	if vTVLFloater != undefined then CloseRolloutFloater vTVLFloater
	vTVLDefineUI()
	vTVLFloater = newRolloutFloater "viewportToVFBLoader v1.03" 310 132 pos.x pos.y
	addRollout vTVLRollout vTVLFloater
	)

fn vTVLDo = 
	(
	viewportToVFBLoader vTVLSaveValue vTVLViewShadeValue vTVLManualGammaCorrectionValue
	if vTVLFloater != undefined then CloseRolloutFloater vTVLFloater
	)

fn vTVLApply = 
	(
	viewportToVFBLoader vTVLSaveValue vTVLViewShadeValue vTVLManualGammaCorrectionValue
	)
	
fn vTVLHelp = 
	(
	sLibSSPrintHelp "viewportToVFBLoader"
	)
	
fn vTVLLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vTVLInputFilename = presetDir + "viewportToVFBLoader.ini"
	if (sLibFileExist vTVLInputFilename == true) then
		(
		vTVLSaveValue = execute (getINISetting vTVLInputFilename "viewportToVFBLoader" "vTVLSaveValue")
		vTVLViewShadeValue = execute (getINISetting vTVLInputFilename "viewportToVFBLoader" "vTVLViewShadeValue")
		vTVLManualGammaCorrectionValue = execute (getINISetting vTVLInputFilename "viewportToVFBLoader" "vTVLManualGammaCorrectionValue")
		vTVLPosValue = execute (getINISetting vTVLInputFilename "viewportToVFBLoader" "vTVLPosValue")
		
		if vTVLSaveValue == OK then vTVLSaveValue = false
		if vTVLViewShadeValue == OK then vTVLViewShadeValue = 1
		if vTVLManualGammaCorrectionValue == OK then vTVLManualGammaCorrectionValue = 1.0
		if vTVLPosValue == OK then vTVLPosValue = [400,400]
		)
	else
		(
		vTVLSaveValue = false
		vTVLViewShadeValue = 1
		vTVLManualGammaCorrectionValue = 1.0
		vTVLPosValue = [400,400]
		)
	)
	
fn vTVLSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vTVLOutputFilename = presetDir + "viewportToVFBLoader.ini"
	if (sLibFileExist vTVLOutputFilename == true) then deleteFile vTVLOutputFilename
	setINISetting vTVLOutputFilename "viewportToVFBLoader" "vTVLSaveValue" (vTVLSaveValue as string)
	setINISetting vTVLOutputFilename "viewportToVFBLoader" "vTVLViewShadeValue" (vTVLViewShadeValue as string)
	setINISetting vTVLOutputFilename "viewportToVFBLoader" "vTVLManualGammaCorrectionValue" (vTVLManualGammaCorrectionValue as string)
	setINISetting vTVLOutputFilename "viewportToVFBLoader" "vTVLPosValue" (vTVLFloater.pos as string)
	)

-- UI

fn vTVLDefineUI = 
	(
	rollout vTVLRollout "viewportToVFBLoader"
		(
		checkbox vTVLSaveCheckbox "Save VFB To Temp Directory?" checked:vTVLSaveValue align:#left
		on vTVLSaveCheckbox changed state do vTVLSaveValue = state
		dropdownlist vTVLViewShadeDropdown "" items:#("Use Current Viewport Shading", "Realistic", "Realistic + Edged Faces", "Shaded", "Wireframe") selection:vTVLViewShadeValue width:180
		on vTVLViewShadeDropdown selected i do vTVLViewShadeValue = i
		spinner vTVLManualGammaCorrectionSpinner "Manual Gamma Correction: " range:[0.0,10.0,vTVLManualGammaCorrectionValue] fieldWidth:55 type:#float align:#left enabled:true
		on vTVLManualGammaCorrectionSpinner changed val do vTVLManualGammaCorrectionValue = val

		button vTVLDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,76]
		on vTVLDoButton pressed do vTVLDo()
		button vTVLApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,76]
		on vTVLApplyButton pressed do vTVLApply()
		button vTVLHelpButton "Help" width:70 toolTip:"Help" pos:[149,76]
		on vTVLHelpButton pressed do vTVLHelp()
		button vTVLSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,76]
		on vTVLSaveDefButton pressed do vTVLSaveDef()
		)
	)
)
-------------------------------------------------------------------------------