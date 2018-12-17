rollout quickOutliner "Make Polylines"
 (
	checkbutton dotracker "SmoothPolyLines"
	on dotracker changed arg1 do 
	(
		try 
		(
			if arg1 then 
			(
				polyOp.setEdgeSelection $ #All;update $
				modPanel.addModToSelection (Edit_Mesh ()) ui:on
				subobjectLevel = 2
				max select invert
				meshOps.invisibleEdge $.modifiers[1]
				subobjectLevel = 0
				modPanel.setCurrentObject $.baseObject
				subobjectLevel = 0
				$.showCage = off
				showendresult=true
			)
			else
			(
				try
				(
					deleteModifier $ 1
				)
				catch
				(
					$.showCage = on
					showendresult=false
				)
				$.showCage = on
				showendresult=false
			)
		)
		catch
		( 
			messageBox "Select an object that is at it's\nbase level an Editable Poly"
			doTracker.state=false
		)
	)
 )
 pDialogue=newRolloutFloater "Smooth Polylines Thing" 150 75
 addRollout quickOutliner pDialogue