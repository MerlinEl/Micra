$.alignToGrid #Vertex               -- align vertices to Grid
$.alignToView #Vertex               -- align vertices to View
$.movetoplane [0,0,1] 5.0 #Vertex   --move 5.0 units along +Z   [x,y,x]
$.insertVertexInFace 4 #(0.5,0,0.5) --insert new vertex
$.SetSelection #Vertex #{15,16,17}  -- slect vertices
selV = for i in $.selectedVerts collect i.index -- get number selected verices
$.selectedVerts = #{1..32}           -- slect vertices
$.verts.count                        --number of all vertices in object
$.selectedVerts.count                --number of selected vertices in object
vSel2 = (getVertSelection $) as array
vSel = polyOp.getVertSelection oSel as array
--------------------------------------------------

how do I query the position of my selected vertex?

theObj = $Box01 --some object, must evaluate to editable mesh
if classof theObj == Editable_Mesh do
(
theSelection = (getVertSelection theObj) as array
--If there is at least one selected, get the first one:
if theSelection.count > 0 do
thePoint = getVert theObj theSelection[1]
)


--Note that the position is in world coordinates.
--To get the position in local space, you could use
in coordsys theObj thePoint = getVert theObj theSelection[1]
or 
thePoint = (getVert theObj theSelection[1])* inverse theObj.transform
--If the object is not an editable mesh, it is not very probable it will have any selection, 
--but you could still access the .mesh property to get the mesh from the top of the modifier stack evaluation.
--Hope this helps.
---------------------------------------------------
--pick a vertex
fn pickAVert = (
vertPos = pickPoint snap:#3d
for i = 1 to getNumVerts $ do (
if (getVert $ i) == vertPos then (
setVertSelection $ #(i)
return i
)
)
return undefined
)
---------------------------------------------------------------
--show number of selected vertex
c = $.selectedverts.count
------------------------------------------------------------------
--move vertices
move $.selectedVerts ( [0,0,0] * inverse $.transform )
--------------------------------------------------------------------
I want to move a group of verts in world coordinates:

What gives? 
Looks like move with vertex selection works in local coordinates only.
I don't know why it is the way it is. 
Probably because sub-object selections assume you want to move in object space no matter how your object is placed in the scene, 
or because they parform the move below the transformation point on the modifier stack.

This one works in world coordinates:

move $.selectedVerts ( [0,0,0.2] * inverse $.transform ) 

What it does is assuming that the vector [0,0,0.2] IS in object space 
and transforming in out of object space by multiplying it with the inverse 
of the object transformation matrix. This gives you a new vector which is 
in world space as seen from the object's "point of view". The Move still thinks it is moving 
in local space, but the vector points in the correct world direction and fools it to move where you want.
--------------------------------------------------------------
--A Move selected vertices to X
vSel = polyOp.getVertSelection $
for i in vSel do
(
vTarget = polyop.getvert $ i 
vTarget.x = 0
polyOp.setVert $ i vTarget 
)

--B Move selected vertices to X
hGrid = grid name:"Grid_Helper" ()     --create Grid_Helper
rotate hGrid (angleaxis 90 [0,1,0])    --rotate Grid_Helper vertical
activeGrid = hGrid                   --activate Grid_Helper
$.alignToGrid #Vertex                --align vertex Grid_Helper
delete hGrid                         --delete Grid_Helper

-----------------------------------------
---Movements and Positions of Vertices---
-----------------------------------------
 
--move <vertlist> <point3 pos>
  move $.selectedVerts [-10,0,0] --move -10 units along +x
--polyOp.setVert <Poly poly> <vertlist> <point3 pos> node:<node=unsupplied>
  polyOp.setVert  $ $.selectedVerts [0,0,0] --set verts pos to [0,0,0]
--<bool>moveToPlane <point3>planeNormal <float>planeOffset <enum>mnSelLevel flags:<DWORD>
      $.movetoplane [1,0,0] -20 #Vertex --move -20 units along +x
--<bool>alignToGrid <enum>mnSelLevel [flags:<DWORD>]
	  $.alignToGrid #Vertex	  
--<bool>makePlanar <enum>mnSelLevel [flags:<DWORD>]
      $.makePlanarIn #X  
--polyOp.makeVertsPlanar <Poly poly> <vertlist>
  polyOp.makeVertsPlanar $ $.selectedVerts
--polyOp.moveVertsToPlane <Poly poly> <vertlist> <Point3 planeNormal> <float planeOffset> node:<node>
  polyOp.moveVertsToPlane $ $.selectedVerts [1,0,0] -50
--polyOp.moveVert <Poly poly> <vertlist> <point3 offset> node:<node=unsupplied>
  polyOp.moveVert $ $.selectedVerts [1,0,0]
-- 
move $.selectedVerts ( [0,0,0] * inverse $.transform )
--
in coordsys local move $.selectedVerts [-10,0,0]

