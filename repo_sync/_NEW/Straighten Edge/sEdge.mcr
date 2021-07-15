-- Title     :  Straighten Edge
--
--              MAXscript, allows to project and place selected vertex/edges on the given straight line on the Editable Poly object, Edit Poly modifier and Editable Spline & Line objects.
--
-- Copyright :  2006-2019 veda3d.com, All rights reserved
-- Author    : Royal Ghost
--
-- Version   : 1.5.1
--				- Fixed bug when constrains mode doesn't works with Edit Poly modifier
-- Version   : 1.5.0
--				- Fixed bug in constraint mode when verteces not align properly (constraint mode works in World coordinate system)
-- Version   : 1.4.0
-- Changes   :  - Added restrictions of straight. Use SHIFT key to get straight with axis constraints (how to use axis constraints please read 3dsmax help "Using the Axis Constraints" chapter).
--				- Now snap mode and type are restored after straighten. When straighting begins, snap mode changes in active and snap type in 3D.
-- Version   : 1.3.0
-- Changes   :  - Added normalize when straight. Use ALT key to get vertex/edges normalized.
-- Version   : 1.2.0
-- Changes   :  - Added support for Editable Spline & Line objects (vertex only). Use "Straighten Edge (Spline Undo)" script for undo.
--				- Added support for Edit Poly modifier
-- Version   : 1.1.1
-- Changes   : - Fixed bug when vertices are not placed properly when Constraints is on
-- Version   : 1.1.0
-- Changes   : 	- Added support to work with edges
--				- Added support for modifiers over Editable Poly baseobject
--				- Now after vertex/edges straightend snap mode off
-- Version   : 1.0.0 - Initial release for MAX 8.
--
-- Homepage  : www.veda3d.com
---------------------------------------------------------------------------------------------
--             MODIFY THIS AT YOUR OWN RISK


