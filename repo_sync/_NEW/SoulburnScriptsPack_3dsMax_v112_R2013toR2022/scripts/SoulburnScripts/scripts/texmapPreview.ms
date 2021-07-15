-------------------------------------------------------------------------------
-- texmapPreview.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.22
-- Created On: 04/06/05
-- Modified On: 09/25/18
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Does a render of the currently selected texmap from the material editor
-- on the objects that it's applied to in the scene. Think of it as something 
-- similar to the "Show Map In Viewport" function, except it works with all
-- procedurals (Show Map In Viewport does not always produce correct results)
-- and does a full render instead of doing the openGL viewport preview.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select an object and assign a material to it. Place a noise map in the material's
-- diffuse slot. Go into the parameters of the map. Run the UI version of the 
-- script. Hit Do. It will render your scene, any objects that have that material 
-- applied will now have a flat looking render of what your noise will look like
-- on the object. Change the Which Objects dropdown to All Visible. Now all visible 
-- objects in the scene will have the map applied, not just the ones that have your
-- material applied.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Defined ui as new function.
--
-- v 1.02 Fixed a bug where the max vfb would be activated even when brazil was 
-- chosen as the renderer. Added new modes so that you can view the texmap
-- on either the objects that contain that texmap, selected objects, or all
-- visible objects.
--
-- v 1.03 Added ability to turn off effects in the render.
--
-- v 1.04 Added some new code to more cleanly open and close the UI.
--
-- v 1.05 Fixed a variable naming error that stopped the Lock Texmap function
-- from working.
--
-- v 1.06 Added Brazil 2 support.
--
-- v 1.07 Added doublesided material support. Also now the pattern can be applied
-- as a bump or diffuse (default).
--
-- v 1.08 Script turns off "Select Buckets Mode" in Brazil 1 (if it's on), and then
-- turns it back on after the render.
--
-- v 1.09 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.10 Added some simple mentalray support.
--
-- v 1.11 Added a way to always render the locked viewport in Max 2009.
--
-- v 1.12 Added size feature, and it turns off render elements now when rendering,
-- and turns of Distributed Bucket Rendering if you're using mentalray.
--
-- v 1.13 Now mentalray's GI and Caustics are also turned off for a faster render.
-- Exposure control is also turned off, and you can choose if it displays the
-- background as well.
--
-- v 1.14 Fixed an error that stopped the defaults version of the script from
-- running.
--
-- v 1.15 Added support for max2011's Slate Material Editor.
--
-- v 1.16 Added super basic Vray Support.
--
-- v 1.17 Added control that lets you turn on or off shadows and occlusion effects.
--
-- v 1.18 Added advanced vray support.
--
-- v 1.19 Now uses sLibGetActiveMap.
--
-- v 1.20 Added super basic Corona support.
--
-- v 1.21 Adjusted some code in the render area to be more efficient.
--
-- v 1.22 Fixed some code so the script now works with vray next.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Does not respect the viewport lock in the render dialog in versions of max
-- prior to 2009.
--
-- Differing values of self illumination doesn't work in vray, it's always 100% 
-- self illuminated..
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global texmapPreview
global texmapPreviewDefaults
global texmapPreviewUI

global tPCloseOpenUI

global tPRenderLockedView

global tPDo
global tPApply
global tPHelp
global tPLoadDef
global tPSaveDef
global tPOpenUI

global tPDefineUI
global tPRollout
global tPFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Global Variables

global tPActiveTexmap = undefined

-- Variables

tPRenderWhatValue = 1
tPRenderScaleValue = 100
tPSelfIllumValue = 1
tPApplyToValue = 1
tPLockMapValue = false

tPAAValue = false
tPAtmosValue = false
tPEffectsValue = false
tPMBlurValue = false
tPDOFValue = false
tPMShadAndOccValue = false
tPMDistRenderValue = false
tPMBackValue = false

tPRenderModeValue = 2
tPMeditModeValue = 1
tPPosValue = [400,400]

-- Functions

fn texmapPreview tPRenderWhat tPRenderScale tPSelfIllum tPApplyTo tPLockMap tPAA tPAtmos tPEffects tPMBlur tPDOF tPMShadAndOcc tPMDistRender tPMBack tPRenderMode tPMeditMode = 
	(
	-- set variables
	theObjectsToView = #()
	theObjectsToHide = #()
	theObjectsToViewMaterials = #()
	unhiddenObjects = sLibGetUnhiddenObjects()
	currentMaterial = meditMaterials[medit.GetActiveMtlSlot()]

	if tPLockMap == false then currentTexmap = sLibGetActiveMap tPMeditMode
	else currentTexmap = tPActiveTexmap
	
	if currentTexmap != undefined then
		(
		-- make new material
		-- Flat Color
		if tPApplyTo == 1 then 
			(
			if sLibWhatsCurrentRenderer() == "Corona" then 
				(
				newMaterial = CoronaLightMtl ()
				newMaterial.texmap = currentTexmap
				)
			if sLibWhatsCurrentRenderer() == "vray" then
				(
				newMaterial = VRayLightMtl ()
				newMaterial.texmap = currentTexmap
				)
			else 
				(
				newMaterial = Standard()
				newMaterial.specularlevel = 0
				newMaterial.Glossiness = 0
				newMaterial.useSelfIllumColor = off
				if tPSelfIllum == 1 then newMaterial.selfIllumAmount = 100
				else if tPSelfIllum == 2 then newMaterial.selfIllumAmount = 75
				else if tPSelfIllum == 3 then newMaterial.selfIllumAmount = 50
				else if tPSelfIllum == 4 then newMaterial.selfIllumAmount = 25
				else if tPSelfIllum == 5 then newMaterial.selfIllumAmount = 0
				newMaterial.Ambient = color 0 0 0
				newMaterial.diffuse = color 128 128 128
				newMaterial.specular = color 0 0 0
				newMaterial.bumpMapAmount = 100
				newMaterial.diffuseMap = currentTexmap				
				)
			)
		-- Bump
		else
			(
			if sLibWhatsCurrentRenderer() == "vray" then
				(
				newMaterial = VRayMtl ()
				newMaterial.texmap_bump_multiplier = 100
				newMaterial.texmap_bump = currentTexmap
				)
			else
				(
				newMaterial = Standard()
				newMaterial.specularlevel = 0
				newMaterial.Glossiness = 0
				newMaterial.useSelfIllumColor = off
				newMaterial.Ambient = color 0 0 0
				newMaterial.diffuse = color 128 128 128
				newMaterial.specular = color 0 0 0
				newMaterial.bumpMapAmount = 100
				newMaterial.selfIllumAmount = 0
				newMaterial.bumpMap = currentTexmap
				)
			)

		-- which objects to render
		for i in unhiddenObjects do
			(
			if tPRenderWhat == 1 then
				(
				if i.material == currentMaterial then append theObjectsToView i
				)
			else if tPRenderWhat == 2 then
				(
				if i.isselected == true then append theObjectsToView i
				)
			else if tPRenderWhat == 3 then
				(
				append theObjectsToView i
				)
			)
		if theObjectsToView.count == 0 then (MessageBox "No objects are available for viewing. Please check your Which Objects value and make sure it doesn't contradict either the texmap you have chosen or the current scene state." title:"texmapPreview")
		else
			(
			rEeffects = renderEffects
			myWidth = (ceil((renderWidth as float)*(0.01*(tPRenderScale as float)))) as integer
			myHeight = (ceil((renderHeight as float)*(0.01*(tPRenderScale as float)))) as integer
			disableSceneRedraw()
			try
				(
				-- Store Current Parameters
				tempBack = useEnvironmentMap
					
				-- modify the scene
				theObjectsToHide = sLibRemoveItemsFromArray unhiddenObjects theObjectsToView
				for i in theObjectsToHide do i.ishidden = true
				for i in theObjectsToView do 
					(
					append theObjectsToViewMaterials i.material
					i.material = newMaterial
					)
				renderEffects = tPEffects
				useEnvironmentMap = tPMBack
				tPRenderLockedView tPRenderMode
	
				-- which renderer?
				
				-- Scanline
				if sLibWhatsCurrentRenderer() == "Scanline" then
					(
					renderSceneDialog.close()
					
					-- Store current parameters
					tempVFB = rendshowVFB
					tempAtmos = rendAtmosphere
					tempRenderElements = (maxOps.GetCurRenderElementMgr()).GetElementsActive()
					tempWidth = RenderWidth
					tempHeight = RenderHeight
					tempAA = scanlineRender.antiAliasing 
					tempMapping = scanlineRender.mapping 
					tempShadows = scanlineRender.shadows 
					tempImageMBlur = scanlineRender.imageMotionBlur 
					tempImageOBlur = scanlineRender.objectMotionBlur 
					
					-- Change current renderer
					rendshowVFB = true
					rendAtmosphere = tPAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive false
					RenderWidth = myWidth
					RenderHeight = myHeight	
					scanlineRender.antiAliasing = tPAA
					scanlineRender.mapping = true
					scanlineRender.shadows = tPMShadAndOcc
					scanlineRender.imageMotionBlur = tPMBlur
					scanlineRender.objectMotionBlur = tPMBlur
					
					-- Render
					max quick render
					
					-- Put everything back
					rendshowVFB = tempVFB
					rendAtmosphere = tempAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive tempRenderElements
					RenderWidth = tempWidth
					RenderHeight = tempHeight
					scanlineRender.antiAliasing = tempAA
					scanlineRender.mapping = tempMapping
					scanlineRender.shadows = tempShadows
					scanlineRender.imageMotionBlur = tempImageMBlur
					scanlineRender.objectMotionBlur = tempImageOBlur
					)
				
				-- Brazil 1.x
				else if sLibWhatsCurrentRenderer() == "Brazil1" then
					(
					renderSceneDialog.close()
					
					-- Setup Vars
					if tPAA == false then (tPMinSamples = 0;tPMaxSamples = 0)
					else (tPMinSamples = renderers.current.min_samples;tPMaxSamples = renderers.current.max_samples)
					
					-- Store current parameters
					tempVFB = rendshowVFB
					tempAtmos = rendAtmosphere
					tempRenderElements = (maxOps.GetCurRenderElementMgr()).GetElementsActive()
					tempWidth = RenderWidth
					tempHeight = RenderHeight
					tempBucketPick = (renderers.current.pick_buckets_on)
					temprenderatmosphericeffects = renderatmosphericeffects
					tempframebuffer_auto_launch_on = renderers.current.framebuffer_auto_launch_on
					tempvfb_type = renderers.current.vfb_type
					tempconsole_auto_launch_on = renderers.current.console_auto_launch_on
					tempmin_samples = renderers.current.min_samples
					tempmax_samples = renderers.current.max_samples
					tempmapping_on = renderers.current.mapping_on
					tempvelocity_blur_on = renderers.current.velocity_blur_on
					tempflux_dirlt_on = renderers.current.flux_dirlt_on
					
					-- Change current renderer
					rendshowVFB = false
					rendAtmosphere = tPAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive false
					RenderWidth = myWidth
					RenderHeight = myHeight	
					renderers.current.pick_buckets_on = false
					renderatmosphericeffects = tPAtmos
					renderers.current.framebuffer_auto_launch_on = true
					renderers.current.vfb_type = 0
					renderers.current.console_auto_launch_on = false
					renderers.current.min_samples = tPMinSamples
					renderers.current.max_samples = tPMaxSamples
					renderers.current.mapping_on = true
					renderers.current.velocity_blur_on = tPMBlur
					renderers.current.flux_dirlt_on = tPMShadAndOcc

					-- Render
					max quick render
										
					-- Put everything back
					rendshowVFB = tempVFB
					rendAtmosphere = tempAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive tempRenderElements
					RenderWidth = tempWidth
					RenderHeight = tempHeight
					renderers.current.pick_buckets_on = tempBucketPick
					renderatmosphericeffects = temprenderatmosphericeffects
					renderers.current.framebuffer_auto_launch_on = tempframebuffer_auto_launch_on
					renderers.current.vfb_type = tempvfb_type
					renderers.current.console_auto_launch_on = tempconsole_auto_launch_on
					renderers.current.min_samples = tempmin_samples
					renderers.current.max_samples = tempmax_samples
					renderers.current.mapping_on = tempmapping_on
					renderers.current.velocity_blur_on = tempvelocity_blur_on
					renderers.current.flux_dirlt_on = tempflux_dirlt_on
					)
				
				-- Brazil 2.x
				else if sLibWhatsCurrentRenderer() == "Brazil2" then
					(
					renderSceneDialog.close()
					
					-- Store current parameters
					tempVFB = rendshowVFB
					tempAtmos = rendAtmosphere
					tempRenderElements = (maxOps.GetCurRenderElementMgr()).GetElementsActive()
					tempWidth = RenderWidth
					tempHeight = RenderHeight
					Brz = trackviewnodes.Brazil_r_s[renderers.current.renderer_no + 1]
					tempMinSamples = Brz.Sampling_Parameter_Block_Holder.aa_min
					tempMaxSamples = Brz.Sampling_Parameter_Block_Holder.aa_max
					tempMapping = Brz.System_Options_Parameter_Block_Holder.mapping_on					
					tempMBlur = Brz.Motion_Blur_Parameter_Block_Holder.motion_blur_type
					tempSSS = Brz.Luma_Server_Parameter_Block_Holder.subsurface_effects_on
					tempShadows = Brz.Luma_Server_Parameter_Block_Holder.shadows_on
					tempGI = Brz.Luma_Server_Parameter_Block_Holder.global_illum_on
					tempEX = SceneExposureControl.exposureControl
					
					-- Change current renderer
					rendshowVFB = true
					rendAtmosphere = tPAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive false
					RenderWidth = myWidth
					RenderHeight = myHeight					
					if tPAA == false then 
						(
						Brz.Sampling_Parameter_Block_Holder.aa_min = 0
						Brz.Sampling_Parameter_Block_Holder.aa_max = 0
						)
					Brz.System_Options_Parameter_Block_Holder.mapping_on = true
					if tPMBlur == false then Brz.Motion_Blur_Parameter_Block_Holder.motion_blur_type = 0
					if tPMShadAndOcc == false then
						(
						Brz.Luma_Server_Parameter_Block_Holder.subsurface_effects_on = false
						Brz.Luma_Server_Parameter_Block_Holder.shadows_on = false
						Brz.Luma_Server_Parameter_Block_Holder.global_illum_on = false
						SceneExposureControl.exposureControl = undefined
						)
					
					-- Render
					max quick render		
					
					-- Put everything back
					rendshowVFB = tempVFB
					rendAtmosphere = tempAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive tempRenderElements
					RenderWidth = tempWidth
					RenderHeight = tempHeight
					Brz.Sampling_Parameter_Block_Holder.aa_min = tempMinSamples
					Brz.Sampling_Parameter_Block_Holder.aa_max = tempMaxSamples
					Brz.System_Options_Parameter_Block_Holder.mapping_on = tempMapping					
					Brz.Motion_Blur_Parameter_Block_Holder.motion_blur_type = tempMBlur
					Brz.Luma_Server_Parameter_Block_Holder.subsurface_effects_on = tempSSS
					Brz.Luma_Server_Parameter_Block_Holder.shadows_on = tempShadows
					Brz.Luma_Server_Parameter_Block_Holder.global_illum_on = tempGI
					SceneExposureControl.exposureControl = tempEX
					)
				
				-- Mentalray
				else if sLibWhatsCurrentRenderer() == "mentalray" then
					(
					renderSceneDialog.close()
					
					-- Store current parameters
					tempVFB = rendshowVFB
					tempAtmos = rendAtmosphere
					tempRenderElements = (maxOps.GetCurRenderElementMgr()).GetElementsActive()
					tempWidth = RenderWidth
					tempHeight = RenderHeight
					tempMinSamples = renderers.current.MinimumSamples
					tempMaxSamples = renderers.current.MaximumSamples
					tempMBlur = renderers.current.MotionBlurEnable
					tempShadows = renderers.current.ShadowsEnable
					tempFG = renderers.current.FinalGatherEnable2
					tempGI = renderers.current.GlobalIllumEnable 
					tempCaustics = renderers.current.CausticsEnable
					tempEX = SceneExposureControl.exposureControl
					tempDistRender = renderers.current.DistributedEnable
					
					-- Change current renderer
					rendshowVFB = true
					rendAtmosphere = tPAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive false
					RenderWidth = myWidth
					RenderHeight = myHeight
					if tPAA == false then 
						(
						renderers.current.MinimumSamples = 0
						renderers.current.MaximumSamples = 0
						)
					if tPMBlur == false then renderers.current.MotionBlurEnable = false
					if tPMShadAndOcc == false then 
						(
						renderers.current.ShadowsEnable = false
						renderers.current.FinalGatherEnable2 = false
						renderers.current.GlobalIllumEnable = false
						renderers.current.CausticsEnable = false
						SceneExposureControl.exposureControl = undefined
						)
					if tPMDistRender == false then renderers.current.DistributedEnable = false
					
					-- Render
					max quick render
					
					-- Put everything back
					rendshowVFB = tempVFB
					rendAtmosphere = tempAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive tempRenderElements
					RenderWidth = tempWidth
					RenderHeight = tempHeight
					renderers.current.MaximumSamples = tempMaxSamples
					renderers.current.MinimumSamples = tempMinSamples
					renderers.current.MotionBlurEnable = tempMBlur
					renderers.current.ShadowsEnable = tempShadows
					renderers.current.FinalGatherEnable2 = tempFG
					renderers.current.GlobalIllumEnable = tempGI
					renderers.current.CausticsEnable = tempCaustics
					SceneExposureControl.exposureControl = tempEX
					renderers.current.DistributedEnable = tempDistRender
					)
					
				-- vray
				else if sLibWhatsCurrentRenderer() == "vray" then
					(
					renderSceneDialog.close()
					
					-- Store current parameters
					tempVFB = rendshowVFB
					tempAtmos = rendAtmosphere
					tempRenderElements = (maxOps.GetCurRenderElementMgr()).GetElementsActive()
					tempWidth = RenderWidth
					tempHeight = RenderHeight
					tempImageSampler = renderers.current.imageSampler_type
					tempFixedRateSubdivs = renderers.current.fixedRate_subdivs
					tempAdaptiveSubdivisionMinRate = renderers.current.adaptiveSubdivision_minRate
					tempAdaptiveSubdivisionMaxRate = renderers.current.adaptiveSubdivision_maxRate
					tempTwoLevelBaseSubdivs = renderers.current.twoLevel_baseSubdivs
					tempTwoLevelFineSubdivs = renderers.current.twoLevel_fineSubdivs
					tempMBlur = renderers.current.moblur_on
					tempDOF = renderers.current.dof_on
					tempGI = renderers.current.gi_on
					tempShadows = renderers.current.options_shadows
					tempEX = SceneExposureControl.exposureControl
					tempDistRender = renderers.current.system_distributedRender
					
					-- Change current renderer
					rendshowVFB = true
					rendAtmosphere = tPAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive false
					RenderWidth = myWidth
					RenderHeight = myHeight
					if tPAA == false then 
						(
						renderers.current.imageSampler_type = 0
						renderers.current.fixedRate_subdivs = 1
						renderers.current.adaptiveSubdivision_minRate = 1
						renderers.current.adaptiveSubdivision_maxRate = 1
						renderers.current.twoLevel_baseSubdivs = 1
						renderers.current.twoLevel_fineSubdivs = 1						
						)
					if tPMBlur == false then
						(
						renderers.current.moblur_on = false
						)
					if tPDOF == false then
						(
						renderers.current.dof_on = false
						)
					if tPMShadAndOcc == false then 
						(
						renderers.current.gi_on = false
						renderers.current.options_shadows = false
						SceneExposureControl.exposureControl = undefined
						)
					if tPMDistRender == false then
						(
						renderers.current.system_distributedRender = false
						)
					
					-- Render
					max quick render
					
					-- Put everything back
					rendshowVFB = tempVFB
					rendAtmosphere = tempAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive tempRenderElements
					RenderWidth = tempWidth
					RenderHeight = tempHeight
					renderers.current.imageSampler_type = tempImageSampler
					renderers.current.fixedRate_subdivs = tempFixedRateSubdivs
					renderers.current.adaptiveSubdivision_minRate = tempAdaptiveSubdivisionMinRate
					renderers.current.adaptiveSubdivision_maxRate = tempAdaptiveSubdivisionMaxRate
					renderers.current.twoLevel_baseSubdivs = tempTwoLevelBaseSubdivs
					renderers.current.twoLevel_fineSubdivs = tempTwoLevelFineSubdivs
					renderers.current.moblur_on = tempMBlur
					renderers.current.dof_on = tempDOF
					renderers.current.gi_on = tempGI
					renderers.current.options_shadows = tempShadows
					SceneExposureControl.exposureControl = tempEX
					renderers.current.system_distributedRender = tempDistRender
					)

				-- Corona
				else if sLibWhatsCurrentRenderer() == "Corona" then
					(
					renderSceneDialog.close()
					
					-- Store current parameters
					tempVFB = rendshowVFB
					tempAtmos = rendAtmosphere
					tempRenderElements = (maxOps.GetCurRenderElementMgr()).GetElementsActive()
					tempWidth = RenderWidth
					tempHeight = RenderHeight
					tempLights = renderers.current.lights_renderHidden
					
					-- Change current renderer
					rendshowVFB = true
					rendAtmosphere = tPAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive false
					RenderWidth = myWidth
					RenderHeight = myHeight
					renderers.current.lights_renderHidden = true
					
					-- Render
					max quick render
					
					-- Put everything back
					rendshowVFB = tempVFB
					rendAtmosphere = tempAtmos
					(maxOps.GetCurRenderElementMgr()).SetElementsActive tempRenderElements
					RenderWidth = tempWidth
					RenderHeight = tempHeight
					renderers.current.lights_renderHidden = tempLights
					)
				
				-- Unknown Renderer
				else
					(
					renderSceneDialog.close()
					
					-- Store current parameters
					tempVFB = rendshowVFB
					tempAtmos = rendAtmosphere
					tempWidth = RenderWidth
					tempHeight = RenderHeight
					
					-- Change current renderer
					rendshowVFB = true
					rendAtmosphere = tPAtmos
					RenderWidth = myWidth
					RenderHeight = myHeight
					
					-- Render
					max quick render
					
					-- Put everything back
					rendshowVFB = tempVFB
					rendAtmosphere = tempAtmos
					RenderWidth = tempWidth
					RenderHeight = tempHeight
					)
				)	
			catch ()
			-- put the scene back
			renderEffects = rEeffects
			useEnvironmentMap = tempBack
			for i = 1 to theObjectsToView.count do theObjectsToView[i].material = theObjectsToViewMaterials[i]
			for i in theObjectsToHide do i.ishidden = false
			enableSceneRedraw()
			completeRedraw()
			)
		)
	)

fn texmapPreviewDefaults = 
	(
	tPLoadDef()
	texmapPreview tPRenderWhatValue tPRenderScaleValue tPSelfIllumValue tPApplyToValue tPLockMapValue tPAAValue tPAtmosValue tPEffectsValue tPMBlurValue tPDOFValue tPMShadAndOccValue tPMDistRenderValue tPMBackValue tPRenderModeValue tPMeditModeValue
	)

fn texmapPreviewUI = 
	(
	tPLoadDef()
	tPCloseOpenUI tPPosValue
	)

fn tPCloseOpenUI pos = 
	(
	if tPFloater != undefined then CloseRolloutFloater tPFloater
	tPDefineUI()
	tPFloater = newRolloutFloater "texmapPreview v1.22" 187 542 pos.x pos.y
	addRollout tPRollout tPFloater
	)

fn tPRenderLockedView Mode = 
	(
	if sLibMaxVer() < 11.0 then (MessageBox "The Render Locked Viewport command only works in max 2009 and above. Defaulting to rendering active viewport." title:"texmapPreview")
	else 
		(
		if Mode == 1 then
			(
			rendViewIndex = viewport.activeViewport
			)
		else if Mode == 2 then
			(
			if rendUseActiveView == false then
				(
				if (rendViewIndex !=0) do 
					(
					if rendViewIndex > viewport.numViews then max tool maximize
					viewport.activeViewport = rendViewIndex
					)
				)
			)
		) 
	)
	
fn tPDo = 
	(
	texmapPreview tPRenderWhatValue tPRenderScaleValue tPSelfIllumValue tPApplyToValue tPLockMapValue tPAAValue tPAtmosValue tPEffectsValue tPMBlurValue tPDOFValue tPMShadAndOccValue tPMDistRenderValue tPMBackValue tPRenderModeValue tPMeditModeValue
	if tPFloater != undefined then CloseRolloutFloater tPFloater
	)

fn tPApply = 
	(
	texmapPreview tPRenderWhatValue tPRenderScaleValue tPSelfIllumValue tPApplyToValue tPLockMapValue tPAAValue tPAtmosValue tPEffectsValue tPMBlurValue tPDOFValue tPMShadAndOccValue tPMDistRenderValue tPMBackValue tPRenderModeValue tPMeditModeValue
	)
	
fn tPHelp = 
	(
	sLibSSPrintHelp "texmapPreview"
	)
	
fn tPLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	tPInputFilename = presetDir + "texmapPreview.ini"
	if (sLibFileExist tPInputFilename == true) then
		(
		tPRenderWhatValue = execute (getINISetting tPInputFilename "texmapPreview" "tPRenderWhatValue")
		tPRenderScaleValue = execute (getINISetting tPInputFilename "texmapPreview" "tPRenderScaleValue")
		tPSelfIllumValue = execute (getINISetting tPInputFilename "texmapPreview" "tPSelfIllumValue")
		tPApplyToValue = execute (getINISetting tPInputFilename "texmapPreview" "tPApplyToValue")
		tPLockMapValue = execute (getINISetting tPInputFilename "texmapPreview" "tPLockMapValue")
		tPAAValue = execute (getINISetting tPInputFilename "texmapPreview" "tPAAValue")
		tPAtmosValue = execute (getINISetting tPInputFilename "texmapPreview" "tPAtmosValue")
		tPEffectsValue = execute (getINISetting tPInputFilename "texmapPreview" "tPEFfectsValue")
		tPMBlurValue = execute (getINISetting tPInputFilename "texmapPreview" "tPMBlurValue")
		tPDOFValue = execute (getINISetting tPInputFilename "texmapPreview" "tPDOFValue")
		tPMShadAndOccValue = execute (getINISetting tPInputFilename "texmapPreview" "tPMShadAndOccValue")
		tPMDistRenderValue = execute (getINISetting tPInputFilename "texmapPreview" "tPMDistRenderValue")
		tPMBackValue = execute (getINISetting tPInputFilename "texmapPreview" "tPMBackValue")
		tPRenderModeValue = execute (getINISetting tPInputFilename "texmapPreview" "tPRenderModeValue")
		tPMeditModeValue = execute (getINISetting tPInputFilename "texmapPreview" "tPMeditModeValue")
		tPPosValue = execute (getINISetting tPInputFilename "texmapPreview" "tPPosValue")
		
		if tPRenderWhatValue == OK then tPRenderWhatValue = 1
		if tPRenderScaleValue == OK then tPRenderScaleValue = 1
		if tPSelfIllumValue == OK then tPSelfIllumValue = 1
		if tPApplyToValue == OK then tPApplyToValue = 1
		if tPLockMapValue == OK then tPLockMapValue = false
		if tPAAValue == OK then tPAAValue = false
		if tPAtmosValue == OK then tPAtmosValue = false
		if tPEffectsValue == OK then tPEffectsValue = false
		if tPMBlurValue == OK then tPMBlurValue = false
		if tPDOFValue == OK then tPDOFValue = false
		if tPMShadAndOccValue == OK then tPMShadAndOccValue = false
		if tPMDistRenderValue == OK then tPMDistRenderValue = false
		if tPMBackValue == OK then tPMBackValue = false
		if tPRenderModeValue == OK then tPRenderModeValue = 2
		if tPMeditModeValue == OK then tPMeditModeValue = 1
		if tPPosValue == OK then tPPosValue = [400,400]
		)
	else
		(
		tPRenderWhatValue = 1
		tPRenderScaleValue = 100
		tPSelfIllumValue = 1
		tPApplyToValue = 1
		tPLockMapValue = false
		tPAAValue = false
		tPAtmosValue = false
		tPEFfectsValue = false
		tPMBlurValue = false
		tPDOFValue = false
		tPMShadAndOccValue = false
		tPMDistRenderValue = false
		tPMBackValue = false
		tPRenderModeValue = 2
		tPMeditModeValue = 1
		tPPosValue = [400,400]
		)
	)
	
