utility circleArray "Circle Array"
(	-- UI --
	pickbutton objToCopy "Pick Source Object" width:120 autoDisplay:true \
	message:"Pick a object to copy"
	pickbutton objToRot "Pick Rotate About" width:120 autoDisplay:true \
	message:"Pick a object to rotate about"
	radiobuttons clone labels:#("Copy", "Ref.", "Ins.") across:2
	radiobuttons rAx labels:#("X", "Y", "Z")
	spinner objCount "Count:" range:[1,360,12] type:#integer \
	fieldwidth:30 across:2 align:#left
	button go "Do it!" align:#center enabled:false
	-- Events --
	on objToCopy picked obj do
	(
		if obj != undefined do
		(
			objToCopy.text = obj.name
			if objToRot.text != "Pick Rotate About" then
				go.enabled = true
		)
	)
	on objToRot picked obj do
	(
		if obj != undefined do
		(
			objToRot.text = obj.name
			if objToCopy.text != "Pick Source Object" then
				go.enabled = true
		)
	)
	on go pressed do
	(
		undo "Circle Array" on
		(
			clearSelection()
			local ax
			a = getNodeByName objToCopy.text
			c = objCount.value
			ro = getNodeByName objToRot.text
			ang = 360/c
			for i = 1 to (c - 1) do
			(
				case rAx.state of (
					1: ax = x_axis
					2: ax = y_axis
					3: ax = z_axis
				)
				about ro rotate a (ang) ax
				case clone.state of (
					1: cp = copy a
					2: cp = reference a
					3: cp = instance a
					)
				selectMore cp
			)
			about ro rotate a (ang) ax
			selectMore a
		)
	)
) -- end