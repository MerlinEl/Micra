-------------------------------------------------------------------------------
-- SoulburnScripts.mcr
-- By Neil Blevins (info@neilblevins.com)
-- v 1.56
-- Created On: 04/08/05
-- Modified On: 11/12/16
-- tested using Max 2017
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
MacroScript aligner category:"SoulburnScripts" tooltip:"aligner" Icon:#("SoulburnScripts_aligner",1)
	(
	Include "$scripts/SoulburnScripts/scripts/aligner.ms"
	on execute do alignerDefaults()
	on Altexecute type do alignerUI()
	)
	
MacroScript alignerUI category:"SoulburnScripts" tooltip:"alignerUI" Icon:#("SoulburnScripts_alignerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/aligner.ms"
	alignerUI()
	)

MacroScript alignerSelectModePosition category:"SoulburnScripts" tooltip:"alignerSelectModePosition" Icon:#("SoulburnScripts_alignerSelectModePosition",1)
	(
	Include "$scripts/SoulburnScripts/scripts/aligner.ms"
	on execute do aligner 1 true true true 1 1 false false false false false false
	on Altexecute type do alignerUI()
	)
	
MacroScript alignerSelectModeRotation category:"SoulburnScripts" tooltip:"alignerSelectModeRotation" Icon:#("SoulburnScripts_alignerSelectModeRotation",1)
	(
	Include "$scripts/SoulburnScripts/scripts/aligner.ms"
	on execute do aligner 1 false false false 1 1 true true true false false false
	on Altexecute type do alignerUI()
	)
	
MacroScript alignerSelectModeScale category:"SoulburnScripts" tooltip:"alignerSelectModeScale" Icon:#("SoulburnScripts_alignerSelectModeScale",1)
	(
	Include "$scripts/SoulburnScripts/scripts/aligner.ms"
	on execute do aligner 1 false false false 1 1 false false false true true true
	on Altexecute type do alignerUI()
	)
	
MacroScript alignViewportToFace category:"SoulburnScripts" tooltip:"alignViewportToFace" Icon:#("SoulburnScripts_alignViewportToFace",1)
	(
	Include "$scripts/SoulburnScripts/scripts/alignViewportToFace.ms"
	on execute do alignViewportToFaceDefaults()
	on Altexecute type do alignViewportToFaceUI()
	)
	
MacroScript alignViewportToFaceUI category:"SoulburnScripts" tooltip:"alignViewportToFaceUI" Icon:#("SoulburnScripts_alignViewportToFaceUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/alignViewportToFace.ms"
	alignViewportToFaceUI()
	)

MacroScript bitmapCollector category:"SoulburnScripts" tooltip:"bitmapCollector" Icon:#("SoulburnScripts_bitmapCollector",1)
	(
	Include "$scripts/SoulburnScripts/scripts/bitmapCollector.ms"
	on execute do bitmapCollectorDefaults()
	on Altexecute type do bitmapCollectorUI()
	)
	
MacroScript bitmapCollectorUI category:"SoulburnScripts" tooltip:"bitmapCollectorUI" Icon:#("SoulburnScripts_bitmapCollectorUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/bitmapCollector.ms"
	bitmapCollectorUI()
	)
	
MacroScript blendedBoxMapMaker category:"SoulburnScripts" tooltip:"blendedBoxMapMaker" Icon:#("SoulburnScripts_blendedBoxMapMaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedBoxMapMaker.ms"
	on execute do blendedBoxMapMakerDefaults()
	on Altexecute type do blendedBoxMapMakerUI()
	)
	
MacroScript blendedBoxMapMakerUI category:"SoulburnScripts" tooltip:"blendedBoxMapMakerUI" Icon:#("SoulburnScripts_blendedBoxMapMakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedBoxMapMaker.ms"
	blendedBoxMapMakerUI()
	)
	
MacroScript blendedBoxMapManager category:"SoulburnScripts" tooltip:"blendedBoxMapManager" Icon:#("SoulburnScripts_blendedBoxMapManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedBoxMapManager.ms"
	on execute do blendedBoxMapManagerDefaults()
	on Altexecute type do blendedBoxMapManagerUI()
	)
	
MacroScript blendedBoxMapManagerUI category:"SoulburnScripts" tooltip:"blendedBoxMapManagerUI" Icon:#("SoulburnScripts_blendedBoxMapManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedBoxMapManager.ms"
	blendedBoxMapManagerUI()
	)

MacroScript blendedCubeProjectionMaker category:"SoulburnScripts" tooltip:"blendedCubeProjectionMaker" Icon:#("SoulburnScripts_blendedCubeProjectionMaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedCubeProjectionMaker.ms"
	on execute do blendedCubeProjectionMakerDefaults()
	on Altexecute type do blendedCubeProjectionMakerUI()
	)
	
MacroScript blendedCubeProjectionMakerUI category:"SoulburnScripts" tooltip:"blendedCubeProjectionMakerUI" Icon:#("SoulburnScripts_blendedCubeProjectionMakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedCubeProjectionMaker.ms"
	blendedCubeProjectionMakerUI()
	)

MacroScript blendedCubeProjectionManager category:"SoulburnScripts" tooltip:"blendedCubeProjectionManager" Icon:#("SoulburnScripts_blendedCubeProjectionManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedCubeProjectionManager.ms"
	on execute do blendedCubeProjectionManagerDefaults()
	on Altexecute type do blendedCubeProjectionManagerUI()
	)
	
MacroScript blendedCubeProjectionManagerUI category:"SoulburnScripts" tooltip:"blendedCubeProjectionManagerUI" Icon:#("SoulburnScripts_blendedCubeProjectionManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/blendedCubeProjectionManager.ms"
	blendedCubeProjectionManagerUI()
	)

MacroScript calculatorLauncher category:"SoulburnScripts" tooltip:"calculatorLauncher" Icon:#("SoulburnScripts_calculatorLauncher",1)
	(
	Include "$scripts/SoulburnScripts/scripts/calculatorLauncher.ms"
	on execute do calculatorLauncherDefaults()
	on Altexecute type do calculatorLauncherUI()
	)
	
MacroScript calculatorLauncherUI category:"SoulburnScripts" tooltip:"calculatorLauncherUI" Icon:#("SoulburnScripts_calculatorLauncherUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/calculatorLauncher.ms"
	calculatorLauncherUI()
	)
	
MacroScript cameraFromPerspView category:"SoulburnScripts" tooltip:"cameraFromPerspView" Icon:#("SoulburnScripts_cameraFromPerspView",1)
	(
	Include "$scripts/SoulburnScripts/scripts/cameraFromPerspView.ms"
	on execute do cameraFromPerspViewDefaults()
	on Altexecute type do cameraFromPerspViewUI()
	)
	
MacroScript cameraFromPerspViewUI category:"SoulburnScripts" tooltip:"cameraFromPerspViewUI" Icon:#("SoulburnScripts_cameraFromPerspViewUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/cameraFromPerspView.ms"
	cameraFromPerspViewUI()
	)
	
MacroScript cameraLensPackager category:"SoulburnScripts" tooltip:"cameraLensPackager" Icon:#("SoulburnScripts_cameraLensPackager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/cameraLensPackager.ms"
	on execute do cameraLensPackagerDefaults()
	on Altexecute type do cameraLensPackagerUI()
	)
	
MacroScript cameraLensPackagerUI category:"SoulburnScripts" tooltip:"cameraLensPackagerUI" Icon:#("SoulburnScripts_cameraLensPackagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/cameraLensPackager.ms"
	cameraLensPackagerUI()
	)

