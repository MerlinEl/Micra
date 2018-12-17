
----------------------------------
disableSceneRedraw()
	try
		(
		newObjs = #()
		
		-- setup progress bar
		progressStart "Make Unique"
		escapeEnable = false
		oldObjs = ($Selection as array)	
		numOfItems = oldObjs.count	
		currentIteration = 0
		for i in oldObjs do
			(
			currentIteration += 1
			m = ((currentIteration as float)/(numOfItems as float))*100
			
			-- clone the objects
			newObj = copy i
			newObj.name = i.name
			newObj.wirecolor = i.wirecolor
					
			append newObjs newObj
			progressUpdate m
			)
		progressEnd()
	
		-- delete old objects, select new objects
		for i in oldObjs do delete i
		if newObjs.count != 0 then select newObjs
		)
	catch ()
	enableSceneRedraw()
	completeRedraw()
	)




/*
i=instancemgr -- the instance manager
i.getinstances $ &x -- get all instances
select x -- select the new array
if (i.CanMakeObjectsUnique x[1]) then (i.MakeObjectsUnique &x[1] #prompt) -- make the first object unique
*/