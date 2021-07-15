-------------------------------------------------------------------------------
-- soulburnAssetLoader.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 1.31
-- Created On: 03/12/14
-- Modified On: 06/17/17
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- A quick way to let you merge various assets into your scene from a nice 
-- icon based interface (including Environments that consist of lights and hdris,
-- material presets and individual models). I got the idea from looking at
-- keyshot, while keyshot is a nice piece of software, it's quite limiting
-- when you want to do something more complex (like adding rust on an object
-- for example.) But it's great at quickly swapping materials and rendering them 
-- in a realistic environment. So hopefully this script can help you achieve the 
-- speed but lets you to customize your materials and rigs more than keyshot 
-- allows. Works with any 3dsmax renderer.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Install some assets. Run the script. Set the 3 asset directories. Hit SaveDef. 
-- You should now see some asset icons. Click on an icon to load asset. For more
-- information on running SAL, watch the youtube instructon video at
-- https://www.youtube.com/watch?v=edvfB7Tc-lU
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed a bug where some people's computers would throw a dotnet error
-- because they didn't have permission to write to the 3dsmax install directory.
-- If a category doesn't exist in the filename of an asset, now the asset will
-- only show up in the "All" category.
--
-- v 1.02 Fixed a bug where the script would fail on some system with an 
-- "Syntax error: at (, expected do" error.
--
-- v 1.03 Fixed a merge bug where sometimes the script would put the objects
-- on the wrong layer.
--
-- v 1.04 Now does a proper alphabetization of assets.
--
-- v 1.05 Added a wizard to install max objects / material as assets. This is
-- currently very basic, but there will be more features added soon. Now when 
-- importing Materials will ignore any helpers inside the imported max file. 
-- Align now works properly with groups. Fixed an error that would occur if
-- you had more than 20 categories. Added ability to always have your light
-- assets visible in your view, invisible, or just accept whatever the setting 
-- is in your saved maxfile (the default).
--
-- v 1.06 Gives option of merging in Model assets into the file's layer, the
-- current layer, or a brand new layer. Added a checkbox to uniquify merged
-- model names. Gives you a warning now when merging duplicate materials.
-- Added a checkbox to place the merged environment light's texture into the 
-- scene's environment slot. Floater is now dockable.
--
-- v 1.07 In the asset wizard, you can now render a camera view to make your 
-- asset icon. In the asset wizard, you can now choose your category from
-- dropdowns of your current categories.
--
-- v 1.08 Fixed a bug that would crash the Asset Wizard. You can now add
-- an extra asset directory in addition to the main asset directory in case
-- you have another location you want to add assets from. Added wildcard
-- filter so you can filter any category by a search string, for example, 
-- "Rock" will filter the assets only showing assets with the word "Rock"
-- anywhere in the name.
--
-- v 1.09 You can now add the environment's filename as a prefix to the imported
-- objects. Also you can now manually resize the floater window if you want, 
-- or keep it in automatic resize mode. Added a button to remake all icons
-- in SAL. You can now do a manual gamma correction on the SAL icons if you want.
-- Note that this is a gamma correction, not the gamma of the icon. So a gamma
-- correction of 1 will make no change, a gamma correction of 0.45 will be 
-- darker, and a gamma correction of 2 will be lighter.
--
-- v 1.10 Adjusted some code in the render area to be more efficient.
--
-- v 1.11 Added ability to place materials in the Slate Material Editor.
--
-- v 1.20 People have been asking for this for awhile now, finally added a
-- Textures category where you can load textures into your material editor. 
-- Currently works with "Tif", "png", "hdr" and "exr" files. Also added 
-- ability to turn off any of the 4 categories of assets, removing them from
-- the interface and giving you more screen real estate. Also fixed a number
-- of issues relating to resizing the floater window.
--
-- v 1.21 Fixed a bug where the asset wizard would install models in the 
-- wrong directory.
--
-- v 1.22 Optimized some merge code.
--
-- v 1.30 Added a Texmap category, where you can load your favorite individual
-- texture maps (like Bitmap, Noise, Gradient, etc), or your own personal texmap
-- chains (such as a Noise with 2 Gradients in the Color swatches. This allows
-- you to make a "Favorites" selection of texmaps so you don't have to find what
-- you need in a long list of texmaps you never use. To make your own texmap 
-- assets, create a Standard Material or VrayMtl, place the texmap or texmap 
-- chain in the diffuse slot, assign this material to a dummy object like a 
-- teapot, and then save the max file to your Texmap directory. Think of it like 
-- the way you save a Material asset, except it only grabs the diffuse map and 
-- places that into the material editor instead of grabbing the entire material.
--
-- v 1.31 Changed the name of the Environment layer to "_EnvSAL" so it always 
-- shows up at the top of the Alphabetical Layer list.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- SAL is meant to be run with gamma correction on. If you turn gamma 
-- correction off in the max ui, max automatically makes sAL's icons darker 
-- the next time they're generated. I haven't found a way to stop max from 
-- doing this yet, so in the meantime, either always work with gamma correction 
-- on (which we all should be doing anyways), or turn it on when you're 
-- regenerating sal's icons and then turn it back off, or use the manual 
-- gamma correction value to manually control your icon gamma.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global soulburnAssetLoader
global soulburnAssetLoaderDefaults
global soulburnAssetLoaderUI

global sALDeleteAllIcons
global sALShouldIRemakeIcon
global sALIconXPos
global sALIconYPos
global sALInstallAsset
global sALDockMe

global sALCloseOpenUI

global sALHelp
global sALLoadDef
global sALSaveDef

global sALDefineUI
global sALShowRollout
global sALEnvRollout
global sALMatRollout
global sALModelRollout
global sALTexRollout
global sALTexMapRollout
global sALRollout
global sALWizardRollout
global sALFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global sALEnvDirValue = "E:\\assets\\env\\"
global sALMatDirValue = "E:\\assets\\mats\\"
global sALModelDirValue = "E:\\assets\\models\\"
global sALTexDirValue = "E:\\assets\\textures\\"
global sALTexMapDirValue = "E:\\assets\\texmaps\\"

global sALEnvDirExtraValue = ""
global sALMatDirExtraValue = ""
global sALModelDirExtraValue = ""
global sALTexDirExtraValue = ""
global sALTexMapDirExtraValue = ""

global sALIgnoreValue = "Ignore_"
global sALRecurseSubdirsValue = true
global sALIconSizeValue = 50
global sALIconsAcrossValue = 16
global sALManualResizeValue = false
global sALManualGammaCorrectionValue = 1.0

global sALEnvDeleteOldValue = true
global sALEnvIgnoreCamValue = true
global sALEnvVisibilityValue = 1
global sALEnvPlaceEnvMapValue = false
global sALEnvAddEnvPrefixValue = false

global sALMatMeditCurSlotValue = false
global sALMatMeditLocationValue = 1
global sALMatSelObjsValue = true

global sALModelAlignValue = false
global sALModelToCurrentLayerValue = true
global sALModelIgnoreCamValue = true
global sALModelIgnoreLightValue = true
global sALModelUniqueNamesValue = true
global sALModelMergeIntoValue = 1

global sALTexMeditLocationValue = 1
global sALTexMapTypeValue = 1

global sALTexMapMeditLocationValue = 1

global sALAssetTypeValue = 3
global sALAssetFileIndexValue = 1
global sALEnvCategoryIndexValue = 1
global sALMatCategoryIndexValue = 1
global sALModelCategoryIndexValue = 1
global sALTexCategoryIndexValue = 1
global sALTexMapCategoryIndexValue = 1

global sALEnvFiles = #()
global sALMatFiles = #()
global sALModelFiles = #()
global sALTexFiles = #()
global sALTexMapFiles = #()
global sALEnvCategories = #("All")
global sALMatCategories = #("All")
global sALModelCategories = #("All")
global sALTexCategories = #("All")
global sALTexMapCategories = #("All")
global sALEnvPresetCategories = #("")
global sALMatPresetCategories = #("")
global sALModelPresetCategories = #("")
global sALTexPresetCategories = #("")
global sALTexMapPresetCategories = #("")

global sALEnvFilterValue = ""
global sALMatFilterValue = ""
global sALModelFilterValue = ""
global sALTexFilterValue = ""
global sALTexMapFilterValue = ""

global sALWizardAssetTypeValue = 3
global sALWizardCategoryValue = ""
global sALWizardNameValue = ""
global sALWizardGetIconFileValue = ""

global sALEnvShowValue = true
global sALMatShowValue = true
global sALModelShowValue = true
global sALTexShowValue = true
global sALTexMapShowValue = true

sALPosValue = [400,400]
sALSizeValue = [800,600]

-- Functions

fn soulburnAssetLoader sALEnvDeleteOld sALEnvIgnoreCam sALEnvVisibility sALEnvPlaceEnvMap sALEnvAddEnvPrefix sALMatMeditCurSlot sALMatMeditLocation sALMatSelObjs sALModelAlign sALModelToCurrentLayer sALModelIgnoreCam sALModelIgnoreLight sALModelUniqueNames sALModelMergeInto sALTexMeditLocation sALTexMapType sALTexMapMeditLocation sALAssetType sALAssetFileIndex = 
	(
	if sALAssetType == 1 then
		(
		-- get current selection
		oldSelection = for i in selection collect i
		
		-- delete old environment
		if sALEnvDeleteOld == true then
			(
			toDelete = #()
			-- Old Layer Name
			if LayerManager.getLayerFromName "SAL_Environment" != undefined then 
				(
				(LayerManager.getLayerFromName "SAL_Environment").nodes &toDelete
				undo "soulburnAssetLoader" on 
					(
					for obj in toDelete do (try (delete obj) catch ())
					)
				LayerManager.deleteLayerByName "SAL_Environment"
				)
			-- New Layer Name
			if LayerManager.getLayerFromName "_EnvSAL" != undefined then 
				(
				(LayerManager.getLayerFromName "_EnvSAL").nodes &toDelete
				undo "soulburnAssetLoader" on 
					(
					for obj in toDelete do (try (delete obj) catch ())
					)
				)
			)
			
		-- merge new environment
		if sLibMaxVer() > 18 then
			(
			mergeMAXFile sALEnvFiles[sALAssetFileIndex] #mergeDups #useSceneMtlDups #neverReparent quiet:true mergedNodes:&theMergedObjs
			)
		else
			(
			handles = #()
			for i in $* do (append handles i.inode.handle)
			if handles.count == 0 then myMaxhandle = 0 else myMaxhandle = amax handles
			mergeMAXFile sALEnvFiles[sALAssetFileIndex] #mergeDups #useSceneMtlDups #neverReparent quiet:true
			theMergedObjs = (for o in $* where o.inode.handle > myMaxhandle collect o)
			)
		
		-- Add To Layer
		if LayerManager.getLayerFromName "_EnvSAL" == undefined then layermanager.newLayerFromName "_EnvSAL"
		myLayer = LayerManager.getLayerFromName "_EnvSAL"
		for obj in theMergedObjs do myLayer.addnode obj

		-- Add prefix
		if sALEnvAddEnvPrefix == true then
			(
			for i in theMergedObjs do
				(
				pre = (getFilenameFile (sALEnvFiles[sALAssetFileIndex]))
				if classof pre == String then 
					(
					i.name = pre + "_" + i.name
					)
				)
			)

		-- Vray check
		vrayyes = false
		for i in theMergedObjs do (if (findString ((classof i) as string) "Vray") != undefined then vrayyes = true)
		if vrayyes == true then
			(
			if (sLibCompareArrays renderers.current.classid #(1941615238, 2012806412)) == false then
				(
				if (sLibCompareArrays renderers.current.classid #(1770671000, 1323107829)) == false then
					(
					MessageBox "You appear to be loading vray assets but don't have vray set as your renderer. Please set vray as your renderer to get the assets to function properly." title:"soulburnAssetLoader"
					)
				)
			)
			
		-- Vray Visibility
		for obj in theMergedObjs do
			(
			if classof obj == VRayLight then
				(
				if sALEnvVisibility == 2 then obj.invisible = off
				else if sALEnvVisibility == 3 then obj.invisible = on
				)
			)

		-- Place env map in env slot
		if sALEnvPlaceEnvMap == true then
			(
			for obj in theMergedObjs do
				(
				if classof obj == VRayLight then
					(
					if obj.texmap != undefined then
						(
						environmentMap = obj.texmap
						)
					)
				)
			)
			
		-- delete cams
		toDelete = #()
		if sALEnvIgnoreCam == true then (for i in theMergedObjs do (if (superclassof i) == camera then append toDelete i))
		undo "soulburnAssetLoader" on (for obj in toDelete do (try (delete obj) catch ()))
		
		-- select old selection
		try (select oldSelection) catch ()
		)
	else if sALAssetType == 2 then
		(
		-- get current selection
		oldSelection = for i in selection collect i

		-- merge new material
		if sLibMaxVer() > 18 then
			(
			mergeMAXFile sALMatFiles[sALAssetFileIndex] #noRedraw #mergeDups #promptMtlDups #neverReparent quiet:true mergedNodes:&theMergedObjs
			)
		else
			(
			handles = #()
			for i in $* do (append handles i.inode.handle)
			if handles.count == 0 then myMaxhandle = 0 else myMaxhandle = amax handles		
			mergeMAXFile sALMatFiles[sALAssetFileIndex] #noRedraw #mergeDups #promptMtlDups #neverReparent quiet:true
			theMergedObjs = (for o in $* where o.inode.handle > myMaxhandle collect o)
			)
		
		-- Get Material
		if theMergedObjs.count !=0 then 
			(
			theMergedGeom = #()
			for i in theMergedObjs do (if superclassof i == GeometryClass then append theMergedGeom i)
			mat = theMergedGeom[1].material
			)

		-- Apply material
		if mat != undefined then
			(
			if sALMatMeditCurSlot == true then 
				(
				if sALMatMeditLocation == 1 then meditMaterials[(medit.GetActiveMtlSlot())] = mat
				else
					(
					if (sme.IsOpen()) == false then (sme.Open())
					CurrentSMEView = sme.getView (sme.activeView)
					CurrentSMEView.CreateNode mat [0,0]	
					)
				)
			if sALMatSelObjs == true then (for i in oldSelection do i.material = mat)
			)

		-- Delete temp object
		for obj in theMergedObjs do (try (delete obj) catch ())
			
		-- Vray check
		vrayyes = false
		for i in selection do
			(
			if (findString ((classof i.material) as string) "Vray") != undefined then vrayyes = true
			)
		if vrayyes == true then
			(
			if (sLibCompareArrays renderers.current.classid #(1941615238, 2012806412)) == false then
				(
				if (sLibCompareArrays renderers.current.classid #(1770671000, 1323107829)) == false then
					(
					MessageBox "You appear to be loading vray assets but don't have vray set as your renderer. Please set vray as your renderer to get the assets to function properly." title:"soulburnAssetLoader"
					)
				)
			)

		-- Scene redraw
		enableSceneRedraw()
		completeRedraw()

		-- select old selection
		select oldSelection
		)
	else if sALAssetType == 3 then
		(
		-- get current selection
		a = sLibGetCollectionBBoxCenter selection
		
		-- merge new objects
		
		-- merge new material
		if sLibMaxVer() > 18 then
			(
			mergeMAXFile sALModelFiles[sALAssetFileIndex] #mergeDups #useSceneMtlDups #neverReparent quiet:true mergedNodes:&theMergedObjs
			)
		else
			(
			handles = #()
			for i in $* do (append handles i.inode.handle)
			if handles.count == 0 then myMaxhandle = 0 else myMaxhandle = amax handles
			mergeMAXFile sALModelFiles[sALAssetFileIndex] #mergeDups #useSceneMtlDups #neverReparent quiet:true
			theMergedObjs = (for o in $* where o.inode.handle > myMaxhandle collect o)
			)		
		
		-- align objects
		if sALModelAlign == true then
			(
			-- Remove group members from selection		
			noGroupMembers = #()
			for i in theMergedObjs do (if isGroupMember i == false then append noGroupMembers i)
			for i in noGroupMembers do i.pos = a
			)		
		
		-- put on proper layer
		if sALModelMergeInto == 1 then
			(
			)
		else if sALModelMergeInto == 2 then
			(
			for obj in theMergedObjs do (LayerManager.current).addnode obj
			)
		else if sALModelMergeInto == 3 then
			(
			l = LayerManager.newLayer()
			for obj in theMergedObjs do l.addnode obj
			)
		
		-- select new selection
		select theMergedObjs
		
		-- rename objects
		if sALModelUniqueNames == true then
			(
			for obj in theMergedObjs do obj.name = Uniquename (obj.name)
			)

		-- delete cams and lights
		toDelete = #()
		if sALModelIgnoreCam == true then
			(
			for i in theMergedObjs do (if (superclassof i) == camera then append toDelete i)
			)
		if sALModelIgnoreLight == true then
			(
			for i in theMergedObjs do (if (superclassof i) == light then append toDelete i)
			)
		undo "soulburnAssetLoader" on (for obj in toDelete do (try (delete obj) catch ()))
		)
	else if sALAssetType == 4 then
		(
		mytexture = sALTexFiles[sALAssetFileIndex]
		mytexturename = getFilenameFile mytexture
		mybitdepth = sLibGetImageBitDepth mytexture
		
		if sALTexMapType == 1 then
			(
			Tex = Bitmaptexture fileName:mytexture name:mytexturename
			)
		else
			(
			if sLibVrayTest() == true then 
				(
				Tex = VRayHDRI HDRIMapName:mytexture name:mytexturename
				Tex.color_space = 3
				if mybitdepth == 8 or mybitdepth == 16 then Tex.gamma = 0.455
				)
			else 
				(
				MessageBox "You don't seem to have Vray installed, and so you can't create a VrayHDRI map. Using default instead." title:"soulburnAssetLoader"
				Tex = Bitmaptexture fileName:mytexture name:mytexturename
				)
			)

		if sALTexMeditLocation == 1 then meditMaterials[(medit.GetActiveMtlSlot())] = Tex
		else
			(
			if (sme.IsOpen()) == false then (sme.Open())
			CurrentSMEView = sme.getView (sme.activeView)
			CurrentSMEView.CreateNode Tex [0,0]
			)
		)
	else if sALAssetType == 5 then
		(
		-- get current selection
		oldSelection = for i in selection collect i

		-- merge new TexMaperial
		if sLibMaxVer() > 18 then
			(
			mergeMAXFile sALTexMapFiles[sALAssetFileIndex] #noRedraw #mergeDups #promptMtlDups #neverReparent quiet:true mergedNodes:&theMergedObjs
			)
		else
			(
			handles = #()
			for i in $* do (append handles i.inode.handle)
			if handles.count == 0 then myMaxhandle = 0 else myMaxhandle = amax handles		
			mergeMAXFile sALTexMapFiles[sALAssetFileIndex] #noRedraw #mergeDups #promptMtlDups #neverReparent quiet:true
			theMergedObjs = (for o in $* where o.inode.handle > myMaxhandle collect o)
			)
		
		-- Get TexMap
		if theMergedObjs.count !=0 then 
			(
			theMergedGeom = #()
			for i in theMergedObjs do (if superclassof i == GeometryClass then append theMergedGeom i)
			Mat = theMergedGeom[1].Material
			if (classof Mat) == Standardmaterial then TexMap = Mat.diffuseMap
			else if (classof Mat) == VRayMtl then TexMap = Mat.texmap_diffuse
			)

		-- Apply TexMaperial
		if TexMap != undefined then
			(
			if sALTexMapMeditLocation == 1 then meditMaterials[(medit.GetActiveMtlSlot())] = TexMap
			else
				(
				if (sme.IsOpen()) == false then (sme.Open())
				CurrentSMEView = sme.getView (sme.activeView)
				CurrentSMEView.CreateNode TexMap [0,0]	
				)
			)

		-- Delete temp object
		for obj in theMergedObjs do (try (delete obj) catch ())
			
		-- Vray check
		vrayyes = false
		if (findString ((classof TexMap) as string) "Vray") != undefined then vrayyes = true
		if vrayyes == true then
			(
			if (sLibCompareArrays renderers.current.classid #(1941615238, 2012806412)) == false then
				(
				if (sLibCompareArrays renderers.current.classid #(1770671000, 1323107829)) == false then
					(
					MessageBox "You appear to be loading vray assets but don't have vray set as your renderer. Please set vray as your renderer to get the assets to function properly." title:"soulburnAssetLoader"
					)
				)
			)

		-- Scene redraw
		enableSceneRedraw()
		completeRedraw()

		-- select old selection
		select oldSelection
		)
	)
	
fn soulburnAssetLoaderDefaults = 
	(
	sALLoadDef()
	)
	
fn soulburnAssetLoaderUI = 
	(
	sALLoadDef()
	sALCloseOpenUI sALPosValue sALSizeValue
	)
	
fn sALShouldIRemakeIcon iconfile width = 
	(
	if (doesFileExist iconfile) == false then return true
	else
		(
		b = openBitmap iconfile
		newwidth = b.width
		close b
		free b
		if newwidth == width then return false
		else return true
		)
	)
	
fn sALDeleteAllIcons = 
	(
	tempEnvFiles = (sLibGetAllFilesInDir sALEnvDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALEnvDirExtraValue sALRecurseSubdirsValue "max")
	tempMatFiles = (sLibGetAllFilesInDir sALMatDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALMatDirExtraValue sALRecurseSubdirsValue "max")
	tempModelFiles = (sLibGetAllFilesInDir sALModelDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALModelDirExtraValue sALRecurseSubdirsValue "max")
	tempTexFiles = (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "png") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "png") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "tif") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "tif") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "exr") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "exr") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "tiff") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "tiff") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "hdr") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "hdr")
	tempTexMapFiles = (sLibGetAllFilesInDir sALTexMapDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALTexMapDirExtraValue sALRecurseSubdirsValue "max")
	tempfiles = tempEnvFiles + tempMatFiles + tempModelFiles + tempTexFiles + tempTexMapFiles
	for i in tempfiles do
		(
		myimage1 = replace i (i.count-3) 4 "_Icon.jpg"
		deleteFile myimage1
		)
	)