MacroScript cameraMapTemplateRenderer category:"SoulburnScripts" tooltip:"cameraMapTemplateRenderer" Icon:#("SoulburnScripts_cameraMapTemplateRenderer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/cameraMapTemplateRenderer.ms"
	on execute do cameraMapTemplateRendererDefaults()
	on Altexecute type do cameraMapTemplateRendererUI()
	)
	
MacroScript cameraMapTemplateRendererUI category:"SoulburnScripts" tooltip:"cameraMapTemplateRendererUI" Icon:#("SoulburnScripts_cameraMapTemplateRendererUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/cameraMapTemplateRenderer.ms"
	cameraMapTemplateRendererUI()
	)
	
MacroScript circleArrayMaker category:"SoulburnScripts" tooltip:"circleArrayMaker" Icon:#("SoulburnScripts_circleArrayMaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/circleArrayMaker.ms"
	on execute do circleArrayMakerDefaults()
	on Altexecute type do circleArrayMakerUI()
	)
	
MacroScript circleArrayMakerUI category:"SoulburnScripts" tooltip:"circleArrayMakerUI" Icon:#("SoulburnScripts_circleArrayMakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/circleArrayMaker.ms"
	circleArrayMakerUI()
	)

MacroScript curvatureMaker category:"SoulburnScripts" tooltip:"curvatureMaker" Icon:#("SoulburnScripts_curvatureMaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/curvatureMaker.ms"
	on execute do curvatureMakerDefaults()
	on Altexecute type do curvatureMakerUI()
	)
	
MacroScript curvatureMakerUI category:"SoulburnScripts" tooltip:"curvatureMakerUI" Icon:#("SoulburnScripts_curvatureMakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/curvatureMaker.ms"
	curvatureMakerUI()
	)
	
MacroScript curvatureManager category:"SoulburnScripts" tooltip:"curvatureManager" Icon:#("SoulburnScripts_curvatureManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/curvatureManager.ms"
	on execute do curvatureManagerDefaults()
	on Altexecute type do curvatureManagerUI()
	)
	
MacroScript curvatureManagerUI category:"SoulburnScripts" tooltip:"curvatureManagerUI" Icon:#("SoulburnScripts_curvatureManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/curvatureManager.ms"
	curvatureManagerUI()
	)

MacroScript customAttributeRemover category:"SoulburnScripts" tooltip:"customAttributeRemover" Icon:#("SoulburnScripts_customAttributeRemover",1)
	(
	Include "$scripts/SoulburnScripts/scripts/customAttributeRemover.ms"
	on execute do customAttributeRemoverDefaults()
	on Altexecute type do customAttributeRemoverUI()
	)
	
MacroScript customAttributeRemoverUI category:"SoulburnScripts" tooltip:"customAttributeRemoverUI" Icon:#("SoulburnScripts_customAttributeRemoverUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/customAttributeRemover.ms"
	customAttributeRemoverUI()
	)

MacroScript edgeDivider category:"SoulburnScripts" tooltip:"edgeDivider" Icon:#("SoulburnScripts_edgeDivider",1)
	(
	Include "$scripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDividerDefaults()
	on Altexecute type do edgeDividerUI()
	)
	
MacroScript edgeDividerUI category:"SoulburnScripts" tooltip:"edgeDividerUI" Icon:#("SoulburnScripts_edgeDividerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/edgeDivider.ms"
	edgeDividerUI()
	)
	
MacroScript edgeDivider2 category:"SoulburnScripts" tooltip:"edgeDivider2" Icon:#("SoulburnScripts_edgeDivider2",1)
	(
	Include "$scripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDivider 2
	on Altexecute type do edgeDividerUI()
	)

MacroScript edgeDivider3 category:"SoulburnScripts" tooltip:"edgeDivider3" Icon:#("SoulburnScripts_edgeDivider3",1)
	(
	Include "$scripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDivider 3
	on Altexecute type do edgeDividerUI()
	)
	
MacroScript edgeDivider4 category:"SoulburnScripts" tooltip:"edgeDivider4" Icon:#("SoulburnScripts_edgeDivider4",1)
	(
	Include "$scripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDivider 4
	on Altexecute type do edgeDividerUI()
	)

MacroScript edgeSelectByAngle category:"SoulburnScripts" tooltip:"edgeSelectByAngle" Icon:#("SoulburnScripts_edgeSelectByAngle",1)
	(
	Include "$scripts/SoulburnScripts/scripts/edgeSelectByAngle.ms"
	on execute do edgeSelectByAngleDefaults()
	on Altexecute type do edgeSelectByAngleUI()
	)
	
MacroScript edgeSelectByAngleUI category:"SoulburnScripts" tooltip:"edgeSelectByAngleUI" Icon:#("SoulburnScripts_edgeSelectByAngleUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/edgeSelectByAngle.ms"
	edgeSelectByAngleUI()
	)

MacroScript elementSelectByFace category:"SoulburnScripts" tooltip:"elementSelectByFace" Icon:#("SoulburnScripts_elementSelectByFace",1)
	(
	Include "$scripts/SoulburnScripts/scripts/elementSelectByFace.ms"
	on execute do elementSelectByFaceDefaults()
	on Altexecute type do elementSelectByFaceUI()
	)
	
MacroScript elementSelectByFaceUI category:"SoulburnScripts" tooltip:"elementSelectByFaceUI" Icon:#("SoulburnScripts_elementSelectByFaceUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/elementSelectByFace.ms"
	elementSelectByFaceUI()
	)

MacroScript geometryBanger category:"SoulburnScripts" tooltip:"geometryBanger" Icon:#("SoulburnScripts_geometryBanger",1)
	(
	Include "$scripts/SoulburnScripts/scripts/geometryBanger.ms"
	on execute do geometryBangerDefaults()
	on Altexecute type do geometryBangerUI()
	)
	
MacroScript geometryBangerUI category:"SoulburnScripts" tooltip:"geometryBangerUI" Icon:#("SoulburnScripts_geometryBangerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/geometryBanger.ms"
	geometryBangerUI()
	)

MacroScript groupWithPoint category:"SoulburnScripts" tooltip:"groupWithPoint" Icon:#("SoulburnScripts_groupWithPoint",1)
	(
	Include "$scripts/SoulburnScripts/scripts/groupWithPoint.ms"
	on execute do groupWithPointDefaults()
	on Altexecute type do groupWithPointUI()
	)

MacroScript groupWithPointUI category:"SoulburnScripts" tooltip:"groupWithPointUI" Icon:#("SoulburnScripts_groupWithPointUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/groupWithPoint.ms"
	groupWithPointUI()
	)
	
MacroScript groupWithPointGroup category:"SoulburnScripts" tooltip:"groupWithPointGroup" Icon:#("SoulburnScripts_groupWithPointGroup",1)
	(
	Include "$scripts/SoulburnScripts/scripts/groupWithPoint.ms"
	on execute do groupWithPoint 1 1 true 100 true 2 1
	on Altexecute type do groupWithPointUI()
	)
	
MacroScript groupWithPointUnGroup category:"SoulburnScripts" tooltip:"groupWithPointUnGroup" Icon:#("SoulburnScripts_groupWithPointUnGroup",1)
	(
	Include "$scripts/SoulburnScripts/scripts/groupWithPoint.ms"
	on execute do groupWithPoint 2 1 true 100 true 2 1
	on Altexecute type do groupWithPointUI()
	)

MacroScript iDSetter category:"SoulburnScripts" tooltip:"iDSetter" Icon:#("SoulburnScripts_iDSetter",1)
	(
	Include "$scripts/SoulburnScripts/scripts/iDSetter.ms"
	on execute do iDSetterDefaults()
	on Altexecute type do iDSetterUI()
	)

MacroScript iDSetterUI category:"SoulburnScripts" tooltip:"iDSetterUI" Icon:#("SoulburnScripts_iDSetterUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/iDSetter.ms"
	iDSetterUI()
	)

