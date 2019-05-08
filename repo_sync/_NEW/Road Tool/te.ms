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
try (custAttributes.delete $ def baseObject:false) catch ()
custAttributes.add $ def --baseObject:false