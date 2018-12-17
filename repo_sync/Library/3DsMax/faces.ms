	fn faceIsHidden f =
	(
		local obj = selection[1]
		if not isCorrectSelection obj do return false
		local all_hidden_faces = polyop.getHiddenFaces obj 
		(#{f} - all_hidden_faces).numberset == 0
	)
	fn getSGarray obj = 
	(
		local SGarray=for i=1 to 32 collect #{}
		for f=1 to obj.numfaces do 
		(
			local SGnumber = polyOp.getFaceSmoothGroup obj f
			local SGbitarray=#{}
			if SGnumber < 0 do 
			(
				SGbitarray[32]=true
				SGnumber -= 2^31
			)
			for i = 1 to 31 do 
			(
				SGbitarray[i] = (mod SGnumber 2 > .5)
				SGnumber /= 2
			)
			for sg in SGbitarray do append SGarray[sg] f
		)
		--format "sg:%\n" SGarray
		SGarray
	)