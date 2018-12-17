(getFaceNormal mesh faceNum)


fn localDirection node=
(		
	local minmax = nodeLocalBoundingBox node
	local tm = node.objecttransform
	local bmin = minmax[1]*(inverse tm) 
	local bmax = minmax[2]*(inverse tm)
	local pa  = bmin *node.transform--LFD min
	local pb  = [bmin.x, bmax.y, bmin.z] *tm--LBD
	local pc  = [bmax.x, bmax.y, bmin.z] *tm--RBD
	vAB=pB-pA
	vAC=pC-pA
	-(normalize (cross vAB vAC))
)

		fn getCornerPoints node =
		(
			local node_lbb = nodeLocalBoundingBox node
			local tm = node.objecttransform --node.transform
			local bmin = node_lbb[1]*(inverse tm) 
			local bmax = node_lbb[2]*(inverse tm) 
			local p1  = bmin                    *tm --LFD min
			local p2  = [bmin.x, bmin.y, bmax.z]*tm --LFU
			local p3  = [bmin.x, bmax.y, bmax.z]*tm --LBU
			local p4 = [bmin.x, bmax.y, bmin.z]*tm --LBD
			local p5 = [bmax.x, bmax.y, bmin.z]*tm --RBD
			local p6 = bmax                    *tm --RBU max
			local p7 = [bmax.x, bmin.y, bmax.z]*tm --RFU
			local p8 = [bmax.x, bmin.y, bmin.z]*tm --RFD
			for i in #(p1,p2,p3,p4,p5,p6,p7,p8) do point pos:i
		)


get the vertex normal be getNormal(), eg :

sss= getNormal () --eg: [2,3,4]
theMatrix= matrixFromNormal (normalize sss)
--will get: theMatrix=(matrix3 [0.894427,0,-0.447214] [-0.249136,0.830455,-0.498273] [0.371391,0.557086,0.742781] [0,0,0])

then u get the 3 axis of the point . maybe right u need .
x_axis = theMatrix.row1
y_axis = theMatrix.row2
z_azis = thematrix.row3

each one will be a point3 value . are these value u need ?



	fn localMatrix p1 p2 p3 = 
	(
		local v1 = normalize (p2 - p1)
		local v3 = normalize (cross v1 (normalize (p3 - p1)))
		local v2 = normalize (cross v3 v1)
		return matrix3 v1 v2 v3 ((p1+p2+p3)/3)
	
	)
	
	fn get3PointsNormal A B C =
	(
			local V1 = B - A
			local V2 = B - C
			return acos (dot (normalize V1) (normalize V2))
	)