MacroScript imagePlaneMaker category:"SoulburnScripts" tooltip:"imagePlaneMaker" Icon:#("SoulburnScripts_imagePlaneMaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/imagePlaneMaker.ms"
	on execute do imagePlaneMakerDefaults()
	on Altexecute type do imagePlaneMakerUI()
	)
	
MacroScript imagePlaneMakerUI category:"SoulburnScripts" tooltip:"imagePlaneMakerUI" Icon:#("SoulburnScripts_imagePlaneMakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/imagePlaneMaker.ms"
	imagePlaneMakerUI()
	)

MacroScript instanceFinder category:"SoulburnScripts" tooltip:"instanceFinder" Icon:#("SoulburnScripts_instanceFinder",1)
	(
	Include "$scripts/SoulburnScripts/scripts/instanceFinder.ms"
	on execute do instanceFinderDefaults()
	on Altexecute type do instanceFinderUI()
	)
	
MacroScript instanceFinderUI category:"SoulburnScripts" tooltip:"instanceFinderUI" Icon:#("SoulburnScripts_instanceFinderUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/instanceFinder.ms"
	instanceFinderUI()
	)

MacroScript instanceTrimmer category:"SoulburnScripts" tooltip:"instanceTrimmer" Icon:#("SoulburnScripts_instanceTrimmer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/instanceTrimmer.ms"
	on execute do instanceTrimmerDefaults()
	on Altexecute type do instanceTrimmerUI()
	)
	
MacroScript instanceTrimmerUI category:"SoulburnScripts" tooltip:"instanceTrimmerUI" Icon:#("SoulburnScripts_instanceTrimmerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/instanceTrimmer.ms"
	instanceTrimmerUI()
	)
	
MacroScript layerCleaner category:"SoulburnScripts" tooltip:"layerCleaner" Icon:#("SoulburnScripts_layerCleaner",1)
	(
	Include "$scripts/SoulburnScripts/scripts/layerCleaner.ms"
	on execute do layerCleanerDefaults()
	on Altexecute type do layerCleanerUI()
	)
	
MacroScript layerCleanerUI category:"SoulburnScripts" tooltip:"layerCleanerUI" Icon:#("SoulburnScripts_layerCleanerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/layerCleaner.ms"
	layerCleanerUI()
	)

MacroScript materialFromSelectedObject category:"SoulburnScripts" tooltip:"materialFromSelectedObject" Icon:#("SoulburnScripts_materialFromSelectedObject",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialFromSelectedObject.ms"
	on execute do materialFromSelectedObjectDefaults()
	on Altexecute type do materialFromSelectedObjectUI()
	)
	
MacroScript materialFromSelectedObjectUI category:"SoulburnScripts" tooltip:"materialFromSelectedObjectUI" Icon:#("SoulburnScripts_materialFromSelectedObjectUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialFromSelectedObject.ms"
	materialFromSelectedObjectUI()
	)

MacroScript materialInfoDisplayer category:"SoulburnScripts" tooltip:"materialInfoDisplayer" Icon:#("SoulburnScripts_materialInfoDisplayer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialInfoDisplayer.ms"
	on execute do materialInfoDisplayerDefaults()
	on Altexecute type do materialInfoDisplayerUI()
	)

MacroScript materialInfoDisplayerUI category:"SoulburnScripts" tooltip:"materialInfoDisplayerUI" Icon:#("SoulburnScripts_materialInfoDisplayerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialInfoDisplayer.ms"
	materialInfoDisplayerUI()
	)

MacroScript materialMover category:"SoulburnScripts" tooltip:"materialMover" Icon:#("SoulburnScripts_materialMover",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMoverDefaults()
	on Altexecute type do materialMoverUI()
	)

MacroScript materialMoverUI category:"SoulburnScripts" tooltip:"materialMoverUI" Icon:#("SoulburnScripts_materialMoverUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialMover.ms"
	materialMoverUI()
	)

MacroScript materialMoverBlankSceneMatsStandard category:"SoulburnScripts" tooltip:"materialMoverBlankSceneMatsStandard" Icon:#("SoulburnScripts_materialMoverBlankSceneMatsStandard",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 5 1 1 24 1 true 2 1 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditStandard category:"SoulburnScripts" tooltip:"materialMoverCleanMeditStandard" Icon:#("SoulburnScripts_materialMoverCleanMeditStandard",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 1 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditBrazil2 category:"SoulburnScripts" tooltip:"materialMoverCleanMeditBrazil2" Icon:#("SoulburnScripts_materialMoverCleanMeditBrazil2",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 4 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditMentalRayAD category:"SoulburnScripts" tooltip:"materialMoverCleanMeditMentalRayAD" Icon:#("SoulburnScripts_materialMoverCleanMeditMentalRayAD",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 5 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditVrayMtl category:"SoulburnScripts" tooltip:"materialMoverCleanMeditVrayMtl" Icon:#("SoulburnScripts_materialMoverCleanMeditVray",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 6 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialRemover category:"SoulburnScripts" tooltip:"materialRemover" Icon:#("SoulburnScripts_materialRemover",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialRemover.ms"
	on execute do materialRemoverDefaults()
	on Altexecute type do materialRemoverUI()
	)

MacroScript materialRemoverUI category:"SoulburnScripts" tooltip:"materialRemoverUI" Icon:#("SoulburnScripts_materialRemoverUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/materialRemover.ms"
	materialRemoverUI()
	)

MacroScript maxfileOldVersionSaver category:"SoulburnScripts" tooltip:"maxfileOldVersionSaver" Icon:#("SoulburnScripts_maxfileOldVersionSaver",1)
	(
	Include "$scripts/SoulburnScripts/scripts/maxfileOldVersionSaver.ms"
	on execute do maxfileOldVersionSaverDefaults()
	on Altexecute type do maxfileOldVersionSaverUI()
	)

MacroScript maxfileOldVersionSaverUI category:"SoulburnScripts" tooltip:"maxfileOldVersionSaverUI" Icon:#("SoulburnScripts_maxfileOldVersionSaverUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/maxfileOldVersionSaver.ms"
	maxfileOldVersionSaverUI()
	)

MacroScript mirrorObjectAlongAxis category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxis" Icon:#("SoulburnScripts_mirrorObjectAlongAxis",1)
	(
	Include "$scripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxisDefaults()
	on Altexecute type do mirrorObjectAlongAxisUI()
	)
	
MacroScript mirrorObjectAlongAxisUI category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisUI" Icon:#("SoulburnScripts_mirrorObjectAlongAxisUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	mirrorObjectAlongAxisUI()
	)

MacroScript mirrorObjectAlongAxisX category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisX" Icon:#("SoulburnScripts_mirrorObjectAlongAxisX",1)
	(
	Include "$scripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxis 1 2 true
	on Altexecute type do mirrorObjectAlongAxisUI()
	)
	
MacroScript mirrorObjectAlongAxisY category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisY" Icon:#("SoulburnScripts_mirrorObjectAlongAxisY",1)
	(
	Include "$scripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxis 2 2 true
	on Altexecute type do mirrorObjectAlongAxisUI()
	)
	
MacroScript mirrorObjectAlongAxisZ category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisZ" Icon:#("SoulburnScripts_mirrorObjectAlongAxisZ",1)
	(
	Include "$scripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxis 2 3 true
	on Altexecute type do mirrorObjectAlongAxisUI()
	)

MacroScript modelPreparer category:"SoulburnScripts" tooltip:"modelPreparer" Icon:#("SoulburnScripts_modelPreparer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/modelPreparer.ms"
	on execute do modelPreparerDefaults()
	on Altexecute type do modelPreparerUI()
	)

