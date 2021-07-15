-------------------------------------------------------------------------------
-- texmapBaker.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.07
-- Created On: 09/17/13
-- Modified On: 06/14/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Bakes any arbitrary map tree on a series of selected objects. So say you have 
-- a vertex color map running through a warp texture, and you want to use it as 
-- a bump. Well, vertex maps don't create proper bumps, so you bake the texture 
-- using this script, and then plug the resulting bitmap into the bump slot, and 
-- now because it's a baked texture map instead of procedural, the bump map will 
-- work properly. Or say you have a super complex diffuse map, you can bake part 
-- of the diffuse map network into a texture to speed render times up. 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a sphere. Assign a Material. Assign a procedural noise to the diffuse 
-- slot. Select that noise in the material editor. Run the script in UI mode. 
-- Choose an output directory for the rendered files. Hit Do. Now that directory 
-- will have a baked map of the diffuse in it for each object.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed 2 crash bugs.
--
-- v 1.02 Works with Vray now.
--
-- v 1.03 Fixed crash bug when a selected object was not geometry. In Vray turns
-- GI off before rendering to speed up baking. Vray now baked multiple objects.
-- Added tons of new features.
--
-- v 1.04 Improved unwrapping algorithm.
--
-- v 1.05 Added ability to use new vray 3 user defined object tags in the switcher.
--
-- v 1.06 Added ability to bake vray occlusion.
--
-- v 1.07 Changed the vray baking element to turn off color mapping that
-- was being applied to the baked element.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Only works currently with scanline, mentalray and vray renderers. If you're 
-- making a switcher map for mentalray, mentalray only allows for 20 objects max.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global texmapBaker
global texmapBakerDefaults
global texmapBakerUI

global tMBCloseOpenUI

global tMBDo
global tMBApply
global tMBHelp
global tMBLoadDef
global tMBSaveDef

global tMBDefineUI
global tMBRollout
global tMBFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

tMBModeValue = 1
tMBOutputDirValue = ""
tMBMapChannelValue = 1
tMBMapChannelTypeValue = 1
tMBSwitcherOnValue = false
tMBSwitcherTypeValue = 1
tMBSwitcherIDValue = 1
tMBSwitcherStartIDValue = 1
tMBSwitcherSlotValue = 2
tMBRenderSizeValue = 1024
tMBVFBValue = true
tMBMeditModeValue = 1
tMBPosValue = [400,400]

-- Functions

