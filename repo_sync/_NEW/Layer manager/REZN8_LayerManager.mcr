--test -merging alt material active layers and objects
--test adding objects to alt mat active layer
--merge layers
--make layer from object color
--deselect objects by layer
--aquire selection sets
--layer lock
--filters for object selections
-- Info on how many objects/polys etc. a layer contains
--collapse layers

--ADD
--group option on add selected dialog

--BUG
--if 2 groups in a row, and no-grouped layer is moved down to go between the 2 groups, it goes below all
--a visibiity track is being created for the object.
(

	global zzz_LM_load = (
		print "lm load"
		print zzz_LayerManager
		--print zzz_LayerManager_load #nomap
		print (timestamp())
	)

	global  CreateStringVariableName --don't know why i have to add this.
	--UI COLOR PREFERENCES --
	local UI_HideCheckColor = ([186,223,239] as color) 			--highlight color of hide/unhide checkbutton
	local UI_PropDialogCheckColor = ([230,230,230]as color) 	--highlight color of category chec buttons in Properties dialog
	local UI_WorldCheckColor = ([234,234,234] as color) 		--highlight color of world layer checkbutton
	local UI_ActiveLayerCheckColor = ([255,247,175] as color) 	--highlight color of active layer checkbutton
	local UI_GroupLayerCheckColor = ([190,238,186] as color)	--highlight color of group layer checkbutton
	local UI_GroupMemberCheckColor = ([160,191,205] as color)	--highlight color of groupsub layer checkbutton
	local UI_XrefCheckColor = ([179,215,205] as color) 		--highlight color of xreflayers checkbutton
	-- END PREFERENCES--
	
	local LM_Version = 3.00
	Global LM, 
		Prop_Tab1_Roll, 
		Prop_Tab2_Roll, 
		Prop_Tab3_Roll, 
		Prop_Tab4_Roll, 
		LM_ExpandedMenu,
		LM_Roll, 
		LM_NewLayerRoll,  
		LM_World_ExpandedMenu, 
		LM_Group_ExpandedMenu,
		LayControlMenuExpand,
		LM_AboutRoll
	Global BMPPath = getFilenamePath ( getSourceFileName() )
	if UI_BMP_ControlsM == undefined then Global UI_BMP_ControlsM = openbitmap (BMPPath + "LM_V3_Controls_M.bmp")
	if UI_BMP_ControlsI == undefined then Global UI_BMP_ControlsI = openbitmap (BMPPath + "LM_V3_Controls_I.bmp")
	if UI_BMP_ButtonsM == undefined then Global UI_BMP_ButtonsM = openbitmap (BMPPath + "LM_V3_Buttons_M.bmp")
	if UI_BMP_ButtonsI == undefined then Global UI_BMP_ButtonsI = openbitmap (BMPPath + "LM_V3_Buttons_I.bmp")
	
	Rollout LM_AboutRoll "About Layer Manager" width:280 height:150
	(
		label n ""
		label A "Layer Manager V3.00 - Beta 01.60"
		label B "David Humpherys" 
		label b2 "\xa9 2001 REZN8"
		label C "***************************************************"
		label D "Send bugs, comments, or suggestions to:" 
		label F "david@rezn8.com" 
	)
	
--GENERAL PROPERTIES ROLLOUT
	Rollout Prop_Tab1_Roll "Layer Properties" width:398 height:550
	(

		checkbutton UI_Tab1 "General" width:65 height:25 pos:[4,4]  highlightcolor:UI_PropDialogCheckColor checked:true
		checkbutton UI_Tab2 "Rendering" width:75 height:25 pos:[69,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab3 "Objects" width:70 height:25 pos:[144,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab4 "Alternate Material" width:105 height:25 pos:[214,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab5 "Other" width:70 height:25 pos:[319,4] highlightcolor:UI_PropDialogCheckColor

		on UI_Tab2 changed state do
		(
			destroyDialog Prop_Tab1_Roll 
			createdialog Prop_Tab2_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu) 
		)
		on UI_Tab3 changed state do
		(
			destroyDialog Prop_Tab1_Roll 
			createdialog Prop_Tab3_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)
		on UI_Tab4 changed state do
		(
			destroyDialog Prop_Tab1_Roll 
			createdialog Prop_Tab4_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)		
		checkbutton UI_UseLayerProp "Automatic Layer Setting Assignment" pos:[9,50] width:375 checked:LM.Layers[LM.PropChange].useLayerProperties
		on UI_UseLayerProp changed state do LM.Layers[LM.PropChange].useLayerProperties = state
		
		groupBox grp1 "Layer Information" pos:[9,76] width:375 height:44
		editText UI_LayerName "Name:" pos:[20,96] width:150 text:LM.Layers[ LM.PropChange ].LayerName
		on UI_LayerName changed txt do 
		( 
			LM.Layers[LM.PropChange].LayerName = txt 
			execute ("LM_Roll.LToggle"+ LM.PropChange as string +".text = \"" + txt + "\"")
		)
		--checkbox UI_isHidden "Hide" pos:[253,30] width:49 height:17 checked:LM.Layers[ LM.PropChange ].isHidden
		--checkbox UI_isFrozen "Freeze" pos:[312,30] width:57 height:17 checked:LM.Layers[ LM.PropChange ].isFrozen
		groupBox grp2 "G-Buffer" pos:[270,76] width:115 height:44
		colorPicker UI_WireColor "WireColor" pos:[180,96] width:80 height:15 color:LM.Layers[ LM.PropChange ].wirecolor
		on UI_WireColor changed val do ( LM.ChangeLayerObjProperty #wirecolor LM.PropChange val )
		spinner UI_gbufferChannel "Channel:" pos:[320,96] width:55 height:16 type:#integer range:[0,99,(LM.Layers[ LM.PropChange ].gbufferChannel)]
		on UI_gbufferChannel changed val do ( LM.ChangeLayerObjProperty #gbufferChannel LM.PropChange val )
		groupBox grp3 "Rendering Control" pos:[9,127] width:192 height:168
		checkbox UI_renderable "Renderable" pos:[16,145] width:84 height:16 checked:LM.Layers[ LM.PropChange ].renderable
		on UI_renderable changed state do ( LM.ChangeLayerObjProperty #renderable LM.PropChange state )
		spinner UI_Visibility "Visibility:" pos:[135,146] width:60 height:16 range:[0,1, ( LM.Layers[ LM.PropChange ].visibility ) ]
		on UI_Visibility changed val do ( LM.ChangeLayerObjProperty #visibility LM.PropChange val )
		checkbox UI_inheritVisibility "Inherit Visibility" pos:[16,163] width:93 height:16 checked:LM.Layers[ LM.PropChange ].inheritVisibility
		on UI_inheritVisibility changed state do ( LM.ChangeLayerObjProperty #inheritVisibility LM.PropChange state )
		checkbox UI_primaryVisibility "Visible to Camera" pos:[16,181] width:105 height:16 checked:LM.Layers[ LM.PropChange ].primaryVisibility 
		on UI_primaryVisibility changed state do ( LM.ChangeLayerObjProperty #primaryVisibility LM.PropChange state )
		checkbox UI_secondaryVisibility "Visible to Reflection/Refraction" pos:[16,199] width:170 height:16 checked:LM.Layers[ LM.PropChange ].secondaryVisibility 
		on UI_secondaryVisibility changed state do (  LM.ChangeLayerObjProperty #secondaryVisibility LM.PropChange state )
		checkbox UI_receiveShadows "Receive Shadows" pos:[16,217] width:123 height:16 checked:LM.Layers[ LM.PropChange ].receiveShadows 
		on UI_receiveShadows changed state do (  LM.ChangeLayerObjProperty #receiveShadows LM.PropChange state )
		checkbox UI_castShadows "Cast Shadows" pos:[16,235] width:123 height:16 checked:LM.Layers[ LM.PropChange ].castShadows
		on UI_castShadows changed state do (  LM.ChangeLayerObjProperty #castShadows LM.PropChange state )
		checkbox UI_applyAtmospherics "Apply Atmospherics" pos:[16,253] width:123 height:16 checked:LM.Layers[ LM.PropChange ].applyAtmospherics 
		on UI_applyAtmospherics changed state do (  LM.ChangeLayerObjProperty #applyAtmospherics LM.PropChange state )
		checkbox UI_renderOccluded "Render Occluded Objects" pos:[16,271] width:153 height:16 checked:LM.Layers[ LM.PropChange ].renderOccluded
		on UI_renderOccluded changed state do ( LM.ChangeLayerObjProperty #renderOccluded LM.PropChange state )
		groupBox grp4 "Display Properties" pos:[213,127] width:172 height:230
		checkbox UI_boxMode "Display as Box" pos:[220,145] width:118 height:16 checked:LM.Layers[ LM.PropChange ].boxMode
		on UI_boxMode changed state do ( LM.ChangeLayerObjProperty #boxMode LM.PropChange state )
		checkbox UI_backFaceCull "Backface Cull" pos:[220,163] width:93 height:16 checked:LM.Layers[ LM.PropChange ].backFaceCull
		on UI_backFaceCull changed state do ( LM.ChangeLayerObjProperty #backFaceCull LM.PropChange state )
		checkbox UI_allEdges "Edges Only" pos:[220,181] width:105 height:16 checked:(not(LM.Layers[ LM.PropChange ].allEdges) )
		on UI_allEdges changed state do ( LM.ChangeLayerObjProperty #allEdges LM.PropChange state )
		checkbox UI_vertexTicks "Vertex Ticks" pos:[220,199] width:138 height:16 checked:LM.Layers[ LM.PropChange ].vertexTicks 
		on UI_vertexTicks changed state do ( LM.ChangeLayerObjProperty #vertexTicks LM.PropChange state )
		checkbox UI_showTrajectory "Trajectory" pos:[220,217] width:123 height:16 checked:LM.Layers[ LM.PropChange ].showTrajectory
		on UI_showTrajectory changed state do ( LM.ChangeLayerObjProperty #showTrajectory LM.PropChange state )
		checkbox UI_xray "See-Through" pos:[220,235] width:123 height:16 checked:LM.Layers[ LM.PropChange ].xray 
		on UI_xray changed state do ( LM.ChangeLayerObjProperty #xray LM.PropChange state )
		checkbox UI_ignoreExtents "Ignore Extents" pos:[220,253] width:123 height:16 checked:LM.Layers[ LM.PropChange ].ignoreExtents 
		on UI_ignoreExtents changed state do ( LM.ChangeLayerObjProperty #ignoreExtents LM.PropChange state )
		checkbox UI_showFrozenInGray "Show Frozen in Gray" pos:[220,271] width:153 height:16 checked:LM.Layers[ LM.PropChange ].showFrozenInGray 
		on UI_showFrozenInGray changed state do ( LM.ChangeLayerObjProperty #showFrozenInGray LM.PropChange state )
		
		checkbox UI_showVertexColors "Vertex Color" pos:[220,289] width:80 height:16 checked:LM.Layers[ LM.PropChange ].showVertexColors 
		on UI_showVertexColors changed state do ( LM.ChangeLayerObjProperty #showVertexColors LM.PropChange state )
		--dropDownList ddl1 "" pos:[238,265] width:96 height:21 items:#("Vertex Color", "Vertex Illumination", "Vertex Alpha")
		checkButton UI_vertexColorsShaded "Shaded" pos:[330,289] width:47 height:18 checked:LM.Layers[ LM.PropChange ].vertexColorsShaded
		on UI_vertexColorsShaded changed state do ( LM.ChangeLayerObjProperty #vertexColorsShaded LM.PropChange state )
		checkbox UI_showLinks "Show Links" pos:[220,315] width:153 height:16 checked:LM.Layers[ LM.PropChange ].showLinks 
		on UI_showLinks changed state do ( LM.ChangeLayerObjProperty #showLinks LM.PropChange state )
		checkbox UI_showLinksOnly "Show Links Only" pos:[220,333] width:153 height:16 checked:LM.Layers[ LM.PropChange ].showLinksOnly 
		on UI_showLinksOnly changed state do ( LM.ChangeLayerObjProperty #showLinksOnly LM.PropChange state )
		groupBox UI_MBGrp "Motion Blur" pos:[8,303] width:192 height:63
		radioButtons UI_motionblur "" pos:[17,342] width:184 height:16 labels:#("None", "Object", "Image") columns:3 default:LM.Layers[ LM.PropChange ].motionblur 
		on UI_motionblur changed stated do ( LM.ChangeLayerObjProperty #motionblur LM.PropChange state )
		checkbox UI_motionBlurOn "Enabled" pos:[16,321] width:153 height:16 checked:LM.Layers[ LM.PropChange ].motionBlurOn	
		on UI_motionBlurOn changed state do ( LM.ChangeLayerObjProperty #motionBlurOn LM.PropChange state )
		spinner UI_imageMotionBlurMultiplier "Multiplier" pos:[125,321] width:65 height:16 range:[0,1,( LM.Layers[ LM.PropChange ].imageMotionBlurMultiplier ) ]
		on UI_imageMotionBlurMultiplier changed val do ( LM.ChangeLayerObjProperty #imageMotionBlurMultiplier LM.PropChange val )
		groupBox grp6 "mental ray Rendering Control" pos:[8,374] width:192 height:94
		checkbox UI_generateCaustics "Generate Caustics" pos:[15,393] width:123 height:16 checked:LM.Layers[ LM.PropChange ].generateCaustics
		on UI_generateCaustics changed state do ( LM.ChangeLayerObjProperty #generateCaustics LM.PropChange state )
		checkbox UI_rcvCaustics "Receive Caustics" pos:[15,410] width:123 height:16 checked:LM.Layers[ LM.PropChange ].rcvCaustics
		on UI_rcvCaustics changed state do ( LM.ChangeLayerObjProperty #rcvCaustics LM.PropChange state )
		checkbox UI_generateGlobalIllum "Generate Global Illumination" pos:[15,428] width:154 height:16 checked:LM.Layers[ LM.PropChange ].generateGlobalIllum 
		on UI_generateGlobalIllum changed state do ( LM.ChangeLayerObjProperty #generateGlobalIllum LM.PropChange state )
		checkbox UI_rcvGlobalIllum "Receive Global Illumination" pos:[15,446] width:153 height:16 checked:LM.Layers[ LM.PropChange ].rcvGlobalIllum 
		on UI_rcvGlobalIllum changed state do ( LM.ChangeLayerObjProperty #rcvGlobalIllum LM.PropChange state )
		groupBox grp8 "Bone" pos:[213,362] width:172 height:144
		
		checkbox UI_boneEnable "Bone On/Off" pos:[220,381] width:89 height:16 checked:LM.Layers[ LM.PropChange ].boneEnable 
		on UI_boneEnable changed state do ( LM.ChangeLayerObjProperty #boneEnable LM.PropChange state )
		checkbox UI_boneAutoAlign "Auto-Align" pos:[220,399] width:89 height:16 checked:LM.Layers[ LM.PropChange ].boneAutoAlign enabled:UI_boneEnable.state
		on UI_boneAutoAlign changed state do ( LM.ChangeLayerObjProperty #boneAutoAlign LM.PropChange state )
		checkbox UI_boneFreezeLength "Freeze Length" pos:[220,417] width:89 height:16 checked:LM.Layers[ LM.PropChange ].boneFreezeLength enabled:UI_boneEnable.state
		on UI_boneFreezeLength changed state do ( LM.ChangeLayerObjProperty #boneFreezeLength LM.PropChange state )
		--button UI_BoneRealign "Realign" pos:[312,383] width:70 height:23
		--button UI_BoneReset "Reset Stretch" pos:[312,409] width:70 height:23
		radioButtons UI_boneScaleType "" pos:[223,454] width:59 height:48 labels:#("None", "Scale", "Squash") columns:1 default:LM.Layers[ LM.PropChange ].boneScaleType
		on UI_boneScaleType changed state do ( LM.ChangeLayerObjProperty #boneScaleType LM.PropChange state )
		radioButtons UI_BoneAxis "" pos:[300,456] width:30 height:48 labels:#("X", "Y", "Z") columns:1 default:LM.Layers[ LM.PropChange ].BoneAxis
		on UI_BoneAxis changed state do ( LM.ChangeLayerObjProperty #BoneAxis LM.PropChange state )
		groupBox grp9 "Stretch" pos:[213,439] width:81 height:67
		groupBox grp10 "Axis" pos:[293,439] width:92 height:67
		checkbox UI_boneAxisFlip "Flip" pos:[337,455] width:40 height:14 checked:LM.Layers[ LM.PropChange ].boneAxisFlip
		on UI_boneAxisFlip changed state do ( LM.ChangeLayerObjProperty #boneAxisFlip LM.PropChange state )
	
		button UI_PropDone "OK" pos:[306,515] width:79 height:26
		on UI_PropDone pressed do destroyDialog Prop_Tab1_Roll 	
		
		on Prop_Tab1_Roll moved loc do LM.PropertyFloaterPosition = [loc.x-3,loc.y-22]
		
	)	
	
--RENDERING PROPERTIES ROLLOUT
	Rollout Prop_Tab2_Roll "Layer Properties" width:398 height:550
	(

		checkbutton UI_Tab1 "General" width:65 height:25 pos:[4,4]  highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab2 "Rendering" width:75 height:25 pos:[69,4] highlightcolor:UI_PropDialogCheckColor checked:true
		checkbutton UI_Tab3 "Objects" width:70 height:25 pos:[144,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab4 "Alternate Material" width:105 height:25 pos:[214,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab5 "Other" width:70 height:25 pos:[319,4] highlightcolor:UI_PropDialogCheckColor
			
		on UI_Tab1 changed state do
		(
			destroyDialog Prop_Tab2_Roll
			createdialog Prop_Tab1_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)
		on UI_Tab3 changed state do
		(
			destroyDialog Prop_Tab2_Roll
			createdialog Prop_Tab3_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)
		on UI_Tab4 changed state do
		(
			destroyDialog Prop_Tab2_Roll
			createdialog Prop_Tab4_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				 style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)

		--UI TAB 2 (rendering)	
		groupBox grpr1 "Time Output" pos:[9,35] width:375 height:101
		radioButtons UI_rendTimeType "" pos:[18,50] width:127 height:180 columns:1 \
			labels:#("Single", "ActiveTime Segement", "Range:", "Frames:") default:LM.Layers[ LM.PropChange ].rendTimeType
		on UI_rendTimeType changed val do ( LM.ChangeLayerProperty #rendTimeType LM.PropChange val )
		spinner UI_rendNthFrame "Every Nth Frame:" pos:[283,55] width:87 height:16 \
			range:[1,100,LM.Layers[ LM.PropChange ].rendNthFrame] type:#integer 
		on UI_rendNthFrame changed val do ( LM.ChangeLayerProperty #rendNthFrame LM.PropChange val )
		spinner UI_rendFileNumberBase "Number Base:" pos:[290,80] width:80 height:16 \
			range:[1,100,LM.Layers[ LM.PropChange ].rendFileNumberBase ] type:#integer
		on UI_rendFileNumberBase changed val do ( LM.ChangeLayerProperty #rendFileNumberBase LM.PropChange val )
		spinner UI_rendStart "" pos:[75,80] width:60 height:16 \
			range:[0,10000,LM.Layers[ LM.PropChange ].rendStart ] type:#integer 
		on UI_rendStart changed val do ( LM.ChangeLayerProperty #rendStart LM.PropChange val )
		spinner UI_rendEnd "To:" pos:[157,80] width:60 height:16 \
			range:[0,10000,LM.Layers[ LM.PropChange ].rendEnd ] type:#integer
		on UI_rendEnd changed val do ( LM.ChangeLayerProperty #rendEnd LM.PropChange val )
		editText UI_rendPickupFrames "" pos:[18,112] width:235 height:19 text:LM.Layers[ LM.PropChange ].rendPickupFrames
		on UI_rendPickupFrames changed val do ( LM.ChangeLayerProperty #rendPickupFrames LM.PropChange val )

		groupBox grpf11 "Options" pos:[9,192] width:375 height:73 --222
		checkbox UI_rendColorCheck "Video Color Check" pos:[16,207] width:115 height:16 checked:LM.Layers[ LM.PropChange ].rendColorCheck 
		on UI_rendColorCheck changed state do ( LM.ChangeLayerProperty #rendColorCheck LM.PropChange state )
		checkbox UI_rendForce2Side "Force 2-Sided" pos:[16,225] width:123 height:16 checked:LM.Layers[ LM.PropChange ].rendForce2Side 
		on UI_rendForce2Side changed state do ( LM.ChangeLayerProperty #rendForce2Side LM.PropChange state )
		checkbox UI_rendAtmosphere "Atmospherics" pos:[16,243] width:123 height:16 checked:LM.Layers[ LM.PropChange ].rendAtmosphere 
		on UI_rendAtmosphere changed state do ( LM.ChangeLayerProperty #rendAtmosphere LM.PropChange state )
		checkbox UI_renderEffects "Effects" pos:[147,207] width:103 height:16 checked:LM.Layers[ LM.PropChange ].renderEffects 
		on UI_renderEffects changed state do ( LM.ChangeLayerProperty #renderEffects LM.PropChange state )
		checkbox UI_rendSuperBlack "Super Black" pos:[147,225] width:103 height:16 checked:LM.Layers[ LM.PropChange ].rendSuperBlack 
		on UI_rendSuperBlack changed state do ( LM.ChangeLayerProperty #rendSuperBlack LM.PropChange state )
		checkbox UI_renderDisplacements "Displacement" pos:[147,243] width:123 height:16 checked:LM.Layers[ LM.PropChange ].renderDisplacements 
		on UI_renderDisplacements changed state do ( LM.ChangeLayerProperty #renderDisplacements LM.PropChange state )
		checkbox UI_renderHidden "Render Hidden" pos:[266,207] width:109 height:16 checked:LM.Layers[ LM.PropChange ].renderHidden 
		on UI_renderHidden changed state do ( LM.ChangeLayerProperty #renderHidden LM.PropChange state )
		checkbox UI_rendFieldRender "Render to Fields" pos:[266,225] width:108 height:16 checked:LM.Layers[ LM.PropChange ].rendFieldRender 
		on UI_rendFieldRender changed state do ( LM.ChangeLayerProperty #rendFieldRender LM.PropChange state )
		
		groupBox grpf10 "Output Size" pos:[9,143] width:375 height:45
		spinner UI_renderWidth "Width:" pos:[45,165] width:70 height:16 range:[1,10000,LM.Layers[ LM.PropChange ].renderWidth ] type:#integer
		on UI_renderWidth changed val do ( LM.ChangeLayerProperty #renderWidth LM.PropChange val )
		spinner UI_renderHeight "Height:" pos:[155,165] width:70 height:16 range:[1,10000,LM.Layers[ LM.PropChange ].renderHeight ] type:#integer
		on UI_renderHeight changed val do ( LM.ChangeLayerProperty #renderHeight LM.PropChange val )
		spinner UI_renderPixelAspect "Pixel Aspect" pos:[280,165] width:70 height:16 range:[0.0001,1000,LM.Layers[ LM.PropChange ].renderPixelAspect ]
		on UI_renderPixelAspect changed val do ( LM.ChangeLayerProperty #renderPixelAspect LM.PropChange val )
	
		groupBox grpf12 "Render Output" pos:[8,274] width:375 height:44
		checkbox UI_rendSaveFile "Save File" pos:[16,292] width:68 height:16 checked:LM.Layers[ LM.PropChange ].rendSaveFile 
		editText UI_renderOutputFilename "" pos:[159,291] width:218 height:19 enabled:false text:LM.Layers[ LM.PropChange ].renderOutputFilename 
		on UI_rendSaveFile changed state do ( LM.ChangeLayerProperty #rendSaveFile LM.PropChange state )
		button UI_getOutputFile "Files.." pos:[92,290] width:67 height:19
		on UI_getOutputFile pressed do
		(
			local OutFile = getBitmapSaveFileName()
			if OutFile != undefined then 
			(
				UI_renderOutputFilename.text=OutFile
				UI_rendSaveFile.checked = true
				LM.Layers[ LM.PropChange ].rendSaveFile = true
				LM.Layers[ LM.PropChange ].renderOutputFilename  = OutFile
			)
		)
	
		groupBox grpf13 "Atmospherics" pos:[8,325] width:375 height:90
		checkbox UI_AtmosAryEnable "Enabled" pos:[16,345] width:68 height:16 checked:LM.Layers[ LM.PropChange ].rendEnableAtmosList
		on UI_AtmosAryEnable changed state do ( LM.ChangeLayerProperty #rendEnableAtmosList LM.PropChange state )		
		button UI_AddAllAtmos "Add All" width:45 pos:[80,340] height:20 enabled:false
		button UI_DelAllAtmos "Del All" width:45 pos:[125,340] height:20 enabled:false
		button UI_DelAtmos "Del" width:45 pos:[170,340] height:20 
		listBox UI_AtmosAry "" pos:[218,340] width:160 height:5		
		dropdownlist UI_AtmosList width:150 pos:[16,380] 
		button UI_AddAtmos "Add >>" width:45 pos:[170,380] height:20
		on UI_DelAtmos pressed do
		(
			if UI_AtmosList.selection > 0 then deleteitem LM.Layers[LM.PropChange].renderAtmosphericsArray UI_AtmosList.selection
			local atmosList = #()
			for a in LM.Layers[LM.PropChange].renderAtmosphericsArray do append atmosList a.name
			UI_AtmosAry.items = atmosList
			UI_AtmosAry.selection = 1
		)
		on UI_AddAtmos pressed do
		(
			local atmosList = #()
			if UI_AtmosList.selection > 0 then 
			(
				--check to see if it exist already
				if finditem LM.Layers[LM.PropChange].renderAtmosphericsArray (getatmospheric UI_AtmosList.selection) == 0 then
					append LM.Layers[LM.PropChange].renderAtmosphericsArray (getatmospheric UI_AtmosList.selection)
			)
			for a in LM.Layers[LM.PropChange].renderAtmosphericsArray do append atmosList a.name
			UI_AtmosAry.items = atmosList	
		)

		groupBox grpf14 "Effects" pos:[8,422] width:375 height:90
		checkbox UI_EffectAryEnable "Enabled" pos:[16,442] width:68 height:16
		on UI_EffectAryEnable changed state do ( LM.ChangeLayerProperty #rendEnableEffectList LM.PropChange state )	
		button UI_AddAllEffect "Add All" width:45 pos:[80,437] height:20 enabled:false
		button UI_DelAllEffect "Del All" width:45 pos:[125,437] height:20 enabled:false
		button UI_DelEffect "Del" width:45 pos:[170,437] height:20
		listBox UI_EffectAry "" pos:[218,437] width:160 height:5		
		dropdownlist UI_EffectList width:150 pos:[16,477] 
		button UI_AddEffect "Add >>" width:45 pos:[170,477] height:20 

		on UI_DelEffect pressed do
		(
			if UI_EffectList.selection > 0 then deleteitem LM.Layers[LM.PropChange].renderEffectsArray UI_EffectAry.selection
			local effectList = #()
			for a in LM.Layers[LM.PropChange].renderEffectsArray do append effectList a.name
			UI_EffectAry.items = effectList 
			UI_EffectAry.selection = 1
		)
		on UI_AddEffect pressed do
		(
			local effectList = #()
			if UI_EffectList.selection > 0 then 
			(
				--check to see if it exist already
				if finditem LM.Layers[LM.PropChange].renderEffectsArray (geteffect UI_EffectList.selection) == 0 then
					append LM.Layers[LM.PropChange].renderEffectsArray (geteffect UI_EffectList.selection)
			)
			for a in LM.Layers[LM.PropChange].renderEffectsArray do append effectList a.name
			UI_EffectAry.items = effectList	
		)


		button UI_PropDone "OK" pos:[306,515] width:79 height:26
		on UI_PropDone pressed do destroyDialog Prop_Tab2_Roll 
		
		on Prop_Tab2_Roll moved loc do LM.PropertyFloaterPosition = [loc.x-3,loc.y-22]
		on Prop_Tab2_Roll open do
		(
			--gather atmospherics
			local AtmosNameAry =#()
			for i = 1 to numatmospherics do
			(
				local a=getatmospheric i
				append AtmosNameAry a.name
			)
			UI_AtmosList.items = AtmosNameAry		
			local atmosList = #()
			for a in LM.Layers[LM.PropChange].renderAtmosphericsArray do append atmosList a.name
			UI_AtmosAry.items = atmosList
			--gather effects
			local EffectNameAry =#()
			for i = 1 to numeffects do
			(
				local e=geteffect i
				append EffectNameAry e.name
			)
			UI_EffectList .items = EffectNameAry 		
			local effectList = #()
			for a in LM.Layers[LM.PropChange].renderEffectsArray do append effectList a.name
			UI_EffectAry.items = effectList 
		)
		
	)
	
	
--OBJECTS ROLLOUT
	Rollout Prop_Tab3_Roll "Layer Properties" width:398 height:550
	(
		local drag_obj , drop_obj
		checkbutton UI_Tab1 "General" width:65 height:25 pos:[4,4]  highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab2 "Rendering" width:75 height:25 pos:[69,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab3 "Objects" width:70 height:25 pos:[144,4] highlightcolor:UI_PropDialogCheckColor checked:true
		checkbutton UI_Tab4 "Alternate Material" width:105 height:25 pos:[214,4] highlightcolor:UI_PropDialogCheckColor 
		checkbutton UI_Tab5 "Other" width:70 height:25 pos:[319,4] highlightcolor:UI_PropDialogCheckColor

		on UI_Tab1 changed state do
		(
			destroyDialog Prop_Tab3_Roll 
			createdialog Prop_Tab1_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)
		on UI_Tab2 changed state do
		(
			destroyDialog Prop_Tab3_Roll 
			createdialog Prop_Tab2_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)
		on UI_Tab4 changed state do
		(
			destroyDialog Prop_Tab3_Roll 
			createdialog Prop_Tab4_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				 style:#(#style_minimizebox, #style_titlebar,#style_sysmenu)
		)


		activeXControl tvObjects "{C74190B6-8589-11D1-B16A-00C0F0283628}" height:450 width:375 align:#left pos:[9,50] setupEvents:true
		button UI_PropDone "OK" pos:[306,515] width:79 height:26
		on UI_PropDone pressed do destroyDialog Prop_Tab3_Roll 
		
		fn initTreeView tv =
		(
			tv.labelEdit = #tvwAutomatic
			tv.lineStyle = #tvwRootLines
			tv.style = #tvwTreelinesPlusMinusText
			tv.indentation = 0
			tv.pathseparator = "."
			tv.hotTracking = true
			tv.hideSelection = false
			tv.oleDragMode = #ccOLEDragAutomatic
			tv.OLEDropMode = #ccOLEDropManual
		)
	
		fn addLayerObjects tv_nodes Objs parent=
		(
			for o in Objs do
				tvn = tv_nodes.add parent.index 4 "" o.name
		)
		
		fn addLayersToTreeView tv_nodes LM  =
		(
			for L = 1 to LM.layers.count do
			(
				tvn = tv_nodes.add()
				tvn.text = LM.Layers[L].LayerName
				if L == LM.PropChange then tvn.expanded = true
				local objs = LM.getlayerobjects L
				for o in objs do
					stvn = tv_nodes.add tvn.index 4 "" o.name
			)
		)
		fn getHitNode ctrl = 
		(
			local p = getCursorPos ctrl
			--ctrl.HitTest ((p.x-2)*btnCalib.value) ((p.y-2)*btnCalib.value)
			return (ctrl.HitTest ((p.x-2)*15) ((p.y-2)*15))
		)
		on Prop_Tab3_Roll open do
		(
			initTreeView tvObjects
			addLayersToTreeView tvObjects.nodes LM
		)
		
		on tvObjects nodeClick arg do
		(
			global obj=execute ("$'"+tvObjects.selectedItem.text+"'")
			if obj != undefined then 
			(
				if keyboard.shiftPressed == true then selectmore obj
				else select obj
			)
		)
		--Drag and Drop -- experimental.
		on tvObjects OLEStartDrag DataObject Effects do
		(
			--drag has begun
			drag_obj = undefined
			drop_obj = undefined
				
			local drag_node = getHitNode tvObjects
			if drag_node != undefined then drag_obj = getnodebyname drag_node.text
			
			--add
			--ax.nodes.remove 5 --remove 5th index 
		)
		on tvObjects OLEDragDrop DataObject Effect btn key x y do
		(
			drop_node = getHitNode tvObjects
			if drop_node != undefined then drop_obj = getnodebyname drop_node.text

			if drop_obj != undefined and drag_obj != undefined then
			(
				--get the index of the drop object
				local drop_Lay_id = getappdata drop_obj 9901
				if drop_Lay_id == undefined then LM.AddObjectsToLayer 1 #(drag_obj)
				else --destination not world layer
				(
					--need to put in some sort of group filter here
					local ID_ary = for L in LM.Layers collect L.ID
					local drop_ind = finditem id_ary (drop_lay_id as integer)
					if drop_ind > 0 then LM.AddObjectsToLayer drop_ind #(drag_obj)
				)
			)
		)
		on Prop_Tab3_Roll moved loc do LM.PropertyFloaterPosition = [loc.x-3,loc.y-22]

	)
	
	Rollout Prop_Tab4_Roll "Layer Properties" width:398 height:550
	(
		checkbutton UI_Tab1 "General" width:65 height:25 pos:[4,4]  highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab2 "Rendering" width:75 height:25 pos:[69,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab3 "Objects" width:70 height:25 pos:[144,4] highlightcolor:UI_PropDialogCheckColor
		checkbutton UI_Tab4 "Alternate Material" width:105 height:25 pos:[214,4] highlightcolor:UI_PropDialogCheckColor checked:true
		checkbutton UI_Tab5 "Other" width:70 height:25 pos:[319,4] highlightcolor:UI_PropDialogCheckColor
		
		on UI_Tab1 changed state do
		(
			destroyDialog Prop_Tab4_Roll 
			createdialog Prop_Tab1_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)
		)
		on UI_Tab2 changed state do
		(
			destroyDialog Prop_Tab4_Roll 
			createdialog Prop_Tab2_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_minimizebox, #style_titlebar,#style_sysmenu) 
		)
		on UI_Tab3 changed state do
		(
			destroyDialog Prop_Tab4_Roll 
			createdialog Prop_Tab3_Roll 398 550 LM.PropertyFloaterPosition.x LM.PropertyFloaterPosition.y \
				style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)
		)
	
		dropdownlist UI_AltMatType "" pos:[7,45] width:200 height:16 enabled:true items:#("Matte / Shadow", "Material Editor Slot  ", "Solid Color") selection:LM.Layers[LM.PropChange].alt_MatType 
		groupBox UI_mattegroup "Matte/Shadow Parameters" pos:[8,73] width:375 height:246 enabled:false 
		checkbox UI_opaqueAlpha  "Opaque Alpha" pos:[29,95] width:115 height:16 enabled:false checked:LM.Layers[LM.PropChange].Alt_opaqueAlpha
		on UI_opaqueAlpha  changed state do (LM.ChangeLayerProperty #Alt_opaqueAlpha LM.PropChange state )
		checkbox UI_applyAtmosphere "Apply Atmosphere" pos:[104,135] width:123 height:16 enabled:false checked:LM.Layers[LM.PropChange].alt_applyAtmosphere 
		on UI_applyAtmosphere changed state do (LM.ChangeLayerProperty #alt_applyAtmosphere LM.PropChange state )
		checkbox UI_affectAlpha  "Affect Alpha" pos:[243,183] width:123 height:16 enabled:false checked:LM.Layers[LM.PropChange].alt_affectAlpha  
		on UI_affectAlpha  changed state do (LM.ChangeLayerProperty #alt_affectAlpha  LM.PropChange state )
		checkbox UI_receiveShadows  "Receive Shadows" pos:[32,182] width:123 height:16 enabled:false checked:LM.Layers[LM.PropChange].Alt_receiveShadows  
		on UI_receiveShadows  changed state do (LM.ChangeLayerProperty #alt_receiveShadows  LM.PropChange state )
		groupBox UI_atmos_grp "Atmosphere" pos:[14,116] width:363 height:46 enabled:false
		radioButtons UI_atmosphereDepth  "" pos:[243,127] width:126 height:32  labels:#("At Background Depth", "At Object Depth") columns:1 enabled:false default:LM.Layers[ LM.PropChange ].alt_atmosphereDepth  
		on UI_atmosphereDepth  changed state do (LM.ChangeLayerProperty #alt_atmosphereDepth  LM.PropChange state )
		groupBox UI_shadgrp "Shadow" pos:[14,164] width:363 height:68 enabled:false
		spinner UI_shadowBrightness  "Shadow Brightness:" pos:[100,205] width:80 height:16 enabled:false range:[0,1.0,LM.Layers[LM.PropChange].alt_shadowBrightness  ]
		on UI_shadowBrightness changed val do (LM.ChangeLayerProperty #alt_shadowBrightness LM.PropChange val )
		colorPicker UI_color  "Color:" pos:[241,205] width:93 height:19 enabled:false color:LM.Layers[LM.PropChange].alt_color
		on UI_color changed col do (LM.ChangeLayerProperty #alt_color LM.PropChange col )
		spinner UI_amount  "Amount:" pos:[75,255] width:80 height:16 range:[0,100,LM.Layers[LM.PropChange].alt_amount  ] enabled:false
		on UI_amount  changed val do (LM.ChangeLayerProperty #alt_amount  LM.PropChange val )
		groupBox grp19 "Reflection" pos:[14,234] width:363 height:68 enabled:false
		--checkbox UI_useRefMap  "" pos:[346,279] width:24 height:16 enabled:false checked:LM.Layers[LM.PropChange].alt_useRefMap
		--on UI_useRefMap  changed state do ( LM.ChangeLayerProperty #alt_useRefMap  LM.PropChange state )
		--mapButton UI_map  "None" pos:[64,277] width:268 height:18 enabled:false
		--label UI_Maplbl "Map:" pos:[31,278] width:26 height:16 enabled:false
		
		groupBox UI_meditgrp "Material Editor Parameters" pos:[8,350] width:375 height:50 enabled:false
		spinner UI_meditSlot  "Slot Number:" pos:[185,370] width:80 height:16 range:[1,24,LM.Layers[LM.PropChange].alt_meditSlot  ] type:#integer enabled:false
		on UI_meditSlot  changed val do (LM.ChangeLayerProperty #alt_meditSlot  LM.PropChange val )

		groupBox UI_SolidGrp "Solid Color Parameters" pos:[8,440] width:375 height:50 enabled:false
		colorPicker UI_solidColor "Color:" pos:[106,464] width:93 height:19 enabled:false color:LM.Layers[LM.PropChange].alt_solidColor 
		on UI_solidColor changed col do (LM.ChangeLayerProperty #alt_solidColor LM.PropChange col )
		
		spinner UI_selfillum "Self Illumination:" pos:[285,464] width:80 height:16 range:[1,100,LM.Layers[LM.PropChange].alt_selfillum ] type:#integer enabled:false
		on UI_selfillum changed val do (LM.ChangeLayerProperty #alt_selfillum LM.PropChange val )

		
		button UI_PropDone "OK" pos:[306,515] width:79 height:26
		on UI_PropDone pressed do destroyDialog Prop_Tab4_Roll 
		
		on Prop_Tab4_Roll moved loc do LM.PropertyFloaterPosition = [loc.x-3,loc.y-22]
		
		Function Update_AltMat_Rollout num=
		(
			UI_mattegroup.enabled = false
			UI_opaqueAlpha.enabled = false
			UI_applyAtmosphere.enabled = false
			UI_affectAlpha.enabled = false
			UI_receiveShadows.enabled = false
			UI_atmos_grp.enabled = false
			UI_atmosphereDepth.enabled = false
			UI_shadgrp.enabled = false
			UI_shadowBrightness.enabled = false
			UI_color.enabled = false
			UI_amount.enabled = false
		--	UI_map.enabled = false
		--	UI_useRefMap.enabled = false
		--	UI_Maplbl.enabled = false
			UI_selfillum.enabled = false
			
			UI_meditSlot.enabled = false
			UI_meditgrp.enabled = false
			
			UI_solidColor.enabled = false
			UI_SolidGrp.enabled = false
			
			case num of
			(
				1:(
					UI_mattegroup.enabled = true
					UI_opaqueAlpha.enabled = true
					UI_applyAtmosphere.enabled = true
					UI_affectAlpha.enabled = true
					UI_receiveShadows.enabled = true
					UI_atmos_grp.enabled = true
					UI_atmosphereDepth.enabled = true
					UI_shadgrp.enabled = true
					UI_shadowBrightness.enabled = true
					UI_color.enabled = true
					UI_amount.enabled = true
				--	UI_map.enabled = true
				--	UI_useRefMap.enabled = true
				--	UI_Maplbl.enabled = true
					
				)
				2: (
					UI_meditSlot.enabled = true
					UI_meditgrp.enabled = true
				)
				3:(
					UI_solidColor.enabled = true
					UI_SolidGrp.enabled = true
					UI_selfillum.enabled = true
				)
			)
		)
		on Prop_Tab4_Roll open do Update_AltMat_Rollout UI_AltMatType.selection

		on UI_AltMatType selected type do
		(
			LM.ChangeLayerProperty #Alt_MatType LM.PropChange type
			Update_AltMat_Rollout type
		)

	)
	
	
	Rollout LM_NewLayerRoll "New Layer"
	(
		edittext NewLayname "Name:" align:#left  --width:250
		radiobuttons add_type labels:#("add to bottom", "add to top", "add under active")
		button okay "OK" align:#right --pos:[220,40]
		on okay pressed do 
		(
			--put new layer name onlayer
			if NewLayName.text != "" then LM.Layers[LM.Layers.count].LayerName=NewLayName.text

			DestroyDialog LM_NewLayerRoll 
			--reorder layers based on radio selection
			case add_type.state of
			(
				2: (--add to top
					LM.MoveLayer LM.Layers.count 2
				)
				3: (--add under active
					LM.MoveLayer LM.Layers.count (LM.ActiveLayer+1)
				)
			)
			LM.UI.UpdateRollout()
		)
		on LM_NewLayerRoll open do NewLayname.text = LM.Layers[LM.Layers.count].LayerName
	)
	RCMenu LM_Group_ExpandedMenu
	(
		MenuItem  miSelectLay "Select Layer" 
		on miSelectLay picked do 
		(
			DisableSceneRedraw()
			if keyboard.shiftpressed == true then selectmore (LM.GetLayerObjects LM.PropChange )
			else select (LM.GetLayerObjects LM.PropChange)
			EnableSceneRedraw()
		)
	
		Seperator sep1
		MenuItem  miDeleteGrp "Delete Group and Sub Layers" 
		on miDeleteGrp picked do 
		(
			LM.DeleteLayer LM.PropChange DelSub:true
			destroyDialog LM_Roll
			LM.UI.MakeRollout()
		)
		MenuItem  miDeleteGrpObj "Delete Group, Sub Layers and Objects" 
		on miDeleteGrpObj picked do 
		(
			DisableSceneRedraw()
			LM.DeleteLayer LM.PropChange DelSub:true DelObjs:true
			EnableSceneRedraw()
			redrawviews()
			destroyDialog LM_Roll
			LM.UI.MakeRollout()
		)
		MenuItem  miDeleteJustGroup "Delete Just Group - Leave Layers" 
		on miDeleteJustGroup picked do 
		(
			LM.DeleteLayer LM.PropChange
			destroyDialog LM_Roll
			LM.UI.MakeRollout()
		)
		Seperator sep2
		MenuItem  miRend "Set Render Setting"
		on miRend picked do LM.SetRenderSettings LM.PropChange
	)
	RCMenu LM_World_ExpandedMenu
	(
		MenuItem miAddSel "Add Selected to Layer"
		on miAddSel picked do LM.AddObjectsToLayer LM.PropChange ($Selection as array)
		MenuItem  miSelectLay "Select Layer" 
		on miSelectLay picked do 
		(
			DisableSceneRedraw()
			if keyboard.shiftpressed == true then selectmore (LM.GetLayerObjects LM.PropChange )
			else select (LM.GetLayerObjects LM.PropChange)
			EnableSceneRedraw()
		)
		Seperator sep1
		MenuItem  miRend "Set Render Setting"
		on miRend picked do LM.SetRenderSettings LM.PropChange
		
	)
	
	RCMenu LM_ExpandedMenu
	(
		SubMenu "Options"
		(
			MenuItem miAutoAssign "Auto Assignment" 
			MenuItem miMinUi "Minimized UI" enabled:false
			MenuItem miXRefUi "XRef Scenes As Layers" 
		)
		SubMenu "Visibility / Selection"
		(
			MenuItem miHideAll "Hide All Layers" 
			MenuItem miUnHideAll "Unhide All Layers" 
			MenuItem miInvert "Invert Hide/Unhide"
			Seperator sep01
			MenuItem miFreezeAll "Freeze All Layers" 
			MenuItem miUnFrezzeAll "Thaw All Layers" 
			MenuItem miInvertFreeze "Invert Freeze/Thaw"
		)
		SubMenu "Manage Layers"
		(
			MenuItem miGatherMerge "Gather Merged Data"
			MenuItem miGatherObjects "Gather Objects"
			--MenuItem miMergeLayers "Merge Layers from File"
			Seperator sep02
			MenuItem miRemoveEmpty "Remove Empty Layers"
			MenuItem miAlphabetize "Alphebetize Layers"
			MenuItem miGenNewLayId "Generate New Layer ID's"
			Seperator sep03
			MenuItem miAquireSelSet "Aquire Selection Sets"
			MenuItem miCreateSelSet "Create Selection Sets"

			--MenuItem miImportOldData "Import Old LM_Data"
		)
		Seperator sep_fin
		MenuItem miDestroyData "Destroy Layer Manger Data"
		on miDestroyData picked do
		(
			LM.KillData()
			destroydialog LM_Roll
			/*
			local LID = LM.ID
			LM = undefined
			execute (LID + " = undefined")
			deleteappdata globaltracks[1] 9901
			deleteAllChangeHandlers id:#LM_Handle
			*/
		)
		MenuItem miabout "About"
		on miabout picked do createdialog LM_AboutRoll
		
		on LM_ExpandedMenu open do 
		(
			miAutoAssign.checked = LM.autoassign
			miXRefUi.checked = LM.xrefLayers
		)
		on miAutoAssign picked do LM.UI.SetAutoAssign (not (LM.autoassign))
		on miXRefUi picked do (
			LM.xrefLayers = ( not (miXRefUI.checked) )
			LM.UI.MakeRollout()
		)
		on miHideAll picked do
		(
			for L = 1 to LM.Layers.count where LM.Layers[L].isgroupMember == false do LM.HideLayer L false
			LM.UI.UpdateRollout()
		)
		on miUnHideAll picked do
		(
			for L = 1 to LM.Layers.count where LM.Layers[L].isgroupMember == false do LM.HideLayer L true
			LM.UI.UpdateRollout()
		)
		on miInvert picked do
		(
			for L = 1 to LM.Layers.count where LM.Layers[L].isgroupMember == false do LM.HideLayer L LM.Layers[L].ishidden
			LM.UI.UpdateRollout()
		)
		on miFreezeAll picked do
		(
			for L = 1 to LM.Layers.count where LM.Layers[L].isgroupMember == false do LM.FreezeLayer L true
			LM.UI.UpdateRollout()
		)
		on miUnFrezzeAll picked do
		(
			for L = 1 to LM.Layers.count where LM.Layers[L].isgroupMember == false do LM.FreezeLayer L false
			LM.UI.UpdateRollout()
		)
		on miInvertFreeze picked do
		(
			for L = 1 to LM.Layers.count where LM.Layers[L].isgroupMember == false do LM.FreezeLayer L (not LM.Layers[L].isfrozen)
			LM.UI.UpdateRollout()
		)
		on miGatherMerge picked do
		(
			SetWaitCursor()
			local GlobNameAry = LM.GetLMGlobals()
			local importLayers = #()
			--create 2 arrays for objects import
			local object_handle_array = #()
			local object_layer_id = #()
			local object_string_id = #()
			
			for o in objects do
			(
				append object_handle_array o.inode.handle
				append object_layer_id ((getappdata o 9901)as integer) --could be undefined!
				append object_string_id (getappdata o 9900)
			)
			print "a"
			--check to see that it's not the current one
			for I in GlobNameAry where I != LM.ID do
			(
				local tempLayerInfo = execute I
				if tempLayerInfo.Layers.count > 0 then
				(
					for TL in tempLayerInfo.Layers do
					(
						local found = 0
						for L in LM.Layers where L.id == TL.id do found = 1
						--append it if it's not found in the current layers
						if found == 0 then append importLayers TL
					)
				)
				execute (I + "=undefined")
			)
			print "b"
			--delete all the existing object arrays on current layers
			for L in LM.Layers do
			(
				L.ObjectHandleArray = #()
				L.ObjectStringIDArray = #()
			)
			print "c"
			--go through each object, checking to see if it's on an exisiting layer
			local existingLayerIds = for L in LM.Layers collect L.ID
			local newLayerIds = for L in importLayers collect L.ID
			--or if a new layer needs to be added.
			for n = 1 to object_layer_id.count do
			(
				print "d"
				local Exists = ( finditem existingLayerIds object_layer_id[n] )
				if  Exists > 0 then --object should exists on a current layers
				(
					append LM.Layers[Exists].ObjectHandleArray object_handle_array[n]
					append LM.Layers[Exists].ObjectStringIDArray object_string_id[n]
					print "e"
				)
				else
				(
					--check and see if the layer id exists anywhere in the imported layers
					local ExistsOnMergeLayer = ( finditem newLayerIds object_layer_id[n] )
					if ExistsOnMergeLayer > 0 then
					(
						--make a new layer
						append LM.Layers importLayers[ExistsOnMergeLayer]
						--remove layer from newlayerIds and add to exisitinglayer ids
						deleteitem newLayerIds ExistsOnMergeLayer
						append existingLayerIds object_layer_id[n]
						
						--delete the layer fromimported layers
						deleteitem importlayers ExistsOnMergeLayer	
						
						--blank out new layer object arrays.
						LM.Layers[ LM.Layers.count ].ObjectHandleArray = #()
						LM.Layers[ LM.Layers.count ].ObjectStringIDArray = #()
						--add object to the new layer
						append LM.Layers[ LM.Layers.count ].ObjectHandleArray object_handle_array[n]
						append LM.Layers[ LM.Layers.count ].ObjectStringIDArray object_string_id[n]											
					)		
				)		
			)
			SetArrowCursor()
			LM.UI.MakeRollout()
		)
		on miGatherObjects picked do
		(
			disablesceneredraw()
			--go through each object and check it's data
			--if the data id # isn't found in LM then create layer
			local Lay_Ids = for L in LM.Layers collect L.ID
			for o in objects do
			(
				local LayIndexString = getappdata o 9901
		--		local LayIndex = (getappdata o 9901) as integer
				if LayIndexString != undefined then
				(
					local LayIndex = LayIndexString as integer
					local findme = ( finditem Lay_Ids LayIndex  )
					if findme == 0 then --no layer for it..awwwww
					(
						--make new layer from obj
						LM.AddNewLayer()
						-- set that layer to that index
						LM.Layers[ LM.Layers.count ].ID = LayIndex
						LM.AddObjectsToLayer LM.Layers.count (#(o))
						append Lay_Ids LayIndex
					)
					else
					(
						--if it does have a layer, make sure it's on that layer.
						local nodeid = o.inode.handle
						if (finditem LM.Layers[ findme ].ObjectHandleArray nodeid) == 0 then
						(
							--remove the data and start fresh
							deleteappdata o 9901
							deleteappdata o 9900
							LM.AddObjectsToLayer findme (#(o))			
						)
					)
				)
			)
			enablesceneredraw()
			destroyDialog LM_Roll
			LM.UI.MakeRollout()
		)

		on miGenNewLayId picked do
		(
			SetWaitCursor()
			Local NewInd = #()
			Local CurrentInd = for L in LM.Layers collect L.id
			for L = 1 to CurrentInd.count do append NewInd (LM.GenerateLayerId())
			--scan objects and update
			for o in objects do
			(
				local ID = getappdata o 9901
				if ID != undefined then
				(
					local foo = (finditem CurrentInd (ID as integer))
					setappdata o 9901 ( NewInd[foo] as string )
				)
			)
			--swap the id's in Layer Data
			for L = 1 to LM.Layers.count do
			(
				LM.Layers[L].ID = NewInd[L]
				if LM.Layers[L].isGroupMember == true then
					LM.Layers[L].groupHeadId = NewInd[(finditem CurrentInd LM.Layers[L].groupHeadId)]
			)
			
			SetArrowCursor()
		)
		on miRemoveEmpty picked do
		(
			if LM.Layers.count > 1 then 
			(
				for L = LM.Layers.count to 2 by -1 do
				(
					local objs = LM.GetLayerObjects L
					if objs.count == 0 then deleteitem LM.Layers L
				)
				LM.UI.MakeRollout()
			)
		)
		on miAlphabetize picked do
		(
			if LM.Layers.count > 1 then 
			(
				local NewLayerArray =#()
				NewLayerArray[1] = copy LM.Layers[1]
				local LayNames = #()
				local unsorted_LayNames = for L in LM.Layers collect L.LayerName
				for L = 2 to LM.Layers.count where LM.Layers[L].isgroupMember == false do append LayNames LM.Layers[L].LayerName
				sort LayNames
				local num = 2
				for L = 1 to LayNames.count do
				(
					--find the layer it corresponds with
					Ind = finditem unsorted_LayNames LayNames[L]
					if LM.Layers[Ind].isgroupHead == true then
					(
						append NewLayerArray (copy LM.Layers[Ind])
						local add = 1
						local sub = 1
						while sub == 1 and (Ind+add) < LM.Layers.count do
						(
							if LM.Layers[Ind+add].isGroupMember == false then 
							(
								sub = 0
								continue
							)
							append NewLayerArray LM.Layers[Ind+add]
							add += 1
						)
					)
					else append NewLayerArray  ( copy LM.Layers[Ind] )
					num +=1
				)
				LM.Layers = NewLayerArray
				LM.UI.MakeRollout()
			)
		)
		on miAquireSelSet picked do
		(
			disablesceneredraw()
			for S = 1 to SelectionSets.count do
			(
				--make a new layer
				LM.AddNewLayer()
				--name the layer
				LM.Layers[LM.Layers.count].LayerName = getNamedSelSetName S
				--add the objects
				local temp = for i in selectionsets[S] collect i
				LM.AddObjectsToLayer LM.Layers.count temp
				
			)
			enablesceneredraw()
			LM.UI.MakeRollout()
		)
		on miCreateSelSet picked do
		(
			for L = 1 to LM.Layers.count where LM.Layers[L].isgroupHead == false do
			(
				local temp = LM.GetLayerObjects L
				if temp.count > 0 then selectionsets
				selectionsets[LM.Layers[L].LayerName] = temp
			)
		
		)
	)
	
	Struct LM_UI
	(
		Function MakeLayerRCMenu =
		(	
			Local GroupNames=#()
			Local GroupIDs=#()
			--get the group names and the index numbers
			for L = 1 to LM.Layers.count do
			(
				if LM.Layers[L].isGroupHead == true then
				(
					append GroupNames LM.Layers[L].LayerName
					append GroupIDs L
				)
			)

			rci = RCMenuCreator "LayControlMenuExpand" 
			rci.begin()
			rci.addMenuItem #miAddSel "Add Selected to Layer"
			rci.addHandler #miAddSel #picked codestr:"LM.AddObjectsToLayer LM.PropChange ($Selection as array)"
			rci.addMenuItem #miSelectLay "Select Layer" 
			rci.addHandler #miSelectLay #picked codeStr:" DisableSceneRedraw()
				if keyboard.shiftpressed == true then selectmore (LM.GetLayerObjects LM.PropChange )
				else select (LM.GetLayerObjects LM.PropChange)
				EnableSceneRedraw() "
			
			rci.addMenuItem #miSelect "Select Objects on Layer"	
			rci.addHandler #miSelect #picked codeStr:" 	fn SF obj  = (GetAppData Obj 9901 == (LM.layers[ LM.PropChange].ID ) as string)
				local MyAry=selectByName title:\" Select Objects\" buttonText:\"Select\" filter:SF 
				If MyAry != undefined then Select MyAry"

			rci.addSeperator #sep1
			rci.addMenuItem #miDelLay "Delete Layer"
			rci.addHandler #miDelLay #picked codeStr:"deleteitem LM.Layers LM.PropChange; destroyDialog LM_Roll;LM.UI.MakeRollout()"
			rci.addMenuItem #miDelLaywObj "Delete Layer and Objects"
			rci.addHandler #miDelLaywObj #picked codeStr:"DeleteAns= querybox (\"This will DELETE all objects on this layer.
Are you sure?\") title:\"Confirm Delete Objects\"
				if deleteAns == true then
				(
					delete (LM.GetLayerObjects LM.PropChange)
					deleteitem LM.Layers LM.PropChange
					destroyDialog LM_Roll
					LM.UI.MakeRollout()
				)"

			rci.addSeperator #sep2
			rci.beginSubMenu "Layer Groups"
			local doit =#(false, false, false)
			if LM.Layers[LM.PropChange].isGroupHead == false then
				rci.addMenuItem #miNewGroup "Make New Group"
			else
				rci.addMenuItem #miDelGroup "Delete Group"
				
			if LM.Layers[LM.PropChange].isGroupMember == true then
				rci.addMenuItem #miRemove "Remove From Group"
			
			rci.addSeperator #subgroupsep1
			if LM.Layers[LM.PropChange].isGroupHead == false then
				for L = 1 to GroupNames.count do rci.addMenuItem (("miGrp"+L as string)as name)  (GroupNames[L] as name)	
			rci.endSubMenu()
			
		--do handelers outside of group menu
			if LM.Layers[LM.PropChange].isGroupHead != true then
			(

				rci.addHandler #miNewGroup #picked codeStr:"insertItem (copy LM.Layers[LM.PropChange]) LM.Layers LM.PropChange
					LM.Layers[LM.PropChange].isGroupHead = true
					LM.Layers[LM.PropChange].isGroupMember = false
					LM.Layers[LM.PropChange].groupHeadId = 0
					LM.Layers[LM.PropChange].LayerName = \"Group\" 
					LM.Layers[LM.PropChange].ObjectHandleArray = #()
					LM.Layers[LM.PropChange].ObjectStringIDArray = #()
					LM.Layers[LM.PropChange].ID = LM.GenerateLayerId()
					LM.Layers[LM.PropChange+1].isGroupMember = true
					LM.Layers[LM.PropChange+1].GroupHeadId = LM.Layers[LM.PropChange].ID
					LM.UI.MakeRollout()
					"
			)
			if LM.Layers[LM.PropChange].isGroupHead == false then
			(
				for L = 1 to GroupNames.count do 
				(
					rci.addHandler (("miGrp"+L as string)as name) #picked codeStr:("LM.Layers[LM.PropChange].isGroupMember = true
						LM.Layers[LM.PropChange].GroupHeadId = LM.Layers["+GroupIDs[L] as string+"].ID
						LM.MoveLayer LM.PropChange " + (GroupIDs[L] + 1) as string +"
						LM.UI.MakeRollout()")
				)
			)
			if LM.Layers[LM.PropChange].isGroupMember == true then
			(
				rci.addHandler #miRemove #picked codeStr:("
					LM.TempData_1 = finditem (for L in LM.Layers collect L.ID) LM.Layers[LM.PropChange].groupHeadId
					LM.Layers[LM.PropChange].isgroupMember= false
					LM.Layers[LM.PropChange].groupHeadId = 0
					LM.MoveLayer LM.PropChange (LM.TempData_1)
					LM.UI.MakeRollout()
				")
			)
			rci.addSeperator #sep5
			rci.addMenuItem #miRend "Set Render Setting" 
			--need to have method to close render dialog box
			rci.addHandler #miRend #picked codeStr:("LM.SetRenderSettings LM.PropChange")
			rci.end()
		),
		Function MakeRollout =
		(
			--define the bitmaps to make it faster
			if (LM_Roll != undefined) then destroyDialog LM_Roll
			--this function uses the RolloutCreator.ms			
			local YPos = 38
			rci = rolloutCreator "LM_Roll" "Layer Manager"
			rci.begin()
		--Layer Opertations
			--NEW LAYER
			rci.addControl #button #Create_New_Layer "" paramStr:(" height:26 width:54 pos:[19,5] ToolTip:\"Create New Layer\" "+
				" images:#(UI_BMP_ButtonsI, UI_BMP_ButtonsM,3,1,1,1,1) ")
			rci.addHandler #Create_New_Layer #pressed CodeStr:"LM.AddNewLayer();destroyDialog LM_Roll;LM.UI.MakeRollout()"
			
			--NEW LAYER FROM SELECTED
			rci.addControl #button #Create_New_Layer_From_Sel "" paramStr:(" height:26 width:74 pos:[73,5] ToolTip:\"Create New " +
				"Layer From Selected Objects\" images:#(UI_BMP_ButtonsI, UI_BMP_ButtonsM,3,2,2,2,2) ")
			rci.addHandler #Create_New_Layer_From_Sel #pressed CodeStr:"LM.AddNewLayer()
				LM.AddObjectsToLayer LM.Layers.count ($Selection as array)
				destroyDialog LM_Roll
				LM.UI.MakeRollout()
				CreateDialog LM_NewLayerRoll modal:true
				max Select none
				"
			--MOVE LAY UP
			rci.addControl #button #MoveLayUp "" paramStr:(" height:13 width:17 pos:[2,5] ToolTip:\"Move Layer Up\" "+
				"images:#(UI_BMP_ControlsI, UI_BMP_ControlsM, 10,7,7,7,7) ")
			rci.addHandler #MoveLayUp #pressed CodeStr:"if LM.ActiveLayer > 1 then LM.MoveLayer LM.ActiveLayer (LM.ActiveLayer-1)
				LM.UI.MakeRollout()"
			--MOVE LAY DOWN
			rci.addControl #button #MoveLayDown "" paramStr:(" height:13 width:17 pos:[2,18] ToolTip:\"Move Layer Down\" "+
				"images:#(UI_BMP_ControlsI, UI_BMP_ControlsM, 10,8,8,8,8) ")
			rci.addHandler #MoveLayDown #pressed CodeStr:"if LM.ActiveLayer < LM.Layers.count then LM.MoveLayer LM.ActiveLayer (LM.ActiveLayer+1)
				LM.UI.MakeRollout()"
				
			--EXTENDED MENU
			rci.addControl #button #A_Help "" paramStr:(" height:26 width:43 pos:[147,5] ToolTip:\"Expanded Menu\" "+
				"images:#(UI_BMP_ButtonsI, UI_BMP_ButtonsM,3,3,3,3,3) ")
			rci.addHandler #A_Help #pressed codeStr:"PopupMenu LM_ExpandedMenu rollout:LM_Roll
				LM.UI.UpdateRollout()"

			local XIndent = 0
			local Yoffset = 20
			local CheckColor
			local ExpandMenuPickStr
			for L = 1 to LM.Layers.count do
			(	
			--set up a few variables for group status
				
				if L == 1 then
				(
					CheckColor = UI_WorldCheckColor as string
					ExpandMenuPickStr = ("LM.PropChange = " + L as string +" 
						LM.UI.MakeLayerRCMenu()
						PopupMenu  LM_World_ExpandedMenu rollout:LM_Roll")
					Yoffset = 22
				)
				else
				(
					CheckColor = UI_HideCheckColor as string

					Yoffset = 20
					if LM.Layers[L].isGroupMember == true then 
					(
						XIndent = 13
						CheckColor = UI_GroupMemberCheckColor as string
					)
					else XIndent = 0			
				)

				if LM.Layers[L].isGroupHead == true then  --expand collapse for groups
				(
					ExpandMenuPickStr = ("if keyboard.shiftPressed == true then (
							DisableSceneRedraw()
							select (LM.GetLayerObjects " + L as string +" )
							EnableSceneRedraw()
						)
						else(
						LM.PropChange = " + L as string +" 
						LM.UI.MakeLayerRCMenu()
						PopupMenu LM_Group_ExpandedMenu rollout:LM_Roll
						)")
					CheckColor =  UI_GroupLayerCheckColor as string
					local LayActString = (" width:11 height:11 pos:[2,"+ (Ypos+3) as string+"] "+
						"images:#(UI_BMP_ControlsI, UI_BMP_ControlsM, 10,10,9,10,9) "+
						"highlightcolor:"+ CheckColor as string)
					
					rci.addControl #checkbutton (("LayAct"+L as string)as name) "" paramStr:LayActString
					rci.addHandler (("LayAct"+L as string)as name) #changed paramStr:"State" \
						codeStr:("LM.SetGroupExpand "+ L as string +" state ; LM.UI.UpdateRollout()")
					--"LM.Layers["+L as string+"].isGroupExpanded = state ;
				)
				else
				(
					if L != 1 then ExpandMenuPickStr = ("if keyboard.shiftPressed == true then (
							DisableSceneRedraw()
							select (LM.GetLayerObjects " + L as string +" )
							EnableSceneRedraw()
						)
						else(
						LM.PropChange = " + L as string +" 
						LM.UI.MakeLayerRCMenu()
						PopupMenu LayControlMenuExpand rollout:LM_Roll
						)")
					--Active Layer
					local LayActString = (" width:12 height:17 highlightcolor:"+UI_ActiveLayerCheckColor as string) --pos:["+(2+XIndent)as string+","+ Ypos as string+"]
					rci.addControl #checkbutton (("LayAct"+L as string)as name) "" paramStr:LayActString
					rci.addHandler (("LayAct"+L as string)as name) #changed paramStr:"state" codestr:("LM.activelayer="+L as string+";LM.UI.UpdateRollout()")
				)
				

				--Layer Toggle Checkbutton		
				local LToggleString = (" highlightcolor:"+CheckColor+" width:"+(111-XIndent)as string+" height:17 align:#left pos:["+(15+XIndent)as string+","+ 
					Ypos as string+"]  tooltip:\"Toggle Layer On/Off\" checked:( not LM.Layers[" + L as string + "].isHidden)")
				rci.addControl #checkbutton (("LToggle"+L as string)as name) LM.Layers[L].LayerName paramStr:LToggleString
				rci.addHandler (("LToggle"+L as string)as name) #changed paramStr:"state" codestr:("LM.HideLayer "+L as string + " state ; LM.UI.UpdateRollout()")
				
				--Layer Freeze Checkbutton
				local Lay_FreezeString = (" height:17 width:17 pos:[127,"+Ypos as string+"] images:#(UI_BMP_ControlsI,UI_BMP_ControlsM, 10,1,5,1,5) "+
					" checked:(LM.Layers[" + L as string + "].isFrozen) tooltip:\"Freeze Layer\" ")
				rci.addControl #checkbutton (("Lay_Freeze"+L as string)as name) "" paramStr:Lay_FreezeString
				rci.addHandler (("Lay_Freeze"+L as string)as name) #changed paramStr:"state" codestr:("LM.FreezeLayer "+L as string + " state")

				--Layer Alt Material Checkbutton
				local Lay_MatteString = (" height:17 width:17 pos:[145,"+Ypos as string+
					"] checked:(LM.Layers[" + L as string + "].isAltMat )  images:#(UI_BMP_ControlsI, UI_BMP_ControlsM, 10,2,6,2,6) tooltip:\"Alternate Material\" ")	
				rci.addControl #checkbutton (("Lay_Matte"+L as string)as name) "" paramStr:Lay_MatteString
				rci.addHandler (("Lay_Matte"+L as string)as name) #changed paramStr:"state" codestr:("LM.SetAltMat State "+L as string +"; LM.UI.UpdateRollout()")

				--Layer Properties
				local Lay_PropString = (" height:17 width:17 pos:[163,"+Ypos as string+
					"] images:#(UI_BMP_ControlsI, UI_BMP_ControlsM, 10,3,3,3,3)  tooltip:\"Layer Parameters\" ")
				rci.addControl #button (("Lay_Prop"+L as string)as name) "" paramStr:Lay_PropString
				rci.addHandler (("Lay_Prop"+L as string)as name) #pressed CodeStr:("LM.PropChange="+L as string + ";createDialog Prop_Tab1_Roll modal:true" )
				
				--Layer Expanded Menu
				LConString = (" width:9 height:17 pos:[181," + Ypos as string+
					"] images:#(UI_BMP_ControlsI, UI_BMP_ControlsM, 10,4,4,4,4)  tooltip:\"Extended Menu\" ")
				rci.addControl #button (("LCon"+L as string)as name) ">" paramStr:LConString 
				rci.addHandler (("LCon"+L as string)as name) #pressed codeStr:ExpandMenuPickStr

				Ypos += Yoffset
			)
			
			--X REF SCENES
			if LM.xrefLayers == true then
			(
				for XR = 1 to xrefs.getXRefFileCount() do
				(
					local XRfile = xrefs.getxreffile XR
					local XRfileName = filenamefromPath (XRfile.filename)
					local XRfileHid = XRFile.hidden
					local XRfileEnab = not (XRFile.disabled)
					local UIState = 168
				--	if LM_Data[1][7]==false then UIState=150 else UIState=100
				
					rci.addControl #checkbox (("XRENab"+ XR as string) as name) "" paramStr:("pos:[2," + Ypos as string + "] width:15 checked:"+ XRfileEnab as string +" \n" )					
					local XRVisString = ("highlightcolor:" + UI_XrefCheckColor as string + " checked:"+ (NOT XRfile.hidden) as string + " width:"+UIState as string+" height:17  align:#left pos:[20,
							"+Ypos as string+"]   checked:"+XRfileHid as string + " tooltip:\"Toggle XRef Visibility\"\n" )
					rci.addControl #checkbutton (("XRVis"+ XR as string) as name) XRfileName paramStr:XRVisString
					
					rci.addHandler (("XRENab"+ XR as string) as name) #changed paramStr:"state" codestr:("
						LM.TempData_1 = xrefs.getxreffile " + XR as string + "
						LM.TempData_1.hidden = (not state)")
					rci.addHandler (("XRVis"+ XR as string) as name) #changed paramStr:"state" codestr:("
						LM.TempData_1 = xrefs.getxreffile " + XR as string + "
						LM.TempData_1.disabled = (not state)")
					
					Ypos+=20
				)			
			)
			
			rci.addHandler "LM_Roll" #moved paramStr:"loc" codeStr:"LM.FloaterPosition =  [loc.x-3,loc.y-22]"
			--LM_Roll = rci.end()
			rci.end()
			
			if Ypos > 800 then Ypos = 800
			
			createDialog rci.def 192 Ypos LM.FloaterPosition.X LM.FloaterPosition.Y
			--LM.UI.UpdateRollout()
		),
		Function UpdateRollout =
		(		
			local Ypos = 18
			local XOffset
			local VisOffset
			local ActiveLayCheck
			
			--Active Layer Checks
			if LM.ActiveLayer > LM.Layers.count then LM.ActiveLayer = LM.Layers.count
			if LM.Layers[LM.ActiveLayer].isGroupHead == true then LM.ActiveLayer += 1
			
			
			
			for L = 1 to LM.Layers.count do
			(
				--reset some vals
				XOffset = 0
				VisOffset = 0

				if LM.Layers[L].isGroupMember == true and LM.Layers[L].isGroupExpanded == false then 
				(
					Ypos += 0
					VisOffset = (-1000)
				)
				else Ypos +=20
								
				if LM.activelayer == L then ActiveLayCheck = true
				else ActiveLayCheck = false
				
				if LM.Layers[L].isGroupHead == true then
				(
					if LM.Layers[L].isGroupExpanded then ActiveLayCheck = true
					else ActiveLayCheck = false
				
				)
				
				if LM.Layers[L].isGroupMember == true then XOffset += 13
				
				--Active Layer
				execute ("LM_Roll.LayAct"+L as string+".checked = " + ActiveLayCheck as string)
				execute ("LM_Roll.LayAct"+L as string+".pos = [" + (2+XOffset+VisOffset) as string + "," + Ypos as string + "]")
				
				--LToggle	
				execute ("LM_Roll.LToggle"+L as string+".pos = ["+ (15+XOffset+VisOffset) as string + "," + Ypos as string + "]")
				--execute ("LM_Roll.LToggle"+L as string+".width = "+(110+XOffset) as string )
				execute ("LM_Roll.LToggle"+L as string+".text = LM.Layers["+L as string +"].LayerName")
				execute ("LM_Roll.LToggle"+L as string+".checked = not LM.Layers["+L as string +"].ishidden")
				
				--Freeze
				execute ("LM_Roll.Lay_Freeze"+L as string+".pos = ["+ (127+VisOffset) as string + "," + Ypos as string + "]")
				execute ("LM_Roll.Lay_Freeze"+L as string+".checked = LM.Layers["+L as string +"].isfrozen")
				
				--Alt Mat
				execute ("LM_Roll.Lay_Matte"+L as string+".pos = ["+ (145+VisOffset) as string + "," + Ypos as string + "]")
				execute ("LM_Roll.Lay_Matte"+L as string+".checked = LM.Layers["+L as string +"].isAltMat")
				
				--Properteies 
				execute ("LM_Roll.Lay_Prop"+L as string+".pos = ["+ (163+VisOffset) as string + "," + Ypos as string + "]")
					
				--Extended
				execute ("LM_Roll.LCon"+L as string+".pos = ["+ (181+VisOffset) as string + "," + Ypos as string + "]")
				
				--High Light Active Layer
				
				--execute ("LM_Roll.High.pos = [16, LM_Roll.LToggle"+L as string+".pos.y ]")
				--execute ("LM_Roll.High.checked = LM_Roll.LToggle"+L as string+".checked ")
				--execute ("LM_Roll.High.text = LM_Roll.LToggle"+L as string+".text ")

			)
			--LM_CreateFloat.size.y = (Ypos+80)
			

		),
		Function SetAutoAssign State =
		(
			LM.autoassign = State
			try (deleteAllChangeHandlers id:#LM_Handle)
			catch(print "LM: Error: During LM.AutoAssign() - ChangeHandlers Deletion")
			if state == True then
			(
				LM_Handle = (
					when children rootNode changes id:#LM_Handle handleAt:#redrawViews do --
					(	
						--checking for appdata before sending it to be added to a layer insures that the objects weren't merged in.
						try (
							if LM != undefined  then
							(
								if LM.Layers[ LM.activeLayer ].ishidden == true then --if layer is hidden unhide it.
								(
									LM.HideLayer LM.activeLayer true
									--do ui
									LM.UI.UpdateRollout()
								)
								if selection.count > 0 then
								(
									local objs = (selection as array)
									if getappdata objs[1] 9901 == undefined then LM.AddObjectsToLayer LM.activeLayer objs
								)
							)
						)
						catch()
					)
				)
				pushPrompt "LM: AutoAssign Active"
			)
			--gc()
		)

	) --end LM_UI Struct

	Function LM_CreateData =
	(
		local VarString = CreateStringVariableName 6
		--make sure it doesn't already exist for some strange reason
--		while (execute VarString) != undefined do
--			VarString = CreateStringVariableName 6
		execute ("Persistent Global " + VarString + " = zzz_LayerManager()")
		execute ("Global LM = " + VarString )
		setappdata GlobalTracks[1] 9901 VarString
		LM.UI = LM_UI()
		LM.ID = VarString
		LM.Version = LM_Version
		LM.AddNewLayer()
		LM.Layers[1].LayerName = "World Layer"
		LM.Layers[1].useLayerProperties = false	
	)

	if getappdata GlobalTracks[1] 9901 == undefined then  -- NO LM DATA EXISTS
	(
		LM_CreateData()
	)
	else
	(	
		local VarString = getappdata GlobalTracks[1] 9901
		execute ("Global LM = " + VarString )
		
		if LM == undefined then LM_CreateData()
		else --LM is defined
		(
			if LM.UI == undefined then LM.UI = LM_UI() --double check the UI exists
			--get new variable name
			local NewVarString = CreateStringVariableName 6
			local OldVarName = LM.ID
			--assign it as the pgloab with a copy of current pglob
			execute ("Persistent Global " + NewVarString + " = copy " + LM.ID)
			execute ("Global LM = " + NewVarString )
			setappdata GlobalTracks[1] 9901 NewVarString
			LM.ID = NewVarString
			--take out current pGlob as pglob and make it undefined in global terms
			persistents.remove (OldVarName as name )
			execute (OldVarName + " = undefined")
		)
	)
	--if (LM_Roll != undefined) then destroyDialog LM_Roll
	if LM.AutoAssign == true then LM.UI.SetAutoAssign true
	LM.UI.MakeRollout()
	--LM.UI.UpdateRollout()
)
