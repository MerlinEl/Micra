-------------------------------------------------------------------------------
-- SoulburnScriptsExtras.mcr
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.09
-- Created On: 10/15/05
-- Modified On: 10/22/16
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
MacroScript AssetBrowser category:"SoulburnScriptsExtras" tooltip:"AssetBrowser" Icon:#("SoulburnScripts_AssetBrowser",1)
	(
	assetBrowser.open()
	)
	
MacroScript AssetTracker category:"SoulburnScriptsExtras" tooltip:"AssetTracker" Icon:#("SoulburnScripts_AssetTracker",1)
	(
	macros.run "Asset Tracking System" "AssetTrackingSystemShow"
	)
	
MacroScript AssignMaterialToSelection category:"SoulburnScriptsExtras" tooltip:"AssignMaterialToSelection" Icon:#("SoulburnScripts_AssignMaterialToSelection",1)
	(
	if selection.count != 0 then $.material = meditMaterials[medit.GetActiveMtlSlot()]
	)

MacroScript BitmapPathsEditor category:"SoulburnScriptsExtras" tooltip:"BitmapPathsEditor" Icon:#("SoulburnScripts_BitmapPathsEditor",1)
	(
	if findItem utilityplugin.classes Bitmap_Photometric_Paths > 0 then UtilityPanel.OpenUtility Bitmap_Photometric_Paths
	else (MessageBox "Utility does not seem to exist." title:"SoulburnScriptsExtra")
	)
	
