-- Uniconnector.ms
-- By Nikolay Litvinov (gniklit@gmail.com)
-- Created On:	2014-05-10
-- Modified:	2016-03-18
-- tested using Max 2016

macroScript FlowConnectSwitcher_macro Category:"Niklit Scripts" Tooltip:"Uconnector FlowConnect Switcher"
icon:#("SubObjectIcons",22)
(
	global FlowConnectSwitcher
	if FlowConnectSwitcher == undefined do FlowConnectSwitcher=false
	on ischecked return FlowConnectSwitcher
	on Execute do FlowConnectSwitcher = if FlowConnectSwitcher != true then true else false
)



messageBox "Category: \"Niklit Scripts\""
macroScript UniConnector Category:"Niklit Scripts" Tooltip:"UniConnector"
(
------------------------- Functions -------------------------
global NewSpline, num_CurO, Es_, gco
global KnotPos_ar=#()

universal=null
struct polyFns
	(
		fn GetSelectionEdge fco node_i=fco.getselection #edge,
		fn SetSelectionEdge fco edges_bitA node_i=fco.SetSelection #Edge edges_bitA,
		fn getNumFaces_fn fco node_i=fco.getNumFaces()
	)
struct polyMODFns
	(
		fn GetSelectionEdge fco node_i=fco.getselection #edge node:selection[node_i],
		fn SetSelectionEdge fco edges_bitA node_i=(fco.SetSelection #Edge #{}; setEdgeSelection node_i fco edges_bitA keep:on),
		fn getNumFaces_fn fco node_i=fco.GetNumFaces node:selection[node_i]
	)

	fn tryInit fco =
		case classOf fco of
		(
			Editable_Poly: (universal = polyFns(); "Editable_Poly")
			Edit_Poly: (universal = polyMODFns(); "Edit_Poly")
		)
global Pos_AllAxisProportional_Rollout
fn GabaritAssigner_fn=
(
if Pos_AllAxisProportional_Rollout==undefined do Pos_AllAxisProportional_Rollout=mouse.screenpos
rollout AllAxisProportional_Rollout "GabaritAssigner" width:99 height:57
(
	checkButton ckb1 "Proportional" pos:[10,11] width:78 height:35
	on AllAxisProportional_Rollout moved pos do Pos_AllAxisProportional_Rollout=pos
)
createdialog AllAxisProportional_Rollout pos: Pos_AllAxisProportional_Rollout
isSelMode=getToolbtnState #select
oStart = pickobject()
oEnd = pickobject()
if oStart!=undefined and oEnd!=undefined and (not keyboard.escPressed)
then
(
oStartVector=oStart.max-oStart.min
oEndVector=oEnd.max-oEnd.min
Nx=oEndVector.x/oStartVector.x
Ny=oEndVector.y/oStartVector.y
Nz=oEndVector.z/oStartVector.z

if isSelMode then scale oStart [Nx,Ny,Nz]
else
 case toolmode.axisConstraints of
	(
		#x: (if AllAxisProportional_Rollout.ckb1.state==on then  scale  oStart [Nx,Nx,Nx] else scale  oStart [Nx,1,1])
		#y: (if AllAxisProportional_Rollout.ckb1.state==on then  scale  oStart [Ny,Ny,Ny] else scale  oStart [1,Ny,1])
		#z: (if AllAxisProportional_Rollout.ckb1.state==on then  scale  oStart [Nz,Nz,Nz] else scale  oStart [1,1,Nz])
		#XY: scale  oStart [Nx,Ny,1]
		#YZ: scale  oStart [1,Ny,Nz]
		#ZX: scale  oStart [Nx,1,Nz]
		Default: oStart [Nx,Ny,Nz]
	)
DestroyDialog AllAxisProportional_Rollout
)
else DestroyDialog AllAxisProportional_Rollout
)


fn AddModiferSuit_fn=(
if getCommandPanelTaskMode() != #modify then max modify mode
Try(Case superclassof selection[1] of
	 (	GeometryClass: modPanel.addModToSelection (Edit_Poly ()) ui:on
				Shape: modPanel.addModToSelection (Edit_Spline ()) ui:on
	 )
 	max select
	)Catch()
)

fn MultiAttach_Spl_fn=
(
spl_ar=for i in selection where IsShapeObject i collect (convertToSplineShape i);
for i=2  to spl_ar.count do addandweld spl_ar[1] spl_ar[i] 0.002
)

fn WeldThreshold_fn = (
	maxWindow_hwnd=(windows.getChildrenHWND (windows.getDesktopHWND()))
	--for i in windows.getChildrenHWND #max do format "%\n" i
	WeldThreshold_hwnd=(for i=1 to maxWindow_hwnd.count where maxWindow_hwnd[i][5]=="Weld" do exit with maxWindow_hwnd[(i+1)][1])
WM_SETFOCUS = 0x007
VK_RETURN=0x000D
WM_CHAR=0x0102
SendKeys=dotNetClass "System.Windows.Forms.SendKeys"
windows.sendMessage WeldThreshold_hwnd WM_SETFOCUS 0 0
SendKeys.SendWait "0,002"
windows.sendMessage WeldThreshold_hwnd WM_CHAR VK_RETURN 0
SendKeys.SendWait "{up}"
UIAccessor.PressButton (for i in maxWindow_hwnd where i[5]=="Weld" do exit with i[1])
)

fn DrawLineBetweenTwoPoints_fn pointA pointB =
(
	global ss
	ss = SplineShape pos:pointA
	addNewSpline ss
	addKnot ss 1 #corner #line PointA
	addKnot ss 1 #corner #line PointB
	updateshape ss
)


fn BridgeKnots_fn =(
	for spl=1 to numSplines $ do
	for k=1 to (getKnotSelection $ spl).count do append KnotPos_ar (getKnotPoint $ spl ((getKnotSelection $ spl)[k]))
	DrawLineBetweenTwoPoints_fn KnotPos_ar[1] KnotPos_ar[2]
	cur=$
	select #(ss,cur)
	MultiAttach_Spl_fn()
	subobjectlevel=1
	max select all
	WeldThreshold_fn()
)

fn ShapeConn_fn fco=(
fco = $
case subobjectlevel of (
	1: BridgeKnots_fn()
	2: splineOps.divide fco
	3: (spl_index_int=(getSplineSelection fco)[1]
		splCount=numSegments fco spl_index_int
		arSpl=for i=1 to splCount collect i
		for i=1 to numSplines fco do
		setSegSelection fco i #()
		setSegSelection fco spl_index_int arSpl keep: on
		subObjectLevel=2
		splineOps.divide fco
		subObjectLevel=3)
	)
)

fn TriFace_fn fco=(
NumF1=fco.getNumFaces()
fco.CreateFace (fco.getSelection #Vertex as array); try fco.Commit() catch()
NumF2=fco.getNumFaces()
NumF1 != NumF2
)


fn BridgeBorder_fn fco =(
NumF1=fco.getNumFaces()
fco.ButtonOp #BridgeBorder
NumF2=fco.getNumFaces()
NumF1 != NumF2
)

fn BridgePolygon_fn fco =(
NumF1=fco.getNumFaces()
fco.ButtonOp #BridgePolygon
NumF2=fco.getNumFaces()
NumF1 != NumF2
)

fn BridgeEdge_fn fco =(
NumF1=fco.getNumFaces()
fco.ButtonOp #BridgeEdge
NumF2=fco.getNumFaces()
NumF1 != NumF2
)


fn ViewDirection_Z_fn =(inverse(getViewTM())).row3

fn FilterOpenVert_fn fco=(
usOpenVert=(fco.getSelection #Vertex) as Array
OpenE=#()
resultType = openEdges.Check currentTime selection[1] &OpenE
allOpnVert=for e in OpenE collect fco.GetEdgeVertex e 1
FilterOpenVert = #()
	for i=1 to usOpenVert.count  do
	if	 findItem allOpnVert usOpenVert[i]!=0 do appendIfUnique FilterOpenVert usOpenVert[i]
FilterOpenVert.count>2
)

fn PostWeld_fn fco = try (fco.weldThreshold=0.002; fco.buttonOp #WeldSelected)
catch (fco.weldVertexThreshold=0.002; fco.buttonOp #WeldVertex)

fn VertConnect_ThroughE_fn fco =(
			Sys0=getRefCoordSys()
			toolMode.coordsys #local
			NumF1=fco.getNumFaces()
arVs=for i=1 to selection.count collect (getVertSelection selection[i].mesh) as Array
startVertex_id=arVs[num_CurO][1]

global startPosition_p3
startPosition_p3=fco.GetVertex arVs[num_CurO][1]
global endPosition_p3
endPosition_p3=fco.GetVertex arVs[num_CurO][2]

viewDirection_p3=ViewDirection_Z_fn()

try (fco.cutVertices startVertex_id endPosition_p3 viewDirection_p3)
catch ( fco.StartCut #Vertex startVertex_id endPosition_p3 viewDirection_p3 node:selection[num_CurO]; fco.Commit() )
			setRefCoordSys Sys0
			PostWeld_fn fco
			NumF2=fco.getNumFaces()
			NumF1 != NumF2
)

fn EdgeConnect_ThroughE_fn fco =(
tryInit fco
arEs=for i=1 to selection.count collect (universal.GetSelectionEdge fco i) as Array
if arEs[num_CurO].count==2 do
(
startEdge_id=arEs[num_CurO][1]
EndEdge_id=arEs[num_CurO][2]
viewDirection_p3=ViewDirection_Z_fn()

if iskindof fco Editable_poly then
(fco.cutEdges startEdge_id .5 EndEdge_id .5 viewDirection_p3
arEs=fco.getSelection #Edge
fco.setSelection #Edge arEs)
else
if iskindof fco Edit_poly do
		(
		setVertSelection selection[num_CurO] fco #{} keep:off
		for e in arEs[num_CurO] do fco.DivideEdge e .5 node:selection[num_CurO]; fco.Commit()
		arVs=for i=1 to selection.count collect (getVertSelection selection[num_CurO].mesh) as Array
		startVertex_id=arVs[num_CurO][1]
		endPosition_p3=fco.GetVertex arVs[num_CurO][2] node:selection[num_CurO]
		fco.setSelection #Edge #{} node:selection[num_CurO]
		fco.StartCut #Vertex startVertex_id endPosition_p3 viewDirection_p3 node:selection[num_CurO]; fco.Commit()
		)
	)
)

fn VertConn_fn fco =(
NumF1=fco.getNumFaces()
fco.ButtonOp #ConnectVertices
NumF2=fco.getNumFaces()
NumF1 != NumF2
)

fn so1_operation_fn fco =(
		if not VertConn_fn fco then-- Connect Vertex
		if not (VertConnect_ThroughE_fn fco) then
		if FilterOpenVert_fn fco
				then TriFace_fn fco -- TriFace
	max select
	)

fn DivideEdg_fn fco =($.selectedVerts=#{(fco.DivideEdge ((polyop.getEdgeSelection $)as array)[1] 0.5)})
		--catch (fco.DivideEdge (Es_ as array)[1] 0.3 node:selection[num_CurO]; fco.Commit())

fn FaceBy2EdgVectors fco=
try (
	NumF1=fco.getNumFaces()
	OE= #()
	openEdges.Check currentTime Selection[1] &OE
	edg0=fco.GetSelection #Edge
	if not (edg0*(OE as BitArray)).isEmpty
	then
		(
			VuE=try (for i in edg0 collect polyop.getVertsUsingEdge fco #{i}) catch for i in edg0 collect #{(fco.GetEdgeVertex i 1 node:selection[1]),(fco.GetEdgeVertex i 2 node:selection[1])}
			v0=((VuE[1]*VuE[2]) as array)[1]
			v12=((VuE[1]-VuE[2])+(VuE[2]-VuE[1])) as array
			v0_pos=try polyop.getvert fco v0 catch (fco.GetVertex v0 node:selection[1])
			v12pos=try for i in v12 collect polyop.getvert fco i catch for i in v12 collect (fco.GetVertex i node:selection[1])
			newVpos=(v12pos[1]+(v12pos[2]-v0_pos))
			newV=try polyop.createVert fco newVpos catch fco.CreateVertex newVpos*(selection[1]).transform node:selection[1]
			polyop.createPolygon fco #(v12[1], newV, v12[2], v0)
			fco.SetSelection #Vertex #{newV}
		)
NumF2=fco.getNumFaces()
NumF1 != NumF2
) catch false

fn ConnectVertByEdges_fn fco=
try (
with redraw off(
NumF1=fco.getNumFaces()
baE=polyop.getEdgeSelection $ as Array

VuE1=polyop.getVertsUsingEdge $ baE[1] as Array
VuE2=polyop.getVertsUsingEdge $ baE[2] as Array

$.ConnectEdges edgeFlag:1
baE1=polyop.getEdgeSelection $

if not 
(
polyop.setVertSelection $ (#{VuE1[1]}+#{VuE2[1]})
$.ConnectVertices vertexFlag:1
polyop.setVertSelection $ (#{VuE1[2]}+#{VuE2[2]})
$.ConnectVertices vertexFlag:1
)
do
(
polyop.setVertSelection $ (#{VuE1[1]}+#{VuE2[2]})
$.ConnectVertices vertexFlag:1
polyop.setVertSelection $ (#{VuE1[2]}+#{VuE2[1]})
$.ConnectVertices vertexFlag:1
)
$.SetSelection #Edge #{}
polyop.setEdgeSelection $ baE1
$.EditablePoly.Remove ()

VuEend=polyop.getVertsUsingEdge $ baE as Array
VertClear2=((for i in VuEend where (polyop.getEdgesUsingVert $ i).numberset == 2 collect i) as BitArray)
polyop.setVertSelection $ VertClear2; $.EditablePoly.Remove selLevel:#Vertex flag:1
polyop.setEdgeSelection $ baE
NumF2=fco.getNumFaces()
if	NumF1 == NumF2 do (max undo; polyop.setEdgeSelection $ baE)
NumF1 != NumF2
)
)catch (max undo ;false)

fn EdgConnect_fn fco =(
NumF01=fco.getNumFaces()
fco.connectEdgeSegments=1
fco.ButtonOp #ConnectEdges
NumF02=fco.getNumFaces()
if NumF01!=NumF02 do 
(
baE1=polyop.getEdgeSelection $
fco.ButtonOp #GrowSelection
baE2=polyop.getEdgeSelection $
polyop.setEdgeSelection $ (baE2-baE1)
)
NumF01!=NumF02
)

fn conn2Edg_fn fco =(
NumF1=fco.getNumFaces()
EdgConnect_fn fco
NumF2=fco.getNumFaces()
NumF1 != NumF2
)

fn so2_operation_fn fco =(
--if (if Es_.numberset==2 do if OpenEdges_sel_less2_fn() and isEdgeStream_fn fco do DistanceConnect_fn())==undefined do
if Es_.numberset==1 then DivideEdg_fn fco -- divide
else
if Es_.numberset==2
then (
	if not BridgeEdge_fn fco then
	if not ConnectVertByEdges_fn fco then
	
	if not conn2Edg_fn fco then 
	if not FaceBy2EdgVectors fco then EdgeConnect_ThroughE_fn fco
	)
else
	(
	if FlowConnectSwitcher == undefined do FlowConnectSwitcher=false
	if FlowConnectSwitcher then macros.run "PolyTools" "FlowConnect" else EdgConnect_fn fco -- Edge Connect
	)
)

fn so4_operation_fn fco =(
if (fco.getSelection #Face).numberset > 1 
then if BridgePolygon_fn fco==off do (fco.ToggleCommandMode #QuickSlice)
else (try fco.tesselateBy = 1 catch fco.tessellateByFace = 1; fco.buttonop #Tessellate; max select)
)

fn vSETi_sel_fn fco=(i_sel=1; Vet_ar=#()
				Vet_ar=for i=1 to selection.count collect (getVertSelection selection[i].mesh)
				while Vet_ar[i_sel].numberset==0 do i_sel+=1
				i_sel)
fn eSETi_sel_fn fco=(i_sel=1
				Edge_ar=for i=1 to selection.count collect (universal.GetSelectionEdge fco i)
				while Edge_ar[i_sel].numberset==0 do i_sel+=1
				i_sel)


------------------------- Script -------------------------
gco = modPanel.getCurrentObject()

if keyboard.escPressed then FixResetObj_fn()
else
if selection.count==0 then GabaritAssigner_fn() 
else
if (subObjectLevel==0 or getCommandPanelTaskMode()!=#modify) then AddModiferSuit_fn() 
else
if iskindof gco Editable_poly or iskindof gco Edit_poly then
case subobjectlevel of
					(
					 1: (
							selected_arr=for i=1 to selection.count where not (getVertSelection selection[i].mesh).isEmpty collect (getVertSelection selection[i].mesh)
							if selected_arr.count>0 and selected_arr[1].numberset>1 then (num_CurO=vSETi_sel_fn gco; so1_operation_fn gco) else
							case selected_arr.count of
							(
							0: (
								try (UIAccessor.PressButton (for i in windows.getChildrenHWND #max where i[5]=="Cut" do exit with i[1]))
								catch UIAccessor.PressButton (for i in (windows.getChildrenHWND (windows.getDesktopHWND())) where i[5]=="Cut" do exit with i[1])
								)
							1: (
								try (UIAccessor.PressButton (for i in windows.getChildrenHWND #max where i[5]=="Target Weld" do exit with i[1]))
								catch UIAccessor.PressButton (for i in (windows.getChildrenHWND (windows.getDesktopHWND())) where i[5]=="Target Weld" do exit with i[1])
								)
							)
						)
					 2: (
					 	tryInit gco
					 	selected_arr=for i=1 to selection.count where not (getEdgeSelection selection[i].mesh).isEmpty collect ((getEdgeSelection selection[i].mesh)as array)
						
					 	if selected_arr.count==0 do 
					 	try (UIAccessor.PressButton (for i in windows.getChildrenHWND #max where i[5]=="Cut" do exit with i[1]))
						catch UIAccessor.PressButton (for i in (windows.getChildrenHWND (windows.getDesktopHWND())) where i[5]=="Cut" do exit with i[1])
						if selected_arr.count>0 do (num_CurO=eSETi_sel_fn gco; Es_=universal.GetSelectionEdge gco num_CurO; so2_operation_fn gco)
						)
					 3: if not (max select; BridgeBorder_fn gco) do macros.run "Editable Polygon Object" "EPoly_Cap"
					 4: (if (gco.getSelection #Face).numberset == 0 then try gco.ToggleCommandMode #CutFace catch gco.ToggleCommandMode #Cut
							else so4_operation_fn gco)
					 5: gco.ToggleCommandMode #QuickSlice
					)
else
if superclassof gco == shape do try (ShapeConn_fn gco; max select) catch()
redrawviews()
)