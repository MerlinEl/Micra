function CreateMorphTest objectsToAdd arr_1 arr_2=
(
	format "creating morph object n - % \n" 1 to:listener							
	local morphobj = MorphObjCreate();

	MorphObj_AddPoint morphObj "p0"
	MorphObj_AddPoint morphObj "p1"
	MorphObj_AddPoint morphObj "p2"
	MorphObj_AddPoint morphObj "p3"
	MorphObj_AddPoint morphObj "p4"
	MorphObj_AddPoint morphObj "p5"

	MorphObj_AddEdge morphObj 0 1
	MorphObj_AddEdge morphObj 1 2

	for objIndex = 1 to objectsToAdd.count do
	(
		format "adding % \n" objIndex to:listener							
		MorphObj_AddTarget morphObj objectsToAdd[objIndex];
		
		if objectsToAdd[objIndex].name == "Sphere001"
		then
		(
			MorphObj_SetPointPos morphObj (objIndex-1) 0  arr_1[1]
			MorphObj_SetPointPos morphObj (objIndex-1) 1  arr_1[2]
			MorphObj_SetPointPos morphObj (objIndex-1) 2  arr_1[3]
			MorphObj_SetPointPos morphObj (objIndex-1) 3  arr_1[4]
		)
		else
		(
			MorphObj_SetPointPos morphObj (objIndex-1) 0  arr_2[1]
			MorphObj_SetPointPos morphObj (objIndex-1) 1  arr_2[2]
			MorphObj_SetPointPos morphObj (objIndex-1) 2  arr_2[3]
			MorphObj_SetPointPos morphObj (objIndex-1) 3  arr_2[4]
		)

		MorphObj_AddEdgeConstraint morphObj (objIndex-1) 0 (point3 -10 -10 -10)
		MorphObj_SetEdgeConstraintPos morphObj (objIndex-1) 0 0 (point3 10 10 10)
	)

)


s1=sphere pos:[71.7621,0.347557,24.3048] radius: 24.3048 name:"Sphere001"
s2=sphere pos:[0,0,17.9371] radius:17.9371 name:"Sphere002"
convertToPoly s1
convertToPoly s2

arr_1 =#([55.8842,-15.5303,33.6058], [88.9482,-16.8385,24.3048], [92.5075,8.94062,33.6058], [63.1691,21.093,33.6058])
arr_2 =#([-8.96855,-8.96855,30.6205], [2.13898e-007,-17.9371,17.9371], [-6.34172,15.3103,24.8013], [8.96854,8.96856,30.6205])

for i in arr_1 do point pos:i
for i in arr_2 do point pos:i
	
arr_1 =for i in arr_1 collect (i*(inverse s1.transform))
arr_2 =for i in arr_2 collect (i*(inverse s2.transform))

CreateMorphTest #(s1, s2) arr_1 arr_2
	
	
	
	
	
function testMorphMaxScript  n =
(
	-- local morphObj = 1;

	local b2 = MorphObj_AddPoint  selection[1] "point0"
		format "prase: % % \n" n nch to:listener
)

function GetMorphInfo morphObj =
(
	-- local morphObj = 1;
	
	local	nPoints = MorphObj_GetNPoints morphObj;
	
	format "NPoints % \n" nPoints to:listener		

	for i = 0 to nPoints-1 do 
	(
		format "Point %: % \n" i (MorphObj_GetPointName morphObj i)to:listener		
	)
	
	local	nEdges = MorphObj_GetNEdges morphObj;
	
	format "NEdges % \n" nEdges to:listener		

	for e = 0 to (nEdges-1) do 
	(
		local p0 = (MorphObj_GetEdgePoint0 morphObj e) ;
		local p1 = (MorphObj_GetEdgePoint1 morphObj e) ;
		
		format "Edge %: %-% \n" e (MorphObj_GetPointName morphObj p0) (MorphObj_GetPointName morphObj p1)to:listener		
	)
	
	local	nTargets = MorphObj_GetNTargets morphObj;
	
	format "NTargets % \n" nTargets to:listener		

	for t = 0 to (nTargets-1) do 
	(
		local p0 = (MorphObj_GetTarget morphObj t) ;
		local p1 = (MorphObj_GetTargetControlMesh morphObj t) ;
		
		format "Target %: %-% \n" t p0 p1 to:listener		
		
		for p = 0 to nPoints-1 do
		(
			local pointpos = MorphObj_GetPointPos morphObj t p;
			format "		point %: %\n" p pointpos to:listener							
		)	

		for e = 0 to (nEdges-1) do
		(
			local nConstr = MorphObj_GetNEdgeConstraints morphObj t e;

			for c = 0 to (nConstr-1) do
			(
				local constrPos = MorphObj_GetEdgeConstraintPos morphObj t e c;						
				format "		edge % constraint %: %\n" e c constrPos to:listener							
			)
		)	

	)

	-- local b2 = MorphObj_AddPoint  selection[1] "point0"
	-- format "prase: % % \n" n nch to:listener
)