fn sALIconXPos val = 
	(
	((val*(sALIconSizeValue+1))-sALIconSizeValue)-(((ceil((val-1)/sALIconsAcrossValue))*(sALIconSizeValue+1))*sALIconsAcrossValue)
	)

fn sALIconYPos val = 
	(
	((ceil((val-1)/sALIconsAcrossValue))*(sALIconSizeValue+1))+26
	)

fn sALInstallAsset sALWizardAssetType sALWizardCategory sALWizardName sALWizardGetIconFile = 
	(
	if sALWizardAssetType == 1 then
		(
		if selection.count != 0 then
			(
			filename = sALEnvDirValue + sALWizardCategory + "_" + sALWizardName
			if (sLibFileExist (filename + ".max")) then 
				(
				if (queryBox "Overwrite Existing File?" title:"soulburnAssetLoader") == false then return false
				)
			deleteFile (filename + ".max")
			deleteFile (filename + ".png")
			deleteFile (filename + "_Icon.jpg")
			saveNodes $ (filename + ".max") quiet:true
			copyFile sALWizardGetIconFile (filename + ".png")
			)
		else MessageBox "Please select at least one object to make an Asset." title:"soulburnAssetLoader"
		)
	else if sALWizardAssetType == 2 then
		(
		filename = sALMatDirValue + sALWizardCategory + "_" + sALWizardName
		oldSelection = for i in selection collect i
		mymat = meditMaterials[(medit.GetActiveMtlSlot())]
		if superclassof mymat != material then MessageBox "The current selected Medit Slot is not a material. Please choose a slot that contains a material." title:"soulburnAssetLoader"
		else
			(
			if (sLibFileExist (filename + ".max")) then 
				(
				if (queryBox "Overwrite Existing File?" title:"soulburnAssetLoader") == false then return false
				)
			myobj = teapot()
			myobj.material = mymat
			select myobj
			deleteFile (filename + ".max")
			deleteFile (filename + ".png")
			deleteFile (filename + "_Icon.jpg")
			saveNodes $ (filename + ".max") quiet:true
			copyFile sALWizardGetIconFile (filename + ".png")
			delete myobj
			select oldSelection
			)
		)
	else if sALWizardAssetType == 3 then
		(
		filename = sALTexMapDirValue + sALWizardCategory + "_" + sALWizardName
		oldSelection = for i in selection collect i
		mymap = meditMaterials[(medit.GetActiveMtlSlot())]
		if superclassof mymap != textureMap then MessageBox "The current selected Medit Slot is not a TexMap. Please choose a slot that contains a TexMap." title:"soulburnAssetLoader"
		else
			(
			if (sLibFileExist (filename + ".max")) then 
				(
				if (queryBox "Overwrite Existing File?" title:"soulburnAssetLoader") == false then return false
				)
			myobj = teapot()
			mymat = Standard()
			mymat.diffuseMap = mymap
			myobj.material = mymat
			select myobj
			deleteFile (filename + ".max")
			deleteFile (filename + ".png")
			deleteFile (filename + "_Icon.jpg")
			saveNodes $ (filename + ".max") quiet:true
			copyFile sALWizardGetIconFile (filename + ".png")
			delete myobj
			select oldSelection
			)
		)
	else if sALWizardAssetType == 4 then
		(
		if selection.count != 0 then
			(
			filename = sALModelDirValue + sALWizardCategory + "_" + sALWizardName
			if (sLibFileExist (filename + ".max")) then 
				(
				if (queryBox "Overwrite Existing File?" title:"soulburnAssetLoader") == false then return false
				)
			deleteFile (filename + ".max")
			deleteFile (filename + ".png")
			deleteFile (filename + "_Icon.jpg")
			saveNodes $ (filename + ".max") quiet:true
			copyFile sALWizardGetIconFile (filename + ".png")
			)
		else MessageBox "Please select at least one object to make an Asset." title:"soulburnAssetLoader"
		)
	sALCloseOpenUI sALPosValue sALSizeValue
	)
	
