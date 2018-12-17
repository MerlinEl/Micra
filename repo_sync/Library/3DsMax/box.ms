--Box
point pos:[-1,-1,0]
point pos:[-1,1,0]
point pos:[1,-1,0]
point pos:[1,1,0]
point pos:[1,-1,2]
point pos:[1,1,2]
point pos:[-1,1,2]
point pos:[-1,-1,2]

fn makeBox l w h =
(
	local 
	m = mesh vertices:#([-1,-1,0],[-1,1,0],[1,1,0],[1,-1,0]) faces:#([1,2,3], [1,3,4]) --face creation cw
	extrudeFace m #(1,2) -2 0 dir:#common
)

fn makeBox l w h =
(
	mesh vertices:# 
	(
		[-1*w/2,-1*l/2,0], [-1*w/2,1*l/2,0], [1*w/2,1*l/2,0], [1*w/2,-1*l/2,0],--bottom
		[-1*w/2,-1*l/2,h], [-1*w/2,1*l/2,h], [1*w/2,1*l/2,h], [1*w/2,-1*l/2,h] --top
	) \
	faces:# 
	(
		[1,2,3], [1,3,4], --bottom face cw
		[5,7,6], [5,8,7], --top face ccw
		[1,8,5], [1,4,8],--front face ccw
		[2,6,7], [2,7,3],--back face cw
		[2,5,6], [2,1,5],--left face ccw
		[3,7,8], [3,8,4] --right face cw
	) 
)

makeBox 10 20 30