MacroScript modelPreparerUI category:"SoulburnScripts" tooltip:"modelPreparerUI" Icon:#("SoulburnScripts_modelPreparerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/modelPreparer.ms"
	modelPreparerUI()
	)

MacroScript modifierUtilities category:"SoulburnScripts" tooltip:"modifierUtilities" Icon:#("SoulburnScripts_modifierUtilities",1)
	(
	Include "$scripts/SoulburnScripts/scripts/modifierUtilities.ms"
	on execute do modifierUtilitiesDefaults()
	on Altexecute type do modifierUtilitiesUI()
	)

MacroScript modifierUtilitiesUI category:"SoulburnScripts" tooltip:"modifierUtilitiesUI" Icon:#("SoulburnScripts_modifierUtilitiesUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/modifierUtilities.ms"
	modifierUtilitiesUI()
	)

MacroScript nameManager category:"SoulburnScripts" tooltip:"nameManager" Icon:#("SoulburnScripts_nameManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/nameManager.ms"
	on execute do nameManagerDefaults()
	on Altexecute type do nameManagerUI()
	)

MacroScript nameManagerUI category:"SoulburnScripts" tooltip:"nameManagerUI" Icon:#("SoulburnScripts_nameManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/nameManager.ms"
	nameManagerUI()
	)

MacroScript nodeTypeDisplayer category:"SoulburnScripts" tooltip:"nodeTypeDisplayer" Icon:#("SoulburnScripts_nodeTypeDisplayer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/nodeTypeDisplayer.ms"
	on execute do nodeTypeDisplayerDefaults()
	on Altexecute type do nodeTypeDisplayerUI()
	)
	
MacroScript nodeTypeDisplayerUI category:"SoulburnScripts" tooltip:"nodeTypeDisplayerUI" Icon:#("SoulburnScripts_nodeTypeDisplayerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/nodeTypeDisplayer.ms"
	nodeTypeDisplayerUI()
	)

MacroScript objectAttacher category:"SoulburnScripts" tooltip:"objectAttacher" Icon:#("SoulburnScripts_objectAttacher",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectAttacher.ms"
	on execute do objectAttacherDefaults()
	on Altexecute type do objectAttacherUI()
	)
	
MacroScript objectAttacherUI category:"SoulburnScripts" tooltip:"objectAttacherUI" Icon:#("SoulburnScripts_objectAttacherUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectAttacher.ms"
	objectAttacherUI()
	)

MacroScript objectDetacher category:"SoulburnScripts" tooltip:"objectDetacher" Icon:#("SoulburnScripts_objectDetacher",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectDetacher.ms"
	on execute do objectDetacherDefaults()
	on Altexecute type do objectDetacherUI()
	)

MacroScript objectDetacherUI category:"SoulburnScripts" tooltip:"objectDetacherUI" Icon:#("SoulburnScripts_objectDetacherUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectDetacher.ms"
	objectDetacherUI()
	)
	
MacroScript objectDropper category:"SoulburnScripts" tooltip:"objectDropper" Icon:#("SoulburnScripts_objectDropper",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectDropper.ms"
	on execute do objectDropperDefaults()
	on Altexecute type do objectDropperUI()
	)

MacroScript objectDropperUI category:"SoulburnScripts" tooltip:"objectDropperUI" Icon:#("SoulburnScripts_objectDropperUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectDropper.ms"
	objectDropperUI()
	)

MacroScript objectPainter category:"SoulburnScripts" tooltip:"objectPainter" Icon:#("SoulburnScripts_objectPainter",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectPainter.ms"
	on execute do objectPainterDefaults()
	on Altexecute type do objectPainterUI()
	)
	
MacroScript objectPainterUI category:"SoulburnScripts" tooltip:"objectPainterUI" Icon:#("SoulburnScripts_objectPainterUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectPainter.ms"
	objectPainterUI()
	)

MacroScript objectReplacer category:"SoulburnScripts" tooltip:"objectReplacer" Icon:#("SoulburnScripts_objectReplacer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectReplacer.ms"
	on execute do objectReplacerDefaults()
	on Altexecute type do objectReplacerUI()
	)

MacroScript objectReplacerUI category:"SoulburnScripts" tooltip:"objectReplacerUI" Icon:#("SoulburnScripts_objectReplacerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectReplacer.ms"
	objectReplacerUI()
	)

MacroScript objectSelectorByMaterial category:"SoulburnScripts" tooltip:"objectSelectorByMaterial" Icon:#("SoulburnScripts_objectSelectorByMaterial",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectSelectorByMaterial.ms"
	on execute do objectSelectorByMaterialDefaults()
	on Altexecute type do objectSelectorByMaterialUI()
	)
	
MacroScript objectSelectorByMaterialUI category:"SoulburnScripts" tooltip:"objectSelectorByMaterialUI" Icon:#("SoulburnScripts_objectSelectorByMaterialUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectSelectorByMaterial.ms"
	objectSelectorByMaterialUI()
	)

MacroScript objectUniquefier category:"SoulburnScripts" tooltip:"objectUniquefier" Icon:#("SoulburnScripts_objectUniquefier",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectUniquefier.ms"
	on execute do objectUniquefierDefaults()
	on Altexecute type do objectUniquefierUI()
	)
	
MacroScript objectUniquefierUI category:"SoulburnScripts" tooltip:"objectUniquefierUI" Icon:#("SoulburnScripts_objectUniquefierUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/objectUniquefier.ms"
	objectUniquefierUI()
	)

MacroScript parameterManager category:"SoulburnScripts" tooltip:"parameterManager" Icon:#("SoulburnScripts_parameterManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/parameterManager.ms"
	on execute do parameterManagerDefaults()
	on Altexecute type do parameterManagerUI()
	)
	
MacroScript parameterManagerUI category:"SoulburnScripts" tooltip:"parameterManagerUI" Icon:#("SoulburnScripts_parameterManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/parameterManager.ms"
	parameterManagerUI()
	)

MacroScript parentSelector category:"SoulburnScripts" tooltip:"parentSelector" Icon:#("SoulburnScripts_parentSelector",1)
	(
	Include "$scripts/SoulburnScripts/scripts/parentSelector.ms"
	on execute do parentSelectorDefaults()
	on Altexecute type do parentSelectorUI()
	)
	
MacroScript parentSelectorUI category:"SoulburnScripts" tooltip:"parentSelectorUI" Icon:#("SoulburnScripts_parentSelectorUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/parentSelector.ms"
	parentSelectorUI()
	)

MacroScript pFlowRemover category:"SoulburnScripts" tooltip:"pFlowRemover" Icon:#("SoulburnScripts_pFlowRemover",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pFlowRemover.ms"
	on execute do pFlowRemoverDefaults()
	on Altexecute type do pFlowRemoverUI()
	)
	
MacroScript pFlowRemoverUI category:"SoulburnScripts" tooltip:"pFlowRemoverUI" Icon:#("SoulburnScripts_pFlowRemoverUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pFlowRemover.ms"
	pFlowRemoverUI()
	)

MacroScript pipeMaker category:"SoulburnScripts" tooltip:"pipeMaker" Icon:#("SoulburnScripts_pipeMaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pipeMaker.ms"
	on execute do pipeMakerDefaults()
	on Altexecute type do pipeMakerUI()
	)
	
MacroScript pipeMakerUI category:"SoulburnScripts" tooltip:"pipeMakerUI" Icon:#("SoulburnScripts_pipeMakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pipeMaker.ms"
	pipeMakerUI()
	)

MacroScript pivotPlacer category:"SoulburnScripts" tooltip:"pivotPlacer" Icon:#("SoulburnScripts_pivotPlacer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pivotPlacer.ms"
	on execute do pivotPlacerDefaults()
	on Altexecute type do pivotPlacerUI()
	)

