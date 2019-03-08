
try(MakeUnique_NodeEventCallback.enabled = off ; MakeUnique_NodeEventCallback = null)catch()
plugin simpleManipulator NewPivot name:"PivotHelper" invisible:false classID:#(0x38ba17e3, 0x451d9fac) category:"Manipulators" version:1
(
	local ppNode, ppClass = NewPivot, gizClrR = [1,0,0], gizClrG = [0,1,0], gizClrB = [0,0,1]
	local ppDotsA = #([0,0,0], [-0.5,0.5,1], [-0.15,0.15,8.0], [-0.5,0.5,8.5], [0,0,10.0], [0.5,-0.5,8.5], [0.15,-0.15,8.0], [0.5,-0.5,1], [0,0,0], [0.5,0.5,1], [0.15,0.15,8.0], [0.5,0.5,8.5], [0,0,10.0], [-0.5,-0.5,8.5], [-0.15,-0.1,8.0], [-0.5,-0.5,1], [0,0,0])
	local ppDotsN = #([0,0,0], [-0.5,0.5,1], [0,0,10.0], [0.5,-0.5,1], [0,0,0], [0.5,0.5,1], [0,0,10.0], [-0.5,-0.5,1], [0,0,0])
	
	fn rotatePoints rotAxis:[0,0,1] rotCenter:[0,0,0] rotAngle:90 posArr: =
	(
		q = quat rotAngle (normalize rotAxis)
		for p in posArr collect (((p - rotCenter) * q) + rotCenter)
	) 
	fn makeCallback = if not iskindof MakeUnique_NodeEventCallback NodeEventCallback do
	(
		fn MakeUnique_Callback event handles = 
		(
			nodes = for n in handles where isvalidnode (local node = getanimbyhandle n) and iskindof node ppClass collect 
			(
				if InstanceMgr.CanMakeObjectsUnique node do (node.rcs = off ; InstanceMgr.MakeObjectsUnique node #individual)
				node
			)
			--format "tm changed > event:% nodes:%
			event nodes
		)
		MakeUnique_NodeEventCallback = NodeEventCallback added:MakeUnique_Callback modelStructured:MakeUnique_Callback
		MakeUnique_NodeEventCallback.enabled = on
	)	
	parameters main rollout:paramRoll
	( 
		currentRCS type:#string ui:et_note default:(getRefCoordSys()) animatable:off
		shownote type:#boolean ui:cb_shownote default:off animatable:off
		note type:#string ui:et_note default:"PivotNote" animatable:off
		notecolor type:#color ui:cp_notecolor default:yellow animatable:false		
		size type:#worldUnits ui:spn_size default:20 animatable:off
		type type:#radiobtnIndex ui:rb_Type default:1	 animatable:off
		rcs type:#boolean ui:btn_rcs default:off animatable:off

		on viewLabel set value do if isKindOf ppNode ppClass do (setUserPropBuffer ppNode value)
		on rcs set value do if isKindOf ppNode ppClass do 
		(
			if value == on then 
			(
				currentRCS = getRefCoordSys()
				toolMode.coordsys ppNode
				enableRefCoordSys (not value)
			)
			else
			(
				enableRefCoordSys (not value)
				setRefCoordSys (currentRCS as name) 
			)
		)
	)

	rollout paramRoll "Parameters"
	(
		colorpicker cp_notecolor "" pos:[1,6] fieldwidth:12 height:12
		checkbox cb_shownote "Show Note In Viewport" pos:[20,5]
		edittext et_note "" pos:[0,22] fieldWidth:134 height:18
		button btn_X "X" pos:[139,22] width:18 height:18
		label lbl1 "Gizmo:" pos:[3,43] width:30
		radiobuttons	rb_type "" labels:#("Arrow","Needle") default:1 columns:2 pos:[50,43]		
		spinner spn_size "Gizmo Size:	  " pos:[3,60] fieldwidth:70 range:[0.01, 1e5, 20.0]
		checkbutton btn_rcs "Set As RefCoordSys" pos:[3,80]	width:154 height:20 highlightColor:((colorMan.getColor #background) * 150.0)

		on cb_showViewLabel changed state do et_viewLabel.enabled = cb_showViewLabel.checked
		on btn_X pressed do et_note.text = ""
		on paramRoll open do 
		(
			if ppNode == null do (ppNode = refs.dependentNodes this firstOnly:on)
			if isKindOf ppNode ppClass do
			(
				if not (isKindOf ppNode[3][3].track Scale_Expression) do
				(
					ppNode[3][3].track = Scale_Expression()
					ppNode[3][3].track.SetExpression "[1,1,1]"
				)
			)
		)
	)
	
	on canManipulate target return false
	tool create (on mousePoint click do (nodeTM.translation = gridPoint ; #stop))
	on updateGizmos do
	(
		this.clearGizmos()
		local coords = if type == 1 then ppDotsA else ppDotsN
		local giz = manip.makeGizmoShape()
		for n in coords do (giz.AddPoint (n * (size/10)))
		this.addGizmoShape giz 0 gizClrB gizClrB
		local giz = manip.makeGizmoShape()
		for n in (rotatePoints rotAxis:[1,0,0] posArr:coords) do (giz.AddPoint (n * (size/10)))
		this.addGizmoShape giz 0 gizClrG gizClrG
		local giz = manip.makeGizmoShape()
		for n in (rotatePoints rotAxis:[0,-1,0] posArr:coords) do (giz.AddPoint (n * (size/10)))
		this.addGizmoShape giz 0 gizClrR gizClrR				
		if not shownote then (this.addGizmoText "" [0,0,0] 0 (notecolor/255.0) (notecolor/255.0))
		else (this.addGizmoText note [0,0,0] 0 (notecolor/255.0) (notecolor/255.0))
	)
	on create do makeCallback()
	on load do makeCallback()
) 