fn texmapBaker tMBMode tMBOutputDir tMBMapChannel tMBMapChannelType tMBSwitcherOn tMBSwitcherType tMBSwitcherID tMBSwitcherStartID tMBSwitcherSlot tMBRenderSize tMBVFB tMBMeditMode = 
	(
	if tMBOutputDir == undefined or tMBOutputDir == "" then (MessageBox "Please select an path to save rendered files" title:"texmapBaker")
	else
		(
		if tMBMode == 2 and sLibVrayTest() == false then (MessageBox "Vray doesn't seem to be installed, and is required to make use Vray Occlusion Mode" title:"texmapBaker")
		else
			(
			theObjectsMaterials = #()
			if tMBMode == 1 then 
				(
				texmapToBake = sLibGetActiveMap tMBMeditMode
				)
			else if tMBMode == 2 then 
				(
				texmapToBake = VRayDirt()
				texmapToBake.subdivs = 32
				)

			if texmapToBake != undefined then
				(
				objs = #()
				for i in selection do (if (sLibGeometryFilter i) == true then append objs i)
				if objs.count == 0 then (MessageBox "Please select some objects to bake" title:"texmapBaker")
				else
					(
					-- make new material
					newMaterial = Standard()
					newMaterial.specularlevel = 0
					newMaterial.Glossiness = 0
					newMaterial.useSelfIllumColor = off
					newMaterial.twoSided = on
					newMaterial.selfIllumAmount = 100
					newMaterial.Ambient = color 0 0 0
					newMaterial.diffuse = color 128 128 128
					newMaterial.specular = color 0 0 0
					newMaterial.bumpMapAmount = 100
					newMaterial.diffuseMap = texmapToBake

					-- Mapping
					if tMBMapChannelType == 2 then
						(
						max modify mode
						for o in objs do
							(
							select o
							unwrapMod = unwrap_UVW()
							addModifier o unwrapMod
							unwrapMod.setPreventFlattening off
							unwrapMod.setMapChannel tMBMapChannel
							unwrapMod.mappingReset()
							allfaces = for i = 1 to (unwrapMod.numberPolygons()) collect i
							unwrapMod.selectFaces (allfaces as bitarray)
							unwrapMod.flattenMap 45 #([1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]) 0.02 true 0 true true
							deselect o
							)
						)

					objsAndIds = #()				
					id = tMBSwitcherStartID - 1

					-- Vray Bake
					if sLibCompareArrays renderers.current.classid #(1941615238, 2012806412) then 
						(
						vr=renderers.current
						gi_on = vr.gi_on
						vr.gi_on = false
						for o in objs do
							(
							-- Material
							append theObjectsMaterials o.material
							o.material = newMaterial

							-- Bake
							fullFileName = (tMBOutputDir + "/" + "tMB_" + o.name + ".png")
							o.iNodeBakeProperties.removeAllBakeElements() 

							be1 = vraydiffusefiltermap()
							be1.outputSzX = be1.outputSzY = tMBRenderSize
							be1.fileType = fullFileName
							be1.fileName = filenameFromPath be1.fileType
							be1.filterOn = true
							be1.enabled = true
							be1.color_mapping = false

							o.INodeBakeProperties.addBakeElement be1
							o.INodeBakeProperties.bakeEnabled = true
							o.INodeBakeProperties.bakeChannel = tMBMapChannel
							o.INodeBakeProperties.nDilations = 1

							select o
							render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[tMBRenderSize,tMBRenderSize]
							id += 1
							append objsAndIds #(o,id,be1.fileType)
							)
						for i = 1 to objs.count do objs[i].material = theObjectsMaterials[i]
						vr.gi_on = gi_on
						select objs
						)
					-- Scanline and Mentalray Bake
					else
						(
						for o in objs do
							(
							-- Material
							append theObjectsMaterials o.material
							o.material = newMaterial

							-- Bake
							fullFileName = (tMBOutputDir + "/" + "tMB_" + o.name + ".png")
							o.iNodeBakeProperties.removeAllBakeElements() 

							be1 = diffusemap()
							be1.outputSzX = be1.outputSzY = tMBRenderSize
							be1.fileType = fullFileName
							be1.fileName = filenameFromPath be1.fileType
							be1.filterOn = true
							be1.shadowsOn = false
							be1.lightingOn = false
							be1.enabled = true

							o.INodeBakeProperties.addBakeElement be1
							o.INodeBakeProperties.bakeEnabled = true
							o.INodeBakeProperties.bakeChannel = tMBMapChannel
							o.INodeBakeProperties.nDilations = 1

							id += 1
							append objsAndIds #(o,id,be1.fileType)
							)
						select objs
						render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[tMBRenderSize,tMBRenderSize]
						for i = 1 to objs.count do objs[i].material = theObjectsMaterials[i]
						)

					-- Do Switcher
					if tMBSwitcherOn == true then
						(
						if tMBSwitcherType == 1 then
							(
							-- Do Mentalray Multi-Map
							if objsAndIds.count > 20 then (MessageBox "Making a mentalray Multi-Map currently only works with object counts of 20 objects or below" title:"texmapBaker")
							else
								(							
								meditMaterials[tMBSwitcherSlot] = Multi_Sub_Map ()
								if tMBSwitcherID == 1 then
									(
									meditMaterials[tMBSwitcherSlot].mode = 0
									for i in objsAndIds do
										(
										i[1].gbufferchannel = i[2]
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader = Bitmaptexture()")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader.filename = " + "\"" + i[3] + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader.name = " + "\"" + (getFilenameFile (filenameFromPath i[3])) + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader.coordinates.mapChannel = " + (tMBMapChannel as string))
										)
									)
								else
									(
									meditMaterials[tMBSwitcherSlot].mode = 1
									for i in objsAndIds do
										(
										theMod = materialmodifier()
										addmodifier i[1] theMod
										theMod.materialID = i[2]
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader = Bitmaptexture()")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader.filename = " + "\"" + i[3] + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader.name = " + "\"" + (getFilenameFile (filenameFromPath i[3])) + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].id_" + ((i[2] - 1) as string) + "_color_shader.coordinates.mapChannel = " + (tMBMapChannel as string))
										)
									)
								)
							)
						else if tMBSwitcherType == 2 then
							(
							if sLibVrayTest() == true then
								(
								-- Do VrayMultiSubTex
								meditmaterials[tMBSwitcherSlot] = VRayMultiSubTex ()

								-- Set number of ids
								while (meditMaterials[2].texmap_num !=0) do meditMaterials[2].deleteSubtex 1 -- clears all current ids
								meditmaterials[tMBSwitcherSlot].addSubtex objsAndIds[objsAndIds.count][2]

								if tMBSwitcherID == 1 then
									(
									meditMaterials[tMBSwitcherSlot].from_id = 1
									for i in objsAndIds do
										(
										i[1].gbufferchannel = i[2]
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + " = Bitmaptexture()")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + ".filename = " + "\"" + i[3] + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + ".name = " + "\"" + (getFilenameFile (filenameFromPath i[3])) + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + ".coordinates.mapChannel = " + (tMBMapChannel as string))
										)
									)
								else
									(
									meditMaterials[tMBSwitcherSlot].from_id = 0
									for i in objsAndIds do
										(
										theMod = materialmodifier()
										addmodifier i[1] theMod
										theMod.materialID = i[2]
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + " = Bitmaptexture()")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + ".filename = " + "\"" + i[3] + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + ".name = " + "\"" + (getFilenameFile (filenameFromPath i[3])) + "\"")
										execute ("meditMaterials[" + (tMBSwitcherSlot as string) + "].texmap_" + ((i[2]) as string) + ".coordinates.mapChannel = " + (tMBMapChannel as string))
										)
									)
								)
							else (MessageBox "Vray doesn't seem to be installed, and is required to make a VrayMultiSubTex map" title:"texmapBaker")
							)
						else if tMBSwitcherType == 3 then
							(
							if sLibVrayTest() == true then
								(
								-- Do Vray User Property Tags
								for i in objsAndIds do (setUserProp i[1] "tMBBakeObjName" i[1].name)							
								meditmaterials[tMBSwitcherSlot] = VRayHDRI ()
								meditmaterials[tMBSwitcherSlot].HDRIMapName = ((getFilenamePath objsAndIds[1][3])+"tMB_<tMBBakeObjName>"+(getFilenameType objsAndIds[1][3]))
								meditmaterials[tMBSwitcherSlot].name = "tMBBake"
								meditmaterials[tMBSwitcherSlot].UVGen.mapChannel = tMBMapChannel
								-- In the file name in VRayHDRI, you can put tags like "c:\temp\diffuse_<mytag>.jpg" then in the User Defined properties of your node add the string mytag=someString When V-Ray evaluates VRayHDRI on that object, it will look up the mytag user property for that node and use the texture "c:\temp\diffuse_someString.jpg" for that node.
								)
							else (MessageBox "Vray doesn't seem to be installed, and is required to make a VrayHDRI map" title:"texmapBaker")
							)
						)
					)
				)
			)
		)
	)
	