MacroScript pivotPlacerUI category:"SoulburnScripts" tooltip:"pivotPlacerUI" Icon:#("SoulburnScripts_pivotPlacerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pivotPlacer.ms"
	pivotPlacerUI()
	)

MacroScript pivotPlacerExpertMode category:"SoulburnScripts" tooltip:"pivotPlacerExpertMode" Icon:#("SoulburnScripts_pivotPlacerExpertMode",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pivotPlacer.ms"
	pivotPlacerExpertMode()
	)
	
MacroScript pivotPlacerCenter category:"SoulburnScripts" tooltip:"pivotPlacerCenter" Icon:#("SoulburnScripts_pivotPlacerCenter",1)
	(
	Include "$scripts/SoulburnScripts/scripts/pivotPlacer.ms"
	on execute do pivotPlacer 14 1 true 1
	on Altexecute type do pivotPlacerUI()
	)

MacroScript polyCountSelector category:"SoulburnScripts" tooltip:"polyCountSelector" Icon:#("SoulburnScripts_polyCountSelector",1)
	(
	Include "$scripts/SoulburnScripts/scripts/polyCountSelector.ms"
	on execute do polyCountSelectorDefaults()
	on Altexecute type do polyCountSelectorUI()
	)
	
MacroScript polyCountSelectorUI category:"SoulburnScripts" tooltip:"polyCountSelectorUI" Icon:#("SoulburnScripts_polyCountSelectorUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/polyCountSelector.ms"
	polyCountSelectorUI()
	)

MacroScript renderSizer category:"SoulburnScripts" tooltip:"renderSizer" Icon:#("SoulburnScripts_renderSizer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/renderSizer.ms"
	on execute do renderSizerDefaults()
	on Altexecute type do renderSizerUI()
	)
	
MacroScript renderSizerUI category:"SoulburnScripts" tooltip:"renderSizerUI" Icon:#("SoulburnScripts_renderSizerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/renderSizer.ms"
	renderSizerUI()
	)

MacroScript selectionRandomizer category:"SoulburnScripts" tooltip:"selectionRandomizer" Icon:#("SoulburnScripts_selectionRandomizer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/selectionRandomizer.ms"
	on execute do selectionRandomizerDefaults()
	on Altexecute type do selectionRandomizerUI()
	)

MacroScript selectionRandomizerUI category:"SoulburnScripts" tooltip:"selectionRandomizerUI" Icon:#("SoulburnScripts_selectionRandomizerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/selectionRandomizer.ms"
	selectionRandomizerUI()
	)

MacroScript snapShoter category:"SoulburnScripts" tooltip:"snapShoter" Icon:#("SoulburnScripts_snapShoter",1)
	(
	Include "$scripts/SoulburnScripts/scripts/snapShoter.ms"
	on execute do snapShoterDefaults()
	on Altexecute type do snapShoterUI()
	)

MacroScript snapShoterUI category:"SoulburnScripts" tooltip:"snapShoterUI" Icon:#("SoulburnScripts_snapShoterUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/snapShoter.ms"
	snapShoterUI()
	)

MacroScript softSelectionControl category:"SoulburnScripts" tooltip:"softSelectionControl" Icon:#("SoulburnScripts_softSelectionControl",1)
	(
	Include "$scripts/SoulburnScripts/scripts/softSelectionControl.ms"
	on execute do softSelectionControlDefaults()
	on Altexecute type do softSelectionControlUI()
	)
	
MacroScript softSelectionControlUI category:"SoulburnScripts" tooltip:"softSelectionControlUI" Icon:#("SoulburnScripts_softSelectionControlUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/softSelectionControl.ms"
	softSelectionControlUI()
	)

MacroScript soulburnAssetLoaderUI category:"SoulburnScripts" tooltip:"soulburnAssetLoaderUI" Icon:#("SoulburnScripts_soulburnAssetLoaderUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/soulburnAssetLoader.ms"
	soulburnAssetLoaderUI()
	)

MacroScript soulburnScriptsLister category:"SoulburnScripts" tooltip:"soulburnScriptsLister" Icon:#("SoulburnScripts_soulburnScriptsLister",1)
	(
	Include "$scripts/SoulburnScripts/scripts/soulburnScriptsLister.ms"
	on execute do soulburnScriptsListerDefaults()
	on Altexecute type do soulburnScriptsListerUI()
	)

MacroScript soulburnScriptsListerUI category:"SoulburnScripts" tooltip:"soulburnScriptsListerUI" Icon:#("SoulburnScripts_soulburnScriptsListerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/soulburnScriptsLister.ms"
	soulburnScriptsListerUI()
	)
	
MacroScript splineKnotManager category:"SoulburnScripts" tooltip:"splineKnotManager" Icon:#("SoulburnScripts_splineKnotManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splineKnotManager.ms"
	on execute do splineKnotManagerDefaults()
	on Altexecute type do splineKnotManagerUI()
	)

MacroScript splineKnotManagerUI category:"SoulburnScripts" tooltip:"splineKnotManagerUI" Icon:#("SoulburnScripts_splineKnotManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splineKnotManager.ms"
	splineKnotManagerUI()
	)
	
MacroScript splineKnotToObject category:"SoulburnScripts" tooltip:"splineKnotToObject" Icon:#("SoulburnScripts_splineKnotToObject",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splineKnotToObject.ms"
	on execute do splineKnotToObjectDefaults()
	on Altexecute type do splineKnotToObjectUI()
	)

MacroScript splineKnotToObjectUI category:"SoulburnScripts" tooltip:"splineKnotToObjectUI" Icon:#("SoulburnScripts_splineKnotToObjectUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splineKnotToObject.ms"
	splineKnotToObjectUI()
	)

MacroScript splineManager category:"SoulburnScripts" tooltip:"splineManager" Icon:#("SoulburnScripts_splineManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splineManager.ms"
	on execute do splineManagerDefaults()
	on Altexecute type do splineManagerUI()
	)

MacroScript splineManagerUI category:"SoulburnScripts" tooltip:"splineManagerUI" Icon:#("SoulburnScripts_splineManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splineManager.ms"
	splineManagerUI()
	)
	
MacroScript splinePainter category:"SoulburnScripts" tooltip:"splinePainter" Icon:#("SoulburnScripts_splinePainter",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splinePainter.ms"
	on execute do splinePainterDefaults()
	on Altexecute type do splinePainterUI()
	)

MacroScript splinePainterUI category:"SoulburnScripts" tooltip:"splinePainterUI" Icon:#("SoulburnScripts_splinePainterUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/splinePainter.ms"
	splinePainterUI()
	)
	
MacroScript subdivisionAutomator category:"SoulburnScripts" tooltip:"subdivisionAutomator" Icon:#("SoulburnScripts_subdivisionAutomator",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionAutomator.ms"
	on execute do subdivisionAutomatorDefaults()
	on Altexecute type do subdivisionAutomatorUI()
	)

MacroScript subdivisionAutomatorUI category:"SoulburnScripts" tooltip:"subdivisionAutomatorUI" Icon:#("SoulburnScripts_subdivisionAutomatorUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionAutomator.ms"
	subdivisionAutomatorUI()
	)

MacroScript subdivisionIterationManip category:"SoulburnScripts" tooltip:"subdivisionIterationManip" Icon:#("SoulburnScripts_subdivisionIterationManip",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionIterationManip.ms"
	on execute do subdivisionIterationManipDefaults()
	on Altexecute type do subdivisionIterationManipUI()
	)

MacroScript subdivisionIterationManipUI category:"SoulburnScripts" tooltip:"subdivisionIterationManipUI" Icon:#("SoulburnScripts_subdivisionIterationManipUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionIterationManip.ms"
	subdivisionIterationManipUI()
	)
	
