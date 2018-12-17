gco=modpanel.getcurrentobject()
gcs = getCurrentSelection()

fn getFirstItem theBitArray = (for i in theBitArray do return i)

fn getContinuousFaces obj outlineEdges firstFace =
	(
	continuousFaces=#{}
	facesToInspect=#{firstFace}
	while facesToInspect.numberset!=0 do (
		currentFace=getFirstItem facesToInspect
		adjacentEdges=polyOp.getEdgesUsingFace obj #{currentFace}
		if (adjacentEdges-outlineEdges).numberset==0 do continuousFaces[currentFace]=true
		for thisEdge in adjacentEdges where ( (outlineEdges*#{thisEdge}).numberset==0 ) do (
			newFace=(polyOp.getFacesUsingEdge obj #{thisEdge})-continuousFaces
			continuousFaces+=newFace
			facesToInspect+=newFace
			)
		facesToInspect[currentFace]=false
		)
	continuousFaces
	)

fn getOutlinesEdges obj theFaces =
	(
		faceEdges=polyOp.getEdgesUsingFace obj theFaces
		openEdges=(for e in faceEdges where (((polyOp.getFacesUsingEdge obj e)*theFaces).numberSet == 1) collect e)as bitarray
	)

fn getOutlineFaces obj outlineEdges =
	(
	theFaces=#{}
	facesToInspect=#{1..polyOp.getNumFaces obj}
	facesGroup=#()
	while facesToInspect.numberset!=0 do (
		currentFaces=getContinuousFaces obj outlineEdges (getFirstItem facesToInspect)
		append facesGroup currentFaces
		facesToInspect-=currentFaces
		)
	openEdgesGroup=for i=1 to facesGroup.count collect (getOutlinesEdges obj facesGroup[i])
	numberOutlineEdges=for i=1 to openEdgesGroup.count collect (openEdgesGroup[i].numberset)
	numberOutlineOpenEdges=for i=1 to openEdgesGroup.count collect ((openEdgesGroup[i]*outlineEdges).numberset)
	if (amax numberOutlineOpenEdges==amin numberOutlineOpenEdges)
		then ( theFaces=facesGroup[findItem numberOutlineEdges (amin numberOutlineEdges)] )
		else ( theFaces=facesGroup[findItem numberOutlineOpenEdges (amax numberOutlineOpenEdges)] )
	theFaces
	)

obj=selection[1]
if classof obj==editable_poly do (
	theFaces=getOutlineFaces obj (polyOp.getEdgeSelection obj)
	polyOp.setFaceSelection obj theFaces
	subObjectLevel=4
	max views redraw
	)



f= polyop.getfaceselection $
f=(modpanel.getcurrentobject()).getSelection #Face
(modpanel.getcurrentobject()).selectFaces f

setfaceSelection $ #{50..100} keep:true

All_Obj_Names =(for i in $objects collect i.name)
All_Obj_Numbers =(for i in 1 to $objects.count collect i)
Vis_Obj_Names =(for i in $objects where i.isHidden==false collect i.name)
Vis_Obj_Numbers =(for i in 1 to $objects.count where objects[i].isHidden==false collect i) 

$.mesh.numverts
$.mesh.edges.count
$.mesh.numfaces
$.Verts.count 
$.Edges.count
$.Faces.count

$.isHidden
$.isFrozen
$.isSelected

local vis_obj   = for o in Objects where not o.isHidden collect o
local sel_obj   = for o in Objects where o.isSelected collect o
local unsel_obj = for o in Objects where not o.isSelected collect o
local frez_obj  = for o in Objects where o.isFrozen collect o

clearSelection()  --Unselect All
getCurrentSelection() --Get info on a object
deselect  --Deselects given node(s)  example:(deselect $box*)
select    --Selects given node(s)  example:(select $Sphere*)
------------------------------------------------------------------------
oldEdge= for i in $.selectedEdges collect i.index -- colect numbers of selected edges
$.SetSelection #Edge #{}   -- clear edges selection
$.selectedEdges = oldEdge  -- restore edges selecion
oldVerts= for i in $.selectedVerts collect i.index -- colect numbers of selected vertices
$.SetSelection #Vertex #{} --clear vertices selection
	 = oldEdgea -- restore vertices selecion
vSel = polyOp.getVertSelection $ --colect numbers of vertices selection
------------------------------------------------------------------------
--Group all type geometry into a single object.
			geometry_array =  $Sphere* as array
			group geometry_array  name:(uniqueName "Items_001" as string)
			select $Items_*
-------------------------------------------------------------------------
actionMan.executeAction 0 "40021"  		-- Select All objects (Visible)
select $*   --Select All objects (Visible and Hiden)
---------------------------------------------------------------------------------------------
if selection.count == 1 then
----------------------------------------------------------------------
if selection.count >= 1 then
-----------------------------------------------------------------
index>GetEdgeVertex <index>edgeID <index>end
Returns the vertex index used by the specified edge. Since an edge has two vertices, the end argument is needed to define which of the two vertices of the edge to get.
Example:
p = convertToPoly(Plane())    --create a Plane, convert to Epoly
p.GetEdgeVertex 1 1 --returns vertex 6 
p.GetEdgeVertex 1 2 --returns vertex 1 
p.GetEdgeVertex 4 1 --returns vertex 1 
p.GetEdgeVertex 4 2 --returns vertex 2 
-----------------------------------------------------------------------
--convert edge selection to vertex
$.EditablePoly.ConvertSelection #Edge #Vertex
-----------------------------------------------------------------------
--convert edge selection to vertex
$.EditablePoly.ConvertSelection #Edge #Face
-----------------------------------------------------------------------
p = convertToPoly(Plane()) --create a plane, convert to EPoly
polyop.DeleteFaces p #(6) --delete a polygon
--select all polygons surrounding the deleted one
polyop.SetFaceSelection p #(1,2,3,5,6,8,9,10)
select p --select the plane
max modify mode --switch to Modify panel
subObjectLevel = 4 --go to Face level to see the selection
p.capHoles #Face --cap the hole using the selection
---------------------------------------------------------------------

--Make vertices selection planar
polyOp.makeVertsPlanar $ #{22..50}

--Move vertices to other location
polyOp.moveVert $ #{1..60} [0,10,2]

--Set vertices to other location
vSel= for i in $.selectedVerts collect i.index
polyOp.setVert $ vSel [0,10,2]
----------------------------------------------------------------------
(polyOp.getFaceSelection sel as array)[1])
polyOp.getVertSelection $
getVertSelection $
polyOp.getVertSelection $.baseobject

(polyOp.getVertSelection $.baseobject as array).count
(polyOp.getEdgeSelection $.baseobject as array).count
(polyOp.getFaceSelection $.baseobject as array).count

for i in 1 to (polyOp.getFaceSelection $ as array).count do print i

for i in 1 to (polyOp.getFaceSelection $ as array).count do print (i as string)
----------------------------------------------------------------------
set1 = selectionSets["my set 1"]
move set1 [10,0,0] --moves all the objects in the set across 10 in x.
selectionSets["new set"] = selection --snap the current selection
selectionSets["old spheres"] = $sphere* --all the current objects named "sphere*"
selectionSets[#foo] = #(obj1, obj2, obj3)
deleteItem selectionSets "old set" --delete the set named "old set"
----------------------------------------------------------------------
-- move vertices in 'mouth' named selection set
move $foo.verts[#mouth] [0,0,10]
-- select vertices in 'front verts' set
select $baz.verts["front verts"]
-- set 'baz' named selection set to given vertices
$foo.verts[#baz] = #(1,3,4,5,10)
-- set 'cursel' set to current selection
$baz.verts[#cursel] = $baz.selectedVerts
-- all the names of the vertex-level named selection sets for object $foo
$foo.verts.selSetNames
-- print out all vertex-level named selection sets
for n in $.verts.selSetNames do print $.verts[n]
----------------------------------------------------------------------

names_array = for i in $* collect i.name
sort names_array
for i in 1 to names_array.count do
(
node_by_name = getNodeByName names_array[2]
)


---Select node in pick dialog
fn AlreadySelected FilterObj =
	(
		if (FilterObj == $) then
			(return false)
			else
			(return true)
	)
Target = selectByName title:"Pick a Object Poly" buttontext:"Pick Poly" filter:AlreadySelected
---Select node in pick dialog

			

polyOp.tessellatebyface poly #selection	--selected face



		local fsel_1 = for i=1 to obj.faces.count collect i
		local esel = polyOp.getEdgeSelection obj		
		--ic cap created do select new polygons
		if not (polyOp.capHolesByEdge obj esel) do return false
		local fsel_2 = for i=1 to obj.faces.count collect i
		local fsel_3 = fsel_2 as bitarray - fsel_1 as bitarray
		polyOp.setFaceSelection obj fsel_3













