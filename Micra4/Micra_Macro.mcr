----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

								                --MICRA--

----------------------------------------------------------------------------------------------------------
MacroScript SuperExpertMode            
category:"Micra"
ButtonText:"Super Expert Mode" 
toolTip:""
(
	On IsEnabled Return (classOf mcInterface == StructDef)
	On Execute Do (mcInterface.super_expert_mode())
)
----------------------------------------------------------------------------------------------------------		
MacroScript SubObject_0
--enabledIn:#("max", "viz", "vizr") --pfb: 2003.12.12 added product switch
category:"Micra" 
ButtonText:"Exit Editing"
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
category:"Micra" 
ButtonText:"NURMS Toggle"
Tooltip:"NURMS Toggle (Poly)2"
-- internalCategory:"Editable Polygon Object" 
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.nurms_toggle())
)
----------------------------------------------------------------------------------------------------------		
macroScript DivideEdges
category:"Micra"
ButtonText:"Divide Edges"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.divide_edges())
)
----------------------------------------------------------------------------------------------------------	
macroScript CreatePoly
category:"Micra"
ButtonText:"Create Poly"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.create_poly())
)
----------------------------------------------------------------------------------------------------------	
macroScript CleanEdges
category:"Micra"
ButtonText:"Clean Edges"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.clean_edges())
)
----------------------------------------------------------------------------------------------------------	
macroScript TriangleCounter
category:"Micra"
ButtonText:"Triangle Counter"
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
ButtonText:"Paint Weights"
toolTip:""
(
	On IsEnabled Return (selection.count == 1 and modPanel.getCurrentObject() == selection[1].modifiers[#Skin] and subobjectLevel == 1)
 	On Execute Do (undo off skinOps.paintWeightsButton selection[1].modifiers[#Skin])
)
----------------------------------------------------------------------------------------------------------
macroScript SoftSelIncerase
category:"Micra"
ButtonText:"Soft Sel Incerase"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly() and subobjectLevel > 0 and selection[1].useSoftSel == on)
	On Execute Do (undo "SoftSel Incerase" on if selection[1].falloff < 999999.0 do selection[1].falloff += 1.0)
)
macroScript SoftSelDecerase
category:"Micra"
ButtonText:"Soft Sel Decerase"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly() and subobjectLevel > 0 and selection[1].useSoftSel == on)
	On Execute Do (undo "SoftSel Decerase" on if selection[1].falloff > 0 do selection[1].falloff -= 1.0)
)
----------------------------------------------------------------------------------------------------------
MacroScript SplineMagnet
category:"Micra"
ButtonText:"Spline Magnet"
toolTip:"Spline Magnet"
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly()) 
	On Execute Do (mcFile.fileInVersion "Spline_Magnet")
)
----------------------------------------------------------------------------------------------------------	
MacroScript HideUni           
category:"Micra"
ButtonText:"Hide Uni"  
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.hide_sel())

)
----------------------------------------------------------------------------------------------------------
MacroScript UnhideUni               
category:"Micra"
ButtonText:"Unhide Uni" 
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.unhide_sel())
)
----------------------------------------------------------------------------------------------------------
MacroScript ShowHideCage              
category:"Micra"
ButtonText:"Show Hide Cage" 
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
ButtonText:"Soft Selection" 
toolTip:""
(
	On IsEnabled Return (Micra != undefined and mcPoly.isInPoly() and mcFile.fileInVersion != undefined)
	On Execute Do (mcFile.fileInVersion "Soft_Selection")
	
)
----------------------------------------------------------------------------------------------------------
MacroScript CharacterTool
category:"Micra" 
ButtonText:"Character_Tool"
Tooltip:"Character_Tool"
(
	On IsEnabled Return (mcFile.fileInVersion != undefined)
	On Execute do
	(
		mcFile.fileInVersion "Character_Tool"
	)
)	
----------------------------------------------------------------------------------------------------------
MacroScript MakePlanarInX            
category:"Micra"
ButtonText:"Make Planar In X"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PlanarInX)
)
----------------------------------------------------------------------------------------------------------	
MacroScript MakePlanarInY           
category:"Micra"
ButtonText:"Make Planar In Y"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PlanarInY)

)
----------------------------------------------------------------------------------------------------------	
MacroScript MakePlanarInZ             
category:"Micra"
ButtonText:"Make Planar In Z"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PlanarInZ)
)
----------------------------------------------------------------------------------------------------------
MacroScript PolyRelax             
category:"Micra"
ButtonText:"Poly Relax"
toolTip:""
(
	On IsEnabled Return (classOf mcAction == StructDef and mcPoly.isInPoly())
	On Execute do  (mcAction.make #PolyRelax)
)
----------------------------------------------------------------------------------------------------------	
MacroScript Reinstancer             
category:"Micra"
ButtonText:"Reinstancer"
toolTip:""
(
	On IsEnabled Return  (classOf mcAction == StructDef)
	On Execute Do (mcAction.reinstance())
)	
----------------------------------------------------------------------------------------------------------
MacroScript CenterPivotToObject            
category:"Micra"
ButtonText:"Center Pivot To Object" 
toolTip:""
(
	On IsEnabled Return  (classOf mcAction == StructDef)
	On Execute Do (mcAction.pivot_move_to_center())
)
----------------------------------------------------------------------------------------------------------
MacroScript CompleteRepairObject            
category:"Micra"
ButtonText:"Complete Repair Object"
toolTip:""
(
	On IsEnabled Return (mcFile.fileInVersion != undefined)
	On Execute Do (mcFile.fileInVersion "Repair_Object")
)
----------------------------------------------------------------------------------------------------------	
MacroScript ResetMatEditor         
category:"Micra"
ButtonText:"Reset Mat Editor"   
toolTip:""
(
	On IsEnabled Return (mcAction != undefined)
	On Execute Do (mcAction.reset_mat_editor())
)
----------------------------------------------------------------------------------------------------------
MacroScript CreateSplineFromPoints          
category:"Micra"
ButtonText:"Create Spline From Points"  
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
ButtonText:"Deep Isolate Hide"
toolTip:""
(
	On IsEnabled Return (mcDeepIsolate != undefined)
	On Execute Do (mcDeepIsolate lvl:#upper)
)
----------------------------------------------------------------------------------------------------------
MacroScript DeepIsolateShow          
category:"Micra"
ButtonText:"Deep Isolate Show"  
toolTip:""
(
	On IsEnabled Return (mcDeepIsolate != undefined)
	On Execute Do (mcDeepIsolate lvl:#lower)
)
----------------------------------------------------------------------------------------------------------

MacroScript MicraQuit          
category:"Micra"
ButtonText:"Quit Micra"  
toolTip:""
(
	On IsEnabled Return (mcMicraDialog != undefined)
	On Execute Do (mcMicraDialog.quit_micra())
)
----------------------------------------------------------------------------------------------------------
MacroScript MicraRun          
category:"Micra"
ButtonText:"Run Micra"  
toolTip:""
(
	On IsEnabled Return (mcPath != undefined)
	On Execute Do (fileIn (mcPath()+ "_Loader.ms"  ))
)
----------------------------------------------------------------------------------------------------------
MacroScript Gallery         
category:"Micra"
ButtonText:"Gallery 3D" 
toolTip:"Gallery3D"
Icon:#("mcDGallery",1)
(
	On IsEnabled Return (mcPath != undefined)
	On execute do (mcFile.fileInVersion "Gallery3D")
)
----------------------------------------------------------------------------------------------------------
macroScript UVW_Align_U
category:"Micra"
ButtonText:"UVW Align U"
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
ButtonText:"UVW Align V"
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
ButtonText:"Move2"
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
ButtonText:"Rotate2"
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
ButtonText:"Scale2"
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
ButtonText:"Select2"
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
ButtonText:"Open Unwrap UVW"
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
ButtonText:"Loop2"
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
ButtonText:"Ring2"
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
ButtonText:"Backup Max File"
toolTip:""
(
	On IsEnabled Return (classOf mcFile == StructDef)
	On Execute Do (mcFile.backupMaxFile())
)
----------------------------------------------------------------------------------------------------------
MacroScript WalkCyrcleToolsUEStyle   
category:"Micra"
ButtonText:"Walk Cyrcle Tools UE Style"
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
ButtonText:"PolySplitRing"
toolTip:""
(
	On IsEnabled Return (mcPath != undefined)
	On execute do (mcFile.fileInVersion "External_PolySplitRing")
)
----------------------------------------------------------------------------------------------------------
macroScript Transformer
category:"Micra"
ButtonText:"Transformer"
toolTip:""
(
	On IsEnabled Return (mcPath != undefined)
	On execute do (mcFile.fileInVersion "Transformer")
)
----------------------------------------------------------------------------------------------------------
macroScript UVW_Align_Center
category:"Micra"
ButtonText:"UVW Align Center"
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
ButtonText:"Toggle Coordinates"
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
Category:"Micra" 
ButtonText:"Select Previous Bone"
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
----------------------------------------------------------------------------------------------------------
MacroScript MCselectNext
Category:"Micra" 
ButtonText:"Select Next Bone"
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
----------------------------------------------------------------------------------------------------------
MacroScript SelectCamTS
category:"Micra" 
ButtonText:"Slect Camera Target Switch"
Tooltip:"Slect Camera Target Switch"
(
	On Execute do
	(
		if classOf selection[1] == Targetobject then select selection[1].lookat else select selection[1].target
	)
)
----------------------------------------------------------------------------------------------------------
MacroScript MC_SubObject_1
Category:"Micra"
ButtonText:"SubobjectLevel 1"
Tooltip:"Set SubobjectLevel to 1"
Icon:#("SubObjectIcons",1)
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute do  (mcAction.setSubobjectLevel 1)
) 
----------------------------------------------------------------------------------------------------------
MacroScript MC_SubObject_2
Category:"Micra"
ButtonText:"SubobjectLevel 2"
Tooltip:"Set SubobjectLevel to 2"
Icon:#("SubObjectIcons",2)
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute do  (mcAction.setSubobjectLevel 2)
) 
----------------------------------------------------------------------------------------------------------
MacroScript MC_SubObject_3
Category:"Micra"
ButtonText:"SubobjectLevel 3"
Tooltip:"Set SubobjectLevel to 3"
Icon:#("SubObjectIcons",3)
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute do  (mcAction.setSubobjectLevel 3)
)
---------------------------------------------------------------------------------------------------------- 
MacroScript MC_SubObject_4
Category:"Micra" 
ButtonText:"SubobjectLevel 4"
Tooltip:"Set SubobjectLevel to 4"
Icon:#("SubObjectIcons",4)
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute do  (mcAction.setSubobjectLevel 4)
) 
----------------------------------------------------------------------------------------------------------
MacroScript MC_SubObject_5
Category:"Micra" 
ButtonText:"SubobjectLevel 5"
Tooltip:"Set SubobjectLevel to 5"
Icon:#("SubObjectIcons",5)
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute do  (mcAction.setSubobjectLevel 5)
) 
----------------------------------------------------------------------------------------------------------
MacroScript MC_Poly_Bridge
Category:"Micra" 
ButtonText:"Create Bridge"
Tooltip:"Create Bridge between Edges"
(
	On IsEnabled Return (selection.count == 1)
	On Execute do  (		
		local obj = modPanel.getCurrentObject()
		case classOf obj of (
			
			Editable_Poly : (
				
				obj.bridgeSelected = 1
				if subObjectLevel == 2 then obj.Bridge() else if subObjectLevel == 3 do (
					--test if two borders are selected(>border()) or single(>cap())
					local esel = mcPoly.get #esel
					if esel.count > 1 do (
					
						local first_border = (polyop.getBorderFromEdge obj esel[1])
						if first_border.numberset == esel.count then (
						
							obj.capHoles #Edge
						
						) else (
						
							obj.Bridge()
						) 
					)
				)
			)
			Edit_Poly :  (
				
				if subObjectLevel == 2 then obj.ButtonOp #BridgeEdge
				else if subObjectLevel == 3 then obj.ButtonOp #BridgeBorder
				obj.Commit()
			)
		)
	)
) 
----------------------------------------------------------------------------------------------------------
MacroScript MC_Move_To_Surface
Category:"Micra" 
ButtonText:"MC Move To Surface"
Tooltip:"Move selected object to Surface"
(
	On IsEnabled Return (selection.count == 1)
	On Execute do  (mcAction.moveObjectToSurface())
)
----------------------------------------------------------------------------------------------------------	
macroScript MC_RemEdgesToFixMapping
category:"Micra"
ButtonText:"Remove Edges Fix Mapping"
toolTip:"Remove Edges Fix Mapping"
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.removeEdgesToFixMapping())
)
----------------------------------------------------------------------------------------------------------
macroScript MC_RecFixedMappingEdges
category:"Micra"
ButtonText:"Reconnect Edges Fix Mapping"
toolTip:"Reconnect Edges Fix Mapping"
(
	On IsEnabled Return (classOf mcAction == StructDef)
	On Execute Do (mcAction.reconnectFixedMappingEdges())
)
----------------------------------------------------------------------------------------------------------


/*
C:\Documents and Settings\rbaca\Local Settings\Application Data\Autodesk\3dsmax\9 - 32bit\enu\UI\usermacros

sysInfo.tempdir
"C:\DOCUME~1\rbaca\LOCALS~1\Temp\"
*/











