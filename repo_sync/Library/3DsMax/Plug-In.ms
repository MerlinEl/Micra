#floatTab

#float animatable
#integer animatable
#index animatable
#color animatable
#rgb  animatable
#frgba animatable
#point3 animatable
#point4 animatable
#boolean animatable
#angle animatable
#percent animatable
#worldUnits animatable
#matrix3
#string
#filename
#colorChannel animatable
#time animatable
#radiobtnIndex
#material
#texturemap
#bitmap
#node
#maxObject


#intTab
#indexTab
#colorTab
#rgbTab
#frgbaTab
#point3Tab
#point4Tab
#boolTab
#angleTab
#percentTab
#worldUnitsTab
#matrix3Tab
#stringTab
#filenameTab
#colorChannelTab
#timeTab
#radiobtnIndexTab
#materialTab
#texturemapTab
#bitmapTab
#nodeTab
#maxObjectTab

 the_weaponData = attributes weaponData
(
	parameters main rollout:params
	(
	hitPoints type: #float default:10
	cost type: #float  default:100
	sound type: #string
	)
	rollout params "Weapon Parameters"
	(
	)
)
custAttributes.add $ the_weaponData



plugin helper getsetHandlerTest 
name:"DummyEx" 
classID:#(1453456,5432110) 
category:"Scripted Primitives" 
extends:dummy
( 
	parameters main rollout:params 
	( 
		nodeTab type:#nodetab tabSizeVariable:true 
		on nodeTab set val index do format "set nodeTab: % : %\n" val index
		on nodeTab get val index do (format "get nodeTab: % : %\n" val index;val)
		intTab type:#inttab tabSizeVariable:true 
		on intTab set val index do format "set intTab: % : %\n" val index
		on intTab get val index do (format "get intTab: % : %\n" val index;val)
		point3Tab type:#point3tab tabSizeVariable:true 
		on point3Tab set val index do format "set point3Tab: % : %\n" val index
		on point3Tab get val index do (format "get point3Tab: % : %\n" val index;val)
		intVal type:#integer 
		on intVal set val do format "set intVal: %\n" val 
		on intVal get val do (format "get intVal: %\n" val;val)
	) 
	rollout params "Parameters" 
	( 
	
	) 
)


parameters params rollout:theRollout
 (
	theNodeList type:#nodeTab tabSize:2 tabSizeVariable:false ui:(theNodePicker1, theNodePicker2)
 )
 rollout theRollout "TheRollout"
 (
	 pickButton theNodePicker1 autoDisplay:true
	 pickButton theNodePicker2 autoDisplay:true
 )
-- If you want to use a listbox instead of multiple pickButtons, you'd need something like this:
 parameters params rollout:theRollout
 (
	theNodeList type:#nodeTab tabSize:0 tabSizeVariable:true
	-- update the multiListBox when the nodeTab has changed
	on theNodeList tabChanged change tabIndex tabCount do this.theRollout.updateNodeList()
 )
 rollout theRollout "TheRollout"
 (
	 -- filter used by pickButton. Prevents duplicate entries
	 fn filterUnique obj = findItem this.theNodeList obj == 0
	 multiListBox lstNodeList
	 pickButton btnAdd "Add" across:2 filter:filterUnique
	 button btnRemove "Remove"
	 -- function to update the multiListBox
	 fn updateNodeList = lstNodeList.items = for obj in theNodeList collect obj.name
	 -- add/remove nodes
	 on btnAdd picked obj do append theNodeList obj
	 on btnRemove pressed do
	 (
	 -- collect all nodes that aren't selected
	 theNodeList = for i = 1 to theNodeList.count where not lstNodeList.selection[i] collect theNodeList[i]
	 )
	 -- update the multiListBox when the rollout is opened
	 on theRollout open do updateNodeList()
 )

--To generate a new unique ID, you can use the GenclassID() method in the Listener and copy the result into the script. 


