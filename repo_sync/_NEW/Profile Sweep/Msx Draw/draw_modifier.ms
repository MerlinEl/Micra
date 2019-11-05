delete objects
ctrlcentre = circle radius:5
addmodifier ctrlcentre (EmptyModifier ())
 
attdef = attributes bitmaptest
(
 
rollout bitmapTest "Bitmap test 9"
(
-- Local Variable Declerations
------------------------------------------
  
 local dim = 200
 local knotRad = 2.4
 
 local bgMap
 local mousePressed = false
 local lastKnotInd = [0,0]
 
 local bgColor = white
 local knotColor = red
 local knotVecColor = green
 local lineColor = blue
 
 local knotsArr = #()
 local jsPos = [0,0]
  
-- User Interface
------------------------------------------
  
 bitmap bmGraph "" width:dim height:dim
 radioButtons rbMode "" labels:#("Draw","Edit") align:#center
 radioButtons rbBezierMode "" labels:#("Bezier","Bezier Corner") align:#center
 checkBox cbHideKnots "Hide Knots" align:#center
 spinner spSteps "Steps:" range:[1,20,6] type:#integer align:#center fieldWidth:30
 button bnClear "Clear" width:100
 
-- Functions
------------------------------------------
 
 fn createBGMap =
 (
  bgMap = bitmap bmGraph.width bmGraph.height color:bgColor
 )
 
 fn round val =
 (
  if val - (floor val) < 0.5 then floor val else ceil val
 )
 
 fn lineLineIntersect pA pB pC pD = 
 (
  pA = [pA.x,pA.y,0]
  pB = [pB.x,pB.y,0]
  pC = [pC.x,pC.y,0]
  pD = [pD.x,pD.y,0]
  
  local a = pB - pA
  local b = pD - pC
  local c = pC - pA
  local cross1 = cross a b
  local cross2 = cross c b
  local n = pA + (a * ((dot cross2 cross1) / ((length cross1) ^ 2)))
  [n.x,n.y]
 )
 
 fn getSteps p1 p2 =
 (
  struct s_neighbor (
   pos,
   dist
  )
  
  local neighborsPos = #([-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1])
  local neighbors = #()
  
  for p in neighborsPos do (
   local newNeighbor = s_neighbor p (distance p2 (p1 + p)) 
   append neighbors newNeighbor
  )
  
  fn sortFn v1 v2 =
  (
   if v1.dist > v2.dist then 1
   else if v1.dist < v2.dist then -1
   else 0
  )
  
  qsort neighbors sortFn
  #(neighbors[1].pos,neighbors[2].pos)
 )
 
 fn getStep p1 p2 pt steps =
 (
  local crossPt = lineLineIntersect p1 p2 (pt + steps[1]) (pt + steps[2])
  local dist1 = distance crossPt (pt + steps[1])
  
  if dist1 < 0.5 then (
   pt + steps[1]
  ) else (
   pt + steps[2]
  )
 )
 
 fn drawDot pos rad bMap color =
 (
  for y = 0 to dim - 1 where y >= pos.y - rad and y <= pos.y + rad do (
   for x = 0 to dim - 1 where distance pos [x,y] <= rad do (
	setPixels bMap [x,y] #(color)
   )
  )
 )
 
 fn drawEdge p1 p2 color bMap =
 (
  local newPt = p1
  local steps = getSteps p1 p2
  local cnt = 0
  
  setPixels bMap newPt #(color)
  
  while newPt != p2 and cnt < dim * 2 do (
   newPt = getStep p1 p2 newPt steps
   setPixels bMap newPt #(color)
   cnt += 1
  )
  
  bMap
 )
 
 fn drawKnots bmap =
 (
  if not cbHideKnots.state and knotsArr.count > 0 then (
   for k = 1 to knotsArr.count do (
	drawDot knotsArr[k][1] knotRad bmap knotVecColor
	drawDot knotsArr[k][2] knotRad bmap knotColor
	drawDot knotsArr[k][3] knotRad bmap knotVecColor
   )
   if mousePressed and rbMode.state == 2 then (
	drawDot knotsArr[lastKnotInd.x][lastKnotInd.y] (knotRad * 1.5) bmap orange
   )
  )
  bmap
 )
 
 fn updateGraph =
 (
  local newMap = copy bgMap
  
  if knotsArr.count > 0 then (
   for k = 1 to knotsArr.count do (
	if knotsArr.count > 1 and k < knotsArr.count then (
	 local P0 = knotsArr[k][2]
	 local P1 = knotsArr[k][3]
	 local P2 = knotsArr[k + 1][1]
	 local P3 = knotsArr[k + 1][2]
	 local Pt0 = P0
	 for t = 0.0 to 1.0 by 1.0 / spSteps.value do (
	  local Pt = (1-t) ^ 3 * P0 + 3 * (1-t) ^ 2 * t * P1 + 3 * (1-t) * t ^ 2 * P2 + t ^ 3 * P3
	  Pt = [round Pt.x,round Pt.y]
	  newMap = drawEdge Pt0 Pt lineColor newMap
	  Pt0 = Pt
	 )
	)
	if not cbHideKnots.state then (
	 newMap = drawEdge knotsArr[k][1] knotsArr[k][2] knotVecColor newMap
	 newMap = drawEdge knotsArr[k][2] knotsArr[k][3] knotVecColor newMap
	)
   )
  )
  
  newMap = drawKnots newMap
	
  bmGraph.bitmap = newMap
 ) -- end updateGraph fn
 
 fn mPressed pos =
 (
  mousePressed = true
  if rbMode.state == 1 then (
   local newKnot = #()
   append newKnot (pos - bmGraph.pos - [10,0])
   append newKnot (pos - bmGraph.pos)
   append newKnot (pos - bmGraph.pos + [10,0])
   append knotsArr newKnot
   updateGraph()
  ) else (
   if knotsArr.count > 0 then (
	local lastDist = dim * 2
	for k = 1 to knotsArr.count do (
	 for i = 1 to 3 do (
	  local newDist = distance (pos - bmGraph.pos) knotsArr[k][i]
	  if newDist < lastDist then (
	   lastDist = newDist
	   lastKnotInd = [k,i]
	  )
	 )
	)
   )
  )
 )
 
 fn updateJS pos =
 (
  if mousePressed do (
   jsPos = pos - bmGraph.pos
   
   if rbMode.state == 1 then (
	knotsArr[knotsArr.count][2] = jsPos
	knotsArr[knotsArr.count][1] = jsPos - [10,0]
	knotsArr[knotsArr.count][3] = jsPos + [10,0]
   ) else (
	if lastKnotInd.y == 2 then (
	 local oldPos = knotsArr[lastKnotInd.x][lastKnotInd.y]
	 knotsArr[lastKnotInd.x][1] += jsPos - oldPos
	 knotsArr[lastKnotInd.x][3] += jsPos - oldPos
	) else (
	 if rbBezierMode.state == 1 then (
	  local otherHandleIndex = 4 - lastKnotInd.y
	  local otherHandleDist = distance knotsArr[lastKnotInd.x][2] knotsArr[lastKnotInd.x][otherHandleIndex]
	  local dir = normalize (jsPos - knotsArr[lastKnotInd.x][2])
	  local otherHandlePos = knotsArr[lastKnotInd.x][2] - dir * otherHandleDist
	  knotsArr[lastKnotInd.x][otherHandleIndex] = [round otherHandlePos.x,round otherHandlePos.y]
	 )
	)
	knotsArr[lastKnotInd.x][lastKnotInd.y] = jsPos
   )
  )
  
  updateGraph()
 )
 
 fn clearVP =
 (
  knotsArr = #()
  updateGraph()
  rbMode.state = 1
 )
 
 fn openDialog =
 (
  createDialog bitmapTest width:(dim + 10) style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing)
 )
   
 fn init =
 (
  createBGMap()
  updateGraph()
 )
  
 fn done =
 (
  -- cleanup code
  gc light:true
 )
  
-- Event Handlers
------------------------------------------
   
 on bitmapTest lbuttondown pos do mPressed pos
 on bitmapTest lbuttonup pos do mousePressed = false
 on bitmapTest mousemove pos do updateJS pos
 
 on bnClear pressed do clearVP()
 on cbHideKnots changed state do updateGraph()
 on spSteps changed val do updateGraph()
 
 on bitmapTest open do init()
 on bitmapTest close do done()
  
) -- end of rollout
  
)
custAttributes.add ctrlcentre.modifiers[1] attdef