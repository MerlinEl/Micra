global CreateStringVariableName
Function CreateStringVariableName NumChars = 
(
	--could create (pow 26 NumChars) possible variables
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local StringVar = ""
	for c = 1 to NumChars do StringVar += chars[ (random 1 26) ]
	return StringVar
)

Struct Layer
(
	LayerName,					--string
	ID,							--float
	ObjectHandleArray = #(),			--object handle id array
	ObjectStringIDArray = #(),			--unique string id array
	isHidden = false,				--boolean
	isFrozen = false,				--boolean
	isAltMat = false,				--alt material boolean
	
	isGroupHead = false,			--when true Objects contains layers.
	isGroupExpanded = true,
	isGroupMember = false,
	GroupHeadId = 0,
	--NumGroupMembers = 0,
	--isLocked,					--boolean - adjusts the selection filter.
	--notes, 						--string
	alternateMaterial, 				--material
	
--OPTIONS
	--exclusiveLights,				--boolean
	--usePrefix,					--boolean
	--prefix,						--string
	--useSuffix,					--boolean
	--suffix,						--string
		
--RENDERING PROPERTIES
	rendTimeType=2,					--int 1-4 (single, active, range, frames)
	rendNthFrame=1,					--boolean
	rendStart=0,					--int
	rendEnd=100,					--int
	rendPickupFrames="1,3,5-12",	--string
	rendFileNumberBase=0,			--int
	renderWidth=720,				--int
	renderHeight=486,				--int
	renderPixelAspect=.9,			--float
	rendColorCheck=false,			--boolean
	rendAtmosphere=true,			--boolean
	rendSuperBlack=false,			--boolean
	rendForce2Side=false,			--boolean
	renderEffects=true,				--boolean
	renderDisplacements=true,		--boolean
	rendFieldRender=false,			--boolean
	renderHidden=false,
	renderOutputFilename="",		--string
	rendSaveFile=false,				--boolean
	renderAtmosphericsArray = #(),	--array of atmospherics to use.
	renderEffectsArray = #(),			--array of effects to use
	rendEnableAtmosList = false,
	rendEnableEffectList = false,

--OBJECT PROPERTIES
	useLayerProperties = true,
	wireColor = ([random 0 255, random 0 255, random 0 255] as color),						--color
	gbufferChannel = 0,				--integer
	renderable = true,				--boolean
	visibility = 1.0, 					--float
	inheritVisibility = true, 			--boolean
	primaryVisibility = true, 			--boolean (render to camera)
	secondaryVisibility = true,			--boolean (render reflections)
	receiveShadows = true,			--boolean
	castShadows = true,			--boolean
	applyAtmospherics = true,		--boolean
	renderOccluded = false,			--boolean
	boxMode = false,				--boolean
	backFaceCull = true,			--boolean
	allEdges = false,				--boolean
	vertexTicks = false,				--boolean
	showTrajectory = false, 			--boolean
	xray = false,					--boolean
	ignoreExtents = false, 			--boolean
	showFrozenInGray = true,			--boolean
	showVertexColors = false,		--boolean
	vertexColorsShaded = false, 		--boolean
	showLinks = false,				--boolean
	showLinksOnly = false,			--boolean
	motionBlurOn = true,			--boolean
	motionBlur = 1, 				--name (0,1,2)
	imageMotionBlurMultiplier = 1,		--float
	generateCaustics = false,		--boolean
	rcvCaustics = true,				--boolean
	generateGlobalIllum = false,		--boolean
	rcvGlobalIllum = true,			--boolean
	boneEnable = false,				--boolean
	boneAutoAlign = true,			--boolean
	boneFreezeLength = true,		--boolean
	boneScaleType = 2,				--boolean
	boneAxis = 2,					--boolean
	boneAxisFlip = false,			--boolean

--ALT MATERIAL PROPERTIES
	Alt_MatObjArray = #(),
	Alt_MatType = 1,					--1 = matteshad, 2 = medit slot, 3=solid color
	Alt_opaqueAlpha  = true,
	Alt_applyAtmosphere  = false,
	Alt_atmosphereDepth = 1,
	Alt_receiveShadows = false,
	Alt_affectAlpha = false, 
	Alt_shadowBrightness = 0,
	Alt_color = black,
	Alt_amount = 50,
	Alt_map = undefined,
	Alt_useRefMap = true,
	
	Alt_meditSlot = 1,
	Alt_solidColor = blue,
	Alt_selfillum = 100

)