MacroScript subdivisionIterationManipPolyUp category:"SoulburnScripts" tooltip:"subdivisionIterationManipPolyUp" Icon:#("SoulburnScripts_subdivisionIterationManipPolyUp",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionIterationManip.ms"
	on execute do subdivisionIterationManip true false false false 1
	on Altexecute type do subdivisionIterationManipUI()
	)
	
MacroScript subdivisionIterationManipPolyDown category:"SoulburnScripts" tooltip:"subdivisionIterationManipPolyDown" Icon:#("SoulburnScripts_subdivisionIterationManipPolyDown",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionIterationManip.ms"
	on execute do subdivisionIterationManip true false false false 2
	on Altexecute type do subdivisionIterationManipUI()
	)

MacroScript subdivisionIterationManipOSDUp category:"SoulburnScripts" tooltip:"subdivisionIterationManipOSDUp" Icon:#("SoulburnScripts_subdivisionIterationManipOSDUp",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionIterationManip.ms"
	on execute do subdivisionIterationManip false false false true 1
	on Altexecute type do subdivisionIterationManipUI()
	)
	
MacroScript subdivisionIterationManipOSDDown category:"SoulburnScripts" tooltip:"subdivisionIterationManipOSDDown" Icon:#("SoulburnScripts_subdivisionIterationManipOSDDown",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionIterationManip.ms"
	on execute do subdivisionIterationManip false false false true 2
	on Altexecute type do subdivisionIterationManipUI()
	)

MacroScript subdivisionManager category:"SoulburnScripts" tooltip:"subdivisionManager" Icon:#("SoulburnScripts_subdivisionManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionManager.ms"
	on execute do subdivisionManagerDefaults()
	on Altexecute type do subdivisionManagerUI()
	)

MacroScript subdivisionManagerUI category:"SoulburnScripts" tooltip:"subdivisionManagerUI" Icon:#("SoulburnScripts_subdivisionManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/subdivisionManager.ms"
	subdivisionManagerUI()
	)

MacroScript texmapBaker category:"SoulburnScripts" tooltip:"texmapBaker" Icon:#("SoulburnScripts_texmapBaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/texmapBaker.ms"
	on execute do texmapBakerDefaults()
	on Altexecute type do texmapBakerUI()
	)

MacroScript texmapBakerUI category:"SoulburnScripts" tooltip:"texmapBakerUI" Icon:#("SoulburnScripts_texmapBakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/texmapBaker.ms"
	texmapBakerUI()
	)

MacroScript texmapPreview category:"SoulburnScripts" tooltip:"texmapPreview" Icon:#("SoulburnScripts_texmapPreview",1)
	(
	Include "$scripts/SoulburnScripts/scripts/texmapPreview.ms"
	on execute do texmapPreviewDefaults()
	on Altexecute type do texmapPreviewUI()
	)

MacroScript texmapPreviewUI category:"SoulburnScripts" tooltip:"texmapPreviewUI" Icon:#("SoulburnScripts_texmapPreviewUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/texmapPreview.ms"
	texmapPreviewUI()
	)
	
MacroScript thinFaceSelector category:"SoulburnScripts" tooltip:"thinFaceSelector" Icon:#("SoulburnScripts_thinFaceSelector",1)
	(
	Include "$scripts/SoulburnScripts/scripts/thinFaceSelector.ms"
	on execute do thinFaceSelectorDefaults()
	on Altexecute type do thinFaceSelectorUI()
	)

MacroScript thinFaceSelectorUI category:"SoulburnScripts" tooltip:"thinFaceSelectorUI" Icon:#("SoulburnScripts_thinFaceSelectorUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/thinFaceSelector.ms"
	thinFaceSelectorUI()
	)

MacroScript transformRandomizer category:"SoulburnScripts" tooltip:"transformRandomizer" Icon:#("SoulburnScripts_transformRandomizer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformRandomizer.ms"
	on execute do transformRandomizerDefaults()
	on Altexecute type do transformRandomizerUI()
	)

MacroScript transformRandomizerUI category:"SoulburnScripts" tooltip:"transformRandomizerUI" Icon:#("SoulburnScripts_transformRandomizerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformRandomizer.ms"
	transformRandomizerUI()
	)
	
MacroScript transformRemover category:"SoulburnScripts" tooltip:"transformRemover" Icon:#("SoulburnScripts_transformRemover",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemoverDefaults()
	on Altexecute type do transformRemoverUI()
	)

MacroScript transformRemoverUI category:"SoulburnScripts" tooltip:"transformRemoverUI" Icon:#("SoulburnScripts_transformRemoverUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformRemover.ms"
	transformRemoverUI()
	)
	
MacroScript transformRemoverPosition category:"SoulburnScripts" tooltip:"transformRemoverPosition" Icon:#("SoulburnScripts_transformRemoverPosition",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemover true true true false false false false false false true
	on Altexecute type do transformRemoverUI()
	)
	
MacroScript transformRemoverRotation category:"SoulburnScripts" tooltip:"transformRemoverRotation" Icon:#("SoulburnScripts_transformRemoverRotation",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemover false false false true true true false false false true
	on Altexecute type do transformRemoverUI()
	)
	
MacroScript transformRemoverScale category:"SoulburnScripts" tooltip:"transformRemoverScale" Icon:#("SoulburnScripts_transformRemoverScale",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemover false false false false false false true true true true
	on Altexecute type do transformRemoverUI()
	)

MacroScript transformSelector category:"SoulburnScripts" tooltip:"transformSelector" Icon:#("SoulburnScripts_transformSelector",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformSelector.ms"
	on execute do transformSelectorDefaults()
	on Altexecute type do transformSelectorUI()
	)
	
MacroScript transformSelectorUI category:"SoulburnScripts" tooltip:"transformSelectorUI" Icon:#("SoulburnScripts_transformSelectorUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/transformSelector.ms"
	transformSelectorUI()
	)
	
MacroScript twoDPlanView category:"SoulburnScripts" tooltip:"twoDPlanView" Icon:#("SoulburnScripts_twoDPlanView",1)
	(
	Include "$scripts/SoulburnScripts/scripts/twoDPlanView.ms"
	on execute do twoDPlanViewDefaults()
	on Altexecute type do twoDPlanViewUI()
	)
	
MacroScript twoDPlanViewUI category:"SoulburnScripts" tooltip:"twoDPlanViewUI" Icon:#("SoulburnScripts_twoDPlanViewUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/twoDPlanView.ms"
	twoDPlanViewUI()
	)

MacroScript uniqueObjectFinder category:"SoulburnScripts" tooltip:"uniqueObjectFinder" Icon:#("SoulburnScripts_uniqueObjectFinder",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uniqueObjectFinder.ms"
	on execute do uniqueObjectFinderDefaults()
	on Altexecute type do uniqueObjectFinderUI()
	)
	
MacroScript uniqueObjectFinderUI category:"SoulburnScripts" tooltip:"uniqueObjectFinderUI" Icon:#("SoulburnScripts_uniqueObjectFinderUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uniqueObjectFinder.ms"
	uniqueObjectFinderUI()
	)

MacroScript uVAreaDisplayer category:"SoulburnScripts" tooltip:"uVAreaDisplayer" Icon:#("SoulburnScripts_uVAreaDisplayer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVAreaDisplayer.ms"
	on execute do uVAreaDisplayerDefaults()
	on Altexecute type do uVAreaDisplayerUI()
	)
	
MacroScript uVAreaDisplayerUI category:"SoulburnScripts" tooltip:"uVAreaDisplayerUI" Icon:#("SoulburnScripts_uVAreaDisplayerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVAreaDisplayer.ms"
	uVAreaDisplayerUI()
	)

