plugin simpleObject AntiStar

name:"AntiStar"

category:"HowTo"

classID:#(0xe855567c, 0xbcd73b8b)

(

parameters main rollout:params

(

num_faces type:#integer ui:num_faces default:10

radius1 type:#float ui:radius1 default:0

radius2 type:#float ui:radius2 default:0

width type:#float ui:width default:1

)

rollout params "AntiStar"

(

spinner num_faces "# Faces" range:[2,100,10] type:#integer

spinner radius1 "Radius 1" range:[0,10000,0]

spinner radius2 "Radius 2" range:[0,10000,0]

spinner width "Width" range:[0,90,1]

)

 

on buildMesh do

(

  --Note: The code below has been taken from the

  --How To ?Create Custom Mesh Object topic and is identical.

vert_array = #()

face_array = #()

vert_count = 0

for a = 0 to 360 by 360.0/num_faces do

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

setMesh mesh verts:vert_array faces:face_array

)--end buildMesh

tool create

(

on mousePoint click do

(

case click of

(

1: coordsys grid (nodeTM.translation = gridPoint)

)

)

 

on mouseMove click do

(

case click of

  (

2: (radius1 = abs(gridDist.y))

3: (radius2 = abs(gridDist.y))

4: (width = abs(gridDist.x))

5: (#stop)

  )

)

)--end create

)--end plugin