function CreateMorphTest objectsToAdd =
(
	format "creating morph object n - % \n" 1 to:listener							
	local morphobj = MorphObjCreate();

	MorphObj_AddPoint morphObj "p0"
	MorphObj_AddPoint morphObj "p1"
	MorphObj_AddPoint morphObj "p2"
	MorphObj_AddPoint morphObj "p3"
	MorphObj_AddPoint morphObj "p4"
	MorphObj_AddPoint morphObj "p5"

	MorphObj_AddEdge morphObj 0 1
	MorphObj_AddEdge morphObj 1 2

	for objIndex = 1 to objectsToAdd.count do
	(
		format "adding % \n" objIndex to:listener							
		MorphObj_AddTarget morphObj objectsToAdd[objIndex];
		
		MorphObj_SetPointPos morphObj (objIndex-1) 0 (point3 -1 -1 0)
		MorphObj_SetPointPos morphObj (objIndex-1) 1 (point3 -1 1 0)
		MorphObj_SetPointPos morphObj (objIndex-1) 2 (point3 1 -1 0)
		MorphObj_SetPointPos morphObj (objIndex-1) 3 (point3 1 1 0)
		MorphObj_SetPointPos morphObj (objIndex-1) 4 (point3 1 -1 10)
		MorphObj_SetPointPos morphObj (objIndex-1) 5 (point3 1 1 10)

		MorphObj_AddEdgeConstraint morphObj (objIndex-1) 0 (point3 -10 -10 -10)
		MorphObj_SetEdgeConstraintPos morphObj (objIndex-1) 0 0 (point3 10 10 10)
	)

	
)
	



clearListener();

--------------------------------------------------------
-- vypise komplenti info o seleklem morph objektu
-- GetMorphInfo selection[1]

--------------------------------------------------------
-- vytvori morph z 2 az n selektlych objetu (zkouseno na 2)
-- CreateMorphTest selection;



Pozor - vsechny indexy jsou od 0 !!!!
Vsechny pozice jsou v lokalnich souradnicich objektu (control meshe)


MorphObjCreate - vytvori morph object 

MorphObj_AddPoint [MorphObj2 Obj] [String PointName]					- prida bod 
MorphObj_DelPoint [MorphObj2 Obj] [Integer PointIndex]					- smaze bod 
MorphObj_GetNPoints [MorphObj2 Obj] as Integer							- ziska pocet bodu
MorphObj_GetPointName [MorphObj2 Obj] [Integer PointIndex] As String	- vraci jmeno bodu

MorphObj_AddEdge [MorphObj2 Obj] [Integer point0] [Integer point1] As Boolean		- prida hranu z point0 do point1
MorphObj_DelEdge [MorphObj2 Obj] [Integer EdgeIndex] As Boolean						- smaze hranu EdgeIndex 
MorphObj_GetNEdges [MorphObj2 Obj] as Integer										- vraci pocet hran 
MorphObj_GetEdgePoint0 [MorphObj2 Obj] [Integer EdgeIndex] As Integer				- vrac bod 0 hrany EdgeIndex
MorphObj_GetEdgePoint1 [MorphObj2 Obj] [Integer EdgeIndex] As Integer				- vrac bod 1 hrany EdgeIndex

MorphObj_AddTarget [MorphObj2 Obj] [INode newTarget] as Bool						- prida target 
MorphObj_GetNTargets [MorphObj2 Obj] as Integer										- vraci pocet targetu
MorphObj_GetTarget [MorphObj2 Obj] [Integer TargetIndex] as INode					- vraci target
MorphObj_GetTargetControlMesh [MorphObj2 Obj] [Integer TargetIndex] as INode		- vraci target control mesh 


MorphObj_GetPointPos [MorphObj2 Obj] [Integer TargetIndex] [Integer PointIndex] as Vector3					- vraci picknuty bod na control meshi targetu
MorphObj_GetPointPos [MorphObj2 Obj] [Integer TargetIndex] [Integer PointIndex] [Point3 Pos] as Boolean		- nastavi bod na control meshi

MorphObj_GetNEdgeConstraints [MorphObj2 Obj][Integer targetIndex][Integer edgeIndex] as Integer						- vraci pocet contraintu pro prislusny target a hranu
MorphObj_AddEdgeContraint [MorphObj2 Obj][Integer targetIndex][Integer edgeIndex][point3 pos] as boolean			- prida constraint
MorphObj_DelEdgeConstraint [MorphObj2 Obj][Integer targetIndex][Integer edgeIndex][Integer constrIndex] as boolean	- smaze constraint 
MorphObj_GetEdgeConstraintPos [MorphObj2 Obj][Integer targetIndex][Integer edgeIndex][Integer constaint] as point3	- vraci pozici constraintu 
MorphObj_SetEdgeConstraintPos [MorphObj2 Obj][Integer targetIndex][Integer edgeIndex][Integer constaint][point3 pos] as boolean	- nastavi pozici constraintu - musi byt jiz pridan	