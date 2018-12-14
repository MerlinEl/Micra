--POLYMORF 1


--CIRCULATE EDGE LOOP

--Set variables
obj = selection[1]
edges = polyOp.getEdgeSelection obj
verts = polyOP.getVertsUsingEdge obj edges as array
vert_pos = [0,0,0]
for v in verts do vert_pos += polyOP.getVert obj v
circle_center = vert_pos/verts.count
circle_radius = distance circle_center (polyOP.getVert obj (verts as array)[1])
first_vert = polyOP.getVert obj verts[1]


--Sort vertices
struct Vert_Data (ang, vect, vert)
fn getVectorsAngle v1 v2 = (acos(dot (normalize v1) (normalize v2)))
fn compareFN v1 v2 =
(
	local d = v1.ang - v2.ang
	case of
	(
		(d < 0.): -1
		(d > 0.):  1
		default:   0
	)
)
initial_vect = circle_center - first_vert
upright_vect = normalize (cross circle_center initial_vect)
vd = for v in verts collect 
(
	vpos      = (polyOP.getVert obj v)
	next_vect = circle_center - vpos
	ang1_dif   = getVectorsAngle initial_vect next_vect
	ang2_dif   = dot next_vect upright_vect
	if ang2_dif < 0 do ang1_dif = 360 - ang1_dif
	Vert_Data ang1_dif vpos v
)
print "before sorting"
for p in vd do print p
print "after sorting"
qsort vd compareFN 
for p in vd do print p


undo on
( 
	--debug
	--point pos:(normalize initial_vect) wirecolor:red
	--point pos:(normalize upright_vect) wirecolor:blue
	--point pos:(normalize circle_center) wirecolor:green
	--point pos:(((normalize (circle_center-first_vert)) *circle_radius)+circle_center)
	
	angle_sum  = 25
	angle_step = 360 / verts.count

	--cnt = 0
	for i in vd do
	(
		--cnt +=1q
		--text text:(cnt as string) pos:(polyOP.getVert obj i.vert) size:4 dir:[1,0,0]
		
		vect  = [ circle_radius * (cos angle_sum) , circle_radius * (sin angle_sum) , 0 ]
		vect += circle_center
		polyOP.setVert obj i.vert vect
		angle_sum += angle_step
		
	)
)



/*
--#((Vert_Data num:1 vect:[58.69,0]), (Vert_Data num:2 vect:[58.69,0]), (Vert_Data num:3 vect:[58.69,0]), (Vert_Data num:4 vect:[58.69,0]))

struct Vert_Data (num, vect)
rand= #(8,4,6,2)
vd = for i =1 to 4 collect Vert_Data rand[i] [58.69,0]

for p in vd do print p

print "next"
fn compareFN v1 v2 =
(
	local d = v1.num - v2.num
	
	case of
	(
	(d < 0.): -1
	(d > 0.):  1
	default:   0
	)
)

qsort vd compareFN 

for p in vd do print p

*/










/*
--Optimize Edges Loop

--select an edge loop
--get loop edges 
obj = selection[1]
edges = polyOp.getEdgeSelection obj as array
format "edges:%\tcount:%\n" edges edges.count 
--get vertices neighbour vertices by order



--draw this loop in tag
*/