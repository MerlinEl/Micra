case of 
(
	(dbutt ==1) : --open 
	(
		for e = 120 to 365 by 5 do
		(
			smoothwire.width = e
			sleep 0.002
			dbutt=0
		)
	)
	(dbutt ==0) : --close
	(
		for f = 350 to 120 by -5 do
		(
			sleep 0.002
			smoothwire.width = f
			dbutt=1
		)
	)
)