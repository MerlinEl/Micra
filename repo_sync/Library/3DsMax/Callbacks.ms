--when $objects deleted [ id:#cDel ] \ [handleAt:#redrawViews|#timeChange] \ [ <object_parameter> ] do <expr> \ 
------------------------------------------------------------------------
when transform $box01 changes do
$box02.pos = $box01.pos + delta
------------------------------------------------------------------------
when names selection change obj do update_name_table obj
------------------------------------------------------------------------
when #($foo, $baz, $bar) deleted obj do
(
messageBox "Warning!"
deleteItem obj_table (findItem obj_table obj)
)
------------------------------------------------------------------------
*/
/*
when $objects deleted id:#cDel do
(
messageBox "Warning!"
deleteAllChangeHandlers id:#cDel
)
*/
/*
when select $objects changes id:#osCha do 
(
print "true" --snum()
--deleteAllChangeHandlers id:#osCha
)
*/
------------------------------------------------------------------------
when geometry id:#gCha do
(
mbox 20
deleteAllChangeHandlers id:#gCha
)
deleteAllChangeHandlers id:#obj
when select $ changes obj do print "true"
------------------------------------------------------------------------
/*	
	on active changed state do
	(
	callbacks.removeScripts id:#MySelectionCallback
	callbacks.addScript #SelectionSetChanged "
	mbox 20 
	" id:#MySelectionCallback
*/
------------------------------------------------------------------------	
--when $objects deleted id:#cDel do (ListObj.LBox.items = oName() ; print "Refresh1")
------------------------------------------------------------------------

callbacks.addscript #modpanelselchanged "print \"changed\" " id:#MvH_QSO --when changed selection in modify panel
callbacks.addscript #modpanelobjpostchange "print \"changed\" " id:#MvH_QSO --when changed selection in modify panel
callbacks.removescripts id:#MvH_QSO


--if selection changed
when select $ changes HandleAt:#RedrawViews id:#zoom_constant do print "changed"
--if selection size, position or rotation changed
when parameters $ changes HandleAt:#RedrawViews id:#zoom_constant do print "changed"

--when parameters viewport.GetTM changes HandleAt:#RedrawViews id:#zoom_constant do print "changed"
deleteAllChangeHandlers id:#zoom_constant

--format "tm:%\n" (viewport.GetTM()).pos
	(
		struct ZOOM_DATA (obj, dist1, dist2)
		ZD = ZOOM_DATA()
		ZD.obj = sphere radius:10 
		ZD.dist1 = getScreenScaleFactor ZD.obj.pos
		ZD.dist2 = ZD.dist1 
		
		fn createCallback = 
		(
			if not isValidNode ZD.obj do return false
			ZD.dist2 = getScreenScaleFactor ZD.obj.pos
            
			local zoom_percent = ZD.dist2 / ZD.dist1
			format "dist1:%\tdist2:%\tzoom percent:%\n" ZD.dist1 ZD.dist2 zoom_percent
			ZD.obj.radius *= zoom_percent
			
			ZD.dist1 = ZD.dist2
		)
	
	)
	registerRedrawViewsCallback createCallback
	unRegisterRedrawViewsCallback createCallback
	



viewport.getBlowupRect viewport.activeViewport
getViewSize()
viewport.getTM()
getScreenScaleFactor $.pos





sulev = 1

when parameters sulev changes HandleAt:#RedrawViews id:#xxx do print "changes"
deleteAllChangeHandlers id:#xxx


when select $ changes obj id:#xxx do update_modifier_list obj 
when parameters $ subobjectlevel  id:#xxx do print "changes"

global mf_morpher_mod
mf_morpher_mod = $.modifiers[#morpher]
deleteAllChangeHandlers id:#morpher_floater
when parameters mf_morpher_mod changes HandleAt:#RedrawViews id:#morpher_floater do print "yes"

when parameters isChecked modPanel HandleAt:#RedrawViews id:#xxx do print "changes"


--parameters
$.modifiers[#Edit_Poly]
$.modifiers[#morpher]
$.height1.controller.value


function bellToll nType =
(
    with printAllElements on
    (
        if (callbacks.notificationParam() == undefined) then
            format "% - %\n" tollCount nType
        else
            format "% - %, %\n" tollCount nType (callbacks.notificationParam())
    )
    tollCount += 1
)

--------------------------------------------------------------------------------

function addBell =
(
    callbacks.addScript #animateOff "bellToll #animateOff" id:#callBell
    callbacks.addScript #animateOn "bellToll #animateOn" id:#callBell
    callbacks.addScript #animationRangeChange "bellToll #animationRangeChange" id:#callBell
    callbacks.addScript #tabbedDialogCreated "bellToll #tabbedDialogCreated" id:#callBell
    callbacks.addScript #tabbedDialogDeleted "bellToll #tabbedDialogDeleted" id:#callBell
    callbacks.addScript #renderParamsChanged "bellToll #renderParamsChanged" id:#callBell
    callbacks.addScript #preRendererChange "bellToll #preRendererChange" id:#callBell
    callbacks.addScript #postRendererChange "bellToll #postRendererChange" id:#callBell
    callbacks.addScript #preRender "bellToll #preRender" id:#callBell
    callbacks.addScript #postRender "bellToll #postRender" id:#callBell
    callbacks.addScript #preRenderEval "bellToll #preRenderEval" id:#callBell
    callbacks.addScript #preRenderFrame "bellToll #preRenderFrame" id:#callBell
    callbacks.addScript #postRenderFrame "bellToll #postRenderFrame" id:#callBell
    callbacks.addScript #beginRenderingReflectRefractMap "bellToll #beginRenderingReflectRefractMap" id:#callBell
    callbacks.addScript #beginRenderingActualFrame "bellToll #beginRenderingActualFrame" id:#callBell
    callbacks.addScript #beginRenderingTonemappingImage "bellToll #beginRenderingTonemappingImage" id:#callBell
    callbacks.addScript #fileLinkPreAttach "bellToll #fileLinkPreAttach" id:#callBell
    callbacks.addScript #fileLinkPostAttach "bellToll #fileLinkPostAttach" id:#callBell
    callbacks.addScript #fileLinkPreBind "bellToll #fileLinkPreBind" id:#callBell
    callbacks.addScript #fileLinkPostBind "bellToll #fileLinkPostBind" id:#callBell
    callbacks.addScript #fileLinkPreDetatch "bellToll #fileLinkPreDetatch" id:#callBell
    callbacks.addScript #fileLinkPostDetatch "bellToll #fileLinkPostDetatch" id:#callBell
    callbacks.addScript #fileLinkPreReload "bellToll #fileLinkPreReload" id:#callBell
    callbacks.addScript #fileLinkPostReload "bellToll #fileLinkPostReload" id:#callBell
    callbacks.addScript #filelinkPostReloadPrePrune "bellToll #filelinkPostReloadPrePrune" id:#callBell
    callbacks.addScript #filePreOpen "bellToll #filePreOpen" id:#callBell
    callbacks.addScript #filePostOpen "bellToll #filePostOpen" id:#callBell
    callbacks.addScript #filePreOpenProcess "bellToll #filePreOpenProcess" id:#callBell
    callbacks.addScript #filePostOpenProcess "bellToll #filePostOpenProcess" id:#callBell
    callbacks.addScript #filePreSave "bellToll #filePreSave" id:#callBell
    callbacks.addScript #filePostSave "bellToll #filePostSave" id:#callBell
    callbacks.addScript #filePreSaveProcess "bellToll #filePreSaveProcess" id:#callBell
    callbacks.addScript #filePostSaveProcess "bellToll #filePostSaveProcess" id:#callBell
    callbacks.addScript #filePreSaveOld "bellToll #filePreSaveOld" id:#callBell
    callbacks.addScript #filePostSaveOld "bellToll #filePostSaveOld" id:#callBell
    callbacks.addScript #filePreMerge "bellToll #filePreMerge" id:#callBell
    callbacks.addScript #filePostMerge "bellToll #filePostMerge" id:#callBell
    callbacks.addScript #filePostMergeProcess "bellToll #filePostMergeProcess" id:#callBell
    callbacks.addScript #preImport "bellToll #preImport" id:#callBell
    callbacks.addScript #postImport "bellToll #postImport" id:#callBell
    callbacks.addScript #importFailed "bellToll #importFailed" id:#callBell
    callbacks.addScript #preExport "bellToll #preExport" id:#callBell
    callbacks.addScript #postExport "bellToll #postExport" id:#callBell
    callbacks.addScript #exportFailed "bellToll #exportFailed" id:#callBell
    callbacks.addScript #objectXrefPreMerge "bellToll #objectXrefPreMerge" id:#callBell
    callbacks.addScript #objectXrefPostMerge "bellToll #objectXrefPostMerge" id:#callBell
    callbacks.addScript #sceneXrefPreMerge "bellToll #sceneXrefPreMerge" id:#callBell
    callbacks.addScript #sceneXrefPostMerge "bellToll #sceneXrefPostMerge" id:#callBell
    callbacks.addScript #layerCreated "bellToll #layerCreated" id:#callBell
    callbacks.addScript #layerDeleted "bellToll #layerDeleted" id:#callBell
    callbacks.addScript #nodeLayerChanged "bellToll #nodeLayerChanged" id:#callBell
    callbacks.addScript #manipulateModeOn "bellToll #manipulateModeOn" id:#callBell
    callbacks.addScript #manipulateModeOff "bellToll #manipulateModeOff" id:#callBell
    callbacks.addScript #modPanelObjPreChange "bellToll #modPanelObjPreChange" id:#callBell
    callbacks.addScript #modPanelObjPostChange "bellToll #modPanelObjPostChange" id:#callBell
    callbacks.addScript #modPanelSelChanged "bellToll #modPanelSelChanged" id:#callBell
    callbacks.addScript #ModPanelSubObjectLevelChanged "bellToll #ModPanelSubObjectLevelChanged" id:#callBell
    callbacks.addScript #preModifierAdded "bellToll #preModifierAdded" id:#callBell
    callbacks.addScript #postModifierAdded "bellToll #postModifierAdded" id:#callBell
    callbacks.addScript #preModifierDeleted "bellToll #preModifierDeleted" id:#callBell
    callbacks.addScript #postModifierDeleted "bellToll #postModifierDeleted" id:#callBell
    callbacks.addScript #mtlLibPreOpen "bellToll #mtlLibPreOpen" id:#callBell
    callbacks.addScript #mtlLibPostOpen "bellToll #mtlLibPostOpen" id:#callBell
    callbacks.addScript #mtlLibPreSave "bellToll #mtlLibPreSave" id:#callBell
    callbacks.addScript #mtlLibPostSave "bellToll #mtlLibPostSave" id:#callBell
    callbacks.addScript #mtlLibPreMerge "bellToll #mtlLibPreMerge" id:#callBell
    callbacks.addScript #mtlLibPostMerge "bellToll #mtlLibPostMerge" id:#callBell
    callbacks.addScript #mtlRefAdded "bellToll #mtlRefAdded" id:#callBell
    callbacks.addScript #mtlRefDeleted "bellToll #mtlRefDeleted" id:#callBell
    callbacks.addScript #nodeCreated "bellToll #nodeCreated" id:#callBell
    callbacks.addScript #nodeCloned "bellToll #nodeCloned" id:#callBell
    callbacks.addScript #sceneNodeAdded "bellToll #sceneNodeAdded" id:#callBell
    callbacks.addScript #nodeFreeze "bellToll #nodeFreeze" id:#callBell
    callbacks.addScript #nodeUnfreeze "bellToll #nodeUnfreeze" id:#callBell
    callbacks.addScript #nodeHide "bellToll #nodeHide" id:#callBell
    callbacks.addScript #nodeUnhide "bellToll #nodeUnhide" id:#callBell
    callbacks.addScript #nodeLinked "bellToll #nodeLinked" id:#callBell
    callbacks.addScript #nodeUnlinked "bellToll #nodeUnlinked" id:#callBell
    callbacks.addScript #nodePreDelete "bellToll #nodePreDelete" id:#callBell
    callbacks.addScript #nodePostDelete "bellToll #nodePostDelete" id:#callBell
    callbacks.addScript #nodePreMaterial "bellToll #nodePreMaterial" id:#callBell
    callbacks.addScript #nodePostMaterial "bellToll #nodePostMaterial" id:#callBell
    callbacks.addScript #nodeRenamed "bellToll #nodeRenamed" id:#callBell
    callbacks.addScript #nodeNameSet "bellToll #nodeNameSet" id:#callBell
    callbacks.addScript #preNodeBonePropChanged "bellToll #preNodeBonePropChanged" id:#callBell
    callbacks.addScript #postNodeBonePropChanged "bellToll #postNodeBonePropChanged" id:#callBell
    callbacks.addScript #preNodeGeneralPropChanged "bellToll #preNodeGeneralPropChanged" id:#callBell
    callbacks.addScript #postNodeGeneralPropChanged "bellToll #postNodeGeneralPropChanged" id:#callBell
    callbacks.addScript #preNodeGiPropChanged "bellToll #preNodeGiPropChanged" id:#callBell
    callbacks.addScript #postNodeGiPropChanged "bellToll #postNodeGiPropChanged" id:#callBell
    callbacks.addScript #preNodeMentalrayPropChanged "bellToll #preNodeMentalrayPropChanged" id:#callBell
    callbacks.addScript #postNodeMentalrayPropChanged "bellToll #postNodeMentalrayPropChanged" id:#callBell
    callbacks.addScript #preNodesCloned "bellToll #preNodesCloned" id:#callBell
    callbacks.addScript #postNodesCloned "bellToll #postNodesCloned" id:#callBell
    callbacks.addScript #preNodeUserPropChanged "bellToll #preNodeUserPropChanged" id:#callBell
    callbacks.addScript #postNodeUserPropChanged "bellToll #postNodeUserPropChanged" id:#callBell
    callbacks.addScript #preMirrorNodes "bellToll #preMirrorNodes" id:#callBell
    callbacks.addScript #postMirrorNodes "bellToll #postMirrorNodes" id:#callBell
    callbacks.addScript #selectedNodesPreDelete "bellToll #selectedNodesPreDelete" id:#callBell
    callbacks.addScript #selectedNodesPostDelete "bellToll #selectedNodesPostDelete" id:#callBell
    callbacks.addScript #selectionSetChanged "bellToll #selectionSetChanged" id:#callBell
    callbacks.addScript #postSystemStartup "bellToll #postSystemStartup" id:#callBell
    callbacks.addScript #systemPreNew "bellToll #systemPreNew" id:#callBell
    callbacks.addScript #systemPostNew "bellToll #systemPostNew" id:#callBell
    callbacks.addScript #systemPreReset "bellToll #systemPreReset" id:#callBell
    callbacks.addScript #systemPostReset "bellToll #systemPostReset" id:#callBell
    callbacks.addScript #systemPreDirChange "bellToll #systemPreDirChange" id:#callBell
    callbacks.addScript #systemPostDirChange "bellToll #systemPostDirChange" id:#callBell
    callbacks.addScript #preSystemShutdown "bellToll #preSystemShutdown" id:#callBell
    callbacks.addScript #postSystemShutdown "bellToll #postSystemShutdown" id:#callBell
    callbacks.addScript #pluginLoaded "bellToll #pluginLoaded" id:#callBell
    callbacks.addScript #radiosityPluginChanged "bellToll #radiosityPluginChanged" id:#callBell
    callbacks.addScript #radiosityProcessDone "bellToll #radiosityProcessDone" id:#callBell
    callbacks.addScript #radiosityProcessReset "bellToll #radiosityProcessReset" id:#callBell
    callbacks.addScript #radiosityProcessStart "bellToll #radiosityProcessStart" id:#callBell
    callbacks.addScript #radiosityProcessStopped "bellToll #radiosityProcessStopped" id:#callBell
    callbacks.addScript #sceneUndo "bellToll #sceneUndo" id:#callBell
    callbacks.addScript #sceneRedo "bellToll #sceneRedo" id:#callBell
    callbacks.addScript #svSelectionSetChanged "bellToll #svSelectionSetChanged" id:#callBell
    callbacks.addScript #svDoubleClickGraphNode "bellToll #svDoubleClickGraphNode" id:#callBell
    callbacks.addScript #svPreLayoutChange "bellToll #svPreLayoutChange" id:#callBell
    callbacks.addScript #svPostLayoutChange "bellToll #svPostLayoutChange" id:#callBell
    callbacks.addScript #assetBrowserPreNavigate "bellToll #assetBrowserPreNavigate" id:#callBell
    callbacks.addScript #NamedSelSetCreated "bellToll #NamedSelSetCreated" id:#callBell
    callbacks.addScript #NamedSelSetDeleted "bellToll #NamedSelSetDeleted" id:#callBell
    callbacks.addScript #NamedSelSetRenamed "bellToll #NamedSelSetRenamed" id:#callBell
    callbacks.addScript #D3DPreDeviceReset "bellToll #D3DPreDeviceReset" id:#callBell
    callbacks.addScript #D3DPostDeviceReset "bellToll #D3DPostDeviceReset" id:#callBell
    callbacks.addScript #bitmapChanged "bellToll #bitmapChanged" id:#callBell
    callbacks.addScript #colorChanged "bellToll #colorChanged" id:#callBell
    callbacks.addScript #customDisplayFilterChanged "bellToll #customDisplayFilterChanged" id:#callBell
    callbacks.addScript #lightingUnitDisplaySystemChange "bellToll #lightingUnitDisplaySystemChange" id:#callBell
    callbacks.addScript #spacemodeChange "bellToll #spacemodeChange" id:#callBell
    callbacks.addScript #timeunitsChange "bellToll #timeunitsChange" id:#callBell
    callbacks.addScript #unitsChange "bellToll #unitsChange" id:#callBell
    callbacks.addScript #viewportChange "bellToll #viewportChange" id:#callBell
    callbacks.addScript #mainWindowEnabled "bellToll #mainWindowEnabled" id:#callBell
    callbacks.addScript #heightMenuChanged "bellToll #heightMenuChanged" id:#callBell
    callbacks.addScript #preProgress "bellToll #preProgress" id:#callBell
    callbacks.addScript #postProgress "bellToll #postProgress" id:#callBell
)

--------------------------------------------------------------------------------

function remBell =
(
    callbacks.removeScripts id:#callBell
)