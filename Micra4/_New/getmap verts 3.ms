		for f=1 to obj.numFaces do
					(
					nVerts=uvwRefModUnwrap.numberPointsInFace faceIndex[i][f]
					for v=1 to nVerts do
						(
						coord=uvwRefModUnwrapgetVertexPosition 0f (uvwRefModUnwrapgetVertexIndexFromFace faceIndex[i][f] v)
						case weldType_osd.selection of
							(
							1: objModUnwrapSetVertexPosition 0f (objModUnwrapgetVertexIndexFromFace f v) coord
							default: objModUnwrapsetFaceVertex coord f v false
							)
						)
					)
					
					
					
					uvwRefModUnwrap.getVertexIndexFromFace
					
obj = $				
targetChannel = -2	
if (polyop.getMapSupport obj targetChannel) do (
					
	faces_num = polyop.getnumfaces obj
	map_verts = for f=1 to faces_num collect (polyop.getmapface obj targetChannel f)
	for v in map_verts do (
	
		tv = polyop.getmapvert node targetChannel v
	)
)