fn texmapBakerDefaults = 
	(
	tMBLoadDef()
	texmapBaker tMBModeValue tMBOutputDirValue tMBMapChannelValue tMBMapChannelTypeValue tMBSwitcherOnValue tMBSwitcherTypeValue tMBSwitcherIDValue tMBSwitcherStartIDValue tMBSwitcherSlotValue tMBRenderSizeValue tMBVFBValue tMBMeditModeValue
	)

fn texmapBakerUI = 
	(
	tMBLoadDef()
	tMBCloseOpenUI tMBPosValue
	)
	
fn tMBCloseOpenUI pos = 
	(
	if tMBFloater != undefined then CloseRolloutFloater tMBFloater
	tMBDefineUI()
	tMBFloater = newRolloutFloater "texmapBaker v1.07" 310 472 pos.x pos.y
	addRollout tMBRollout tMBFloater
	)

fn tMBDo = 
	(
	texmapBaker tMBModeValue tMBOutputDirValue tMBMapChannelValue tMBMapChannelTypeValue tMBSwitcherOnValue tMBSwitcherTypeValue tMBSwitcherIDValue tMBSwitcherStartIDValue tMBSwitcherSlotValue tMBRenderSizeValue tMBVFBValue tMBMeditModeValue
	if tMBFloater != undefined then CloseRolloutFloater tMBFloater
	)

fn tMBApply = 
	(
	texmapBaker tMBModeValue tMBOutputDirValue tMBMapChannelValue tMBMapChannelTypeValue tMBSwitcherOnValue tMBSwitcherTypeValue tMBSwitcherIDValue tMBSwitcherStartIDValue tMBSwitcherSlotValue tMBRenderSizeValue tMBVFBValue tMBMeditModeValue
	)
	
fn tMBHelp = 
	(
	sLibSSPrintHelp "texmapBaker"
	)
	