macroScript Straighten_edge category:"Veda3d.com" tooltip:"Straighten Edge" buttontext:"Straighten Edge"
(
global SE_undo_arry=#() -- spline custom undo

fn vecVecIntersect p1 vec1 p2 vec2 = --https://forums.cgsociety.org/t/intersection-between-vectors-proper-method/1871560/16
( 

    if (abs (dot vec1 vec2)) > (1.0 - 0.0001) then (
    
        false -- are parallel
        
    ) else (

        vec3 = p2 - p1
        
        c1 = cross vec1 vec2
        c2 = cross vec3 vec2
        
        intersectionPoint = p1 + vec1 * ( (dot c2 c1)/((length c1)^2) )
--        dot vec1 (intersectionPoint - p1) > 0 and dot vec2 (intersectionPoint - p2) > 0
  
    )
return intersectionPoint
)

fn get_restriction =
(
sedgeXYZ = #(true,true,true)
	
	if keyboard.shiftPressed== true then
	(
	ac=toolmode.axisConstraints
		sedgeXYZ = case toolmode.axisConstraints of
		(
		#X:#(true,false,false)
		#Y:#(false,true,false)
		#Z:#(false,false,true)
		#XY:#(true,true,false)
		#YZ:#(false,true,true)
		#ZX:#(true,false,true)
		)
	)
--print (sedgeXYZ as string)
return sedgeXYZ
)

fn calc_normPointPos point_n ndist points p =
(
local sedgeXYZ = get_restriction()

p1 = points[1]
p3 = points[2]
p2 = p
m = ndist*point_n
n = (distance p1 p3)-m
	
new = [0,0,0]
new.x = (n*p1.x+m*p3.x)/(n+m)
new.y = (n*p1.y+m*p3.y)/(n+m)
new.z = (n*p1.z+m*p3.z)/(n+m)
return new
)
fn calc_pointpos p points=
(
	
local sedgeXYZ = get_restriction()


p1 = points[1]
p3 = points[2]
p2 = p

p1Proj_X = [p2.x,p1.y,p1.z]
p3Proj_X = [p2.x,p3.y,p3.z]

p1Proj_Y = [p1.x,p2.y,p1.z]
p3Proj_Y = [p3.x,p2.y,p3.z]

p1Proj_Z = [p1.x,p1.y,p2.z]
p3Proj_Z = [p3.x,p3.y,p2.z]


world_X_Vec = [1,0,0]
world_Y_Vec = [0,1,0]
world_Z_Vec = [0,0,1]

straighVec = normalize (p3-p1)

straightProz_X_Vec = normalize (p1Proj_X-p3Proj_X)
straightProz_Y_Vec = normalize (p1Proj_Y-p3Proj_Y)
straightProz_Z_Vec = normalize (p1Proj_Z-p3Proj_Z)


p2Wold_X_Vec = normalize (p2 - (p2 + world_X_Vec))
p2Wold_Y_Vec = normalize (p2 - (p2 + world_Y_Vec))
p2Wold_Z_Vec = normalize (p2 - (p2 + world_Z_Vec))	


if 	sedgeXYZ[1] == true and sedgeXYZ[2] == true and sedgeXYZ[3] == true then
(
		k = (distance p1 p3)
		a = (distance p1 p2)
		b = (distance p2 p3)

		m = (a^2-b^2+k^2)/(k+k)
		n = k-m

		newPos =[0,0,0]
		newPos.x = (n*p1.x+m*p3.x)/(n+m)
		newPos.y = (n*p1.y+m*p3.y)/(n+m)
		newPos.z = (n*p1.z+m*p3.z)/(n+m)
)
else
(
	newPos = copy p2

	if sedgeXYZ[1] == true then --X
	(
	projIntersectPoint = vecVecIntersect p1Proj_X straightProz_X_Vec p2 p2Wold_Z_Vec
	projIntersectPoint_X_Vec = normalize (projIntersectPoint - (projIntersectPoint+world_X_Vec))
	newIntersectPoint = vecVecIntersect p1 straighVec projIntersectPoint projIntersectPoint_X_Vec
	newPos.x = newIntersectPoint.x
	)	
	if sedgeXYZ[2] == true then --Y
	(
	projIntersectPoint = vecVecIntersect p1Proj_Y straightProz_Y_Vec p2 p2Wold_Z_Vec
	projIntersectPoint_Y_Vec = normalize (projIntersectPoint - (projIntersectPoint+world_Y_Vec))
	newIntersectPoint = vecVecIntersect p1 straighVec projIntersectPoint projIntersectPoint_Y_Vec
	newPos.y = newIntersectPoint.y
	)	
	if sedgeXYZ[3] == true then --Z
	(
	projIntersectPoint = vecVecIntersect p1Proj_Z straightProz_Z_Vec p2 p2Wold_Y_Vec
	projIntersectPoint_Z_Vec = normalize (projIntersectPoint - (projIntersectPoint+world_Z_Vec))
	newIntersectPoint = vecVecIntersect p1 straighVec projIntersectPoint projIntersectPoint_Z_Vec
	newPos.z = newIntersectPoint.z
	)
)
		
return newPos
)

fn pick_points =
(
snpM = snapMode.active
snpT = snapMode.type
snapMode.active=true
snapMode.type = #3D

points_arry=#()
p1 = undefined
p3 = undefined

p1 = pickPoint snap:#3d 
if classof p1 == point3 then p2 = pickPoint snap:#3d rubberBand:p1 
points_arry = #(p1,p2)
snapMode.active=snpM
try snapMode.type=snpT catch() -- undefined when file loaded, bug?!

return points_arry
)

-----------------------------------------------------------------------------------------------------------------
-- editable poly fn
fn edges2vertex edges_arry polyObj =
(
vert_arry=#()
edges_arry = edges_arry as array
	
	for k = 1 to edges_arry.count do
	(
	v = polyOp.getEdgeVerts polyObj edges_arry[k]
	append vert_arry v[1]
	append vert_arry v[2]
	)
vert_arry = vert_arry as bitarray
vert_arry = vert_arry as array
return vert_arry
)

fn get_vertex points polyObj =
(
vert_arry=#()
sl = getSelectionLevel polyObj

	vert_arry = case sl of
	(
	#vertex:polyop.getVertSelection polyObj
	#edge:edges2vertex (polyop.getEdgeSelection polyObj) polyObj
	default:#()
	)
vert_arry = vert_arry as array
return vert_arry
)

fn set_vertex points sel_arry obj polyObj=
(
undo on
(
if keyboard.altPressed== true then
(
	ndist_arry=#()
	sdist_arry=#()
		for k = 1 to sel_arry.count do
		(
		pos = polyOp.getVert polyObj sel_arry[k] node:obj
		newpos = calc_pointpos pos points
		newdist=distance points[1] newpos
		append ndist_arry newdist
		append sdist_arry newdist
		)
		sdist_arry = sort sdist_arry
		normalized_dist=(distance points[1] points[2])/(sel_arry.count+1)
		for k = 1 to sel_arry.count do
		(
		n = findItem ndist_arry sdist_arry[k]
		pos = polyOp.getVert polyObj n node:obj
		newpos = calc_normPointPos n normalized_dist points pos
		polyOp.setVert polyObj sel_arry[k] newpos node:obj	
		)
) --alt pressed
else
(
		for k = 1 to sel_arry.count do
		(
		pos = polyOp.getVert polyObj sel_arry[k] node:obj
		newpos = calc_pointpos pos points
		polyOp.setVert polyObj sel_arry[k] newpos node:obj
		)	
)
) --undo
)
-----------------------------------------------------------------------------------------------------------------
-- Spline fn
fn get_selknots points spline =
(
if keyboard.altPressed== true then
(
knotsel_arry=#()
ndist_arry=#()
sdist_arry=#()
--undo_arry=#()
	for i = 1 to (numSplines spline) do
	(
	sel_arry=#()
	sel_arry = getKnotSelection spline i
		
		for k = 1 to sel_arry.count do
		(
		pos = getKnotPoint spline i sel_arry[k]
--		print sel_arry[k]
-- custom undo
		p_arry=#(spline,i,sel_arry[k],pos)
		append SE_undo_arry p_arry		
		newpos = calc_pointpos pos points
		newdist=distance points[1] newpos
		append ndist_arry newdist
		append sdist_arry newdist
		)
		sdist_arry = sort sdist_arry
		normalized_dist=(distance points[1] points[2])/(sel_arry.count+1)
		for k = 1 to sel_arry.count do
		(
		n = findItem ndist_arry sdist_arry[k]
		pos = getKnotPoint spline i n
		newpos = calc_normPointPos n normalized_dist points pos
		setKnotPoint spline i sel_arry[k] newpos
		)
	)
)	
else
(
	for i = 1 to (numSplines spline) do
	(
	sel_arry=#()
	sel_arry = getKnotSelection spline i
		
		for k = 1 to sel_arry.count do
		(
		pos = getKnotPoint spline i sel_arry[k]
--		print sel_arry[k]
-- custom undo
		p_arry=#(spline,i,sel_arry[k],pos)
		append SE_undo_arry p_arry		
		newpos = calc_pointpos pos points
		setKnotPoint spline i sel_arry[k] newpos
		)
	)	
)
)
-----------------------------------------------------------------------------------------------------------------
-- Edit Poly fn
fn ep_get_vertex points polyObj =
(
vert_arry=#()
verts_barry=polyObj.GetSelection #Vertex -- backup org vertex selection
	
sl = getSelectionLevel polyObj

	vert_arry = case sl of
	(
	#vertex:polyObj.GetSelection #Vertex
	#edge:
			(
			polyObj.ConvertSelection #Edge #Vertex
			polyObj.GetSelection #Vertex
			)
	default:#()
	)
polyObj.SetSelection #Vertex verts_barry --restore org vertex selection
vert_arry = vert_arry as array
return vert_arry
)
-----------------------------------------------------------------------------------------------------------------

on execute do
(
if selection.count == 1 then
	(
	if (classof (modPanel.getCurrentObject())) == Edit_Poly then
		(
		polyObj = modPanel.getCurrentObject()
		)
		else
		(
		polyObj = $.baseobject
		)

		objClass	= classof polyObj		
		objType = case objClass of
		(
			Editable_Poly:(
								setWaitCursor()
								with redraw off	
								obj=$
									if (getSelectionLevel polyObj) == #vertex or (getSelectionLevel polyObj) == #edge then
									( 
									points = pick_points()
								
										if classof points[1] == point3 and classof points[2] == point3 then
										(
										verts = get_vertex points polyObj
											
											if verts.count != 0 then
											(
											cur_const = getProperty polyobj #constrainType
											setProperty polyobj #constrainType 0
											set_vertex points verts obj polyObj
											setProperty polyobj #constrainType cur_const
											-- bug?!
											--	max move
											--
											)
											else
											(
											messagebox "Select Some Vertex Or Edges" title:"Straighten edge"
											)
										)
										setArrowCursor()
										)
										else
										(
										messagebox "Activate Vertex/Edge sub-object level" title:"Straighten edge"
										)
								)
			line:(
					setWaitCursor()
					with redraw off	
					spline=$
					points = pick_points()
					if classof points[1] == point3 and classof points[2] == point3 then
					(
						get_selknots points spline
						updateShape spline
					)
					setArrowCursor()				
				  )
			SplineShape:(
					setWaitCursor()
					with redraw off	
					spline=$
					points = pick_points()
					if classof points[1] == point3 and classof points[2] == point3 then
					(
						get_selknots points spline
						updateShape spline
					)
					setArrowCursor()				
				  )  
			Edit_Poly:(
								setWaitCursor()
						--		with redraw off	
									if (getSelectionLevel polyObj) == #vertex or (getSelectionLevel polyObj) == #edge then
									 (
										points = pick_points()
										 	
										if classof points[1] == point3 and classof points[2] == point3 then
										(
											with redraw off
											sel_arry=#()
											ndist_arry=#()
											sdist_arry=#()
											verts_arry=#()
											sl = polyObj.GetEPolySelLevel()
											verts_barry = polyObj.GetSelection #Vertex
											verts = ep_get_vertex points polyObj
											sel_arry = ep_get_vertex points polyObj
											if verts.count != 0 then
											(
												if keyboard.altPressed== true then
												(
													for i in verts do
													(
													polyObj.SetEPolySelLevel #vertex
													polyObj.SetSelection #Vertex #{}
													polyobj.Select #Vertex #{i}
													pos= polyObj.GetVertex i 
													newpos = calc_pointpos pos points
													newdist=distance points[1] newpos
													append ndist_arry newdist
													append sdist_arry newdist
													append verts_arry i
													)
													sdist_arry = sort sdist_arry
													normalized_dist=(distance points[1] points[2])/(sel_arry.count+1)
													for k = 1 to sel_arry.count do
													(
													n = findItem ndist_arry sdist_arry[k]
													polyObj.SetEPolySelLevel #vertex
													polyObj.SetSelection #Vertex #{}
													polyobj.Select #Vertex #{verts_arry[k]}
													pos= polyObj.GetVertex verts_arry[k]
													newpos = calc_normPointPos n normalized_dist points pos
													polyObj.SetOperation #Transform
													polyObj.MoveSelection (newpos-pos) 
													polyObj.Commit()
													)
													polyObj.SetSelection #Vertex verts_barry -- restore selection
													polyObj.SetEPolySelLevel sl
													redrawviews()
											    )
												else
												(
													for i in verts do
													(
													polyObj.SetEPolySelLevel #vertex
													polyObj.SetSelection #Vertex #{}
													polyobj.Select #Vertex #{i}
													pos= polyObj.GetVertex i 
													newpos = calc_pointpos pos points
													polyObj.SetOperation #Transform
													polyObj.MoveSelection (newpos-pos) 
													polyObj.Commit()
													)
													polyObj.SetSelection #Vertex verts_barry -- restore selection
													polyObj.SetEPolySelLevel sl
													redrawviews()
													--)													
												)
											)
										)
										setArrowCursor()
										)
										else
										(
										messagebox "Activate Vertex/Edge sub-object level" title:"Straighten edge"
										)	
						 )
			default:(
						messagebox "Select Editable Poly/Edit Poly modifier/Shape Object" title:"Straighten edge"
						)
	)
	)
	else
	(
	messagebox "Select Editable Poly/Edit Poly modifier/Shape Object" title:"Straighten edge"
	)
	) --execute
) -- end script

macroScript Straighten_edge_spline_undo category:"Veda3d.com" tooltip:"Straighten Edge (Spline Undo)" buttontext:"Straighten Edge (Spline Undo)"
(

fn restore_knots =
(

	if SE_undo_arry != undefined and SE_undo_arry != #() then
	(
		for i = 1 to SE_undo_arry.count do
		(
		cur = SE_undo_arry[i]
		setKnotPoint cur[1] cur[2] cur[3] cur[4]
		updateShape cur[1]
		)
	)

)
restore_knots()
)