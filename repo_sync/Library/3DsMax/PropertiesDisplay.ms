-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- // File: PropertiesDisplay.ms                                                                        //
-- // Created By: Kevin Mackey (a.k.a. Malkalypse)                                                      //
-- //                                                                                                   //
-- // Version: 1.0 (Last Modified 1/15/08)                                                              //
-- //                                                                                                   //
-- // Description:                                                                                      //
-- // - Displays a TreeView of all objects in the scene, along with their associated modifiers.         //
-- // - Click on any of the objects or modifiers to display a dynamically generated interactive rollout //
-- // created from the selection's associated properties and their values.                              //
-- //                                                                                                   //
-- // - The properties rollout can be toggled to display alphabetically or by number                    //
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////

if (splitViewRollout != undefined) and (splitViewRollout.isDisplayed) do (destroyDialog splitViewRollout)

global splitViewRollout
global propertiesRollout

global mySelection
global myNode

global str_DynamicRollout
global nodeName
global dynamicProperties
global str_DynamicProperties
global str_DynamicValues

alphaOrder = false

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // Begin Dynamic SubRollout                                                                                                                                                                   //
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fn sortAlpha theArray =
(
	try
	(
		sortStrArray_Properties = (sort theArray)
		execArray_Properties = #()
	
		for i = 1 to dynamicProperties.count do
		(
			execArray_Properties[i] = execute sortStrArray_Properties[i]
		) -- end for loop
	
		dynamicProperties = execArray_Properties
	) catch()
)

