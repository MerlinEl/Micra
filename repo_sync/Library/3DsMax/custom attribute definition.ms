ca= attributes controls --redefine:ca
(
	fn resetPos obj = if obj != undefined do obj.pos = [0,0,0]
	rollout roll "reset"
	(
		button btnr "ResetPosition"
		on btnr pressed do resetPos selection[1]
    )	
)


b = box pos:[0,0,20] wirecolor:green isSelected:true
em = EmptyModifier()
addModifier b em
--custAttributes.add em ca
custAttributes.add b.modifiers[1] ca
---------------------------------------------------------------



--Create a custom attribute definition
ca=attributes myCaDef
(
	--Function for calculating the roll of a wheel
	fn wheel v r=
	(
		c=(2*pi*r)		--Circumference of the wheel
		deg=(c/6.28319) --c / Radians
		rot=v/deg		--Position / deg
		rot				--This isn't really needed
	)
)

--Create a control circle that will store the CA def.
cir=circle name:"Master"
--Add the CA def to the control.
custAttributes.add cir ca

--Create a cylinder to act as the wheel.
cyl=cylinder radius:30 height:10 name:"Wheel"
rotate cyl (eulerAngles 90 0 0)
move cyl [0,0,30]
--Apply a script controller to the y rotation of the wheel.
sCon=cyl.rotation.y_rotation.controller=float_script()
--Write the script controller, notice it is calling on the function stored in the control.
sCon.script="$master.myCaDef.wheel $wheel.pos.x $wheel.radius"

--Animate the wheel for demonstration.
animate on
at time 100 move cyl [200,0,0]



degTorad 360



-----Custom attribute definition



sph=#()
--Create three spheres with random positions. 

for i = 1 to 3 do 
(
	s=sphere radius:10 pos:(random [-100,0,0] [0,0,0])
	append sph s
)

--Create a box.
b=box pos:[40,0,0]


--Custom attribute definition

def=attributes nodeStore
(

--Param2 with #maxObjectTab

	parameters nodesP rollout:nodesR
	(
		refNodes type:#maxObjectTab tabSize:0 tabSizeVariable:true
	)

--Rollout for the UI to control which nodes are stored. 

	rollout nodesR "Nodes"
	(
		local btW=135, btW2=65
		listBox nodesListLb "Nodes:"
		pickButton addObject "Add Object" width:btW2 across:2
		button deleteObject "Delete" width:btW2
		
		group "Tests:"
		(
			button printRefNodes "Print refNodes" width:btW
			button printRefNodesNode "Print Nodes" width:btW
		)

--Function to update the listBox when the UI is opened or a new node is added. 		
		fn updateList=
		(
			nNames=for n in refNodes collect n.node.name
			nodesListLb.items=nNames
		)

--Called when the Add Node picked button has selected an object. 		
		on addObject picked obj do
		(
--Creates a nodeTransformMonitor from using the selected node and appends refNodes with it. 
			append refNodes (nodeTransformMonitor node:obj forwardTransformChangeMsgs:false)
			updateList()
		)

--Called when delete is pressed.
		on deleteObject pressed do
		(
			num=nodesListLb.selection
			if num>0 then
			(
				deleteItem refNodes num
				updateList()
			)
		)
		
--Prints the contents of refNodes to the listener. 
		on printRefNodes pressed do
		(
			for n in refNodes do
			(
				print n
			)
		)

--Get the referenced nodes held in nodeTransformMonitor and prints then to the listener. 
		on printRefNodesNode pressed do
		(
			for n in refNodes do
			(
				print n.node
			)
		)
		
		on nodesR open do
		(
			updateList()
		)
	)
)

--Creates an instance of an attribute holder modifier. 
ah=(EmptyModifier())
--Adds the modifier to the box that was created. 
addModifier b ah
--Adds the custom attribute definition to the attribute holder. 
custAttributes.add ah def


--Loops through all the spheres and adds them to nodeTransformMonitor and then appends then
--to the refNodes parameter on the attribute holder. 
for s in sph do
(
	obj=nodeTransformMonitor node:s forwardTransformChangeMsgs:false
	append b.modifiers[1].refNodes obj
)

--Select the box.
select b


-------------------------------------------------------------------
ca = attributes controls
(
	parameters main rollout:roUI
	(
		-- Here we store the state
		hideState type:#boolean default:false animatable:false ui:chbtHideMe
		-- Here we store the node reference
		hideNode type:#maxObject
	)
	
	rollout roUI "UI Stuff"
	(
		checkButton chbtHideMe "Hide Reference" height:18 width:155 align:#center
		
		on chbtHideMe changed state do
		(
			hideNode.node.isHidden = state
			chbtHideMe.Text = if state then "Show Reference" else "Hide Reference"
		)
	)
)

b = box wirecolor:black isSelected:true
b2 = box height:10 width:30 length:30 wirecolor:orange
em = EmptyModifier()
addModifier b em
custAttributes.add em ca
em.controls.hideNode = NodeTransformMonitor node:b2 forwardTransformChangeMsgs:false


----------------------------
--Redefine Controls

-- Create a test modifier
b = bend angle:45

-- Add it before the attribute holder, so it gets index 2
addModifier $ b before:1

-- Get the attrib def
ca = CustAttributes.getDef $.modifiers[1].controls

-- redefine it
cc = attributes controls
redefine:ca
(
parameters params rollout:roll
(
boxState type:#boolean default:false animatable:false ui:boxBut
boxNode type:#maxObject
boxMod type:#maxObject
)
rollout roll "Options"
(
checkbutton boxBut "Hide/Show"
on boxBut changed state do
(
max create mode -- circumvent the ui update problem
boxMod.enabled = not state
max modify mode

)
)
)
-- assign the bend modifier to the boxmod parameter
$.modifiers[1].controls.boxMod = $.modifiers[2]
