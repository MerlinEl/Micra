--#X
(
	q = $.rotation.track.value
	q.x*=  -1
	q.w*=  -1
	$.rotation.controller.value =  q
	
)
--#Y
(
	q = $.rotation.track.value
	q.y*=  -1
	q.w*=  -1
	$.rotation.controller.value =  q
	
)

--#Z
(
	q = qorthog $.rotation.track.value [0,1,0]
	q.x*=  -1
	q.w*=  -1
	$.rotation.controller.value =  q
)



---------

for o in sel do
(
	local opos = o.pos
	o.transform *= case axis of
	(
		#X:(matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])
		#Y:(matrix3 [1,0,0] [0,-1,0] [0,0,1] [0,0,0])
		#Z:(matrix3 [1,0,0] [0,1,0] [0,0,-1] [0,0,0])
	)
	o.pos = opos
)

---------

 	delete objects 
 	
 	origin = box pos:[-30, 10, 10] wirecolor:yellow
 	rotate origin (eulerangles 30 50 80)
 
 	mirrorX = copy origin wirecolor:green
 	tm = origin.transform * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])
 	mirrorX.transform = prescale tm [-1,1,1] 

------
fn flipObject obj axis =
(
	for v=1 to getnumverts obj do
	(
		 local vert_pos = polyOp.getvert obj v
		 case axis of
		 (
			#x: vert_pos[1] = obj.position.x - (vert_pos[1] - obj.position.x)
			#y: vert_pos[2] = obj.position.y - (vert_pos[2] - obj.position.y)
			#z: vert_pos[3] = obj.position.z - (vert_pos[3] - obj.position.z)
		)
		
		 polyOp.setvert obj v vert_pos 
	 )
	update obj
 )
flipObject $ #y