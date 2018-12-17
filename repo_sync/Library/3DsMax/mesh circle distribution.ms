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