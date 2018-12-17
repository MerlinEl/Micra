p1 = [20,10,10]
p1_vector = p1
p1_vector_length = distance [0,0,0] p1



fn movePointAlongVector p v val = ( p + (normalize v) * val )
point pos:(movePointAlongVector $.pos $.dir 100) dir:$.dir



Operace s vektory
fn RotateVectorByAxisAngle vect axis angle =  --thanks to: Martin Fedor (def)
(
   local outVect = [0,0,0]
   local vx=axis.x
   local vy=axis.y
   local vz=axis.z
   local s=sin(angle)
   local c=cos(angle)
   local u=1.0f-c

   local vxvxc=vx*vx+c
   local vyvyc=vy*vy+c
   local vzvzc=vz*vz+c

   local vxvyu=vx*vy*u
   local vxvzu=vx*vz*u
   local vyvzu=vy*vz*u

   local vxs=vx*s
   local vys=vy*s
   local vzs=vz*s

   outVect.x=vxvxc*vect.x        +  (vxvyu-vzs)*vect.y   +  (vxvzu+vys)*vect.z
   outVect.y=(vxvyu+vzs)*vect.x  +  vyvyc*vect.y         +  (vyvzu-vxs)*vect.z
   outVect.z=(vxvzu-vys)*vect.x  +  (vyvzu+vxs)*vect.y   +  vzvzc*vect.z
   
   return outVect
)

fn rotateVectorByAxisAngle rotAxis rotCenter thePoint rotAngle =
(
	local q = inverse (quat rotAngle (normalize rotAxis))
	return (((thePoint - rotCenter) * q) + rotCenter) --pointAfterRotation
)


fn getMiddlePoint A B =
(
	return ((A + B)/2)
)

fn get3PointsAngle A B C =
(
	local V1 = B - A
	local V2 = B - C
	return acos (dot (normalize V1) (normalize V2))  -- angle
)
		
fn getVectorsAngle v1 v2 = acos (dot (normalize v1) (normalize v2))),


--------------------------------------------------------
Základní definice a operace

Nulový vektor:	o = (0, …, 0)
Opaèný vektor:	-(x,y,z) = (-x, -y, -z)
Sèítání vektorù:	(x,y,z) + (u,v,w) = (x+u, y+v, z+w)
Odèítání vektorù:	(x,y,z) - (u,v,w) = (x-u, y-v, z-w)
Násobení vektoru skalárem:	s(x,y,z) = (sx, sy, sz)
Lineární kombinace vektorù:	a(x,y,z) + b(u,v,w) = (ax + bu, ay + bv, az + bw)
Délka vektoru (Euklidovská):	|(x,y,z)| = ?(x^(2) + y^(2) + z^(2))



		p1 = polyOp.getVert $ verts[1]
		p2 = polyOp.getVert $ verts[2]
		ve = (p2 - p1) -- get the vector
		l = length ve
		
		-------------
		
		theEdge = (modPanel.getCurrentObject()).getSelection #Edge
		theVerts = (polyOp.getVertsUsingEdge $ theEdge) as array
		vPos = #(polyOp.getVert $ theVerts[1],polyOp.getVert $ theVerts[2])
		
		ve = (vPos[2] - vPos[1]) -- get the vector
		l = length ve
		
		po1=point Pos:vpos[1]
		po2=point Pos:vpos[2]
		
		po1.dir = ve
		po2.dir = ve
		
		in coordsys local po1.pos = [po1.pos.x,po1.pos.y,1]
		
		
		
scalarni soucin : 

fn getScalar v1 v2 = 
(
	v1.x*v1.x + v1.y*v1.y + v1.z*v1.z
)
dot  eV v1
dot  eV v4