fn tMBLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	tMBInputFilename = presetDir + "texmapBaker.ini"
	if (sLibFileExist tMBInputFilename == true) then
		(
		tMBModeValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBModeValue")
		tMBOutputDirValue = (getINISetting tMBInputFilename "texmapBaker" "tMBOutputDirValue")
		tMBMapChannelValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBMapChannelValue")
		tMBMapChannelTypeValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBMapChannelTypeValue")
		tMBSwitcherOnValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBSwitcherOnValue")
		tMBSwitcherTypeValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBSwitcherTypeValue")
		tMBSwitcherIDValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBSwitcherIDValue")
		tMBSwitcherStartIDValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBSwitcherStartIDValue")
		tMBSwitcherSlotValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBSwitcherSlotValue")
		tMBRenderSizeValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBRenderSizeValue")
		tMBVFBValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBVFBValue")
		tMBMeditModeValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBMeditModeValue")
		tMBPosValue = execute (getINISetting tMBInputFilename "texmapBaker" "tMBPosValue")
		
		if tMBModeValue == OK then tMBModeValue = 1
		if tMBOutputDirValue == OK then tMBOutputDirValue = ""
		if tMBMapChannelValue == OK then tMBMapChannelValue = 1
		if tMBMapChannelTypeValue == OK then tMBMapChannelTypeValue = 1
		if tMBSwitcherOnValue == OK then tMBSwitcherOnValue = false
		if tMBSwitcherTypeValue == OK then tMBSwitcherTypeValue = 1
		if tMBSwitcherIDValue == OK then tMBSwitcherIDValue = 1
		if tMBSwitcherStartIDValue == OK then tMBSwitcherStartIDValue = 1
		if tMBSwitcherSlotValue == OK then tMBSwitcherSlotValue = 2
		if tMBRenderSizeValue == OK then tMBRenderSizeValue = 1024
		if tMBVFBValue == OK then tMBVFBValue = true
		if tMBMeditModeValue == OK then tMBMeditModeValue = 1	
		if tMBPosValue == OK then tMBPosValue = [400,400]
		)
	else
		(
		tMBModeValue = 1
		tMBOutputDirValue = ""
		tMBMapChannelValue = 1
		tMBMapChannelTypeValue = 1
		tMBSwitcherOnValue = false
		tMBSwitcherTypeValue = 1
		tMBSwitcherIDValue = 1
		tMBSwitcherStartIDValue = 1
		tMBSwitcherSlotValue = 2
		tMBRenderSizeValue = 1024
		tMBVFBValue = true
		tMBMeditModeValue = 1
		tMBPosValue = [400,400]
		)
	)
	