Struct zzz_LayerManager
(
	Version,
	ID,										--6 character string
	Layers = #(),
	--WorldLayer,
	UI,										--LM_UI Struct
	ActiveLayer = 1, 						--int ( for auto assignment )
	PropChange = 0,							--int ( for sub menu or prop dialog ),
	TempData_1 = 0,
	TempData_2 = 0,
	FloaterPosition = [300,300],			--point2
	PropertyFloaterPosition = [300,300],	--point2
	--FloaterSize, 							--point2
	MinimizedUI=false,						--boolean
	autoassign=true,						--boolean
	xrefLayers=false, 						--boolean
	

	Function GenerateLayerId =
	(
		local found = 0
		local LayRanIndex = (Random 10 60000) --.001 %
		if Layers.count > 0 then
		(
			for i = 1 to Layers.count do 
				(if Layers[i].ID == LayRanIndex then (found=1;exit))
			if found == 1 then (LM.IndexGenerate()) else (return LayRanIndex)
		)
		else (return LayRanIndex)
	
	),
	Function SetGroupExpand Index State =
	(
		Layers[Index].isGroupExpanded = State
		for L = (Index+1) to Layers.count do
		(
			if Layers[L].isGroupMember ==false then exit
			Layers[L].isGroupExpanded = State
		)
	),
	Function MoveLayer BeginLayIndex EndLayIndex = 
	(
		if BeginLayIndex == 1 or EndLayIndex == 1 then return 0
		setSaveRequired true
		if Layers[ BeginLayIndex ].isGroupMember == true then
		(
			--check to see if destination is in same group
			if Layers[ EndLayIndex ].isGroupMember == true and Layers[ EndLayIndex ].GroupHeadId == Layers[ BeginLayIndex ].GroupHeadId then
			(
				local tempLayer = copy Layers[ BeginLayIndex ]
				deleteitem Layers BeginLayIndex
				insertitem tempLayer Layers EndLayIndex
				if ActiveLayer == BeginLayIndex then ActiveLayer = EndLayIndex	
			)
		)
		else
		(
			if Layers[ EndLayIndex ].isGroupMember == false and  Layers[ EndLayIndex ].isGroupHead == false then
			(
				local tempLayer = copy Layers[ BeginLayIndex ]
				deleteitem Layers BeginLayIndex
				insertitem tempLayer Layers EndLayIndex
				if ActiveLayer == BeginLayIndex then ActiveLayer = EndLayIndex
			)
			else
			(
				if BeginLayIndex > EndLayIndex then
				(
					for L = EndLayIndex to 1 by -1 do
					(
						if Layers[L].isGroupHead == true then
						(
							local tempLayer = copy Layers[ BeginLayIndex ]
							deleteitem Layers BeginLayIndex
							insertitem tempLayer Layers L
							if ActiveLayer == BeginLayIndex then ActiveLayer = L
							exit				
						)
					)
				
				)
				else
				(
					local groupheadhit = 0
					for L = EndLayIndex to Layers.count do
					(
						if Layers[L].isGroupHead == true then
						(
							groupheadhit = 1
							continue		
						)
						if Layers[L].isgroupMember == false and groupHeadHit ==1 then
						(
							local tempLayer = copy Layers[ BeginLayIndex ]
							deleteitem Layers BeginLayIndex
							insertitem tempLayer Layers (L-1)
							if ActiveLayer == BeginLayIndex then ActiveLayer = (L-1)
							exit		
						)
					)
				
				)
			
			)
		)
	),
	
	Function AddNewLayer = 
	(
		local LName = ("Layer " + (Layers.count+1) as string)
		local LayerID = GenerateLayerId()
		append Layers (Layer LayerName:LName ID:LayerID ) 
		setSaveRequired true
		
		--set the render settings to what the file currently has	
		Layers[Layers.count].rendStart = animationrange.start 
		Layers[Layers.count].rendEnd = animationrange.end
		Layers[Layers.count].renderWidth = renderWidth	
		Layers[Layers.count].renderHeight = renderHeight
		Layers[Layers.count].renderPixelAspect = renderPixelAspect	
		Layers[Layers.count].rendColorCheck = rendColorCheck
		Layers[Layers.count].rendAtmosphere = rendAtmosphere
		Layers[Layers.count].rendSuperBlack = rendSuperBlack
		Layers[Layers.count].rendForce2Side = rendForce2Side
		Layers[Layers.count].renderEffects = renderEffects
		Layers[Layers.count].renderDisplacements = renderDisplacements
		Layers[Layers.count].rendFieldRender = rendFieldRender
		Layers[Layers.count].renderHidden = rendHidden
		--selectionSets[LName] = #()
	),
	
	Function CleanLayerObjectAry Layer =
	(
		for H = Layer.ObjectHandleArray.count to 1 by -1 do
		(
			if (maxops.getnodebyhandle Layer.ObjectHandleArray[H]) == undefined then
			(
				deleteitem Layer.ObjectHandleArray H
				deleteitem Layer.ObjectStringIDArray H
			)
		)
	),
	Function GetLayerObjects LayerInd =
	( --pass in Layer Index
		local L = #()
		if LayerInd == 1 then --world layer
		(	for o in objects where getappdata o 9901 == undefined do append L o )
		else
		(		
			for H = Layers[ LayerInd ].ObjectHandleArray.count to 1 by -1 do
			(
				local o = (maxops.getnodebyhandle Layers[ LayerInd ].ObjectHandleArray[H])
				if o == undefined then
				(
					deleteitem Layers[ LayerInd ].ObjectHandleArray H
					deleteitem Layers[ LayerInd ].ObjectStringIDArray H
				)
				else append L o
			)			
		)
		
		if Layers[LayerInd].isGroupHead == true then
		(
			local checklayer = LayerInd+1
			while Layers[checklayer].isGroupMember == true do
			(
				local TempL = GetLayerObjects checklayer
				for o in TempL do append L o
				if checkLayer == Layers.count then exit
				checkLayer += 1
			)
		)
		return L
	),
	
	Function DeleteLayer Index DelObjs:false DelSub:false=
	(
		local sub = true
		local count = (Index+1)		
		--delete items from main layer
		if DelObjs == true then delete (GetLayerObjects Index )
		
		--make array of layers to delete
		local Del_Lay_ID = #()
		append Del_Lay_ID Layers[ Index ].ID
		if DelSub == true and Layers[ Index ].isGroupHead == true then
		(

			while sub == true and count <= Layers.count do
			(
				if Layers[ count ].isGroupMember == true then 
				(
					append Del_Lay_ID Layers[ count ].ID
					if DelObjs == true then delete (GetLayerObjects Count )	
				)
				else sub = false
				count +=1
			)
		)
		else --remove subs as group members
		(
			local sub = true
			local count = Index+1
			while sub == true do	 
			(
				if Layers[ count ].isGroupMember == true then Layers[ count ].isGroupMember = false
				else sub = false
			)
		)
		
		--delete layers
		for L = Layers.count to 1 by -1 do
			if finditem Del_Lay_ID Layers[ L ].ID > 0 then deleteitem Layers L

	),
	
	Function ChangeLayerObjProperty Prop LayerInd Value= --pass the layer into the function
	(--pass in Layer ID so that i can check sub layers
		SetWaitCursor()
		setProperty Layers[LayerInd] Prop Value
		CleanLayerObjectAry Layers[LayerInd]
		local L = GetLayerObjects LayerInd
		for O in L do
		(
			if Prop == #visibility then
			(
				if getVisController O == undefined then
				(
					SetProperty 0 Prop Value
					O.visibility.controller.value = Value
				)
				else O.visibility.controller.value = Value
			)
			else 
			(
				try (SetProperty O Prop value)
				catch()
			)
		)
		if Layers[LayerInd].isGroupHead == true then
		(
			local checklayer = LayerInd+1
			while Layers[checklayer].isGroupMember == true do
			(
				ChangeLayerProperty Prop checklayer Value
				if checkLayer == Layers.count then exit
				checkLayer += 1
			)
		)
		SetArrowCursor()
		setSaveRequired true
	),
	
	Function ChangeLayerProperty Prop LayerInd Value= --pass the layer into the function -- layer props don't get assigned to objects directly
	(--pass in Layer ID so that i can check sub layers
		SetWaitCursor()
		setProperty Layers[LayerInd] Prop Value
		if Layers[LayerInd].isGroupHead == true then
		(
			local checklayer = LayerInd+1
			while Layers[checklayer].isGroupMember == true do
			(
				ChangeLayerProperty Prop checklayer Value
				if checkLayer == Layers.count then exit
				checkLayer += 1
			)
		)
		SetArrowCursor()
		setSaveRequired true
	),
	Function UpdateObjectProperties Obj Layer =
	(
		for P in (getpropnames Layer) do
		(
			if P == #visibility then
			(
				for o in Obj do
				(
					if (getVisController o) == undefined then
					(			
						setProperty o P (getProperty Layer P)
						o.visibility.controller.value = (getProperty Layer P)
					)
					else o.visibility.controller.value = (getProperty Layer P)
				)
			)
			else
			(
				try (setProperty Obj P (getProperty Layer P))
				catch()
			)
			if Layer.ishidden == true then (for i in obj where i.isselected ==true do i.isselected = false)
		)
	),
	Function AddObjectsToLayer LayerInd ObjectAry = --pass the layer Index into the function
	(		
		
		pushPrompt ("LM: Adding Objects to Layer " + LayerInd as string)
		SetWaitCursor()
		setSaveRequired true
		DisableSceneRedraw()
		if LayerInd == 1 then --WORLD LAYER
		(
			for o in ObjectAry do
			(
				--take it off the layer it was on
				local ObjAppData = getappdata o 9901
				--check to see if it has a id different than the layer it's being added to
				if (ObjAppData != undefined) and (ObjAppData != (Layers[LayerInd].Id as string)) then 
				(
					--remove the item from the current layer's object list
					for L in Layers where L.ID == (ObjAppData as integer) do
					( 
						local itemInd = finditem L.ObjectHandleArray o.inode.handle
						if itemInd > 0 then 
						(	
							deleteitem L.ObjectHandleArray itemInd
							deleteitem L.ObjectStringIDArray itemInd
						)
					)
				)

				
				deleteappdata o 9901
				deleteappdata o 9900
				if Layers[LayerInd].useLayerProperties == true then	UpdateObjectProperties o Layers[ LayerInd ]
				
			)
		)
		else
		(
			--object has two pieces of appdata stored in it
			--9900 = object id --> 10character string
			--9901 = layer id
	
			--within the layer data there are 2 arys to store the object info
			--ObjectHandleArray --> stores the object handle $.inode.handle
			--ObjectStringIDArray --> stores the unique string 10char 
	
			for o in ObjectAry do 
			(	
				local ObjAppData = getappdata o 9901
				--check to see if it has a id different than the layer it's being added to
				if (ObjAppData != undefined) and (ObjAppData != (Layers[LayerInd].Id as string)) then 
				(
					--remove the item from the current layer's object list
					for L in Layers where L.ID == (ObjAppData as integer) do
					( 
						local itemInd = finditem L.ObjectHandleArray o.inode.handle
						if itemInd > 0 then 
						(	
							deleteitem L.ObjectHandleArray itemInd
							deleteitem L.ObjectStringIDArray itemInd
						)
					)
				)
				--tag object with layer app data & unique object id
				local StringVar = (CreateStringVariableName 10)
				setappdata o 9900 StringVar 
				setappdata o 9901 (Layers[LayerInd].Id as string) 
				
				if finditem Layers[ LayerInd ] .ObjectHandleArray o.inode.handle == 0 then --put object in layer lists
				(
					append Layers[ LayerInd ] .ObjectHandleArray o.inode.handle
					append Layers[ LayerInd ] .ObjectStringIDArray StringVar 
				)
				--update object properties
			--	if Layers[LayerInd].useLayerProperties == true then UpdateObjectProperties o Layers[ LayerInd ] 	
			)
			--try settings the properties as a group
			if Layers[LayerInd].useLayerProperties == true then UpdateObjectProperties ObjectAry Layers[ LayerInd ] 	
		)
		EnableSceneRedraw()
		SetArrowCursor()
	),

	/*	
	Function MergeLayers =
	(
		if LM.TempData_1.count == 2 and LM.TempData_2.count > 0 then
		(
			execute ("tempLM = " + LM.TempData_1[2])
			local objary = #()
			for L = 1 to tempLM.layers.count where LM.TempData_2[L] == true do
			(
				for i in tempLM.Layers[L].objects do append
			
			)
			
			mergeMaxFile LM.TempData_1[1] #(ObjNames[1])
			
			tempLM = undefined
		)
		LM.TempData_1 = 0
		LM.TempData_2 = 0
	)*/
	Function HideLayer LayerInd State=
	( --pass in Layer ID so that i can check sub layers
		SetWaitCursor()
		try
		(
			DisableSceneRedraw()
			local L = GetLayerObjects LayerInd
			L.ishidden = (not State)
			if State == true then for o in L do InvalidateTM o
			else ( for o in L where o.isselected do deselect o) --so hidden objects aren't selected
			EnableSceneRedraw()
		)
		catch(EnableSceneRedraw();throw())
		--InvalidateWS -->if TM doesn't work
		Layers[LayerInd].ishidden = (not state)
		--check sub layers
		if Layers[LayerInd].isGroupHead == true then
		(
			local checklayer = LayerInd+1
			while Layers[checklayer].isGroupMember == true do
			(
				HideLayer checklayer State
				if checkLayer == Layers.count then exit
				checkLayer += 1
			)
		)
		SetArrowCursor()
		setSaveRequired true
	),
	Function FreezeLayer LayerInd State= 
	(--pass in Layer ID so that i can check sub layers
		SetWaitCursor()
		local L = GetLayerObjects LayerInd
		L.isfrozen = State
		Layers[LayerInd].isfrozen = state
		if Layers[LayerInd].isGroupHead == true then
		(
			local checklayer = LayerInd+1
			while Layers[checklayer].isGroupMember == true do
			(
				FreezeLayer checklayer State
				if checkLayer == Layers.count then exit
				checkLayer += 1
			)
		)
		SetArrowCursor()
		setSaveRequired true
	),
	Function GetLMGlobals =
	(
		local SS = stringstream ""
		apropos "*" to:SS
		local theGlobals = #()
		local LM_Globals = #()
		local Final_Ary = #()
		seek SS 0
		while not eof SS do append theGlobals (readline SS)
		
		for i = 1 to theGlobals.count do
		(
			if ((findstring theGlobals[i] "LayerManager") != undefined ) and ((findstring theGlobals[i] "id") != undefined ) then
			(
				append LM_Globals theGlobals[i]
			)
		)
		--parse the globals
		for i = 1 to LM_Globals.count do
		(
			local varname = substring LM_Globals[i] ((findstring LM_Globals[i] "id:")+4) 6 
			if ( finditem Final_Ary varname) == 0 then append Final_Ary varname 
		
		)
		--return LM_Globals
		return Final_Ary
	),
	Function SetAltMat State LayerNum =
	(
		setSaveRequired true
		Layers[LayerNum].isAltMat  = State
		if State==true then --assigning alternate material
		(
			SetWaitCursor()
			--clear the altMatObjArray
			Layers[LayerNum].Alt_MatObjArray  = #()
			local LayerObjs = GetLayerObjects LayerNum
			--create material
			local AltMat
			case Layers[LayerNum].Alt_MatType of
			(
				1: ( --MATTE SHADOW
					AltMat=MatteShadow name:("ALT_Mat_"+LayerNum as string)
					AltMat.opaqueAlpha=Layers[LayerNum].Alt_opaqueAlpha  
					AltMat.applyAtmosphere=Layers[LayerNum].Alt_applyAtmosphere 
					AltMat.AtmosphereDepth=Layers[LayerNum].Alt_atmosphereDepth  
					AltMat.receiveShadows=Layers[LayerNum].Alt_receiveShadows  
					AltMat.AffectAlpha=Layers[LayerNum].Alt_affectAlpha  
					AltMat.shadowBrightness  =Layers[LayerNum].Alt_shadowBrightness  
					AltMat.Color=Layers[LayerNum].Alt_color 
					AltMat.amount = Layers[LayerNum].Alt_amount
					)
				2: ( --MATERIAL EDITOR MATERIAL
					AltMat = MeditMaterials[ Layers[LayerNum].Alt_meditSlot  ]			
				)
				3: ( -- SOLID COLOR
					AltMat = StandardMaterial name:("ALT_Mat_"+LayerNum as string)		
					AltMat.diffuse = Layers[LayerNum].Alt_solidColor 
					AltMat.ambient = Layers[LayerNum].Alt_solidColor 
					AltMat.specularLevel=0
					AltMat.glossiness=0
					AltMat.SelfIllumAmount=Layers[LayerNum].Alt_selfillum 
				)
			)
			
			--run thru objects on layer
			for i in LayerObjs where (superclassof i == Geometryclass or superclassof i == Shape) \
			and classof i != TargetObject do
			(	
				if i.material == undefined then
				(
					local TempMaterial = StandardMaterial()
					TempMaterial.name="LM-Default"
					i.material=TempMaterial
				)
				--look for existing material
				local found=0
				--store objects that have alternate material applied
				for j in Layers[LayerNum].Alt_MatObjArray do
				(
					if i.material == j[1].material then 
					(
						append j i
						found = 1
						exit
					)
				)
				if found == 0 then append Layers[LayerNum].Alt_MatObjArray #(i)
			) --end obj loop
			
			--loop obj group create new material for each group and assign
			for i in Layers[LayerNum].Alt_MatObjArray do
			(
				--create a new material
				if classof blend == modifier then
					NewBlendMat = BlendMaterial() --bones pro mod is loaded.
				else
					NewBlendMat = Blend()
							
				NewBlendMat.name = ("LMAlt_" + i[1].material.name)
				NewBlendMat.Map1 = AltMat
				NewBlendMat.Map2 = i[1].material
				--assign objects with alt material
				for j in i do j.material = NewBlendMat						
			)

			SetArrowCursor()

		)
		else -- unchecking alt material--return original material
		(
			--local LayerObjs = LM.FilterLayer LayerNum
			
			for i in Layers[LayerNum].Alt_MatObjArray do
			(			
				--OldMat = i[1].material.Map2
				for j in i where (isdeleted j ) != true do 
				(
					if (classof j.material == blend) or (classof j.material == blendmaterial) then
						j.material = j.material.Map2
				)				
			)

			Layers[LayerNum].Alt_MatObjArray=#()
		)
		
		
		if Layers[LayerNum].isGroupHead == true then
		(
			local checklayer = LayerNum+1
			while Layers[checklayer].isGroupMember == true do
			(
				if Layers[checklayer].isAltMat  != state then SetAltMat State checklayer 
				if checkLayer == Layers.count then exit
				checkLayer += 1
			)
		)
		
		SetArrowCursor()
	), ---END SetAltMat FN
	
	Function SetRenderSettings LayInd =
	(
		rendTimeType = Layers[ LayInd ].rendTimeType
		rendNthFrame= Layers[ LayInd ].rendNthFrame
		rendStart= Layers[ LayInd ].rendStart
		rendEnd= Layers[ LayInd ].rendEnd
		rendPickupFrames= Layers[ LayInd ].rendPickupFrames
		rendFileNumberBase= Layers[ LayInd ].rendFileNumberBase
		renderWidth= Layers[ LayInd ].renderWidth
		renderHeight= Layers[ LayInd ].renderHeight
		renderPixelAspect= Layers[ LayInd ].renderPixelAspect
		rendColorCheck= Layers[ LayInd].rendColorCheck
		rendAtmosphere= Layers[ LayInd ].rendAtmosphere
		rendSuperBlack= Layers[ LayInd ].rendSuperBlack
		rendForce2Side= Layers[ LayInd ].rendForce2Side
		renderEffects= Layers[ LayInd ].renderEffects
		renderDisplacements= Layers[ LayInd ].renderDisplacements
		rendFieldRender= Layers[ LayInd ].rendFieldRender
		rendHidden= Layers[ LayInd ].renderHidden
		rendOutputFilename= Layers[ LayInd ].renderOutputFilename
		rendSaveFile= Layers[ LayInd ].rendSaveFile
		if Layers[ LayInd ].rendEnableAtmosList == true then
		(
			for i = 1 to numatmospherics do
			(
				a = (getatmospheric i)
				if ( finditem Layers[ LayInd ].renderAtmosphericsArray a ) > 0 then
					setactive a true
				else
					setactive a false
			)				
		)
		if Layers[ LayInd ].rendEnableEffectList == true then
		(
			for i = 1 to numeffects do
			(
				e = (geteffect i)
				if ( finditem Layers[ LayInd ].renderEffectsArray e ) > 0 then
					setactive e true
				else
					setactive e false
			)				
		)
		max render scene
	),
	Function KillData =
	(
		local LID = ID
		LM = undefined
		execute (LID + " = undefined")
		deleteappdata globaltracks[1] 9901
		deleteAllChangeHandlers id:#LM_Handle	
	)

)

global zzz_LayerManager_load = #(timestamp(),sleep 1)