MacroScript uVFlattener category:"SoulburnScripts" tooltip:"uVFlattener" Icon:#("SoulburnScripts_uVFlattener",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattenerDefaults()
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerUI category:"SoulburnScripts" tooltip:"uVFlattenerUI" Icon:#("SoulburnScripts_uVFlattenerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	uVFlattenerUI()
	)
	
MacroScript uVFlattenerMinU category:"SoulburnScripts" tooltip:"uVFlattenerMinU" Icon:#("SoulburnScripts_uVFlattenerMinU",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 1 1
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerAverageU category:"SoulburnScripts" tooltip:"uVFlattenerAverageU" Icon:#("SoulburnScripts_uVFlattenerAverageU",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 2 1
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerMaxU category:"SoulburnScripts" tooltip:"uVFlattenerMaxU" Icon:#("SoulburnScripts_uVFlattenerMaxU",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 3 1
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerMinV category:"SoulburnScripts" tooltip:"uVFlattenerMinV" Icon:#("SoulburnScripts_uVFlattenerMinV",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 1 2
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerAverageV category:"SoulburnScripts" tooltip:"uVFlattenerAverageV" Icon:#("SoulburnScripts_uVFlattenerAverageV",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 2 2
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerMaxV category:"SoulburnScripts" tooltip:"uVFlattenerMaxV" Icon:#("SoulburnScripts_uVFlattenerMaxV",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 3 2
	on Altexecute type do uVFlattenerUI()
	)

MacroScript uVFlattenMapper category:"SoulburnScripts" tooltip:"uVFlattenMapper" Icon:#("SoulburnScripts_uVFlattenMapper",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattenMapper.ms"
	on execute do uVFlattenMapperDefaults()
	on Altexecute type do uVFlattenMapperUI()
	)
	
MacroScript uVFlattenMapperUI category:"SoulburnScripts" tooltip:"uVFlattenMapperUI" Icon:#("SoulburnScripts_uVFlattenMapperUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVFlattenMapper.ms"
	uVFlattenMapperUI()
	)

MacroScript uVPlacer category:"SoulburnScripts" tooltip:"uVPlacer" Icon:#("SoulburnScripts_uVPlacer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVPlacer.ms"
	on execute do uVPlacerDefaults()
	on Altexecute type do uVPlacerUI()
	)
	
MacroScript uVPlacerUI category:"SoulburnScripts" tooltip:"uVPlacerUI" Icon:#("SoulburnScripts_uVPlacerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVPlacer.ms"
	uVPlacerUI()
	)
	
MacroScript uVTransfer category:"SoulburnScripts" tooltip:"uVTransfer" Icon:#("SoulburnScripts_uVTransfer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVTransfer.ms"
	on execute do uVTransferDefaults()
	on Altexecute type do uVTransferUI()
	)
	
MacroScript uVTransferUI category:"SoulburnScripts" tooltip:"uVTransferUI" Icon:#("SoulburnScripts_uVTransferUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/uVTransfer.ms"
	uVTransferUI()
	)

MacroScript vertexAndEdgeConnector category:"SoulburnScripts" tooltip:"vertexAndEdgeConnector" Icon:#("SoulburnScripts_vertexAndEdgeConnector",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	on execute do vertexAndEdgeConnectorDefaults()
	on Altexecute type do vertexAndEdgeConnectorUI()
	)
	
MacroScript vertexAndEdgeConnectorUI category:"SoulburnScripts" tooltip:"vertexAndEdgeConnectorUI" Icon:#("SoulburnScripts_vertexAndEdgeConnectorUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	vertexAndEdgeConnectorUI()
	)

MacroScript vertexAndEdgeConnectorDialog category:"SoulburnScripts" tooltip:"vertexAndEdgeConnectorDialog" Icon:#("SoulburnScripts_vertexAndEdgeConnectorDialog",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	on execute do vertexAndEdgeConnector true false 1 0 0
	on Altexecute type do vertexAndEdgeConnectorUI()
	)
	
MacroScript vertexAndEdgeConnectorNoDialog category:"SoulburnScripts" tooltip:"vertexAndEdgeConnectorNoDialog" Icon:#("SoulburnScripts_vertexAndEdgeConnectorNoDialog",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	on execute do vertexAndEdgeConnector false false 1 0 0
	on Altexecute type do vertexAndEdgeConnectorUI()
	)
	
MacroScript vertexAndEdgeConnectorNoDialog1Seg category:"SoulburnScripts" tooltip:"vertexAndEdgeConnectorNoDialog1Seg" Icon:#("SoulburnScripts_vertexAndEdgeConnectorNoDialog1Seg",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	on execute do vertexAndEdgeConnector false true 1 0 0
	on Altexecute type do vertexAndEdgeConnectorUI()
	)
	
MacroScript vertexAndEdgeConnectorNoDialog2Seg category:"SoulburnScripts" tooltip:"vertexAndEdgeConnectorNoDialog2Seg" Icon:#("SoulburnScripts_vertexAndEdgeConnectorNoDialog2Seg",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	on execute do vertexAndEdgeConnector false true 2 0 0
	on Altexecute type do vertexAndEdgeConnectorUI()
	)
	
MacroScript vertexAndEdgeConnectorNoDialog3Seg category:"SoulburnScripts" tooltip:"vertexAndEdgeConnectorNoDialog3Seg" Icon:#("SoulburnScripts_vertexAndEdgeConnectorNoDialog3Seg",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	on execute do vertexAndEdgeConnector false true 3 0 0
	on Altexecute type do vertexAndEdgeConnectorUI()
	)
	
MacroScript vertexAndEdgeConnectorNoDialog4Seg category:"SoulburnScripts" tooltip:"vertexAndEdgeConnectorNoDialog4Seg" Icon:#("SoulburnScripts_vertexAndEdgeConnectorNoDialog4Seg",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexAndEdgeConnector.ms"
	on execute do vertexAndEdgeConnector false true 4 0 0
	on Altexecute type do vertexAndEdgeConnectorUI()
	)

MacroScript vertexEdgeFaceSelectByNormal category:"SoulburnScripts" tooltip:"vertexEdgeFaceSelectByNormal" Icon:#("SoulburnScripts_vertexEdgeFaceSelectByNormal",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexEdgeFaceSelectByNormal.ms"
	on execute do vertexEdgeFaceSelectByNormalDefaults()
	on Altexecute type do vertexEdgeFaceSelectByNormalUI()
	)
	
MacroScript vertexEdgeFaceSelectByNormalUI category:"SoulburnScripts" tooltip:"vertexEdgeFaceSelectByNormalUI" Icon:#("SoulburnScripts_vertexEdgeFaceSelectByNormalUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexEdgeFaceSelectByNormal.ms"
	vertexEdgeFaceSelectByNormalUI()
	)

MacroScript vertexMapDisplayer category:"SoulburnScripts" tooltip:"vertexMapDisplayer" Icon:#("SoulburnScripts_vertexMapDisplayer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexMapDisplayer.ms"
	on execute do vertexMapDisplayerDefaults()
	on Altexecute type do vertexMapDisplayerUI()
	)
	
MacroScript vertexMapDisplayerUI category:"SoulburnScripts" tooltip:"vertexMapDisplayerUI" Icon:#("SoulburnScripts_vertexMapDisplayerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertexMapDisplayer.ms"
	vertexMapDisplayerUI()
	)
	
MacroScript vertPlacer category:"SoulburnScripts" tooltip:"vertPlacer" Icon:#("SoulburnScripts_vertPlacer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacerDefaults()
	on Altexecute type do vertPlacerUI()
	)
	
MacroScript vertPlacerUI category:"SoulburnScripts" tooltip:"vertPlacerUI" Icon:#("SoulburnScripts_vertPlacerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertPlacer.ms"
	vertPlacerUI()
	)
	
