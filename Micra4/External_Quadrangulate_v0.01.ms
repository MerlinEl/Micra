(
	disablesceneredraw()
	cobjs = selection.count
	cobjset=#()
	for i = 1 to cobjs do 
	(
	cobjset[i] = selection[i]
	)
	tb = Bomb strength:0 gravity:0 detonation:0f minFragmentSize:2 maxFragmentSize:2 falloff:100 pos:[0,0,0] name:"tempbomb"
	for i = 1 to cobjs do
	(
		try
			(
				oldname = cobjset[i].name
				oldpivot = cobjset[i].pivot
				cobjset[i].name = "deleteoldmesh"
				bindSpaceWarp cobjset[i] $tempbomb
				snapshot cobjset[i] name:"tempmesh"
				select $tempmesh
				macros.run "Modifier Stack" "Convert_to_Poly"
				subobjectLevel = 2
				actionMan.executeAction 0 "40021"
				$.EditablePoly.Remove ()
				$.edgeWeldThreshold = 0.00001
				$.EditablePoly.weldFlaggedEdges ()
				subobjectLevel = 0
				$.pivot=oldpivot
				$tempmesh.name=oldname 
			)
		catch()
	)
	delete $deleteoldmesh*
	delete $tempbomb
	clearSelection()
	enablesceneredraw()
	redrawviews()
)