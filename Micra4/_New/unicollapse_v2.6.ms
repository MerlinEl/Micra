/*
------------------------------------------------
Using single one hotkey of Collapse. Works with:
Edit Poly (for several objects)
Editable poly
UnwrapUVW
SplineShape
------------------------------------------------
Script: UniCollapse
Author: Nikolay Litvinov
*/
macroScript UniCollapse Category:"Niklit Scripts" Tooltip:"UniCollapse"
(
------------------------- Functions -------------------------
gco = modPanel.getCurrentObject()

fn ESCollapse = (
	if (classof $ == SplineShape or classof $ == line) do
	if subobjectLevel == 1 then (
	macros.run "Editable Spline Object" "ESpline_Fuse_Vertex"
	macros.run "Editable Spline Object" "ESpline_Weld")
	)
fn KnotCollapse fco = (
	fco=$
	if finditem #(SplineShape, line) (classof $.baseObject) !=0 do (
	if showEndResult == true then (
	showEndResult = false
	ESCollapse()
	showEndResult = true
	)
	else ESCollapse()
	)
)

fn UVConnectCollapse fco = (
fco.scaleSelectedVerticesCenter 0 0
fco.WeldSelectedShared())

fn collapsePolyMod_fn=
with redraw off(
		WM_SETFOCUS = 0x007
		WM_RBUTTONDOWN=0x0204 --https://msdn.microsoft.com/en-us/library/windows/desktop/ms646242(v=vs.85).aspx
		toolMode.uniformScale()
		max tti
		desktopHWND = windows.getDesktopHWND()
		desktopChildren = windows.getChildrenHWND desktopHWND
		tti=for child in desktopChildren where (child[5] == "Scale Transform Type-In") do (exit with child)
		-- get the tti's dialog handle (tti[1])
		-- get its children
		ttiSpiner_hwnd = windows.getChildrenHWND tti[1]
		windows.sendMessage ttiSpiner_hwnd[32][1] WM_SETFOCUS 0 0
		windows.sendMessage ttiSpiner_hwnd[32][1] WM_RBUTTONDOWN 1 0
		UIAccessor.CloseDialog tti[1]
		max select
	)

fn FN_Spl_2_Knot fco = (
	fco=$
	spl_index_int=(getSplineSelection $)[1]
	KnotCount=numKnots $ spl_index_int
	knot_idx_ar= for i=1 to KnotCount collect i
	subObjectLevel=1
	for spl=1 to numSplines $ do
	setKnotSelection $ spl #()
	setKnotSelection $ spl_index_int knot_idx_ar
)

fn FN_Seg_2_Knot fco = (
fco=$
ARarSeg=for spl=1 to numSplines $ collect  getSegSelection $ spl
arKnot=(
for i=1 to ARarSeg.count where ARarSeg[i].count!=0 do
for j=1 to ARarSeg[i].count  do appendIfUnique ARarSeg[i] (ARarSeg[i][j]+1)
for i=1 to ARarSeg.count do
	(
		endKnot=numKnots $ i
		if ARarSeg[i].count>endKnot do deleteItem ARarSeg[i] ARarSeg[i].count
	)
ARarSeg
)
for spl=1 to ARarSeg.count do
setKnotSelection $ spl arKnot[spl]
subObjectLevel=1
)

fn CollapseShape fco = Case subobjectLevel of
					(
					1:	try (KnotCollapse fco) Catch()
					2: (disableSceneRedraw(); FN_Seg_2_Knot fco; try (KnotCollapse fco) Catch(); subobjectLevel=2; enableSceneRedraw())
					3: (disableSceneRedraw(); FN_Spl_2_Knot fco; try (KnotCollapse fco) Catch(); subobjectLevel=3; enableSceneRedraw())
					)

------------------------- Script -------------------------
Case classOf gco of
 		(
	Unwrap_UVW: UVConnectCollapse gco
   	 Edit_Poly: (Case subobjectLevel of
					(	1: (if Selection.count > 1 
							then (
								gco.ButtonOp #ConnectVertices
								gco.ButtonOp #CollapseVertex
								collapsePolyMod_fn())
							else (
								NumF1=gco.GetNumVertices()
									gco.ButtonOp #ConnectVertices
									gco.ButtonOp #CollapseVertex
								NumF2=gco.GetNumVertices()
								differ = NumF1 - NumF2
								if differ!=0 do PushPrompt ((differ+1) as string + " collapsed Vertex")
								)
							max select)
						2:	(gco.ButtonOp #CollapseEdge; max select)
						3:	(gco.ButtonOp #CollapseEdge; max select)
						4:	(gco.ButtonOp #CollapseFace; max select)
					)
				)
Editable_poly: Case subobjectLevel of
					(
					1:	(
						NumF1=gco.GetNumVertices()
							gco.ButtonOp #ConnectVertices
							gco.ButtonOp #Collapse; max select
						NumF2=gco.GetNumVertices()
						differ = NumF1 - NumF2
						if differ!=0 do PushPrompt ((differ+1) as string + " collapsed Vertex")
						)
					2:	(gco.ButtonOp #Collapse; max select)
					3:	(gco.ButtonOp #Collapse; max select)
					4:	(gco.ButtonOp #Collapse; max select)
					)
		Line: CollapseShape gco
 SplineShape: CollapseShape gco
 Edit_Spline: CollapseShape gco
 	)
)