MacroScript vertPlacerXMouseClick category:"SoulburnScripts" tooltip:"vertPlacerXMouseclick" Icon:#("SoulburnScripts_vertPlacerXMouseclick",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacer true false false 3 0.00
	on Altexecute type do vertPlacerUI()
	)
	
MacroScript vertPlacerYMouseClick category:"SoulburnScripts" tooltip:"vertPlacerYMouseclick" Icon:#("SoulburnScripts_vertPlacerYMouseclick",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacer false true false 3 0.00
	on Altexecute type do vertPlacerUI()
	)
	
MacroScript vertPlacerZMouseClick category:"SoulburnScripts" tooltip:"vertPlacerZMouseclick" Icon:#("SoulburnScripts_vertPlacerZMouseclick",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacer false false true 3 0.00
	on Altexecute type do vertPlacerUI()
	)

MacroScript vertSelectionToObject category:"SoulburnScripts" tooltip:"vertSelectionToObject" Icon:#("SoulburnScripts_vertSelectionToObject",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertSelectionToObject.ms"
	on execute do vertSelectionToObjectDefaults()
	on Altexecute type do vertSelectionToObjectUI()
	)

MacroScript vertSelectionToObjectUI category:"SoulburnScripts" tooltip:"vertSelectionToObjectUI" Icon:#("SoulburnScripts_vertSelectionToObjectUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vertSelectionToObject.ms"
	vertSelectionToObjectUI()
	)

MacroScript viewportControl category:"SoulburnScripts" tooltip:"viewportControl" Icon:#("SoulburnScripts_viewportControl",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControlDefaults()
	on Altexecute type do viewportControlUI()
	)
	
MacroScript viewportControlUI category:"SoulburnScripts" tooltip:"viewportControlUI" Icon:#("SoulburnScripts_viewportControlUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	viewportControlUI()
	)

MacroScript viewportControlExpertMode category:"SoulburnScripts" tooltip:"viewportControlExpertMode" Icon:#("SoulburnScripts_viewportControlExpertMode",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	viewportControlExpertMode()
	)

MacroScript viewportControlTop category:"SoulburnScripts" tooltip:"viewportControlTop" Icon:#("SoulburnScripts_viewportControlTop",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 1 true true true
	on Altexecute type do viewportControlUI()
	)

MacroScript viewportControlBottom category:"SoulburnScripts" tooltip:"viewportControlBottom" Icon:#("SoulburnScripts_viewportControlBottom",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 2 true true true
	on Altexecute type do viewportControlUI()
	)

MacroScript viewportControlFront category:"SoulburnScripts" tooltip:"viewportControlFront" Icon:#("SoulburnScripts_viewportControlFront",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 3 true true true
	on Altexecute type do viewportControlUI()
	)

MacroScript viewportControlBack category:"SoulburnScripts" tooltip:"viewportControlBack" Icon:#("SoulburnScripts_viewportControlBack",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 4 true true true
	on Altexecute type do viewportControlUI()
	)

MacroScript viewportControlLeft category:"SoulburnScripts" tooltip:"viewportControlLeft" Icon:#("SoulburnScripts_viewportControlLeft",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 5 true true true
	on Altexecute type do viewportControlUI()
	)
	
MacroScript viewportControlRight category:"SoulburnScripts" tooltip:"viewportControlRight" Icon:#("SoulburnScripts_viewportControlRight",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 6 true true true
	on Altexecute type do viewportControlUI()
	)
	
MacroScript viewportControlPersp category:"SoulburnScripts" tooltip:"viewportControlPersp" Icon:#("SoulburnScripts_viewportControlPersp",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 7 true true true
	on Altexecute type do viewportControlUI()
	)

MacroScript viewportControlCamera category:"SoulburnScripts" tooltip:"viewportControlCamera" Icon:#("SoulburnScripts_viewportControlCamera",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportControl.ms"
	on execute do viewportControl 8 true true true
	on Altexecute type do viewportControlUI()
	)

MacroScript viewportToVFBLoader category:"SoulburnScripts" tooltip:"viewportToVFBLoader" Icon:#("SoulburnScripts_viewportToVFBLoader",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportToVFBLoader.ms"
	on execute do viewportToVFBLoaderDefaults()
	on Altexecute type do viewportToVFBLoaderUI()
	)
	
MacroScript viewportToVFBLoaderUI category:"SoulburnScripts" tooltip:"viewportToVFBLoaderUI" Icon:#("SoulburnScripts_viewportToVFBLoaderUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/viewportToVFBLoader.ms"
	viewportToVFBLoaderUI()
	)

MacroScript vrayMatteManager category:"SoulburnScripts" tooltip:"vrayMatteManager" Icon:#("SoulburnScripts_vrayMatteManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vrayMatteManager.ms"
	on execute do vrayMatteManagerDefaults()
	on Altexecute type do vrayMatteManagerUI()
	)
	
MacroScript vrayMatteManagerUI category:"SoulburnScripts" tooltip:"vrayMatteManagerUI" Icon:#("SoulburnScripts_vrayMatteManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vrayMatteManager.ms"
	vrayMatteManagerUI()
	)

MacroScript vraySamplingSubdivManager category:"SoulburnScripts" tooltip:"vraySamplingSubdivManager" Icon:#("SoulburnScripts_vraySamplingSubdivManager",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vraySamplingSubdivManager.ms"
	on execute do vraySamplingSubdivManagerDefaults()
	on Altexecute type do vraySamplingSubdivManagerUI()
	)
	
MacroScript vraySamplingSubdivManagerUI category:"SoulburnScripts" tooltip:"vraySamplingSubdivManagerUI" Icon:#("SoulburnScripts_vraySamplingSubdivManagerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/vraySamplingSubdivManager.ms"
	vraySamplingSubdivManagerUI()
	)

MacroScript wireMaker category:"SoulburnScripts" tooltip:"wireMaker" Icon:#("SoulburnScripts_wireMaker",1)
	(
	Include "$scripts/SoulburnScripts/scripts/wireMaker.ms"
	on execute do wireMakerDefaults()
	on Altexecute type do wireMakerUI()
	)
	
MacroScript wireMakerUI category:"SoulburnScripts" tooltip:"wireMakerUI" Icon:#("SoulburnScripts_wireMakerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/wireMaker.ms"
	wireMakerUI()
	)
	
MacroScript wireColorRandomizer category:"SoulburnScripts" tooltip:"wireColorRandomizer" Icon:#("SoulburnScripts_wireColorRandomizer",1)
	(
	Include "$scripts/SoulburnScripts/scripts/wireColorRandomizer.ms"
	on execute do wireColorRandomizerDefaults()
	on Altexecute type do wireColorRandomizerUI()
	)
	
MacroScript wireColorRandomizerUI category:"SoulburnScripts" tooltip:"wireColorRandomizerUI" Icon:#("SoulburnScripts_wireColorRandomizerUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/wireColorRandomizer.ms"
	wireColorRandomizerUI()
	)
	
MacroScript xFormResetter category:"SoulburnScripts" tooltip:"xFormResetter" Icon:#("SoulburnScripts_xFormResetter",1)
	(
	Include "$scripts/SoulburnScripts/scripts/xFormResetter.ms"
	on execute do xFormResetterDefaults()
	on Altexecute type do xFormResetterUI()
	)
	
MacroScript xFormResetterUI category:"SoulburnScripts" tooltip:"xFormResetterUI" Icon:#("SoulburnScripts_xFormResetterUI",1)
	(
	Include "$scripts/SoulburnScripts/scripts/xFormResetter.ms"
	xFormResetterUI()
	)
)
-------------------------------------------------------------------------------