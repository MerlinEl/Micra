
  
  rollout testRoll "Drag Test"
  (
  	local theMat --Stores the material to apply to the object
  	local theObject --Stores the object who's material you are aobut to change
  	local dragFlag = false --A flag to keep the material from beeing changed if the drag and drop did not end outside the treeView and the rollout looses focus
  	dotNetControl matTreeView "TreeView" height:477 width:150 pos:[9,26]
  	fn hitTest =
  --Returns the object at the mouse position in the viewport	
  (
  	local theRay=mapScreenToWorldRay mouse.pos
  	local dist=undefined
  	local theHit=undefined
  	local hitObject=undefined
  	for x in objects do 
  	(
  		hitRay=intersectRay x theRay
  		if hitRay!=undefined then
  		(
  			tempDist=distance hitRay.pos theRay.pos
  			if dist==undefined or tempDist<dist then
  			(
  				dist=tempDist
  				theHit=hitRay
  				hitObject = X
  			)
  		)
  	)
  	hitObject 
  )
  	ON matTreeView ItemDrag arg DO
  	--When the dragging starts store the corresponding material
  	(
  		dragFlag = true
  		theMat = (getMeditMaterial (arg.item.index+1))
  	)
  	
  	ON matTreeView mouseUp arg DO
  	--Then the mouse button is up set the flag to false. Only happens if the mouse button is released INSIDE the treeView
  	(
  		dragFlag = false
  	)
  	
  	ON matTreeView lostFocus arg DO
  	--When the treeview looses focus find the object under the mouse and apply the material
  	(
  		theObject = hitTest()
  		IF theObject != undefined AND dragFlag == true DO --Check an object was found and that the flag is set to true
  		(
  			theObject.material = theMat
  		)
  		theObject = undefined
  	)
  
  	ON testRoll OPEN DO
  	--When the roll open populate with the materials in the MatEd
  	(
  		FOR mat = 1 to 24 DO
  		(
  			matTreeView.nodes.Add (getmeditMaterial mat).name
  		)
  		matTreeView.allowDrop = true
  	)
  )
  
  createDialog testRoll