fn sALDockMe input = 
	(
	if input == 1 then
		(
		cui.RegisterDialogBar sALFloater style:#(#cui_dock_all, #cui_floatable, #cui_handles)
		cui.DockDialogBar sALFloater #cui_dock_left
		)
	else if input == 2 then
		(
		cui.RegisterDialogBar sALFloater style:#(#cui_dock_all, #cui_floatable, #cui_handles)
		cui.DockDialogBar sALFloater #cui_dock_right
		)
	else if input == 3 then
		(
		cui.RegisterDialogBar sALFloater style:#(#cui_dock_all, #cui_floatable, #cui_handles)
		cui.DockDialogBar sALFloater #cui_dock_top
		)
	else if input == 4 then
		(
		cui.RegisterDialogBar sALFloater style:#(#cui_dock_all, #cui_floatable, #cui_handles)
		cui.DockDialogBar sALFloater #cui_dock_bottom
		)
	else if input == 5 then
		(
		cui.FloatDialogBar sALFloater 
		cui.UnRegisterDialogBar sALFloater 
		)	
	)

fn sALCloseOpenUI pos siz = 
	(
	if sALFloater != undefined and sALFloater.dialogBar == true then cui.UnRegisterDialogBar sALFloater 
	if sALFloater != undefined then CloseRolloutFloater sALFloater
	pushPrompt "Updating soulburnAssetLoader UI"
	sALDefineUI()

	-- Prep Arrays
	sALEnvFiles = #()
	sALMatFiles = #()
	sALModelFiles = #()
	sALTexFiles = #()
	sALTexMapFiles = #()
	
	sALEnvCategories = #("All")
	sALMatCategories = #("All")
	sALModelCategories = #("All")
	sALTexCategories = #("All")
	sALTexMapCategories = #("All")

	tempEnvFiles = #()
	tempMatFiles = #()
	tempModelFiles = #()
	tempTexFiles = #()
	tempTexMapFiles = #()
	temp2EnvFiles = #()
	temp2MatFiles = #()
	temp2ModelFiles = #()
	temp2TexFiles = #()
	temp2TexMapFiles = #()
	temp3EnvFiles = #()
	temp3MatFiles = #()
	temp3ModelFiles = #()
	temp3TexFiles = #()
	temp3TexMapFiles = #()
	temp4EnvFiles = #()
	temp4MatFiles = #()
	temp4ModelFiles = #()
	temp4TexFiles = #()
	temp4TexMapFiles = #()
	
	tempEnvCategories = #()
	tempMatCategories = #()
	tempModelCategories = #()
	tempTexCategories = #()
	tempTexMapCategories = #()
	
	-- Find Blank Default Icon
	sALDefaultImage = ((getdir #scripts) + "\\SoulburnScripts\\images\\" + "sALDefault.png")

	-- Make File Arrays
	tempEnvFiles = sort ((sLibGetAllFilesInDir sALEnvDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALEnvDirExtraValue sALRecurseSubdirsValue "max"))
	tempMatFiles = sort ((sLibGetAllFilesInDir sALMatDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALMatDirExtraValue sALRecurseSubdirsValue "max"))
	tempModelFiles = sort ((sLibGetAllFilesInDir sALModelDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALModelDirExtraValue sALRecurseSubdirsValue "max"))
	tempTexFiles = sort ((sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "png") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "png") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "tif") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "tif") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "exr") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "exr") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "tiff") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "tiff") + (sLibGetAllFilesInDir sALTexDirValue sALRecurseSubdirsValue "hdr") + (sLibGetAllFilesInDir sALTexDirExtraValue sALRecurseSubdirsValue "hdr"))
	tempTexMapFiles = sort ((sLibGetAllFilesInDir sALTexMapDirValue sALRecurseSubdirsValue "max") + (sLibGetAllFilesInDir sALTexMapDirExtraValue sALRecurseSubdirsValue "max"))

	-- Remove Ignored Files
	for i in tempEnvFiles do (if (substring (sLibFilenameFromPath i) 1 7) != sALIgnoreValue then append temp2EnvFiles i)
	for i in tempMatFiles do (if (substring (sLibFilenameFromPath i) 1 7) != sALIgnoreValue then append temp2MatFiles i)
	for i in tempModelFiles do (if (substring (sLibFilenameFromPath i) 1 7) != sALIgnoreValue then append temp2ModelFiles i)
	for i in tempTexFiles do (if (substring (sLibFilenameFromPath i) 1 7) != sALIgnoreValue then append temp2TexFiles i)
	for i in tempTexMapFiles do (if (substring (sLibFilenameFromPath i) 1 7) != sALIgnoreValue then append temp2TexMapFiles i)
	
	-- Make Catgeory Arrays
	for i in temp2EnvFiles do 
		(
		if (findString (sLibFilenameFromPath i) "_") != undefined then append tempEnvCategories (filterString (sLibFilenameFromPath i) "_")[1]
		)
	for i in temp2MatFiles do 
		(
		if (findString (sLibFilenameFromPath i) "_") != undefined then append tempMatCategories (filterString (sLibFilenameFromPath i) "_")[1]
		)
	for i in temp2ModelFiles do 
		(
		if (findString (sLibFilenameFromPath i) "_") != undefined then append tempModelCategories (filterString (sLibFilenameFromPath i) "_")[1]
		)
	for i in temp2TexFiles do 
		(
		if (findString (sLibFilenameFromPath i) "_") != undefined then append tempTexCategories (filterString (sLibFilenameFromPath i) "_")[1]
		)
	for i in temp2TexMapFiles do 
		(
		if (findString (sLibFilenameFromPath i) "_") != undefined then append tempTexMapCategories (filterString (sLibFilenameFromPath i) "_")[1]
		)
	for i in (sLibTrimDups tempEnvCategories) do append sALEnvCategories i
	for i in (sLibTrimDups tempMatCategories) do append sALMatCategories i
	for i in (sLibTrimDups tempModelCategories) do append sALModelCategories i
	for i in (sLibTrimDups tempTexCategories) do append sALTexCategories i
	for i in (sLibTrimDups tempTexMapCategories) do append sALTexMapCategories i

	-- Set Category Index
	if sALEnvCategoryIndexValue > sALEnvCategories.count then sALEnvCategoryIndexValue = 1
	if sALMatCategoryIndexValue > sALMatCategories.count then sALMatCategoryIndexValue = 1
	if sALModelCategoryIndexValue > sALModelCategories.count then sALModelCategoryIndexValue = 1
	if sALTexCategoryIndexValue > sALTexCategories.count then sALTexCategoryIndexValue = 1
	if sALTexMapCategoryIndexValue > sALTexMapCategories.count then sALTexMapCategoryIndexValue = 1
	
	-- Sort Categories
	sort sALEnvCategories
	sort sALMatCategories
	sort sALModelCategories
	sort sALTexCategories
	sort sALTexMapCategories
	
	-- Filter Asset by Category
	if sALEnvCategoryIndexValue == 1 then temp3EnvFiles = temp2EnvFiles
	else (for i in temp2EnvFiles do (if (filterString (sLibFilenameFromPath i) "_")[1] == sALEnvCategories[sALEnvCategoryIndexValue] then append temp3EnvFiles i))
	if sALMatCategoryIndexValue == 1 then temp3MatFiles = temp2MatFiles
	else (for i in temp2MatFiles do (if (filterString (sLibFilenameFromPath i) "_")[1] == sALMatCategories[sALMatCategoryIndexValue] then append temp3MatFiles i))
	if sALModelCategoryIndexValue == 1 then temp3ModelFiles = temp2ModelFiles
	else (for i in temp2ModelFiles do (if (filterString (sLibFilenameFromPath i) "_")[1] == sALModelCategories[sALModelCategoryIndexValue] then append temp3ModelFiles i))
	if sALTexCategoryIndexValue == 1 then temp3TexFiles = temp2TexFiles
	else (for i in temp2TexFiles do (if (filterString (sLibFilenameFromPath i) "_")[1] == sALTexCategories[sALTexCategoryIndexValue] then append temp3TexFiles i))
	if sALTexMapCategoryIndexValue == 1 then temp3TexMapFiles = temp2TexMapFiles
	else (for i in temp2TexMapFiles do (if (filterString (sLibFilenameFromPath i) "_")[1] == sALTexMapCategories[sALTexMapCategoryIndexValue] then append temp3TexMapFiles i))

	-- Filter Asset by Wildcard
	if sALEnvFilterValue == "" then temp4EnvFiles = temp3EnvFiles
	else (for i in temp3EnvFiles do (if (findstring (sLibFilenameFromPath i) sALEnvFilterValue) != undefined then append temp4EnvFiles i))
	if sALMatFilterValue == "" then temp4MatFiles = temp3MatFiles
	else (for i in temp3MatFiles do (if (findstring (sLibFilenameFromPath i) sALMatFilterValue) != undefined then append temp4MatFiles i))
	if sALModelFilterValue == "" then temp4ModelFiles = temp3ModelFiles
	else (for i in temp3ModelFiles do (if (findstring (sLibFilenameFromPath i) sALModelFilterValue) != undefined then append temp4ModelFiles i))
	if sALTexFilterValue == "" then temp4TexFiles = temp3TexFiles
	else (for i in temp3TexFiles do (if (findstring (sLibFilenameFromPath i) sALTexFilterValue) != undefined then append temp4TexFiles i))
	if sALTexMapFilterValue == "" then temp4TexMapFiles = temp3TexMapFiles
	else (for i in temp3TexMapFiles do (if (findstring (sLibFilenameFromPath i) sALTexMapFilterValue) != undefined then append temp4TexMapFiles i))

	-- Sort Asset Arrays By Filename, Not Filepath
	qsort temp4EnvFiles sLibFileNameCompareCaseSensitive
	qsort temp4MatFiles sLibFileNameCompareCaseSensitive
	qsort temp4ModelFiles sLibFileNameCompareCaseSensitive
	qsort temp4TexFiles sLibFileNameCompareCaseSensitive
	qsort temp4TexMapFiles sLibFileNameCompareCaseSensitive
	
	-- Final Asset Arrays
	sALEnvFiles = temp4EnvFiles
	sALMatFiles = temp4MatFiles
	sALModelFiles = temp4ModelFiles
	sALTexFiles = temp4TexFiles
	sALTexMapFiles = temp4TexMapFiles
	
	-- Create Env UI
	freeSceneBitmaps()
	gc()
	rci = rolloutCreator "sALEnvRollout" "Environments"
	rci.begin()
	
	rci.addControl #dropdownlist #sALEnvCategoriesDropdown "" paramStr:("items: " + (with printAllElements on (sALEnvCategories as string)) + " selection: " + (sALEnvCategoryIndexValue as string) + " pos:[1,2] width:100")
	-- had to add an extra space after paramStr:"i to avoid the bug fixed in 1.02
	rci.addHandler #sALEnvCategoriesDropdown #selected paramStr:"i " codeStr:("sALEnvCategoryIndexValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")

	rci.addControl #edittext #sALEnvFilterEditText "" paramStr:("text:" + "sALEnvFilterValue" + " pos:[102,4] width:150")
	rci.addHandler #sALEnvFilterEditText #entered paramStr:"i " codeStr:("sALEnvFilterValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")
	
	if sALEnvFiles.count !=0 then
		(
		for i = 1 to sALEnvFiles.count do
			(
			myimage1 = replace sALEnvFiles[i] (sALEnvFiles[i].count-3) 4 "_Icon.jpg"
			-- Create Icons
			if (sALShouldIRemakeIcon myimage1 sALIconSizeValue) == true then
				(
				highresimage = replace sALEnvFiles[i] (sALEnvFiles[i].count-3) 4 ".png"
				if (doesFileExist highresimage) == true then sLibResizeImageByPixelsFilter #(highresimage) (getFilenamePath highresimage) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				)
						
			-- Put Icons in rollout
			if (doesFileExist myimage1) == false then 
				(
				sLibResizeImageByPixelsFilter #(sALDefaultImage) (getFilenamePath myimage1) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				renameFile ((getFilenamePath myimage1)+"sALDefault_Icon.jpg") myimage1
				)
			iconimage1 = sLibAddExtraBackslashesToFilename myimage1
			rci.addControl #imgtag (("buttonA"+(i as string)) as name) ((sLibStripFileExtension (sLibFilenameFromPath sALEnvFiles[i])) as string) paramStr:("transparent: (color 257 257 257) bitmap:(openbitmap " + "\"" + iconimage1 + "\"" + ")" + " toolTip:"+"\""+((sLibStripFileExtension (sLibFilenameFromPath sALEnvFiles[i])) as string)+"\""+" pos:["+((sALIconXPos i) as string)+","+((sALIconYPos i) as string)+"]")
			rci.addHandler (("buttonA"+(i as string)) as name) #click filter:on codeStr:("soulburnAssetLoader sALEnvDeleteOldValue sALEnvIgnoreCamValue sALEnvVisibilityValue sALEnvPlaceEnvMapValue sALEnvAddEnvPrefixValue sALMatMeditCurSlotValue sALMatMeditLocationValue sALMatSelObjsValue sALModelAlignValue sALModelToCurrentLayerValue sALModelIgnoreCamValue sALModelIgnoreLightValue sALModelUniqueNamesValue sALModelMergeIntoValue sALTexMeditLocationValue sALTexMapTypeValue sALTexMapMeditLocationValue 1 " + (i as string))
			)
		)
	rci.end()
	
	-- Create Materials UI
	freeSceneBitmaps()
	gc()
	rci = rolloutCreator "sALMatRollout" "Materials"
	rci.begin()
	
	rci.addControl #dropdownlist #sALMatCategoriesDropdown "" paramStr:("items: " + (with printAllElements on (sALMatCategories as string)) + " selection: " + (sALMatCategoryIndexValue as string) + " pos:[1,2] width:100")
	-- had to add an extra space after paramStr:"i to avoid the bug fixed in 1.02
	rci.addHandler #sALMatCategoriesDropdown #selected paramStr:"i " codeStr:("sALMatCategoryIndexValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")

	rci.addControl #edittext #sALMatFilterEditText "" paramStr:("text:" + "sALMatFilterValue" + " pos:[102,4] width:150")
	rci.addHandler #sALMatFilterEditText #entered paramStr:"i " codeStr:("sALMatFilterValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")
	
	if sALMatFiles.count !=0 then
		(
		for i = 1 to sALMatFiles.count do
			(
			myimage2 = replace sALMatFiles[i] (sALMatFiles[i].count-3) 4 "_Icon.jpg"
			-- Create Icons
			if (sALShouldIRemakeIcon myimage2 sALIconSizeValue) == true then
				(
				highresimage = replace sALMatFiles[i] (sALMatFiles[i].count-3) 4 ".png"
				if (doesFileExist highresimage) == true then sLibResizeImageByPixelsFilter #(highresimage) (getFilenamePath highresimage) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				)
						
			-- Put Icons in rollout
			if (doesFileExist myimage2) == false then 
				(
				sLibResizeImageByPixelsFilter #(sALDefaultImage) (getFilenamePath myimage2) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				renameFile ((getFilenamePath myimage2)+"sALDefault_Icon.jpg") myimage2
				)
			iconimage2 = sLibAddExtraBackslashesToFilename myimage2
			rci.addControl #imgtag (("buttonB"+(i as string)) as name) ((sLibStripFileExtension (sLibFilenameFromPath sALMatFiles[i])) as string) paramStr:("transparent: (color 257 257 257) bitmap:(openbitmap " + "\"" + iconimage2 + "\"" + ")" + " toolTip:"+"\""+((sLibStripFileExtension (sLibFilenameFromPath sALMatFiles[i])) as string)+"\""+" pos:["+((sALIconXPos i) as string)+","+((sALIconYPos i) as string)+"]")
			rci.addHandler (("buttonB"+(i as string)) as name) #click filter:on codeStr:("soulburnAssetLoader sALEnvDeleteOldValue sALEnvIgnoreCamValue sALEnvVisibilityValue sALEnvPlaceEnvMapValue sALEnvAddEnvPrefixValue sALMatMeditCurSlotValue sALMatMeditLocationValue sALMatSelObjsValue sALModelAlignValue sALModelToCurrentLayerValue sALModelIgnoreCamValue sALModelIgnoreLightValue sALModelUniqueNamesValue sALModelMergeIntoValue sALTexMeditLocationValue sALTexMapTypeValue sALTexMapMeditLocationValue 2 " + (i as string))
			)
		)
	rci.end()

	-- Create Models UI
	freeSceneBitmaps()
	gc()
	rci = rolloutCreator "sALModelRollout" "Models"
	rci.begin()
	
	rci.addControl #dropdownlist #sALModelCategoriesDropdown "" paramStr:("items: " + (with printAllElements on (sALModelCategories as string)) + " selection: " + (sALModelCategoryIndexValue as string) + " pos:[1,2] width:100")
	-- had to add an extra space after paramStr:"i to avoid the bug fixed in 1.02
	rci.addHandler #sALModelCategoriesDropdown #selected paramStr:"i " codeStr:("sALModelCategoryIndexValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")

	rci.addControl #edittext #sALModelFilterEditText "" paramStr:("text:" + "sALModelFilterValue" + " pos:[102,4] width:150")
	rci.addHandler #sALModelFilterEditText #entered paramStr:"i " codeStr:("sALModelFilterValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")
	
	if sALModelFiles.count !=0 then
		(
		for i = 1 to sALModelFiles.count do
			(
			myimage3 = replace sALModelFiles[i] (sALModelFiles[i].count-3) 4 "_Icon.jpg"
			-- Create Icons
			if (sALShouldIRemakeIcon myimage3 sALIconSizeValue) == true then
				(
				highresimage = replace sALModelFiles[i] (sALModelFiles[i].count-3) 4 ".png"
				if (doesFileExist highresimage) == true then sLibResizeImageByPixelsFilter #(highresimage) (getFilenamePath highresimage) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				)
						
			-- Put Icons in rollout
			if (doesFileExist myimage3) == false then 
				(
				sLibResizeImageByPixelsFilter #(sALDefaultImage) (getFilenamePath myimage3) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				renameFile ((getFilenamePath myimage3)+"sALDefault_Icon.jpg") myimage3
				)
			iconimage3 = sLibAddExtraBackslashesToFilename myimage3
			rci.addControl #imgtag (("buttonB"+(i as string)) as name) ((sLibStripFileExtension (sLibFilenameFromPath sALModelFiles[i])) as string) paramStr:("transparent: (color 257 257 257) bitmap:(openbitmap " + "\"" + iconimage3 + "\"" + ")" + " toolTip:"+"\""+((sLibStripFileExtension (sLibFilenameFromPath sALModelFiles[i])) as string)+"\""+" pos:["+((sALIconXPos i) as string)+","+((sALIconYPos i) as string)+"]")
			rci.addHandler (("buttonB"+(i as string)) as name) #click filter:on codeStr:("soulburnAssetLoader sALEnvDeleteOldValue sALEnvIgnoreCamValue sALEnvVisibilityValue sALEnvPlaceEnvMapValue sALEnvAddEnvPrefixValue sALMatMeditCurSlotValue sALMatMeditLocationValue sALMatSelObjsValue sALModelAlignValue sALModelToCurrentLayerValue sALModelIgnoreCamValue sALModelIgnoreLightValue sALModelUniqueNamesValue sALModelMergeIntoValue sALTexMeditLocationValue sALTexMapTypeValue sALTexMapMeditLocationValue 3 " + (i as string))
			)
		)
	rci.end()
	
	-- Create Textures UI
	freeSceneBitmaps()
	gc()
	rci = rolloutCreator "sALTexRollout" "Textures"
	rci.begin()
	
	rci.addControl #dropdownlist #sALTexCategoriesDropdown "" paramStr:("items: " + (with printAllElements on (sALTexCategories as string)) + " selection: " + (sALTexCategoryIndexValue as string) + " pos:[1,2] width:100")
	-- had to add an extra space after paramStr:"i to avoid the bug fixed in 1.02
	rci.addHandler #sALTexCategoriesDropdown #selected paramStr:"i " codeStr:("sALTexCategoryIndexValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")

	rci.addControl #edittext #sALTexFilterEditText "" paramStr:("text:" + "sALTexFilterValue" + " pos:[102,4] width:150")
	rci.addHandler #sALTexFilterEditText #entered paramStr:"i " codeStr:("sALTexFilterValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")
	
	if sALTexFiles.count !=0 then
		(
		for i = 1 to sALTexFiles.count do
			(
			myimage4 = replace sALTexFiles[i] (sALTexFiles[i].count-3) 4 "_Icon.jpg"
			-- Create Icons
			if (sALShouldIRemakeIcon myimage4 sALIconSizeValue) == true then
				(
				highresimage = sALTexFiles[i]
				if (doesFileExist highresimage) == true then sLibResizeImageByPixelsFilter #(highresimage) (getFilenamePath highresimage) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				)
						
			-- Put Icons in rollout
			if (doesFileExist myimage4) == false then 
				(
				sLibResizeImageByPixelsFilter #(sALDefaultImage) (getFilenamePath myimage4) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				renameFile ((getFilenamePath myimage4)+"sALDefault_Icon.jpg") myimage4
				)
			iconimage4 = sLibAddExtraBackslashesToFilename myimage4
			rci.addControl #imgtag (("buttonB"+(i as string)) as name) ((sLibStripFileExtension (sLibFilenameFromPath sALTexFiles[i])) as string) paramStr:("transparent: (color 257 257 257) bitmap:(openbitmap " + "\"" + iconimage4 + "\"" + ")" + " toolTip:"+"\""+((sLibStripFileExtension (sLibFilenameFromPath sALTexFiles[i])) as string)+"\""+" pos:["+((sALIconXPos i) as string)+","+((sALIconYPos i) as string)+"]")
			rci.addHandler (("buttonB"+(i as string)) as name) #click filter:on codeStr:("soulburnAssetLoader sALEnvDeleteOldValue sALEnvIgnoreCamValue sALEnvVisibilityValue sALEnvPlaceEnvMapValue sALEnvAddEnvPrefixValue sALMatMeditCurSlotValue sALMatMeditLocationValue sALMatSelObjsValue sALModelAlignValue sALModelToCurrentLayerValue sALModelIgnoreCamValue sALModelIgnoreLightValue sALModelUniqueNamesValue sALModelMergeIntoValue sALTexMeditLocationValue sALTexMapTypeValue sALTexMapMeditLocationValue 4 " + (i as string))
			)
		)
	rci.end()

	-- Create TexMap UI
	freeSceneBitmaps()
	gc()
	rci = rolloutCreator "sALTexMapRollout" "TexMaps"
	rci.begin()
	
	rci.addControl #dropdownlist #sALTexMapCategoriesDropdown "" paramStr:("items: " + (with printAllElements on (sALTexMapCategories as string)) + " selection: " + (sALTexMapCategoryIndexValue as string) + " pos:[1,2] width:100")
	-- had to add an extra space after paramStr:"i to avoid the bug fixed in 1.02
	rci.addHandler #sALTexMapCategoriesDropdown #selected paramStr:"i " codeStr:("sALTexMapCategoryIndexValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")

	rci.addControl #editText #sALTexMapFilterEditTexMapt "" paramStr:("Text:" + "sALTexMapFilterValue" + " pos:[102,4] width:150")
	rci.addHandler #sALTexMapFilterEditText #entered paramStr:"i " codeStr:("sALTexMapFilterValue = i;sALCloseOpenUI sALFloater.pos sALFloater.size")
	
	if sALTexMapFiles.count !=0 then
		(
		for i = 1 to sALTexMapFiles.count do
			(
			myimage5 = replace sALTexMapFiles[i] (sALTexMapFiles[i].count-3) 4 "_Icon.jpg"
			-- Create Icons
			if (sALShouldIRemakeIcon myimage5 sALIconSizeValue) == true then
				(
				highresimage = replace sALTexMapFiles[i] (sALTexMapFiles[i].count-3) 4 ".png"
				if (doesFileExist highresimage) == true then sLibResizeImageByPixelsFilter #(highresimage) (getFilenamePath highresimage) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				)
						
			-- Put Icons in rollout
			if (doesFileExist myimage5) == false then 
				(
				sLibResizeImageByPixelsFilter #(sALDefaultImage) (getFilenamePath myimage5) "" "_Icon" 2 sALIconSizeValue sALIconSizeValue "jpg" sALManualGammaCorrectionValue
				renameFile ((getFilenamePath myimage5)+"sALDefault_Icon.jpg") myimage5
				)
			iconimage5 = sLibAddExtraBackslashesToFilename myimage5
			rci.addControl #imgtag (("buttonB"+(i as string)) as name) ((sLibStripFileExtension (sLibFilenameFromPath sALTexMapFiles[i])) as string) paramStr:("transparent: (color 257 257 257) bitmap:(openbitmap " + "\"" + iconimage5 + "\"" + ")" + " toolTip:"+"\""+((sLibStripFileExtension (sLibFilenameFromPath sALTexMapFiles[i])) as string)+"\""+" pos:["+((sALIconXPos i) as string)+","+((sALIconYPos i) as string)+"]")
			rci.addHandler (("buttonB"+(i as string)) as name) #click filter:on codeStr:("soulburnAssetLoader sALEnvDeleteOldValue sALEnvIgnoreCamValue sALEnvVisibilityValue sALEnvPlaceEnvMapValue sALEnvAddEnvPrefixValue sALMatMeditCurSlotValue sALMatMeditLocationValue sALMatSelObjsValue sALModelAlignValue sALModelToCurrentLayerValue sALModelIgnoreCamValue sALModelIgnoreLightValue sALModelUniqueNamesValue sALModelMergeIntoValue sALTexMeditLocationValue sALTexMapTypeValue sALTexMapMeditLocationValue 5 " + (i as string))
			)
		)
	rci.end()

	freeSceneBitmaps()
	gc()

	-- define floater size
	if sALManualResizeValue == false then
		(
		-- define floater width
		numberofcolumns = #(sALEnvFiles.count, sALMatFiles.count, sALModelFiles.count, sALTexFiles.count, sALTexMapFiles.count)
		longestColumn = (amax numberofcolumns)
		if longestColumn > sALIconsAcrossValue then longestColumn = sALIconsAcrossValue
		floaterWidth = (longestColumn*sALIconSizeValue) + 40
		if floaterWidth < 170 then floaterWidth = 170

		-- define floater height
		if sALEnvShowValue == true then n1 = (ceil(sALEnvFiles.count/(sALIconsAcrossValue as float))*sALIconSizeValue)+57 else n1 = 0
		if sALMatShowValue == true then n2 = (ceil(sALMatFiles.count/(sALIconsAcrossValue as float))*sALIconSizeValue)+57 else n2 = 0
		if sALModelShowValue == true then n3 = (ceil(sALModelFiles.count/(sALIconsAcrossValue as float))*sALIconSizeValue)+57 else n3 = 0
		if sALTexShowValue == true then n4 = (ceil(sALTexFiles.count/(sALIconsAcrossValue as float))*sALIconSizeValue)+57 else n4 = 0
		if sALTexMapShowValue == true then n5 = (ceil(sALTexMapFiles.count/(sALIconsAcrossValue as float))*sALIconSizeValue)+57 else n5 = 0
		numberofrows = n1 + n2 + n3 + n4 + n5
		floaterHeight = numberofrows + 103
		sheight = systemTools.GetScreenHeight()
		if floaterHeight > (sheight-pos.y) then floaterHeight = (sheight-pos.y)
		if floaterHeight < 170 then floaterHeight = 170
		)
	else 
		(
		floaterWidth = siz.x
		floaterHeight = siz.y
		)
	
	sALFloater = newRolloutFloater "soulburnAssetLoader v1.31" floaterWidth floaterHeight pos.x pos.y
	addRollout sALShowRollout sALFloater
	if sALEnvShowValue == true then addRollout sALEnvRollout sALFloater
	if sALMatShowValue == true then addRollout sALMatRollout sALFloater
	if sALTexShowValue == true then addRollout sALTexRollout sALFloater
	if sALTexMapShowValue == true then addRollout sALTexMapRollout sALFloater
	if sALModelShowValue == true then addRollout sALModelRollout sALFloater
	addRollout sALRollout sALFloater rolledUp:true
	addRollout sALWizardRollout sALFloater rolledUp:true
	popPrompt()
	)

fn sALHelp = 
	(
	sLibSSPrintHelp "soulburnAssetLoader"
	)
	
fn sALLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sALInputFilename = presetDir + "soulburnAssetLoader.ini"
	if (sLibFileExist sALInputFilename == true) then
		(
		sALEnvDirValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvDirValue"
		sALMatDirValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALMatDirValue"
		sALModelDirValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALModelDirValue"
		sALTexDirValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALTexDirValue"
		sALTexMapDirValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALTexMapDirValue"
		
		sALEnvDirExtraValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvDirExtraValue"
		sALMatDirExtraValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALMatDirExtraValue"
		sALModelDirExtraValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALModelDirExtraValue"
		sALTexDirExtraValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALTexDirExtraValue"
		sALTexMapDirExtraValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALTexMapDirExtraValue"
		
		sALIgnoreValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALIgnoreValue"
		sALRecurseSubdirsValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALRecurseSubdirsValue")
		sALIconSizeValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALIconSizeValue")
		sALIconsAcrossValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALIconsAcrossValue")
		sALManualResizeValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALManualResizeValue")
		sALManualGammaCorrectionValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALManualGammaCorrectionValue") 
		
		sALEnvDeleteOldValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvDeleteOldValue")		
		sALEnvIgnoreCamValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvIgnoreCamValue")
		sALEnvVisibilityValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvVisibilityValue")
		sALEnvPlaceEnvMapValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvPlaceEnvMapValue")
		sALEnvAddEnvPrefixValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvAddEnvPrefixValue")
		
		sALMatMeditCurSlotValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALMatMeditCurSlotValue")
		sALMatMeditLocationValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALMatMeditLocationValue")
		sALMatSelObjsValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALMatSelObjsValue")
		
		sALModelAlignValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelAlignValue")
		sALModelToCurrentLayerValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelToCurrentLayerValue")
		sALModelIgnoreCamValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelIgnoreCamValue")
		sALModelIgnoreLightValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelIgnoreLightValue")
		sALModelUniqueNamesValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelUniqueNamesValue")
		sALModelMergeIntoValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelMergeIntoValue")
		
		sALTexMeditLocationValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALTexMeditLocationValue")
		sALTexMapTypeValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALTexMapTypeValue")
		
		sALTexMapMeditLocationValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALTexMapMeditLocationValue")
		
		sALAssetTypeValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALAssetTypeValue")
		sALAssetFileIndexValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALAssetFileIndexValue")
		sALEnvCategoryIndexValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvCategoryIndexValue")
		sALMatCategoryIndexValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALMatCategoryIndexValue")
		sALModelCategoryIndexValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelCategoryIndexValue")
		sALTexCategoryIndexValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALTexCategoryIndexValue")
		sALTexMapCategoryIndexValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALTexMapCategoryIndexValue")
		
		sALWizardAssetTypeValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALWizardAssetTypeValue")
		sALWizardCategoryValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALWizardCategoryValue"
		sALWizardNameValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALWizardNameValue"
		sALWizardGetIconFileValue = getINISetting sALInputFilename "soulburnAssetLoader" "sALWizardGetIconFileValue"
		
		sALEnvShowValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALEnvShowValue")
		sALMatShowValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALMatShowValue")
		sALModelShowValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALModelShowValue")
		sALTexShowValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALTexShowValue")
		sALTexMapShowValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALTexMapShowValue")
		
		sALPosValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALPosValue")
		sALSizeValue = execute (getINISetting sALInputFilename "soulburnAssetLoader" "sALSizeValue")
		
		if sALEnvDirValue == OK then sALEnvDirValue = "E:\\assets\\env\\"
		if sALMatDirValue == OK then sALMatDirValue = "E:\\assets\\mats\\"
		if sALModelDirValue == OK then sALModelDirValue = "E:\\assets\\models\\"
		if sALTexDirValue == OK then sALTexDirValue = "E:\\assets\\textures\\"
		if sALTexMapDirValue == OK then sALTexMapDirValue = "E:\\assets\\texmaps\\"
		
		if sALEnvDirExtraValue == OK then sALEnvDirExtraValue = ""
		if sALMatDirExtraValue == OK then sALMatDirExtraValue = ""
		if sALModelDirExtraValue == OK then sALModelDirExtraValue = ""
		if sALTexDirExtraValue == OK then sALTexDirExtraValue = ""
		if sALTexMapDirExtraValue == OK then sALTexMapDirExtraValue = ""
		
		if sALIgnoreValue == OK then sALIgnoreValue = "Ignore_"
		if sALRecurseSubdirsValue == OK then sALRecurseSubdirsValue = true
		if sALIconSizeValue == OK then sALIconSizeValue = 50
		if sALIconsAcrossValue == OK then sALIconsAcrossValue = 16
		if sALManualResizeValue == OK then sALManualResizeValue = false
		if sALManualGammaCorrectionValue == OK then sALManualGammaCorrectionValue = 1.0
		
		if sALEnvDeleteOldValue == OK then sALEnvDeleteOldValue = true
		if sALEnvIgnoreCamValue == OK then sALEnvIgnoreCamValue = true
		if sALEnvVisibilityValue == OK then sALEnvVisibilityValue = 1
		if sALEnvPlaceEnvMapValue == OK then sALEnvPlaceEnvMapValue = false
		if sALEnvAddEnvPrefixValue == OK then sALEnvAddEnvPrefixValue = false
		
		if sALMatMeditCurSlotValue == OK then sALMatMeditCurSlotValue = false
		if sALMatMeditLocationValue == OK then sALMatMeditLocationValue = 1
		if sALMatSelObjsValue == OK then sALMatSelObjsValue = true
		
		if sALModelAlignValue == OK then sALModelAlignValue = false
		if sALModelToCurrentLayerValue == OK then sALModelToCurrentLayerValue = true
		if sALModelIgnoreCamValue == OK then sALModelIgnoreCamValue = true
		if sALModelIgnoreLightValue == OK then sALModelIgnoreLightValue = true
		if sALModelUniqueNamesValue == OK then sALModelUniqueNamesValue = true
		if sALModelMergeIntoValue == OK then sALModelMergeIntoValue = 1
		
		if sALTexMeditLocationValue == OK then sALTexMeditLocationValue = 1
		if sALTexMapTypeValue == OK then sALTexMapTypeValue = 1
		
		if sALTexMapMeditLocationValue == OK then sALTexMapMeditLocationValue = 1
		
		if sALAssetTypeValue == OK then sALAssetTypeValue = 3
		if sALAssetFileIndexValue == OK then sALAssetFileIndexValue = 1
		if sALEnvCategoryIndexValue == OK then sALEnvCategoryIndexValue = 1
		if sALMatCategoryIndexValue == OK then sALMatCategoryIndexValue = 1
		if sALModelCategoryIndexValue == OK then sALModelCategoryIndexValue = 1
		if sALTexCategoryIndexValue == OK then sALTexCategoryIndexValue = 1
		if sALTexMapCategoryIndexValue == OK then sALTexMapCategoryIndexValue = 1
		
		if sALWizardAssetTypeValue == OK then sALWizardAssetTypeValue = 3
		if sALWizardCategoryValue == OK then sALWizardCategoryValue = ""
		if sALWizardNameValue == OK then sALWizardNameValue = ""
		if sALWizardGetIconFileValue == OK then sALWizardGetIconFileValue = ""
		
		if sALEnvShowValue == OK then sALEnvShowValue = true
		if sALMatShowValue == OK then sALMatShowValue = true
		if sALModelShowValue == OK then sALModelShowValue = true
		if sALTexShowValue == OK then sALTexShowValue = true
		if sALTexMapShowValue == OK then sALTexMapShowValue = true
		
		if sALPosValue == OK then sALPosValue = [50,50]
		if sALSizeValue == OK then sALSizeValue = [800,600]
		)
	else
		(
		sALEnvDirValue = "E:\\assets\\env\\"
		sALMatDirValue = "E:\\assets\\mats\\"
		sALModelDirValue = "E:\\assets\\models\\"
		sALTexDirValue = "E:\\assets\\textures\\"
		sALTexMapDirValue = "E:\\assets\\texmaps\\"
		
		sALEnvDirExtraValue = ""
		sALMatDirExtraValue = ""
		sALModelDirExtraValue = ""
		sALTexDirExtraValue = ""
		sALTexMapDirExtraValue = ""
		
		sALIgnoreValue = "Ignore_"
		sALRecurseSubdirsValue = true
		sALIconSizeValue = 50
		sALIconsAcrossValue = 16
		sALManualResizeValue = false
		sALManualGammaCorrectionValue = 1.0
		
		sALEnvDeleteOldValue = true
		sALEnvIgnoreCamValue = true
		sALEnvVisibilityValue = 1
		sALEnvPlaceEnvMapValue = false
		sALEnvAddEnvPrefixValue = false
		
		sALMatMeditCurSlotValue = false
		sALMatMeditLocationValue = 1
		sALMatSelObjsValue = true
		
		sALModelAlignValue = false
		sALModelToCurrentLayerValue = true
		sALModelIgnoreCamValue = true
		sALModelIgnoreLightValue = true
		sALModelUniqueNamesValue = true
		sALModelMergeIntoValue = 1
		
		sALTexMeditLocationValue = 1
		sALTexMapTypeValue = 1
		
		sALTexMapMeditLocationValue = 1
		
		sALAssetTypeValue = 3
		sALAssetFileIndexValue = 1
		sALEnvCategoryIndexValue = 1
		sALMatCategoryIndexValue = 1
		sALModelCategoryIndexValue = 1
		sALTexCategoryIndexValue = 1
		sALTexMapCategoryIndexValue = 1
		
		sALWizardAssetTypeValue = 3
		sALWizardCategoryValue = ""
		sALWizardNameValue = ""
		sALWizardGetIconFileValue = ""
		
		sALEnvShowValue = true
		sALMatShowValue = true
		sALModelShowValue = true
		sALTexShowValue = true
		sALTexMapShowValue = true
		
		sALPosValue = [50,50]
		sALSizeValue = [800,600]
		)
	)
	
fn sALSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
	if (sLibFileExist sALOutputFilename == true) then deleteFile sALOutputFilename
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvDirValue" (sALEnvDirValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatDirValue" (sALMatDirValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelDirValue" (sALModelDirValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexDirValue" (sALTexDirValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapDirValue" (sALTexMapDirValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvDirExtraValue" (sALEnvDirExtraValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatDirExtraValue" (sALMatDirExtraValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelDirExtraValue" (sALModelDirExtraValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexDirExtraValue" (sALTexDirExtraValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapDirExtraValue" (sALTexMapDirExtraValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALIgnoreValue" (sALIgnoreValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALRecurseSubdirsValue" (sALRecurseSubdirsValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALIconSizeValue" (sALIconSizeValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALIconsAcrossValue" (sALIconsAcrossValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALManualResizeValue" (sALManualResizeValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALManualGammaCorrectionValue" (sALManualGammaCorrectionValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvDeleteOldValue" (sALEnvDeleteOldValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvIgnoreCamValue" (sALEnvIgnoreCamValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvVisibilityValue" (sALEnvVisibilityValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvPlaceEnvMapValue" (sALEnvPlaceEnvMapValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvAddEnvPrefixValue" (sALEnvAddEnvPrefixValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatMeditCurSlotValue" (sALMatMeditCurSlotValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatMeditLocationValue" (sALMatMeditLocationValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatSelObjsValue" (sALMatSelObjsValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelAlignValue" (sALModelAlignValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelToCurrentLayerValue" (sALModelToCurrentLayerValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelIgnoreCamValue" (sALModelIgnoreCamValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelIgnoreLightValue" (sALModelIgnoreLightValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelUniqueNamesValue" (sALModelUniqueNamesValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelMergeIntoValue" (sALModelMergeIntoValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMeditLocationValue" (sALTexMeditLocationValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapTypeValue" (sALTexMapTypeValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapMeditLocationValue" (sALTexMapMeditLocationValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALAssetTypeValue" (sALAssetTypeValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALAssetFileIndexValue" (sALAssetFileIndexValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvCategoryIndexValue" (sALEnvCategoryIndexValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatCategoryIndexValue" (sALMatCategoryIndexValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelCategoryIndexValue" (sALModelCategoryIndexValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexCategoryIndexValue" (sALTexCategoryIndexValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapCategoryIndexValue" (sALTexMapCategoryIndexValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALWizardAssetTypeValue" (sALWizardAssetTypeValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALWizardCategoryValue" (sALWizardCategoryValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALWizardNameValue" (sALWizardNameValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALWizardGetIconFileValue" (sALWizardGetIconFileValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvShowValue" (sALEnvShowValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatShowValue" (sALMatShowValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelShowValue" (sALModelShowValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexShowValue" (sALTexShowValue as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapShowValue" (sALTexMapShowValue as string)
	
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALPosValue" (sALFloater.pos as string)
	setINISetting sALOutputFilename "soulburnAssetLoader" "sALSizeValue" (sALFloater.size as string)
	)

-- UI

fn sALDefineUI = 
	(
	rollout sALShowRollout "SAL"
		(
		checkbutton sALEnvShowCheckbutton "Env" checked:sALEnvShowValue tooltip:"Show Environments" fieldWidth:35 pos:[2,4] 
		checkbutton sALMatShowCheckbutton "Mat" checked:sALMatShowValue tooltip:"Show Materials" fieldWidth:35 pos:[39,4] 
		checkbutton sALTexShowCheckbutton "Tex" checked:sALTexShowValue tooltip:"Show Textures" fieldWidth:35 pos:[76,4]
		checkbutton sALTexMapShowCheckbutton "TMp" checked:sALTexMapShowValue tooltip:"Show TexMaps" fieldWidth:35 pos:[111,4]  
		checkbutton sALModelShowCheckbutton "Mdl" checked:sALModelShowValue tooltip:"Show Models" fieldWidth:35 pos:[148,4]
		
		on sALEnvShowCheckbutton changed state do 
			(
			if state == on then sALEnvShowValue = true
			else sALEnvShowValue = false
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALMatShowCheckbutton changed state do 
			(
			if state == on then sALMatShowValue = true
			else sALMatShowValue = false
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALTexShowCheckbutton changed state do 
			(
			if state == on then sALTexShowValue = true
			else sALTexShowValue = false
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALTexMapShowCheckbutton changed state do 
			(
			if state == on then sALTexMapShowValue = true
			else sALTexMapShowValue = false
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALModelShowCheckbutton changed state do 
			(
			if state == on then sALModelShowValue = true
			else sALModelShowValue = false
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		)
	rollout sALRollout "Options"
		(
		group "Asset Files and Directories"
		(
		button sALEnvGetPathButton "F" width:20 toolTip:"Choose Env Path" pos:[12,24]
		label label1 "Env: " pos:[35,27]
		edittext sALEnvPathEditText "" fieldWidth:300 text:sALEnvDirValue pos:[80,25]
		edittext sALEnvPathExtraEditText "" fieldWidth:300 text:sALEnvDirExtraValue pos:[387,25]

		button sALMatGetPathButton "F" width:20 toolTip:"Choose Mat Path" pos:[12,48]
		label label2 "Mats: " pos:[35,51]
		edittext sALMatPathEditText "" fieldWidth:300 text:sALMatDirValue pos:[80,49]
		edittext sALMatPathExtraEditText "" fieldWidth:300 text:sALMatDirExtraValue pos:[387,49]

		button sALTexGetPathButton "F" width:20 toolTip:"Choose Tex Path" pos:[12,72]
		label label4 "Textures: " pos:[35,75]
		edittext sALTexPathEditText "" fieldWidth:300 text:sALTexDirValue pos:[80,73]
		edittext sALTexPathExtraEditText "" fieldWidth:300 text:sALTexDirExtraValue pos:[387,73]

		button sALTexMapGetPathButton "F" width:20 toolTip:"Choose TexMap Path" pos:[12,96]
		label label5 "TexMaps: " pos:[35,99]
		edittext sALTexMapPathEditText "" fieldWidth:300 text:sALTexMapDirValue pos:[80,97]
		edittext sALTexMapPathExtraEditText "" fieldWidth:300 text:sALTexMapDirExtraValue pos:[387,97]

		button sALModelGetPathButton "F" width:20 toolTip:"Choose Model Path" pos:[12,120]
		label label3 "Models: " pos:[35,123]
		edittext sALModelPathEditText "" fieldWidth:300 text:sALModelDirValue pos:[80,121]
		edittext sALModelPathExtraEditText "" fieldWidth:300 text:sALModelDirExtraValue pos:[387,121]
		
		checkbox sALRecurseSubdirsCheckbox "Recurse Subdirectories?" checked:sALRecurseSubdirsValue align:#left offset:[0,5]

		edittext sALIgnoreEditText "Ignore files with this Prefix:" fieldWidth:90 text:sALIgnoreValue

		button sALGetAssetsButton "Get New Assets" width:130 toolTip:"Get New Assets" align:#left
		
		checkbox sALManualResizeCheckbox "Manual Floater Resize?" checked:sALManualResizeValue align:#left offset:[0,5]
		)

		on sALEnvPathEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALEnvDirValue = mypath
			sALEnvPathEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			-- Save To Preset
		        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
			if (getDirectories presetDir).count == 0 then makeDir presetDir
		        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
		        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                	else setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvDirValue" (mypath as string)
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALEnvGetPathButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				sALEnvDirValue = mypath
				sALEnvPathEditText.text = mypath
				mappathvalue = (mypath as string) + "maps" + "\\"
				mapPaths.add mappathvalue
				-- Save To Preset
			        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
				if (getDirectories presetDir).count == 0 then makeDir presetDir
			        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
			        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                		else setINISetting sALOutputFilename "soulburnAssetLoader" "sALEnvDirValue" (mypath as string)
				curPos = sALFloater.pos
				curSize = sALFloater.size
				sALCloseOpenUI curPos curSize
				)
			else 
				(
				sALEnvDirValue = ""
				sALEnvPathEditText.text = ""
				)
			)
		on sALEnvPathExtraEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALEnvDirExtraValue = mypath
			sALEnvPathExtraEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			)
		on sALMatPathEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALMatDirValue = mypath
			sALMatPathEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			-- Save To Preset
		        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
			if (getDirectories presetDir).count == 0 then makeDir presetDir
		        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
		        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                	else setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatDirValue" (mypath as string)
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALMatGetPathButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				sALMatDirValue = mypath
				sALMatPathEditText.text = mypath
				mappathvalue = (mypath as string) + "maps" + "\\"
				mapPaths.add mappathvalue
				-- Save To Preset
			        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
				if (getDirectories presetDir).count == 0 then makeDir presetDir
			        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
			        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                		else setINISetting sALOutputFilename "soulburnAssetLoader" "sALMatDirValue" (mypath as string)
				curPos = sALFloater.pos
				curSize = sALFloater.size
				sALCloseOpenUI curPos curSize
				)
			else 
				(
				sALMatDirValue = ""
				sALMatPathEditText.text = ""
				)
			)
		on sALMatPathExtraEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALMatDirExtraValue = mypath
			sALMatPathExtraEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			)
		on sALTexPathEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALTexDirValue = mypath
			sALTexPathEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			-- Save To Preset
		        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
			if (getDirectories presetDir).count == 0 then makeDir presetDir
		        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
		        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                	else setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexDirValue" (mypath as string)
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALTexGetPathButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				sALTexDirValue = mypath
				sALTexPathEditText.text = mypath
				mappathvalue = (mypath as string) + "maps" + "\\"
				mapPaths.add mappathvalue
				-- Save To Preset
			        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
				if (getDirectories presetDir).count == 0 then makeDir presetDir
			        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
			        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                		else setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexDirValue" (mypath as string)
				curPos = sALFloater.pos
				curSize = sALFloater.size
				sALCloseOpenUI curPos curSize
				)
			else 
				(
				sALTexDirValue = ""
				sALTexPathEditText.text = ""
				)
			)
		on sALTexPathExtraEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALTexDirExtraValue = mypath
			sALTexPathExtraEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			)
		on sALTexMapPathEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALTexMapDirValue = mypath
			sALTexMapPathEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			-- Save To Preset
		        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
			if (getDirectories presetDir).count == 0 then makeDir presetDir
		        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
		        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                	else setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapDirValue" (mypath as string)
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALTexMapGetPathButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				sALTexMapDirValue = mypath
				sALTexMapPathEditText.text = mypath
				mappathvalue = (mypath as string) + "maps" + "\\"
				mapPaths.add mappathvalue
				-- Save To Preset
			        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
				if (getDirectories presetDir).count == 0 then makeDir presetDir
			        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
			        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                		else setINISetting sALOutputFilename "soulburnAssetLoader" "sALTexMapDirValue" (mypath as string)
				curPos = sALFloater.pos
				curSize = sALFloater.size
				sALCloseOpenUI curPos curSize
				)
			else 
				(
				sALTexMapDirValue = ""
				sALTexMapPathEditText.text = ""
				)
			)
		on sALTexMapPathExtraEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALTexMapDirExtraValue = mypath
			sALTexMapPathExtraEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			)
		on sALModelPathEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALModelDirValue = mypath
			sALModelPathEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			-- Save To Preset
		        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
			if (getDirectories presetDir).count == 0 then makeDir presetDir
		        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
		        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                	else setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelDirValue" (mypath as string)
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALModelGetPathButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				sALModelDirValue = mypath
				sALModelPathEditText.text = mypath
				mappathvalue = (mypath as string) + "maps" + "\\"
				mapPaths.add mappathvalue
				-- Save To Preset
			        presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
				if (getDirectories presetDir).count == 0 then makeDir presetDir
			        sALOutputFilename = presetDir + "soulburnAssetLoader.ini"
			        if (sLibFileExist sALOutputFilename == false) then sALSaveDef()
                		else setINISetting sALOutputFilename "soulburnAssetLoader" "sALModelDirValue" (mypath as string)
				curPos = sALFloater.pos
				curSize = sALFloater.size
				sALCloseOpenUI curPos curSize
				)
			else 
				(
				sALModelDirValue = ""
				sALModelPathEditText.text = ""
				)
			)
		on sALModelPathExtraEditText entered mypath do 
			(
			if mypath != "" then (if mypath[mypath.count] != "\\" then mypath = mypath + "\\")
			sALModelDirExtraValue = mypath
			sALModelPathExtraEditText.text = mypath
			mappathvalue = (mypath as string) + "maps" + "\\"
			mapPaths.add mappathvalue
			)
		on sALRecurseSubdirsCheckbox changed state do 
			(
			sALRecurseSubdirsValue = state
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALIgnoreEditText changed text do 
			(
			sALIgnoreValue = text
			sALIgnoreEditText.text = text
			)

		on sALGetAssetsButton pressed do 
			(
			ShellLaunch "http://www.neilblevins.com/cg_tools/assets/assets_3dsmax.htm" ""
			)
		on sALManualResizeCheckbox changed state do 
			(
			sALManualResizeValue = state
			)

		group "Env"
		(
		checkbox sALEnvDeleteOldCheckbox "Delete Old Environment When Loading A New One" checked:sALEnvDeleteOldValue align:#left
		checkbox sALEnvIgnoreCamCheckbox "Don't Merge Cameras From Env Files" checked:sALEnvIgnoreCamValue align:#left
		dropdownlist sALEnvVisibilityDropdown "" items:#("Light Visibility Set To Max File Default", "Light Visibility Always Visible", "Light Visibility Always Invisible") selection:sALEnvVisibilityValue width:250
		checkbox sALEnvPlaceEnvMapCheckbox "Place Light's Texture Into Environment Map" checked:sALEnvPlaceEnvMapValue align:#left
		checkbox sALEnvAddEnvPrefixCheckbox "Add Filename Prefix To Merged Environment" checked:sALEnvAddEnvPrefixValue align:#left
		)
		on sALEnvDeleteOldCheckbox changed state do sALEnvDeleteOldValue = state
		on sALEnvIgnoreCamCheckbox changed state do sALEnvIgnoreCamValue = state
		on sALEnvVisibilityDropdown selected i do sALEnvVisibilityValue = i
		on sALEnvPlaceEnvMapCheckbox changed state do sALEnvPlaceEnvMapValue = state
		on sALEnvAddEnvPrefixCheckbox changed state do sALEnvAddEnvPrefixValue = state

		group "Materials"
		(
		checkbox sALMatMeditCurSlotCheckbox "Copy Selected Material To Medit" checked:sALMatMeditCurSlotValue align:#left
		dropdownlist sALMatMeditLocationDropdown "" items:#("Place In Currently Selected Medit Slot", "Place in Active SME") selection:sALMatMeditLocationValue width:250
		checkbox sALMatSelObjsCheckbox "Apply Material To Selected Objects" checked:sALMatSelObjsValue align:#left
		)
		on sALMatMeditCurSlotCheckbox changed state do sALMatMeditCurSlotValue = state
		on sALMatMeditLocationDropdown selected i do sALMatMeditLocationValue = i
		on sALMatSelObjsCheckbox changed state do sALMatSelObjsValue = state

		group "Textures"
		(
		dropdownlist sALTexMeditLocationDropdown "" items:#("Place In Currently Selected Medit Slot", "Place in Active SME") selection:sALTexMeditLocationValue width:250
		dropdownlist sALTexMapTypeDropdown "" items:#("Create Bitmap Map", "Create VrayHRDI map") selection:sALTexMapTypeValue width:250
		)
		on sALTexMeditLocationDropdown selected i do sALTexMeditLocationValue = i
		on sALTexMapTypeDropdown selected i do sALTexMapTypeValue = i

		group "TexMaps"
		(
		dropdownlist sALTexMapMeditLocationDropdown "" items:#("Place In Currently Selected Medit Slot", "Place in Active SME") selection:sALTexMapMeditLocationValue width:250
		)
		on sALTexMapMeditLocationDropdown selected i do sALTexMapMeditLocationValue = i

		group "Models"
		(
		checkbox sALModelAlignCheckbox "Align Model To Current Selection" checked:sALModelAlignValue align:#left
		checkbox sALModelIgnoreCamCheckbox "Don't Merge Cameras From Model Files" checked:sALModelIgnoreCamValue align:#left
		checkbox sALModelIgnoreLightCheckbox "Don't Merge Lights From Model Files" checked:sALModelIgnoreLightValue align:#left
		checkbox sALModelUniqueNamesCheckbox "Give Merged Objects Unique Names" checked:sALModelUniqueNamesValue align:#left
		dropdownlist sALModelMergeIntoDropdown "" items:#("Keep Original Layer", "Merge Into Current Scene Layer", "Merge Into New Layer") selection:sALModelMergeIntoValue width:250
		)
		on sALModelAlignCheckbox changed state do sALModelAlignValue = state
		on sALModelIgnoreCamCheckbox changed state do sALModelIgnoreCamValue = state
		on sALModelIgnoreLightCheckbox changed state do sALModelIgnoreLightValue = state
		on sALModelUniqueNamesCheckbox changed state do sALModelUniqueNamesValue = state
		on sALModelMergeIntoDropdown selected i do sALModelMergeIntoValue = i
		
		group "Docking"
		(
		button DockButton5 "Undock" width:120 toolTip:"Undock" align:#left
		button DockButton1 "Dock Left" width:120 toolTip:"Dock Left" align:#left
		button DockButton2 "Dock Right" width:120 toolTip:"Dock Right" align:#left
		button DockButton3 "Dock Top" width:120 toolTip:"Dock Top" align:#left
		button DockButton4 "Dock Bottom" width:120 toolTip:"Dock Bottom" align:#left
		)
		on DockButton1 pressed do sALDockMe 1
		on DockButton2 pressed do sALDockMe 2
		on DockButton3 pressed do sALDockMe 3
		on DockButton4 pressed do sALDockMe 4
		on DockButton5 pressed do sALDockMe 5
		
		group "Icons"
		(
		spinner sALIconSizeSpinner "Icon Size: " range:[10,200,sALIconSizeValue] fieldWidth:55 type:#integer align:#left enabled:true
		spinner sALIconsAcrossSpinner "Icons Across: " range:[1,500,sALIconsAcrossValue] fieldWidth:55 type:#integer align:#left enabled:true
		button sALRemakeAllIconsButton "Remake All Icons" width:150 toolTip:"Remake All Icons" align:#left
		spinner sALManualGammaCorrectionSpinner "Manual Gamma Correction: " range:[0.0,10.0,sALManualGammaCorrectionValue] fieldWidth:55 type:#float align:#left enabled:true
		)

		on sALIconSizeSpinner changed val do 
			(
			sALIconSizeValue = val
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALIconsAcrossSpinner changed val do 
			(
			sALIconsAcrossValue = val
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize
			)
		on sALRemakeAllIconsButton pressed do 
			(
			sALDeleteAllIcons()
			curPos = sALFloater.pos
			curSize = sALFloater.size
			sALCloseOpenUI curPos curSize			
			)
		on sALManualGammaCorrectionSpinner changed val do 
			(
			sALManualGammaCorrectionValue = val
			)
	
		button sALHelpButton "Help" width:70 toolTip:"Help" align:#left
		button sALSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" align:#left
		on sALHelpButton pressed do sALHelp()
		on sALSaveDefButton pressed do sALSaveDef()
		)
	rollout sALWizardRollout "Asset Install Wizard"
		(
		group "Asset Parameters"
		(
		label label5 "Type: " pos:[13,28]
		dropdownlist sALWizardAssetTypeDropdown "" items:#("Env", "Material", "Texmaps", "Model") selection:sALWizardAssetTypeValue width:90 pos:[46,26]
		
		label label6 "Category: " pos:[13,55]
		edittext sALWizardCategoryEditText "" fieldWidth:150 text:sALWizardCategoryValue pos:[85,53]
		dropdownlist sALWizardCategoryPreset1Dropdown "" items:sALEnvPresetCategories selection:1 width:90 pos:[248,52]
		dropdownlist sALWizardCategoryPreset2Dropdown "" items:sALMatPresetCategories selection:1 width:90 pos:[346,52]
		dropdownlist sALWizardCategoryPreset3Dropdown "" items:sALTexMapPresetCategories selection:1 width:90 pos:[445,52]
		dropdownlist sALWizardCategoryPreset4Dropdown "" items:sALModelPresetCategories selection:1 width:90 pos:[543,52]
		
		label label7 "Asset Name: " pos:[13,78]
		edittext sALWizardNameEditText "" fieldWidth:150 text:sALWizardNameValue pos:[85,76]
		
		label label8 "Use Icon: " pos:[13,101]
		button sALWizardGetIconFileButton "F" width:20 toolTip:"Choose Icon" pos:[64,98]
		edittext sALWizardGetIconFileEditText "" fieldWidth:300 text:sALWizardGetIconFileValue pos:[85,99]
		button sALWizardRenderIconButton "Render" width:80 toolTip:"Render Icon" pos:[394,98]
		)
		
		button sALWizardCreateAssetButton "Create Asset From Selection" width:170 toolTip:"Create Asset From Selection" align:#left		

		on sALWizardAssetTypeDropdown selected i do 
			(
			sALWizardAssetTypeValue = i
			if i == 1 then (sALWizardCategoryPreset1Dropdown.enabled = true;sALWizardCategoryPreset2Dropdown.enabled = false;sALWizardCategoryPreset3Dropdown.enabled = false;sALWizardCategoryPreset4Dropdown.enabled = false)
			else if i == 2 then (sALWizardCategoryPreset1Dropdown.enabled = false;sALWizardCategoryPreset2Dropdown.enabled = true;sALWizardCategoryPreset3Dropdown.enabled = false;sALWizardCategoryPreset4Dropdown.enabled = false)
			else if i == 3 then (sALWizardCategoryPreset1Dropdown.enabled = false;sALWizardCategoryPreset2Dropdown.enabled = false;sALWizardCategoryPreset3Dropdown.enabled = true;sALWizardCategoryPreset4Dropdown.enabled = false)
			else if i == 4 then (sALWizardCategoryPreset1Dropdown.enabled = false;sALWizardCategoryPreset2Dropdown.enabled = false;sALWizardCategoryPreset3Dropdown.enabled = false;sALWizardCategoryPreset4Dropdown.enabled = true)
			)
		on sALWizardCategoryEditText entered mypath do (sALWizardCategoryValue = mypath)
		on sALWizardCategoryPreset1Dropdown selected i do 
			(
			Preset1 = sALEnvPresetCategories[i]
			sALWizardCategoryPreset1Dropdown.selection = 1
			sALWizardCategoryEditText.text = Preset1
			sALWizardCategoryValue = Preset1
			)
		on sALWizardCategoryPreset2Dropdown selected i do 
			(
			Preset2 = sALMatPresetCategories[i]
			sALWizardCategoryPreset2Dropdown.selection = 1
			sALWizardCategoryEditText.text = Preset2
			sALWizardCategoryValue = Preset2
			)
		on sALWizardCategoryPreset3Dropdown selected i do 
			(
			Preset3 = sALTexMapPresetCategories[i]
			sALWizardCategoryPreset3Dropdown.selection = 1
			sALWizardCategoryEditText.text = Preset3
			sALWizardCategoryValue = Preset3
			)
		on sALWizardCategoryPreset4Dropdown selected i do 
			(
			Preset4 = sALModelPresetCategories[i]
			sALWizardCategoryPreset4Dropdown.selection = 1
			sALWizardCategoryEditText.text = Preset4
			sALWizardCategoryValue = Preset4
			)
		on sALWizardNameEditText entered mypath do (sALWizardNameValue = mypath)

		on sALWizardGetIconFileEditText changed text do sALWizardGetIconFileValue = sALWizardGetIconFileEditText.text
		on sALWizardGetIconFileButton pressed do 
			(
			myfile = getOpenFileName types:"png(*.png)|"			
			if myfile == undefined then
				(
				sALWizardGetIconFileEditText.text = ""
				sALWizardGetIconFileValue = ""
				)
			else 
				(
				sALWizardGetIconFileEditText.text = myfile
				sALWizardGetIconFileValue = myfile
				)
			)
		on sALWizardRenderIconButton pressed do	
			(
			renderSceneDialog.close()
			myfile = (getdir #temp + "\SALIconTemp.png")
			if (doesfileexist myfile) == true then deletefile myfile

			-- Store current parameters
			tempVFB = rendshowVFB
			tempWidth = RenderWidth
			tempHeight = RenderHeight
			tempSave = rendSaveFile
			tempFile = rendOutputFilename
			-- Change current renderer
			rendshowVFB = true
			RenderWidth = 1024
			RenderHeight = 1024
			rendSaveFile = true
			rendOutputFilename = myfile
			-- Render
			max quick render
			-- Put everything back
			rendshowVFB = tempVFB
			RenderWidth = tempWidth
			RenderHeight = tempHeight
			rendSaveFile = tempSave
			rendOutputFilename = tempFile

			if (doesfileexist myfile) == true then 
				(
				sALWizardGetIconFileEditText.text = myfile
				sALWizardGetIconFileValue = myfile
				)
			)			
			
		on sALWizardCreateAssetButton pressed do sALInstallAsset sALWizardAssetTypeValue sALWizardCategoryValue sALWizardNameValue sALWizardGetIconFileValue

		on sALWizardRollout open do
			(
			sALEnvPresetCategories = #("")
			sALMatPresetCategories = #("")
			sALModelPresetCategories = #("")
			sALTexMapPresetCategories = #("")
			
			for i = 1 to sALEnvCategories.count do (if i != 1 then append sALEnvPresetCategories sALEnvCategories[i])
			for i = 1 to sALMatCategories.count do (if i != 1 then append sALMatPresetCategories sALMatCategories[i])
			for i = 1 to sALModelCategories.count do (if i != 1 then append sALModelPresetCategories sALModelCategories[i])
			for i = 1 to sALTexMapCategories.count do (if i != 1 then append sALTexMapPresetCategories sALTexMapCategories[i])
			
			if sALWizardAssetTypeValue == 1 then (sALWizardCategoryPreset1Dropdown.enabled = true;sALWizardCategoryPreset2Dropdown.enabled = false;sALWizardCategoryPreset3Dropdown.enabled = false;sALWizardCategoryPreset4Dropdown.enabled = false)
			else if sALWizardAssetTypeValue == 2 then (sALWizardCategoryPreset1Dropdown.enabled = false;sALWizardCategoryPreset2Dropdown.enabled = true;sALWizardCategoryPreset3Dropdown.enabled = false;sALWizardCategoryPreset4Dropdown.enabled = false)
			else if sALWizardAssetTypeValue == 3 then (sALWizardCategoryPreset1Dropdown.enabled = false;sALWizardCategoryPreset2Dropdown.enabled = false;sALWizardCategoryPreset3Dropdown.enabled = true;sALWizardCategoryPreset4Dropdown.enabled = false)
			else if sALWizardAssetTypeValue == 4 then (sALWizardCategoryPreset1Dropdown.enabled = false;sALWizardCategoryPreset2Dropdown.enabled = false;sALWizardCategoryPreset3Dropdown.enabled = false;sALWizardCategoryPreset4Dropdown.enabled = true)
			
			sALWizardCategoryPreset1Dropdown.items = sALEnvPresetCategories
			sALWizardCategoryPreset2Dropdown.items = sALMatPresetCategories
			sALWizardCategoryPreset3Dropdown.items = sALTexMapPresetCategories
			sALWizardCategoryPreset4Dropdown.items = sALModelPresetCategories
			)

		)
	)
)
-------------------------------------------------------------------------------