plugin simpleObject tower_plugin_def
name:"Tower"
classID:#(145345,543211)
category:"Scripted Primitives"
( 
	parameters main rollout:params
	(
		height type:#worldUnits ui:height default:0
		width type:#worldUnits ui:width default:0
		depth type:#worldUnits ui:depth default:0
	)
	rollout params "Two Faces Parameters"
	(
		spinner height "Height" type:#worldunits range:[-1000,1000,0]
		spinner width "Width" type:#worldunits range:[-1000,1000,0]
		spinner depth "Depth" type:#worldunits range:[-1000,1000,0]
	)
	on buildMesh do
	(
		setMesh mesh \
		verts:#([0,0,0],[width,0,0],[width,depth,0],[0,depth,0]) \
		faces:#([3,2,1], [1,4,3])
		extrudeFace mesh #(1,2) (height * 0.5) 40 dir:#common
		extrudeFace mesh #(1,2) (height * 0.5) 50 dir:#common
	)
	tool create
	(
		on mousePoint click do
		case click of
		(
			1: nodeTM.translation = gridPoint
			3: #stop
		)
		on mouseMove click do
		case click of
		(
			2: (width = gridDist.x; depth = gridDist.y)
			3: height = gridDist.z
		)
	)
)
tower_plugin_def()


plugin simpleObject squareTube
name:"SquareTube"
classID:#(63445,55332)
category:"Scripted Primitives"
( 
	local box1, box2
	parameters main rollout:params
	(
		length type:#worldUnits ui:length default:1E-3
		width type:#worldUnits ui:width default:1E-3
		height type:#worldUnits ui:height default:1E-3
	)
	rollout params "SquareTube"
	(
		spinner height "Height" type:#worldUnits range:[1E-3,1E9,1E-3]
		spinner width "Width" type:#worldUnits range:[1E-3,1E9,1E-3]
		spinner length "Length" type:#worldUnits range:[-1E9,1E9,1E-3]
	)
	on buildMesh do
	(
		if box1 == undefined then
		(box1 = createInstance box; box2 = createInstance box)
		box1.height = height; box2.height = height
		box1.width = width; box2.width = width * 2
		box1.length = length; box2.length = length * 2
		mesh = box2.mesh - box1.mesh
	)
	tool create
	(
		on mousePoint click do
		case click of
		(
			1: nodeTM.translation = gridPoint
			3: #stop
		)
		on mouseMove click do
		case click of
		(
			2: (width = abs gridDist.x; length = abs gridDist.y)
			3: height = gridDist.z
		)
	)
)
squareTube()





plugin shape NEWDot
 name:"New Dot"
 classID:#(0x133067, 0x53375)
 extends:Circle version:1
 category:"New Dot"
 (
   tool create
   (
 	local clickPoint
 	  
 	on mousePoint click do
 	  case click of
 	  (
 		1: (nodeTM.translation = gridPoint
 			 delegate.radius = 1.35
 			 $.name = UniqueName "Dot"
 			 $.wirecolor = (color 20 240 20)
 			)
 		3: #stop
 	  )
 	on mouseMove click do
 	  case click of
 	  (
 		2: (nodeTM.translation = gridPoint)
 		3: #stop
 	  )
   )
 )
 
 
 (
 struct sourceObject 
 (
 node,
 name,
 checked,
 Properties = #(),
 mutationsList = #(),
 linkedSourceObjectsList = #()
 )

 ca = attributes ca
 (
 parameters store
 (
 node type:#maxObject
 name type:#string
 checked type:#boolean
 properties type:#string
 mutationsList type:#string
 linkedSourceObjectsList type:#maxObjectTab tabSize:0 tabSizeVariable:true
 )
 )

 b = box name:"CA_Holder"
 append b.children (box name:"Child1" pos:[25,0,0])
 append b.children (box name:"Child2" pos:[0,25,0])

 custAttributes.add b ca

 -- Save data to CA

 b.ca.node = NodeTransformMonitor node:b forwardTransformChangeMsgs:false
 b.ca.name = b.name
 b.ca.checked = true
 b.ca.properties = #(1, 0.0, 0.0, 0.0, false, 1, false, "Teapot001_", (color 145 28 177), false, 1, 1) as string
 b.ca.mutationsList = #() as string
 b.ca.linkedSourceObjectsList = for c in b.children collect NodeTransformMonitor node:c forwardTransformChangeMsgs:false

 -- Parse back to struct

 mySource = sourceObject node:b.ca.node.node \
 name:b.ca.name \
 checked:b.ca.checked \
 properties:(execute b.ca.properties) \
 mutationsList:(execute b.ca.mutationsList) \
 linkedSourceObjectsList:(for n in b.ca.linkedSourceObjectsList collect n.node)

 print mySource
 ok
 )