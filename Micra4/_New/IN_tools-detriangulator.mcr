macroScript detriangulator category:"IN_tools"
 (
  Global PolyObj
  Global edges = #{}
  Global removeEdgeCandidate = #{}
  Global removeEdge = #{}
  Global edgeLens = #()
  Global checkFace = #()
------------------------------------------------------------------------------------------
  fn FilterPoly obj = classof obj==Editable_Poly
----------------------------------------------------------------------------------------
  fn edgeLen num =
   (
    local val
	if edgeLens[num]!=undefined
		then val = edgeLens[num]
		else
			(
				polyOp.setEdgeSelection PolyObj #{num}
				polyObj.convertselection #edge #vertex
				verts = (polyOp.getVertSelection polyObj) as array
				v1 = polyOp.getVert polyObj verts[1]
				v2 = polyOp.getVert polyObj verts[2]
				val = length(v1-v2)
				edgeLens[num] = val
			)
	val
   )
------------------------------------------------------------------------------------------------
/*  fn getPerim num =
   (
    local val
	polyOp.setEdgeSelection polyObj num
	polyObj.convertSelection #edge #face
	polyObj.convertSelection #face #edge
	perimIndex = (polyOp.getEdgeSelection polyObj) - #{num}
	val = 0
	for i in perimIndex do val=val+edgeLen(i)
	val
   )*/
-------------------------------------------------------------------------------------------
  rollout detri "Detriangulator v 1.0"
   (
    group "Pick poly"
	 (
	  label  PolyName ""
	  pickbutton PickPoly "Pick poly" message:"Pick" filter:FilterPoly
	 )
	group "Settings"
	 (
	  label angLab "Angle threshold" across:2 align:#left enabled:false
	  spinner angThres "" range:[0,180,45] type:#float scale:0.01 width:60 align:#right enabled:false
	  checkBox keepUV "Keep UV" checked:true enabled:false
	  checkBox keepSm "Keep smoothing" checked:true enabled:false
	 )
	label stat "select poly to process"
	button proc "Process" enabled:false
	progressbar gradusnik
	on PickPoly picked obj do
	 (
	  PolyObj = obj
	  PolyName.text = obj.name
	  angLab.enabled = true
	  angThres.enabled = true
	  keepUV.enabled = true
	  keepSm.enabled = true
	  proc.enabled = true
	  gradusnik.value = 0
	  stat.text = "ready to process"
	 )
	on proc pressed do
	 (
	  removeEdgeCandidate = #{}
	  removeEdge = #{}
	  edgeNum = (polyOp.getNumEdges polyObj)
	  edges = #{1..edgeNum}
	  for i=1 to edgeNum do edgeLens[i] = undefined
      gradusnik.value = 0
      if keepSm.checked then stat.text = "filtering smooth and topology..."
								else stat.text = "filtering topology..."
	  for i in edges do
	   (
	    checkFace = (polyOp.getFacesUsingEdge polyObj i) as array
		num = checkFace.count
		if num == 1 then edges = edges - #{i}
		            else if keepSm.checked do
					 (
					  sm1 = polyObj.getFaceSmoothingGroups checkFace[1]
					  sm2 = polyObj.getFaceSmoothingGroups checkFace[2]
					  res = bit.and sm1 sm2
					  if res == 0 then edges = edges - #{i}
					 )
		gradusnik.value = (i as float)/(edgeNum as float)*100
	   )
	  if keepUV.checked do
	   (
   		stat.text = "filtering UV..."
        for i in edges do
         (
		  checkFace = (polyOp.getFacesUsingEdge polyObj i) as array
		  arr1 = (polyOp.getMapFace polyObj 1 checkFace[1]) as bitArray
		  arr2 = (polyOp.getMapFace polyObj 1 checkFace[2]) as bitArray
		  if (((arr1+arr2) as array).count) > 4 then
		   (
			edges = edges - #{i}
           )
          gradusnik.value = (i as float)/(edgeNum as float)*100
	     )
       )
	  if angThres.value>0 do
	   (
	    stat.text = "filtering angles..."
		for i in edges do
		 (
		  polyOp.setEdgeSelection polyObj #{i}
		  polyObj.convertSelection #edge #face
		  checkFace = (polyOp.getFaceSelection polyObj) as array
		  n1 = polyOp.getFaceNormal polyObj checkFace[1]
		  n2 = polyOp.getFaceNormal polyObj checkFace[2]
		  valA = acos(dot n1 n2)
          if valA > angThres.value then edges = edges - #{i}
		  gradusnik.value = (i as float)/(edgeNum as float)*100
		 )
	   )
	  stat.text = "Detriangulation..."
	  faceNum = polyOp.getNumFaces polyObj
	  --print (edges as string)
	  for i=1 to faceNum do
	   (
		--print i
		polyOp.setfaceSelection polyObj i
		polyObj.convertSelection #face #edge
		currentEdges = (polyOp.getEdgeSelection polyObj)-(-edges)
		--print currentEdges
		perimeters = #()
		for j in currentEdges do
		 (
		  append perimeters (edgeLen(j))
		 )
		if perimeters.count!=0 do
		 (
		  maxEdgeNum = (currentEdges as array)[findItem perimeters (amax perimeters)]
          if removeEdgeCandidate[maxEdgeNum] then append removeEdge maxEdgeNum
		                                      else append removeEdgeCandidate maxEdgeNum
         )
		gradusnik.value = (i as float)/(faceNum as float)*100
		--print " "
	   )
	  proc.enabled = false
	  stat.text = "Finished"
	  angLab.enabled = false
	  angThres.enabled = false
	  keepUV.enabled = false
	  keepSm.enabled = false
	  polyOp.setEdgeSelection polyObj removeEdge
	  undo "Detriangulate" on polyObj.remove selLevel:#edge
	 )
   )
  -------------------------------------------------------------
  createDialog detri
 )
