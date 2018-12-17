-- * * * * * * * * * * * * * * * * * * * * * * *
-- *  Creates lines from an object's vertices  *
-- *  GARP - 2009                              *
-- * * * * * * * * * * * * * * * * * * * * * * *

(
global rltLinePerVertex
try destroyDialog rltLinePerVertex catch()

rollout rltLinePerVertex "Line Per Vertex" width:140
(
	spinner spnLength "Length: " range:[0, 10000, 10]
	spinner spnSegments "Segments: " range:[1, 100, 1] type:#integer
	editText edtName "Name: " text:"Guides"
	fn geometryFilter obj = superClassOf obj == GeometryClass
	pickButton btnMesh "Pick Mesh Target" filter:geometryFilter
	checkBox chkVertSel "Use Vert. Selection"
	
	on btnMesh picked obj do undo "Lines from Vertices" on
	(
		local ss = SplineShape name:edtName.text pos:obj.pos
		local nv = getNumVerts obj.mesh
		local vs = getVertSelection obj.mesh
		
		fn makeLine obj ss ind =
		(
			addNewSpline ss
			si = ss.numSplines
			p = (getVert obj.mesh ind) * obj.transform
			addKnot ss si #corner #line p
			n = (getNormal obj.mesh ind) * obj.transform - obj.pos
 			p += spnLength.value * normalize((getNormal obj.mesh ind) * obj.transform - obj.pos)
			addKnot ss si #corner #line p	
		)
		
		if chkVertSel.checked and (vs as array).count != 0 then for i in vs do makeline obj ss i
		else for i = 1 to nv do makeline obj ss i
		
		updateShape ss
		if spnSegments.value > 1 do for i = 1 to ss.numSplines do
		(
			subdivideSegment ss i 1 (spnSegments.value - 1)
			for j = 1 to numKnots ss i do setKnotType ss i j #smooth
		)
		completeRedraw()
	)
)
createDialog rltLinePerVertex
)