fn tPSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	tPOutputFilename = presetDir + "texmapPreview.ini"
	if (sLibFileExist tPOutputFilename == true) then deleteFile tPOutputFilename
	setINISetting tPOutputFilename "texmapPreview" "tPRenderWhatValue" (tPRenderWhatValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPRenderScaleValue" (tPRenderScaleValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPSelfIllumValue" (tPSelfIllumValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPApplyToValue" (tPApplyToValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPLockMapValue" (tPLockMapValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPAAValue" (tPAAValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPAtmosValue" (tPAtmosValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPEffectsValue" (tPEffectsValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPMBlurValue" (tPMBlurValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPDOFValue" (tPDOFValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPMShadAndOccValue" (tPMShadAndOccValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPMDistRenderValue" (tPMDistRenderValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPMBackValue" (tPMBackValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPRenderModeValue" (tPRenderModeValue as string)
	setINISetting tPOutputFilename "texmapPreview" "tPMeditModeValue" (tPMeditModeValue as string)	
	setINISetting tPOutputFilename "texmapPreview" "tPPosValue" (tPFloater.pos as string)
	)

-- UI

fn tPDefineUI = 
	(
	rollout tPRollout "texmapPreview"
		(
		group "Which Objects?"
		(		
		dropdownlist tPRenderWhatDropdown "" items:#("Calculated", "Selected Objects", "All Visible") selection:tPRenderWhatValue width:149
		)
		on tPRenderWhatDropdown selected i do tPRenderWhatValue = i

		group "Which Map?"
		(
		label mapLabel "" align:#left
		checkbox tPLockMapCheckbox "Lock Currently Active Map?" checked:tPLockMapValue
		)

		on tPLockMapCheckbox changed state do
			(
			tPLockMapValue = state
			curPos = tPFloater.pos
			tPCloseOpenUI curPos
			)

		group "Render Options"
		(
		spinner tPRenderScaleSpinner "Render Scale: " range:[1,100,tPRenderScaleValue] fieldWidth:50 type:#integer across:2 align:#left offset:[5,0]
		label label3 "%" align:#right
		label label1 "Self Illumination:" offset:[0,4] across:2
		dropdownlist tPSelfIllumDropdown "" items:#("100%", "75%", "50%", "25%", "0%") selection:tPSelfIllumValue width:70 offset:[4,0]
		label label2 "Apply To:" offset:[14,4] across:2
		dropdownlist tPApplyToDropdown "" items:#("Diffuse", "Bump") selection:tPApplyToValue width:70 offset:[4,0]
		checkbox tPAACheckbox "Anti-Alias?" checked:tPAAValue align:#left
		checkbox tPAtmosCheckbox "Atmospherics?" checked:tPAtmosValue align:#left
		checkbox tPEffectsCheckbox "Effects?" checked:tPAtmosValue align:#left
		checkbox tPMBlurCheckbox "Motion Blur?" checked:tPMBlurValue align:#left
		checkbox tPDOFCheckbox "DOF?" checked:tPDOFValue align:#left
		checkbox tPMShadAndOccCheckbox "Shadows And Occlusion?" checked:tPMShadAndOccValue align:#left
		checkbox tPMDistRenderCheckbox "Distributed Render?" checked:tPMDistRenderValue align:#left
		checkbox tPMBackCheckbox "Background Map?" checked:tPMBackValue align:#left
		)

		on tPRenderScaleSpinner changed val do tPRenderScaleValue = val
		on tPSelfIllumDropdown selected i do tPSelfIllumValue = i
		on tPApplyToDropdown selected i do 
			(
			tPApplyToValue = i
			if i == 1 then
				(
				label1.enabled = true
				tPSelfIllumDropdown.enabled = true
				)
			else 
				(
				label1.enabled = false
				tPSelfIllumDropdown.enabled = false
				)
			)
		on tPAACheckbox changed state do tPAAValue = state
		on tPAtmosCheckbox changed state do tPAtmosValue = state
		on tPEffectsCheckbox changed state do tPEffectsValue = state
		on tPMBlurCheckbox changed state do tPMBlurValue = state
		on tPDOFCheckbox changed state do tPDOFValue = state
		on tPMShadAndOccCheckbox changed state do tPMShadAndOccValue = state
		on tPMDistRenderCheckbox changed state do tPMDistRenderValue = state
		on tPMBackCheckbox changed state do tPMBackValue = state

		group "Options"
		(
		dropdownlist tPRenderModeDropdown "" items:#("Render Current Viewport", "Render Locked Viewport") selection:tPRenderModeValue width:150
		dropdownlist tPMeditModeDropdown "" items:#("Use Classic Mat Editor", "Use Slate Mat Editor") selection:tPMeditModeValue width:150
		)
		on tPRenderModeDropdown selected i do tPRenderModeValue = i
		on tPMeditModeDropdown selected i do tPMeditModeValue = i

		button tPDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[15,462]
		on tPDoButton pressed do tPDo()
		button tPApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[87,462]
		on tPApplyButton pressed do tPApply()
		button tPHelpButton "Help" width:70 toolTip:"Help" pos:[15,486]
		on tPHelpButton pressed do tPHelp()
		button tPSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[87,486]
		on tPSaveDefButton pressed do tPSaveDef()

		on tPRollout open do
			(
			if tPApplyToValue == 2 then 
				(
				label1.enabled = false
				tPSelfIllumDropdown.enabled = false
				)
			if tPLockMapCheckbox.state == false then
				(
				tPActiveTexmap = undefined
				tPRollout.mapLabel.text = "Active Texmap"
				)
			else 
				(
				theMap = sLibGetActiveMap tPMeditModeValue
				if theMap != undefined then 
					(
					tPActiveTexmap = theMap
					tPRollout.mapLabel.text = theMap.name
					)
				else 
					(
					tPLockMapCheckbox.checked = false
					tPActiveTexmap = undefined
					tPRollout.mapLabel.text = "Active Texmap"
					)
				)
			tPLockMapValue = tPLockMapCheckbox.state
			)
		)
	)
)
-------------------------------------------------------------------------------