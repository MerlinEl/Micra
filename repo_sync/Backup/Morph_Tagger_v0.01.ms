--Morph Tagger

plugin simpleObject morph_tagger
	name:"MorphTagger"
	classID:#(0x3c0334b1, 0x30f5be78)
	category:"Standard Primitives"
(
	parameters main rollout:params
	(
	num_points type:#integer ui:num_points default:4
	radius type:#float ui:radius default:0
	)
	rollout params "AntiStar"
	(
		spinner num_points "Points" range:[2,100,10] type:#integer
		spinner radius "Radius" range:[0,10000,0]
	)
	 
	on buildMesh do
	(
		
		points_array = #()
		

		--Note: The code below has been taken from the
		  --How To ?Create Custom Mesh Object topic and is identical.
		vert_array = #()
		face_array = #()
		vert_count = 0
		radius2 = 10
		width = 10
		for a = 0 to 360 by 360.0/num_points do
		(
			v1 = [radius*cos(a+width),radius*sin(a+width),0]
			v2 = [radius*cos(a-width),radius*sin(a-width),0]
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
		2: (radius = abs(gridDist.y))
		/*3:	(num_points = abs(gridDist.x))*/
		3: (#stop)
	  )
	)
	)--end create
)--end plugin
