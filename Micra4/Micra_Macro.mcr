----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

								                --MICRA--

----------------------------------------------------------------------------------------------------------
MacroScript SuperExpertMode             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcInterface == StructDef)
	On Execute Do (mcInterface.super_expert_mode())
)
----------------------------------------------------------------------------------------------------------		
MacroScript SubObject_0
--enabledIn:#("max", "viz", "vizr") --pfb: 2003.12.12 added product switch
ButtonText:"Element"
category:"Micra" 
Tooltip:"Sub-object Level 0"
-- internalCategory:"Modifier Stack"
(
	On IsEnabled Return (selection.count != 0)
	On Execute do
	(
		Max Modify Mode
		if SubObjectLevel != 0 do SubObjectLevel = 0
	)
)
----------------------------------------------------------------------------------------------------------	
MacroScript EPoly_NURMS_Toggle2
--enabledIn:#("max", "viz") --pfb: 2003.12.12 added product switch
ButtonText:"NURMS Toggle"
category:"Micra" 
Tooltip:"NURMS Toggle (Poly)2"
-- internalCategory:"Editable Polygon Object" 
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.nurms_toggle())
)
----------------------------------------------------------------------------------------------------------		
macroScript DivideEdges
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.divide_edges())
)
----------------------------------------------------------------------------------------------------------	
macroScript CreatePoly
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.create_poly())
)
----------------------------------------------------------------------------------------------------------	
macroScript CleanEdges
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.clean_edges())
)
----------------------------------------------------------------------------------------------------------	
macroScript TriangleCounter
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do 
	(
		if mcTriangleCounter 
		then (unregisterRedrawViewsCallback mcAction.triangle_counter)
		else
		(
			unregisterRedrawViewsCallback mcAction.triangle_counter
			registerRedrawViewsCallback mcAction.triangle_counter
		)	
		mcTriangleCounter = not mcTriangleCounter
		completeredraw()
	)
)
----------------------------------------------------------------------------------------------------------	
macroScript PaintWeights
category:"Micra"
toolTip:""
(
	On IsEnabled Return (selection.count == 1 and modPanel.getCurrentObject() == selection[1].modifiers[#Skin] and subobjectLevel == 1)
 	On Execute Do (undo off skinOps.paintWeightsButton selection[1].modifiers[#Skin])
)
----------------------------------------------------------------------------------------------------------
macroScript SoftSelIncerase
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly() and subobjectLevel > 0 and selection[1].useSoftSel == on)
	On Execute Do (undo "SoftSel Incerase" on if selection[1].falloff < 999999.0 do selection[1].falloff += 1.0)
)
macroScript SoftSelDecerase
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly() and subobjectLevel > 0 and selection[1].useSoftSel == on)
	On Execute Do (undo "SoftSel Decerase" on if selection[1].falloff > 0 do selection[1].falloff -= 1.0)
)
----------------------------------------------------------------------------------------------------------
MacroScript SplineMagnet
category:"Micra"
toolTip:"Spline Magnet"
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly()) 
	On Execute Do (Micra.fileInVersion "Spline_Magnet")
)
----------------------------------------------------------------------------------------------------------	
MacroScript HideUni             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.hide_sel())

)
----------------------------------------------------------------------------------------------------------
MacroScript UnhideUni             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.unhide_sel())
)
----------------------------------------------------------------------------------------------------------
MacroScript ShowHideCage             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (Micra != undefined and mcPoly.isInPoly())
	(
		selection[1].showCage = (not selection[1].showCage)
	)
)
----------------------------------------------------------------------------------------------------------
MacroScript SoftSelection             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (Micra != undefined and mcPoly.isInPoly() and Micra.fileInVersion != undefined)
	On Execute Do (Micra.fileInVersion "Soft_Selection")
	
)
----------------------------------------------------------------------------------------------------------
MacroScript CharacterTool
ButtonText:"Character_Tool"
category:"Micra" 
Tooltip:"Character_Tool"
(
	On IsEnabled Return (Micra.fileInVersion != undefined)
	On Execute do
	(
		Micra.fileInVersion "Character_Tool"
	)
)	
----------------------------------------------------------------------------------------------------------
MacroScript MakePlanarInX             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PlanarInX)
)
----------------------------------------------------------------------------------------------------------	
MacroScript MakePlanarInY             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PlanarInY)

)
----------------------------------------------------------------------------------------------------------	
MacroScript MakePlanarInZ             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PlanarInZ)
)
----------------------------------------------------------------------------------------------------------
MacroScript PolyRelax             
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PolyRelax)
)
----------------------------------------------------------------------------------------------------------	
MacroScript Reinstancer             
category:"Micra"
toolTip:""
(
	On IsEnabled Return  (classOf mcAction == StructDef)
	On Execute Do (mcAction.reinstance())
)	
----------------------------------------------------------------------------------------------------------
MacroScript CenterPivotToObject             
category:"Micra"
toolTip:""
(
	On IsEnabled Return  (classOf mcAction == StructDef)
	On Execute Do (mcAction.pivot_move_to_center())
)
----------------------------------------------------------------------------------------------------------
MacroScript CompleteRepairObject            
category:"Micra"
toolTip:""
(
	On IsEnabled Return (Micra.fileInVersion != undefined)
	On Execute Do (Micra.fileInVersion "Repair_Object")
)
----------------------------------------------------------------------------------------------------------	
MacroScript ResetMatEditor            
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcAction != undefined)
	On Execute Do (mcAction.reset_mat_editor())
)
----------------------------------------------------------------------------------------------------------
MacroScript CreateSplineFromPoints            
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcCreate != undefined)
	On Execute Do 
	(
		if selection.count != 0 do
		(
			local poi = for i in selection collect i.pos
			mcCreate.splineFrom poi type:#corner closed:false color:green
		)
	)
)
----------------------------------------------------------------------------------------------------------
MacroScript DeepIsolateHide            
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcDeepIsolate != undefined)
	On Execute Do (mcDeepIsolate lvl:#upper)
)
----------------------------------------------------------------------------------------------------------
MacroScript DeepIsolateShow            
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcDeepIsolate != undefined)
	On Execute Do (mcDeepIsolate lvl:#lower)
)
----------------------------------------------------------------------------------------------------------

