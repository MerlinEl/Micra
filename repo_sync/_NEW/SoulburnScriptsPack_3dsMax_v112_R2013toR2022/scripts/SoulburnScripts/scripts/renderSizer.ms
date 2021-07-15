-------------------------------------------------------------------------------
-- renderSizer.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.00
-- Created On: 09/15/15
-- Modified On: 09/23/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Sometimes when you render you want to do a test render that's smaller. But
-- changing the render size means you then have to remember what the old size was
-- and re-enter it when you're done test rendering. This script allows you to 
-- render a smaller test render size (by percentage) without modifying your final 
-- render size.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Open a scene, set the render size to 800x600. Render. Run the script in UI
-- mode, change the spinner to 50%. Hit Do or Apply. Next time you render you'll
-- get a render that's 400x300. To stop the smaller renders, Open the script, 
-- choose "New Render Size Off", hit Do or Apply, and you'll be back to normal.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global renderSizer
global renderSizerDefaults
global renderSizerUI

global rSZCloseOpenUI

global rSZHelp
global rSZLoadDef
global rSZSaveDef

global rSZDefineUI
global rSZRollout
global rSZFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

rSZAAValue = 1
rSZNewSizePercentValue = 50

global rSZTempWidth = 640
global rSZTempHeight = 480

rSZPosValue = [400,400]

-- Functions

fn renderSizer rSZAA rSZNewSizePercent = 
	(
	renderSceneDialog.close()
	
	rSZTempWidth = renderwidth
	rSZTempHeight = renderheight		
	w = (ceil((renderWidth as float)*(0.01*(rSZNewSizePercent as float)))) as integer
	h = (ceil((renderHeight as float)*(0.01*(rSZNewSizePercent as float)))) as integer
	renderwidth = w
	renderheight = h
	
	if sLibWhatsCurrentRenderer() == "Scanline" then
		(
		-- Store current parameters
		tempaa = renderers.current.antiAliasing
		
		-- Change current renderer
		if rSZAA == 1 then renderers.current.antiAliasing = false

		-- Render
		max quick render

		-- Put everything back
		renderers.current.antiAliasing = tempaa
		)

	-- Brazil 1.x
	if sLibWhatsCurrentRenderer() == "Brazil1" then
		(
		-- Store current parameters
		tempMinSamples = renderers.current.min_samples;tempMaxSamples = renderers.current.max_samples
		tempBucketPick = (renderers.current.pick_buckets_on)

		-- Change current renderer
		if rSZAA == 1 then (renderers.current.min_samples = 0; renderers.current.max_samples = 0)
		renderers.current.pick_buckets_on = false
		
		-- Render
		max quick render

		-- Put everything back
		renderers.current.min_samples = tempMinSamples;renderers.current.max_samples = tempMaxSamples
		renderers.current.pick_buckets_on = tempBucketPick
		)

	-- Brazil 2.x
	else if sLibWhatsCurrentRenderer() == "Brazil2" then
		(
		-- Store current parameters
		Brz = trackviewnodes.Brazil_r_s[renderers.current.renderer_no + 1]
		tempMinSamples = Brz.Sampling_Parameter_Block_Holder.aa_min
		tempMaxSamples = Brz.Sampling_Parameter_Block_Holder.aa_max

		-- Change current renderer

		if rSZAA == false then 
			(
			Brz.Sampling_Parameter_Block_Holder.aa_min = 0
			Brz.Sampling_Parameter_Block_Holder.aa_max = 0
			)

		-- Render
		max quick render		

		-- Put everything back
		Brz.Sampling_Parameter_Block_Holder.aa_min = tempMinSamples
		Brz.Sampling_Parameter_Block_Holder.aa_max = tempMaxSamples
		)

	-- Mentalray
	else if sLibWhatsCurrentRenderer() == "mentalray" then
		(
		-- Store current parameters
		tempMinSamples = renderers.current.MinimumSamples
		tempMaxSamples = renderers.current.MaximumSamples

		-- Change current renderer
		if rSZAA == 1 then 
			(
			renderers.current.MinimumSamples = 0
			renderers.current.MaximumSamples = 0
			)

		-- Render
		max quick render

		-- Put everything back
		renderers.current.MaximumSamples = tempMaxSamples
		renderers.current.MinimumSamples = tempMinSamples
		)

	-- vray
	else if sLibWhatsCurrentRenderer() == "vray" then
		(
		-- Store current parameters
		tempImageSampler = renderers.current.imageSampler_type
		tempFixedRateSubdivs = renderers.current.fixedRate_subdivs
		tempAdaptiveSubdivisionMinRate = renderers.current.adaptiveSubdivision_minRate
		tempAdaptiveSubdivisionMaxRate = renderers.current.adaptiveSubdivision_maxRate
		tempTwoLevelBaseSubdivs = renderers.current.twoLevel_baseSubdivs
		tempTwoLevelFineSubdivs = renderers.current.twoLevel_fineSubdivs

		-- Change current renderer
		if rSZAA == 1 then 
			(
			renderers.current.imageSampler_type = 0
			renderers.current.fixedRate_subdivs = 1
			renderers.current.adaptiveSubdivision_minRate = 1
			renderers.current.adaptiveSubdivision_maxRate = 1
			renderers.current.twoLevel_baseSubdivs = 1
			renderers.current.twoLevel_fineSubdivs = 1						
			)

		-- Render
		max quick render

		-- Put everything back
		renderers.current.imageSampler_type = tempImageSampler
		renderers.current.fixedRate_subdivs = tempFixedRateSubdivs
		renderers.current.adaptiveSubdivision_minRate = tempAdaptiveSubdivisionMinRate
		renderers.current.adaptiveSubdivision_maxRate = tempAdaptiveSubdivisionMaxRate
		renderers.current.twoLevel_baseSubdivs = tempTwoLevelBaseSubdivs
		renderers.current.twoLevel_fineSubdivs = tempTwoLevelFineSubdivs
		)
	-- Corona
	else if sLibWhatsCurrentRenderer() == "Corona" then
		(
		-- Store current parameters
		-- Change current renderer
		-- Render
		max quick render
		-- Put everything back
		)
	-- Unknown Renderer
	else
		(
		-- Render
		max quick render
		)
	renderwidth = rSZTempWidth
	renderheight = rSZTempHeight
	)
	