fn createDynamicSubRollout =
(
	if myNode != undefined do
	(
		try
		(
			if $ == myNode then	(dynamicProperties = getPropNames myNode)
			else 
			(			
				str_NodeName = "nodeName = $" + $.name + "." + myNode.name
				execute str_NodeName
				dynamicProperties = getPropNames nodeName
			)
			
			array_Properties = #()
			strArray_Properties = #()
			
			for i = 1 to dynamicProperties.count do
			(
				append array_Properties #()
				array_Properties[i][1] = dynamicProperties[i]	
				array_Properties[i][2] = i
		
				strArray_Properties[i] = array_Properties[i] as string
			) -- end for loop
		) catch()
		
		if alphaOrder == true then (sortAlpha StrArray_Properties) else (dynamicProperties = array_Properties)
	)

	-- Create a dynamically generated string using the property array
	str_DynamicProperties = stringStream ""
	for i = 1 to dynamicProperties.count do
	(
		format "label lbl_%Index \"%\" pos:[5, (20 * %) + 20]\n" dynamicProperties[i][2] dynamicProperties[i][2] i										to:str_DynamicProperties
		format "label lbl_%Name \"%\" pos:[40, (20 * %) + 20]\n" dynamicProperties[i][2] dynamicProperties[i][1] i										to:str_DynamicProperties
	
		if (classOf (getProperty myNode dynamicProperties[i][1]) == float) or (classOf (getProperty myNode dynamicProperties[i][1]) == integer) do
		(
			format "spinner spn_% pos:[250, (20 * %) + 20] width:75 range:[-1e+008,1e+007,%] " dynamicProperties[i][2] i (getProperty myNode dynamicProperties[i][1])	to:str_DynamicProperties
			if (classOf (getProperty myNode dynamicProperties[i][1]) == integer) do format "type:#integer"												to:str_DynamicProperties 
			format "\n"																																	to:str_DynamicProperties
		)
		
		if (classOf (getProperty myNode dynamicProperties[i][1]) == booleanClass) do
		(
			if (getProperty myNode dynamicProperties[i][1]) == true then (dynamicBoolean = 1) else (dynamicBoolean = 2)
			format "radioButtons rad_% labels:#(\"True\",\"False\") default:% pos:[250, (20 * %) + 20]\n" i dynamicBoolean i							to:str_DynamicProperties
		)
	)
	str_DynamicProperties = str_DynamicProperties as string

	-- Create a dynamically generated string for the interactive values of each property
	str_DynamicValues = stringStream ""
	for i in 1 to dynamicProperties.count do
	(
		if (classOf (getProperty myNode dynamicProperties[i][1]) == float) or (classOf (getProperty myNode dynamicProperties[i][1]) == integer) do
		(
			format "on spn_% buttonDown do disableUpdate()\n" dynamicProperties[i][2]						to:str_DynamicValues
			format "on spn_% changed val do\n" dynamicProperties[i][2]										to:str_DynamicValues
			format "(\n"																					to:str_DynamicValues
			format "myNode.% = spn_%.value\n" (dynamicProperties[i][1] as string) dynamicProperties[i][2]	to:str_DynamicValues
			format ")\n"																					to:str_DynamicValues
			format "on spn_% buttonUp do enableUpdate()\n" dynamicProperties[i][2]							to:str_DynamicValues
		)
		
		if (classOf (getProperty myNode dynamicProperties[i][1]) == booleanClass) do
		(
			format "on rad_% changed state do\n" dynamicProperties[i][2]									to:str_DynamicValues
			format "(\n"																					to:str_DynamicValues
			format "  if rad_%.state == 1 then\n" dynamicProperties[i][2]									to:str_DynamicValues
			format "  (\n"																					to:str_DynamicValues
			format "    myNode.% = true\n" (dynamicProperties[i][1] as string)								to:str_DynamicValues
			format "  )\n"																					to:str_DynamicValues
			format "  else\n"																				to:str_DynamicValues
			format "  (\n"																					to:str_DynamicValues
			format "    myNode.% = false\n" (dynamicProperties[i][1] as string)								to:str_DynamicValues
			format "  )\n"																					to:str_DynamicValues
			format ")\n"																					to:str_DynamicValues
		)
	)
	str_DynamicValues = str_DynamicValues as string

	-- Create a dynamically generated rollout
	str_DynamicRollout = stringStream ""
	format "rollout propertiesRollout \"Properties\"\n"								to:str_DynamicRollout
	format "(\n"																	to:str_DynamicRollout
	format "  label title \"%\"\n" myNode.name										to:str_DynamicRollout
	format "  label blank \"\"\n"													to:str_DynamicRollout

	-- Use the dynamically generated string from above as rollout content
	format "  %\n" str_DynamicProperties											to:str_DynamicRollout
	format   "%\n" str_DynamicValues												to:str_DynamicRollout
	format ")\n"																	to:str_DynamicRollout
	str_DynamicRollout = str_DynamicRollout as string

	execute str_DynamicRollout
	
	addSubRollout splitViewRollout.dynamicSubRollout propertiesRollout
)

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // End Dynamic SubRollout                                                                                                                                                                     //
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



