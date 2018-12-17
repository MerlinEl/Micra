-- turn off all visible edges
for f = 1 to p2.numfaces do
(
	setEdgeVis p2 f 1 true
	setEdgeVis p2 f 2 true 
	setEdgeVis p2 f 3 true
)
update p2


obj.allEdges=True --show all edges

fn getEdgesDistance obj edge1 edge2 =
	(
		local pos1=eposlibs.getAvgVertPos obj (polyOp.getEdgeVerts obj edge1)
		local pos2=eposlibs.getAvgVertPos obj (polyOp.getEdgeVerts obj edge2)
		return distance pos1 pos2
	),
	
	fn getEdgeAngle obj edge1 edge2 =
	(
		local edgeVerts=polyOp.getEdgeVerts obj edge1
		local getref
		local edge1Vect=eposlibs.getFreeEdgeNormal obj edge1
		local edge2Vect=normalize((eposlibs.getEdge obj edge2)-(eposlibs.getEdge obj edge1))
		local edge1L=length edge1Vect
		local edge2L=length edge2Vect
		local dotEdge=dot edge1Vect edge2Vect
		local edgeangle=degtorad(acos (dotEdge/(edge1L*edge2L)))
		
		if edgeangle < 0.5 then
			return edgeangle
		else
			return (1-edgeangle)
	),

	fn getAvgVertNormals obj vertlist =
	(
		local avgNormals=0
		local vertcount=0

		for i in vertlist do
		(
			avgNormals += getNormal obj i
			vertcount += 1
		)

		avgNormals = avgNormals/vertcount

		return avgNormals
	),

	fn getAvgVertPos obj vertlist =
	(
		local avgPos=0
		local vertcount=0

		for i in vertlist do
		(
			avgPos+=polyOp.getVert obj i
			vertcount+=1
		)

		avgPos = avgPos/vertcount

		return avgPos
	),

	fn getVertLocal obj vert ref =
	(
		return ((getVert obj vert)-ref)
	),
	
	fn getVertsAngle obj ref1 ref2 vert =
	(
		local ref1pos=polyOp.getVert obj ref1
		local ref2pos=polyOp.getVert obj ref2
		local vertPos=polyOp.getVert obj vert
		local vert1L=length (normalize(vertPos-ref1pos))
		local vert2L=length (normalize(ref2pos-ref1pos))
		local dotvert=dot (normalize(vertPos-ref1pos)) (normalize(ref2pos-ref1pos))
		local vertangle=degtorad(acos (dotvert/(vert1L*vert2L)))
		
		if vertangle < 0.5 then
			return vertangle
		else
			return (1-vertangle)
	),
	
		fn getFreeEdgeNormal obj edge =
	(
		local facearr=eposlibs.bitarrayToArray(polyOp.getFacesUsingEdge obj edge)
		local facepos=polyop.getfacecenter obj facearr[1]
		local edgepos=eposlibs.getEdge obj edge
		
		return normalize (edgepos - facepos)
	),
	
	
	
	
	
	
	fn CheckEdgedFacesMode =
(
	currentSel = selection as array
	max select all
	currentVisible = selection as array
	hide selection
	oldTM = viewport.getTM()
	b = box wirecolor:(color 255 0 0) 
	b.material = standardmaterial useSelfillumColor:true
	b.material.diffusecolor = b.material.selfillumcolor = (color 0 255 0) 
	select b
	max tool zoomextents
	max select none
	redrawViews()
	theBmp = gw.getViewportDIB()
	--display theBmp
	thePixels = getPixels theBmp [0,theBmp.height/2] theBmp.width
	EdgedFacesOn = false
	ShadedOn = false
	for p in thePixels do 
	(
	if p == (color 255 0 0) do EdgedFacesOn = true
	if p == (color 0 255 0) do ShadedOn = true
	)	
	delete b
	theBmp = undefined
	gc light:true
	unhide currentVisible 
	select currentSel 
	viewport.setTM oldTM 
	(EdgedFacesOn and ShadedOn)
)

print (CheckEdgedFacesMode())