fn renderSizerDefaults = 
	(
	rSZLoadDef()
	renderSizer rSZAAValue rSZNewSizePercentValue
	)

fn renderSizerUI = 
	(
	rSZLoadDef()
	rSZCloseOpenUI rSZPosValue
	)
	
fn rSZCloseOpenUI pos = 
	(
	if rSZFloater != undefined then CloseRolloutFloater rSZFloater
	rSZDefineUI()
	rSZFloater = newRolloutFloater "renderSizer v1.00" 190 139 pos.x pos.y
	addRollout rSZRollout rSZFloater
	)
	
fn rSZDo = 
	(
	renderSizer rSZAAValue rSZNewSizePercentValue
	if rSZFloater != undefined then CloseRolloutFloater rSZFloater
	)

fn rSZApply = 
	(
	renderSizer rSZAAValue rSZNewSizePercentValue
	)
	
fn rSZHelp = 
	(
	sLibSSPrintHelp "renderSizer"
	)
	
fn rSZLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	rSZInputFilename = presetDir + "renderSizer.ini"
	if (sLibFileExist rSZInputFilename == true) then
		(
		rSZAAValue = execute (getINISetting rSZInputFilename "renderSizer" "rSZAAValue")
		rSZNewSizePercentValue = execute (getINISetting rSZInputFilename "renderSizer" "rSZNewSizePercentValue")
		rSZPosValue = execute (getINISetting rSZInputFilename "renderSizer" "rSZPosValue")
		
		if rSZAAValue == OK then rSZAAValue = 1
		if rSZNewSizePercentValue == OK then rSZNewSizePercentValue = 50
		if rSZPosValue == OK then rSZPosValue = [400,400]
		)
	else
		(
		rSZAAValue = 1
		rSZNewSizePercentValue = 50
		rSZPosValue = [400,400]
		)
	)
	
fn rSZSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	rSZOutputFilename = presetDir + "renderSizer.ini"
	if (sLibFileExist rSZOutputFilename == true) then deleteFile rSZOutputFilename
	setINISetting rSZOutputFilename "renderSizer" "rSZAAValue" (rSZAAValue as string)
	setINISetting rSZOutputFilename "renderSizer" "rSZNewSizePercentValue" (rSZNewSizePercentValue as string)
	setINISetting rSZOutputFilename "renderSizer" "rSZPosValue" (rSZFloater.pos as string)
	)

-- UI

fn rSZDefineUI = 
	(
	rollout rSZRollout "renderSizer"
		(
		dropdownlist rSZAADropdown "" items:#("No Antialiasing", "Antialiasing") selection:rSZAAValue width:150 align:#center
		spinner rSZNewSizePercentSpinner "Size %: " range:[1,100,rSZNewSizePercentValue] fieldWidth:50 type:#float

		on rSZAADropdown selected i do rSZAAValue = i
		on rSZNewSizePercentSpinner changed val do rSZNewSizePercentValue = val

		button rSZDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[16,57]
		on rSZDoButton pressed do rSZDo()
		button rSZApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[88,57]
		on rSZApplyButton pressed do rSZApply()
		button rSZHelpButton "Help" width:70 toolTip:"Help" pos:[16,83]
		on rSZHelpButton pressed do rSZHelp()
		button rSZSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[88,83]
		on rSZSaveDefButton pressed do rSZSaveDef()
		)
	)
)
-------------------------------------------------------------------------------