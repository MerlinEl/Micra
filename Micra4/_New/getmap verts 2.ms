

macroscript multiObjectsUnwrapMacro
	category:"UVWtoolBox"
	buttonText:"multiUnwrap"
	toolTip:"multiObjectsUnwrap"
(
global multiObjUnwrapFloater
global multiObjUnwrapRollout
try(removeRollout multiObjUnwrapRollout)catch()
try(closerolloutfloater multiObjUnwrapFloater)catch()

rollout multiObjUnwrapRollout "multiObjectsUnwrap 1.31b"
(
group "multi Objects Unwrap"
	(
	spinner channel_osd "channel:" range:[1,99,1] type:#integer scale:1 fieldwidth:28
	button editUVW_osd "unwrap UV's" align:#left width:72
	button copyUVW_osd "set UV's" align:#right offset:[0,-26] width:50 enabled:false
	button cancelUVW_osd "Cancel" enabled:false
	checkbox useExUVW_osd "use previous unwrap" checked:true
	checkbox defCh_osd "for a new channel" checked:true
	spinner defChRepl_osd "use the channel : " range:[1,99,1] type:#integer scale:1 fieldwidth:20
	checkbox hunterCollapse_osd "convert to polys" checked:false
	button infoHC_osd "?" align:#right height:18 width:16 offset:[0,-22]
	dropdownlist weldType_osd "mapVertices operation:" items:#("don't break mapVertices","break and don't weld","break and weld","break + clusters weld") selection:4 width:108
	button info_osd "?" align:#right height:18 width:16 offset:[0,-26]
	progressBar pBar value:0 color:blue
	)
label lb1 "by Olivier Vandecasteele"
label lb2 "email: gray@skynet.be"

global sel=undefined
global faceIndex=undefined
global uvwRef=undefined

fn addUnwrapIfNecessary obj channel reuse =
	(
	if reuse then
		(
		if classof obj.modifiers[1]!=Unwrap_UVW
			then
				(
				addModifier obj (Unwrap_UVW ())
				obj.modifiers[1].unwrap.setMapChannel channel
				)
			else
				(
				currentChannel=obj.modifiers[1].unwrap.getMapChannel()
				case currentChannel of
					(
					0: currentChannel=1
					1: currentChannel=0
					)
				if channel!=currentChannel do
					(
					addModifier obj (Unwrap_UVW ())
					obj.modifiers[1].unwrap.setMapChannel channel
					)
				)
		)
	else
		(
		addModifier obj (Unwrap_UVW ())
		obj.modifiers[1].unwrap.setMapChannel channel
		)
	)--fn

fn findSubItem array toFind =
	(
	index=0
	for subArray in array do
		(
		idx=findItem subArray toFind
		if idx!=0 then index=idx
		)--for
	index
	)--fn

fn getFaceUVClusters obj channel =
	(
	facesArray=#()
	objUnwrap=obj.modifiers[1].unwrap
	objUnwrap2=obj.modifiers[1].unwrap2
	objUnwrap.setMapChannel channel
	objUnwrap.displayMap false
	objUnwrap2.setGridVisible false
	objUnwrap2.setTVSubObjectMode 3
	objUnwrap2.setTVElementMode true
	userSel=objUnwrap2.getSelectedFaces()
	for f=1 to obj.numFaces do
		(
		if findSubItem facesArray f==0 do
			(
			objUnwrap2.selectFaces #{f}
			objUnwrap2.selectElement()
			currentCluster=objUnwrap2.getSelectedFaces()
			currentClusterA=currentCluster as array
			append facesArray currentClusterA
			)
		)--for f
	objUnwrap2.selectFaces userSel
	facesArray
	)--fn

fn copyMapChannelDirect obj fromChannel toChannel =
	(
	returnSymbol=false
	classOfObj=classof obj
	if classOfObj==Editable_mesh do
		(numMapVerts=meshOp.getNumMapVerts obj fromChannel
		meshOp.setNumMapVerts obj toChannel numMapVerts
		for mv=1 to numMapVerts do
			(currentMapVert=meshOp.getMapVert obj fromChannel mv
			meshOp.setMapVert obj toChannel mv currentMapVert)
		numMapFaces=meshOp.getNumMapFaces obj fromChannel
		meshOp.setNumMapFaces obj toChannel numMapFaces
		for mf=1 to numMapFaces do
			(currentMapFace=meshOp.getMapFace obj fromChannel mf
			meshOp.setMapFace obj toChannel mf currentMapFace)
		returnSymbol=true
		)--Editable_mesh
	if ((classOfObj==Editable_Poly)or(classOfObj==PolyMeshObject)) do
		(numMapVerts=polyOp.getNumMapVerts obj fromChannel
		polyOp.setNumMapVerts obj toChannel numMapVerts
		for mv=1 to numMapVerts do
			(currentMapVert=polyOp.getMapVert obj fromChannel mv
			polyOp.setMapVert obj toChannel mv currentMapVert)
		numMapFaces=polyOp.getNumMapFaces obj fromChannel
		polyOp.setNumMapFaces obj toChannel numMapFaces
		for mf=1 to numMapFaces do
			(currentMapFace=polyOp.getMapFace obj fromChannel mf
			polyOp.setMapFace obj toChannel mf currentMapFace)
		returnSymbol=true
		)--Editable_Poly
	returnSymbol
	)--fn

fn allowMapChannel obj channel insteadOfDefault =
	(
	returnSymbol=false
	classOfObj=classof obj
	if classOfObj==Editable_mesh do
		( numMapChannels=(meshOp.getNumMaps obj)-1
		if numMapChannels<channel do meshOp.setNumMaps obj (channel+1)
		currentMapSupport=meshOp.getMapSupport obj channel
		if currentMapSupport==false do
			( meshOp.defaultMapFaces obj channel
			meshOp.setMapSupport obj channel true
			if (channel!=1 and insteadOfDefault!=0) then copyMapChannelDirect obj insteadOfDefault channel
			)--if
		returnSymbol=true
		)--Editable_mesh
	if ((classOfObj==Editable_Poly)or(classOfObj==PolyMeshObject)) do
		( numMapChannels=(polyOp.getNumMaps obj)-1
		if numMapChannels<channel do polyOp.setNumMaps obj (channel+1)
		currentMapSupport=polyOp.getMapSupport obj channel
		if currentMapSupport==false do
			( polyOp.defaultMapFaces obj channel
			polyOp.setMapSupport obj channel true
			if (channel!=1 and insteadOfDefault!=0) then copyMapChannelDirect obj insteadOfDefault channel
			)--if
		returnSymbol=true
		)--Editable_Poly
	returnSymbol
	)--fn

fn copyMapChannel obj fromChannel toChannel =
	(
	if defCh_osd.checked then insteadOfDefault=defChRepl_osd.value else insteadOfDefault=0
	if insteadOfDefault!=0 then allowMapChannel obj insteadOfDefault 0
	allowMapChannel obj toChannel insteadOfDefault
	allowMapChannel obj fromChannel insteadOfDefault
	returnSymbol=copyMapChannelDirect obj fromChannel toChannel
	returnSymbol
	)--fn

fn resetXFormAndFlip obj = 
	(
	rotvalue=obj.rotation
	obj.rotation=(quat 0 0 0 1)
	M=obj.transform
	obj.transform=transMatrix obj.pos
	p=obj.objecttransform*(inverse obj.transform)
	obj.objectoffsetPos=[0,0,0]
	obj.objectoffsetRot=(quat 0 0 0 1)
	obj.objectoffsetScale=[1,1,1]
	M.translation=[0,0,0]
	M=p*M
	xformMod=XForm()
	addmodifier obj xformMod
	xformMod.gizmo.transform=M
	obj.rotation=rotvalue
	addmodifier obj (Normalmodifier flip:true)
	)--fn

on info_osd pressed do
	(
	msg="choose the right operating mode:\n\n"
	msg+="break + clusters weld (best mode): if you use functions that modify and break yours UVs. Weld by Clusters.\n"
	msg+="break and weld: if you use functions that modify and break yours UVs. Weld global.\n"
	msg+="don't break (fast): if you only move, rotate, scale yours UVs and functions like Pack\n"
	msg+="break and don't weld (fast): same as 'break and weld' but each UV  become independent"
	messageBox(msg) title:"Operating mode"
	)--on

on infoHC_osd pressed do
	(
	msg="Same as 'convert to Editable Poly'\n"
	msg+="beware: the stack will be collapsed!\n"
	msg+="Use this option with caution : no undo available"
	messageBox(msg) title:"Collapse option"
	)--on

on editUVW_osd pressed do
	(
	vn=maxVersion()
	sel=#()
	if selection.count>0 then
		(
		for obj in selection where canConvertTo obj Editable_Poly do
			(
			if not(classOf obj==Editable_Poly or classOf obj==PolyMeshObject or classOf obj==Editable_mesh)
				then ( if vn[1]<7000 then addModifier obj (Edit_Mesh ()) else addModifier obj (Edit_Poly ()) )
			if ((obj.scale.x < 0) OR (obj.scale.y < 0) OR (obj.scale.z < 0)) do (resetXFormAndFlip obj)
			allowMapChannel obj 1 0
			append sel obj
			)--for obj
		if sel.count>1 then
			(
			max modify mode
			workChannel=channel_osd.value
			hide sel
			maxops.cloneNodes sel cloneType:#copy newNodes:&SelNewObj
			for obj in SelNewObj do
				(
				if classOf obj==Editable_mesh then
					(
					convertToMesh obj
					for face=1 to obj.numfaces do ( for edge=1 to 3 do ( setedgevis obj face edge true ) )
					)
				convertToPoly obj
				)
			if workChannel!=1 do ( for obj in SelNewObj do ( copyMapChannel obj workChannel 1 ) )
			faceIndex=#()
			count=0
			for i=1 to SelNewObj.count do
				(
				obj=SelNewObj[i]
				currentFaces=for f=1 to obj.numFaces collect (count+f)
				append faceIndex currentFaces
				count+=obj.numFaces
				)
			for i=2 to SelNewObj.count do polyOp.attach SelNewObj[1] SelNewObj[i]
			uvwRef=SelNewObj[1]
			convertToPoly uvwRef
			uvwRef.name="multiObjectsUnwrap"
			unhide uvwRef
			select uvwRef
			editUVW_osd.enabled=false
			channel_osd.enabled=false
			cancelUVW_osd.enabled=true
			copyUVW_osd.enabled=true
			addModifier uvwRef (Unwrap_UVW ())
			uvwRef.modifiers[1].unwrap.setMapChannel 1
			uvwRef.modifiers[1].unwrap.edit()
			uvwRef.modifiers[1].unwrap.displayMap false
			uvwRef.modifiers[1].unwrap2.setGridVisible false
			uvwRef.modifiers[1].unwrap2.setTVSubObjectMode 3
			uvwRef.modifiers[1].unwrap2.setTVElementMode true
			)--if sel.count>1
		else
			(
			if sel.count==1
				then
					(
					max modify mode
					obj=sel[1]
					select obj
					addUnwrapIfNecessary obj channel_osd.value useExUVW_osd.checked
					obj.modifiers[1].unwrap.edit()
					obj.modifiers[1].unwrap.displayMap false
					obj.modifiers[1].unwrap2.setGridVisible false
					obj.modifiers[1].unwrap2.setTVSubObjectMode 3
					obj.modifiers[1].unwrap2.setTVElementMode true
					)
				else messageBox("select several objects!")
			)
		)
	else messageBox("nothing selected")
	)--on

on copyUVW_osd pressed do
	(
	if sel.count>0 then
		(
		startTime=timeStamp()
		max create mode
		unhide sel
		clearSelection()
		disableSceneRedraw()
		for i=1 to sel.count do
			(
			pBar.value=((i as float/sel.count as float)*100.0)as integer
			obj=sel[i]
			if obj.numFaces==faceIndex[i].count then
				(
				select obj
				addUnwrapIfNecessary obj channel_osd.value useExUVW_osd.checked
				obj.modifiers[1].enabled=true
				obj.modifiers[1].name="Unwrap UVW ch"+(channel_osd.value as string)
				uvwRefModUnwrap=uvwRef.modifiers[1].unwrap
				objModUnwrap=obj.modifiers[1].unwrap				
				objModUnwrap2=obj.modifiers[1].unwrap2
				if weldType_osd.selection==3 do
					(
					max modify mode
					objModUnwrap.edit()
					objModUnwrap2.setTVSubObjectMode 3
					nf=objModUnwrap.numberPolygons()
					facesClusterArray=#(for f=1 to nf collect f)
					)
				if weldType_osd.selection==4 do
					(
					max modify mode
					objModUnwrap.edit()
					objModUnwrap2.setTVSubObjectMode 3
					facesClusterArray=getFaceUVClusters obj 1
					objModUnwrap.setMapChannel channel_osd.value
					)				
				uvwRefModUnwrapgetVertexPosition=uvwRefModUnwrap.getVertexPosition
				uvwRefModUnwrapgetVertexIndexFromFace=uvwRefModUnwrap.getVertexIndexFromFace
				objModUnwrapSetVertexPosition=objModUnwrap.SetVertexPosition
				objModUnwrapgetVertexIndexFromFace=objModUnwrap.getVertexIndexFromFace
				objModUnwrapsetFaceVertex=objModUnwrap.setFaceVertex
				for f=1 to obj.numFaces do
					(
					nVerts=uvwRefModUnwrap.numberPointsInFace faceIndex[i][f]
					for v=1 to nVerts do
						(
						coord=uvwRefModUnwrapgetVertexPosition 0f (uvwRefModUnwrapgetVertexIndexFromFace faceIndex[i][f] v)
						case weldType_osd.selection of
							(
							1: objModUnwrapSetVertexPosition 0f (objModUnwrapgetVertexIndexFromFace f v) coord
							default: objModUnwrapsetFaceVertex coord f v false
							)
						)
					)
				if ((weldType_osd.selection==3)or(weldType_osd.selection==4)) do
					(
					objModUnwrap2.setTVSubObjectMode 3
					objModUnwrap2.setTVElementMode false
					objModUnwrap.setWeldThreshold 0.001
					for clusterFace in facesClusterArray do
						(
						objModUnwrap2.selectFaces (clusterFace as bitarray)
						objModUnwrap.weldSelected()
						)
					objModUnwrap2.selectFaces #{}
					objModUnwrap2.setTVElementMode true
					)
				)
			else (format "error : object % has changed\n" obj.name)
			)
		enableSceneRedraw()
		for obj in sel do obj.modifiers[1].enabledInViews=true
		if hunterCollapse_osd.checked do (for obj in sel do convertToPoly obj)
		pBar.value=0.0
		delete uvwRef
		editUVW_osd.enabled=true
		channel_osd.enabled=true
		copyUVW_osd.enabled=false
		cancelUVW_osd.enabled=false
		max create mode
		max views redraw
		endTime=timeStamp()
		format "\nSet UV's Processing took % seconds\n" ((endTime-startTime) / 1000.0)
		select sel
		)
	)--on

on cancelUVW_osd pressed do
	(
	max create mode
	pBar.value=0.0
	if isValidNode uvwRef do delete uvwRef
	sel2=#()
	for obj in sel do ( if isValidNode obj do ( unhide obj; append sel2 obj ) )
	select sel2
	editUVW_osd.enabled=true
	channel_osd.enabled=true
	copyUVW_osd.enabled=false
	cancelUVW_osd.enabled=false
	max views redraw
	)--on

)
multiObjUnwrapFloater = newRolloutFloater "multi-unwrap" 162 270
addRollout multiObjUnwrapRollout multiObjUnwrapFloater rolledUp:false
)--macro