fn tMBSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	tMBOutputFilename = presetDir + "texmapBaker.ini"
	if (sLibFileExist tMBOutputFilename == true) then deleteFile tMBOutputFilename
	setINISetting tMBOutputFilename "texmapBaker" "tMBModeValue" (tMBModeValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBOutputDirValue" (tMBOutputDirValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBMapChannelValue" (tMBMapChannelValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBMapChannelTypeValue" (tMBMapChannelTypeValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBSwitcherOnValue" (tMBSwitcherOnValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBSwitcherTypeValue" (tMBSwitcherTypeValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBSwitcherIDValue" (tMBSwitcherIDValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBSwitcherStartIDValue" (tMBSwitcherStartIDValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBSwitcherSlotValue" (tMBSwitcherSlotValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBRenderSizeValue" (tMBRenderSizeValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBVFBValue" (tMBVFBValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBMeditModeValue" (tMBMeditModeValue as string)
	setINISetting tMBOutputFilename "texmapBaker" "tMBPosValue" (tMBFloater.pos as string)
	)

-- UI

fn tMBDefineUI = 
	(
	rollout tMBRollout "texmapBaker"
		(
		group "Bake What?"
		(
		dropdownlist tMBModeDropdown "" items:#("Currently Selected Texmap Chain in Medit", "Vray Occlusion") selection:tMBModeValue width:250 align:#right
		label label1 "Get Texmap To Bake From:" align:#right across:2 offset:[0,2]
		dropdownlist tMBMeditModeDropdown "" items:#("Classic Mat Editor", "Slate Mat Editor") selection:tMBMeditModeValue width:130 align:#right
		)
		on tMBModeDropdown selected i do 
			(
			tMBModeValue = i
			if i == 1 then tMBMeditModeDropdown.enabled = true else tMBMeditModeDropdown.enabled = false
			)
		on tMBMeditModeDropdown selected i do tMBMeditModeValue = i
		
		group "Path To Save Baked Files"
		(
		edittext tMBOutputDirEditText "" fieldWidth:240 text:tMBOutputDirValue align:#left across:2
		button tMBOutputDirButton "F" width:20 toolTip:"Choose Path" align:#right offset:[0,-2]
		)
		on tMBOutputDirEditText changed text do 
			(
			if text[text.count] != "\\" then text = text + "\\"
			tMBOutputDirValue = text
			tMBOutputDirEditText.text = text
			)
		on tMBOutputDirButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				tMBOutputDirValue = mypath
				tMBOutputDirEditText.text = mypath
				)
			else 
				(
				tMBOutputDirValue = ""
				tMBOutputDirEditText.text = ""
				)
			)
			
		group "Mapping"
		(
		spinner tMBMapChannelSpinner "Map Channel To Use: " range:[1,99,tMBMapChannelValue] fieldWidth:50 type:#integer align:#right
		dropdownlist tMBMapChannelTypeDropdown "" items:#("Use Current UVs", "Automatic UV Unwrap") selection:tMBMapChannelTypeValue width:150 align:#right
		)
		on tMBMapChannelSpinner changed val do tMBMapChannelValue = val
		on tMBMapChannelTypeDropdown selected i do tMBMapChannelTypeValue = i
		
		group "Make Switcher Map"
		(
		checkbox tMBSwitcherOnCheckbox "Enable:" checked:tMBSwitcherOnValue align:#right
		dropdownlist tMBSwitcherTypeDropdown "" items:#("Mentalray Multi-Map", "VrayMultiSubTex", "Vray 3.0 User Defined Tags") selection:tMBSwitcherTypeValue width:150 align:#right enabled:tMBSwitcherOnValue
		dropdownlist tMBSwitcherIDDropdown "" items:#("Object ID", "Mat ID") selection:tMBSwitcherIDValue width:100 align:#right enabled:tMBSwitcherOnValue
		spinner tMBSwitcherStartIDSpinner "Starting ID:" range:[1,9999999,tMBSwitcherStartIDValue] fieldWidth:50 type:#integer align:#right enabled:tMBSwitcherOnValue
		spinner tMBSwitcherSlotSpinner "What Slot To Place Switcher Map In Medit:" range:[1,24,tMBSwitcherSlotValue] fieldWidth:50 type:#integer align:#right enabled:tMBSwitcherOnValue
		)
		
		on tMBSwitcherOnCheckbox changed state do 
			(
			tMBSwitcherTypeDropdown.enabled = state
			tMBSwitcherIDDropdown.enabled = state
			tMBSwitcherStartIDSpinner.enabled = state
			tMBSwitcherSlotSpinner.enabled = state
			tMBSwitcherOnValue = state
			if tMBSwitcherTypeValue == 3 and tMBSwitcherOnValue == true then 
				(
				tMBSwitcherIDDropdown.enabled = false
				tMBSwitcherStartIDSpinner.enabled = false
				)
			)
		on tMBSwitcherTypeDropdown selected i do 
			(
			tMBSwitcherTypeValue = i
			if tMBSwitcherTypeValue == 3 then 
				(
				tMBSwitcherIDDropdown.enabled = false
				tMBSwitcherStartIDSpinner.enabled = false
				)
			else
				(
				tMBSwitcherIDDropdown.enabled = true
				tMBSwitcherStartIDSpinner.enabled = true
				)
			)
		on tMBSwitcherIDDropdown selected i do tMBSwitcherIDValue = i
		on tMBSwitcherStartIDSpinner changed val do tMBSwitcherStartIDValue = val
		on tMBSwitcherSlotSpinner changed val do tMBSwitcherSlotValue = val

		group "Options"
		(
		spinner tMBRenderSizeSpinner "Render Size: " range:[1,99999,tMBRenderSizeValue] fieldWidth:50 type:#integer align:#right
		checkbox tMBVFBCheckbox "VFB?:" checked:tMBVFBValue align:#right
		)
		on tMBRenderSizeSpinner changed val do tMBRenderSizeValue = val
		on tMBVFBCheckbox changed state do tMBVFBValue = state
		
		button tMBDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,416]
		on tMBDoButton pressed do tMBDo()
		button tMBApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,416]
		on tMBApplyButton pressed do tMBApply()
		button tMBHelpButton "Help" width:70 toolTip:"Help" pos:[149,416]
		on tMBHelpButton pressed do tMBHelp()
		button tMBSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,416]
		on tMBSaveDefButton pressed do tMBSaveDef()	

		on tMBRollout open do
			(
			if tMBSwitcherTypeValue == 3 then 
				(
				tMBSwitcherIDDropdown.enabled = false
				tMBSwitcherStartIDSpinner.enabled = false
				)
			)		
		)
	)
)
-------------------------------------------------------------------------------