--normal matrix
$.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
--double size (row 1x,2y,3z)
$.transform = (matrix3 [2,0,0] [0,2,0] [0,0,2] [0,0,0])
--change pos (row 4 [x,y,z])
$.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [10,10,10])
--mirror in  X
$.transform = (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])
--mirror in y
$.transform = (matrix3 [1,0,0] [0,-1,0] [0,0,1] [0,0,0])
--mirror in z
$.transform = (matrix3 [1,0,0] [0,1,0] [0,0,-1] [0,0,0])

addmodifier $ (xform())
(xform()).gizmo.transform=$.transform
(xform()).gizmo.rotation = (quat 0 0 0 1)

v1 = $.dir
p1 = $.pos
p2 = p1 + v1 * 10
point pos:p2 dir:v1
tm=$.transform
----------------------
tm.row3 --dir
tm.row4 --pos
$.dir = tm.row3 --dir
-----------------------

--TRANSFORM MATRIX--
x= $.transform
(matrix3 [1,0,0] [0,1,0] [0,0,1] [-489.553,-311.048,0])

x.pos
[-489.553,-311.048,0]

x.rotation
(quat 0 0 0 1)

x.scale
[1,1,1]

x[1]
[1,0,0]
 
x.row1
[1,0,0]



x.pos
x.rotation
x.scale

--normalize
(matrixFromNormal (polyOp.getFaceNormal $ 4)*$.transform ) as eulerAngles
(eulerAngles 90 0 90)

--MatrixFromNormal
MatrixFromNormal [0,1,1]

--tm
verts=polyOp.getFaceVerts $  141
p = for i in verts collect polyOp.getVert $ i
matrix3 p[1] p[2] p[3] x
