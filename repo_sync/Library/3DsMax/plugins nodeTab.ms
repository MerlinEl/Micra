plugin helper getsetHandlerTest 
name:"DummyEx" 
classID:#(0x3c0334b1, 0x30f5be78)
category:"Standard" 
extends:dummy
(
	-- If you want to use a listbox instead of multiple pickButtons, you'd need something like this:
	 parameters params rollout:theRollout
	 (
		--size type:#point3 ui:size default:[10,10,10]
		 size type:#worldUnits ui:size default:69.3063
		 theNodeList type:#nodeTab tabSize:0 tabSizeVariable:true
		-- update the multiListBox when the nodeTab has changed
		on theNodeList tabChanged change tabIndex tabCount do this.theRollout.updateNodeList()
	 )
	 rollout theRollout "TheRollout"
	 (
		spinner size "Size:" type:#worldUnits range:[0,10000,0] align:#center
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
	 on getDisplayMesh do
	 (
		/*print (classof node)*/
		 /*scale theMesh [size, size, size]*/
	 )
	tool create
    (
        on mousePoint click do
		case click of 
		(
			1: (nodeTM.translation = gridPoint)
			2: #stop
		)   
		on mouseMove click do
		case click of
		(
			2: 
			(
				size = 2 * length gridDist
				local thisNode = (refs.dependentNodes this)[1]
				/*thisNode.boxsize=[size, size, size]*/
			)
			
		)		
    )
 )