MacroScript MicraQuit            
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcMicraDialog != undefined)
	On Execute Do (mcMicraDialog.quit_micra())
)
----------------------------------------------------------------------------------------------------------
MacroScript MicraRun            
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcPath != undefined)
	On Execute Do (fileIn (mcPath()+ "_Loader.ms"  ))
)
----------------------------------------------------------------------------------------------------------
MacroScript Gallery          
category:"Micra"
toolTip:"3DGallery"
Icon:#("mcDGallery",1)
(
	On IsEnabled Return (mcPath != undefined)
	On execute do (Micra.fileInVersion "3DGallery")
)
----------------------------------------------------------------------------------------------------------
macroScript UVW_Align_U
category:"Micra"
toolTip:""
(
	local gco=modpanel.getcurrentobject()
	if classOf gco == Unwrap_UVW do
	(
		if (gco.getTVSubObjectMode() == 1 or gco.getTVSubObjectMode() == 2) do
		(
			unwrapUIdialog.btn_aliU.pressed()
		)
	)
)
----------------------------------------------------------------------------------------------------------
macroScript UVW_Align_V
category:"Micra"
toolTip:""
(
	local gco=modpanel.getcurrentobject()
	if classOf gco == Unwrap_UVW do
	(
		if (gco.getTVSubObjectMode() == 1 or gco.getTVSubObjectMode() == 2) do
		(
			unwrapUIdialog.btn_aliV.pressed()
		)
	)
)
----------------------------------------------------------------------------------------------------------
macroScript Move2
category:"Micra"
toolTip:""
(
	local gco=modpanel.getcurrentobject()
	if classOf gco == Unwrap_UVW and unwrapUIdialog.open 
	then (Try (gco.move() ) Catch ())
	else (Try (Max Move) Catch ())
)
----------------------------------------------------------------------------------------------------------
macroScript Rotate2
category:"Micra"
toolTip:""
(
	local gco=modpanel.getcurrentobject()
	if classOf gco == Unwrap_UVW and unwrapUIdialog.open
	then (Try (gco.rotate() ) Catch ())
	else (Try (Max Rotate) Catch ())
)
----------------------------------------------------------------------------------------------------------
macroScript Scale2
category:"Micra"
toolTip:""
(
	local gco=modpanel.getcurrentobject()
	if classOf gco == Unwrap_UVW and unwrapUIdialog.open
	then (Try (gco.scale() ) Catch ())
	else (Try (Max Scale) Catch ())
)
----------------------------------------------------------------------------------------------------------
macroScript Select2
category:"Micra"
toolTip:""
(
	local gco=modpanel.getcurrentobject()
	if classOf gco == Unwrap_UVW and unwrapUIdialog.open
	then (Try (gco.setFreeFormMode on) Catch ())
	else (Try (Max select) Catch ())
)
----------------------------------------------------------------------------------------------------------
macroScript OpenUnwrapUVW
category:"Micra"
toolTip:""
(
	try 
	(
		local gco=modpanel.getcurrentobject()
		if gco == undefined do --not in max modify mode or nothing selected
		(
			Max modify mode
			gco=modpanel.getcurrentobject()
		)
	
		if classOf gco != Unwrap_UVW 
		then (modPanel.addModToSelection (Unwrap_UVW ()) )
		else (gco.edit() ) 
	)
	Catch() 
)
----------------------------------------------------------------------------------------------------------
macroScript Loop2
category:"Micra"
toolTip:""
(
	try (Max modify mode) catch()
	local gco=modpanel.getcurrentobject()
	local obj = selection[1]
	if classOf gco == Unwrap_UVW
	then
	(
		if unwrapUIdialog != undefined and unwrapUIdialog.isDisplayed and gco.getTVSubObjectMode() == 2 do
		(
			unwrapUIdialog.dash_EdgeLoop.pressed()
		)
	)
	else if classOf obj == Editable_Poly do 
	(
		try (obj.SelectEdgeLoop ()) catch()
	)
)
----------------------------------------------------------------------------------------------------------
macroScript Ring2
category:"Micra"
toolTip:""
(
	try (Max modify mode) catch()
	local gco=modpanel.getcurrentobject()
	local obj = selection[1]
	if classOf gco == Unwrap_UVW 
	then
	(
		if unwrapUIdialog != undefined and unwrapUIdialog.isDisplayed and gco.getTVSubObjectMode() == 2 do
		(
			unwrapUIdialog.dash_EdgeRing.pressed()
		)
	)
	else if classOf obj == Editable_Poly do
	(
		try (obj.SelectEdgeRing ()) catch()
	)
)
----------------------------------------------------------------------------------------------------------
macroScript BackupMaxFile
category:"Micra"
toolTip:""
(
	On IsEnabled Return (classOf mcFile == StructDef)
	On Execute Do (mcFile.backupMaxFile())
)
----------------------------------------------------------------------------------------------------------
MacroScript WalkCyrcleToolsUEStyle             
category:"Micra"
toolTip:""
(
	On execute do undo off 
	(
		local gco = modpanel.getcurrentobject()
		if classOf gco == Unwrap_UVW and unwrapUIdialog.open
		then
			(
				--texture vertex scale mode
				--$.unwrap_uvw.unwrap.move()
				--$.unwrap_uvw.unwrap.rotate()
				--$.unwrap_uvw.unwrap.scale()
			)
		else
		(
			--format "current tool:%\n" toolmode.commandmode
			case toolmode.commandmode of
			(
				#move   :(max rotate)
				#rotate :(max scale)
				#uscale :(max move)
				#nuscale:(max move)
				#squash :(max move)
				#select :(max move)
				#hierarchy:(max move)
			)
		)
	)
)
----------------------------------------------------------------------------------------------------------
macroScript PolySplitRing
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcPath != undefined)
	On execute do (Micra.fileInVersion "External_PolySplitRing")
)
----------------------------------------------------------------------------------------------------------
macroScript Transformer
category:"Micra"
toolTip:""
(
	On IsEnabled Return (mcPath != undefined)
	On execute do (Micra.fileInVersion "Transformer")
)
----------------------------------------------------------------------------------------------------------
macroScript UVW_Align_Center
category:"Micra"
toolTip:""
(
	local gco=modpanel.getcurrentobject()
	if classOf gco == Unwrap_UVW do
	(
		if (gco.getTVSubObjectMode() == 1) do
		(
			unwrapUIdialog.btn_aliU.pressed()
			unwrapUIdialog.btn_aliV.pressed()
		)
	)
)
----------------------------------------------------------------------------------------------------------
macroScript Toggle_Coordinates
category:"Micra"
toolTip:"Toggle Coordinates"
(
	local old_tool = toolmode.commandmode
	local coord = if getRefCoordSys() == #hybrid then #local else #view
	
	max move
	Toolmode.coordsys coord 
	max rotate
	Toolmode.coordsys coord 
	max scale	
	Toolmode.coordsys coord 
	max select
	Toolmode.coordsys coord
	
	case old_tool of
	(
		#move   :(max move)
		#rotate :(max rotate)
		#uscale :(max scale)
		#nscale :(max scale)
		#squash :(max scale)
		#select :(max select)
	)
)
----------------------------------------------------------------------------------------------------------
MacroScript MCselectPrevious
ButtonText:"Select Previous Bone"
Category:"Micra" 
internalCategory:"Bones" 
Tooltip:"Select Previous Bone" 
-- Needs Icon
(
	On Execute do
	(
		if ((classof(modPanel.GetcurrentObject())) == Skin)
		then
		(
			skinOps.SelectPreviousBone  (modPanel.GetcurrentObject()) 
		)
		else
		(
			max select parent
		)
	)
)

MacroScript MCselectNext
ButtonText:"Select Next Bone"
Category:"Micra" 
internalCategory:"Bones" 
Tooltip:"Select Next Bone" 
-- Needs Icon
(
	On Execute do
	(
		if ((classof(modPanel.GetcurrentObject())) == Skin)
		then
		(
			skinOps.SelectNextBone  (modPanel.GetcurrentObject()) 
		)
		else
		(
			max select child
		)
	)
)

MacroScript SelectCamTS
ButtonText:"Slect Camera Target Switch"
category:"Micra" 
Tooltip:"Slect Camera Target Switch"
(
	On Execute do
	(
		if classOf selection[1] == Targetobject then select selection[1].lookat else select selection[1].target
	)
)
/*
C:\Documents and Settings\rbaca\Local Settings\Application Data\Autodesk\3dsmax\9 - 32bit\enu\UI\usermacros

sysInfo.tempdir
"C:\DOCUME~1\rbaca\LOCALS~1\Temp\"
*/
