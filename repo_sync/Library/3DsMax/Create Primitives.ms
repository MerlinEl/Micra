radius1 = 100
radius2 = 10
width = 10
vert_array = #()
face_array = #()
vert_count = 0
num_faces = 10

for a = 0 to 360 by 360/num_faces do
(
v1 = [radius1*cos(a+width),radius1*sin(a+width),0]
v2 = [radius1*cos(a-width),radius1*sin(a-width),0]
v3 = [radius2*cos(a),radius2*sin(a),0]
append vert_array v1
append vert_array v2
append vert_array v3

append face_array [vert_count+1,vert_count+3,vert_count+2]
vert_count += 3
)

m = mesh vertices:vert_array faces:face_array


-----------------------------------------
plugin simpleObject tower_plugin_def
name:"Tower"
classID:#(145345,543211)
category:"Scripted Primitives"
( 
parameters main rollout:params
(
height type:#worldUnits ui:height default:0
width type:#worldUnits ui:width default:0
depth type:#worldUnits ui:depth default:0
)
rollout params "Two Faces Parameters"
(
spinner height "Height" type:#worldunits range:[-1000,1000,0]
spinner width "Width" type:#worldunits range:[-1000,1000,0]
spinner depth "Depth" type:#worldunits range:[-1000,1000,0]
)
on buildMesh do
(
setMesh mesh \
verts:#([0,0,0],[width,0,0],[width,depth,0],[0,depth,0]) \
faces:#([3,2,1], [1,4,3])
extrudeFace mesh #(1,2) (height * 0.5) 40 dir:#common
extrudeFace mesh #(1,2) (height * 0.5) 50 dir:#common
)
tool create
(
on mousePoint click do
case click of
(
1: nodeTM.translation = gridPoint
3: #stop
)
on mouseMove click do
case click of
(
2: (width = gridDist.x; depth = gridDist.y)
3: height = gridDist.z
)
)
)
