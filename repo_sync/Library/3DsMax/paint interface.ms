(
	local tPlane = sphere pos:[0,0,0]
	
	
	fn startStroke = 
	(
		print "Handle start stroke here"
	)

	fn paintStroke = 
	(
		try
		(
			local localHit = Point3 0 0 0
			local localNormal = Point3 0 0 0
			local worldHit = Point3 0 0 0
			local worldNormal = Point3 0 0 0
			local str = 0.0f
			local radius = 0.0f
			
			local shift = true
			local ctrl = true
			local alt = true
			local pressure = 0.0
		
			thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0
			thePainterInterface.getHitPressureData &shift &ctrl &alt &pressure 0
		
--thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal
--format "pressure:%\n" (if not bit.isFinite pressure then pressure else "infinite")
		
			local hit = thePainterInterface.getIsHit 0
			
			if hit do
			(
				print "Handle paint stroke here"
				thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &str 0
				
				format "pos:% zDepth:%\n" worldHit pressure
				--thePainterInterface.clearStroke()
			)
		)catch(print (getcurrentException()) )
	)

	fn endStroke = 
	(
		print "Handle end stroke here"
	)

	fn cancelStroke = 
	(
		print "Handle cancel stroke here"
	)

	fn systemEnd = 
	(
		print "Handle system end here"
	)

	if isValidNode tPlane do
	(
		thePainterInterface.ScriptFunctions startStroke paintStroke endStroke cancelStroke systemEnd
		thePainterInterface.initializeNodes 0 #(tPlane)
	-- 	thePainterInterface.pressureEnable = true
	-- 	thePainterInterface.pressureAffects = 2
		thePainterInterface.startPaintSession()
	)
)