rollout splitViewRollout " Modifiers"
(

	-- //////////////////////////////////////////////////////////////////////////////////
	-- // Begin TreeView                                                               //
	-- //////////////////////////////////////////////////////////////////////////////////
	
	fn initTreeView tv = (tv.sorted = true)
		
	fn addModifiers theNode theModifiers =
	(
		for m in theModifiers do
		(
			newNode = theNode.nodes.add m.name
			newNode.tag = dotNetMXSValue m
		)
	) -- end fn
	
	fn addObjects theNode theObjects =
	(
		for c in theObjects do
		(		
			if isValidNode c do
			(
				newNode = theNode.nodes.add c.name
				newNode.tag = dotNetMXSValue c
				newNode.forecolor = (dotNetClass "System.Drawing.Color").fromARGB 200 0 0
			
				addModifiers newNode c.modifiers
			)
		)
	) -- end fn
	
	fn fillInTreeView tv =
	(
		tv.nodes.clear()
	
		theRoot = tv.nodes.add "(Objects)"
		objectNodes = for o in objects collect o
		addObjects theRoot objectNodes
		
		tv.expandAll()
	)
	
	-- //////////////////////////////////////////////////////////////////////////////////
	-- // End TreeView                                                                 //
	-- //////////////////////////////////////////////////////////////////////////////////
	
	
	
	dotNetControl tv "TreeView" width:150 height:325 pos:[5, 5]
	subRollout dynamicSubRollout
	
	button btn_Refresh			"Refresh"			pos:[5, 335]
	checkButton chk_Order		"Numeric"			pos:[160, 335]	
	--radioButtons rad_PropsType labels: #("Node","Transform","General") default:1 pos:[320, 335]
	
	on tv click arg do
	(	
		hitNode = tv.getNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
		try (removeSubRollout splitViewRollout.dynamicSubRollout propertiesRollout) catch()
		
		if hitNode.tag != undefined do
		(
			myNode = hitNode.tag.value
			if superClassOf hitNode.tag.value == GeometryClass do (select hitNode.tag.value)
			if superClassOf hitNode.tag.value == Modifier do (select hitNode.parent.tag.value)
				
			createDynamicSubRollout()
		)
	)
	
	on btn_Refresh pressed do
	(
		fillInTreeView tv
		try
		(
			removeSubRollout splitViewRollout.dynamicSubRollout propertiesRollout
			createDynamicSubRollout()
		) catch()
	)
	
	on chk_Order changed state do
	(
		try (removeSubRollout splitViewRollout.dynamicSubRollout propertiesRollout) catch()

		try
		(		
			alphaOrder = chk_Order.state
			chk_Order.text = if chk_Order.checked then "Alpha" else "Numeric"
		
			createDynamicSubRollout()
		) catch()
	)
	
	on splitViewRollout open do
	(
		initTreeView tv
		fillInTreeView tv
	)

	on splitViewRollout close do callbacks.removeScripts id:#redraw
)

createDialog splitViewRollout 540 365 style:#(#style_sysmenu, #style_titlebar, #style_toolwindow)

splitViewRollout.dynamicSubRollout.pos		= [160, 5]
splitViewRollout.dynamicSubRollout.width	= 375
splitViewRollout.dynamicSubRollout.height	= 325

fn updateControls =
(
	if selection.count == 1 do
	(
		try
		(
			dynamicControls = getPropNames myNode

			str_DynamicControls = stringStream ""
			for i = 1 to dynamicControls.count do
			(
				if (classOf (getProperty myNode dynamicControls[i]) == float) or (classOf (getProperty myNode dynamicControls[i]) == integer) do
				(	
					format "propertiesRollout.spn_%.value = %\n" i (getProperty myNode dynamicControls[i])	to:str_DynamicControls
				)
				if (classOf (getProperty myNode dynamicControls[i]) == booleanClass) do
				(
					if (getProperty myNode dynamicControls[i]) == true then (dynamicBoolean = 1) else (dynamicBoolean = 2) 
					format "propertiesRollout.rad_%.state = %\n" i dynamicBoolean							to:str_DynamicControls
				)
			)
			str_DynamicControls = str_DynamicControls as string
			execute str_DynamicControls
		)
		catch()
	)
)

fn enableUpdate = (registerRedrawViewsCallback updateControls)
fn disableUpdate = (unregisterRedrawViewsCallback updateControls)
enableUpdate()


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // Begin Callbacks                                                                                     //
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////
callbacks.addScript #nodeCreated			"splitViewRollout.fillInTreeView splitViewRollout.tv" id:#redraw
callbacks.addScript #nodePostDelete			"splitViewRollout.fillInTreeView splitViewRollout.tv" id:#redraw
callbacks.addScript #postModifierAdded		"splitViewRollout.fillInTreeView splitViewRollout.tv" id:#redraw
callbacks.addScript #postModifierDeleted	"splitViewRollout.fillInTreeView splitViewRollout.tv" id:#redraw

callbacks.addScript #nodeRenamed			"splitViewRollout.fillInTreeView splitViewRollout.tv" id:#redraw
callbacks.addScript #sceneUndo				"splitViewRollout.fillInTreeView splitViewRollout.tv" id:#redraw
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // End Callbacks                                                                                       //
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////