MacroScript BrazilLight category:"SoulburnScriptsExtras" tooltip:"BrazilLight" Icon:#("SoulburnScripts_BrazilLight",1)
	(
	on execute do (Try(StartObjectCreation Brazil_Light) Catch(MessageBox "Brazil does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	)

MacroScript ColorClipboard category:"SoulburnScriptsExtras" tooltip:"ColorClipboard" Icon:#("SoulburnScripts_ColorClipboard",1)
	(
	if findItem utilityplugin.classes Color_Clipboard > 0 then UtilityPanel.OpenUtility Color_Clipboard
	else (MessageBox "Utility does not seem to exist." title:"SoulburnScriptsExtra")
	)

MacroScript Druid category:"SoulburnScriptsExtras" tooltip:"Druid" Icon:#("SoulburnScripts_Druid",1)
	(
	on execute do (Try(StartObjectCreation Druid) Catch(MessageBox "Druid does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	)

MacroScript EdgeChEx category:"SoulburnScriptsExtras" tooltip:"EdgeChEx" Icon:#("SoulburnScripts_EdgeChEx",1)
	(
	on execute do (Try(AddMod EdgeChEx) Catch(MessageBox "EdgeChEx does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	on isEnabled return mcrUtils.ValidMod EdgeChEx
	)
	
MacroScript EditPoly category:"SoulburnScriptsExtras" tooltip:"EditPoly" Icon:#("SoulburnScripts_EditPoly",1)
	(
	on execute do AddMod EditPolyMod
	on isEnabled return mcrUtils.ValidMod EditPolyMod
	)

MacroScript GrassOMatic category:"SoulburnScriptsExtras" tooltip:"GrassOMatic" Icon:#("SoulburnScripts_GrassOMatic",1)
	(
	on execute do (Try(StartObjectCreation Grass_O_matic) Catch(MessageBox "GrassOMatic does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	)

MacroScript Greeble category:"SoulburnScriptsExtras" tooltip:"Greeble" Icon:#("SoulburnScripts_Greeble",1)
	(
	on isEnabled return mcrUtils.ValidMod Greeble	
	on execute do (Try(AddMod Greeble) Catch(MessageBox "Greeble does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	)

MacroScript MaterialEditorClassic category:"SoulburnScriptsExtras" tooltip:"MaterialEditorClassic" Icon:#("SoulburnScripts_MaterialEditorClassic",1)
	(
	MatEditor.mode = #basic
	MatEditor.Open()
	)
	
MacroScript MaterialEditorSchematic category:"SoulburnScriptsExtras" tooltip:"MaterialEditorSchematic" Icon:#("SoulburnScripts_MaterialEditorSchematic",1)
	(
	MatEditor.mode = #advanced
	MatEditor.Open()
	)

MacroScript Measure category:"SoulburnScriptsExtras" tooltip:"Measure" Icon:#("SoulburnScripts_Measure",1)
	(
	if findItem utilityplugin.classes Measure > 0 then UtilityPanel.OpenUtility Measure
	else (MessageBox "Utility does not seem to exist." title:"SoulburnScriptsExtra")
	)
	
MacroScript MeasureDistance category:"SoulburnScriptsExtras" tooltip:"MeasureDistance" Icon:#("SoulburnScripts_MeasureDistance",1)
	(
	macros.run "Tools" "two_point_dist"
	)
	
MacroScript PolygonCounter category:"SoulburnScriptsExtras" tooltip:"PolygonCounter" Icon:#("SoulburnScripts_PolygonCounter",1)
	(
	if findItem utilityplugin.classes Polygon_Counter > 0 then UtilityPanel.OpenUtility Polygon_Counter
	else (MessageBox "Utility does not seem to exist." title:"SoulburnScriptsExtra")
	)

MacroScript PolySelect category:"SoulburnScriptsExtras" tooltip:"PolySelect" Icon:#("SoulburnScripts_PolySelect",1)
	(
	on execute do AddMod Poly_Select
	on isEnabled return mcrUtils.ValidMod Poly_Select
	)

MacroScript RandomWalk category:"SoulburnScriptsExtras" tooltip:"RandomWalk" Icon:#("SoulburnScripts_RandomWalk",1)
	(
	on execute do (Try(StartObjectCreation RandomWalk) Catch(MessageBox "RandomWalk does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	)

MacroScript RelaxPoly category:"SoulburnScriptsExtras" tooltip:"Relax (Poly)" Icon:#("SoulburnScripts_RelaxPoly",1)
	(
	On IsEnabled Return Filters.Is_EPoly()
	On IsVisible Return Filters.Is_EPoly()
	On execute do 
		(
		if selection.count ==1 then 
			(
			if classof $.baseobject == Editable_Poly then $.EditablePoly.Relax()
			)
		else (MessageBox "Either no object is selected, or the base object is not an Editable Poly." title:"SoulburnScriptsExtra")
		)
	)

MacroScript RenderQuick category:"SoulburnScriptsExtras" tooltip:"RenderQuick" Icon:#("SoulburnScripts_RenderQuick",1)
	(
	max quick render
	)

MacroScript RenderSetup category:"SoulburnScriptsExtras" tooltip:"RenderSetup" Icon:#("SoulburnScripts_RenderSetup",1)
	(
	max render scene
	)
	
MacroScript ResetXForm category:"SoulburnScriptsExtras" tooltip:"ResetXForm" Icon:#("SoulburnScripts_ResetXForm",1)
	(
	if findItem utilityplugin.classes Reset_XForm > 0 then UtilityPanel.OpenUtility Reset_XForm
	else (MessageBox "Utility does not seem to exist." title:"SoulburnScriptsExtra")
	)

MacroScript ScatterUtility category:"SoulburnScriptsExtras" tooltip:"ScatterUtility" Icon:#("SoulburnScripts_ScatterUtility",1)
	(
	if findItem utilityplugin.classes ScatterUtilityPlugin > 0 then UtilityPanel.OpenUtility ScatterUtilityPlugin
	else (MessageBox "Utility does not seem to exist. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra")
	)
	
MacroScript SelectByColor category:"SoulburnScriptsExtras" tooltip:"SelectByColor" Icon:#("SoulburnScripts_SelectByColor",1)
	(
	actionMan.executeAction 0 "40109"
	)

MacroScript Shell category:"SoulburnScriptsExtras" tooltip:"Shell" Icon:#("SoulburnScripts_Shell",1)
	(
	on execute do AddMod Shell 
	on isEnabled return mcrUtils.ValidMod Shell 
	)	

MacroScript SimCloth category:"SoulburnScriptsExtras" tooltip:"SimCloth" Icon:#("SoulburnScripts_SimCloth",1)
	(
	on execute do (Try(AddMod SimCloth3) Catch(MessageBox "SimCloth3 does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	on isEnabled return mcrUtils.ValidMod SimCloth3
	)

MacroScript SplineBooleanUnion category:"SoulburnScriptsExtras" tooltip:"SplineBooleanUnion" Icon:#("SoulburnScripts_SplineBooleanUnion",1)
	(
	On IsEnabled Return Filters.Is_EditSpline()
	On IsVisible Return Filters.Is_EditSpline()

	On Execute Do
		(
		if subobjectlevel == undefined then max modify mode
		if subobjectlevel != 3 then subobjectlevel = 3
		Try(ApplyOperation Edit_Spline splineOps.startUnion)Catch(MessageBox "Operation Failed" Title:"Spline Editing")	
		)
	)

MacroScript SplineBooleanSubtract category:"SoulburnScriptsExtras" tooltip:"SplineBooleanSubtract" Icon:#("SoulburnScripts_SplineBooleanSubtract",1)
	(
	On IsEnabled Return Filters.Is_EditSpline()
	On IsVisible Return Filters.Is_EditSpline()

	On Execute Do
		(
		if subobjectlevel == undefined then max modify mode
		if subobjectlevel != 3 then subobjectlevel = 3
		Try(ApplyOperation Edit_Spline splineOps.startSubtract)Catch(MessageBox "Operation Failed" Title:"Spline Editing")	
		)
	)
	
MacroScript SplineBooleanIntersect category:"SoulburnScriptsExtras" tooltip:"SplineBooleanIntersect" Icon:#("SoulburnScripts_SplineBooleanIntersect",1)
	(
	On IsEnabled Return Filters.Is_EditSpline()
	On IsVisible Return Filters.Is_EditSpline()

	On Execute Do
		(
		if subobjectlevel == undefined then max modify mode
		if subobjectlevel != 3 then subobjectlevel = 3
		Try(ApplyOperation Edit_Spline splineOps.startIntersect)Catch(MessageBox "Operation Failed" Title:"Spline Editing")	
		)
	)

MacroScript SplineMesher category:"SoulburnScriptsExtras" tooltip:"SplineMesher" Icon:#("SoulburnScripts_SplineMesher",1)
	(
	on execute do (Try(AddMod SplineMesher) Catch(MessageBox "SplineMesher does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	on isEnabled return mcrUtils.ValidMod SplineMesher
	)

MacroScript SurfaceMapper category:"SoulburnScriptsExtras" tooltip:"SurfaceMapper" Icon:#("SoulburnScripts_SurfaceMapper",1)
	(
	on execute do AddMod Surface_Mapper
	on isEnabled return mcrUtils.ValidMod Surface_Mapper
	)

MacroScript TexLay category:"SoulburnScriptsExtras" tooltip:"Texture Layers" Icon:#("SoulburnScripts_TexLay",1)
	(
	on execute do (Try(AddMod TexLay) Catch(MessageBox "Texture Layers does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	on isEnabled return mcrUtils.ValidMod TexLay
	)
	
MacroScript Texporter category:"SoulburnScriptsExtras" tooltip:"Texporter" Icon:#("SoulburnScripts_Texporter",1)
	(
	if findItem utilityplugin.classes Texporter > 0 then UtilityPanel.OpenUtility Texporter
	else (MessageBox "Utility does not seem to exist." title:"SoulburnScriptsExtra")
	)
	
MacroScript Turbosmooth category:"SoulburnScriptsExtras" tooltip:"Turbosmooth" Icon:#("SoulburnScripts_Turbosmooth",1)
	(
	on execute do AddMod TurboSmooth
	on isEnabled return mcrUtils.ValidMod TurboSmooth
	)

MacroScript VrayDisplacementMod category:"SoulburnScriptsExtras" tooltip:"VrayDisplacementMod" Icon:#("SoulburnScripts_VrayDisplacementMod",1)
	(
	on execute do (Try(AddMod VRayDisplacementMod) Catch(MessageBox "VRayDisplacementMod does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	)

MacroScript VrayLight category:"SoulburnScriptsExtras" tooltip:"VrayLight" Icon:#("SoulburnScripts_VrayLight",1)
	(
	on execute do (Try(StartObjectCreation VRayLight) Catch(MessageBox "Vray does not seem to be installed on this system. Please visit the publisher of this plugin, download and install the plugin, and then this macroscript will work." title:"SoulburnScriptsExtra") )
	)
	
MacroScript VrayShowVFB category:"SoulburnScriptsExtras" tooltip:"VrayShowVFB" Icon:#("SoulburnScripts_VrayShowVFB",1)
	(
	if renderers.current.classid[1] == 1941615238 and renderers.current.classid[2] == 2012806412 then
		(
		vr=renderers.current
		vr.showLastVFB()
		)
	)
)
-------------------------------------------------------------------------------